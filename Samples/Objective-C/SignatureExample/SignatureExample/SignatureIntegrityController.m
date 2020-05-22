//
//  SignatureIntegrityController.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 08/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "SignatureIntegrityController.h"
#import "UIImage+TintImage.h"
#import <WacomSignatureSDK/WacomSignatureSDK.h>

@interface SignatureIntegrityController ()

@property (strong, nonatomic) IBOutlet UIButton *okButton;
@property (strong, nonatomic) IBOutlet UILabel *who;
@property (strong, nonatomic) IBOutlet UILabel *when;
@property (strong, nonatomic) IBOutlet UILabel *why;
@property (strong, nonatomic) IBOutlet UILabel *captureArea;
@property (strong, nonatomic) IBOutlet UILabel *singatureArea;
@property (strong, nonatomic) IBOutlet UILabel *digitizer;
@property (strong, nonatomic) IBOutlet UILabel *driver;
@property (strong, nonatomic) IBOutlet UILabel *machineOS;
@property (strong, nonatomic) IBOutlet UILabel *hashType;
@property (strong, nonatomic) IBOutlet UILabel *integrityStatus;
@property (strong, nonatomic) IBOutlet UILabel *documentHashType;
@property (strong, nonatomic) IBOutlet UILabel *documentHashStatus;
@property (strong, nonatomic) IBOutlet UILabel *extraItemsLabel;
@property (strong, nonatomic) IBOutlet UIButton *extraItemsButton;
@property (strong, nonatomic) IBOutlet UIView *integView;
@property (strong, nonatomic) UIPopoverController *extraDatapopoverController;

- (SIGNATURE_HASH_TYPE)getHashTypeForSigObj;
- (SIGNATURE_HASH_TYPE)getDocHashTypeForSigObj;
- (NSString *)stringForHashType:(SIGNATURE_HASH_TYPE)hashType;
- (NSString *)validationStringForSignature;
- (NSString *)validationStringForDocumentData;
- (IBAction)extraItemsButtonTapped:(id)sender;

@end

@implementation SignatureIntegrityController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.okButton.layer.cornerRadius = 5.0f;
    [self.extraItemsButton setImage:[[UIImage imageNamed:@"action_about"] tintedImageWithColour:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]] forState:UIControlStateNormal];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.who.text = self.sigObj.who;
    self.why.text = self.sigObj.why;
    self.when.text = [NSDateFormatter localizedStringFromDate:self.sigObj.when dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    self.captureArea.text = [NSString stringWithFormat:@"%.0fx%.0f", self.sigObj.captureAreaBounds.width, self.sigObj.captureAreaBounds.height];
    self.singatureArea.text = [NSString stringWithFormat:@"%.0fx%.0f", self.sigObj.signatureAreaBounds.width, self.sigObj.signatureAreaBounds.height];
    self.digitizer.text = self.sigObj.additionalData[kCaptureDigitizer];
    self.driver.text = self.sigObj.additionalData[kCaptureDigitizerDriver];
    self.machineOS.text = self.sigObj.additionalData[kCaptureMachineOS];
    self.hashType.text = [self stringForHashType:[self getHashTypeForSigObj]];
    self.integrityStatus.text = [self validationStringForSignature];
    self.documentHashType.text = [self stringForHashType:[self getDocHashTypeForSigObj]];
    self.documentHashStatus.text = [self validationStringForDocumentData];
    
    if([self.sigObj.extraDataItems count] > 0) {
        self.extraItemsLabel.text = [NSString stringWithFormat:@"%lu Extra Data Items:",  (unsigned long)self.sigObj.extraDataItems.count];
    } else {
        self.extraItemsLabel.hidden = YES;
        self.extraItemsButton.hidden = YES;
    }
}

- (SIGNATURE_HASH_TYPE)getHashTypeForSigObj {
    SIGNATURE_INTEGRITY_STATUS status;

    //MD5
    status = [self.sigObj checkIntegrity:MD5_HASH];
    if(status == INTEGRITY_MISSING) {
        return(NO_HASH);
    } else if((status == INTEGRITY_OK) || (status == INTEGRITY_FAIL) || (status == INTEGRITY_INVALID_KEY)) {//we know the type
        return(MD5_HASH);
    }
    
    //SHA-1
    status = [self.sigObj checkIntegrity:SHA_1_HASH];
    if(status != INTEGRITY_WRONG_TYPE) { //must be OK or FAIL at this point so we have the correct type as missing is accounted for above
        return(SHA_1_HASH);
    }
    
    //SHA-224
    status = [self.sigObj checkIntegrity:SHA_224_HASH];
    if(status != INTEGRITY_WRONG_TYPE) {
        return(SHA_224_HASH);
    }
    
    //SHA-256
    status = [self.sigObj checkIntegrity:SHA_256_HASH];
    if(status != INTEGRITY_WRONG_TYPE) {
        return(SHA_256_HASH);
    }
    
    //SHA-384
    status = [self.sigObj checkIntegrity:SHA_384_HASH];
    if(status != INTEGRITY_WRONG_TYPE) {
        return(SHA_384_HASH);
    }
    
    //SHA-512
    status = [self.sigObj checkIntegrity:SHA_512_HASH];
    if(status != INTEGRITY_WRONG_TYPE) {
        return(SHA_512_HASH);
    }
    
    //MD5-MAC
    status = [self.sigObj checkIntegrity:MD5_MAC_HASH];
    if(status != INTEGRITY_WRONG_TYPE) {
        return(MD5_MAC_HASH);
    }
    
    return(NO_HASH);
}

- (SIGNATURE_HASH_TYPE)getDocHashTypeForSigObj {
    SIGNATURE_SIGNED_DATA_STATUS status;

    status = [self.sigObj checkSignatureData:MD5_HASH withData:self.hashData];
    if(status == DATA_NO_DATA || status == DATA_NO_HASH) {
        return(NO_HASH);
    }
    
    if(status != DATA_BAD_TYPE) {
        return(MD5_HASH);
    }
    
    status = [self.sigObj checkSignatureData:SHA_1_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(SHA_1_HASH);
    }
    
    status = [self.sigObj checkSignatureData:SHA_224_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(SHA_224_HASH);
    }
    
    status = [self.sigObj checkSignatureData:SHA_256_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(SHA_256_HASH);
    }
    
    status = [self.sigObj checkSignatureData:SHA_384_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(SHA_384_HASH);
    }
    
    status = [self.sigObj checkSignatureData:SHA_512_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(SHA_512_HASH);
    }
    
    //MD5-MAC
    status = [self.sigObj checkSignatureData:MD5_MAC_HASH withData:self.hashData];
    if(status != DATA_BAD_TYPE) {
        return(MD5_MAC_HASH);
    }
    
    return(NO_HASH);
}

- (NSString *)stringForHashType:(SIGNATURE_HASH_TYPE)hashType {
    switch (hashType) {
        case NO_HASH:
            return(@"No Hash");
        case MD5_HASH:
            return(@"MD5");
        case MD5_MAC_HASH:
            return (@"MD5 with MAC-KEY");
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
    }
}

- (NSString *)validationStringForSignature {
    SIGNATURE_HASH_TYPE hash = [self getHashTypeForSigObj];
    
    if(hash == NO_HASH) {
        return(@"No Hash");
    } else {
        SIGNATURE_INTEGRITY_STATUS st = [self.sigObj checkIntegrity:hash];
        
        switch (st) {
            case INTEGRITY_MISSING:
                return(@"No integrity data found");
            case INTEGRITY_FAIL:
                return(@"Integrity failed");
            case INTEGRITY_WRONG_TYPE:
                return(@"Integrity is of wrong type");
            case INTEGRITY_OK:
                return(@"Integrity OK");
            case INTEGRITY_INVALID_KEY:
                return (@"Invalid MAC key");
        }
    }
}

- (NSString *)validationStringForDocumentData {
    SIGNATURE_HASH_TYPE hash = [self getDocHashTypeForSigObj];

    if(hash == NO_HASH) {
        return(@"No Hash Data");
    } else {
        SIGNATURE_SIGNED_DATA_STATUS st = [self.sigObj checkSignatureData:[self getDocHashTypeForSigObj] withData:self.hashData];
        
        switch (st) {
            case DATA_BAD_HASH:
                return(@"Data hash does not match. Document differs.");
            case DATA_BAD_TYPE:
                return(@"Incorrect hash type");
            case DATA_NO_HASH:
                return(@"No document hash data defined");
            case DATA_NO_DATA:
                return(@"No hash data provided");
            case DATA_GOOD:
                return(@"Data hash matches. Document is the same.");
        }
    }
}

- (IBAction)extraItemsButtonTapped:(id)sender {
    UITableViewController *vc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    vc.tableView.delegate = self;
    vc.tableView.dataSource = self;
    vc.tableView.rowHeight = 33.0f;
    vc.preferredContentSize = CGSizeMake(500.0f, 33.0f * self.sigObj.extraDataItems.count);
    self.extraDatapopoverController = [[UIPopoverController alloc] initWithContentViewController:vc];

    [self.extraDatapopoverController presentPopoverFromRect:self.extraItemsButton.frame inView:self.integView permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

#pragma mark - UIPopover Delegate methods

- (void)popoverController:(UIPopoverController *)popoverController willRepositionPopoverToRect:(inout CGRect *)rect inView:(inout UIView **)view {
    [popoverController dismissPopoverAnimated:YES];
    self.extraDatapopoverController = nil;
}

#pragma mark - UITableView delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return(self.sigObj.extraDataItems.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"extraData"];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"extraData"];
        [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [cell.textLabel setTextColor:[UIColor colorWithRed:0.31f green:0.31f blue:0.31f alpha:1.0f]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
        [cell.detailTextLabel setTextColor:[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f]];
    }
    
    NSString *key = self.sigObj.extraDataItems.allKeys[indexPath.row];
    cell.textLabel.text = key;
    cell.detailTextLabel.text = self.sigObj.extraDataItems[key];
    
    return(cell);
}
@end
