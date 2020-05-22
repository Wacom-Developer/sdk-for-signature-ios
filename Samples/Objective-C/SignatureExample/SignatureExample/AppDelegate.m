//
//  AppDelegate.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 05/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate

#pragma mark - Support Copying PDF, PNG, TXT and FFS files into the documents area of our test application

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    ViewController *vc = (ViewController *)[[[[[UIApplication sharedApplication] keyWindow] subviews] objectAtIndex:0] nextResponder];
    [vc performSegueWithIdentifier:@"OpenIn" sender:url];
    return(YES);
}


@end
