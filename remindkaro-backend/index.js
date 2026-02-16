// =======================================
// LOAD ENV VARIABLES FIRST
// =======================================
require("dotenv").config();

const express = require("express");
const cors = require("cors");
const { Pool } = require("pg");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");

const app = express();

// =======================================
// UTILITY FUNCTIONS
// =======================================
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// =======================================
// NODEMAILER SETUP
// =======================================
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// =======================================
// MIDDLEWARE
// =======================================
app.use(express.json());
app.use(cors());

// =======================================
// DATABASE CONNECTION
// =======================================
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// Test DB connection on server start
pool.connect()
  .then(() => console.log("✅ PostgreSQL Connected"))
  .catch(err => console.error("❌ DB Connection Error:", err.message));


// =======================================
// JWT AUTH MIDDLEWARE
// =======================================
function authenticateToken(req, res, next) {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ message: "Authorization header missing ❌" });
  }

  if (!authHeader.startsWith("Bearer ")) {
    return res.status(401).json({ message: "Invalid token format ❌" });
  }

  const token = authHeader.split(" ")[1];

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ message: "Invalid or expired token ❌" });
    }

    req.user = decoded;
    next();
  });
}


// =======================================
// TEST DB ROUTE
// =======================================
app.get("/test-db", async (req, res) => {
  try {
    const result = await pool.query("SELECT NOW()");
    res.json({
      message: "Database connected ✅",
      time: result.rows[0],
    });
  } catch (err) {
    res.status(500).json({
      error: "Database connection failed ❌",
      details: err.message,
    });
  }
});


// =======================================
// SIGNUP ROUTE
// =======================================
app.post("/signup", async (req, res) => {
  try {
    const { name, email, password, mobile_number } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        message: "Name, email and password are required ❌",
      });
    }

    // Check if user exists
    const existingUser = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (existingUser.rows.length > 0) {
      return res.status(400).json({
        message: "Email already registered ❌",
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Insert new user
    const newUser = await pool.query(
      `INSERT INTO users (name, email, password, mobile_number)
       VALUES ($1, $2, $3, $4)
       RETURNING user_id, name, email, mobile_number`,
      [name, email, hashedPassword, mobile_number]
    );

    // Generate OTP
    const otp = generateOTP();
    const expiresAt = new Date(Date.now() + 5 * 60 * 1000); // 5 minutes

    // Save OTP in DB
    await pool.query(
      "INSERT INTO otp_verifications (email, otp, expires_at) VALUES ($1, $2, $3)",
      [email, otp, expiresAt]
    );

    // Send OTP Email
    try {
      await transporter.sendMail({
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Verify your RemindKaro account",
        text: `Your OTP is ${otp}. It will expire in 5 minutes.`,
        html: `
          <h2>Email Verification</h2>
          <p>Your OTP is: <strong>${otp}</strong></p>
          <p>This OTP will expire in 5 minutes.</p>
          <p>Do not share this OTP with anyone.</p>
        `,
      });
      console.log("✅ OTP sent to:", email);
    } catch (emailError) {
      console.error("❌ Email send error:", emailError.message);
    }

    res.status(201).json({
      message: "User registered successfully ✅. Please verify your email.",
      user: newUser.rows[0],
      otp: otp, // ✅ OTP included for testing (remove in production)
      note: "OTP has been sent to your email. It expires in 5 minutes.",
    });

  } catch (err) {
    console.error("Signup error:", err);
    res.status(500).json({
      message: "Server error ❌",
      error: err.message,
    });
  }
});


// =======================================
// OTP VERIFICATION ROUTE
// =======================================
app.post("/verify-otp", async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({ message: "Email and OTP required ❌" });
    }

    console.log(`Verifying OTP for ${email}: ${otp}`);

    // Find matching OTP
    const result = await pool.query(
      "SELECT * FROM otp_verifications WHERE email = $1 AND otp = $2 ORDER BY created_at DESC LIMIT 1",
      [email, otp]
    );

    console.log(`OTP Query Result:`, result.rows);

    if (result.rows.length === 0) {
      // Debug: show what OTPs exist for this email
      const debugResult = await pool.query(
        "SELECT email, otp, expires_at FROM otp_verifications WHERE email = $1 ORDER BY created_at DESC LIMIT 3",
        [email]
      );
      console.log(`Available OTPs for ${email}:`, debugResult.rows);
      
      return res.status(400).json({ 
        message: "Invalid OTP ❌",
        debug: {
          providedOTP: otp,
          availableOTPs: debugResult.rows.map(r => ({ otp: r.otp, expires_at: r.expires_at }))
        }
      });
    }

    const record = result.rows[0];

    // Check if OTP expired
    if (new Date() > new Date(record.expires_at)) {
      return res.status(400).json({ message: "OTP expired ❌" });
    }

    // Mark user as verified
    await pool.query(
      "UPDATE users SET is_email_verified = TRUE WHERE email = $1",
      [email]
    );

    // Delete used OTP
    await pool.query(
      "DELETE FROM otp_verifications WHERE email = $1 AND otp = $2",
      [email, otp]
    );

    res.json({ message: "Email verified successfully ✅" });

  } catch (err) {
    console.error("OTP verification error:", err);
    res.status(500).json({
      message: "Server error ❌",
      error: err.message,
    });
  }
});


// =======================================
// DEBUG: GET OTP ROUTE (FOR TESTING ONLY)
// =======================================
app.get("/get-otp/:email", async (req, res) => {
  try {
    const { email } = req.params;
    
    const result = await pool.query(
      "SELECT otp, expires_at FROM otp_verifications WHERE email = $1 ORDER BY created_at DESC LIMIT 1",
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ message: "No OTP found for this email ❌" });
    }

    const record = result.rows[0];
    const isExpired = new Date() > new Date(record.expires_at);

    res.json({ 
      email, 
      otp: record.otp,
      expires_at: record.expires_at,
      expired: isExpired
    });

  } catch (err) {
    res.status(500).json({
      message: "Error fetching OTP ❌",
      error: err.message,
    });
  }
});



// =======================================
// LOGIN ROUTE
// =======================================
app.post("/login", async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        message: "Email and password required ❌",
      });
    }

    const userResult = await pool.query(
      "SELECT * FROM users WHERE email = $1",
      [email]
    );

    if (userResult.rows.length === 0) {
      return res.status(400).json({
        message: "Invalid email or password ❌",
      });
    }

    const user = userResult.rows[0];

    // Compare password
    const isMatch = await bcrypt.compare(password, user.password);

    if (!isMatch) {
      return res.status(400).json({
        message: "Invalid email or password ❌",
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { user_id: user.user_id, email: user.email },
      process.env.JWT_SECRET,
      { expiresIn: "1h" }
    );

    res.json({
      message: "Login successful ✅",
      token,
      user: {
        user_id: user.user_id,
        name: user.name,
        email: user.email,
        mobile_number: user.mobile_number,
      },
    });

  } catch (err) {
    console.error("Login error:", err);
    res.status(500).json({
      message: "Server error ❌",
      error: err.message,
    });
  }
});


// =======================================
// PROTECTED PROFILE ROUTE
// =======================================
app.get("/profile", authenticateToken, async (req, res) => {
  try {
    const userId = req.user.user_id;

    const result = await pool.query(
      "SELECT user_id, name, email, mobile_number FROM users WHERE user_id = $1",
      [userId]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({
        message: "User not found ❌",
      });
    }

    res.status(200).json({
      message: "Profile fetched successfully ✅",
      user: result.rows[0],
    });

  } catch (err) {
    console.error("Profile error:", err);
    res.status(500).json({
      message: "Server error ❌",
      error: err.message,
    });
  }
});


// =======================================
// TEST PROFILE ROUTE (PUBLIC - NO AUTH)
// =======================================
app.get("/profile-test", async (req, res) => {
  res.json({
    message: "Profile route is working ✅",
    note: "Use /profile with Authorization Bearer token to get actual user data",
  });
});


// =======================================
// ROOT ROUTE
// =======================================
app.get("/", (req, res) => {
  res.send("Remind Karo Backend Running 🚀");
});


// =======================================
// TEST ROUTE (NO AUTH REQUIRED)
// =======================================
app.get("/check", (req, res) => {
  res.json({
    message: "Server is running ✅",
    timestamp: new Date().toISOString(),
  });
});


// =======================================
// 404 FALLBACK ROUTE
// =======================================
app.use((req, res) => {
  res.status(404).json({
    message: "Route not found ❌",
    path: req.path,
    method: req.method,
  });
});


// =======================================
// START SERVER
// =======================================
const PORT = process.env.PORT || 5000;

app.listen(PORT, () => {
  console.log("\n🚀 Server running on port", PORT);
  console.log("📍 Root: http://localhost:" + PORT + "/");
  console.log("📍 Test DB: http://localhost:" + PORT + "/test-db");
  console.log("📍 Check: http://localhost:" + PORT + "/check");
  console.log("📍 Profile (Protected): http://localhost:" + PORT + "/profile");
  console.log("\n⚠️  Note: /profile requires Authorization Bearer token");
});
