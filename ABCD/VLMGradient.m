//
//  VLMGradient.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMGradient.h"
#import "VLMConstants.h"

@interface VLMGradient ()
@property (nonatomic, strong) UILabel *current;
@property (nonatomic, strong) UILabel *next;
@property CGFloat restoreAlphaCurrent;
@property CGFloat restoreAlphaNext;
@end

@implementation VLMGradient
@synthesize current;
@synthesize next;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setUserInteractionEnabled:NO];
		[self setBackgroundColor:[UIColor clearColor]];

		CGFloat pad = 30.0f;
		[self setCurrent:[[UILabel alloc] initWithFrame:CGRectMake(pad, 50 + pad, 320 - pad * 2, 100)]];
		[self.current setText:@""];
		[self.current setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
		[self.current setTextColor:[UIColor whiteColor]];
		[self.current setTextAlignment:NSTextAlignmentCenter];
		[self.current setAdjustsFontSizeToFitWidth:YES];
		[self.current setNumberOfLines:3.0f];
		[self addSubview:self.current];

		[self setNext:[[UILabel alloc] initWithFrame:CGRectMake(pad, 50 + pad, 320 - pad * 2, 100)]];
		[self.next setText:@""];
		[self.next setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
		[self.next setTextColor:[UIColor whiteColor]];
		[self.next setTextAlignment:NSTextAlignmentCenter];
		[self.next setAlpha:0.0f];
		[self.next setAdjustsFontSizeToFitWidth:YES];
		[self.next setNumberOfLines:3.0f];
		[self addSubview:self.next];
	}
	return self;
}

- (void)drawRect:(CGRect)rect
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();

	NSArray *gradientColors = [NSArray arrayWithObjects:(id) [UIColor clearColor].CGColor, [UIColor colorWithWhite:0.0f alpha:0.9f].CGColor, nil];

	CGFloat gradientLocations[] = { 0, 0.3 };
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);

	CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));

	CGContextDrawRadialGradient(context, gradient, midPoint, 0, midPoint, rect.size.height * 2.0f, kCGGradientDrawsAfterEndLocation);

	CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

- (void)setAlpha:(CGFloat)alpha
{
	[self.current setAlpha:alpha];
	[self.next setAlpha:0];
	[super setAlpha:alpha];
}

- (void)setText:(NSString *)text
{
	[self.next setText:text];

	// fade up next
	// fade down cur
	// oncomplete: cur -> next, next->cur

	[UIView animateWithDuration:GENERIC_DURATION
						  delay:0.0f
						options:GENERIC_OPTIONS
					 animations:^{
		 [self.current setAlpha:0.0f];
		 [self.next setAlpha:1.0f];
	 }

					 completion:^(BOOL completed) {
		 UILabel *temp = self.current;
		 [self setCurrent:self.next];
		 [self setNext:temp];
	 }

	];
}

- (void)setTextNoAnimation:(NSString *)text
{
	[self.next setText:text];
	[self.current setText:text];
}

- (void)setAlpha:(CGFloat)alpha forText:(NSString *)text andAlpha:(CGFloat)alpha2 forText2:(NSString *)text2
{
	[self.next setText:text];
	[self.next setAlpha:alpha];

	[self.current setText:text2];
	[self.current setAlpha:alpha2];
}

- (void)hide
{
	self.restoreAlphaCurrent = self.current.alpha;
	self.restoreAlphaNext = self.next.alpha;

	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
		 [self setAlpha:0.0f];
		 [self.next setAlpha:0.0f];
		 [self.current setAlpha:0.0f];
	 }

					 completion:^(BOOL completed) {
	 }

	];
}

- (void)show
{
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
		 [self setAlpha:1.0f];
		 [self.next setAlpha:self.restoreAlphaNext];
		 [self.current setAlpha:self.restoreAlphaCurrent];
	 }

					 completion:^(BOOL completed) {
	 }

	];
}

@end