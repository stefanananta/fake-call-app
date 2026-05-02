# Fake Call App — Flutter

A fake incoming call app for iOS (and Android) that lets you schedule a fake
call to escape noisy situations.

---

## Features
- Set any caller name and phone number
- Delay timer from 5 to 60 seconds
- Real vibration pattern (like a true incoming call)
- Pulse animation on the avatar while ringing
- Switchable to "accepted call" view with live call timer
- Full-screen call UI that matches iOS aesthetics

---

## How to Run on Your iPhone (Windows PC)

### Step 1 — Install Flutter on Windows
1. Download Flutter SDK: https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH
4. Run `flutter doctor` in PowerShell to verify

### Step 2 — Install dependencies
```bash
cd fake_call_app
flutter pub get
```

### Step 3 — Build for iOS (requires a Mac or cloud Mac)

Since you're on Windows, use **Codemagic** (free tier):

1. Push this project to GitHub
2. Go to https://codemagic.io and connect your GitHub repo
3. Set up an iOS workflow
4. Download the `.ipa` file from the build artifacts

### Step 4 — Install on your iPhone using AltStore (Windows)

1. Install **AltStore** on Windows: https://altstore.io
2. Connect your iPhone via USB
3. Open AltStore on Windows → drag the `.ipa` file in
4. Sign in with your Apple ID when prompted
5. Done! Open the app on your iPhone ✅

---

## Notes
- AltStore re-signs the app every 7 days automatically if AltStore is running
- No jailbreak required
- Works on iOS 14+

---

## Project Structure
```
lib/
  main.dart              # App entry point
  screens/
    setup_screen.dart    # Caller config + delay timer
    call_screen.dart     # Full-screen incoming call UI
pubspec.yaml             # Dependencies
```
