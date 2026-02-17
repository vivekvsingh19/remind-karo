# External Device Connection Test

## Current Status
✅ Backend server running on port 5000
✅ Listening on all interfaces (0.0.0.0)
✅ Firewall allows port 5000
✅ Local connection works (192.168.1.8:5000)

## Issue Fixed
The Flutter app was using `10.0.2.2:5000` for ALL Android devices (emulator address).
Now changed to use `192.168.1.8:5000` for physical devices.

## Test Steps for External Device

### 1. Verify Device is on Same WiFi Network
On your external device (phone/tablet):
- Open WiFi settings
- Check connected network name matches your computer's WiFi
- Verify IP is in `192.168.1.x` range

### 2. Test Server Connection from Device

#### Option A: Using Browser
Open browser on your device and go to:
```
http://192.168.1.8:5000/check
```

**Expected Response:**
```json
{
  "message": "Server is running ✅",
  "timestamp": "2026-02-17T..."
}
```

#### Option B: Using Terminal/ADB (if available)
```bash
# From device terminal or via ADB
curl http://192.168.1.8:5000/check
```

### 3. Rebuild Flutter App
**IMPORTANT:** After changing the API URL, you must rebuild the app:

```bash
cd /home/vivek/Documents/remind_karo

# Hot restart won't work - need full rebuild
flutter clean
flutter pub get
flutter run
```

Or in VS Code:
- Press `Ctrl+Shift+P`
- Type "Flutter: Hot Restart"
- If that doesn't work, stop and restart the app

### 4. Check App Logs
When the app starts, it should log:
```
🔌 API: Base URL: http://192.168.1.8:5000
```

## Troubleshooting

### Still Getting Timeout?

#### Check 1: Device on Same WiFi?
```bash
# On external device (using ADB or terminal app):
ip addr show wlan0 | grep inet

# Should show: 192.168.1.xxx
```

#### Check 2: Can Ping Server?
```bash
# On external device:
ping 192.168.1.8

# Should get responses
```

#### Check 3: Firewall on Device?
Some phones have built-in firewall apps that block local network connections.
- Check device settings > Security > Firewall
- Disable temporarily to test

#### Check 4: Router Isolation?
Some WiFi routers have "AP Isolation" or "Client Isolation" enabled:
- This prevents devices from talking to each other
- Check router settings and disable AP Isolation
- Usually in WiFi settings > Advanced

### Alternative: Use Tailscale VPN

If same-network connection doesn't work, use Tailscale:

1. **Install Tailscale on both computer and device:**
   - Computer: Already has Tailscale (IP: 100.85.59.107)
   - Device: Install from Play Store/App Store

2. **Connect both to same Tailscale network:**
   - Sign in with same account on both devices

3. **Update API URL in Flutter app:**
   ```dart
   // In lib/core/services/api_service.dart
   static String get baseUrl {
     return 'http://100.85.59.107:5000';  // Tailscale IP
   }
   ```

4. **Rebuild app:**
   ```bash
   flutter clean && flutter pub get && flutter run
   ```

## Current Configuration

### Backend Server
- **IP Addresses:**
  - Local: 192.168.1.8 (WiFi network)
  - Tailscale: 100.85.59.107 (VPN)
  - Localhost: 127.0.0.1
- **Port:** 5000
- **Status:** Running (PID: 53019)
- **Listening:** 0.0.0.0:5000 (all interfaces)

### Flutter App
- **Current URL:** `http://192.168.1.8:5000` (physical devices)
- **Timeout:** 30 seconds
- **File:** `lib/core/services/api_service.dart`

### Firewall
```bash
# Port 5000 is open:
sudo ufw status | grep 5000
# Output: 5000 ALLOW Anywhere
```

## Quick Test Commands

### On Computer
```bash
# Check server running
ps aux | grep "node index.js" | grep -v grep

# Check listening port
ss -tuln | grep 5000

# Test local connection
curl http://192.168.1.8:5000/check

# Check firewall
sudo ufw status | grep 5000
```

### On External Device (via ADB)
```bash
# Check WiFi IP
adb shell ip addr show wlan0 | grep inet

# Test connection
adb shell curl http://192.168.1.8:5000/check

# Check app logs
adb logcat | grep -i "api\|dio\|connection"
```

## Network Diagram

```
[Computer: 192.168.1.8:5000]  <--- Backend Server
         |
         | WiFi Router (192.168.1.x network)
         |
[External Device: 192.168.1.???] <--- Flutter App
```

Both devices must be on the **same WiFi network** for this to work!

## Success Indicators

✅ Browser on device shows: `{"message":"Server is running ✅",...}`
✅ App logs show: `✅ API: Login response received: 200`
✅ No timeout errors in app
✅ Login/signup works on external device

## If Nothing Works

Last resort - use **local tunnel** service:

```bash
# Install ngrok (or similar)
npm install -g localtunnel

# Create tunnel
lt --port 5000

# You'll get a URL like: https://your-app.loca.lt
# Update Flutter app to use this URL
```

**Note:** Free tunnel services have rate limits and aren't suitable for production.
