# SecureFlow Mobile App

This is the client-side Flutter application for SecureFlow. It acts as a **Zero-Knowledge Vault**, meaning it encrypts your data *before* sending it to the backend. The server never sees your password or your secrets.

## 1. Prerequisites

Before you begin, ensure you have the following installed:
- **Flutter SDK** (v3.0+)
- **Android Studio** (for Android Emulator) or **Xcode** (for iOS Simulator, Mac only).
- **VS Code** (Optional, if you prefer it over Android Studio).

## 2. Opening in Android Studio

1.  Open **Android Studio**.
2.  Select **"Open"**.
3.  Navigate to the `mobile-app` folder inside `secure-flow-backend`.
    *   Path: `.../secure-flow-backend/mobile-app`
4.  Click **OK**.
5.  Android Studio will sync the project. If prompted, click **"Get dependencies"**.

## 3. Configuration

The app is pre-configured to connect to the backend running locally.

- **Android Emulator:** Connects to `http://10.0.2.2:3000` (which forwards to your computer's `localhost:3000`).
- **iOS Simulator / Web:** Connects to `http://localhost:3000`.

**Important:** Ensure your backend is running!
```bash
cd secure-flow-backend
npm run start
```

## 4. Running the App

### Via Android Studio
1.  Select an emulator (e.g., "Pixel 5 API 33") from the device dropdown in the toolbar.
2.  Click the green **Run** (Play) button.

### Via Command Line
```bash
cd mobile-app
flutter pub get
flutter run
```

## 5. Testing Guide (Manual)

Follow these steps to verify the application works:

### Step 1: Registration (SRP)
1.  Launch the app. You should see the **Login Screen**.
2.  Click **"Create an Account"**.
3.  Enter a username (e.g., `alice`) and a password (e.g., `password123`).
4.  Click **"Create Account"**.
    *   *What happens:* The app generates a random Salt and Verifier and sends them to the server.
    *   *Success:* You will see a success message and be returned to the Login screen.

### Step 2: Login (Zero-Knowledge Proof)
1.  Enter the credentials you just created.
2.  Click **"Login"**.
    *   *What happens:*
        1.  App sends "Challenge" (Public Key A).
        2.  Server returns Salt and Public Key B.
        3.  App computes Session Key and Proof.
        4.  App sends Proof to Server.
    *   *Success:* You are navigated to the **Secure Vault** (Home Screen).

### Step 3: Secure Sync
1.  In the Vault, click the **+ (Plus)** button.
2.  Enter a secret (e.g., "My API Key: 12345").
3.  Click **"Save"**.
    *   *What happens:* The app generates an AES Key from your session, encrypts the text, and sends the *Ciphertext* to the backend.
4.  The list should refresh and show your new item.
    *   *Verification:* The server database only contains encrypted gibberish. Only your app can read it.

## 6. Project Structure

- **`lib/data`**: Data layer.
    - `services/api_service.dart`: HTTP calls.
    - `services/srp_service.dart`: The complex math for SRP authentication.
    - `services/crypto_service.dart`: AES-CBC encryption for your vault data.
    - `services/sync_service.dart`: Orchestrates pushing/pulling data.
- **`lib/logic`**: State Management.
    - `auth_provider.dart`: Holds the user's session and handles Login/Register logic.
- **`lib/ui`**: User Interface.
    - `screens/login_screen.dart`
    - `screens/register_screen.dart`
    - `screens/home_screen.dart`: The main vault view.

## 7. Troubleshooting

**"Network Error" or "Connection Refused"**
- **Cause:** The backend is not running, or the Emulator cannot reach `10.0.2.2`.
- **Fix:** ensure `npm run start` is active in the backend folder.

**"SRP Challenge Failed" or "Invalid Proof"**
- **Cause:** The math calculated by the Flutter app doesn't exactly match the `thinbus-srp` library on the server (e.g., different padding or hashing rules).
- **Fix:** Check `lib/data/services/srp_service.dart` and compare with standard SRP-6a implementations.

