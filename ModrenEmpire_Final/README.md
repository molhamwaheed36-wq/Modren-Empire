# Modren Empire — Full Android Project

Modren Empire is an offline-first technology-company management simulation for Android. The project is packaged as a local WebView asset and has no runtime web-server dependency.

Open `ModrenEmpire_Final` in Android Studio, sync Gradle and build the `app` module. See `BUILD.md` for SDK requirements and `PROJECT_STATUS.md` for honest verification status.

The bank layer is a virtual in-game ledger and adapter contract only; it does not create real money or connect to a real bank. Local LAN co-op uses TCP port 47777 and is documented in `LAN_PROTOCOL.md`.
