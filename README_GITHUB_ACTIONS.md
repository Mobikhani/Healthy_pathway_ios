# 🚀 iOS Build with GitHub Actions

## Quick Start

1. **Push your code to GitHub**
2. **Go to Actions tab** in your repository
3. **Select "Build iOS IPA (Production)"**
4. **Click "Run workflow"**
5. **Download the .ipa file** from artifacts

## 📱 What You Get

- **Unsigned .ipa file** ready for testing
- **Automatic builds** on every push to main/master
- **Detailed build logs** for troubleshooting
- **30-day artifact retention** for easy access

## 🔧 How It Works

The GitHub Actions workflow:
1. Sets up Flutter environment on macOS
2. Installs iOS dependencies (CocoaPods)
3. Builds the iOS app with your updated configuration
4. Creates an unsigned .ipa file
5. Uploads the file as an artifact

## 📋 Prerequisites

- ✅ Your code is on GitHub
- ✅ iOS configuration is updated (bundle ID, export options)
- ✅ All dependencies support iOS

## 🎯 Next Steps

1. **Test the unsigned build** using AltStore or similar tool
2. **Set up code signing** if you want App Store distribution
3. **Use the signed workflow** for production releases

## 📖 Detailed Guide

See [GITHUB_IOS_BUILD_GUIDE.md](GITHUB_IOS_BUILD_GUIDE.md) for complete instructions.

## 🆘 Need Help?

- Check the build logs in GitHub Actions
- Verify your iOS configuration
- Ensure all dependencies are iOS-compatible 