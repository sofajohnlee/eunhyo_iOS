# eunhyo_iOS

SwiftUI native iOS port of `sofajohnlee/eunhyo2`.

## Estimated port progress: 55%

Progress is estimated by Android feature-module parity, not by raw file count. Core navigation and many self-contained learning modules are now native SwiftUI implementations; resource-heavy and integration-heavy modules remain.

## Implemented

- Main navigation and elementary / middle / high school menus
- Korean study basics, spelling and idiom practice
- English study, speech, alphabet tracing and word practice
- Math arithmetic practice, scoring, GCD/LCM and measurement conversion
- Hanja study, speech and starter radical groups
- History and learning utilities
- Geometry categories and native SwiftUI Canvas previews
- Graph tools / Desmos link
- World country/capital search (30-country Android starter dataset)
- OX Golden Bell quiz
- Educational personality play quiz
- Settings and local learning-state storage
- AI learning chat baseline
- Typing practice
- Maze practice
- Board-game score tracker

## Android parity work remaining

Major remaining work includes richer AIML assets/chat behavior, phonics coloring, English sentence import, PDF library, drawing practice, advanced geometry interaction, Korean book/editor, songs/media, education links, legacy gallery/slideshow, study mail, sports, magic, detailed math state/progress screens, data import/export and migration, plus final asset parity and Xcode/device validation.

## Run

Open `eunhyo_iOS.xcodeproj` in Xcode 16 or newer, select a signing team, choose an iPhone/iPad simulator or device, and Run.
