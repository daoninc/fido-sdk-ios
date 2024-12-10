#!/bin/sh

# build.sh
#
# Created by Jonny Mortensen on FEB 2019.
# Copyright 2019 Daon. All rights reserved.
#
#

PROJECT_NAME=SDKDemo

DIST_DIR=ipa
BUILD_DIR=Build
DEVELOPER_NAME="iPhone Distribution: Daon Inc"
ARCHIVE=${DIST_DIR}/${PROJECT_NAME}-$1.xcarchive

# clean
rm -dfr ${DIST_DIR}

if [ ! -d "${DIST_DIR}" ]
then
mkdir ${DIST_DIR}
fi

echo Exporting archive

xcodebuild archive -scheme SDKDemo -archivePath "${ARCHIVE}" -allowProvisioningUpdates

#Check if build succeeded
if [ $? != 0 ]
then
exit 1
fi

xcodebuild -exportArchive -exportOptionsPlist exportoptions.plist -archivePath "${ARCHIVE}" -exportPath "${DIST_DIR}" -allowProvisioningUpdates

mv "${DIST_DIR}/${PROJECT_NAME}.ipa" "../.."

# Cleanup
rm -rf "${BUILD_DIR}"
rm -rf "${DIST_DIR}"
