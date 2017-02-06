fastlane documentation
================
# Installation
```
sudo gem install fastlane
```
# Available Actions
## iOS
### ios pull_frameworks
```
fastlane ios pull_frameworks
```
build frameworks for pull request
### ios pull_canvas
```
fastlane ios pull_canvas
```
build canvas for pull request
### ios beta_canvas
```
fastlane ios beta_canvas
```
build Canvas.app and submit to iTunes Connect
### ios pull_teacher
```
fastlane ios pull_teacher
```

### ios beta_teacher
```
fastlane ios beta_teacher
```
build Teacher.app and submit to iTunes Connect
### ios pull_parent
```
fastlane ios pull_parent
```
build parent for pull request
### ios beta_parent
```
fastlane ios beta_parent
```
build Parent.app and submit to iTunes Connect
### ios test_parent
```
fastlane ios test_parent
```
Test Parent.app
### ios deps
```
fastlane ios deps
```
Update carthage and cocoapods dependencies
### ios build_earlgrey_parent
```
fastlane ios build_earlgrey_parent
```
Parent.app EarlGrey build-for-testing
### ios test_earlgrey_parent
```
fastlane ios test_earlgrey_parent
```
Parent.app EarlGrey test-without-building.
Requires fbsimctl

brew tap facebook/fb
brew install fbsimctl --HEAD

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
