# JackedLog Setup Guide

Complete setup instructions for running JackedLog on Chrome (web) and Android devices using FVM (Flutter Version Manager).

## Prerequisites

- **FVM (Flutter Version Manager)** - For managing Flutter versions
- **Flutter SDK 3.2.6 or higher** (managed via FVM)
- **Dart SDK** (included with Flutter)
- **Chrome browser** (for web development)
- **Android Studio** (for Android development and device connection)

---

## Step 1: Install FVM (Flutter Version Manager)

### On Linux/macOS:
```bash
# Install FVM via pub
dart pub global activate fvm

# Or via snap (Linux)
snap install fvm

# Or via Homebrew (macOS)
brew tap leoafarias/fvm
brew install fvm
```

### Verify Installation:
```bash
fvm --version
```

---

## Step 2: Install Flutter via FVM

```bash
# Navigate to your project directory
cd /path/to/JackedLog

# Install Flutter 3.2.6 (or higher compatible version)
fvm install 3.2.6

# Use Flutter 3.2.6 for this project
fvm use 3.2.6

# Verify Flutter installation
fvm flutter --version
```

---

## Step 3: Install Project Dependencies

```bash
# Make sure you're in the project root directory
cd /home/hash/Desktop/JackedLog

# Install dependencies using FVM Flutter
fvm flutter pub get

# Generate database code (required for Drift)
fvm flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Step 4: Database Setup

The database is **automatically configured** when the app starts:

- **Native platforms (Android/iOS)**: Uses SQLite via Drift's native backend
  - Database file: `jackedlog.sqlite` in app documents directory
  - Automatically created and migrated on first run

- **Web platform**: Uses IndexedDB via Drift's web backend
  - Database stored in browser's IndexedDB
  - Automatically created on first run
  - Persists across browser sessions

**No manual database setup required!** The app handles everything automatically.

---

## Step 5: Run on Chrome (Web)

### Enable Web Support (if not already enabled):

```bash
# Enable web support for the project
fvm flutter create --platforms=web .

# Or if web support is already enabled, skip this step
```

### Run on Chrome:

```bash
# Run in debug mode on Chrome
fvm flutter run -d chrome

# Or run in release mode (faster, no debugging)
fvm flutter run -d chrome --release

# Or specify Chrome profile for persistent data
fvm flutter run -d chrome --web-browser-flag="--profile-directory=Default"
```

### Web-Specific Notes:

- Database is stored in browser's **IndexedDB** (visible in Chrome DevTools → Application → IndexedDB)
- Data persists across browser sessions
- Each browser profile has its own database
- To clear data: Chrome DevTools → Application → Storage → Clear site data

---

## Step 6: Run on Android Phone

### Prerequisites for Android:

1. **Enable Developer Mode on your Android phone:**
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Developer options will appear in Settings

2. **Enable USB Debugging:**
   - Go to Settings → Developer Options
   - Enable "USB Debugging"
   - Connect phone via USB to your computer

3. **Verify Device Connection:**
   ```bash
   # Check if device is detected
   fvm flutter devices

   # You should see your Android device listed
   ```

### Run on Android:

```bash
# Run in debug mode on connected Android device
fvm flutter run -d <device-id>

# Or just run (Flutter will auto-detect if only one device)
fvm flutter run

# Run in release mode (for testing performance)
fvm flutter run --release
```

### Android-Specific Notes:

- Database file: `/data/data/com.presley.jackedlog/app_flutter/jackedlog.sqlite`
- App will automatically migrate from old database if upgrading from previous version
- Requires Android 5.0 (API 21) or higher

---

## Troubleshooting

### FVM Issues:

```bash
# If FVM commands don't work, add to PATH
export PATH="$PATH:$HOME/fvm/default/bin"

# Or create alias in your shell profile (~/.bashrc, ~/.zshrc, etc.)
alias flutter="fvm flutter"
alias dart="fvm dart"
```

### Database Connection Errors:

- **Web**: Make sure you're using Chrome/Edge (IndexedDB support required)
- **Android**: Check app permissions for file storage access
- **Migration Errors**: If you see migration errors, you may need to clear app data:
  - **Web**: Clear browser data for the site
  - **Android**: Settings → Apps → JackedLog → Storage → Clear Data

### Build Errors:

```bash
# Clean and rebuild
fvm flutter clean
fvm flutter pub get
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Then try running again
fvm flutter run
```

### Missing Spotify Config:

If you want to use Spotify features, update `lib/spotify/spotify_config.dart`:

```dart
static const String clientId = 'YOUR_SPOTIFY_CLIENT_ID';  // Get from Spotify Developer Dashboard
static const String redirectUrl = 'jackedlog://callback';
```

The app will work without Spotify - just skip the Spotify connection step.

---

## Quick Reference Commands

```bash
# Install Flutter version
fvm install 3.2.6
fvm use 3.2.6

# Get dependencies
fvm flutter pub get

# Generate code (after schema changes)
fvm flutter pub run build_runner build --delete-conflicting-outputs
fvm flutter pub run build_runner watch  # Auto-regenerate on file changes

# Run on specific platform
fvm flutter run -d chrome        # Web (Chrome)
fvm flutter run -d android       # Android
fvm flutter run                  # Auto-detect device

# Build for release
fvm flutter build web            # Web release build
fvm flutter build apk            # Android APK
fvm flutter build appbundle      # Android App Bundle

# Check Flutter environment
fvm flutter doctor               # Check setup
fvm flutter devices              # List available devices
```

---

## Database Architecture

### Native (Android/iOS):
- **Backend**: SQLite via `sqlite3` package
- **ORM**: Drift 2.28.1
- **Location**: App documents directory
- **Migrations**: Automatic via Drift migration system (currently v60)

### Web:
- **Backend**: IndexedDB via Drift WebDatabase
- **ORM**: Drift 2.28.1
- **Location**: Browser IndexedDB
- **Migrations**: Automatic via Drift migration system (currently v60)

Both platforms use the same database schema and migration system, ensuring data compatibility.

---

## Additional Notes

- **Offline-First**: All data is stored locally - no internet required
- **Data Export**: Use the "Export Data" feature in settings to backup your data
- **Data Import**: Import CSV files or database backups via the import feature
- **Auto-Backups**: Configure automatic backups in Settings → Backup Path

---

## Support

If you encounter issues:

1. Check `fvm flutter doctor` output for configuration issues
2. Review error messages in the console
3. Check database connection files:
   - `lib/database/database_connection_native.dart` (native)
   - `lib/database/database_connection_web.dart` (web)
   - `lib/database/database.dart` (main connection logic)

---

**You're all set!** The app should now run on both Chrome (web) and Android devices. 🚀

