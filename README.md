# LaunchPad (macOS)

A beautiful, full-screen Launchpad replacement for macOS, built with SwiftUI.

## Features

- Full-screen display with a semi-transparent background
- Grid layout for app icons with proper spacing and pagination
- Click-to-launch functionality for apps
- Click anywhere outside the content to hide the Launchpad
- App icons and text are visually clear and styled
- Drag-and-drop to create folders
- Search bar for quick app filtering

## Getting Started

### Requirements
- macOS 12.0+
- Xcode 14+

### Build & Run
1. Clone this repository:
   ```sh
   git clone https://github.com/your-username/your-repo.git
   ```
2. Open `LaunchPad.xcodeproj` in Xcode.
3. Select the `LaunchPad` scheme.
4. Press `Cmd+R` to build and run.

### Distribute/Export
- Use `Product > Archive` in Xcode to create a release build.
- Use the Organizer to export `.app` or submit to the App Store.

## Project Structure
- `LaunchPad/` — Main app code (SwiftUI views, models)
- `LaunchPadTests/` — Unit tests
- `LaunchPadUITests/` — UI tests

## Customization
- Modify grid layout, icon size, and colors in `AppGridView.swift`.
- Update search and folder logic as needed.

## License
MIT

---

**Author:** Chu Feng
