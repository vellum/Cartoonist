//
//  VLMGradient.h
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMGradient : UIView
- (void)setText:(NSString *)text;
- (void)setAlpha:(CGFloat)alpha forText:(NSString *)text andAlpha:(CGFloat)alpha2 forText2:(NSString *)text2;
@end
