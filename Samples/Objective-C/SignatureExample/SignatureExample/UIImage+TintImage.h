//
//  UIImage+TintImage.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 05/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (TintImage)

/**
 *  @brief Simple Utility method for adding a tint to a UIImage
 *
 *  @param tintColor The desired tint
 *
 *  @return The tinted image
 */
- (UIImage *)tintedImageWithColour:(UIColor *)tintColor;

@end
