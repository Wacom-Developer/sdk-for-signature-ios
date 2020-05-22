//
//  AppDelegate.m
//  InPlaceSigning
//
//  Created by joss on 07/09/2015.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

#import "AppDelegate.h"
#import <WacomSignatureSDK/WacomSignatureSDK.h>
#import <WacomLicensing/WacomLicensing-Swift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Load a license into the validator. This will need to be replaced with a license from http://developer.wacom.com/
    
    NSString *license = @"*** YOU WILL NEED A LICENSE FROM DEVELOPER.WACOM.COM ***";
    @try {
        NSError *err;
        [[LicenseValidator sharedInstance] initLicense:license error:&err];
        
        if(err != NULL) {
            UIAlertController *qv = [UIAlertController alertControllerWithTitle:@"License error" message:err.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
            [qv addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [qv dismissViewControllerAnimated:YES completion:NULL];
            }]];
            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:qv animated:YES completion:NULL];
        }
    } @catch (NSException *e) {
        UIAlertController *qv = [UIAlertController alertControllerWithTitle:@"License error" message:e.description preferredStyle:UIAlertControllerStyleAlert];
        [qv addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [qv dismissViewControllerAnimated:YES completion:NULL];
        }]];
    
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:qv animated:YES completion:NULL];
    }
    
    [SigningView class];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
