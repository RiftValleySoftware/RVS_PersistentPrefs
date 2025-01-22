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
        --module RVS_Persistent_Prefs \
        --output docs \
        --min-acl private \
        --build-tool-arguments -workspace,"RVS_Persistent_Prefs.xcworkspace",-scheme,"RVS_Persistent_Prefs"
cp icon.png docs/icon.png
cd "${CWD}"
