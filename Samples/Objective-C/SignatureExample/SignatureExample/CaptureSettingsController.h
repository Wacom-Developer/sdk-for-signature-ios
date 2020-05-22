//
//  CaptureSettingsController.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 11/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomSignatureSDK/WacomSignatureSDK.h>

@interface CaptureSettingsController : UIViewController <UITextFieldDelegate, UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) CGFloat xPadding;
@property (nonatomic, assign) CGFloat yPadding;
@property (nonatomic, strong) NSString *macKey;
@property (nonatomic, assign) SIGNATURE_IMAGE_FLAGS imageFlags;
@property (nonatomic, assign) SIGNATURE_HASH_TYPE signatureHashType;
@property (nonatomic, assign) SIGNATURE_HASH_TYPE extraDataHashType;

@end
