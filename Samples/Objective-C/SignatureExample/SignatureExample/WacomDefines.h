//
//  WacomColours.h
//  SignatureExample
//
//  Created by Joss Giffard-Burley on 05/08/2014.
//  Copyright (c) 2014 Wacom. All rights reserved.
//

/**
 *  This is a simple collection of constants that are used in the demo application
 */

#import <Foundation/Foundation.h>

#define WACOM_BLACK         [UIColor colorWithRed:0.015f green:0.015f blue:0.015f alpha:1.0f]
#define WACOM_DARK_GREY     [UIColor colorWithRed:0.149f green:0.149f blue:0.149f alpha:1.0f]
#define WACOM_LIGHT_GREY    [UIColor colorWithRed:0.325f green:0.325f blue:0.325f alpha:1.0f]
#define WACOM_BLUE          [UIColor colorWithRed:0.223f green:0.270f blue:0.560f alpha:1.0f]
#define WACOM_RED           [UIColor colorWithRed:0.588f green:0.156f blue:0.172f alpha:1.0f]
#define WACOM_GREEN         [UIColor colorWithRed:0.203f green:0.478f blue:0.278f alpha:1.0f]
#define WACOM_PURPLE        [UIColor colorWithRed:0.419f green:0.278f blue:0.454f alpha:1.0f]

/**
 *  @brief Simple enum to allow us to identify which button has been tapped
 */
typedef enum : NSUInteger {
    BLACK,
    DARK_GREY,
    LIGHT_GREY,
    BLUE,
    RED,
    GREEN,
    PURPLE
} BUTTON_COLOUR;

/**
 *  @brief Simple enum defining toolbar button types
 */
typedef enum : NSUInteger {
    OPEN_BUTTON = 0,
    CAPTURE_BUTTON,
    IMAGE_BUTTON,
    SAVE_BUTTON,
    DELETE_BUTTON,
    SETTINGS_BUTTON,
    VALIDATE_BUTTON,
    ATTACHMENT_BUTTON,
    ABOUT_BUTTON
} TOOLBAR_BUTTONS;

static NSString *TOOLBAR_REUSE_ID = @"TOOLBARCELL";