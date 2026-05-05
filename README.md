# 🥘 SaffronEats — Premium Food Delivery Platform

The premium food ordering experience for Adama, built with Flutter and Supabase.

## 🔑 Admin & Owner Credentials
For testing purposes, please use the following accounts:

Role	Email	Password
Admin	admin@saffroneats.com	password123
Kenbon Owner	kenbon@saffroneats.com	password123
YegnawBet Owner	yegnawbet@saffroneats.com	password123
Gola Owner	gola@saffroneats.com	password123
Marafa Owner	marafa@saffroneats.com	password123
---

## 📸 Screenshots

> _The app features a vibrant "Saffron Orange" aesthetic with dark mode support._

| Customer App | Restaurant View | Cart & Checkout |
|---|---|---|
| ![Home](https://raw.githubusercontent.com/flutter/flutter/master/docs/images/logo.png) | ![Restaurant](https://raw.githubusercontent.com/flutter/flutter/master/docs/images/logo.png) | ![Cart](https://raw.githubusercontent.com/flutter/flutter/master/docs/images/logo.png) |

---

## 🧩 Key Features

This platform connects **customers**, **restaurant owners**, and **superadmins** through a unified Flutter application:

### 👤 Customer Features
- **Smart Discovery**: Search restaurants or filter by category (Meat, Fast Food, Meals, Traditional).
- **Interactive Menus**: Browse categorical menus with high-res photos and detailed descriptions.
- **Dynamic Cart**: Real-time quantity management, tip selection, and order summary.
- **Order Tracking**: Visual timeline for order status (Placed → Preparing → Delivering → Delivered).
- **Profile Hub**: Manage addresses, VIP status, and referral codes.

### 🏢 Restaurant Owner Hub
- **Live Analytics**: Real-time revenue charts and growth metrics via `fl_chart`.
- **Order Pipeline**: Monitor active orders and sales distribution.
- **Menu Management**: Ability to add/edit menu items and restaurant details.

### ⚙️ Superadmin Control Panel
- **Network Health**: Dashboard tracking total restaurants, users, and platform revenue.
- **Partner Vetting**: Review and approve new restaurant applications.
- **Node Management**: Oversight of all restaurant nodes in the network.

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| **Mobile App** | Flutter (Native Android/iOS/Linux) |
| **State Management** | Provider (ChangeNotifier) |
| **Navigation** | Go Router (Typed Routing) |
| **Backend** | Supabase (PostgreSQL + Auth + Storage) |
| **Storage** | shared_preferences (Local Persistence) |
| **Animations** | flutter_animate |
| **UI Kit** | Material 3 + Google Fonts (Outfit & Inter) |

---

## 🗂️ File Structure

```
lib/
├── main.dart + app.dart          # Entry point & App Routing
├── core/
│   └── constants/                # Colors, Theme, Mock Data
├── models/                       # Data Models (User, Restaurant, Order, etc.)
├── providers/                    # State Providers (Auth, Cart, Restaurant)
├── widgets/                      # Reusable UI Components
└── screens/
    ├── auth/                     # Unified Auth & Registration
    ├── customer/                 # Home, Detail, Cart, Orders, Profile
    ├── owner/                    # Dashboard & Partner Application
    └── superadmin/               # Control Panel
```

---

## 🚀 How to Run Locally

### 1. Install Flutter
If you don't have Flutter installed, follow the [official guide](https://docs.flutter.dev/get-started/install) or use these Linux commands:
```bash
sudo snap install flutter --classic
flutter doctor
```

### 2. Setup the Project
```bash
cd "Food Ordering App"
flutter create .
flutter pub get
```

### 3. Run on Desktop/Web
```bash
flutter run -d linux   # Run as native desktop app
flutter run -d chrome  # Run in browser
```

---

## 📱 How to Run on Your Phone

### **Android Instructions**
1. **Enable Developer Options**: Go to `Settings` > `About Phone` > Tap `Build Number` 7 times.
2. **Enable USB Debugging**: In `Settings` > `System` > `Developer Options`, toggle **USB Debugging** to ON.
3. **Connect Phone**: Plug your phone into your computer via USB.
4. **Select Device**: 
   ```bash
   flutter devices
   ```
   Confirm your phone appears in the list.
5. **Launch App**:
   ```bash
   flutter run
   ```

### **iOS Instructions (macOS only)**
1. Install **Xcode** from the App Store.
2. Open the project and run `open ios/Runner.xcworkspace`.
3. Select your physical iPhone as the build target.
4. Run `flutter run` in the terminal.

---

## 🌐 Supabase Integration

To use the live backend, update your credentials in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

---

## 📄 License

Private project — All rights reserved © 2025 SaffronEats.
