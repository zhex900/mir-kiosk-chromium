#!/bin/bash
# Copyright 2016 The Chromium Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.
#
# Purpose: Pack a Chromium extension directory into crx format (generate PEM
# key if necessary), generate key for manifest file .
set -eu

if test $# -ne 2; then
  echo "Usage: $0 <name> <extension dir>"
  exit 1
fi
name=$1
dir=$2
crx="$name.crx"
pub="$name.pub"
sig="$name.sig"
zip="$name.zip"
trap 'rm -f "$pub" "$sig" "$zip"' EXIT

# Create private key called key.pem, if one does not already exist outside build dir.
key="../../chromium-key.pem"
if [ ! -f "$key" ];  then
  openssl genrsa 2048 | openssl pkcs8 -topk8 -nocrypt -out "$key"
fi

# generate string to be used as "key" in manifest.json
manifestkey=$(openssl rsa -in "$key" -pubout -outform DER | openssl base64 -A)
# insert key into the manifest
if [ ! -f "$dir/manifest.json.bak" ]; then
  mv "$dir/manifest.json" "$dir/manifest.json.bak"
fi
awk '/manifest_version/ { print; print "  key: \"$manifestkey\""; next }1' "$dir/manifest.json.bak" > "$dir/manifest.json"

# zip up the crx dir
cwd=$(pwd -P)
(cd "$dir" && zip -qr -9 -x "manifest.json.bak" -X "$cwd/$zip" .)
# signature
openssl sha1 -sha1 -binary -sign "$key" < "$zip" > "$sig"
# public key
openssl rsa -pubout -outform DER < "$key" > "$pub" 2>/dev/null
byte_swap () {
  # Take "abcdefgh" and return it as "ghefcdab"
  echo "${1:6:2}${1:4:2}${1:2:2}${1:0:2}"
}
crmagic_hex="4372 3234" # Cr24
version_hex="0200 0000" # 2
pub_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$pub" | awk '{print $5}')))
sig_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$sig" | awk '{print $5}')))
(
  echo "$crmagic_hex $version_hex $pub_len_hex $sig_len_hex" | xxd -r -p
  cat "$pub" "$sig" "$zip"
) > "$crx"
echo "Wrote $crx"

# calculate extension ID and save to file
extension=$(openssl rsa -in "$key" -pubout -outform DER | shasum -a 256 | head -c32 | tr 0-9a-f a-p)
echo "$extension" > extension.id

# create Chromium preferences file to arrange pre-install
cat > "${extension}.json" <<EOL
{
  "external_crx": "/etc/chromium-browser/${crx}",
  "external_version": "1.0",
}
EOL
