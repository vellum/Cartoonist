//
//  VLMNarrationCaption.h
//  Cartoonist
//
//  Created by David Lu on 12/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLMCollectionViewLayoutAttributes;

@interface VLMNarrationCaption : UIView
- (void)setup;
- (void)transitionAtValue:(CGFloat)value;
- (void)applyLayoutAttributes:(VLMCollectionViewLayoutAttributes*)attributes;
- (void)setText:(NSString *)text;
- (void)setAttributedText:(NSAttributedString *)text;
@end
