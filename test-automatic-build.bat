@echo off
echo 🚀 Testing Automatic Build System
echo ==================================

REM Check if we're in a git repository
if not exist ".git" (
    echo ❌ Error: Not in a git repository
    echo Please run this script from your project root directory
    pause
    exit /b 1
)

REM Check current branch
for /f "tokens=*" %%i in ('git branch --show-current') do set CURRENT_BRANCH=%%i
echo 📍 Current branch: %CURRENT_BRANCH%

REM Check if we have changes to commit
git status --porcelain > temp_status.txt
set /p STATUS_CHECK=<temp_status.txt
del temp_status.txt

if not "%STATUS_CHECK%"=="" (
    echo 📝 You have uncommitted changes:
    git status --short
    
    set /p COMMIT_CHOICE="Do you want to commit these changes? (y/n): "
    if /i "%COMMIT_CHOICE%"=="y" (
        set /p COMMIT_MESSAGE="Enter commit message: "
        git add .
        git commit -m "%COMMIT_MESSAGE%"
        echo ✅ Changes committed
    ) else (
        echo ❌ Please commit your changes first
        pause
        exit /b 1
    )
) else (
    echo ✅ No uncommitted changes
)

REM Check if we have a remote repository
git remote -v > temp_remote.txt
set /p REMOTE_CHECK=<temp_remote.txt
del temp_remote.txt

if "%REMOTE_CHECK%"=="" (
    echo ❌ Error: No remote repository configured
    echo Please add a GitHub remote: git remote add origin ^<your-repo-url^>
    pause
    exit /b 1
)

REM Show remote info
echo 🌐 Remote repository:
git remote -v

REM Push to trigger automatic build
echo.
echo 🚀 Pushing to trigger automatic build...
git push origin %CURRENT_BRANCH%

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Successfully pushed to GitHub!
    echo.
    echo 📋 Next steps:
    echo 1. Go to your GitHub repository
    echo 2. Click on 'Actions' tab
    echo 3. Watch the automatic build progress
    echo 4. Download the IPA/APK when build completes
    echo.
    echo ⏱️  Build time: Usually 5-10 minutes
    echo.
    echo 🎉 Your automatic build system is working!
) else (
    echo ❌ Failed to push to GitHub
    echo Please check your git configuration and try again
)

pause 