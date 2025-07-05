# Automation Permissions Issue - Documentation

## Problem Summary
The Dot-Dash app cannot appear in System Settings > Privacy & Security > Automation, despite being properly signed, sandboxed, and having all required entitlements and usage descriptions.

## Current Status
- ✅ App is properly signed with Developer ID (Team ID: 4VS9K4RWP9)
- ✅ App sandbox is enabled
- ✅ All required entitlements are present:
  - `com.apple.security.app-sandbox`
  - `com.apple.security.automation.apple-events`
  - `com.apple.security.device.input-device`
- ✅ Usage descriptions are in Info.plist:
  - `NSAppleEventsUsageDescription`
  - `NSSystemAdministrationUsageDescription`
- ✅ App runs from /Applications (not Xcode)
- ❌ App does not appear in Automation permissions section
- ❌ TCC database shows no entries for Apple Events

## What Has Been Tried

### 1. Code Signing Fixes
- ✅ Changed from "Automatic" to "Manual" code signing
- ✅ Added development team ID to project settings
- ✅ Built with proper Developer ID certificate
- ✅ Verified signature shows "Apple Development" not "adhoc"

### 2. Entitlements and Permissions
- ✅ Enabled app sandbox
- ✅ Added `com.apple.security.automation.apple-events` entitlement
- ✅ Added device permissions for input monitoring
- ✅ Added usage descriptions to Info.plist

### 3. Build and Installation
- ✅ Built for Release configuration
- ✅ Installed to /Applications folder
- ✅ Verified app runs from Applications (not DerivedData)
- ✅ Cleaned build folder and rebuilt multiple times

### 4. System Testing
- ✅ Quit and relaunched app multiple times
- ✅ Rebooted macOS
- ✅ Triggered text expansion to attempt Apple Events
- ✅ Checked Console.app for TCC errors
- ✅ Ran diagnostic scripts to verify configuration

### 5. AppleScript Testing
- ✅ Verified AppleScript can run (permission test succeeds)
- ✅ Confirmed Apple Events permission is granted
- ✅ Tested with System Events running
- ❌ Still no TCC database entry for Automation

## Root Cause Analysis

### Known macOS TCC Limitations
1. **TCC Database Entry Creation**: Automation entries are only created when:
   - App attempts to send Apple Event to another app
   - System recognizes app as eligible (signed, sandboxed, correct usage description)
   - System prompt is shown and user responds
   - Apple Event is "user-initiated" and interactive

2. **macOS 13+ Stricter Behavior**: 
   - Automation section may not show app until successful, user-initiated Apple Event
   - If Apple Event fails with error -600 ("Application isn't running"), TCC may not register
   - System Events must be running for proper permission registration

3. **Sandboxed App Limitations**:
   - Sandboxed apps have stricter permission requirements
   - Some Apple Events may not trigger proper TCC registration
   - Development builds may have limited permission capabilities

### Potential Issues
1. **Apple Event Target**: Sending events to "System Events" when it's not running
2. **Event Timing**: Apple Events triggered too early in app lifecycle
3. **User Interaction**: Events not "user-initiated" enough for TCC registration
4. **Notarization**: Non-notarized apps may have stricter permission requirements
5. **TCC Database State**: Possible corruption or stuck state in user's TCC database

## Remaining Solutions to Try

### 1. Notarization (High Priority)
```bash
# Archive app in Xcode
# Submit for notarization via Apple Developer portal
# Install notarized version and test
```

### 2. Clean User Account Test
```bash
# Create new macOS user account
# Install app and test permissions
# Determine if issue is user-specific or app-specific
```

### 3. System Events Integration
```bash
# Ensure System Events is running before Apple Events
open -a "System Events"
# Then trigger text expansion
```

### 4. Alternative Apple Event Targets
- Try sending Apple Events to specific apps (TextEdit, Mail) instead of System Events
- Use different Apple Event types that are more likely to trigger TCC registration

### 5. TCC Database Reset (Last Resort)
```bash
# Advanced: Reset TCC database (risky, backup first)
# Only if other solutions fail and issue affects multiple apps
```

## Current Workaround
- Using backspace + paste method for text expansion
- This works reliably without requiring Apple Events permission
- App functions correctly for core text expansion features
- AppleScript method is disabled until permissions issue is resolved

## Code Changes Made
- Commented out all AppleScript-related code
- Added TODO comments for future automation implementation
- Kept backspace + paste method as primary text expansion strategy
- Maintained all permission-related code for future use

## Future Implementation Plan

### Phase 1: Resolve Permissions (When Ready)
1. **Notarize the app** using Apple Developer account
2. **Test on clean user account** to isolate issue
3. **Implement proper Apple Event timing** (user-initiated only)
4. **Add System Events integration** before Apple Events
5. **Test with specific app targets** instead of System Events

### Phase 2: Re-enable AppleScript (After Permissions Work)
1. **Uncomment AppleScript code** with proper error handling
2. **Add fallback to backspace method** if AppleScript fails
3. **Implement hybrid approach** (try AppleScript first, fallback to backspace)
4. **Add user preference** to choose expansion method

### Phase 3: Enhanced Features
1. **Rich text support** via AppleScript (when permissions work)
2. **Advanced text manipulation** capabilities
3. **Cross-application compatibility** improvements

## Technical Notes

### AppleScript Error Codes
- **-1743**: Not authorized to send Apple events (permission denied)
- **-600**: Application isn't running (target app not available)
- **-50**: Parameter error (script syntax or parameter issue)

### TCC Database Location
```bash
# User TCC database
~/Library/Application Support/com.apple.TCC/TCC.db

# System TCC database  
/Library/Application Support/com.apple.TCC/TCC.db
```

### Required Entitlements for Automation
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.automation.apple-events</key>
<true/>
```

### Required Info.plist Keys
```xml
<key>NSAppleEventsUsageDescription</key>
<string>Dot-Dash needs Apple Events permission to perform text expansion and replacement in other applications.</string>
<key>NSSystemAdministrationUsageDescription</key>
<string>Dot-Dash needs system administration permission to monitor keyboard input for text expansion commands.</string>
```

## References
- [Apple Developer Documentation - App Sandbox](https://developer.apple.com/documentation/security/app_sandbox)
- [Apple Developer Documentation - Entitlements](https://developer.apple.com/documentation/bundleresources/entitlements)
- [Apple Developer Documentation - Code Signing](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution)
- [Apple Developer Documentation - Apple Events](https://developer.apple.com/documentation/applescript)

## Last Updated
July 4, 2025 - Issue documented, AppleScript disabled, backspace method active 