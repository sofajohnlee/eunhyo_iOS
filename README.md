# eunhyo_iOS

SwiftUI native iOS port of `sofajohnlee/eunhyo2`.

## Estimated port progress: 70%

Progress is estimated by Android feature-module parity, not raw file count. Core navigation, learning modules, quiz/game modules and several resource-based modules now have native SwiftUI equivalents.

## Implemented

- Main navigation and elementary / middle / high school menus
- Korean study basics, spelling and idiom practice
- English study, speech, alphabet tracing, phonics starter groups and word practice
- English sentence CSV import, preview and local persistence
- Math arithmetic practice, scoring, GCD/LCM and measurement conversion
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
- Sports YouTube links
- Magic YouTube catalog
- Settings and local learning-state storage
- AI learning chat baseline
- Typing practice
- Maze practice
- Board-game score tracker

## Android parity work remaining

Major remaining work includes richer AIML assets/chat behavior, complete phonics legacy CSV asset parity, richer PDF viewing, drawing image import/export, advanced geometry interaction, Korean book/editor, songs/media catalog parity, full education-link catalog parity, legacy gallery/slideshow, study mail, detailed math state/progress screens, data import/export and migration, final bundled assets, and Xcode/device validation.

## Run

Open `eunhyo_iOS.xcodeproj` in Xcode 16 or newer, select a signing team, choose an iPhone/iPad simulator or device, and Run.
