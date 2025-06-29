@echo off
echo 🚀 Starting iOS Cloud Build Process for Healthy Pathway App

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Build for iOS using cloud build
echo 📱 Building for iOS using Flutter Cloud Build...
flutter build ios --release --no-codesign

echo ✅ Cloud build initiated!
echo.
echo 📋 Next steps:
echo 1. The build will be processed in the cloud
echo 2. You'll receive a download link for the IPA file
echo 3. Download and install the IPA on your iOS device
echo.
echo 💡 Alternative methods for iOS builds on Windows:
echo - Use a Mac or macOS virtual machine
echo - Set up GitHub Actions for automated builds
echo - Use Codemagic or other CI/CD services

pause 