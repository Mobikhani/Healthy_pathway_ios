# Building iOS .ipa Files on GitHub Actions

## 🚀 Quick Start

1. **Push your code to GitHub** (main or master branch)
2. **Go to Actions tab** in your GitHub repository
3. **Select "Build iOS IPA (Production)" workflow**
4. **Click "Run workflow"** to manually trigger the build
5. **Download the .ipa** from the artifacts section

## 📋 Available Workflows

### 1. `ios-production.yml` (Recommended)
- **Purpose**: Production-ready builds with detailed logging
- **Features**: 
  - Automatic verification of iOS configuration
  - Detailed build logs
  - IPA file validation
  - Better error handling
- **Use for**: Regular builds and testing

### 2. `ios-signed.yml` (For App Store)
- **Purpose**: Signed builds for App Store distribution
- **Requirements**: Apple Developer account and certificates
- **Use for**: App Store submissions

### 3. `ios.yml` (Basic)
- **Purpose**: Simple unsigned builds
- **Use for**: Quick testing

## 🔧 Setup Instructions

### Step 1: Push Your Code
```bash
git add .
git commit -m "Update iOS configuration for GitHub Actions"
git push origin main
```

### Step 2: Trigger the Build
1. Go to your GitHub repository
2. Click on **Actions** tab
3. Select **"Build iOS IPA (Production)"**
4. Click **"Run workflow"**
5. Select your branch and click **"Run workflow"**

### Step 3: Download the IPA
1. Wait for the build to complete (usually 5-10 minutes)
2. Click on the completed workflow run
3. Scroll down to **Artifacts** section
4. Click **"healthy-pathway-ipa"** to download
5. Extract the ZIP file to get your `.ipa` file

## 📱 Installing the IPA on Your Device

### Method 1: AltStore (Recommended for Windows Users)
1. **Install AltStore** on your iOS device
2. **Install AltServer** on your computer
3. **Connect your device** to your computer
4. **Drag and drop** the IPA file to AltStore

### Method 2: Xcode (Mac Users)
1. **Connect your device** to your Mac
2. **Open Xcode**
3. **Go to Window → Devices and Simulators**
4. **Drag and drop** the IPA file to install

### Method 3: Third-party Tools
- **3uTools**: Popular Windows tool
- **iMazing**: Professional iOS management
- **Apple Configurator 2**: Official Apple tool

## 🔐 For Signed Builds (App Store)

If you want to create signed builds for App Store distribution:

### 1. Get Apple Developer Account
- Sign up at [developer.apple.com](https://developer.apple.com)
- Cost: $99/year

### 2. Generate Certificates
1. **Export your p12 certificate** from Keychain Access
2. **Convert to base64**: `base64 -i Certificates.p12 | pbcopy`

### 3. Add GitHub Secrets
Go to your repository → Settings → Secrets and variables → Actions

Add these secrets:
```
P12_BASE64 - Your p12 certificate (base64 encoded)
P12_PASSWORD - Password for your p12 certificate
```

### 4. Use Signed Workflow
- Use the `ios-signed.yml` workflow instead
- This will create a properly signed IPA for App Store

## 🛠️ Troubleshooting

### Common Issues:

#### 1. Build Fails with Pod Install Error
**Solution**: The workflow includes `--repo-update` flag to fix this

#### 2. IPA File Not Found
**Check**:
- Bundle identifier is correct (`com.healthypathway.app`)
- Export options are properly configured
- All iOS dependencies are compatible

#### 3. App Won't Install on Device
**Solutions**:
- Use AltStore for unsigned builds
- For signed builds, ensure device UDID is in your Apple Developer account
- Trust the developer certificate in Settings → General → VPN & Device Management

#### 4. Build Takes Too Long
**Optimizations**:
- The workflow uses caching for dependencies
- Build time is typically 5-10 minutes
- Consider using signed builds for faster installation

### Build Logs
- Check the **Actions** tab for detailed build logs
- Download **build-logs-production** artifact for more details
- Look for specific error messages in the logs

## 📊 Build Status

You can monitor your builds:
- **Green checkmark**: Build successful
- **Red X**: Build failed
- **Yellow dot**: Build in progress

## 🔄 Automatic Builds

The workflow automatically runs on:
- **Push to main/master branch**
- **Pull requests to main/master**
- **Manual trigger** (workflow_dispatch)

## 📈 Best Practices

1. **Test unsigned builds first** before setting up signing
2. **Keep your Flutter version updated** in the workflow
3. **Monitor build logs** for any issues
4. **Use meaningful commit messages** to track changes
5. **Set up branch protection** for main/master

## 🆘 Support

If you encounter issues:

1. **Check the build logs** in GitHub Actions
2. **Verify your iOS configuration** is correct
3. **Ensure all dependencies** support iOS
4. **Test locally first** if possible

## 🎯 Next Steps

1. **Test the unsigned build** on your device
2. **Set up code signing** for App Store distribution
3. **Upload to TestFlight** for beta testing
4. **Submit to App Store** when ready

## 📞 Need Help?

- Check the build logs for specific error messages
- Verify all configurations match the guide
- Ensure your device is properly set up for testing 