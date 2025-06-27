#!/bin/bash

echo "🚀 Testing Automatic Build System"
echo "=================================="

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository"
    echo "Please run this script from your project root directory"
    exit 1
fi

# Check current branch
CURRENT_BRANCH=$(git branch --show-current)
echo "📍 Current branch: $CURRENT_BRANCH"

# Check if we have changes to commit
if [ -n "$(git status --porcelain)" ]; then
    echo "📝 You have uncommitted changes:"
    git status --short
    
    read -p "Do you want to commit these changes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " COMMIT_MESSAGE
        git add .
        git commit -m "$COMMIT_MESSAGE"
        echo "✅ Changes committed"
    else
        echo "❌ Please commit your changes first"
        exit 1
    fi
else
    echo "✅ No uncommitted changes"
fi

# Check if we have a remote repository
if [ -z "$(git remote -v)" ]; then
    echo "❌ Error: No remote repository configured"
    echo "Please add a GitHub remote: git remote add origin <your-repo-url>"
    exit 1
fi

# Show remote info
echo "🌐 Remote repository:"
git remote -v

# Push to trigger automatic build
echo ""
echo "🚀 Pushing to trigger automatic build..."
git push origin $CURRENT_BRANCH

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "📋 Next steps:"
    echo "1. Go to your GitHub repository"
    echo "2. Click on 'Actions' tab"
    echo "3. Watch the automatic build progress"
    echo "4. Download the IPA/APK when build completes"
    echo ""
    echo "🔗 Repository URL: $(git remote get-url origin)"
    echo "⏱️  Build time: Usually 5-10 minutes"
    echo ""
    echo "🎉 Your automatic build system is working!"
else
    echo "❌ Failed to push to GitHub"
    echo "Please check your git configuration and try again"
    exit 1
fi 