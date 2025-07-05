#!/bin/bash

echo "=== Dot-Dash Permission Diagnostics ==="
echo "Date: $(date)"
echo ""

# Check if app exists
APP_PATH="/Applications/Dot-Dash.app"
if [ -d "$APP_PATH" ]; then
    echo "✓ Dot-Dash app found at: $APP_PATH"
else
    echo "✗ Dot-Dash app not found at: $APP_PATH"
    echo "  Looking for other locations..."
    find /Applications -name "Dot-Dash.app" 2>/dev/null
fi

echo ""

# Check app signature
echo "=== App Signature ==="
if [ -d "$APP_PATH" ]; then
    echo "Code signing info:"
    codesign -dv "$APP_PATH" 2>&1
    echo ""
    
    echo "Notarization info:"
    codesign -dv --verbose=4 "$APP_PATH" 2>&1 | grep -E "(Authority|Team|Notarization)" || echo "No notarization info found"
fi

echo ""

# Check entitlements
echo "=== Entitlements ==="
if [ -d "$APP_PATH" ]; then
    echo "App entitlements:"
    codesign -d --entitlements :- "$APP_PATH" 2>/dev/null || echo "No entitlements found"
fi

echo ""

# Check TCC database for automation permissions
echo "=== TCC Database (Automation Permissions) ==="
echo "Checking TCC database for Dot-Dash entries..."

# Check both user and system TCC databases
TCC_DB_USER="$HOME/Library/Application Support/com.apple.TCC/TCC.db"
TCC_DB_SYSTEM="/Library/Application Support/com.apple.TCC/TCC.db"

if [ -f "$TCC_DB_USER" ]; then
    echo "User TCC database entries for Dot-Dash:"
    sqlite3 "$TCC_DB_USER" "SELECT client, service, auth_value, auth_reason FROM access WHERE client LIKE '%Dot-Dash%' OR client LIKE '%augustcomstock.Dot-Dash%';" 2>/dev/null || echo "No entries found or database not accessible"
else
    echo "User TCC database not found at: $TCC_DB_USER"
fi

echo ""

if [ -f "$TCC_DB_SYSTEM" ]; then
    echo "System TCC database entries for Dot-Dash:"
    sudo sqlite3 "$TCC_DB_SYSTEM" "SELECT client, service, auth_value, auth_reason FROM access WHERE client LIKE '%Dot-Dash%' OR client LIKE '%augustcomstock.Dot-Dash%';" 2>/dev/null || echo "No entries found or database not accessible"
else
    echo "System TCC database not found at: $TCC_DB_SYSTEM"
fi

echo ""

# Check if app is running
echo "=== Running Processes ==="
if pgrep -f "Dot-Dash" > /dev/null; then
    echo "✓ Dot-Dash is currently running"
    ps aux | grep -i "dot-dash" | grep -v grep
else
    echo "✗ Dot-Dash is not currently running"
fi

echo ""

# Check system version
echo "=== System Information ==="
echo "macOS version: $(sw_vers -productVersion)"
echo "Build version: $(sw_vers -buildVersion)"

echo ""

# Check if running from Xcode
echo "=== Development Environment ==="
if [[ "$APP_PATH" == *"DerivedData"* ]]; then
    echo "⚠️  App appears to be running from Xcode (DerivedData)"
    echo "   This may affect permission requests. Try building and running from Applications folder."
else
    echo "✓ App is not running from Xcode"
fi

echo ""

# Check for any crash logs
echo "=== Recent Crash Logs ==="
find ~/Library/Logs/DiagnosticReports -name "*Dot-Dash*" -mtime -1 2>/dev/null | head -5 | while read log; do
    echo "Recent crash log: $log"
done

echo ""

echo "=== Recommendations ==="
echo "1. Ensure the app is properly signed and notarized"
echo "2. Try running the app from Applications folder, not Xcode"
echo "3. Check System Settings > Privacy & Security > Automation"
echo "4. If app doesn't appear in Automation list, try restarting the app"
echo "5. Check Console.app for any permission-related errors"
echo "6. Ensure the app has the required entitlements (com.apple.security.automation.apple-events)"

echo ""
echo "=== End Diagnostics ===" 