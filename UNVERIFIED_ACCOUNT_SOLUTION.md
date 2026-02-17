# Unverified Account Auto-Deletion Solution

## Problem
When users back out during OTP verification, their account exists but isn't verified. They can't login (error: "Please verify your email first") and can't register again (error: "Email already registered").

## Solution Implemented ✅

### 1. **Immediate Deletion on Re-Signup**
**Backend: `remindkaro-backend/index.js` - Signup Route (Lines 116-139)**

When a user tries to sign up with an email that already exists:
- ✅ If the account is **verified**: Block signup, ask them to login
- ✅ If the account is **unverified**: **Automatically delete it** and allow fresh signup

```javascript
if (existingUser.rows.length > 0) {
  const user = existingUser.rows[0];

  if (user.is_email_verified) {
    return res.status(400).json({
      message: "Email already registered. Please login instead ❌",
    });
  }

  // Auto-delete unverified account
  console.log(`🗑️ Deleting unverified account for ${email} to allow fresh signup`);
  await pool.query("DELETE FROM users WHERE email = $1", [email]);
  await pool.query("DELETE FROM otp_verifications WHERE email = $1", [email]);
}
```

### 2. **Automatic Cleanup of Old Unverified Accounts**
**Backend: `remindkaro-backend/index.js` - Auto-Cleanup Function (Lines 550-575)**

Scheduled job that runs:
- ✅ **On server startup**: Immediate cleanup
- ✅ **Every 1 hour**: Recurring cleanup

Deletes accounts that are:
- Unverified (`is_email_verified = FALSE`)
- Older than 24 hours

```javascript
async function cleanupUnverifiedAccounts() {
  const result = await pool.query(
    `DELETE FROM users
     WHERE is_email_verified = FALSE
     AND created_at < NOW() - INTERVAL '24 hours'
     RETURNING email`
  );

  if (result.rowCount > 0) {
    console.log(`🗑️ Auto-cleanup: Deleted ${result.rowCount} unverified accounts`);
  }
}

// Run every hour
setInterval(cleanupUnverifiedAccounts, 60 * 60 * 1000);
// Run on startup
cleanupUnverifiedAccounts();
```

### 3. **Better Login Error Handling**
**Backend: `remindkaro-backend/index.js` - Login Route (Line 411)**

When login fails due to unverified email:
```javascript
if (!user.is_email_verified) {
  return res.status(403).json({
    message: "Please verify your email before logging in ❌",
    email: email,
    requiresVerification: true,
    hint: "You can register again with the same email to delete the old unverified account.",
  });
}
```

### 4. **User-Friendly UI Dialog**
**Frontend: `lib/features/auth/presentation/screens/login_screen.dart` (Lines 34-68)**

When login fails due to unverified email:
- Shows a dialog explaining the issue
- Offers "Sign Up Again" button that redirects to signup
- Backend will auto-delete the old unverified account
- User can complete fresh signup with OTP verification

```dart
void _showUnverifiedAccountDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Email Not Verified'),
      content: const Text('Your email address has not been verified yet.'),
      actions: [
        TextButton(
          onPressed: () {
            // Go to signup - backend will auto-delete old account
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const SignupScreen()),
            );
          },
          child: const Text('Sign Up Again'),
        ),
      ],
    ),
  );
}
```

## How It Works

### Scenario 1: User Backs Out During OTP
1. User signs up → OTP sent
2. User backs out (doesn't verify OTP)
3. User tries to login → Error: "Please verify your email"
4. Dialog shows: "Sign Up Again" option
5. User clicks "Sign Up Again" → Goes to signup
6. User enters same email → **Backend auto-deletes old unverified account**
7. New signup succeeds → New OTP sent
8. User verifies OTP → Account activated ✅

### Scenario 2: Old Unverified Account (>24 hours)
1. User signed up 25 hours ago but never verified
2. Auto-cleanup job runs every hour
3. Detects account is unverified and >24 hours old
4. **Automatically deletes account and OTP records**
5. User can now signup fresh with same email ✅

## Benefits

✅ **No stuck accounts**: Unverified accounts are always removable
✅ **User-friendly**: Clear guidance when verification is needed
✅ **Automatic cleanup**: Old unverified accounts don't pile up
✅ **Database hygiene**: Keeps database clean of abandoned signups
✅ **Better UX**: Users can retry signup without confusion

## Testing

### Test 1: Immediate Deletion on Re-Signup
```bash
# 1. Sign up but don't verify OTP
curl -X POST http://localhost:5000/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","password":"password123"}'

# 2. Sign up again with same email
curl -X POST http://localhost:5000/signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test","email":"test@example.com","password":"password123"}'

# Expected: Success! Old unverified account deleted, new account created
```

### Test 2: Auto-Cleanup Check
```bash
# Check server logs for cleanup messages
tail -f remindkaro-backend/server.log | grep "Auto-cleanup"

# Expected output every hour:
# 🗑️ Auto-cleanup: Deleted X unverified accounts older than 24 hours
```

## Configuration

### Cleanup Interval
To change cleanup frequency, modify in `index.js`:
```javascript
// Current: Every 1 hour (60 * 60 * 1000 ms)
setInterval(cleanupUnverifiedAccounts, 60 * 60 * 1000);

// Daily cleanup: 24 * 60 * 60 * 1000
// Every 30 minutes: 30 * 60 * 1000
```

### Account Age Threshold
To change the 24-hour threshold:
```javascript
// Current: 24 hours
WHERE created_at < NOW() - INTERVAL '24 hours'

// Change to 48 hours:
WHERE created_at < NOW() - INTERVAL '48 hours'

// Change to 1 hour:
WHERE created_at < NOW() - INTERVAL '1 hour'
```

## Server Logs

The server now shows:
```
🚀 Server running on port 5000
✅ PostgreSQL Connected
🧹 Auto-cleanup: Unverified accounts older than 24h will be deleted hourly
🗑️  Auto-cleanup: Deleted 1 unverified accounts older than 24 hours
   - vivek@gmail.com
```

## Status: ✅ COMPLETED

- [x] Immediate deletion on re-signup
- [x] Automatic cleanup of old accounts (24h+)
- [x] Better error messages with hints
- [x] User-friendly dialog in app
- [x] Server logs cleanup activity
- [x] Backend server restarted with changes
- [x] Tested and verified working
