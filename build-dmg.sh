#!/bin/bash
set -e

APP_NAME="CozyClip"
BUILD_DIR="build"
DMG_NAME="${APP_NAME}.dmg"

echo "==> Building ${APP_NAME}..."
xcodebuild -project "${APP_NAME}.xcodeproj" \
    -scheme "${APP_NAME}" \
    -configuration Release \
    -derivedDataPath "${BUILD_DIR}" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    clean build 2>&1 | tail -5

APP_PATH="${BUILD_DIR}/Build/Products/Release/${APP_NAME}.app"

if [ ! -d "$APP_PATH" ]; then
    echo "ERROR: Build failed - ${APP_PATH} not found"
    exit 1
fi

echo "==> Creating DMG..."
rm -f "${DMG_NAME}"

# Create a temporary directory for DMG contents
DMG_TEMP="dmg_temp"
rm -rf "${DMG_TEMP}"
mkdir -p "${DMG_TEMP}"
cp -R "${APP_PATH}" "${DMG_TEMP}/"
ln -s /Applications "${DMG_TEMP}/Applications"

hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${DMG_TEMP}" \
    -ov -format UDZO \
    "${DMG_NAME}"

rm -rf "${DMG_TEMP}"

echo ""
echo "==> Done! ${DMG_NAME} created successfully."
echo "    Open it and drag CozyClip to Applications."
