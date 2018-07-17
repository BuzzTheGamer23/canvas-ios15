#!/bin/bash

set -euxo pipefail

DD="dd_ios_teacher_ftl"
SCHEME="TeacherUITests"
ZIP="ios_teacher_earlgrey.zip"

xcodebuild test-without-building \
  -workspace ../../AllTheThings.xcworkspace \
  -scheme "$SCHEME" \
  -derivedDataPath "$DD" \
  -destination 'id=ADD_YOUR_ID_HERE' \
  -sdk iphoneos

# get device identifier in Xcode -> Window -> Devices and Simulators
