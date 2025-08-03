#!/bin/bash

# Build Configuration Validation Script
# This script helps prevent Info.plist conflicts and validates build settings

echo "🔍 Validating build configuration..."

PROJECT_FILE="Lender-s-Ledger.xcodeproj/project.pbxproj"
APP_INFO_PLIST="Lender-s-Ledger/Info.plist"

# Check if project file exists
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Error: Project file not found at $PROJECT_FILE"
    exit 1
fi

# Check for Info.plist conflicts
echo "📋 Checking for Info.plist conflicts..."

# Check if GENERATE_INFOPLIST_FILE is set to YES
GENERATE_COUNT=$(grep -c "GENERATE_INFOPLIST_FILE = YES" "$PROJECT_FILE")
echo "   Found GENERATE_INFOPLIST_FILE = YES in $GENERATE_COUNT configurations"

# Check if manual Info.plist exists
if [ -f "$APP_INFO_PLIST" ]; then
    echo "❌ Warning: Manual Info.plist file exists at $APP_INFO_PLIST"
    echo "   This may conflict with GENERATE_INFOPLIST_FILE = YES"
    echo "   Consider either:"
    echo "   1. Removing the manual Info.plist and using build settings (recommended)"
    echo "   2. Setting GENERATE_INFOPLIST_FILE = NO and using manual Info.plist"
else
    echo "✅ No manual Info.plist found - using Xcode auto-generation"
fi

# Check for required camera usage description
if grep -q "INFOPLIST_KEY_NSCameraUsageDescription" "$PROJECT_FILE"; then
    echo "✅ Camera usage description configured in build settings"
else
    echo "❌ Warning: NSCameraUsageDescription not found in build settings"
    echo "   This is required for QR code scanning functionality"
fi

# Validate Swift files
echo "🔧 Validating Swift syntax..."
SWIFT_FILES=$(find Lender-s-Ledger -name "*.swift" | wc -l)
echo "   Found $SWIFT_FILES Swift files"

# Check if swift compiler is available
if command -v swift &> /dev/null; then
    echo "   Testing Swift syntax..."
    if find Lender-s-Ledger -name "*.swift" | xargs swift -frontend -parse - > /dev/null 2>&1; then
        echo "✅ All Swift files have valid syntax"
    else
        echo "❌ Syntax errors found in Swift files"
        exit 1
    fi
else
    echo "⚠️  Swift compiler not available for syntax validation"
fi

echo "✅ Build configuration validation complete!"