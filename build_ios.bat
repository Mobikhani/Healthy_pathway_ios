@echo off
echo 🚀 Starting iOS Build Process for Healthy Pathway App

REM Clean previous builds
echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

REM Build for iOS
echo 📱 Building for iOS...
flutter build ios --release --no-codesign

REM Navigate to iOS directory
cd ios

REM Archive the app
echo 📦 Archiving the app...
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -archivePath build/Runner.xcarchive clean archive

REM Export IPA
echo 📤 Exporting IPA...
xcodebuild -exportArchive -archivePath build/Runner.xcarchive -exportPath build/ios -exportOptionsPlist exportOptions.plist

echo ✅ Build completed!
echo 📁 IPA file location: ios/build/ios/Runner.ipa
echo.
echo 📋 Next steps:
echo 1. Install the IPA on your device using one of these methods:
echo    - Use Xcode to install directly
echo    - Use Apple Configurator 2
echo    - Use a third-party tool like AltStore
echo 2. Make sure your device is registered in your Apple Developer account
echo 3. Trust the developer certificate in Settings ^> General ^> VPN ^& Device Management

pause 