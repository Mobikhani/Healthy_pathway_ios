# Notification Troubleshooting Guide

## Common Issues and Solutions

### 1. Notifications Not Appearing

**Symptoms:**
- Notifications are scheduled but never show up
- No error messages in logs
- App appears to work normally

**Possible Causes:**
- Missing permissions
- Battery optimization blocking notifications
- Notification channel not created properly
- Device-specific settings

**Solutions:**

#### Check Permissions
1. Go to your device Settings > Apps > Healthy Pathway > Permissions
2. Ensure "Notifications" permission is granted
3. Ensure "Display over other apps" permission is granted (if available)

#### Check Battery Optimization
1. Go to Settings > Apps > Healthy Pathway > Battery
2. Set battery optimization to "Don't optimize" or "Unrestricted"
3. Enable "Allow background activity"

#### Check Notification Settings
1. Go to Settings > Apps > Healthy Pathway > Notifications
2. Ensure notifications are enabled
3. Check if "Medicine Reminders" channel exists and is enabled
4. Set importance to "High" or "Urgent"

#### Check Do Not Disturb
1. Ensure Do Not Disturb is not enabled
2. Check if the app is in the allowed list for Do Not Disturb

### 2. Notifications Delayed or Inconsistent

**Symptoms:**
- Notifications appear but are delayed
- Some notifications work, others don't
- Notifications stop working after some time

**Possible Causes:**
- Android's battery optimization
- Background app restrictions
- Incorrect timezone handling

**Solutions:**

#### Force Stop and Restart
1. Go to Settings > Apps > Healthy Pathway
2. Force stop the app
3. Clear app data (optional)
4. Restart the app

#### Check Background Restrictions
1. Go to Settings > Apps > Healthy Pathway > Battery
2. Enable "Allow background activity"
3. Disable "Background app restrictions"

### 3. Test Notifications

Use the built-in test features in the app:

1. Open the app
2. Go to Medication Reminder
3. Navigate to Notification Debug Screen
4. Try "Send Test Now" button
5. Try "Schedule Test (30s)" button
6. Check the status information

### 4. Debug Information

The app provides detailed debug information:

- **Service Status**: Shows if notification service is initialized
- **Permissions**: Shows current permission status
- **Pending Notifications**: Shows scheduled notifications
- **Test Buttons**: Test immediate and scheduled notifications

### 5. Device-Specific Issues

#### Samsung Devices
- Check "Auto-start" settings
- Enable "Allow background activity"
- Check "Adaptive battery" settings

#### Xiaomi/Redmi Devices
- Enable "Auto-start" for the app
- Disable "Battery saver" for the app
- Check "MIUI optimization" settings

#### Huawei Devices
- Enable "Auto-launch" for the app
- Disable "Battery optimization"
- Check "Protected apps" settings

#### OnePlus Devices
- Enable "Auto-start" for the app
- Disable "Battery optimization"
- Check "Advanced optimization" settings

### 6. Manual Testing Steps

1. **Immediate Test**:
   - Use "Send Test Now" button
   - Should show notification immediately
   - If this fails, there's a basic setup issue

2. **Scheduled Test**:
   - Use "Schedule Test (30s)" button
   - Wait 30 seconds
   - Should show notification
   - If this fails, there's a scheduling issue

3. **Permission Test**:
   - Check permission status in debug screen
   - Request permissions if needed
   - Verify permissions are granted

4. **Service Test**:
   - Check service initialization status
   - Force reinitialize if needed
   - Verify alarm manager is working

### 7. Log Analysis

Check the debug console for these messages:

**Good signs:**
- ✅ Notification service initialized successfully
- ✅ Android notification channel created
- ✅ Medicine channel verified
- ✅ Immediate test notification successful
- ✅ flutter_local_notifications scheduled
- ✅ android_alarm_manager_plus scheduled

**Warning signs:**
- ⚠️ Some permissions not granted
- ⚠️ Android implementation not available
- ⚠️ Could not cancel alarm

**Error signs:**
- ❌ Error initializing notification service
- ❌ Failed to initialize Android Alarm Manager
- ❌ Medicine channel not found after creation
- ❌ Immediate test notification failed

### 8. Advanced Troubleshooting

If basic troubleshooting doesn't work:

1. **Clear App Data**:
   - Settings > Apps > Healthy Pathway > Storage
   - Clear data and cache
   - Restart app

2. **Reinstall App**:
   - Uninstall the app
   - Restart device
   - Reinstall the app

3. **Check System Logs**:
   - Enable developer options
   - Check logcat for notification-related errors

4. **Test on Different Device**:
   - Try on a different Android device
   - Check if issue is device-specific

### 9. Contact Support

If none of the above solutions work:

1. Note down your device model and Android version
2. Take screenshots of the debug screen
3. Copy the console logs
4. Describe the exact behavior you're experiencing

## Quick Fix Checklist

- [ ] Notifications permission granted
- [ ] Battery optimization disabled for app
- [ ] Do Not Disturb not enabled
- [ ] App notifications enabled in system settings
- [ ] Test notification works immediately
- [ ] Test notification works when scheduled
- [ ] Service shows as initialized in debug screen
- [ ] No error messages in console logs 