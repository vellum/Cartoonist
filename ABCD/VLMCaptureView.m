//
//  VLMCaptureView.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCaptureView.h"
#import "VLMConstants.h"

@interface VLMCaptureView ()
@property (nonatomic, strong) UIPanGestureRecognizer *topLevelPanGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *horizontalPanGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *verticalPanGestureRecognizer;

@property NSInteger recognizedDirection;
@property BOOL shouldRecognizeHorizontalPans;
@end

@implementation VLMCaptureView
@synthesize topLevelPanGestureRecognizer;
@synthesize horizontalPanGestureRecognizer;
@synthesize verticalPanGestureRecognizer;
@synthesize recognizedDirection;
@synthesize shouldRecognizeHorizontalPans;
@synthesize checkOverviewBlock;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
		[self setTopLevelPanGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTopLevelPans:)]];
		[self.topLevelPanGestureRecognizer setMaximumNumberOfTouches:1];
		[self.topLevelPanGestureRecognizer setMinimumNumberOfTouches:1];
		[self.topLevelPanGestureRecognizer setDelegate:self];
		[self addGestureRecognizer:self.topLevelPanGestureRecognizer];
		[self setRecognizedDirection:FUCKING_UNKNOWN];
		
        //[self setShouldRecognizeHorizontalPans:YES];
        [self enableHorizontalPan:NO];

		UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [pinch requireGestureRecognizerToFail:self.topLevelPanGestureRecognizer];
		[self addGestureRecognizer:pinch];
        [pinch setDelegate:self];
	}
	return self;
}

#pragma mark - ()

- (void)handlePinch:(UIPinchGestureRecognizer *)pgr
{
	BOOL ended = NO;
	switch (pgr.state)
	{
        case UIGestureRecognizerStateBegan:
        [self.topLevelPanGestureRecognizer setEnabled:NO];
        [self.topLevelPanGestureRecognizer setEnabled:YES];
        if (self.verticalPanGestureRecognizer) {
            [self.verticalPanGestureRecognizer setEnabled:NO];
            [self.verticalPanGestureRecognizer setEnabled:YES];
        }
        if (self.horizontalPanGestureRecognizer) {
            [self.horizontalPanGestureRecognizer setEnabled:NO];
            [self.horizontalPanGestureRecognizer setEnabled:YES];
        }
        
            break;
		case UIGestureRecognizerStateEnded :
		case UIGestureRecognizerStateCancelled :
			ended = YES;
			break;
		default :
			break;
	}
    /*
    // this code forces the pinch gesture to end when a threshold is reached
	CGFloat threshold = 1;                                                                                                                                                                                                                                                                            // 0.125f;
	if ([pgr scale] < 1 - threshold || [pgr scale] > 1 + threshold)
	{
		//[pgr setEnabled:NO];
		//[pgr setEnabled:YES];
		//ended = YES;
	}
     */
	if (self.zoomPageBlock)
	{
		self.zoomPageBlock([pgr scale], [pgr velocity], ended);
	}
}

- (void)handleTopLevelPans:(UIPanGestureRecognizer *)pgr
{
    BOOL isZoomOverview = NO;
    if (self.checkOverviewBlock) {
        isZoomOverview = self.checkOverviewBlock();
    }
    
	switch (pgr.state)
	{
		// when the pan starts or ends, make sure we reset the state
		case UIGestureRecognizerStateBegan :        
			[self setRecognizedDirection:FUCKING_UNKNOWN];
			if (self.horizontalPanGestureRecognizer && !self.horizontalPanGestureRecognizer.enabled)
			{
				[self.horizontalPanGestureRecognizer setEnabled:YES];
			}
			if (self.verticalPanGestureRecognizer && !self.verticalPanGestureRecognizer.enabled)
			{
				[self.verticalPanGestureRecognizer setEnabled:YES];
			}
			[self setRecognizedDirection:FUCKING_UNKNOWN];
			break;
		case UIGestureRecognizerStateChanged :
			//NSLog(@"ch");
			break;
		case UIGestureRecognizerStateEnded :
			//NSLog(@"end");
			break;
		case UIGestureRecognizerStateCancelled :
			//NSLog(@"cancel");
			break;
		case UIGestureRecognizerStateFailed :
			//NSLog(@"failed");
			break;
		default :
			break;
	}                                 // end switch

	if (self.recognizedDirection == FUCKING_UNKNOWN)
	{
		// accumulated translation from start point
		CGPoint p = [pgr translationInView:self];

		// establish a deadzone of 50 x 24
		// this is a generous allowance for which we ignore wiggly movement
		CGSize deadzone = DEAD_ZONE;

		// vertical pans will cancel this gesture recognizer
		// and let the scrollview's recognizer to take over
		if (!self.shouldRecognizeHorizontalPans || p.y > deadzone.height / 2 || p.y < -deadzone.height / 2)
		{
			// set the recognized direction
			[self setRecognizedDirection:FUCKING_VERTICAL];

			// cancel the recognizer and restart it for capturing the next pan
			// the current pan will continue, but the scrollview will handle it
			[self.topLevelPanGestureRecognizer setEnabled:NO];
			[self.topLevelPanGestureRecognizer setEnabled:YES];
            
            // set vertical pan gesture recognizer's translation value to zero
			// this means that we scroll based on fresh data (not accumulated translation data)
			if (self.verticalPanGestureRecognizer)
			{
                //commenting out as it seems to sometimes causes the gesture recco to fail
				//[self.verticalPanGestureRecognizer setTranslation:CGPointZero inView:self];
			}

			// reset the horizontal pan gesture recognizer
			if (self.horizontalPanGestureRecognizer)
			{
				[self.horizontalPanGestureRecognizer setEnabled:NO];
				[self.horizontalPanGestureRecognizer setEnabled:YES];
			}

			// a little debugging
			 NSLog(@"recognized vertical pan");
		}
		else if (!isZoomOverview && (p.x > deadzone.width / 2 || p.x < -deadzone.width / 2))
		{
			[self setRecognizedDirection:FUCKING_HORIZONTAL];

			// cancel the recognizer and restart it for capturing the next pan
			// the current pan will continue, but the scrollview will handle it
			[self.topLevelPanGestureRecognizer setEnabled:NO];
			[self.topLevelPanGestureRecognizer setEnabled:YES];
            
			// horizontal pan resets the translation point
			// so that translationinview: reports a delta from last event
			if (self.horizontalPanGestureRecognizer)
			{
                //commenting out as it seems to sometimes causes the gesture recco to fail
				//[self.horizontalPanGestureRecognizer setTranslation:CGPointZero inView:self];

				if (!self.shouldRecognizeHorizontalPans)
				{
					[self.horizontalPanGestureRecognizer setEnabled:NO];
					[self.horizontalPanGestureRecognizer setEnabled:YES];
				}
			}

			// reset the vertical gesture recognizer
			if (self.verticalPanGestureRecognizer)
			{
				[self.verticalPanGestureRecognizer setEnabled:NO];
				[self.verticalPanGestureRecognizer setEnabled:YES];
			}

			 NSLog(@"recognized horizontal pan");
		}
	}
	else
	{
	}
}

- (void)addHorizontalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
	// if exists, check if we're trying to add a pgr we already know about
	if (self.horizontalPanGestureRecognizer)
	{
		// if so, return
		if (self.horizontalPanGestureRecognizer == panGestureRecognizer)
		{
			return;
		}
		// otherwise, unhook this and forget about it
		[self removeGestureRecognizer:self.horizontalPanGestureRecognizer];
		[self setHorizontalPanGestureRecognizer:nil];
	}
	// add & configure
	[self addGestureRecognizer:panGestureRecognizer];
	[self setHorizontalPanGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer requireGestureRecognizerToFail:self.topLevelPanGestureRecognizer];
	[panGestureRecognizer setEnabled:YES];
}

- (void)addVerticalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
	// if exists, forget we know anything (unlikely because there will only ever be one)
	if (self.verticalPanGestureRecognizer)
	{
		[self removeGestureRecognizer:self.verticalPanGestureRecognizer];
		[self setVerticalPanGestureRecognizer:Nil];
	}
	// add & configure
	[self addGestureRecognizer:panGestureRecognizer];
	[self setVerticalPanGestureRecognizer:panGestureRecognizer];
	[panGestureRecognizer requireGestureRecognizerToFail:self.topLevelPanGestureRecognizer];
	[panGestureRecognizer setEnabled:YES];
}

- (void)removeAnyHorizontalGestureRecognizers
{
	if (self.horizontalPanGestureRecognizer)
	{
		[self.horizontalPanGestureRecognizer setEnabled:NO];
		[self removeGestureRecognizer:self.horizontalPanGestureRecognizer];
		[self setHorizontalPanGestureRecognizer:nil];
	}
}

- (void)enableHorizontalPan:(BOOL)shouldEnable
{
	[self setShouldRecognizeHorizontalPans:shouldEnable];
	if (shouldEnable)
	{
		[self.topLevelPanGestureRecognizer setEnabled:NO];
		[self.topLevelPanGestureRecognizer setEnabled:YES];
		if (self.horizontalPanGestureRecognizer)
		{
			[self.horizontalPanGestureRecognizer setEnabled:YES];
			if (![self.gestureRecognizers containsObject:self.horizontalPanGestureRecognizer])
			{
				[self addGestureRecognizer:self.horizontalPanGestureRecognizer];
			}
		}
	}
	else
	{
		[self.topLevelPanGestureRecognizer setEnabled:NO];
		if (self.horizontalPanGestureRecognizer)
		{
			[self.horizontalPanGestureRecognizer setEnabled:NO];
			if ([self.gestureRecognizers containsObject:self.horizontalPanGestureRecognizer])
			{
				[self removeGestureRecognizer:self.horizontalPanGestureRecognizer];
			}
		}
	}
}
- (void)resetHGR
{
    [self.topLevelPanGestureRecognizer setEnabled:NO];
    [self.topLevelPanGestureRecognizer setEnabled:YES];
    if (self.horizontalPanGestureRecognizer)
    {
        [self.horizontalPanGestureRecognizer setEnabled:NO];
        [self.horizontalPanGestureRecognizer setEnabled:YES];
        [self.horizontalPanGestureRecognizer setEnabled:NO];
        [self removeAnyHorizontalGestureRecognizers];
    }
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer
{
	// currently, our gesture recognizer is always on for the feed
	// we probably want to turn off gesturerecco if we're not dealing with votable rows
	return YES;
}

// recognize gestures at same time as scrollview
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return YES;
}

#pragma mark -
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    /*
    if ([touches count]>1) {
        [self.topLevelPanGestureRecognizer setEnabled:NO];
        [self.topLevelPanGestureRecognizer setEnabled:YES];
        
        if (self.verticalPanGestureRecognizer)
        {
            [self.verticalPanGestureRecognizer setEnabled:NO];
            [self.verticalPanGestureRecognizer setEnabled:YES];
        }
        
        if (self.horizontalPanGestureRecognizer)
        {
            [self.horizontalPanGestureRecognizer setEnabled:NO];
            [self.horizontalPanGestureRecognizer setEnabled:YES];
        }
        
        
    }*/
}

@end