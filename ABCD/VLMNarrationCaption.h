//
//  VLMNarrationCaption.h
//  Cartoonist
//
//  Created by David Lu on 12/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMNarrationCaption : UIView
- (void)setup;
- (void)transitionAtValue:(CGFloat)value;
- (void)setText:(NSString *)text;
- (void)setAttributedText:(NSAttributedString *)text;
@end
