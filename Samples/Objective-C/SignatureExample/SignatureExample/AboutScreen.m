//
//  AboutScreen.m
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 06/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

#import "AboutScreen.h"
#import "UIImage+TintImage.h"

@interface AboutScreen()

@property (strong, nonatomic) IBOutlet UIImageView *logoImage;
@property (strong, nonatomic) IBOutlet UILabel *versionText;
@property (strong, nonatomic) IBOutlet UILabel *licenseText;

@end

@implementation AboutScreen


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //Set the SDK version string
    [self.versionText setText:[NSString stringWithFormat:@"Version %@", self.versionString]];
    
    //Set the license string
    [self.licenseText setText:self.licenseString];
    
    //Tint the logo
    [self.logoImage setImage:[[UIImage imageNamed:@"logo_sdk_screen"] tintedImageWithColour:[UIColor colorWithRed:0.4f
                                                                                                            green:0.4f
                                                                                                             blue:0.4f
                                                                                                            alpha:1.0f]]];
}

- (IBAction)goToWebsite:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.wacom.com/"]];
}

@end
