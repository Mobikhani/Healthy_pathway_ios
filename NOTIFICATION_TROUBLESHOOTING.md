# Notification Troubleshooting Guide

## Overview
This guide helps you troubleshoot notification issues in the Healthy Pathway app.

## Common Issues and Solutions

### 1. Notifications Not Appearing

#### Check Permissions First
1. Open the app and go to **Medicine Reminders**
2. Tap the settings icon (⚙️) in the top-right corner
3. Check if both "Notification Permission" and "Alarm Permission" show as "Granted"
4. If not, tap "Request Permissions" and allow all permissions

#### Test Notifications
1. In the **Medicine Reminders** screen, you'll see a "Notification Tests" section
2. Try these tests in order:
   - **Test Now** - Should show immediate notification
   - **Test 10s** - Should show notification after 10 seconds
   - **Test 2min** - Should show notification after 2 minutes

### 2. Android-Specific Issues

#### Battery Optimization
- Go to **Settings > Apps > Healthy Pathway > Battery**
- Set to "Unrestricted" or "Don't optimize"
- Enable "Allow background activity"

#### Do Not Disturb
- Check if Do Not Disturb is enabled
- Go to **Settings > Sound & vibration > Do not disturb**
- Make sure the app is allowed to show notifications

#### Notification Settings
- Go to **Settings > Apps > Healthy Pathway > Notifications**
- Ensure "Show notifications" is enabled
- Enable "Medicine Reminders" channel
- Set importance to "High" or "Urgent"

### 3. iOS-Specific Issues

#### Notification Settings
- Go to **Settings > Notifications > Healthy Pathway**
- Enable "Allow Notifications"
- Enable "Sounds", "Badges", and "Banners"
- Set "Alert Style" to "Banners" or "Alerts"

#### Focus Mode
- Check if Focus mode is enabled
- Go to **Settings > Focus**
- Make sure the app is allowed in your current focus mode

### 4. Debug Information

#### Check Console Logs
When testing notifications, check the console output for these messages:

✅ **Success Messages:**
- "Notification service initialized successfully"
- "Android notification channel created"
- "Test notification sent successfully"
- "Notification scheduled successfully"

❌ **Error Messages:**
- "Error initializing notification service"
- "Permission denied"
- "Failed to schedule notification"

#### Common Error Solutions

**"Permission denied"**
- Request permissions again through the app
- Check system notification settings
- Restart the app

**"Failed to schedule notification"**
- Check if the time is in the past
- Ensure the app has proper permissions
- Try scheduling for a future time

**"Notification service not initialized"**
- Restart the app
- Check if Firebase is properly initialized
- Clear app data and reinstall

### 5. Testing Steps

#### Step 1: Basic Test
1. Open the app
2. Go to Medicine Reminders
3. Tap "Test Now"
4. Check if notification appears immediately

#### Step 2: Scheduled Test
1. Tap "Test 10s"
2. Wait 10 seconds
3. Check if notification appears

#### Step 3: Medicine Test
1. Add a medicine with a time 2-3 minutes in the future
2. Wait for the scheduled time
3. Check if notification appears

### 6. Advanced Troubleshooting

#### Clear All Data
1. Go to **Settings > Apps > Healthy Pathway > Storage**
2. Tap "Clear Data" and "Clear Cache"
3. Restart the app
4. Test notifications again

#### Reinstall the App
1. Uninstall the app
2. Restart your device
3. Reinstall the app
4. Grant all permissions when prompted

#### Check Device Compatibility
- Ensure your device supports scheduled notifications
- Check if the device has enough storage space
- Verify the device is not in power-saving mode

### 7. Developer Information

#### Permissions Added
The app now includes these Android permissions:
- `POST_NOTIFICATIONS`
- `SCHEDULE_EXACT_ALARM`
- `USE_EXACT_ALARM`
- `RECEIVE_BOOT_COMPLETED`
- `WAKE_LOCK`
- `FOREGROUND_SERVICE`
- `REQUEST_IGNORE_BATTERY_OPTIMIZATIONS`
- `VIBRATE`
- `ACCESS_NOTIFICATION_POLICY`

#### Boot Receiver
The app includes a BootReceiver to reschedule notifications after device restart.

#### Timezone Handling
The app uses Asia/Karachi timezone by default, with fallback to device timezone.

## Still Having Issues?

If you're still experiencing notification problems:

1. **Check the console logs** for specific error messages
2. **Test on a different device** to isolate the issue
3. **Contact support** with the specific error messages and device information

## Version Information
- Flutter: 3.x
- flutter_local_notifications: ^19.3.0
- timezone: ^0.10.1
- permission_handler: ^11.1.0 