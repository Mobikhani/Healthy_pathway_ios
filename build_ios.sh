#!/bin/bash

# iOS Build Script for Healthy Pathway
# This script automates the iOS build process

echo "🚀 Starting iOS build process for Healthy Pathway..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    print_error "Flutter is not installed or not in PATH"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    print_error "pubspec.yaml not found. Please run this script from the project root."
    exit 1
fi

print_status "Flutter version: $(flutter --version | head -n 1)"

# Clean previous builds
print_status "Cleaning previous builds..."
flutter clean

# Get dependencies
print_status "Getting Flutter dependencies..."
flutter pub get

# Generate app icons
print_status "Generating app icons..."
flutter pub run flutter_launcher_icons:main

# Install iOS pods
print_status "Installing iOS pods..."
cd ios
if ! command -v pod &> /dev/null; then
    print_error "CocoaPods is not installed. Please install it first: sudo gem install cocoapods"
    exit 1
fi

pod install
if [ $? -ne 0 ]; then
    print_warning "Pod install failed, trying pod deintegrate and reinstall..."
    pod deintegrate
    pod install
fi

cd ..

# Build for iOS simulator
print_status "Building for iOS simulator..."
flutter build ios --simulator

if [ $? -eq 0 ]; then
    print_status "✅ iOS simulator build completed successfully!"
    print_status "You can now run: flutter run -d ios"
else
    print_error "❌ iOS simulator build failed!"
    exit 1
fi

# Optional: Build for device (commented out by default)
# Uncomment the following lines if you want to build for device
# print_status "Building for iOS device..."
# flutter build ios --release
# if [ $? -eq 0 ]; then
#     print_status "✅ iOS device build completed successfully!"
# else
#     print_error "❌ iOS device build failed!"
#     exit 1
# fi

print_status "🎉 iOS build process completed!"
print_warning "Next steps:"
echo "1. Open ios/Runner.xcworkspace in Xcode"
echo "2. Configure signing and capabilities"
echo "3. Select your target device"
echo "4. Build and run from Xcode"

print_warning "For App Store submission:"
echo "1. Update bundle identifier in Xcode"
echo "2. Archive the project in Xcode"
echo "3. Upload to App Store Connect" 