# eunhyo_iOS

SwiftUI native iOS port of `sofajohnlee/eunhyo2`.

## Estimated port progress: 98%

Progress is estimated by Android feature-module parity rather than raw file count. Major user-facing modules are implemented. Remaining work is concentrated in complete legacy asset copying and final Xcode simulator/device validation.

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
- Bundled AIML asset loader with Android Hari asset manifest, config/predicate/property loading and simple category parsing
- Hari resource folder added to Xcode Copy Bundle Resources
- Typing practice, maze practice and board-game score tracker

## Build-safety work completed

- Xcode target explicitly includes all Swift source modules through `AIMLAssetLoader.swift`
- Compatibility aliases added for earlier menu type names (`PDFLibraryView`, `SportsVideosView`, `MagicVideosView`)
- Main navigation exposes the AIML-compatible chat and interactive geometry directly
- Hari resource folder is configured as a bundled resource folder
- Project marketing version is 1.7

## Android parity work remaining

Remaining work includes copying the complete legacy Hari AIML/config file set, complete phonics and education-link resource parity, remaining Korean-book image assets, complete media/song asset parity, broader Android-to-iOS migration coverage, automated macOS build checks, and final Xcode simulator/device validation.

## Run

Open `eunhyo_iOS.xcodeproj` in Xcode 16 or newer, select a signing team, choose an iPhone/iPad simulator or device, and Run.
