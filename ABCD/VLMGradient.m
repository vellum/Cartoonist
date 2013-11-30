//
//  VLMGradient.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMGradient.h"

@interface VLMGradient()
@property (nonatomic,strong) UILabel *label;
@end

@implementation VLMGradient
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];
        [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 100)]];
        [self.label setText:@"something"];
        [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
        [self.label setTextColor:[UIColor whiteColor]];
        [self.label setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.label];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSArray *gradientColors = [NSArray arrayWithObjects:(id) [UIColor clearColor].CGColor, [UIColor blackColor].CGColor, nil];
    
    CGFloat gradientLocations[] = {0, 0.75, 1};
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, gradientLocations);
    
    CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGContextDrawRadialGradient(context, gradient, midPoint, 0, midPoint, rect.size.height*2.0f, kCGGradientDrawsAfterEndLocation);
    
    //CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    //CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    //CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
}

- (void)setAlpha:(CGFloat)alpha{
    [self.label setAlpha:alpha];
    [super setAlpha:alpha];
}
@end
