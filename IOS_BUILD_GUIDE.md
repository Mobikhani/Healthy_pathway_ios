# iOS Build Guide - GitHub Actions

This guide explains how to build iOS .ipa files using GitHub Actions without needing a Mac locally.

## Quick Start (Unsigned Build)

1. **Push your code to GitHub** (main or master branch)
2. **Go to Actions tab** in your GitHub repository
3. **Select "Build iOS IPA" workflow**
4. **Click "Run workflow"** to manually trigger the build
5. **Download the .ipa** from the artifacts section

## Workflow Files

### 1. `ios.yml` - Unsigned Build
- Builds .ipa without code signing
- Good for testing and development
- No Apple Developer account required

### 2. `ios-signed.yml` - Signed Build
- Builds .ipa with code signing
- Required for App Store distribution
- Requires Apple Developer account setup

## Setup Instructions

### For Unsigned Builds (Testing)

1. **Push your code to GitHub**
2. **The workflow will run automatically** on push to main/master
3. **Download the .ipa** from the Actions tab

### For Signed Builds (App Store)

1. **Get Apple Developer Account** ($99/year)
2. **Create App Store Connect App**
3. **Generate certificates and profiles**
4. **Add GitHub Secrets**

#### Required GitHub Secrets:

```
P12_BASE64 - Your p12 certificate (base64 encoded)
P12_PASSWORD - Password for your p12 certificate
APPSTORE_ISSUER_ID - Your App Store Connect issuer ID
APPSTORE_KEY_ID - Your App Store Connect API key ID
APPSTORE_PRIVATE_KEY - Your App Store Connect private key
```

#### How to get these values:

1. **P12 Certificate:**
   - Export from Keychain Access on Mac
   - Convert to base64: `base64 -i Certificates.p12 | pbcopy`

2. **App Store Connect API:**
   - Go to App Store Connect → Users and Access → Keys
   - Generate new API key
   - Note the Key ID and Issuer ID

## Manual Build Trigger

You can manually trigger builds:

1. Go to **Actions** tab
2. Select **"Build iOS IPA"** workflow
3. Click **"Run workflow"**
4. Select branch and click **"Run workflow"**

## Troubleshooting

### Common Issues:

1. **Pod install fails:**
   - Check if all iOS dependencies are compatible
   - Update pod versions in `ios/Podfile.lock`

2. **Build fails:**
   - Check the build logs in artifacts
   - Verify all permissions are set in `Info.plist`

3. **Code signing fails:**
   - Verify all secrets are correctly set
   - Check certificate and profile validity

### Build Logs

Build logs are automatically uploaded as artifacts. Check them for detailed error information.

## Alternative: Codemagic

If GitHub Actions doesn't work for you, try [Codemagic](https://codemagic.io):

1. **Sign up** for Codemagic
2. **Connect your GitHub repository**
3. **Configure iOS build**
4. **Build and download .ipa**

## Local Testing

To test your app before building .ipa:

1. **Use iOS Simulator** (requires Mac)
2. **Use TestFlight** (requires signed build)
3. **Use Firebase App Distribution** (for testing)

## Next Steps

1. **Test the unsigned build** first
2. **Set up code signing** for App Store distribution
3. **Upload to TestFlight** for beta testing
4. **Submit to App Store** when ready

## Support

If you encounter issues:
1. Check the build logs in GitHub Actions
2. Verify all configurations are correct
3. Ensure all dependencies support iOS 