# Build Configuration Fix

## Info.plist Conflict Resolution

The project was experiencing "Multiple commands producing the same Info.plist file" errors because:

1. The project has `GENERATE_INFOPLIST_FILE = YES` in build settings
2. There was also a physical Info.plist file present

**Resolution:** Removed the physical Info.plist file to let Xcode generate it automatically.

## Required Manual Configuration in Xcode

Since the Info.plist file contained calendar permissions, you need to add these manually in Xcode:

### Calendar Permissions Setup

1. Open the project in Xcode
2. Select the main app target ("Lender-s-Ledger")
3. Go to the "Info" tab
4. Add the following custom keys:

- **Key:** `NSCalendarsUsageDescription` 
  **Type:** String
  **Value:** `Lender's Ledger needs calendar access to create return date reminders for your lent items.`

- **Key:** `NSCalendarsWriteOnlyUsageDescription`
  **Type:** String  
  **Value:** `Lender's Ledger needs calendar access to create return date reminders for your lent items.`

### Alternative: Add via Build Settings

You can also add these in the Build Settings:

1. Select the target
2. Go to Build Settings
3. Search for "Info.plist"
4. Find "Custom Target Properties" section
5. Add:
   - `INFOPLIST_KEY_NSCalendarsUsageDescription = Lender's Ledger needs calendar access to create return date reminders for your lent items.`
   - `INFOPLIST_KEY_NSCalendarsWriteOnlyUsageDescription = Lender's Ledger needs calendar access to create return date reminders for your lent items.`

This will resolve the Info.plist conflicts and maintain proper calendar permissions.