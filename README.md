# Loyalty Wallet

A modern, offline-first Flutter application for storing and managing loyalty cards with barcode/QR code support.

![Loyalty Wallet Banner](https://via.placeholder.com/800x200/673AB7/FFFFFF?text=Loyalty+Wallet)

## Overview

Loyalty Wallet allows users to digitize their physical loyalty cards, reducing wallet clutter while ensuring quick access when needed. The app works completely offline, making it reliable regardless of network conditions.

## Features

- **Digital Card Storage**: Store all loyalty cards in one secure location
- **Multiple Barcode Formats**: Support for QR codes, Code128, and EAN-13 barcodes
- **Custom Card Colors**: Personalize each card with different colors
- **Offline Functionality**: Works 100% offline - no internet required
- **Barcode Scanner**: Built-in scanner to easily add new cards
- **Secure Storage**: Card data is stored securely on your device
- **User Authentication**: Simple login/registration system
- **Modern UI**: Clean, intuitive interface with Material Design 3

## Screenshots

| Add New Card | Card Detail View | Card with Barcode |
|:-:|:-:|:-:|
| ![Add Card](https://via.placeholder.com/250x500/F5F5F5/000000?text=Add+Card) | ![Card Detail](https://via.placeholder.com/250x500/F5F5F5/000000?text=Card+Detail) | ![Barcode View](https://via.placeholder.com/250x500/F5F5F5/000000?text=Barcode+View) |

## Installation

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / Xcode (for mobile deployment)
- Chrome (for web testing)

### Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/loyalty_wallet.git
   cd loyalty_wallet
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the application:
   ```bash
   # For mobile
   flutter run
   
   # For web (using web-compatible version)
   flutter run -t lib/web_compatible_main.dart -d chrome
   ```

## Technical Architecture

### Components

- **Mock Services**: Simulated backend services for authentication, storage, notifications, and synchronization
- **Provider Pattern**: State management using the Provider package
- **Local Storage**: Data persistence using SharedPreferences
- **Barcode Generation**: Client-side barcode/QR code generation

### Directory Structure

```
lib/
├── main.dart                    # Standard entry point (Firebase integration)
├── web_compatible_main.dart     # Web-compatible entry point
├── main_simplified.dart         # Simplified version without dependencies
├── services/
│   ├── mock_auth_service.dart   # Authentication service
│   ├── mock_storage_service.dart # Data storage service
│   ├── mock_sync_service.dart   # Synchronization service
│   └── mock_notification_service.dart # Notification service
```

## Usage Guide

### Adding a Loyalty Card

1. Tap the "+" button to add a new card
2. Enter the company name and card name
3. Choose a color for the card
4. Scan the barcode or manually enter the number
5. Select the appropriate barcode type
6. Tap "Create new Card" to save

### Viewing a Card

1. Tap on any card in the main list
2. View the card details and barcode/QR code
3. Present the digital barcode at the store for scanning

### Deleting a Card

1. Open the card details page
2. Tap "Delete card" at the bottom
3. Confirm deletion in the dialog

## Technology Stack

- **Frontend**: Flutter 3.0+
- **State Management**: Provider 6.1.1
- **Local Storage**: SharedPreferences 2.2.2, Hive 2.2.3
- **Barcode Generation**: barcode_widget 2.0.4
- **Barcode Scanning**: flutter_barcode_scanner 2.0.0
- **Notifications**: flutter_local_notifications 15.1.0+1
- **UI Components**: flutter_slidable 3.0.0, Material Design 3

## Web Compatibility

This app uses a special web-compatible implementation (`web_compatible_main.dart`) that replaces Firebase services with mock implementations to ensure functionality in web environments. To run the web version:

```bash
flutter run -t lib/web_compatible_main.dart -d chrome
```

## Offline Functionality

The app is designed to work 100% offline:

- All data is stored locally on the device
- Authentication is handled locally with mock services
- Barcode generation happens on-device
- No network requests are needed for core functionality

## Future Improvements

- Card categorization and tagging
- Expiry date tracking and reminders
- Automatic suggestions for popular card formats
- Dark mode support
- Custom barcode formats
- Data export/import functionality
- Real backend integration option

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request
