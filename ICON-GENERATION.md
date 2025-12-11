# App Icon Generation

This document describes how to generate iOS app icons for Repeto.

## Overview

The app icon is generated from a single SVG source file (`app-icon.svg`) and automatically
converted to all required iOS app icon sizes.

## Design

- **Style**: Minimalist
- **Theme**: Task repeat reminder (circular arrow + checkmark)
- **Colors**: Blue gradient (#0A84FF → #5AC8FA)
- **Size**: 1024x1024 base, scaled to all iOS sizes

## Generated Sizes

The following icon sizes are generated for iOS:

- **iPhone**: 40, 60, 58, 87, 80, 120, 180 px
- **iPad**: 20, 29, 40, 58, 76, 80, 152, 167 px
- **App Store**: 1024 px

## How to Regenerate Icons

If you need to modify the app icon:

### 1. Edit the SVG source

Edit `app-icon.svg` with any SVG editor or text editor.

### 2. Install dependencies

```bash
pip3 install cairosvg pillow
```

### 3. Generate PNG files

```bash
python3 generate-icons.py
```

This creates all required sizes in the `AppIcons/` directory.

### 4. Copy to Xcode Assets

```bash
python3 copy-icons.py
```

This copies the generated icons to `Repeto/Assets.xcassets/AppIcon.appiconset/`
with the correct filenames expected by Xcode.

## Files

- `app-icon.svg` - Source SVG file (1024x1024)
- `generate-icons.py` - Converts SVG to all required PNG sizes
- `copy-icons.py` - Copies generated icons to Xcode Assets catalog
- `AppIcons/` - Temporary directory (gitignored)

## Notes

- The `AppIcons/` directory is temporary and gitignored
- Only the source SVG and Python scripts are version controlled
- The generated PNG files in the Assets catalog are committed to git
