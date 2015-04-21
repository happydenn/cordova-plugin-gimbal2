//
//  Gimbal2.h
//  cordova-plugin-gimbal2
//
//  Created by Denny Tsai on 4/21/15.
//
//

#import <Foundation/Foundation.h>
#import <Cordova/CDV.h>
#import <Gimbal/Gimbal.h>

@interface Gimbal2 : CDVPlugin <GMBLBeaconManagerDelegate>

@property (nonatomic, strong) GMBLBeaconManager *beaconManager;

- (void)initialize:(CDVInvokedUrlCommand *)command;

- (void)startBeaconManager:(CDVInvokedUrlCommand *)command;
- (void)stopBeaconManager:(CDVInvokedUrlCommand *)command;

@end
