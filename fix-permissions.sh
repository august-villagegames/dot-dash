#!/bin/bash

echo "=== Dot-Dash Permission Fix Script ==="
echo "This script will help fix the automation permission issues."
echo ""

# Check if we're running from the right directory
if [ ! -f "Dot-Dash.xcodeproj/project.pbxproj" ]; then
    echo "Error: Please run this script from the Dot-Dash project root directory"
    exit 1
fi

echo "Current issues detected:"
echo "1. App is signed with ad-hoc signature (should be Developer ID)"
echo "2. Missing usage descriptions in Info.plist"
echo "3. App sandbox may not be properly enabled"
echo ""

echo "To fix these issues, you need to:"
echo ""
echo "1. Open the project in Xcode"
echo "2. Go to the 'Dot-Dash' target"
echo "3. In 'Signing & Capabilities' tab:"
echo "   - Uncheck 'Automatically manage signing'"
echo "   - Select your Developer ID certificate"
echo "   - Ensure your Team is selected"
echo ""
echo "4. Clean the build folder (Product > Clean Build Folder)"
echo "5. Build for Release (Product > Archive)"
echo "6. Export as Developer ID Distribution"
echo "7. Install the new app to /Applications"
echo ""

echo "Alternative quick fix (development only):"
echo "If you don't have a Developer ID certificate, you can:"
echo "1. Keep 'Automatically manage signing' checked"
echo "2. Select your development team"
echo "3. Build and test"
echo ""

echo "After building, run:"
echo "./diagnose-permissions.sh"
echo ""

echo "Expected results after proper build:"
echo "- Code signing should show 'Developer ID Application' instead of 'adhoc'"
echo "- Entitlements should include app sandbox"
echo "- App should appear in System Settings > Privacy & Security > Automation"
echo ""

read -p "Press Enter to continue..."

echo ""
echo "Checking current app status..."
if [ -d "/Applications/Dot-Dash.app" ]; then
    echo "Current app signature:"
    codesign -dv /Applications/Dot-Dash.app 2>&1 | head -10
    
    echo ""
    echo "Current entitlements:"
    codesign -d --entitlements :- /Applications/Dot-Dash.app 2>/dev/null || echo "No entitlements found"
    
    echo ""
    echo "Current Info.plist usage descriptions:"
    plutil -p /Applications/Dot-Dash.app/Contents/Info.plist | grep -E "(NSAppleEventsUsageDescription|NSSystemAdministrationUsageDescription)" || echo "Usage descriptions not found"
else
    echo "Dot-Dash.app not found in /Applications"
fi

echo ""
echo "For more detailed diagnostics, run:"
echo "./diagnose-permissions.sh" 