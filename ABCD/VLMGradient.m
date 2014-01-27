//
//  VLMGradient.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMGradient.h"
#import "VLMConstants.h"
#import "VLMCollectionViewCell.h"

@interface VLMGradient ()
@property (nonatomic, strong) UILabel *current;
@property (nonatomic, strong) UILabel *next;
@property CGFloat restoreAlphaCurrent;
@property CGFloat restoreAlphaNext;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UIView *scrollIndicator;
@property CGPoint portraitHeaderPos;
@property CGPoint portraitLabelPos;
@end

@implementation VLMGradient

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setUserInteractionEnabled:NO];
		[self setBackgroundColor:[UIColor clearColor]];
        
        if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
        {
            CGFloat padx = 24.0f;
            CGFloat pady = 48.0f;
            [self setCurrent:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, frame.size.width - padx * 2, 60)]];
            [self.current setText:@""];
            [self.current setFont:[UIFont fontWithName:@"Helvetica-Bold" size:28.0f]];
            [self.current setTextColor:[UIColor whiteColor]];
            [self.current setTextAlignment:NSTextAlignmentCenter];
            //[self.current setAdjustsFontSizeToFitWidth:YES];
            [self.current setNumberOfLines:2.0f];
            [self addSubview:self.current];
            
            [self setNext:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, frame.size.width - padx * 2, 60)]];
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
            
            self.portraitHeaderPos = self.heading.center;
            self.portraitLabelPos = self.current.center;
         
        }
        else
        {
            CGFloat padx = 24.0f;
            CGFloat pady = 120.0f;
            [self setCurrent:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, frame.size.width - padx * 2, 60)]];
            [self.current setText:@""];
            [self.current setFont:[UIFont fontWithName:@"Helvetica-Bold" size:48.0f]];
            [self.current setTextColor:[UIColor whiteColor]];
            [self.current setTextAlignment:NSTextAlignmentCenter];
            //[self.current setAdjustsFontSizeToFitWidth:YES];
            [self.current setNumberOfLines:2.0f];
            [self addSubview:self.current];
            
            [self setNext:[[UILabel alloc] initWithFrame:CGRectMake(padx, 50 + pady, frame.size.width - padx * 2, 60)]];
            [self.next setText:@""];
            [self.next setFont:[UIFont fontWithName:@"Helvetica-Bold" size:48.0f]];
            [self.next setTextColor:[UIColor whiteColor]];
            [self.next setTextAlignment:NSTextAlignmentCenter];
            [self.next setAlpha:0.0f];
            //[self.next setAdjustsFontSizeToFitWidth:YES];
            [self.next setNumberOfLines:2.0f];
            [self addSubview:self.next];
            
            [self setHeading:[[UILabel alloc] initWithFrame:CGRectMake(self.current.frame.origin.x, self.current.frame.origin.y - 12.0f, self.current.frame.size.width, 12.0f)]];
            [self.heading setText:@"a story branch"];
            [self.heading setFont:[UIFont fontWithName:@"Helvetica-Bold" size:12.0f]];
            [self.heading setTextColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
            [self.heading setTextAlignment:NSTextAlignmentCenter];
            [self addSubview:self.heading];
            [self.heading setAlpha:0.0f];
            
            self.portraitHeaderPos = self.heading.center;
            self.portraitLabelPos = self.current.center;

            
        }
	}
    [self setScrollIndicator:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.scrollIndicator setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.5f]];
    [self addSubview:self.scrollIndicator];
    [self.scrollIndicator setAlpha:0.0f];

    
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


- (void)setAlpha:(CGFloat)alpha withLabelsHidden:(BOOL)shouldHideLabels
{
    if (shouldHideLabels) {
        [self.heading setAlpha:0.0f];
        [self.current setAlpha:0.0f];
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
                     }
					 completion:^(BOOL completed) {
                     }

	];
}

- (void)hideText
{
    //NSLog(@"hidetext");
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

- (void)hideTextNoAnimation
{
    [self.next setAlpha:0.0f];
    [self.current setAlpha:0.0f];
    [self.heading setAlpha:0.0f];
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

- (void)setScrollIndicatorPositionAsPercent:(CGFloat)pctPos heightAsPercent:(CGFloat)pctHeight  shouldFlash:(BOOL)shouldFlash
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(1.0f, 0.0f, 1.0f, 0.0f);
    CGFloat frameHeight = self.frame.size.height - edgeInsets.top - edgeInsets.bottom;
    CGSize size = CGSizeMake(/*kItemPadding*0.25f*/2.0f, frameHeight * pctHeight);
    if (pctPos<0) {
        size.height *= 1+pctPos*25.0f;
    } else if (pctPos>1){
        size.height *= 1-(pctPos-1)*25.0f;
    }
    CGPoint pos = CGPointMake(self.frame.size.width-size.width-edgeInsets.right, edgeInsets.top + pctPos * (frameHeight-size.height));
    
    /*
    if (UIDeviceOrientationIsLandscape(self.orientation))
    {
        pos.x = edgeInsets.left;
    }
    */
    
    if (pos.y < edgeInsets.top) {
        pos.y = edgeInsets.top;
    } else if (pos.y > self.frame.size.height - edgeInsets.bottom - size.height ) {
        pos.y = self.frame.size.height - edgeInsets.bottom - size.height;
    }
    
    
    [self.scrollIndicator setFrame:CGRectMake(pos.x, pos.y, size.width, size.height)];
    if (shouldFlash) {
        [self flashScrollIndicator];
    }
    
    
}

- (void)flashScrollIndicator
{
    [UIView animateWithDuration:ZOOM_DURATION
                          delay:0.0f
                        options:ZOOM_OPTIONS
                     animations:^{
                         [self.scrollIndicator setAlpha:1.0f];
                     }
                     completion:^(BOOL completed) {
                     }
     ];
    [UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideScrollIndicator) object:nil];
    [self performSelector:@selector(hideScrollIndicator) withObject:nil afterDelay:ZOOM_DURATION*1.5f];

}

- (void)hideScrollIndicator
{
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.scrollIndicator setAlpha:0.0f];
                     }
					 completion:^(BOOL completed) {
                     }
     ];
}

- (void)setOrientation:(UIDeviceOrientation)orientation
{
    _orientation = orientation;
    
    if (UIDeviceOrientationIsPortrait(orientation)) {
        
        self.current.transform = CGAffineTransformMakeRotation(0.0f);
        self.next.transform = CGAffineTransformMakeRotation(0.0f);
        self.heading.transform = CGAffineTransformMakeRotation(0.0f);
        
        self.heading.center = self.portraitHeaderPos;
        self.current.center = self.portraitLabelPos;
        self.next.center = self.current.center;

        [self.heading setTextAlignment:NSTextAlignmentCenter];
        [self.current setTextAlignment:NSTextAlignmentCenter];
        [self.next setTextAlignment:NSTextAlignmentCenter];

        
        
    } else {
        self.current.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
        self.next.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
        self.heading.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
        
        if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
        {
            self.current.center = CGPointMake(self.frame.size.width*(1-0.25f), self.frame.size.height/2.0f - self.current.frame.size.width*1.25);
            self.heading.center = CGPointMake(self.current.center.x + 28, self.current.center.y);
            self.next.center = self.current.center;
            
            [self.heading setTextAlignment:NSTextAlignmentLeft];
            [self.current setTextAlignment:NSTextAlignmentLeft];
            [self.next setTextAlignment:NSTextAlignmentLeft];

        }
        else
        {
            self.current.center = CGPointMake(self.frame.size.width*(1-self.portraitLabelPos.y/self.frame.size.height), self.frame.size.height/2.0f);
            self.next.center = self.current.center;
            self.heading.center = CGPointMake(self.current.center.x + 36, self.frame.size.height/2.0f);
        }
    }

    /*
    [UIView animateWithDuration:ROT_DURATION*0.25f
						  delay:0.0f
						options:ROT_OPTIONS_OUT
					 animations:^{
                         self.current.alpha = 0.0f;
                         self.next.alpha = 0.0f;
                         self.heading.alpha = 0.0f;
                     }
					 completion:^(BOOL completed) {
                         if (UIDeviceOrientationIsPortrait(orientation)) {
     
                             self.current.transform = CGAffineTransformMakeRotation(0.0f);
                             self.next.transform = CGAffineTransformMakeRotation(0.0f);
                             self.heading.transform = CGAffineTransformMakeRotation(0.0f);
                             
                             self.heading.center = self.portraitHeaderPos;
                             self.current.center = self.portraitLabelPos;
                             self.next.center = self.current.center;
                             
                         } else {
                             self.current.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
                             self.next.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
                             self.heading.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
                             
                             if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
                             {
                                 self.current.center = CGPointMake(self.frame.size.width*(1-0.3f), self.frame.size.height/2.0f);
                                 self.heading.center = CGPointMake(self.current.center.x + 28, self.frame.size.height/2.0f);
                                 self.next.center = self.current.center;
                             }
                             else
                             {
                                 self.current.center = CGPointMake(self.frame.size.width*(1-self.portraitLabelPos.y/self.frame.size.height), self.frame.size.height/2.0f);
                                 self.next.center = self.current.center;
                                 self.heading.center = CGPointMake(self.current.center.x + 36, self.frame.size.height/2.0f);
                             }
                         }
                         
                         [UIView animateWithDuration:ROT_DURATION*0.25f delay:ROT_DURATION*0.25f options:ROT_OPTIONS_IN animations:^{
                             self.current.alpha = 1.0f;
                             self.next.alpha = 1.0f;
                             self.heading.alpha = 1.0f;

                         } completion:^(BOOL completed){}];
                     }
     ];*/
}

@end