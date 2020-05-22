//
//  ViewController.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 05/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "ViewController.h"
#import "WacomDefines.h"
#import "ToolbarButton.h"
#import "AboutScreen.h"
#import "SingatureImageController.h"
#import "UIImage+TintImage.h"
#import "UIAlertView+Blocks.h"
#import "FileBrowser.h"
#import "SignatureIntegrityController.h"
#import "CaptureSettingsController.h"
#import <WacomLicensing/WacomLicensing-Swift.h>

//======================================================================================================================

/**
 *  @brief This enum is used to allow us to share the same file open dialog for open, save and hash file
 */
typedef enum : NSUInteger {
    OPEN_SIGNATURE_FILE,
    SAVE_SIGNATURE_FILE,
    OPEN_BINARY_HASH_FILE,
    OPEN_IN_FILE
} FILE_DIALOG_MODE;

typedef enum : NSUInteger {
    IMAGE,
    BINARY,
    TEXT
} EXPORT_FILE_TYPE;

//======================================================================================================================

@interface ViewController ()

//======================================================================================================================
@property (strong, nonatomic) IBOutlet UITextField *widthField;
@property (strong, nonatomic) IBOutlet UITextField *whoField;
@property (strong, nonatomic) IBOutlet UITextField *whyField;
@property (strong, nonatomic) IBOutlet UITextField *heightField;
@property (strong, nonatomic) IBOutlet UICollectionView *toolbarCollectionView;

@property (strong, nonatomic) IBOutlet UIButton *blackButton;
@property (strong, nonatomic) IBOutlet UIButton *darkGreyButton;
@property (strong, nonatomic) IBOutlet UIButton *lightGreyButton;
@property (strong, nonatomic) IBOutlet UIButton *blueButton;
@property (strong, nonatomic) IBOutlet UIButton *redButton;
@property (strong, nonatomic) IBOutlet UIButton *greenButton;
@property (strong, nonatomic) IBOutlet UIButton *purpleButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
//======================================================================================================================
@property (strong, nonatomic) NSArray *inputFields;
@property (strong, nonatomic) NSArray *colourButtons;
@property (strong, nonatomic) NSArray *buttonImages; //Used for the toolbar images. Array is same order as enum
@property (strong, nonatomic) SignatureCapture *signatureCapture; //This is signature capture controller
//======================================================================================================================
//These are used to hold the 'export as image' options as selected in the settings screen. The width / height are taken
//From the input fields.
@property (assign, nonatomic) SIGNATURE_IMAGE_FLAGS exportAsImageFlags;
@property (assign, nonatomic) EXPORT_FILE_TYPE exportFileType; //This is used to save which type of signature to output
@property (assign, nonatomic) CGFloat xPaddingForImageExport;
@property (assign, nonatomic) CGFloat yPaddingForImageExport;
@property (assign, nonatomic) BOOL confirmForFileOverwrite;    //If this is YES then warn the user before overwrite
//======================================================================================================================


/**
 *  @brief This is called when a user taps to select a new ink colour
 *
 *  @param sender The selected button. The control's TAG field is set to the colour enum at the top of this file.
 */
- (IBAction)colourButtonSelected:(id)sender;

/**
 *  @brief This is called when the user taps on the backround of the view. This causes the on-screen keyboard to be
 *  dismissed if it is currently being displayed.
 */
- (IBAction)dismissKeyboard;

/**
 *  @brief This action opens the signature capture window to begin a capture session.
 */
- (void)openCaptureWindow;

/**
 *  @brief This action validates the current captured signature data
 */
- (void)validateSignature;

/**
 *  @brief Simple utility method that converts between the button enum and the underlying UIColor
 *
 *  @param buttonColour The enum value for the button colour
 *
 *  @return The UIColor for the colour
 */
- (UIColor *)colourForButton:(BUTTON_COLOUR)buttonColour;

/**
 *  @brief Utility method that attemps to load encoded signature data from the PNG at the supplied path
 *
 *  @param filepath The path to the source file
 */
- (void)loadEncodedPNGAtPath:(NSString *)filepath;

/**
 *  @brief Utility method that attemps to load encoded signature data from the TXT at the supplied path
 *
 *  @param filepath The path to the source file
 */
- (void)loadEncodedTXTAtPath:(NSString *)filepath;

/**
 *  @brief Utility method that attemps to load encoded signature data from the FSS at the supplied path
 *
 *  @param filepath The path to the source file
 */
- (void)loadEncodedBINAtPath:(NSString *)filepath;

/**
 *  @brief Utility method that saves an encoded signature to the supplied path
 *
 *  @param filepath The output path
 */
- (void)exportSignatureWithCurrentFlagsToPath:(NSString *)filepath;

/**
 *  @brief Utility method that confirms if a file exists at a path before prompting a user to confirm overwrite
 *
 *  @param filepath The output path
 */
- (void)checkForOverwriteAtPath:(NSString *)filepath;

/**
 *  @brief Utility method that confirms if a file exists at a particular  path before prompting the user to confirm
 *  overwrite. This method is used by the 'Open In...' routines
 *
 *  @param filepath   The target file destiniation
 *  @param sourceFile The URL of the source file to copy
 */
- (void)checkForOverwriteAtPath:(NSString *)filepath withSourceFile:(NSURL *)sourceFile;

/**
 *  @brief Simply wrapper to a `UIAlertView` with an OK button
 *
 *  @param title   The title of the dialog
 *  @param message The message to display
 */
- (void)showMessageBoxWithTitle:(NSString *)title andMessage:(NSString *)message;

/**
 *  @brief Copies the demo data into the documents directory of the demo application. 
 *
 *  @discussion The sample data contains 3 PNG encoded signatures (named.sigimg to prevent XCode re-encoding and destroying
 *  the encoded data), one binary .fss signature and one base 64 encoded txt signature. There are also two PDF files under
 *  the 'Documents' folder for use with the hashing systems. 
 *
 */
- (void)seedDocumentsDir;

@end

@implementation ViewController
//======================================================================================================================
#pragma mark - Signature Capture Delegate Methods

///----------
/// @name Signature Capture Delegate Methods
///----------

/**
 *  @brief This delegate method is called when the user sucessfully completes a sigautre input.
 *
 *  @param captureView The signature view that was used during signature capture
 *  @param signature   The SignatureObject representing the captured data
 */
- (void)signatureCapture:(SignatureCapture *)captureView completedWithSignature:(SignatureObject *)signature {
    self.currentSignatureObject = signature;
    [self.currentSignatureObject addExtraDataItemWithKey:@"myData" andValue:@"Some extra data from iOS SDK"];
    [self.toolbarCollectionView reloadData];
    
    //SigObj is a completed SignatureObjet
    
    
}

/**
 *  @brief This delegate method is called when the user dismisses the signature capture window without sucessfuly
 *  completing a signature capture.
 *
 *  @param captureView The view that was used during signature capture
 *  @param reason      An error code defining the reason for the cancelled capture session.
 */
- (void)signatureCapture:(SignatureCapture *)captureView cancelledWithReason:(SIGNATURE_CANCEL_REASON)reason {
    NSString *reasonText;
    
    switch (reason) {
        case USER_CANCELLED:
            reasonText = @"The user cancelled the capture session";
            break;
        case NO_SIGNATURE_DATA_CAPTURED:
            reasonText = @"No signature data was captured during the session";
            break;
        case CAPTURE_ABORTED:
            reasonText = @"The signature capture was aborted, check console for error logs";
            break;
    }
    
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Capture Cancelled"
                                                 message:reasonText
                                                delegate:nil
                                       cancelButtonTitle:@"OK"
                                       otherButtonTitles:nil];
    [av show];
    
    self.currentSignatureObject = nil;
    [self.toolbarCollectionView reloadData];
}
//======================================================================================================================
#pragma mark - UIView methods

///----------
/// @name UIView Methods
///----------

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImage *colourButtonImage = [UIImage imageNamed:@"colour_button"];
    UIImage *colourSelectedImage = [UIImage imageNamed:@"colour_button_selected"];
    
    //Tint our ink selection colours
    [self.blackButton setImage:[colourButtonImage tintedImageWithColour:WACOM_BLACK] forState:UIControlStateNormal];
    [self.blackButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_BLACK] forState:UIControlStateSelected];
    [self.blackButton setTag:BLACK];
    
    [self.darkGreyButton setImage:[colourButtonImage tintedImageWithColour:WACOM_DARK_GREY] forState:UIControlStateNormal];
    [self.darkGreyButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_DARK_GREY] forState:UIControlStateSelected];
    [self.darkGreyButton setTag:DARK_GREY];
    
    [self.lightGreyButton setImage:[colourButtonImage tintedImageWithColour:WACOM_LIGHT_GREY] forState:UIControlStateNormal];
    [self.lightGreyButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_LIGHT_GREY] forState:UIControlStateSelected];
    [self.lightGreyButton setTag:LIGHT_GREY];
    
    [self.blueButton setImage:[colourButtonImage tintedImageWithColour:WACOM_BLUE] forState:UIControlStateNormal];
    [self.blueButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_BLUE] forState:UIControlStateSelected];
    [self.blueButton setTag:BLUE];
    
    [self.redButton setImage:[colourButtonImage tintedImageWithColour:WACOM_RED] forState:UIControlStateNormal];
    [self.redButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_RED] forState:UIControlStateSelected];
    [self.redButton setTag:RED];
    
    [self.greenButton setImage:[colourButtonImage tintedImageWithColour:WACOM_GREEN] forState:UIControlStateNormal];
    [self.greenButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_GREEN] forState:UIControlStateSelected];
    [self.greenButton setTag:GREEN];
    
    [self.purpleButton setImage:[colourButtonImage tintedImageWithColour:WACOM_PURPLE] forState:UIControlStateNormal];
    [self.purpleButton setImage:[colourSelectedImage tintedImageWithColour:WACOM_PURPLE] forState:UIControlStateSelected];
    [self.purpleButton setTag:PURPLE];
    
    
    //Create the capture window and set ourselves at delegate, catching any license errors
    @try {
        _signatureCapture = [[SignatureCapture alloc] initWithDelelgate:self];
    }
    @catch (NSException *exception) {
        [self showMessageBoxWithTitle:@"License Error" andMessage:[exception reason]];
    }
    
    /*
     For this example application we will use an SHA-512 hash for the signature key and SHA-1 for any data bound against
     the signature as defaults. This can be changed in the settings screen.
     */
    
    self.signatureCapture.keyType  = SHA_512_HASH; //Used to detect malicious or accidental tampering with the signature object or the data it contains
    self.signatureCapture.hashType = SHA_1_HASH;   //Type of hash to use against supplied hash data
    
    //Set our default ink colour to BLUE
    self.signatureCapture.inkColor = WACOM_BLUE;
    self.blueButton.selected = YES;
    
    //Add our input fields to the input fields array
    self.inputFields = @[self.whyField,
                         self.whoField,
                         self.widthField,
                         self.heightField];
    
    self.colourButtons = @[self.blackButton,
                           self.blueButton,
                           self.darkGreyButton,
                           self.lightGreyButton,
                           self.blueButton,
                           self.redButton,
                           self.greenButton,
                           self.purpleButton];
    
    //Setup toolbar images
    self.toolbarItems = @[[UIImage imageNamed:@"action_collection"],
                          [UIImage imageNamed:@"action_edit"],
                          [UIImage imageNamed:@"action_picture"],
                          [UIImage imageNamed:@"action_save"],
                          [UIImage imageNamed:@"action_discard"],
                          [UIImage imageNamed:@"action_settings"],
                          [UIImage imageNamed:@"action_accept"],
                          [UIImage imageNamed:@"action_new_attachment"],
                          [UIImage imageNamed:@"action_about"]
                          ];
    //Register class for toolbar items
    [self.toolbarCollectionView registerClass:[ToolbarButton class] forCellWithReuseIdentifier:TOOLBAR_REUSE_ID];
    
    //Set some defaults for the image export settings. We also set the default export type to PNG
    self.xPaddingForImageExport = 0.0f;
    self.yPaddingForImageExport = 0.0f;
    self.exportAsImageFlags = ENCODE_SIGNATURE_DATA | TRANSPARENT_BACKGROUND | DO_NOT_SCALE;
    self.exportFileType = IMAGE;
    self.confirmForFileOverwrite = YES; //By default we want to warn for file overwrites
    
    //Copy the sample data
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self seedDocumentsDir];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.toolbarCollectionView reloadData];
}

- (void)seedDocumentsDir {
    //Seed the document directory with the sample data
    NSString *sourceDir = [[NSBundle mainBundle] resourcePath];
    NSString *targetDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *err;
    BOOL isDir;
    
    NSArray *sampleSignatureImages = @[ @"Mondi.sigimg", @"Sample.sigimg", @"Vincent.sigimg" ];
    NSArray *sampleSignatureData = @[ @"Sample-text.txt", @"sample-binary.fss" ];
    NSArray *sampleDocuments = @[ @"IntuosProSE_en_Manual.pdf", @"IntuosSmall_en_Manual.pdf" ];
    
    //Create documents folder if required
    if(![fm fileExistsAtPath:[targetDir stringByAppendingPathComponent:@"Documents"] isDirectory:&isDir]) {
        [fm createDirectoryAtPath:[targetDir stringByAppendingPathComponent:@"Documents"] withIntermediateDirectories:YES attributes:nil error:&err];
        if(err) NSLog(@"ERROR: %@", err);
    }
    
    //Copy sample images
    for(NSString *image in sampleSignatureImages) {
        NSString *targetFile = [[[targetDir stringByAppendingPathComponent:image] stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
        
        if(![fm fileExistsAtPath:targetFile isDirectory:&isDir]) {
            [fm copyItemAtPath:[sourceDir stringByAppendingPathComponent:image] toPath:targetFile error:&err];
            if(err) NSLog(@"ERROR: %@", err);
        }
    }
    
    //Copy sample txt and fss files
    for(NSString *file in sampleSignatureData) {
        NSString *targetFile = [targetDir stringByAppendingPathComponent:file];
        NSString *sourceFile = [sourceDir stringByAppendingPathComponent:file];
        
        if(![fm fileExistsAtPath:targetFile isDirectory:&isDir]) {
            [fm copyItemAtPath:sourceFile toPath:targetFile error:&err];
            if(err) NSLog(@"ERROR: %@", err);
        }
    }
    
    //Copy sample documents
    for(NSString *document in sampleDocuments) {
        NSString *targetFile = [[targetDir stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:document];
        NSString *sourceFile = [sourceDir stringByAppendingPathComponent:document];
        
        if(![fm fileExistsAtPath:targetFile isDirectory:&isDir]) {
            [fm copyItemAtPath:sourceFile toPath:targetFile error:&err];
            if(err) NSLog(@"ERROR: %@", err);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
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
            [self presentViewController:qv animated:YES completion:NULL];
        }
    } @catch (NSException *e) {
        UIAlertController *qv = [UIAlertController alertControllerWithTitle:@"License error" message:e.description preferredStyle:UIAlertControllerStyleAlert];
        [qv addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [qv dismissViewControllerAnimated:YES completion:NULL];
        }]];
        
       [self presentViewController:qv animated:YES completion:NULL];
    }
}

//======================================================================================================================
#pragma mark - Action Callbacks

///----------
/// @name Action Callback Methods
///----------

/**
 *  @brief This is called when the user taps on the view background. This causes the keyboard to be dismissed.
 */
- (IBAction)dismissKeyboard {
    for(UIControl *field in self.inputFields) {
        if([field isFirstResponder]) {
            [field resignFirstResponder];
            break;
        }
    }
}

- (IBAction)colourButtonSelected:(id)sender {
    BUTTON_COLOUR col = [sender tag];
    
    //Deselect currently selected button
    for(UIButton *button in self.colourButtons) {
        button.selected = NO;
    }
    
    //Change ink colour and select new button
    self.signatureCapture.inkColor = [self colourForButton:col];
    [sender setSelected:YES];
}

- (void)openCaptureWindow {
#ifdef CHECK_FOR_WHO_AND_WHY_FIELDS
    if([self.whyField.text length] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"You must enter a reason for signature capture"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.whyField becomeFirstResponder];
        });
        return;
    }
    
    if([self.whoField.text length] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:nil
                                                     message:@"You must enter a signatory name"
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil];
        [av show];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.whoField becomeFirstResponder];
        });
        return;
    }
#endif
    
    [self dismissKeyboard];
    @try {
        [self.signatureCapture openCaptureWindowWithSignatory:self.whoField.text
                                                    andReason:self.whyField.text
                                                  boundToData:self.hashData];
    }
    @catch (NSException *exception) { //License Exception
        [self showMessageBoxWithTitle:@"License Error" andMessage:[exception reason]];
    }
    
}

- (void)validateSignature {
    SIGNATURE_INTEGRITY_STATUS status = [self.currentSignatureObject checkIntegrity:self.signatureCapture.keyType];
    NSString *message;
    
    switch (status) {
        case INTEGRITY_OK:
            message = @"Integrity OK";
            break;
        case INTEGRITY_FAIL:
            message = @"Integrity failed";
            break;
        case INTEGRITY_MISSING:
            message = @"Integrity data is missing";
            break;
        case INTEGRITY_WRONG_TYPE:
            message = @"Integrity type is incorrect";
            break;
        case INTEGRITY_INVALID_KEY:
            message = @"Integrity key is invalid";
            break;
    }
    
    UIAlertController *av = [UIAlertController alertControllerWithTitle:@"Signature Itegrity" message:message preferredStyle:UIAlertControllerStyleAlert];
    [av addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [av dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:av animated:YES completion:nil];
}

//======================================================================================================================
#pragma mark - Collection view delegate methods

///----------
/// @name Collection view delegate methods
///----------

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ToolbarButton *button = [collectionView dequeueReusableCellWithReuseIdentifier:TOOLBAR_REUSE_ID forIndexPath:indexPath];
    TOOLBAR_BUTTONS buttonType = indexPath.row;
    
    switch (buttonType) {
            //The following are always enabled
        case OPEN_BUTTON:
        case ABOUT_BUTTON:
        case CAPTURE_BUTTON:
        case ATTACHMENT_BUTTON:
            button.imageView.image = (UIImage *)self.toolbarItems[indexPath.row];
            button.userInteractionEnabled = YES;
            break;
            //These are only active if we have a signature object
        case IMAGE_BUTTON:
        case SAVE_BUTTON:
        case DELETE_BUTTON:
        case VALIDATE_BUTTON:
        case SETTINGS_BUTTON:
            if(self.currentSignatureObject != nil) {
                button.imageView.image = (UIImage *)self.toolbarItems[indexPath.row];
                button.userInteractionEnabled = YES;
            } else {
                button.imageView.image = [(UIImage *)self.toolbarItems[indexPath.row] tintedImageWithColour:WACOM_LIGHT_GREY];
                button.userInteractionEnabled = NO;
            }
            break;
    }
    
    return(button);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return(self.toolbarItems.count);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TOOLBAR_BUTTONS buttonID = indexPath.row;
    [self dismissKeyboard];
    
    switch (buttonID) {
        case CAPTURE_BUTTON:
            [self openCaptureWindow];
            break;
        case ABOUT_BUTTON:
            [self performSegueWithIdentifier:@"About" sender:nil];
            break;
        case DELETE_BUTTON:
            //Simply clear out the local signature object & reset input fields
            self.currentSignatureObject = nil;
            self.whoField.text = @"";
            self.whyField.text = @"";
            self.hashData = nil;
            self.widthField.text = @"600";
            self.heightField.text = @"600";
            [self.toolbarCollectionView reloadData];

            break;
        case IMAGE_BUTTON: {
            [self.activityIndicator startAnimating];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"ShowImage" sender:nil];
            });
        } break;
        case OPEN_BUTTON:
            [self performSegueWithIdentifier:@"OpenFile" sender:nil];
            break;
        case SAVE_BUTTON:
            [self performSegueWithIdentifier:@"SaveFile" sender:nil];
            break;
        case ATTACHMENT_BUTTON:
            [self performSegueWithIdentifier:@"HashFile" sender:nil];
            break;
        case VALIDATE_BUTTON:
            [self validateSignature];
            break;
        case SETTINGS_BUTTON:
            [self performSegueWithIdentifier:@"VerifySignature" sender:nil];
            //[self performSegueWithIdentifier:@"CaptureSettings" sender:nil];
            break;
            
    }
}

//======================================================================================================================
#pragma mark - Utililty methods

///----------
/// @name Utililty methods
///----------

- (UIColor *)colourForButton:(BUTTON_COLOUR)buttonColour {
    switch (buttonColour) {
        case BLACK:
            return(WACOM_BLACK);
        case DARK_GREY:
            return(WACOM_DARK_GREY);
        case LIGHT_GREY:
            return(WACOM_LIGHT_GREY);
        case BLUE:
            return(WACOM_BLUE);
        case RED:
            return(WACOM_RED);
        case GREEN:
            return(WACOM_GREEN);
        case PURPLE:
            return(WACOM_PURPLE);
    }
    
    //Return magenta for an unknown colour
    return([UIColor magentaColor]);
}

- (void)showMessageBoxWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}

- (void)checkForOverwriteAtPath:(NSString *)filepath {
    BOOL isDir = NO;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDir]) {
        NSString *alertText = [NSString stringWithFormat:@"Are you sure you want to overwrite %@?", [filepath lastPathComponent]];
        [UIAlertView alertViewWithTitle:@"Overwrite File"
                                message:alertText cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(NSInteger buttonIndex) {
                                    [self exportSignatureWithCurrentFlagsToPath:filepath];
                                } onCancel:nil];
    } else { //File doesn't exist at path
        [self exportSignatureWithCurrentFlagsToPath:filepath];
    }
}

- (void)checkForOverwriteAtPath:(NSString *)filepath withSourceFile:(NSURL *)sourceFile {
    BOOL isDir = NO;
    __block NSError *err = nil;
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filepath isDirectory:&isDir]) {
        NSString *alertText = [NSString stringWithFormat:@"Are you sure you want to overwrite %@?", [filepath lastPathComponent]];
        [UIAlertView alertViewWithTitle:@"Overwrite File"
                                message:alertText cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"] onDismiss:^(NSInteger buttonIndex) {
                                    [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
                                    [[NSFileManager defaultManager] moveItemAtPath:[sourceFile path] toPath:filepath error:&err];
                                    if(err)  {
                                        NSLog(@"%@",err);
                                    } else {
                                        [self showMessageBoxWithTitle:nil andMessage:[NSString stringWithFormat:@"Wrote: %@", [filepath lastPathComponent]]];
                                    }
                                    
                                } onCancel:nil];
    } else { //File doesn't exist at path
        [[NSFileManager defaultManager] moveItemAtPath:[sourceFile path] toPath:filepath error:&err];
        if(err) {
            NSLog(@"%@",err);
        } else {
            [self showMessageBoxWithTitle:nil andMessage:[NSString stringWithFormat:@"Wrote: %@", [filepath lastPathComponent]]];
        }
    }
    [[NSFileManager defaultManager] removeItemAtURL:sourceFile error:nil];
}

- (void)loadEncodedPNGAtPath:(NSString *)filepath {
    @try {
        self.currentSignatureObject = [[SignatureObject alloc] initWithEncodedImageAtPath:filepath];
    }
    @catch (NSException *exception) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"License Error" message:[exception reason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    
    if(self.currentSignatureObject == nil) {
        [self showMessageBoxWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Failed to load encoded signature data from file:%@", filepath.lastPathComponent]];
    }
    
    [self.toolbarCollectionView reloadData];
}

- (void)loadEncodedBINAtPath:(NSString *)filepath {
    @try {
        self.currentSignatureObject = [[SignatureObject alloc] initWithBinarySignatureData:[NSData dataWithContentsOfFile:filepath]];
    }
    @catch (NSException *exception) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"License Error" message:[exception reason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    if(self.currentSignatureObject == nil) {
        [self showMessageBoxWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Failed to load encoded signature data from file:%@", filepath.lastPathComponent]];
    }
    
    [self.toolbarCollectionView reloadData];
}

- (void)loadEncodedTXTAtPath:(NSString *)filepath {
    @try {
        self.currentSignatureObject = [[SignatureObject alloc] initWithBase64EncodedSignatureData:[NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil]];
    }
    @catch (NSException *exception) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"License Error" message:[exception reason] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [av show];
    }
    
    if(self.currentSignatureObject == nil) {
        [self showMessageBoxWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Failed to load encoded signature data from file:%@", filepath.lastPathComponent]];
    }
    
    [self.toolbarCollectionView reloadData];
}

- (void)exportSignatureWithCurrentFlagsToPath:(NSString *)filepath {
    switch (self.exportFileType) {
        case IMAGE: {
            //Fix output ext
            NSString *output = [[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"png"];
            [self.currentSignatureObject writeSignatureToPNG:output
                                                   withFlags:self.exportAsImageFlags
                                                       width:[self.widthField.text integerValue]
                                                      height:[self.heightField.text integerValue]
                                                    paddingX:self.xPaddingForImageExport
                                                    paddingY:self.yPaddingForImageExport
                                                    inkColor:self.signatureCapture.inkColor
                                             backgroundColor:[UIColor whiteColor]];
        } break;
            
        case BINARY: {
            //Fix output ext
            NSString *output = [[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"fss"];
            [[self.currentSignatureObject signatureAsBinaryData] writeToFile:output atomically:YES];
        } break;
            
        case TEXT: {
            NSString *output = [[filepath stringByDeletingPathExtension] stringByAppendingPathExtension:@"txt"];
            [[self.currentSignatureObject signatureAsBase64EncodedString] writeToFile:output atomically:YES encoding:NSUTF8StringEncoding error:nil];
        } break;
    }
    [self showMessageBoxWithTitle:nil andMessage:[NSString stringWithFormat:@"Wrote: %@", [filepath lastPathComponent]]];
}

//======================================================================================================================
#pragma mark - Navigation

///----------
/// @name Storyboard Navigation Methods
///----------

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //About Screen
    if([segue.identifier compare:@"About" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        AboutScreen *aboutScreen = segue.destinationViewController;
        aboutScreen.versionString = self.signatureCapture.versionString;
    }
    
    //Show Signature Image screen
    if([segue.identifier compare:@"ShowImage" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SingatureImageController *imageScreen = segue.destinationViewController;
        imageScreen.signatureImage = [self.currentSignatureObject signatureAsUIImageWithFlags:self.exportAsImageFlags
                                                                                        width:[self.widthField.text floatValue]
                                                                                       height:[self.heightField.text floatValue]
                                                                                     paddingX:self.xPaddingForImageExport
                                                                                     paddingY:self.yPaddingForImageExport
                                                                                     inkColor:self.signatureCapture.inkColor
                                                                              backgroundColor:[UIColor whiteColor]];
        [self.activityIndicator stopAnimating];
    }
    
    //Open file
    if([segue.identifier compare:@"OpenFile" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        FileBrowser *fbrowser = segue.destinationViewController;
        fbrowser.titleText = @"Select a signature file to open:";
        fbrowser.baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        fbrowser.isOpenDialog = YES;
        fbrowser.signatureTypesOnly = YES;
        fbrowser.view.tag = OPEN_SIGNATURE_FILE;
    }
    
    //Save File
    if([segue.identifier compare:@"SaveFile" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        FileBrowser *fbrowser = segue.destinationViewController;
        fbrowser.titleText = @"Enter filename or select file to overwrite:";
        fbrowser.baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        fbrowser.isOpenDialog = NO;
        fbrowser.signatureTypesOnly = YES;
        fbrowser.view.tag = SAVE_SIGNATURE_FILE;
    }
    
    //Attach File
    if([segue.identifier compare:@"HashFile" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        FileBrowser *fbrowser = segue.destinationViewController;
        fbrowser.titleText = @"Select a file to use as a hash:";
        fbrowser.baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        fbrowser.isOpenDialog = YES;
        fbrowser.signatureTypesOnly = NO;
        fbrowser.view.tag = OPEN_BINARY_HASH_FILE;
    }
    
    //Show validation status
    if([segue.identifier compare:@"VerifySignature" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        SignatureIntegrityController *sv = segue.destinationViewController;
        sv.sigObj = self.currentSignatureObject;
        sv.hashData = self.hashData;
    }
    
    //Capture settings
    if([segue.identifier compare:@"CaptureSettings" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        CaptureSettingsController *settingsController = segue.destinationViewController;
        settingsController.xPadding = self.xPaddingForImageExport;
        settingsController.yPadding = self.yPaddingForImageExport;
        settingsController.imageFlags = self.exportAsImageFlags;
        settingsController.signatureHashType = self.signatureCapture.keyType;
        settingsController.extraDataHashType = self.signatureCapture.hashType;
        settingsController.macKey = self.currentSignatureObject.keyValue;
    }
    
    //Open In (called from Application Delegate)
    if([segue.identifier compare:@"OpenIn" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
        FileBrowser *fbrowser = segue.destinationViewController;
        fbrowser.titleText = @"Select a desintation filename:";
        fbrowser.baseDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        fbrowser.isOpenDialog = NO;
        fbrowser.signatureTypesOnly = YES;
        fbrowser.view.tag = OPEN_IN_FILE;
        
        if([sender isKindOfClass:[NSURL class]]) {
            fbrowser.sourceFile = (NSURL *)sender;
            fbrowser.selectedFilename = [fbrowser.sourceFile lastPathComponent];
        }
    }
}

//Default unwind used for cancel out of modal dialogues & return from read-only info screens
- (IBAction)unwindToMainViewController:(UIStoryboardSegue *)unwindSegue {
    
}

//Return from file open dialog screen
- (IBAction)unwindWithFileToOpen:(UIStoryboardSegue *)unwindSegue {
    FileBrowser *fb = unwindSegue.sourceViewController;
    FILE_DIALOG_MODE mode = fb.view.tag;
    
    switch (mode) {
        case OPEN_SIGNATURE_FILE: {
            if([fb.selectedFilename length] == 0) {
                [self showMessageBoxWithTitle:@"Error" andMessage:@"No File Selected"];
                return;
            }
            
            self.currentSignatureObject = nil; //We've got this far so clear out any current signature data
            if([[fb.selectedFilename pathExtension] compare:@"txt" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [self loadEncodedTXTAtPath:fb.selectedFilename];
            } else if([[fb.selectedFilename pathExtension] compare:@"fss" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [self loadEncodedBINAtPath:fb.selectedFilename];
            } else if([[fb.selectedFilename pathExtension] compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                [self loadEncodedPNGAtPath:fb.selectedFilename];
            } else {
                [self showMessageBoxWithTitle:@"Error" andMessage:[NSString stringWithFormat:@"Unsupported file type:%@", [fb.selectedFilename pathExtension]]];
                [self.toolbarCollectionView reloadData];
                return;
            }
        } break;
            
        case OPEN_BINARY_HASH_FILE: {
            if([fb.selectedFilename length] == 0) {
                [self showMessageBoxWithTitle:@"Error" andMessage:@"No File Selected"];
                return;
            }
            self.hashData = [NSData dataWithContentsOfFile:fb.selectedFilename];
            [self.toolbarCollectionView reloadData];
        } break;
            
        case SAVE_SIGNATURE_FILE: {
            if([fb.selectedFilename length] == 0) {
                [self showMessageBoxWithTitle:@"Error" andMessage:@"No Filename Set"];
                return;
            }
            if(self.confirmForFileOverwrite) {
                [self checkForOverwriteAtPath:fb.selectedFilename];
            } else {
                [self exportSignatureWithCurrentFlagsToPath:fb.selectedFilename];
            }
        } break;
            
        case OPEN_IN_FILE: {
            if([fb.selectedFilename length] == 0) {
                return;
            }
            
            if(self.confirmForFileOverwrite) {
                [self checkForOverwriteAtPath:fb.selectedFilename withSourceFile:fb.sourceFile];
            } else {
                [[NSFileManager defaultManager] removeItemAtPath:fb.selectedFilename error:nil];
                [[NSFileManager defaultManager] moveItemAtPath:[fb.sourceFile path] toPath:fb.selectedFilename error:nil];
                [self showMessageBoxWithTitle:nil andMessage:[NSString stringWithFormat:@"Wrote: %@", [fb.selectedFilename lastPathComponent]]];
            }
        } break;
    }
}

//New settings
- (IBAction)unwindWithNewSettings:(UIStoryboardSegue *)unwindSegue {
    CaptureSettingsController *settingsController = unwindSegue.sourceViewController;
    self.xPaddingForImageExport = settingsController.xPadding;
    self.yPaddingForImageExport = settingsController.yPadding;
    self.exportAsImageFlags = settingsController.imageFlags;
    self.signatureCapture.keyType = settingsController.signatureHashType;
    self.signatureCapture.hashType = settingsController.extraDataHashType;
    self.signatureCapture.MD5_MacKeyValue = settingsController.macKey;
    self.currentSignatureObject.keyValue = settingsController.macKey;
}

//======================================================================================================================
#pragma mark - UITextView delegate methods

///----------
/// @name TextView delegate Methods
///----------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return(YES);
}


@end

