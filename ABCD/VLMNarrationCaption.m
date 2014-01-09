//
//  VLMNarrationCaption.m
//  Cartoonist
//
//  Created by David Lu on 12/2/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMNarrationCaption.h"
#import "VLMConstants.h"
#import "VLMPaddedLabel.h"
#import "VLMCollectionViewLayoutAttributes.h"

@interface VLMNarrationCaption()
@property (nonatomic, strong) VLMPaddedLabel *label;
@end

@implementation VLMNarrationCaption

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		// Initialization code
		[self setup];
	}
	return self;
}

- (void)setup
{
	//[self setBackgroundColor:[UIColor colorWithHue:54.0f / 360.0f saturation:0.96f brightness:0.98f alpha:1.0f]];
    [self setBackgroundColor:[UIColor clearColor]];
	[self setAlpha:0];
	[self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    [self setLabel:[[VLMPaddedLabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)]];
    [self addSubview:self.label];
    
    [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	[self.label setTextAlignment:NSTextAlignmentCenter];
	[self.label setAdjustsFontSizeToFitWidth:YES];
	[self.label setNumberOfLines:3];
    [self.label setFont:FONT_CAPTION];
    [self setUserInteractionEnabled:NO];
    
    
    [self.label setTextColor:[UIColor blackColor]];
    [self.label setBackgroundColor:[UIColor whiteColor]];
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1.0f;
}

- (void)setText:(NSString *)text
{
    [self.label setText:text];
}

- (void)setAttributedText:(NSAttributedString *)text
{
    [self.label setAttributedText:text];
}

- (void)transitionAtValue:(CGFloat)value
{
    
    
	/*
	 * // notes:
	 * // 0 to 1 - panel is scrolling between center and off top edge of screen
	 * // 0 to -1 - panel is scrolling between center and off bottom edge of screen
	 */
	BOOL isLeaving = roundf(value * 100.0f) / 100.0f > 0;
	BOOL isArriving = roundf(value * 100.0f) / 100.0f < 0;
	CGFloat transition = fabsf(value);


	if (transition > 1)
	{
		transition = 1;
	}
	transition = 1 - transition;
	transition = roundf(transition * 100.0f) / 100.0f;     // this makes for jaggy animation
	CGFloat duration = 0;//0.5f;

	if (isLeaving)
	{
		// map 0 to 0.1 to 1 and 0
		CGFloat mapped = value;
		CGFloat threshold = 0.1f;
		if (mapped > threshold)
		{
			mapped = threshold;
		}
		mapped = 1.0f - (mapped / threshold);
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:duration];
		[self setAlpha:mapped];

		// CATransform3D t = CATransform3DScale(CATransform3DIdentity, mapped, mapped, 1.0f);
		// [self.caption.layer setTransform:t];

		[UIView commitAnimations];
	}
	else if (isArriving)
	{
		CGFloat threshold = 0.5f;
		CGFloat mapped = (transition - threshold) / (1 - threshold);
		if (mapped < 0)
		{
			mapped = 0;
		}
		if (mapped > 0.9f)
		{
			mapped = 1.0f;
		}
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:duration];
		[self setAlpha:mapped];

		// CATransform3D t = CATransform3DScale(CATransform3DIdentity, mapped, mapped, 1.0f);
		// [self.caption.layer setTransform:t];
		[UIView commitAnimations];
	}
}

- (void)applyLayoutAttributes:(VLMCollectionViewLayoutAttributes*)attributes{
    if (attributes.isOverview) {

        if (self.alpha==1) {
            return;
        }
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationBeginsFromCurrentState:YES];
		[UIView setAnimationDuration:0.5f];
		[self setAlpha:1.0f];
		[UIView commitAnimations];

    } else {
        [self transitionAtValue:attributes.transitionValue];
    }
}

/*
 * // Only override drawRect: if you perform custom drawing.
 * // An empty implementation adversely affects performance during animation.
 * - (void)drawRect:(CGRect)rect
 * {
 *  // Drawing code
 * }
 */

@end
