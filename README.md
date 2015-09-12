# Cordova Gimbal v2 Plugin

_This plugin is the successor of cordova-plugin-gimbal which used Gimbal v1 SDK._

A Cordova plugin for scanning and interacting with [Qualcomm Gimbal](http://gimbal.com) beacons.
Updated for Gimbal SDK v2.


## Supported Platforms

- iOS 7.1+
- Android 4.4.3, 4.4.4, 5.0+ (5.0+ recommended)

_Support for previous versions is not possible because the lack of Bluetooth LE support in earlier versions of the platforms._


## Supported SDK Features

- Beacon Manager: listen for beacon sightings


## Requirements

- Gimbal Manager account
- Gimbal SDK v2 (latest version can be obtained from Gimbal Manager web app)
- Gimbal beacons (can be bought on Gimbal's online store)


## Installation

### Plugin Setup

*NOT ON OFFICIAL REPOSITORY YET*
```text
cordova plugin add io.hpd.cordova.gimbal
```

*NOT ON GITHUB YET*
Or, alternatively you can install the bleeding edge version from Github:

```text
cordova plugin add https://github.com/happydenn/cordova-plugin-gimbal.git
```

### Gimbal SDK Setup

#### iOS

From the downloaded SDK, drag and drop __Gimbal.framework__ from the __Frameworks__ folder to the __Frameworks__ group inside the Xcode project. Be sure to copy the files when asked by Xcode.


Add the following to your project's Info.plist to enable using Bluetooth beacons in background mode.

```xml
<key>UIBackgroundModes</key>
<array>
    <string>bluetooth-central</string>
</array>
```

Finally for iOS 8 and later, you need to add a new entry to your Xcode project's Info.plist to properly request for permission to use the location service which is required by Gimbal SDK.

```xml
<key>NSLocationAlwaysUsageDescription</key>
<string>Specifies the reason for accessing the user's location information.</string>
```

#### Android

From the downloaded SDK, copy all the jars inside the __libs__ folder to the __libs__ folder located in the Android platform folder.

Next inside the __'platforms/android'__ folder of your project, create a new file named __build-extras.gradle__ (open the file if it already exists) and add the following lines:

```
ext.postBuildExtras = {
    android {
        packagingOptions {
            exclude 'META-INF/notice.txt'
            exclude 'META-INF/license.txt'
        }
    }
}
```

This will get rid of the error while building the Android version.


## Plugin API

### Methods

#### Gimbal2.initialize(apiKey)

Initialize the Gimbal SDK with the API key.

- apiKey: API key (generated from Gimbal Manager web backend)

#### Gimbal2.startBeaconManager()

Start the BeaconManager. BeaconManager is responsible for scanning nearby beacons.

#### Gimbal2.stopBeaconManager()

Stop the BeaconManager.

### Events

Events are fired on the window object. Attach event listeners to handle the events.

#### beaconsighting

Fires when a beacon is scanned by the BeaconManager.

- __RSSI__: Signal strength of the sighting
- __datetime__: Time when the sighting occured
- __beaconName__
- __beaconIdentifier__
- __beaconBatteryLevel__
- __beaconIconUrl__
- __beaconTemperature__
