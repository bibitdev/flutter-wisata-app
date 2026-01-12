# Flutter Wisata App

Aplikasi Point of Sale (POS) untuk wisata dengan fitur print struk thermal.

## ✨ Features

- 🛒 Product Management & Checkout
- 💳 Multiple Payment Methods (Cash, QRIS)
- 🎫 QR Code Ticket Generation
- 🖨️ **Thermal Receipt Printing** (via Thermer)
- 📄 PDF Export
- 📊 Order Management & Sync
- 🔄 Offline Support with Local Database
- 👤 User Authentication

## 🖨️ Print Feature

Aplikasi ini mendukung **print struk thermal** menggunakan aplikasi Thermer sebagai bridge ke printer Bluetooth.

### Quick Start Print
1. Install [Thermer](https://play.google.com/store/apps/details?id=ru.a402d.rawbtprinter) di HP Android
2. Build & run aplikasi: `flutter clean && flutter run`
3. Test print dari: Settings → Printer → Test Print
4. Print transaksi dari halaman Payment Success

### Dokumentasi Print
- 📖 [Quick Start Guide](QUICK_START_PRINT.md) - Panduan lengkap print
- 🐛 Troubleshooting: Jika error `MissingPluginException`, run `flutter clean && flutter run`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.4.0)
- Android Studio / VS Code
- Android Device / Emulator
- Thermer App (untuk print feature)

### Installation

1. Clone repository
```bash
git clone [repository-url]
cd flutter-wisata-app
```

2. Install dependencies
```bash
flutter pub get
```

3. Run application
```bash
flutter run
```

### Setup Print Feature
```bash
# Full rebuild (required for native code changes)
flutter clean
flutter pub get
flutter run
```

## 📱 Tech Stack

- **Framework:** Flutter
- **State Management:** flutter_bloc
- **Local Database:** sqflite
- **API Client:** dio, http
- **Print:** Platform Channel + Android Intent + Thermer
- **PDF:** pdf package
- **QR Code:** qr_flutter, mobile_scanner
- **Notifications:** flutter_local_notifications

## 📁 Project Structure

```
lib/
├── core/                      # Core utilities
│   ├── components/           # Reusable widgets
│   ├── constants/            # App constants
│   ├── extensions/           # Dart extensions
│   └── utils/
│       ├── auth_utils.dart   # Auth helper
│       └── print_helper.dart # Print helper ⭐
├── data/                      # Data layer
│   ├── datasources/          # Remote & local data sources
│   └── models/               # Data models
└── presentation/              # UI layer
    ├── auth/                 # Authentication pages
    ├── home/                 # Home & main features
    └── settings/             # Settings & printer ⭐
        └── pages/
            ├── setting_page.dart
            └── printer_setting_page.dart
```

## 🔧 Configuration

### API Base URL
Edit `lib/core/constants/variables.dart`:
```dart
static const String baseUrl = 'YOUR_API_URL';
```

### Print Format
Edit `lib/core/utils/print_helper.dart`:
```dart
const width = 32; // 32, 42, or 48 characters
```

## 📖 Documentation

### General
- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter Documentation](https://docs.flutter.dev/)
- [Print Feature Guide](QUICK_START_PRINT.md)

## 🐛 Troubleshooting

### Print Issues
- **MissingPluginException**: Run `flutter clean && flutter run` (full rebuild required)
- **Thermer tidak buka**: Install Thermer dari Play Store
- **Format berantakan**: Thermer Settings → Font: Monospace, Width: 32
- Detail: [QUICK_START_PRINT.md](QUICK_START_PRINT.md)

### General Issues
```bash
# Clean build
flutter clean
flutter pub get
flutter run

# Check logs
flutter logs

# Check devices
flutter devices
```

## 📄 License

This project is a Flutter application for POS system.

## 👥 Contributors

- Development Team

---

**Version:** 1.0.0  
**Last Updated:** January 12, 2026  
**Status:** ✅ Production Ready
