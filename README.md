# 📱 Lender's Ledger

[![iOS](https://img.shields.io/badge/iOS-15.0%2B-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-4.0-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![Xcode](https://img.shields.io/badge/Xcode-15.0%2B-lightgrey.svg)](https://developer.apple.com/xcode/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

> A beautiful and intuitive iOS app for tracking your lent and borrowed items with smart features and seamless sharing.

## 🌟 App Overview

Lender's Ledger is a comprehensive iOS application designed to help you keep track of items you've lent to others or borrowed from them. Never lose track of your belongings again! Whether it's books, tools, electronics, or any other items, this app provides an elegant solution for managing your personal lending library.

Built with modern iOS technologies, the app offers a native, fluid experience with powerful features like QR code sharing, calendar integration, and smart reminders to ensure you and your friends stay organized.

## ✨ Features

### 📋 Core Functionality
- **📝 Lending & Borrowing Tracking** - Easily add and manage items you've lent out or borrowed
- **🏷️ Smart Tagging System** - Categorize items with custom tags for easy organization
- **🔍 Advanced Search & Filtering** - Find items quickly by name, person, tags, or status
- **📅 Return Date Management** - Set and track return dates with overdue notifications
- **📝 Condition Notes** - Add detailed notes about item condition and important details

### 📱 Smart Features
- **📲 QR Code Sharing** - Generate and scan QR codes to instantly share item details
- **📸 Photo Attachments** - Add photos to document item condition and details
- **📅 Calendar Integration** - Automatic calendar reminders for return dates
- **🎯 Dashboard Analytics** - Visual statistics and insights about your lending activity
- **💝 Wishlist Management** - Keep track of items you want to buy or borrow

### 🔧 Advanced Capabilities
- **🤝 Polite Reminder Messages** - Generate thoughtful reminder texts to send to friends
- **🗂️ Cross-View Filtering** - Filter items across different views and screens
- **🗃️ Deleted Items Recovery** - Safely recover accidentally deleted items
- **📊 Activity Tracking** - Monitor recent lending and borrowing activity
- **🏷️ Popular Tags** - Quick access to frequently used categories

## 📱 Screenshots

> *Screenshots will be added here to showcase the app's beautiful interface*

### Main Ledger View
```
[Screenshot placeholder - Main ledger with lent/borrowed items]
```

### Dashboard Analytics
```
[Screenshot placeholder - Dashboard with statistics and charts]
```

### QR Code Sharing
```
[Screenshot placeholder - QR code generation and scanning]
```

### Item Details
```
[Screenshot placeholder - Detailed item view with photo and notes]
```

## 🚀 Installation Instructions

### Prerequisites
- **macOS** 13.0 (Ventura) or later
- **Xcode** 15.0 or later
- **iOS Simulator** or **iOS Device** running iOS 15.0+

### Build and Run

1. **Clone the Repository**
   ```bash
   git clone https://github.com/elkmr-code/Lender-s-Ledger.git
   cd Lender-s-Ledger
   ```

2. **Open in Xcode**
   ```bash
   open Lender-s-Ledger.xcodeproj
   ```

3. **Configure Signing**
   - In Xcode, select the project in the navigator
   - Go to "Signing & Capabilities" tab
   - Select your Apple Developer Team
   - Ensure "Automatically manage signing" is checked

4. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` or click the "Run" button
   - The app will build and launch automatically

### Running Tests

```bash
# Run unit tests
xcodebuild test -scheme Lender-s-Ledger -destination 'platform=iOS Simulator,name=iPhone 15'

# Or run from Xcode
# Press Cmd + U to run all tests
```

## 📋 System Requirements

### Minimum Requirements
- **iOS Version**: 15.0 or later
- **Device Storage**: 50 MB available space
- **Xcode**: 15.0+ (for development)
- **Swift**: 5.9+

### Recommended Requirements
- **iOS Version**: 16.0 or later for optimal performance
- **Device**: iPhone 12 or newer for best camera performance
- **Storage**: 100 MB for photos and data

### Permissions Required
- **📷 Camera Access** - For QR code scanning functionality
- **📅 Calendar Access** - For creating return date reminders (optional)
- **☁️ iCloud Access** - For data synchronization across devices (optional)

## 📖 Usage Guide

### Getting Started

1. **Adding Your First Item**
   - Tap the "+" button in the top-right corner
   - Fill in item details (name, person, type)
   - Optionally add photos, tags, and return dates
   - Tap "Add Item" to save

2. **Using QR Code Sharing**
   - Tap the QR scanner icon in the top-left
   - To share: Select an item → "Share via QR Code"
   - To receive: Point camera at someone's QR code

3. **Managing Return Dates**
   - Set return dates when adding items
   - View overdue items on the dashboard
   - Tap calendar button to add reminders
   - Use "Send Polite Reminder" to message friends

### Advanced Features

#### Dashboard Analytics
- View statistics about your lending activity
- Tap on stat cards to filter the main ledger
- Monitor overdue items and recent activity
- Explore popular tags for quick filtering

#### Wishlist Management
- Switch to the "Wishlist" tab
- Add items you want to buy or borrow
- Set priority levels and estimated prices
- Use tags to organize wishlist categories

#### Smart Filtering
- Use the search bar to find specific items
- Filter by tags, person names, or item names
- Cross-view filtering works across all screens
- Clear filters anytime from the filter indicator

## 🛠️ Technologies Used

### Core Frameworks
- **SwiftUI** - Modern declarative UI framework
- **Combine** - Reactive programming for data flow
- **Foundation** - Core system services and utilities

### iOS Integration
- **EventKit** - Calendar integration for return reminders
- **PhotosUI** - Photo selection and management
- **Core Image** - QR code generation and processing
- **AVFoundation** - Camera functionality for QR scanning

### Data & Storage
- **CloudKit** - Cloud synchronization and backup
- **Core Data** - Local data persistence
- **UserDefaults** - App preferences and settings

### Development Tools
- **Xcode 15+** - Integrated development environment
- **Swift Package Manager** - Dependency management
- **XCTest** - Unit and UI testing framework

## 📁 Project Structure

```
Lender-s-Ledger/
├── Lender-s-Ledger/                    # Main app source code
│   ├── Lender_s_LedgerApp.swift       # App entry point and configuration
│   ├── ContentView.swift              # Main ledger view and navigation
│   ├── DashboardView.swift            # Analytics and statistics
│   ├── WishlistView.swift             # Wishlist management
│   ├── EditWishlistItemView.swift     # Wishlist item editing
│   ├── AppStateManager.swift          # Cross-view state management
│   ├── CalendarManager.swift          # Calendar integration
│   ├── QRCodeGenerator.swift          # QR code generation and sharing
│   ├── QRCodeScanner.swift            # QR code scanning functionality
│   ├── LedgerIntents.swift            # Siri shortcuts integration
│   └── Assets.xcassets/               # App icons and images
├── Lender-s-LedgerTests/              # Unit tests
├── Lender-s-LedgerUITests/            # UI automation tests
├── Scripts/                           # Build and validation scripts
└── README.md                          # This file
```

### Architecture Overview

The app follows the **MVVM (Model-View-ViewModel)** pattern with SwiftUI:

- **Models**: `LedgerItem`, `WishlistItem`, `ShareableLedgerItem`
- **ViewModels**: `LedgerViewModel` (ObservableObject for data management)
- **Views**: SwiftUI views for each screen and component
- **Managers**: Service classes for external integrations (Calendar, QR codes)

## 🤝 Contributing Guidelines

We welcome contributions to make Lender's Ledger even better! Here's how you can help:

### Getting Started
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit with clear messages: `git commit -m "Add amazing feature"`
5. Push to your branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

### Development Guidelines

#### Code Style
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftLint for code formatting consistency
- Write clear, descriptive variable and function names
- Add comments for complex logic

#### Testing
- Write unit tests for new functionality
- Ensure UI tests pass on multiple device sizes
- Test on both iOS simulator and physical devices
- Verify accessibility compliance

#### Pull Request Requirements
- ✅ All tests pass
- ✅ Code follows style guidelines
- ✅ New features include tests
- ✅ Documentation is updated
- ✅ No breaking changes without discussion

### Reporting Issues
- Use the GitHub issue tracker
- Include iOS version, device model, and steps to reproduce
- Add screenshots or videos when helpful
- Check existing issues before creating new ones

### Feature Requests
- Open an issue with the "enhancement" label
- Describe the use case and expected behavior
- Consider contributing the implementation yourself!

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2024 Lender's Ledger

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 📞 Contact Information

### Developer
- **GitHub**: [@elkmr-code](https://github.com/elkmr-code)
- **Email**: support@lendersledger.app
- **Project Repository**: [Lender-s-Ledger](https://github.com/elkmr-code/Lender-s-Ledger)

### Support
- 🐛 **Bug Reports**: [GitHub Issues](https://github.com/elkmr-code/Lender-s-Ledger/issues)
- 💡 **Feature Requests**: [GitHub Discussions](https://github.com/elkmr-code/Lender-s-Ledger/discussions)
- 📖 **Documentation**: [Wiki](https://github.com/elkmr-code/Lender-s-Ledger/wiki)

---

<p align="center">
  <strong>Made with ❤️ for the iOS community</strong><br>
  <em>Never lose track of your stuff again!</em>
</p>

<p align="center">
  <a href="#-lenders-ledger">🔝 Back to Top</a>
</p>