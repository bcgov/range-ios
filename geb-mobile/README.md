
# Geb Mobile Extension
---

## Under Development
+ WIP
---

## Docker usage:
+ Build the image and start a container
+ Go to `cd /bin/bash/geb-mobile`
+ Run `./gradlew -i clean androidOnBrowserStack`


## Running Sample Test Cases with Cloud-based devices
+ To run the Android test case: `./gradlew -i clean androidOnBrowserStack`
+ To run iOS test case: `./gradlew -i clean iOSOnBrowserStack`
+ To upload apps: replace app path in geb-mobile-test-spock/build.gradle, then run `./gradlew -i clean uploadAppToDeviceFarm`


## Running Sample Test Cases with local devices

To run Android local device, please install adb:
+ install SDK `brew install android-platform-tools`
+ setup android SDK home path
+ connect device with USB, check if device is recognized by android device bridge `adb devices`
+ To run the test case: replace device info in geb-mobile-test-spock/build.gradle, then run `./gradlew -i clean androidOnLocalDevice`

To run iOS local device:
+ install Xcode
+ install npm at https://www.npmjs.com/get-npm
+ init npm for the package.json `npm init`
+ install XCUITest Driver: `npm install appium-xcuitest-driver`
+ connect device with USB, check if device is recognized by xcode `xcrun instruments -s devices`
+ follow instructions from appium repo: https://github.com/appium/appium-xcuitest-driver/blob/master/docs/real-device-config.md to install WebDriverAgent on iPhone (this will be an app that helps to install and run testing apps on the device)
+ make sure it works as mentioned from above config
+ To run the test case: replace device info in geb-mobile-test-spock/build.gradle, then run `./gradlew -i clean iOSOnLocalDevice`

## TODO
+ Add mobile touch screen specific methods (scroll + direction +distance/target, swipe, long press, )
+ Add mobile KeyCode
+ Local simulator/emulator (Xcode and ADB)
+ Find element for children
+ Chrome/Chromeium Driver
+ Auto import app bs from cloud device farm
+ Locate elements from layout xml using Appium Desktop
+ data table in test case
+ Add old drivers: selendroid, UIautomation 1
+ docker image


## Dependency versions:
+ Geb v2.0
+ Spock v1.0-groovy-2.3
+ Groovy v2.3.11
+ Gradle v4.3.1
+ Appium Java Client v5.0.4 (stable version)
+ Selenium v3.8.1
+ jUnit v4.11
