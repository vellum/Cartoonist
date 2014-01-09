//
//  VLMSpinner.h
//  Cartoonist
//
//  Created by David Lu on 1/6/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMSpinner : UIView

- (void)hide;
- (void)show;
- (void)hideWithDelay:(CGFloat)delay;
- (BOOL)isSpinning;

@end
