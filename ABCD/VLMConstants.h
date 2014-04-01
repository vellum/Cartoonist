//
//  VLMConstants.h
//  Cartoonist
//
//  Created by David Lu on 12/21/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//
//#define PRESENT_TOUCHES 1

#define CHOICE_SCALE       0.9f
#define ZOOM_DURATION      0.325f
#define ZOOM_OPTIONS       UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut

#define GENERIC_DURATION   0.325f
#define GENERIC_OPTIONS    UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut

#define ROT_DURATION   0.5f
#define ROT_OPTIONS    UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
#define ROT_OPTIONS_OUT UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
#define ROT_OPTIONS_IN UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut

#define DEAD_ZONE          CGSizeMake(10.0f, 10.0f)
#define FUCKING_UNKNOWN    0
#define FUCKING_VERTICAL   1
#define FUCKING_HORIZONTAL 2

// Mixed Case, Legible but not quite heavy enough
/*
 
#define FONT_CAPTION [UIFont fontWithName:@"Architect-Bold" size:20.0f]
#define USE_ALL_CAPS NO
#define FONT_LINE_SPACING 0.0f
#define FONT_WIREFRAME [UIFont fontWithName:@"Architect-Bold" size:24.0f]
 */

#define FONT_CAPTION [UIFont fontWithName:@"Architect-Regular" size:20.0f]
#define USE_ALL_CAPS NO
#define FONT_LINE_SPACING 0.0f
#define FONT_WIREFRAME [UIFont fontWithName:@"Architect-Regular" size:24.0f]

#define kItemSize          [VLMCollectionViewCell idealItemSize]
#define kItemPadding       [VLMCollectionViewCell itemPadding]

#define kItemPaddingIphone  9.0f
#define kItemPaddingIpad    18.0f

// fill screen
#define kItemSizeIphone    CGSizeMake(320, 568.0f - 2.0f * (9.0f + 9.0f) + 9.0f)
#define kItemSizeIpad      CGSizeMake(768.0f, 1024.0f - 2.0f * (18.0f + 18.0f) + 18.0f)

// square items
//#define kItemSizeIphone    CGSizeMake(320, 320.0f - 2.0f * (4.5f))
//#define kItemSizeIpad      CGSizeMake(768.0f, 768.0f - 2.0f * (9.0f))

// fill screen iphone, square items ipad
//#define kItemSizeIphone    CGSizeMake(320, 568.0f - 2.0f * (9.0f + 9.0f) + 9.0f)
//#define kItemSizeIpad      CGSizeMake(768.0f, 768.0f - 2.0f * (9.0f))


#define SPINNER_STYLE UIActivityIndicatorViewStyleGray
#define SPINNER_BACKGROUND_COLOR [UIColor colorWithWhite:1.0f alpha:0.8f]
#define SPINNER_DIAMETER 40.0f
