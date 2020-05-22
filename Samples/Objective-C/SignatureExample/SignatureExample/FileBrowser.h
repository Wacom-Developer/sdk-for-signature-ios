//
//  FileBrowser.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 06/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileBrowser : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSString *selectedFilename;
@property (nonatomic, strong) NSString *baseDirectory;
@property (nonatomic, strong) NSString *inputfieldText;
@property (nonatomic, strong) NSString *titleText;
@property (nonatomic, strong) NSURL    *sourceFile;        //Used to store the file input location for Open In.. requests
@property (nonatomic, assign) BOOL     isOpenDialog;
@property (nonatomic, assign) BOOL     signatureTypesOnly; //Only display .txt, .fss and .png

@end
