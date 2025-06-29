@echo off
REM iOS Build Script for Healthy Pathway (Windows)
REM This script automates the iOS build process for Windows users

echo 🚀 Starting iOS build process for Healthy Pathway...

REM Check if Flutter is installed
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Flutter is not installed or not in PATH
    exit /b 1
)

REM Check if we're in the right directory
if not exist "pubspec.yaml" (
    echo ❌ pubspec.yaml not found. Please run this script from the project root.
    exit /b 1
)

echo ✅ Flutter version: 
flutter --version | findstr "Flutter"

REM Clean previous builds
echo ✅ Cleaning previous builds...
flutter clean

REM Get dependencies
echo ✅ Getting Flutter dependencies...
flutter pub get

REM Generate app icons
echo ✅ Generating app icons...
flutter pub run flutter_launcher_icons:main

echo ✅ iOS build preparation completed!
echo.
echo ⚠️  Next steps for iOS development:
echo 1. Transfer this project to a Mac computer
echo 2. Install Xcode from the Mac App Store
echo 3. Install CocoaPods: sudo gem install cocoapods
echo 4. Run the following commands on Mac:
echo    cd ios
echo    pod install
echo    cd ..
echo    flutter build ios --simulator
echo.
echo ⚠️  For App Store submission:
echo 1. Open ios/Runner.xcworkspace in Xcode
echo 2. Configure signing and capabilities
echo 3. Update bundle identifier
echo 4. Archive and upload to App Store Connect
echo.
echo 📋 Note: iOS development requires macOS and Xcode
echo    This script only prepares the Flutter project for iOS

pause 