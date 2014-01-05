//
//  VLMPaddedLabel.m
//  Cartoonist
//
//  Created by David Lu on 1/5/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMPaddedLabel.h"

@implementation VLMPaddedLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, 10, 0, 10};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
