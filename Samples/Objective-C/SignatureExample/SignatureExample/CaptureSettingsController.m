//
//  CaptureSettingsController.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 11/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//


#import "CaptureSettingsController.h"
#import "UIImage+TintImage.h"

/**
 *  @brief ENUM that is used to define the pop-over contents
 */
typedef enum : NSUInteger {
    SIGNATURE_KEY_TYPE,
    SIGNATURE_DOCUMENT_KEY_TYPE,
} SETTINGS_POPOVER_MODE;

@interface CaptureSettingsController ()

@property (weak, nonatomic)   IBOutlet UIButton *cancelButton;
@property (weak, nonatomic)   IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UIButton *signtureKeyButton;
@property (strong, nonatomic) IBOutlet UIButton *documentKeyButton;
@property (strong, nonatomic) IBOutlet UILabel *signatureKeyType;
@property (strong, nonatomic) IBOutlet UILabel *documentKeyType;
@property (strong, nonatomic) IBOutlet UILabel *md5MacLabel;
@property (strong, nonatomic) IBOutlet UISwitch *encodeSignatureSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *renderWatermark;
@property (strong, nonatomic) IBOutlet UISwitch *transparentBackground;
@property (strong, nonatomic) IBOutlet UISwitch *clipToBounds;
@property (strong, nonatomic) IBOutlet UISwitch *scaleOutput;
@property (strong, nonatomic) IBOutlet UITextField *xPaddingField;
@property (strong, nonatomic) IBOutlet UITextField *yPaddingField;
@property (strong, nonatomic) IBOutlet UITextField *md5MACKeyField;
@property (strong, nonatomic) IBOutlet UIPopoverController *settingsPopover;
@property (assign, nonatomic) SETTINGS_POPOVER_MODE currentPopoverMode;

/**
 *  @brief Update the display values of the fields based on the current settings
 */
- (void)updateFields;

/**
 *  @brief Simple utility method that creates a human readable version of the singature hash type
 *
 *  @param hashType The `SIGNATURE_HASH_TYPE` to convert
 *
 *  @return A human readable NSString for representing the hash type
 */
- (NSString *)hashTypeToString:(SIGNATURE_HASH_TYPE)hashType;

/**
 *  @brief Update data fields based on the field data
 */
- (IBAction)updateImageFlags;

/**
 *  @brief This closes the keyboard view
 */
- (void)dismissKeyboard;

/**
 *  @brief Updates the xPadding, yPadding and MAC key based on the current field contents
 */
- (void)updateTextData;

- (IBAction)documentKeyButtonAction:(UIButton *)sender;
- (IBAction)signatureKeyButtonAction:(UIButton *)sender;

@end

@implementation CaptureSettingsController

//======================================================================================================================
#pragma mark - UIView methods

///----------
/// @name UIView methods
///----------

- (void)viewDidLoad {
    [super viewDidLoad];
    self.okButton.layer.cornerRadius = 5.0f;
    self.cancelButton.layer.cornerRadius = 5.0f;
    [self.documentKeyButton setImage:[[UIImage imageNamed:@"action_edit"] tintedImageWithColour:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]] forState:UIControlStateNormal];
    [self.signtureKeyButton setImage:[[UIImage imageNamed:@"action_edit"] tintedImageWithColour:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]] forState:UIControlStateNormal];
    [self updateFields];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [self dismissKeyboard];
    [self updateTextData];
    [self updateImageFlags];
}

//======================================================================================================================
#pragma mark - Interface methods

///----------
/// @name Interface methods
///----------

- (NSString *)hashTypeToString:(SIGNATURE_HASH_TYPE)hashType {
    switch (hashType) {
        case MD5_HASH:
            return(@"MD5");
        case MD5_MAC_HASH:
            return(@"MD5 With MAC key");
        case SHA_1_HASH:
            return(@"SHA-1");
        case SHA_224_HASH:
            return(@"SHA-224");
        case SHA_256_HASH:
            return(@"SHA-256");
        case SHA_384_HASH:
            return(@"SHA-384");
        case SHA_512_HASH:
            return(@"SHA-512");
        case NO_HASH:
            return(@"No Hash");
    }
    
    return(@"Unknown Hash Type");
}

- (void)updateFields {
    //Signature key
    self.signatureKeyType.text = [self hashTypeToString:self.signatureHashType];
    
    //Document key
    self.documentKeyType.text = [self hashTypeToString:self.extraDataHashType];
    
    //MD5
    self.md5MACKeyField.text = self.macKey;
    //Only show these fields if the type is MD5 MAC
    self.md5MACKeyField.hidden = self.signatureHashType != MD5_MAC_HASH;
    self.md5MacLabel.hidden = self.signatureHashType != MD5_MAC_HASH;
    
    //Encode
    self.encodeSignatureSwitch.on = self.imageFlags & ENCODE_SIGNATURE_DATA;
    //Render
    self.renderWatermark.on = self.imageFlags & RENDER_WATERMARK;
    
    //Trans
    self.transparentBackground.on = self.imageFlags & TRANSPARENT_BACKGROUND;
    
    //clip
    self.clipToBounds.on = self.imageFlags & CLIP_TO_SIGNATURE_BOUNDS;
    
    //scale
    self.scaleOutput.on = self.imageFlags & DO_NOT_SCALE;
    
    //Xpad
    self.xPaddingField.text = [NSString stringWithFormat:@"%.1f", self.xPadding];
    
    //Ypad
    self.yPaddingField.text = [NSString stringWithFormat:@"%.1f", self.yPadding];
}

- (IBAction)updateImageFlags {
    [self dismissKeyboard];
    
    if(self.encodeSignatureSwitch.on) {
        self.imageFlags |= ENCODE_SIGNATURE_DATA;
    } else {
        self.imageFlags &= ~ENCODE_SIGNATURE_DATA;
    }
    
    if(self.renderWatermark.on) {
        self.imageFlags |= RENDER_WATERMARK;
    } else {
        self.imageFlags &= ~RENDER_WATERMARK;
    }
    
    if(self.transparentBackground.on) {
        self.imageFlags |= TRANSPARENT_BACKGROUND;
    } else {
        self.imageFlags &= ~TRANSPARENT_BACKGROUND;
    }
    
    if(self.clipToBounds.on) {
        self.imageFlags |= CLIP_TO_SIGNATURE_BOUNDS;
    } else {
        self.imageFlags &= ~CLIP_TO_SIGNATURE_BOUNDS;
    }
    
    if(self.scaleOutput.on) {
        self.imageFlags |= DO_NOT_SCALE;
    } else {
        self.imageFlags &= ~DO_NOT_SCALE;
    }
}

- (void)updateTextData {
    self.macKey = self.md5MACKeyField.text;
    self.xPadding = [self.xPaddingField.text floatValue];
    self.yPadding = [self.yPaddingField.text floatValue];
}

- (void)dismissKeyboard {
    [self.md5MACKeyField resignFirstResponder];
    [self.xPaddingField resignFirstResponder];
    [self.yPaddingField resignFirstResponder];
}

//======================================================================================================================
#pragma mark - Action callbacks

///----------
/// @name Action callback methods
///----------

- (IBAction)documentKeyButtonAction:(UIButton *)sender {
    NSInteger totalTableHeight = 7 * 33;
    
    UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, totalTableHeight) style:UITableViewStylePlain];
    tb.delegate = self;
    tb.dataSource = self;
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = tb;
    vc.preferredContentSize = CGSizeMake(200, totalTableHeight);
    
    self.currentPopoverMode = SIGNATURE_DOCUMENT_KEY_TYPE;
    
    self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.settingsPopover.delegate = self;

    [self.settingsPopover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (IBAction)signatureKeyButtonAction:(UIButton *)sender {
    NSInteger totalTableHeight = 8 * 33;
    
    UITableView *tb = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 200, totalTableHeight) style:UITableViewStylePlain];
    tb.delegate = self;
    tb.dataSource = self;
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view = tb;
    vc.preferredContentSize = CGSizeMake(200, totalTableHeight);
    
    self.currentPopoverMode = SIGNATURE_KEY_TYPE;
    
    self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:vc];
    self.settingsPopover.delegate = self;
    
    [self.settingsPopover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//======================================================================================================================
#pragma mark - Text Field Delegate methods

///----------
/// @name Text Field Delegate methods
///----------

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dismissKeyboard];
    return(YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self dismissKeyboard];
    [self updateTextData];
}

//======================================================================================================================
#pragma mark - UIPopover delegate methods

///----------
/// @name UIPopover Delegate methods
///----------

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    UIButton *button = self.currentPopoverMode == SIGNATURE_DOCUMENT_KEY_TYPE ? self.signtureKeyButton : self.documentKeyButton;
    [popoverController presentPopoverFromRect:button.frame inView:*view permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
}

//======================================================================================================================
#pragma mark - UITableView Delegate methods

///----------
/// @name UITableView Delegate methods
///----------

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popovercell"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"popovercell"];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.4f green:0.4f blue:0.4f alpha:1.0f]];
    }
    
    SIGNATURE_HASH_TYPE currentlySelected = self.currentPopoverMode == SIGNATURE_KEY_TYPE ? self.signatureHashType : self.extraDataHashType;
    
    switch (indexPath.row) {
        case 0: //NO HASH
            cell.textLabel.text = [self hashTypeToString:NO_HASH];
            if(currentlySelected == NO_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 1: //SHA-1
            cell.textLabel.text = [self hashTypeToString:SHA_1_HASH];
            if(currentlySelected == SHA_1_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 2: //SHA-224
            cell.textLabel.text = [self hashTypeToString:SHA_224_HASH];
            if(currentlySelected == SHA_224_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 3: //SHA-256
            cell.textLabel.text = [self hashTypeToString:SHA_256_HASH];
            if(currentlySelected == SHA_256_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 4: //SHA-384
            cell.textLabel.text = [self hashTypeToString:SHA_384_HASH];
            if(currentlySelected == SHA_384_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 5: //SHA-512
            cell.textLabel.text = [self hashTypeToString:SHA_512_HASH];
            if(currentlySelected == SHA_512_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 6: //MD5
            cell.textLabel.text = [self hashTypeToString:MD5_HASH];
            if(currentlySelected == MD5_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
        case 7: //MD5-MAC
            cell.textLabel.text = [self hashTypeToString:MD5_MAC_HASH];
            if(currentlySelected == MD5_MAC_HASH) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            break;
    }
    
    return(cell);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.currentPopoverMode == SIGNATURE_KEY_TYPE) {
        return(8);
    } else {
        return(7); //No MD5-MAC for the document hash
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return(33.0f);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SIGNATURE_HASH_TYPE targetType;
    
    switch (indexPath.row) {
        case 0:
            targetType = NO_HASH;
            break;
        case 1:
            targetType = SHA_1_HASH;
            break;
        case 2:
            targetType = SHA_224_HASH;
            break;
        case 3:
            targetType = SHA_256_HASH;
            break;
        case 4:
            targetType = SHA_384_HASH;
            break;
        case 5:
            targetType = SHA_512_HASH;
            break;
        case 6:
            targetType = MD5_HASH;
            break;
        case 7:
            targetType = MD5_MAC_HASH;
            break;
        default:
            targetType = NO_HASH;
    }
    
    if(self.currentPopoverMode == SIGNATURE_KEY_TYPE) {
        self.signatureHashType = targetType;
    } else {
        self.extraDataHashType = targetType;
    }
    
    [self.settingsPopover dismissPopoverAnimated:YES];
    self.settingsPopover = nil;
    [self updateFields];
}

@end
