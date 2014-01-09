//
//  VLMSpinner.m
//  Cartoonist
//
//  Created by David Lu on 1/6/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "VLMSpinner.h"
#include "VLMConstants.h"


@interface VLMSpinner ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation VLMSpinner

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:SPINNER_STYLE];
        [self.spinner setCenter:CGPointMake(frame.size.width/2.0f, frame.size.height/2.0f)];
        [self addSubview:self.spinner];
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:SPINNER_BACKGROUND_COLOR];
        [self.layer setCornerRadius:frame.size.width/2.0f];
        [self.layer setMasksToBounds:YES];
        [self setAlpha:0.0f];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)hide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:0.0f];
                     }
     
					 completion:^(BOOL completed) {
                         [self.spinner stopAnimating];
                     }
     
     ];
}

- (void)show
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.spinner startAnimating];
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:1.0f];
                     }
     
					 completion:^(BOOL completed) {
                         //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
                         //[self performSelector:@selector(hide) withObject:nil afterDelay:1.0f];
                     }
     
     ];
}

- (void)hideWithDelay:(CGFloat)delay{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(hide) withObject:nil afterDelay:delay];
    
}

- (BOOL)isSpinning
{
    return self.spinner.isAnimating;
}

@end
