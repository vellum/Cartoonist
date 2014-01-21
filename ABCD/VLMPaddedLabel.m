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
        self.padding = 10.0f;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIEdgeInsets insets = {0, self.padding, 0, self.padding};
    return [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

@end
