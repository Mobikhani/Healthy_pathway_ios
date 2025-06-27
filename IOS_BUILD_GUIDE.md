# iOS Build Guide for Healthy Pathway App

## Prerequisites

1. **Apple Developer Account**: You need a paid Apple Developer account ($99/year)
2. **Xcode**: Latest version installed on a Mac
3. **Flutter**: Latest stable version
4. **iOS Device**: Physical device for testing (not just simulator)

## Step-by-Step Build Process

### 1. Setup Apple Developer Account
- Go to [developer.apple.com](https://developer.apple.com)
- Sign in with your Apple ID
- Enroll in the Apple Developer Program
- Add your device UDID to your account

### 2. Configure Xcode Project
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select the "Runner" project in the navigator
3. Select the "Runner" target
4. Go to "Signing & Capabilities" tab
5. Check "Automatically manage signing"
6. Select your Team (Apple Developer account)
7. The Bundle Identifier should be: `com.healthypathway.app`

### 3. Build the IPA

#### Option A: Using the Build Script (Recommended)
```bash
# On Mac/Linux
chmod +x build_ios.sh
./build_ios.sh

# On Windows
build_ios.bat
```

#### Option B: Manual Build
```bash
# Clean and get dependencies
flutter clean
flutter pub get

# Build for iOS
flutter build ios --release --no-codesign

# Open Xcode and archive manually
open ios/Runner.xcworkspace
```

### 4. Archive and Export in Xcode
1. In Xcode, select "Product" → "Archive"
2. Wait for the archive to complete
3. In the Organizer window, select your archive
4. Click "Distribute App"
5. Choose "Ad Hoc" distribution
6. Select your team and provisioning profile
7. Choose export location
8. The IPA file will be created

## Installing the IPA on Your Device

### Method 1: Xcode (Easiest)
1. Connect your iOS device to your Mac
2. Open Xcode
3. Go to "Window" → "Devices and Simulators"
4. Select your device
5. Drag and drop the IPA file to the "Installed Apps" section

### Method 2: Apple Configurator 2
1. Download Apple Configurator 2 from the Mac App Store
2. Connect your device
3. Drag and drop the IPA file to install

### Method 3: AltStore (For Windows Users)
1. Install AltStore on your iOS device
2. Use AltServer on your computer to install the IPA

### Method 4: Third-party Tools
- **3uTools**: Popular Windows tool for iOS management
- **iMazing**: Professional iOS management tool

## Troubleshooting Common Issues

### Issue: "Untrusted Developer" Error
**Solution**: 
1. Go to Settings → General → VPN & Device Management
2. Find your developer certificate
3. Tap "Trust [Developer Name]"

### Issue: App Won't Install
**Possible Causes**:
- Device not registered in Apple Developer account
- Wrong provisioning profile
- Bundle identifier mismatch

**Solutions**:
1. Verify device UDID is in your Apple Developer account
2. Check bundle identifier matches exactly
3. Regenerate provisioning profiles

### Issue: App Crashes on Launch
**Possible Causes**:
- Missing permissions in Info.plist
- Code signing issues
- Architecture mismatch

**Solutions**:
1. Check all required permissions are in Info.plist
2. Verify code signing in Xcode
3. Ensure building for correct architecture

## Important Notes

1. **Bundle Identifier**: Must be unique and follow reverse domain notation
2. **Provisioning Profile**: Must include your device UDID
3. **Code Signing**: Must use valid certificates
4. **Permissions**: All required permissions must be declared in Info.plist

## Testing Checklist

- [ ] App launches without crashing
- [ ] All features work as expected
- [ ] Permissions are requested properly
- [ ] App responds to device rotation
- [ ] Memory usage is reasonable
- [ ] No console errors in Xcode

## Distribution Options

1. **Ad Hoc**: For testing on specific devices
2. **Enterprise**: For internal company distribution
3. **App Store**: For public distribution (requires App Store review)

## Support

If you encounter issues:
1. Check Xcode console for error messages
2. Verify all prerequisites are met
3. Ensure device is properly registered
4. Check Apple Developer account status 