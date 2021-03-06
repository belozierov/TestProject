#!/bin/sh
MY_KEYCHAIN=ios-build.keychain
MY_KEYCHAIN_PASSWORD="secret"
security create-keychain -p "$MY_KEYCHAIN_PASSWORD" "$MY_KEYCHAIN"
security list-keychains -d user -s "$MY_KEYCHAIN" $(security list-keychains -d user | sed s/\"//g)
security set-keychain-settings "$MY_KEYCHAIN"
security unlock-keychain -p "$MY_KEYCHAIN_PASSWORD" "$MY_KEYCHAIN"

security import ./scripts/certs/apple.cer -k ~/Library/Keychains/ios-build.keychain -A /usr/bin/codesign
security import ./scripts/certs/dist.cer -k ~/Library/Keychains/ios-build.keychain -A /usr/bin/codesign
security import ./scripts/certs/dist.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -A /usr/bin/codesign
security import ./scripts/certs/dev.cer -k ~/Library/Keychains/ios-build.keychain -A /usr/bin/codesign
security import ./scripts/certs/dev.p12 -k ~/Library/Keychains/ios-build.keychain -P $KEY_PASSWORD -A /usr/bin/codesign

CERT_IDENTITY=$(security find-identity -v -p codesigning "$MY_KEYCHAIN" | head -1 | grep '"' | sed -e 's/[^"]*"//' -e 's/".*//') # Programmatically derive the identity
CERT_UUID=$(security find-identity -v -p codesigning "$MY_KEYCHAIN" | head -1 | grep '"' | awk '{print $2}') # Handy to have UUID (just in case)
security set-key-partition-list -S apple-tool:,apple: -s -k $MY_KEYCHAIN_PASSWORD -D "$CERT_IDENTITY" -t private $MY_KEYCHAIN # Enable codesigning from a non user interactive shell

echo "list keychains: "
security list-keychains
echo " ****** "

echo "find indentities keychains: "
security find-identity -p codesigning  ~/Library/Keychains/ios-build.keychain
echo " ****** "

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./scripts/profile/TestProject.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
cp ./scripts/profile/TestProject_ad_hoc.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/
