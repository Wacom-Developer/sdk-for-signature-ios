//
//  ViewController.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 05/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomSignatureSDK/WacomSignatureSDK.h>

@interface ViewController : UIViewController <SignatureCaptureDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate>

@property (strong, nonatomic) NSData *hashData;                        //This is used as the basis of the hash to bind a particiular signature to
@property (strong, nonatomic) SignatureObject *currentSignatureObject; //Used to hold the current signature data

@end
