# Dot-Dash Build and Deployment Guide

## Problem Summary
The app is currently signed with an "adhoc" signature, which prevents it from properly appearing in System Settings > Privacy & Security > Automation. The app needs to be properly signed and built with the correct entitlements.

## Required Changes Made

### 1. ✅ Fixed Entitlements
- Enabled app sandbox
- Added required device permissions
- Ensured automation permissions are properly configured

### 2. ✅ Added Usage Descriptions
- `NSAppleEventsUsageDescription` - explains why app needs Apple Events
- `NSSystemAdministrationUsageDescription` - explains system access needs

### 3. ✅ Changed Code Signing Style
- Changed from "Automatic" to "Manual" code signing
- This allows proper Developer ID signing instead of ad-hoc

## Build Steps

### Step 1: Clean Previous Builds
```bash
# In Xcode, go to Product > Clean Build Folder
# Or use Cmd+Shift+K
```

### Step 2: Configure Code Signing in Xcode
1. Open the project in Xcode
2. Select the "Dot-Dash" target
3. Go to "Signing & Capabilities" tab
4. Ensure "Automatically manage signing" is **UNCHECKED**
5. Select your Developer ID certificate from the dropdown
6. Verify the Team is set correctly

### Step 3: Build for Release
1. In Xcode, select "Any Mac (arm64)" as the destination
2. Select "Release" configuration
3. Go to Product > Archive
4. Wait for the archive to complete

### Step 4: Export the App
1. In the Organizer window, select your archive
2. Click "Distribute App"
3. Choose "Developer ID Distribution"
4. Follow the signing process
5. Export to a location (e.g., Desktop)

### Step 5: Install and Test
```bash
# Remove the old app
sudo rm -rf /Applications/Dot-Dash.app

# Copy the new app
cp -R ~/Desktop/Dot-Dash.app /Applications/

# Verify the signature
codesign -dv /Applications/Dot-Dash.app

# Run diagnostics
./diagnose-permissions.sh
```

## Expected Results After Proper Build

### Code Signing Output Should Show:
```
Executable=/Applications/Dot-Dash.app/Contents/MacOS/Dot-Dash
Identifier=augustcomstock.Dot-Dash
Format=app bundle with Mach-O thin (arm64)
CodeDirectory v=20400 size=656 flags=0x0(none) hashes=10+7 location=embedded
Signature size=8968
Authority=Developer ID Application: [Your Name] ([Team ID])
Authority=Developer ID Certification Authority
Authority=Apple Root CA
Timestamp=...
```

### Entitlements Should Include:
```xml
<key>com.apple.security.app-sandbox</key>
<true/>
<key>com.apple.security.automation.apple-events</key>
<true/>
<key>com.apple.security.device.input-device</key>
<true/>
```

### TCC Database Should Show:
```sql
-- After running the app and attempting Apple Events
augustcomstock.Dot-Dash|kTCCServiceAppleEvents|2|4
```

## Troubleshooting Build Issues

### If Code Signing Fails:
1. Ensure you have a valid Developer ID certificate
2. Check that the certificate is not expired
3. Verify the Team ID matches your Apple Developer account
4. Try revoking and regenerating the certificate

### If Entitlements Don't Apply:
1. Clean build folder completely
2. Delete derived data: `~/Library/Developer/Xcode/DerivedData`
3. Rebuild from scratch
4. Verify entitlements file is included in the target

### If Usage Descriptions Don't Appear:
1. Check that `GENERATE_INFOPLIST_FILE = YES` is set
2. Verify the `INFOPLIST_KEY_*` settings are in both Debug and Release
3. Clean and rebuild

## Alternative: Development Build

If you don't have a Developer ID certificate, you can still test with a development build:

### Step 1: Use Development Team
1. In Xcode, select your development team
2. Keep "Automatically manage signing" checked
3. Build for development

### Step 2: Test Permissions
1. Install the development build
2. Run the app
3. Check if it appears in Automation permissions
4. Note: Development builds may have limited permission capabilities

## Verification Checklist

After building and installing:

- [ ] App launches without errors
- [ ] Code signing shows proper Developer ID (not ad-hoc)
- [ ] Entitlements include app sandbox and automation
- [ ] Usage descriptions appear in Info.plist
- [ ] App appears in System Settings > Privacy & Security > Automation
- [ ] TCC database contains Apple Events entry
- [ ] Diagnostic script shows all green checkmarks

## Next Steps

1. **Build the app** following the steps above
2. **Install and test** the new build
3. **Run diagnostics** to verify permissions
4. **Test text expansion** functionality
5. **Submit for notarization** if distributing outside App Store

## Support

If you encounter issues during the build process:
1. Check Xcode's build log for specific errors
2. Verify your Apple Developer account status
3. Ensure all certificates are valid and not expired
4. Try building on a different machine if needed 