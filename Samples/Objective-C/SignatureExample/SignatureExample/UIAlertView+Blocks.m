//
//  UIAlertView+Blocks.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 08/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "UIAlertView+Blocks.h"
#import <objc/runtime.h>

static char DISMISS_IDENTIFER;
static char CANCEL_IDENTIFER;

@implementation UIAlertView(Blocks)

@dynamic alertCancelBlock;
@dynamic alertDismissBlock;


- (void)setAlertDismissBlock:(AlertDismissBlock)dismissBlock {
    objc_setAssociatedObject(self, &DISMISS_IDENTIFER, dismissBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (AlertDismissBlock)alertDismissBlock {
    return objc_getAssociatedObject(self, &DISMISS_IDENTIFER);
}

- (void)setAlertCancelBlock:(AlertCancelBlock)cancelBlock {
    objc_setAssociatedObject(self, &CANCEL_IDENTIFER, cancelBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (AlertCancelBlock)alertCancelBlock {
    return objc_getAssociatedObject(self, &CANCEL_IDENTIFER);
}

+ (UIAlertView*)alertViewWithTitle:(NSString*)title
                           message:(NSString*)message
                 cancelButtonTitle:(NSString*)cancelButtonTitle
                 otherButtonTitles:(NSArray*) otherButtons
                         onDismiss:(AlertDismissBlock) dismissed
                          onCancel:(AlertCancelBlock) cancelled {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:[self class]
                                          cancelButtonTitle:cancelButtonTitle
                                          otherButtonTitles:nil];
    
    [alert setAlertDismissBlock:dismissed];
    [alert setAlertCancelBlock:cancelled];
    
    for(NSString *buttonTitle in otherButtons) {
        [alert addButtonWithTitle:buttonTitle];
    }
    [alert show];
    return(alert);
}

+ (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == [alertView cancelButtonIndex]) {
        if (alertView.alertCancelBlock) {
            alertView.alertCancelBlock();
        }
    } else {
        if (alertView.alertDismissBlock) {
            alertView.alertDismissBlock(buttonIndex - 1); // cancel button is button 0
        }
    }
}
@end
