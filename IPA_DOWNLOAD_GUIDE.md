# 📱 IPA Download Guide for iPhone 12 Pro

## 🎯 **Which IPA File Should You Download?**

### **For iPhone 12 Pro - Choose ONE of these:**

1. **📦 Production Build (Recommended)**
   - **Name Pattern**: `HealthyPathway-iPhone12Pro-YYYYMMDD-HHMMSS-commit.ipa`
   - **Example**: `HealthyPathway-iPhone12Pro-20241201-143022-a12d617.ipa`
   - **When to use**: For testing the final app on your iPhone 12 Pro
   - **Location**: GitHub Actions → Latest workflow run → Artifacts

2. **🔧 Development Build (For Testing)**
   - **Name Pattern**: `HealthyPathway-iPhone12Pro-DEV-debug-YYYYMMDD-HHMMSS-commit.ipa`
   - **Example**: `HealthyPathway-iPhone12Pro-DEV-debug-20241201-143022-a12d617.ipa`
   - **When to use**: For development testing and debugging
   - **Location**: GitHub Actions → Manual workflow run → Artifacts

## 📋 **How to Download:**

1. **Go to your GitHub repository**: https://github.com/Mobikhani/Healthy-pathway
2. **Click "Actions" tab**
3. **Find the latest workflow run** (green checkmark = successful)
4. **Click on the workflow run**
5. **Scroll down to "Artifacts" section**
6. **Download the file with "HealthyPathway-iPhone12Pro" in the name**

## 🚨 **Important Notes:**

- **Always download the LATEST one** (highest date/time in filename)
- **Only ONE IPA file will be available** (old ones are automatically deleted)
- **The filename includes the date and time** so you know it's the newest version
- **Both types work on iPhone 12 Pro** - choose based on your needs

## 📱 **Installation on iPhone 12 Pro:**

1. **Download the IPA file** to your computer
2. **Install using one of these methods:**
   - **AltStore** (requires computer connection)
   - **Apple Configurator 2** (Mac only)
   - **Xcode** (Mac only)

## 🔄 **Getting a New Build:**

- **Automatic**: Push code to GitHub → New IPA created automatically
- **Manual**: Go to Actions → "iOS Development Build" → "Run workflow"

---
**💡 Tip**: The filename tells you exactly when it was built and which version it is! 