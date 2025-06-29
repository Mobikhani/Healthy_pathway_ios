# iOS Build Guide for Healthy Pathway

This guide provides step-by-step instructions for building and deploying the Healthy Pathway app to iOS.

## Prerequisites

### Required Tools
1. **Xcode** (Latest version from Mac App Store)
2. **Flutter SDK** (3.32.5 or higher)
3. **CocoaPods** (`sudo gem install cocoapods`)
4. **Apple Developer Account** (for App Store deployment)

### System Requirements
- macOS (required for iOS development)
- iOS 13.0 or later (minimum deployment target)
- Xcode 15.0 or later

## Project Configuration

### ✅ Already Configured
- iOS platform support enabled
- Firebase configuration for iOS
- App icons generated
- Permissions configured in Info.plist
- Podfile optimized for iOS 13+
- Notification service iOS-compatible
- Platform-specific code handling

### Bundle Identifier
- Current: `com.example.healthyPathway`
- **Important**: Change this to your unique bundle identifier before App Store submission

## Build Steps

### 1. Setup Development Environment

```bash
# Navigate to project directory
cd healthy_pathway

# Get dependencies
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

### 2. Open in Xcode

```bash
# Open the workspace (not the project)
open ios/Runner.xcworkspace
```

### 3. Configure Signing & Capabilities

In Xcode:
1. Select "Runner" project
2. Select "Runner" target
3. Go to "Signing & Capabilities" tab
4. Configure:
   - Team: Your Apple Developer Team
   - Bundle Identifier: Your unique identifier
   - Provisioning Profile: Automatic

### 4. Build for Simulator

```bash
# Build for iOS Simulator
flutter build ios --simulator

# Or run directly
flutter run -d ios
```

### 5. Build for Device

```bash
# Build for physical device
flutter build ios --release

# Or run on connected device
flutter run -d <device-id>
```

### 6. Archive for App Store

In Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Follow App Store Connect upload process

## Key Features for iOS

### ✅ Notifications
- Local notifications configured
- Background app refresh enabled
- iOS-specific notification permissions

### ✅ Permissions
- Camera access for health photos
- Photo library access
- Notification permissions
- HealthKit permissions (future use)

### ✅ Firebase Integration
- iOS Firebase configuration
- Authentication support
- Database connectivity

### ✅ Platform Compatibility
- iOS-specific UI adjustments
- Platform-specific code handling
- iOS 13+ compatibility

## Troubleshooting

### Common Issues

1. **Pod Install Fails**
   ```bash
   cd ios
   pod deintegrate
   pod install
   ```

2. **Signing Issues**
   - Verify Apple Developer account
   - Check bundle identifier uniqueness
   - Ensure provisioning profiles are valid

3. **Build Errors**
   ```bash
   flutter clean
   flutter pub get
   cd ios && pod install && cd ..
   ```

4. **Simulator Issues**
   ```bash
   flutter devices  # List available devices
   open -a Simulator  # Open iOS Simulator
   ```

### Performance Optimization

1. **Enable Bitcode**: Disabled (as configured)
2. **Swift Version**: 5.0
3. **Deployment Target**: iOS 13.0
4. **Architecture**: arm64 for devices, excluded for simulator

## App Store Submission

### Before Submission
1. Update bundle identifier
2. Test on physical devices
3. Verify all permissions work
4. Test notifications
5. Check app icons display correctly

### Required Assets
- App icon (1024x1024)
- Screenshots for different device sizes
- App description and keywords
- Privacy policy URL

### App Store Review Guidelines
- Ensure health-related content follows guidelines
- Verify notification usage is appropriate
- Check data collection compliance
- Test all features thoroughly

## Testing Checklist

- [ ] App launches without crashes
- [ ] All screens display correctly
- [ ] Navigation works smoothly
- [ ] Notifications trigger properly
- [ ] Camera/photo access works
- [ ] Firebase authentication works
- [ ] Data persistence functions
- [ ] App responds to background/foreground transitions
- [ ] Memory usage is reasonable
- [ ] Battery usage is acceptable

## Support

For issues specific to iOS deployment:
1. Check Flutter iOS documentation
2. Review Xcode build logs
3. Verify Apple Developer account status
4. Test on multiple iOS versions

## Notes

- The app is configured for iOS 13.0+ compatibility
- All Android-specific code is properly isolated
- iOS-specific optimizations are in place
- Background processing is enabled for notifications
- App Transport Security is configured for Firebase 