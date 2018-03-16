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
    
    self.placeManager = [[GMBLPlaceManager alloc] init];
    self.placeManager.delegate = self;
}

- (void)initialize:(CDVInvokedUrlCommand *)command {
    NSString *apiKey = command.arguments[0];
    statusCallbackId = command.callbackId;
    
    [Gimbal setAPIKey:apiKey options:nil];
    
    [Gimbal start];
    
    NSArray * current = [self.placeManager currentVisits];
    for(GMBLVisit *visit in current) {
        [self placeManager:self.placeManager didBeginVisit:visit];
    }
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
        @"beaconUniqueIdentifier": (beacon.uuid != nil) ? beacon.uuid : [NSNull null],
        @"beaconBatteryLevel": [NSNumber numberWithFloat:beacon.batteryLevel],
        @"beaconIconUrl": (beacon.iconURL != nil) ? beacon.iconURL : [NSNull null],
        @"beaconTemperature": [NSNumber numberWithInteger:beacon.temperature],
    };
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnData];
    pluginResult.keepCallback = [NSNumber numberWithBool:YES];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:statusCallbackId];
}

- (void) placeManager:(GMBLPlaceManager *)manager didBeginVisit:(GMBLVisit *)visit {
    GMBLPlace *place = visit.place;
    [self sendPlaceEvent:@"onBeginVisit" withVisitId:visit.visitID withPlace:place];
}

- (void)placeManager:(GMBLPlaceManager *)manager didEndVisit:(GMBLVisit *)visit {
    GMBLPlace *place = visit.place;
    [self sendPlaceEvent:@"onEndVisit" withVisitId:visit.visitID withPlace:place];
}

- (void) placeManager:(GMBLPlaceManager *)manager didReceiveBeaconSighting:(GMBLBeaconSighting *)sighting forVisits:(NSArray *)visits {
    for(GMBLVisit *visit in visits) {
        GMBLBeacon *beacon = sighting.beacon;
        NSDictionary *returnData = @{
                                     @"event": @"onBeaconSightingForVisit",
                                     @"visitId":visit.visitID,
                                     @"placeId":visit.place.identifier,
                                     @"RSSI": [NSNumber numberWithInteger:sighting.RSSI],
                                     @"datetime": [dateFormatter stringFromDate:sighting.date],
                                     @"beaconName": (beacon.name != nil) ? beacon.name : [NSNull null],
                                     @"beaconIdentifier": (beacon.identifier != nil) ? beacon.identifier : [NSNull null],
                                     @"beaconUniqueIdentifier": (beacon.uuid != nil) ? beacon.uuid : [NSNull null],
                                     @"beaconBatteryLevel": [NSNumber numberWithFloat:beacon.batteryLevel],
                                     @"beaconIconUrl": (beacon.iconURL != nil) ? beacon.iconURL : [NSNull null],
                                     @"beaconTemperature": [NSNumber numberWithInteger:beacon.temperature],
                                     };
        
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnData];
        pluginResult.keepCallback = [NSNumber numberWithBool:YES];
        
        [self.commandDelegate sendPluginResult:pluginResult callbackId:statusCallbackId];
    }
}

- (void) sendPlaceEvent:(NSString*) eventName withVisitId: (NSString*) visitId withPlace: (GMBLPlace *) place {
    NSMutableDictionary *theseAttributes = [[NSMutableDictionary alloc] init];
    NSDictionary *returnData = @{
                                 @"event":eventName,
                                 @"visitId": visitId,
                                 @"placeId":place.identifier,
                                 @"placeName":place.name,
                                 @"placeAttributes":theseAttributes
                                 };
    
    for (NSString *key in [place.attributes allKeys]) {
        NSString* value = [place.attributes stringForKey:key];
        [theseAttributes setObject:value forKey:key];
    }
    
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnData];
    pluginResult.keepCallback = [NSNumber numberWithBool:YES];
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:statusCallbackId];
}

@end
