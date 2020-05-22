//
//  UIAlertView+Blocks.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 08/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AlertDismissBlock)(NSInteger buttonIndex);
typedef void (^AlertCancelBlock)(void);

@interface UIAlertView(Blocks)

@property (nonatomic, copy) AlertDismissBlock alertDismissBlock;
@property (nonatomic, copy) AlertCancelBlock alertCancelBlock;

+ (UIAlertView*) alertViewWithTitle:(NSString*)title
                            message:(NSString*)message
                  cancelButtonTitle:(NSString*)cancelButtonTitle
                  otherButtonTitles:(NSArray*)otherButtons
                          onDismiss:(AlertDismissBlock) dismissed
                           onCancel:(AlertCancelBlock) cancelled;

@end
