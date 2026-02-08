#!/bin/sh
CWD="$(pwd)"
MY_SCRIPT_PATH=`dirname "${BASH_SOURCE[0]}"`
cd "${MY_SCRIPT_PATH}"
rm -drf docs
jazzy   --github_url https://github.com/RiftValleySoftware/RVS_PersistentPrefs \
        --readme ./README.md \
        --theme fullwidth \
        --author The\ Great\ Rift\ Valley\ Software\ Company \
        --author_url https://riftvalleysoftware.com \
        --module RVS_PersistentPrefs \
        --output docs \
        --min-acl private \
        --build-tool-arguments -workspace,"RVS_PersistentPrefs.xcworkspace",-scheme,"RVS_PersistentPrefs"
cp icon.png docs/icon.png
cd "${CWD}"
