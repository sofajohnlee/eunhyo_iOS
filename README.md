# eunhyo_iOS

SwiftUI native iOS port of `sofajohnlee/eunhyo2`.

## Estimated port progress: 99.5%

Progress is estimated by Android feature-module parity rather than raw file count. Major user-facing modules are implemented, Android Hari assets are synchronized automatically, and the project passes an actual Xcode 16.4 iOS Simulator build in GitHub Actions. Remaining work is primarily physical-device/UI validation and final visual/media parity checks that cannot be fully verified in headless CI.

## Implemented

- Main navigation and elementary / middle / high school menus
- Korean study basics, spelling, idiom practice, Korean book story generator and story editor/TTS
- English study, speech, alphabet tracing, phonics starter groups and word practice
- English sentence CSV import, preview and local persistence
- Math arithmetic practice, scoring, GCD/LCM, measurement conversion, progress dashboard and learning-state selection
- Hanja study, speech and starter radical groups
- History and learning utilities
- Geometry categories, Canvas previews and interactive size/rotation controls
- Graph tools / Desmos link
- World country/capital search
- OX Golden Bell quiz
- Educational personality play quiz
- PDF file selection plus PDFKit in-app rendering
- Native drawing canvas, background image import, undo/clear and PNG export
- Education links baseline
- Sports YouTube links and magic catalog
- Media library with major Android video catalog entries
- Gallery multi-image selection and slideshow
- Study-mail compose workflow via iOS mail handler
- JSON learning-data backup and restore baseline
- Settings and local learning-state storage
- AIML-compatible core with `*` / `_` wildcard matching, substitutions and predicate state
- Bundled AIML asset loader with Android Hari asset manifest, config/predicate/property loading and category parsing
- Advanced bundled AIML template rendering for `srai`, `set`, `get`, `think`, `random/li`, `condition`, `bot`, `date`, `star`, `request` and `response`
- AI chat uses the bundled Hari AIML engine first and falls back to the native Swift learning rules
- Recursive AIML redirection is depth-limited to prevent runaway `srai` loops
- Android Hari AIML/config assets are synchronized automatically by `scripts/sync_android_assets.sh`
- Hari resource folder is copied into the iOS application bundle
- Typing practice, maze practice and board-game score tracker

## Build verification

- GitHub Actions workflow: `.github/workflows/ios-build.yml`
- Runner: macOS 15
- Xcode: 16.4
- Target: iOS Simulator, Debug, iOS 17+
- Android Hari asset synchronization: passed (12 AIML files, 8 config files)
- Xcode build after advanced AIML renderer integration: passed
- Code signing is disabled in CI because the workflow validates simulator compilation rather than App Store signing

## Android parity work remaining

Remaining work is mainly final iPhone/iPad physical-device interaction review, complete visual/media asset parity where Android-specific resources have no direct iOS equivalent, and broader legacy Android-data migration validation. These are final acceptance/QA items rather than known compile blockers.

## Run

Open `eunhyo_iOS.xcodeproj` in Xcode 16 or newer, select a signing team, choose an iPhone/iPad simulator or device, and Run. If the Hari resource directory is not present in a fresh checkout, run `bash scripts/sync_android_assets.sh` first; GitHub Actions performs this synchronization automatically.
