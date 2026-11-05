#!/usr/bin/env bash
# Regenerates app icons and launch images from assets/branding/logo_source.png.
# macOS only (uses sips). Run after changing the logo artwork.
set -euo pipefail
cd "$(dirname "$0")/.."

flutter test tool/render_branding_test.dart

# App Store icons must not carry an alpha channel: round-trip through JPEG.
tmp="$(mktemp -d)"
sips -s format jpeg -s formatOptions 100 assets/branding/icon_1024.png --out "$tmp/icon.jpg" >/dev/null
sips -s format png "$tmp/icon.jpg" --out assets/branding/icon_1024.png >/dev/null
rm -rf "$tmp"

resize() { sips -z "$1" "$1" "$2" --out "$3" >/dev/null; }

ios_icons=ios/Runner/Assets.xcassets/AppIcon.appiconset
while read -r file px; do
  resize "$px" assets/branding/icon_1024.png "$ios_icons/$file"
done < <(python3 -c "
import json
for i in json.load(open('$ios_icons/Contents.json'))['images']:
    print(i['filename'], round(float(i['size'].split('x')[0]) * int(i['scale'][0])))
")

res=android/app/src/main/res
for pair in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  resize "${pair#*:}" assets/branding/icon_1024.png "$res/mipmap-${pair%%:*}/ic_launcher.png"
done
for pair in mdpi:120 hdpi:180 xhdpi:240 xxhdpi:360 xxxhdpi:480; do
  resize "${pair#*:}" assets/branding/launch_480.png "$res/mipmap-${pair%%:*}/launch_image.png"
done

launch=ios/Runner/Assets.xcassets/LaunchImage.imageset
resize 160 assets/branding/launch_480.png "$launch/LaunchImage.png"
resize 320 assets/branding/launch_480.png "$launch/LaunchImage@2x.png"
resize 480 assets/branding/launch_480.png "$launch/LaunchImage@3x.png"
echo "branding updated"
