//
//  VLMConstants.h
//  Cartoonist
//
//  Created by David Lu on 12/21/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#define CHOICE_SCALE       0.9f
#define ZOOM_DURATION      0.325f
#define ZOOM_OPTIONS       UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut

#define GENERIC_DURATION   0.325f
#define GENERIC_OPTIONS    UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut

#define DEAD_ZONE          CGSizeMake(10.0f, 10.0f)
#define FUCKING_UNKNOWN    0
#define FUCKING_VERTICAL   1
#define FUCKING_HORIZONTAL 2

#define FONT_WIREFRAME [UIFont fontWithName:@"Draftsman" size:14.0f]
#define USE_ALL_CAPS YES
#define FONT_LINE_SPACING 6.0f
//#define FONT_WIREFRAME [UIFont fontWithName:@"Architect_Regular" size:18.0f]
//#define USE_ALL_CAPS NO

#define kItemPadding       9.0f
#define kItemPaddingBottom 9.0f
#define kItemSize          [VLMCollectionViewCell idealItemSize]
#define kItemSizeIphone    CGSizeMake(320, 568.0f - 2.0f * (9.0f + 9.0f))
#define kItemSizeIpad      CGSizeMake(768.0f, 1024.0f - 2.0f * (9.0f + 9.0f))
