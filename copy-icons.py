#!/usr/bin/env python3
"""
Copy generated icons to Xcode Assets catalog with correct naming
"""
import shutil
import os

# Mapping from generated filenames to expected filenames in Assets catalog
icon_mapping = {
    'AppIcon-20-ipad.png': 'AppIcon-20.png',
    'AppIcon-29-ipad.png': 'AppIcon-29.png',
    'AppIcon-20@2x.png': 'AppIcon-40.png',
    'AppIcon-29@2x.png': 'AppIcon-58.png',
    'AppIcon-20@3x.png': 'AppIcon-60.png',
    'AppIcon-76-ipad.png': 'AppIcon-76.png',
    'AppIcon-40@2x.png': 'AppIcon-80.png',
    'AppIcon-29@3x.png': 'AppIcon-87.png',
    'AppIcon-60@2x.png': 'AppIcon-120.png',
    'AppIcon-76@2x-ipad.png': 'AppIcon-152.png',
    'AppIcon-83.5@2x-ipad.png': 'AppIcon-167.png',
    'AppIcon-60@3x.png': 'AppIcon-180.png',
    'AppIcon-1024.png': 'AppIcon-1024.png',
}

def copy_icons(source_dir, dest_dir):
    """Copy icons with correct naming to Assets catalog"""
    print(f"📋 Copying icons to Xcode Assets catalog")
    print(f"   Source: {source_dir}")
    print(f"   Destination: {dest_dir}\n")

    copied_count = 0
    for source_name, dest_name in icon_mapping.items():
        source_path = os.path.join(source_dir, source_name)
        dest_path = os.path.join(dest_dir, dest_name)

        if not os.path.exists(source_path):
            print(f"⚠️  {source_name:35} - NOT FOUND")
            continue

        shutil.copy2(source_path, dest_path)
        size = os.path.getsize(dest_path)
        print(f"✓  {dest_name:20} ← {source_name:35} ({size:,} bytes)")
        copied_count += 1

    print(f"\n✨ Copied {copied_count} icon files successfully!")

if __name__ == '__main__':
    source_dir = 'AppIcons'
    dest_dir = 'Repeto/Assets.xcassets/AppIcon.appiconset'

    copy_icons(source_dir, dest_dir)
