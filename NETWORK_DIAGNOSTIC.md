# Network Diagnostic Guide

## Server Status ✅
- **Backend Server**: Running (PID 29440)
- **Listening on**: 0.0.0.0:5000 (all interfaces)
- **Local IP**: 192.168.1.8:5000
- **Remote IP**: 100.85.59.107:5000 (Tailscale VPN)

## If External Device is Timing Out:

### Step 1: Check Device Network
On your external device (phone/tablet), determine what network you're on:
- **Same WiFi as computer?** → Network shows "192.168.1.x"
- **Different WiFi?** → Network shows different IP range
- **Mobile data?** → No WiFi connection

### Step 2: Test Connectivity
**On your external device, open a terminal/command prompt:**

#### If on same WiFi (192.168.1.x):
```bash
# Test if server is reachable
ping 192.168.1.8

# Test if port is open
curl -v http://192.168.1.8:5000/check
```

#### If on different network or using mobile data:
```bash
# Test via Tailscale VPN
curl -v http://100.85.59.107:5000/check
```

### Step 3: Solutions

#### ✅ **Same WiFi Network** (Recommended)
- Ensure device connected to **same WiFi** as computer
- Use: `http://192.168.1.8:5000`
- No additional setup needed
- Current app configuration: **Already set to 192.168.1.8**

#### ✅ **Different Network or Remote Access**
1. Install Tailscale on your device: https://tailscale.com/
2. Connect Tailscale account (same as computer's)
3. Update API service or app configuration to use: `http://100.85.59.107:5000`

**To update app for Tailscale:**
Edit `lib/core/services/api_service.dart` and change:
```dart
return 'http://100.85.59.107:5000';  // Instead of 192.168.1.8:5000
```

#### ✅ **Android Emulator**
- Already handled in code
- Uses: `http://10.0.2.2:5000`
- No action needed

## Current Configuration

### What the app currently does:
- **Android Phone**: Uses `192.168.1.8:5000` (local WiFi)
- **Android Emulator**: Uses `10.0.2.2:5000` (emulator bridge)
- **iOS**: Uses `192.168.1.8:5000` (local WiFi)

### Updated API Service
The `api_service.dart` has been updated with:
- Better comments explaining network options
- Android emulator detection (10.0.2.2)
- Physical device defaults to local WiFi (192.168.1.8)
- Instructions for Tailscale fallback

## Server Health Check

```bash
# From your computer, verify server is responding:
curl http://192.168.1.8:5000/check
curl http://100.85.59.107:5000/check  # Via Tailscale
```

Expected response:
```json
{"message":"Server is running ✅","timestamp":"2026-02-17T..."}
```

## Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Timeout on same WiFi | Different subnet | Ensure both on same WiFi network |
| Timeout on mobile data | No local network access | Use Tailscale IP (100.85.59.107:5000) |
| Connection refused | Server not running | Check: `ps aux \| grep "node index.js"` |
| 192.168.1.8 not resolving | Wrong device IP | Run: `ip addr show` on server computer |
| Firewall blocks connection | Port 5000 closed | Check: `sudo ufw status` |

## Quick Verification Checklist

- [ ] Server running: `ps aux | grep "node index.js"`
- [ ] Server listening: `ss -tuln | grep 5000`
- [ ] Port open: `sudo ufw status | grep 5000`
- [ ] Local test works: `curl http://192.168.1.8:5000/check`
- [ ] External device on same WiFi: Check WiFi network name
- [ ] External device can ping server: `ping 192.168.1.8`
- [ ] External device can reach port: `curl http://192.168.1.8:5000/check`
