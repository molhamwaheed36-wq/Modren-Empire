# Android Build

## Android Studio

1. Open the `ModrenEmpire_Final` folder.
2. Allow Gradle to sync using Android Gradle Plugin 8.7.3, Kotlin 2.0.21 and compile SDK 35.
3. Build `app` using **Build > Make Project**.
4. Run the `debug` variant on an Android 6.0+ device/emulator.
5. Use `release` only after configuring the developer's own signing key.

## Command line

A machine with JDK 17+, Android SDK 35 and Gradle 8.9+ can run:

```bash
gradle :app:assembleDebug
gradle :app:assembleRelease
```

The supplied sandbox did not contain Android SDK or Gradle, so an APK was not falsely claimed as built here.

## Runtime permissions and LAN

`INTERNET`, `ACCESS_WIFI_STATE` and `CHANGE_WIFI_STATE` are declared for local hotspot/TCP operation. The game does not request a real-money or cloud account permission. LAN uses port `47777`.

## Save behavior

The WebView uses local storage for saves. Director tools can export a JSON backup and import a schema-validated file.
