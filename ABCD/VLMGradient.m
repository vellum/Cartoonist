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
@property (nonatomic, strong) UILabel *heading;
@end

@implementation VLMGradient

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setUserInteractionEnabled:NO];
		[self setBackgroundColor:[UIColor clearColor]];

		CGFloat padx = 24.0f;
		CGFloat pady = 48.0f;
		[self setCurrent:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, 320 - padx * 2, 60)]];
		[self.current setText:@""];
		[self.current setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28.0f]];
		[self.current setTextColor:[UIColor whiteColor]];
		[self.current setTextAlignment:NSTextAlignmentCenter];
		//[self.current setAdjustsFontSizeToFitWidth:YES];
		[self.current setNumberOfLines:2.0f];
		[self addSubview:self.current];

		[self setNext:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, 320 - padx * 2, 60)]];
		[self.next setText:@""];
		[self.next setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28.0f]];
		[self.next setTextColor:[UIColor whiteColor]];
		[self.next setTextAlignment:NSTextAlignmentCenter];
		[self.next setAlpha:0.0f];
		//[self.next setAdjustsFontSizeToFitWidth:YES];
		[self.next setNumberOfLines:2.0f];
		[self addSubview:self.next];
        
        [self setHeading:[[UILabel alloc] initWithFrame:CGRectMake(self.current.frame.origin.x, self.current.frame.origin.y - 6.0f, self.current.frame.size.width, 12.0f)]];
        [self.heading setText:@"a story branch"];
        [self.heading setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10.0f]];
        [self.heading setTextColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
        [self.heading setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:self.heading];
        [self.heading setAlpha:0.0f];

        //[self.current setBackgroundColor:[UIColor blackColor]];
        //[self.next setBackgroundColor:[UIColor blackColor]];
        
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
    //NSLog(@"setalpha");
    BOOL isOverview = NO;
    if (self.checkOverviewBlock) {
        isOverview = self.checkOverviewBlock();
        [self.heading setAlpha:0.0f];
        [self.current setAlpha:0.0f];
        [self.next setAlpha:0.0f];
    }
    if (!isOverview) {
        [self.heading setAlpha:alpha];
        [self.current setAlpha:alpha];
        [self.next setAlpha:0.0f];
    }
	[super setAlpha:alpha];
}

- (void)setText:(NSString *)text
{
    //NSLog(@"settext");
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
         [self.heading setAlpha:1.0f];
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
    //NSLog(@"settextnoanimation");
	[self.next setText:text];
	[self.current setText:text];
}

- (void)setAlpha:(CGFloat)alpha forText:(NSString *)text andAlpha:(CGFloat)alpha2 forText2:(NSString *)text2
{
    //NSLog(@"setalphafortextandalphafortext2");

	[self.next setText:text];
	[self.next setAlpha:alpha];

	[self.current setText:text2];
	[self.current setAlpha:alpha2];
    
}

- (void)hide
{
    //NSLog(@"hide");

	self.restoreAlphaCurrent = self.current.alpha;
	self.restoreAlphaNext = self.next.alpha;

	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
		 [self setAlpha:0.0f];
		 [self.next setAlpha:0.0f];
		 [self.current setAlpha:0.0f];
         [self.heading setAlpha:0.0f];
	 }

					 completion:^(BOOL completed) {
	 }

	];
}

- (void)show
{
    //NSLog(@"show");

    if (self.restoreAlphaCurrent == 0.0f) {
        self.restoreAlphaCurrent = 1.0f;
        self.restoreAlphaNext = 0.0f;
    }
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
		 [self setAlpha:1.0f];
		 [self.next setAlpha:self.restoreAlphaNext];
		 [self.current setAlpha:self.restoreAlphaCurrent];
         [self.heading setAlpha:self.restoreAlphaCurrent];

                         /*
                         [self.next setAlpha:1.0f];
                         [self.current setAlpha:0.0f];
                         
                         if ([self.next.text length]==0) {
                             [self.heading setAlpha:0.0f];
                         } else {
                             [self.heading setAlpha:1.0f];
                         }
                          */
                         
	 }

					 completion:^(BOOL completed) {
                         
	 }

	];
}

- (void)hideText
{
    //NSLog(@"hidetext");
	//self.restoreAlphaCurrent = self.current.alpha;
	//self.restoreAlphaNext = self.next.alpha;
    
	[UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.next setAlpha:0.0f];
                         [self.current setAlpha:0.0f];
                         [self.heading setAlpha:0.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

- (void)showBaseWithTextHidden
{
    //NSLog(@"showbasewithtexthidden");
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.next setAlpha:0.0f];
                         [self.current setAlpha:0.0f];
                         [self.heading setAlpha:0.0f];
                         [self setAlpha:1.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

@end