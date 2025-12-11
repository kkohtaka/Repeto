#!/usr/bin/env python3
"""
Generate iOS app icons from SVG source
"""
import os
from cairosvg import svg2png

# iOS app icon sizes needed
# Format: (filename, size)
icon_sizes = [
    # iPhone Notification (iOS 7-15) - 20pt
    ('AppIcon-20@2x.png', 40),
    ('AppIcon-20@3x.png', 60),

    # iPhone Settings (iOS 7-15) - 29pt
    ('AppIcon-29@2x.png', 58),
    ('AppIcon-29@3x.png', 87),

    # iPhone Spotlight (iOS 7-15) - 40pt
    ('AppIcon-40@2x.png', 80),
    ('AppIcon-40@3x.png', 120),

    # iPhone App (iOS 7-15) - 60pt
    ('AppIcon-60@2x.png', 120),
    ('AppIcon-60@3x.png', 180),

    # iPad Notifications (iOS 7-15) - 20pt
    ('AppIcon-20-ipad.png', 20),
    ('AppIcon-20@2x-ipad.png', 40),

    # iPad Settings (iOS 7-15) - 29pt
    ('AppIcon-29-ipad.png', 29),
    ('AppIcon-29@2x-ipad.png', 58),

    # iPad Spotlight (iOS 7-15) - 40pt
    ('AppIcon-40-ipad.png', 40),
    ('AppIcon-40@2x-ipad.png', 80),

    # iPad App (iOS 7-15) - 76pt
    ('AppIcon-76-ipad.png', 76),
    ('AppIcon-76@2x-ipad.png', 152),

    # iPad Pro App (iOS 9-15) - 83.5pt
    ('AppIcon-83.5@2x-ipad.png', 167),

    # App Store
    ('AppIcon-1024.png', 1024),
]

def generate_icons(svg_path, output_dir):
    """Generate all required icon sizes from SVG"""
    os.makedirs(output_dir, exist_ok=True)

    with open(svg_path, 'r') as f:
        svg_data = f.read()

    print(f"🎨 Generating iOS app icons from {svg_path}")
    print(f"📁 Output directory: {output_dir}\n")

    for filename, size in icon_sizes:
        output_path = os.path.join(output_dir, filename)

        svg2png(
            bytestring=svg_data.encode('utf-8'),
            write_to=output_path,
            output_width=size,
            output_height=size,
        )

        print(f"✓ {filename:30} ({size}x{size})")

    print(f"\n✨ Generated {len(icon_sizes)} icon files successfully!")

if __name__ == '__main__':
    svg_path = 'app-icon.svg'
    output_dir = 'AppIcons'

    generate_icons(svg_path, output_dir)
