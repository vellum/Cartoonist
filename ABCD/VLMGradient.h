//
//  VLMGradient.h
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef BOOL (^CheckOverviewBlock)();

@interface VLMGradient : UIView

@property (nonatomic, copy) CheckOverviewBlock checkOverviewBlock;
@property (nonatomic) UIDeviceOrientation orientation;

- (void)setText:(NSString *)text;
- (void)setAlpha:(CGFloat)alpha withLabelsHidden:(BOOL)shouldHideLabels;
- (void)setAlpha:(CGFloat)alpha forText:(NSString *)text andAlpha:(CGFloat)alpha2 forText2:(NSString *)text2;
- (void)hide;
- (void)show;
- (void)setTextNoAnimation:(NSString *)text;
- (void)hideText;
- (void)showBaseWithTextHidden;
- (void)hideTextNoAnimation;
- (void)setScrollIndicatorPositionAsPercent:(CGFloat)pctPos heightAsPercent:(CGFloat)pctHeight shouldFlash:(BOOL)shouldFlash;
- (void)flashScrollIndicator;

@end