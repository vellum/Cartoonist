//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMNarrationCaption.h"
#import "VLMPanelModel.h"

@interface VLMCollectionViewCell ()
@property (nonatomic) CGRect coverFrame;
@property (nonatomic) CGRect normalFrame;
@end

@implementation VLMCollectionViewCell
@synthesize label;
@synthesize imageview;
@synthesize caption;
@synthesize base;
@synthesize imagename;
@synthesize coverFrame;
@synthesize normalFrame;

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
	{
		return nil;
	}

	[self.contentView setBackgroundColor:[UIColor clearColor]];
	[self.contentView setClipsToBounds:NO];

	[self setBackgroundColor:[UIColor clearColor]];

	CGFloat pad = kItemPadding;
	self.coverFrame = CGRectMake(pad, -3.0f, kItemSize.width - pad * 2, kItemSize.height - kItemPaddingBottom + pad + 3.0f);
	self.normalFrame = CGRectMake(pad, pad, kItemSize.width - pad * 2, kItemSize.height - kItemPaddingBottom);

	UIView *baseView = [[UIView alloc] initWithFrame:self.normalFrame];
	[baseView setBackgroundColor:[UIColor clearColor]];
	// [baseView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	[baseView setAutoresizesSubviews:NO];
	[baseView setUserInteractionEnabled:NO];
	[baseView setClipsToBounds:YES];
	[self.contentView addSubview:baseView];
	[self setBase:baseView];

	[self setImageview:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, baseView.frame.size.width, baseView.frame.size.height)]];
	[self.imageview setContentMode:UIViewContentModeScaleAspectFill];
	[self.imageview setClipsToBounds:YES];
	[self.imageview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];

	[baseView addSubview:self.imageview];

	[self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
	[self.label setTextColor:[UIColor whiteColor]];
	[self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
	[self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	[self.label setTextAlignment:NSTextAlignmentCenter];
	[self.contentView addSubview:self.label];

	VLMNarrationCaption *vvvv = [[VLMNarrationCaption alloc] initWithFrame:CGRectMake(pad, pad, baseView.frame.size.width - pad * 2, 50.0f)];
	[self setCaption:vvvv];
	[baseView addSubview:self.caption];

	self.imagename = @"<not set yet>";
	return self;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
}

- (void)layoutSubviews
{
}

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
	// debug text
	// [self.label setText:[NSString stringWithFormat:@"%f", transition]];

	[self.caption transitionAtValue:castedLayoutAttributes.transitionValue];

	// NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)configureWithModel:(VLMPanelModel *)model
{
	NSLog(@"configurewithmodel %i", model.index);
	if (model.image)
	{
		[self.imageview setImage:model.image];
		if (model.index == 0)
		{
			[self.base setFrame:self.coverFrame];
			[self.imageview setFrame:CGRectMake(0, 0, self.base.frame.size.width, self.base.frame.size.height)];
		}
		else
		{
			[self.base setFrame:self.normalFrame];
			[self.imageview setFrame:CGRectMake(0, 0, self.base.frame.size.width, self.base.frame.size.height)];
		}
	}
	if ([model.name length] > 0)
	{
		 [self.label setText:model.name];
	}
}

+ (CGSize)idealItemSize
{
	if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
	{
		return kItemSizeIphone;
	}
	return kItemSizeIpad;
}

@end