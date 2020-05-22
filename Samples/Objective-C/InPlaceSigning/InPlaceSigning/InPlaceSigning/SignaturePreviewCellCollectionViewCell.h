//
//  SignaturePreviewCellCollectionViewCell.h
//  InPlaceSigning
//
//  Created by Joss Giffard-Burley on 08/09/2015.
//  Copyright (c) 2015 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WacomSignatureSDK/WacomSignatureSDK.h>
IB_DESIGNABLE
/**
 *  `SignaturePreviewCellCollectionViewCell` displays a PNG image of the signature that has been captured
 */
@interface SignaturePreviewCellCollectionViewCell : UICollectionViewCell

/**
 *  The signature data to display the preview for
 */
@property (nonatomic, strong) SignatureObject *signatureData;

/**
 *  The colour to use for the ink rendering
 */
@property (nonatomic, strong) UIColor *inkColour;

/**
 *  The background colour of the cell
 */
@property (nonatomic, strong) UIColor *signatureBackgroundColour;

@end
