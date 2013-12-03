//
//  VLMGradient.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMGradient.h"

@interface VLMGradient()
@property (nonatomic,strong) UILabel *current;
@property (nonatomic,strong) UILabel *next;
@end

@implementation VLMGradient
@synthesize current;
@synthesize next;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInteractionEnabled:NO];
        [self setBackgroundColor:[UIColor clearColor]];

        [self setCurrent:[[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 100)]];
        [self.current setText:@""];
        [self.current setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
        [self.current setTextColor:[UIColor whiteColor]];
        [self.current setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.current];

        [self setNext:[[UILabel alloc] initWithFrame:CGRectMake(0, 50, 320, 100)]];
        [self.next setText:@""];
        [self.next setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
        [self.next setTextColor:[UIColor whiteColor]];
        [self.next setTextAlignment:NSTextAlignmentCenter];
        [self.next setAlpha:0.0f];
        [self addSubview:self.next];
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
    
    CGGradientRelease(gradient);
}

- (void)setAlpha:(CGFloat)alpha
{
    [self.current setAlpha:alpha];
    [super setAlpha:alpha];
}

- (void)setText:(NSString *)text
{
    [self.next setText:text];
    
    // fade up next
    // fade down cur
    // oncomplete: cur -> next, next->cur
    
    [UIView animateWithDuration:0.4f
        delay:0.0f
        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseInOut
        animations:^{
            [self.current setAlpha:0.0f];
            [self.next setAlpha:1.0f];
        }
        completion:^(BOOL completed){
            UILabel *temp = self.current;
            [self setCurrent:self.next];
            [self setNext:temp];
        }
     ];
    
}

@end
