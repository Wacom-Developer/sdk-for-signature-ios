//
//  SignatureIntegrityController.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 08/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomSignatureSDK/WacomSignatureSDK.h>

@interface SignatureIntegrityController : UIViewController <UIPopoverControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SignatureObject *sigObj;
@property (nonatomic, strong) NSData *hashData;
@end
