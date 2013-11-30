//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewLayoutAttributes.h"

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

    CGFloat pad = kItemPadding;

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, kItemSize.width-pad*2, kItemSize.height-kItemPaddingBottom)];
    [v setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:1.0f]];
    [v setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.contentView addSubview:v];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    [v setAutoresizesSubviews:NO];
    self.base = v;
    
    [self setImageview:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, v.frame.size.width, v.frame.size.height)]];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.imageview setContentMode:UIViewContentModeScaleAspectFill];
    [self.imageview setClipsToBounds:YES];
    [v addSubview:self.imageview];
    
    [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height-50, frame.size.width, 50)]];
    [self.label setTextColor:[UIColor whiteColor]];
    [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
    [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.label];

    pad = 5;
    UIView *vvvv = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, v.frame.size.width-pad*2, 50.0f)];
    [self setCaption:vvvv];
    [self.caption setBackgroundColor:[UIColor colorWithHue:54.0f/360.0f saturation:0.96f brightness:0.98f alpha:1.0f]];
    [self.caption setAlpha:1];
    [self.caption setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];

    [v addSubview:self.caption];
    
    self.imagename = @"<not set yet>";
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
}

-(void)layoutSubviews
{
}


- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes{

    [super applyLayoutAttributes:layoutAttributes];
    
    // Important! Check to make sure we're actually this special subclass.
    // Failing to do so could cause the app to crash!
    if (![layoutAttributes isKindOfClass:[VLMCollectionViewLayoutAttributes class]])
    {
        return;
    }
    
    VLMCollectionViewLayoutAttributes *castedLayoutAttributes = (VLMCollectionViewLayoutAttributes *)layoutAttributes;
    CGFloat transition = fabsf(castedLayoutAttributes.transitionValue);
    if (transition > 1) transition = 1;
    transition = 1 - transition;
    [self.caption setAlpha:transition];
    
}

- (void)configureImage:(UIImage *)image
{
    [self.imageview setImage:image];
}

@end
