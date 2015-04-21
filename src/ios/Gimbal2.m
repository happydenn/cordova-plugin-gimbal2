//
//  Gimbal2.m
//  cordova-plugin-gimbal2
//
//  Created by Denny Tsai on 4/21/15.
//
//

#import "Gimbal2.h"

@implementation Gimbal2 {
    NSString *statusCallbackId;
    NSDateFormatter *dateFormatter;
}

- (void)pluginInitialize {
    [super pluginInitialize];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    
    self.beaconManager = [[GMBLBeaconManager alloc] init];
    self.beaconManager.delegate = self;
}

- (void)initialize:(CDVInvokedUrlCommand *)command {
    NSString *apiKey = command.arguments[0];
    statusCallbackId = command.callbackId;
    
    [Gimbal setAPIKey:apiKey options:nil];
}

- (void)startBeaconManager:(CDVInvokedUrlCommand *)command {
    [self.beaconManager startListening];
}

- (void)stopBeaconManager:(CDVInvokedUrlCommand *)command {
    [self.beaconManager stopListening];
}

- (void)beaconManager:(GMBLBeaconManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting {
    GMBLBeacon *beacon = sighting.beacon;
    NSDictionary *returnData = @{
        @"event": @"onBeaconSighting",
        @"RSSI": [NSNumber numberWithInteger:sighting.RSSI],
        @"datetime": [dateFormatter stringFromDate:sighting.date],
        @"beaconName": (beacon.name != nil) ? beacon.name : [NSNull null],
        @"beaconIdentifier": (beacon.identifier != nil) ? beacon.identifier : [NSNull null],
        @"beaconBatteryLevel": [NSNumber numberWithFloat:beacon.batteryLevel],
        @"beaconIconUrl": (beacon.iconURL != nil) ? beacon.iconURL : [NSNull null],
        @"beaconTemperature": [NSNumber numberWithInteger:beacon.temperature],
    };
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnData];
    pluginResult.keepCallback = [NSNumber numberWithBool:YES];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:statusCallbackId];
}

@end
