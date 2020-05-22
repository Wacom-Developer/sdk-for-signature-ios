//
//  SignaturePreviewCellCollectionViewCell.m
//  InPlaceSigning
//
//  Created by Joss Giffard-Burley on 08/09/2015.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

#import "SignaturePreviewCellCollectionViewCell.h"


@interface SignaturePreviewCellCollectionViewCell()

/**
 *  UIImage version of the signature
 */
@property (nonatomic, strong) IBOutlet UIImageView *signatureImageView;

/**
 *  The label that is used to display the 'name' data within the signature
 */
@property (nonatomic, strong) IBOutlet UILabel *nameLabel;

/**
 *  The label that is used to display the 'reason' data within the signature
 */
@property (nonatomic, strong) IBOutlet UILabel *reasonLabel;

/**
 *  The UIImage version of the signature
 */
@property (nonatomic, strong) UIImage *signatureImage;

/**
 *  Updates the view based on the current signature data & settigns
 */
- (void)reloadSignatureData;

/**
 *  Common UI init routines
 */
- (void)commonInit;

@end


@implementation SignaturePreviewCellCollectionViewCell

@synthesize inkColour = _inkColour;

- (void)awakeFromNib {
    [super awakeFromNib];
    [self contentView];
    [self commonInit];
}

- (void) prepareForInterfaceBuilder {
    [self commonInit];
}

- (void)commonInit {
    self.signatureBackgroundColour = [UIColor whiteColor];
    self.inkColour = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 5.0f;
    self.reasonLabel.text = @"(no reason data)";
    self.nameLabel.text = @"(no name data)";

}


- (void)setSignatureData:(SignatureObject *)signatureData {
    _signatureData = signatureData;
    [self reloadSignatureData];
}

- (void)setSignatureBackgroundColour:(UIColor *)signatureBackgroundColour {
    [self.signatureImageView setBackgroundColor:signatureBackgroundColour];
}

/**
 *  Reloads the signature data based on the current settings & signature object
 */
- (void)reloadSignatureData {
    if(self.signatureData) {
        
        //Set the text field data
        if(self.signatureData.why.length > 0) {
            self.reasonLabel.text = self.signatureData.why;
        } else {
            self.reasonLabel.text = @"(no reason data)";
        }
        
        if(self.signatureData.who.length > 0) {
            self.nameLabel.text = self.signatureData.who;
        } else {
            self.nameLabel.text = @"(no name data)";
        }
        
        if(!_signatureImage) {
        //Load the signature image
        SIGNATURE_IMAGE_FLAGS imageFlags = TRANSPARENT_BACKGROUND | CLIP_TO_SIGNATURE_BOUNDS |DO_NOT_SCALE ;
        _signatureImage = [self.signatureData signatureAsUIImageWithFlags:imageFlags
                                                                            width:0
                                                                           height:0
                                                                         paddingX:5
                                                                         paddingY:5
                                                                         inkColor:self.inkColour
                                                                  backgroundColor:[UIColor clearColor]];
        }
        [self.signatureImageView setImage:self.signatureImage];
    }
}

- (void)prepareForReuse {
    self.signatureData = nil;
    self.nameLabel.text = @"";
    self.reasonLabel.text = @"";
    self.inkColour = [UIColor blackColor];
    self.backgroundColor = [UIColor whiteColor];
}

@end
