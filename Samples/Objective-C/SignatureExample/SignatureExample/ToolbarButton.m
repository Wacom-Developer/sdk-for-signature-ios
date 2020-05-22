//
//  ToolbarButton.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 06/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "ToolbarButton.h"

@implementation ToolbarButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:(16.0f/255.0f) green:(132.0f/255.0f) blue:(202.0f/255.0f) alpha:1.0f];
        self.layer.cornerRadius = 5.0f;
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 5, 34, 34)];
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:self.imageView];
    }
    return self;
}

@end
