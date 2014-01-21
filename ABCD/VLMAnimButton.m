//
//  VLMAnimButton.m
//  Cartoonist
//
//  Created by David Lu on 1/8/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMAnimButton.h"
#import "VLMConstants.h"

@implementation VLMAnimButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)hide
{
    [self setUserInteractionEnabled:NO];
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:0.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

- (void)show
{
    [self setUserInteractionEnabled:YES];
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:ZOOM_DURATION/2.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:1.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

- (void)setAlpha:(CGFloat)alpha
{
    [super setAlpha:alpha];
    
    if (alpha>0.5f) {
        [self setUserInteractionEnabled:YES];
    } else {
        [self setUserInteractionEnabled:NO];
    }
}
@end
