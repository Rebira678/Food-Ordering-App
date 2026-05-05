# 🚀 SaffronEats Deployment Strategy (2026)

Since this project requires a **strictly mobile** deployment without upfront costs (no $99/year Apple Developer fee), we are adopting a "Zero-Budget" distribution strategy.

---

## 🤖 Android: Flexible Distribution

Android allows "sideloading," making it the easiest platform for free distribution.

### 1. Direct APK Distribution
We will host the release APK on **GitHub Releases**.
- **Build Command:** `flutter build apk --release --split-per-abi`
- **Why split?** This generates smaller, device-specific APKs, ideal for users with limited data.
- **Distribution:** Share the link via Telegram, WhatsApp, or email.

### 2. F-Droid (Open Source)
If we choose to make the repository public, we can submit to **F-Droid**. They will build the APK from our source code for us.

### 3. Firebase App Distribution
Best for internal testing (up to 500 testers).
- Provides crash reporting via Crashlytics.
- Completely free for beta builds.

---

## 🍎 iOS: The "Truly Free" Challenge

Building and deploying for iOS on Linux requires a Cloud-based CI/CD approach.

### 1. Building without a Mac (Cloud CI)
Since we are developing on Linux, we cannot build `.ipa` files locally. We will use:
- **Codemagic:** 500 free build minutes/month. Connect our GitHub repo, and it will output the `.ipa`.
- **GitHub Actions:** Use macOS runners (2,000 free minutes, though macOS consumes them faster).

### 2. Sideloading (SideStore / AltStore)
Without a paid developer account, apps stay active for only **7 days**.
- **Solution:** Use **SideStore**. It allows you to "refresh" the 7-day timer over Wi-Fi without a computer.
- **Personal Certificate:** Sign the app using a standard Apple ID.

---

## 🛠️ Recommended CI/CD Workflow

| Action | Platform | Tool |
| :--- | :--- | :--- |
| **Build APK** | Android | GitHub Actions |
| **Build IPA** | iOS | Codemagic |
| **Distribute Beta** | Both | Firebase App Distribution |

---

## 📝 Next Steps for the Team
1. **Keystore Generation**: We need to generate a release keystore for Android and store it securely.
2. **GitHub Secrets**: Add `SUPABASE_URL` and `SUPABASE_ANON_KEY` to GitHub Secrets for automated builds.
3. **App Signing**: Setup a personal Apple ID for iOS signing testing.
