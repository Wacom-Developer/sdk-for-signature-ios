//
//  ViewController.m
//  InPlaceSigning
//
//  Created by joss on 07/09/2015.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

#import "ViewController.h"
#import "SignaturePreviewCellCollectionViewCell.h"
#import <WacomSignatureSDK/WacomSignatureSDK.h>


/**
 *  Basic data object for our sample signature fields
 */
@interface SignatureSample : NSObject<SigningViewDelegate>

@property (nonatomic, strong) SignatureObject *sigData;
@property (nonatomic, strong) UIColor *inkColour;
@property (nonatomic, strong) UIColor *backgroundColour;

@end

@implementation SignatureSample

- (void)inkingBegan {
    
}

- (void)inkingEnded {
    
}

@end


@interface ViewController ()

@property (strong, nonatomic) IBOutlet UITextField *signatureNameField;
@property (strong, nonatomic) IBOutlet UITextField *signatureReasonField;
@property (strong, nonatomic) IBOutlet UILabel *inkColourLabel;
@property (strong, nonatomic) IBOutlet UILabel *stylusStatusLabel;
@property (strong, nonatomic) IBOutlet SigningView *signingView;
@property (strong, nonatomic) IBOutlet UICollectionView *signatureSamples;
@property (strong, nonatomic) IBOutlet UILabel *signatureSampesLabel;
@property (strong, nonatomic) NSMutableArray *signatureSampleData;

- (void)updateStylusLabel;

/**
 *  Captures the current signature data, and creates a new signature sample object
 *
 *  @param sender The UIButton
 */
- (IBAction)captureSignatureData:(id)sender;
- (IBAction)changeInkColour;
- (IBAction)resetSignatureField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _signatureSampleData = [[NSMutableArray alloc] init];

    self.signatureSamples.dataSource = self;
    self.signatureSamples.delegate = self;
    [self.signatureSamples registerNib:[UINib nibWithNibName:@"SignaturePreviewCellCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"sigSample"];
    
    self.signingView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.signingView.layer.borderWidth = 1.0f;
    self.signingView.layer.cornerRadius = 2.0f;
    
    //Set the starting colour to black on white
    self.signingView.inkColor = [UIColor blackColor];
    self.signingView.backgroundColor = [UIColor whiteColor];
    
    //Set the starting who / why

    self.signingView.why = self.signatureReasonField.text;
    self.signingView.who = self.signatureNameField.text;
    
    //Set the delegate
    
    self.signingView.delegate = self;
    
    [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(updateStylusLabel) userInfo:nil repeats:YES];
}

/**
 *  Generate a random colour
 *
 *  @return A random colour
 */
- (UIColor *)randomCol {
    CGFloat hue = (arc4random() % 256 / 256.0);
    CGFloat saturation = (arc4random() % 128 / 256.0) + 0.5;
    CGFloat brightness = (arc4random() % 128 / 256.0) + 0.5;
    UIColor *col = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    return(col);
}

/**
 *  Captures the current signature data, and adds a new sample signature to our list.
 *
 *  @param sender The UIButton
 */
- (IBAction)captureSignatureData:(id)sender {
    SignatureObject *signatureData = [self.signingView currentSignatureData];
    
    if(signatureData) {
        SignatureSample *newSample = [[SignatureSample alloc] init];
        newSample.inkColour = self.signingView.inkColor;
        newSample.backgroundColour = self.signingView.backgroundColor;
        newSample.sigData = signatureData;
        [self.signatureSampleData addObject:newSample];
        [self.signatureSamples reloadData];
        [self.signingView reset];
        
        //Change to a random colour
        [self changeInkColour];
    }
}

- (IBAction)textChanged:(UITextField *)sender {
    if(sender == self.signatureReasonField) {
        self.signingView.why = sender.text;
    } else if (sender == self.signatureNameField) {
        self.signingView.who = sender.text;
    }
}

/**
 *  Changes the signature view colours to a random selection
 */
- (IBAction)changeInkColour {
    UIColor *ink = [self randomCol];
    UIColor *background = [self randomCol];
    
    self.signingView.inkColor = ink;
    self.inkColourLabel.textColor = ink;
    self.signingView.backgroundColor = background;
    self.inkColourLabel.backgroundColor = background;
}

/**
 *  Clears the signature field
 */
- (IBAction)resetSignatureField {
    [self.signingView reset];
}

/**
 *  Updates the stylus label based on the current connection status
 */
- (void)updateStylusLabel {
    if(self.signingView.stylusIsConnected) {
        self.stylusStatusLabel.textColor = [UIColor greenColor];
        self.stylusStatusLabel.text = @"Stylus Connected";
    } else {
        self.stylusStatusLabel.textColor = [UIColor redColor];
        self.stylusStatusLabel.text = @"STYLUS IS NOT CONNECTED";
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.signatureSampleData count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SignaturePreviewCellCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sigSample" forIndexPath:indexPath];
    SignatureSample *obj = self.signatureSampleData[indexPath.row];
    
    cell.inkColour = obj.inkColour;
    cell.signatureBackgroundColour = obj.backgroundColour;
    cell.signatureData = obj.sigData;
    
    return(cell);
}

- (BOOL)shouldAutorotate {
    return(NO);
}

//Delegate methods

- (void)inkingBegan {
    self.stylusStatusLabel.textColor = [UIColor blueColor];
    self.stylusStatusLabel.text = [NSString stringWithFormat:@"Inking began - Battery %d", self.signingView.stylusBatteryLevel];
}

- (void)inkingEnded {
    self.stylusStatusLabel.textColor = [UIColor yellowColor];
    self.stylusStatusLabel.text = [NSString stringWithFormat:@"Inking ended - Battery %d", self.signingView.stylusBatteryLevel];
    //Dump battery level to console
}
@end
