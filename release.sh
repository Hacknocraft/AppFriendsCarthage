#!/bin/sh

# by default, just increase the version number by 1
PROJECT_DIR="./"
INFOPLIST_FILE="AppFriendsCarthage/Info.plist"
VERSIONNUM=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "${PROJECT_DIR}/${INFOPLIST_FILE}")
NEWSUBVERSION=`echo $VERSIONNUM | awk -F "." '{print $3}'`
NEWSUBVERSION=$(($NEWSUBVERSION + 1))
NEWVERSIONSTRING=`echo $VERSIONNUM | awk -F "." '{print $1 "." $2 ".'$NEWSUBVERSION'" }'`

# see if the we want to customize the release version
inputVersionString=""
echo -n "Enter the release version (skip to auto-version) > "
read inputVersionString
size=${#inputVersionString}
if test $size -gt 0;
then
  NEWVERSIONSTRING=${inputVersionString}
fi
# ask for release notes
releaseNotes=""
echo -n "Enter the release notes > "
read releaseNotes
size=${#releaseNotes}
if test $size -eq 0;
then
  releaseNotes="release ${NEWVERSIONSTRING}"
fi
# start release
echo "releasing version: ${NEWVERSIONSTRING}"
echo "Notes: ${releaseNotes}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $NEWVERSIONSTRING" "${PROJECT_DIR}/${INFOPLIST_FILE}"

PRODUCTNAME="AppFriendsCarthage"
PROJECT="AppFriendsCarthage.xcodeproj"
SCHEME="AppFriendsCarthage"

echo "Build SDK for Carthage ..."
carthage build --no-skip-current

# commit to github release
git commit -a -m "commit release ${NEWVERSIONSTRING}"
git push
git tag -a ${NEWVERSIONSTRING} -m "release ${NEWVERSIONSTRING}"
git push --tag

echo "Github release ..."
export GITHUB_TOKEN=9f25b727bc5c7a97dace8a0e4aaca6aecd0d6f04
github-release release \
    --user hacknocraft \
    --repo ${PRODUCTNAME} \
    --tag ${NEWVERSIONSTRING} \
    --name "${PRODUCTNAME} release"\
    --description "${releaseNotes}"
    # --pre-release

echo "released version: ${NEWVERSIONSTRING}"
