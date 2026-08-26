# eunhyo_iOS

SwiftUI native iOS port of `sofajohnlee/eunhyo2`.

## Estimated port progress: 83%

Progress is estimated by Android feature-module parity rather than raw file count. Most user-facing learning modules now have native SwiftUI equivalents; the largest remaining gaps are legacy assets, richer file/media handling, AIML parity, and final Xcode/device validation.

## Implemented

- Main navigation and elementary / middle / high school menus
- Korean study basics, spelling, idiom practice, Korean book story generator and story editor/TTS
- English study, speech, alphabet tracing, phonics starter groups and word practice
- English sentence CSV import, preview and local persistence
- Math arithmetic practice, scoring, GCD/LCM, measurement conversion, progress dashboard and learning-state selection
- Hanja study, speech and starter radical groups
- History and learning utilities
- Geometry categories and native SwiftUI Canvas previews
- Graph tools / Desmos link
- World country/capital search
- OX Golden Bell quiz
- Educational personality play quiz
- PDF file selection baseline
- Native drawing canvas with undo/clear
- Education links baseline
- Sports YouTube links and magic catalog
- Media library with major Android video catalog entries
- JSON learning-data backup and restore baseline
- Settings and local learning-state storage
- AI learning chat baseline
- Typing practice, maze practice and board-game score tracker

## Android parity work remaining

Major remaining work includes richer AIML assets/chat behavior, complete legacy phonics/education-link assets, in-app PDF rendering, drawing image import/export, advanced interactive geometry, remaining Korean-book image assets, complete media/song catalog parity, legacy gallery/slideshow, study-mail workflow, broader data migration coverage, final bundled assets, automated build checks, and Xcode simulator/device validation.

## Run

Open `eunhyo_iOS.xcodeproj` in Xcode 16 or newer, select a signing team, choose an iPhone/iPad simulator or device, and Run.
