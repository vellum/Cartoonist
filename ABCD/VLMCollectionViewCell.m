//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMConstants.h"

@interface VLMCollectionViewCell ()
@end

@implementation VLMCollectionViewCell

+ (NSString *)CellIdentifier
{
    return @"VLMCollectionViewCellID";
}

- (id)initWithFrame:(CGRect)frame
{
	if (!(self = [super initWithFrame:frame]))
	{
		return nil;
	}

	[self setBackgroundColor:[UIColor clearColor]];
	[self.contentView setBackgroundColor:[UIColor clearColor]];
	[self.contentView setClipsToBounds:NO];

	CGFloat pad = kItemPadding;
	[self setCoverFrame: CGRectMake(pad, 0, kItemSize.width - pad * 2, kItemSize.height - kItemPadding + pad)];
	[self setNormalFrame: CGRectMake(pad, pad, kItemSize.width - pad * 2, kItemSize.height - kItemPadding)];

	UIView *baseView = [[UIView alloc] initWithFrame:self.normalFrame];
	[baseView setBackgroundColor:[UIColor clearColor]];
	[baseView setAutoresizesSubviews:NO];
	[baseView setUserInteractionEnabled:NO];
	[baseView setClipsToBounds:YES];
	[self.contentView addSubview:baseView];

	[self setBase:baseView];
	[self setCellType: kCellTypeUndefined];
	
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
}

- (void)configureWithModel:(VLMPanelModel *)model
{
	// NSLog(@"configurewithmodel %i", model.index);
	if (model.index == 0)
	{
		[self.base setFrame:self.coverFrame];
	}
	else
	{
		[self.base setFrame:self.normalFrame];
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

+ (CGFloat)itemPadding
{
	if ((UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad))
	{
		return kItemPaddingIphone;
	}
	return kItemPaddingIpad;
}


@end