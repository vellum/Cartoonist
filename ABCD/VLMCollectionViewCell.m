//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMPanelModel.h"

@interface VLMCollectionViewCell()
@end

@implementation VLMCollectionViewCell
@synthesize label;
@synthesize imageview;
@synthesize caption;
@synthesize base;
@synthesize imagename;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;

    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [self setBackgroundColor:[UIColor clearColor]];

    CGFloat pad = kItemPadding;

    UIView *baseView = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, kItemSize.width-pad*2, kItemSize.height-kItemPaddingBottom)];
    [baseView setBackgroundColor:[UIColor clearColor]];
    [baseView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [baseView setAutoresizesSubviews:NO];
    [baseView setUserInteractionEnabled:NO];
    [baseView setClipsToBounds:YES];
    [self.contentView addSubview:baseView];
    [self setBase:baseView];
    
    [self setImageview:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, baseView.frame.size.width, baseView.frame.size.height)]];
    [self.imageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageview setClipsToBounds:YES];
    [baseView addSubview:self.imageview];
    
    [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
    [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.label];

    UIView *vvvv = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, baseView.frame.size.width-pad*2, 50.0f)];
    [self setCaption:vvvv];
    [self.caption setBackgroundColor:[UIColor colorWithHue:54.0f/360.0f saturation:0.96f brightness:0.98f alpha:1.0f]];
    [self.caption setAlpha:0];
    [self.caption setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

    [baseView addSubview:self.caption];
    
    self.imagename = @"<not set yet>";
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)layoutSubviews{}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{

    [super applyLayoutAttributes:layoutAttributes];
    
    // Important! Check to make sure we're actually this special subclass.
    // Failing to do so could cause the app to crash!
    if (![layoutAttributes isKindOfClass:[VLMCollectionViewLayoutAttributes class]])
    {
        return;
    }
    
    VLMCollectionViewLayoutAttributes *castedLayoutAttributes = (VLMCollectionViewLayoutAttributes *)layoutAttributes;
    CGFloat transition = fabsf(castedLayoutAttributes.transitionValue);
    
    // debug text
    [self.label setText:[NSString stringWithFormat:@"%f", transition]];
    
    /*
    // notes:
    // 0 to 1 - panel is scrolling between center and off top edge of screen
    // 0 to -1 - panel is scrolling between center and off bottom edge of screen
    */
    BOOL isLeaving = roundf(castedLayoutAttributes.transitionValue*100.0f)/100.0f > 0;
    BOOL isArriving = roundf(castedLayoutAttributes.transitionValue*100.0f)/100.0f < 0;
    
    if (transition > 1) transition = 1;
    transition = 1 - transition;
    transition = roundf(transition*100.0f)/100.0f; // this makes for jaggy animation
    CGFloat duration = 0.4f;
    if (isLeaving) {

        // map 0 to 0.1 to 1 and 0
        CGFloat mapped = castedLayoutAttributes.transitionValue;
        if (mapped>0.1)
        {
            mapped = 0.1;
        }
        mapped = 1.0f - (mapped/0.1f);
        if (mapped>0.9)
        {
            mapped = 0.9;
        }
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDelay:0.0f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:duration];
        [self.caption setAlpha:mapped];
        [UIView commitAnimations];
        
        
    } else {
        
        CGFloat threshold = 0.5f;
        CGFloat mapped = (transition - threshold)/(1-threshold);
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
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationDuration:duration];
        [self.caption setAlpha:mapped];
        //CATransform3D t = CATransform3DScale(CATransform3DIdentity, transition, transition, 1.0f);
        //[self.caption.layer setTransform:t];
        [UIView commitAnimations];
    }
    
    //transition = roundf(transition*100.0f)/100.0f; // this makes for jaggy animation
    //[self.imageview setAlpha:transition];
    /*
    // this is how transitions work if you're scrolling between identical panels
    if (isLeaving) {
        [self.imageview setFrame:CGRectMake(0, (1 - transition) * self.base.frame.size.height, self.base.frame.size.width, self.base.frame.size.height)];
    } else {
        [self.imageview setFrame:CGRectMake(0, -(1-transition) * self.base.frame.size.height, self.base.frame.size.width, self.base.frame.size.height)];
    }
    //*/
    

}

- (void)configureWithModel:(VLMPanelModel *)model
{
    [self.imageview setImage:model.image];
    [self.label setText:model.name];
}


@end
