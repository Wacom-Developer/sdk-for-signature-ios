//
//  SingatureImageController.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 07/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "SingatureImageController.h"
#import "UIImage+TintImage.h"

@interface SingatureImageController ()
@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UIImageView *signatureView;

@end

@implementation SingatureImageController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.logoImage setImage:[[UIImage imageNamed:@"logo_window"] tintedImageWithColour:[UIColor colorWithRed:0.4f
                                                                                                        green:0.4f
                                                                                                         blue:0.4f
                                                                                                        alpha:1.0f]]];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.superview.bounds = CGRectMake(0, 0, 520.0f, 376.0f);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.signatureView.image = self.signatureImage;
}

@end
