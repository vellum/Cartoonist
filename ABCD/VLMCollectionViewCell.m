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
#import "VLMPaddedLabel.h"
#import "VLMConstants.h"

@interface VLMCollectionViewCell ()
@property (nonatomic) CGRect coverFrame;
@property (nonatomic) CGRect normalFrame;
@property (nonatomic) CellType cellType;
@end

@implementation VLMCollectionViewCell
@synthesize label;
@synthesize imageview;
@synthesize caption;
@synthesize base;
@synthesize imagename;
@synthesize coverFrame;
@synthesize normalFrame;
@synthesize cellType;




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

    //NSLog(@"cover %f,%f", self.coverFrame.size.width, self.coverFrame.size.height);
    
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

	[self setLabel:[[VLMPaddedLabel alloc] initWithFrame:self.normalFrame]];
	[self.label setTextColor:[UIColor whiteColor]];
	//[self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
    [self.label setFont:FONT_WIREFRAME];
    
    
    
	[self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
	[self.label setTextAlignment:NSTextAlignmentCenter];
	[self.label setAdjustsFontSizeToFitWidth:YES];
	[self.label setNumberOfLines:100];
	[self.contentView addSubview:self.label];

	VLMNarrationCaption *vvvv = [[VLMNarrationCaption alloc] initWithFrame:CGRectMake(pad, pad, baseView.frame.size.width - pad * 2, 60.0f)];
	[self setCaption:vvvv];
	[baseView addSubview:self.caption];

    
    //FIXME: i think this might be a weird default
	self.imagename = @"<not set yet>";

	self.cellType = kCellTypeNoCaption;
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

	switch (self.cellType)
	{
		case kCellTypeCaption :
			[self.caption transitionAtValue:castedLayoutAttributes.transitionValue];
			break;

		case kCellTypeNoCaption :
			break;

		case kCellTypeWireframe :
			break;

		default :
			break;
	}
	// NSLog(@"%@", NSStringFromCGRect(self.frame));
}

- (void)configureWithModel:(VLMPanelModel *)model
{
	// NSLog(@"configurewithmodel %i", model.index);

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

	if ([model.name length] > 0)
	{
        NSString *labelText;
        if (USE_ALL_CAPS) {
            labelText = [model.name uppercaseString];
        } else {
            labelText = model.name;
        }
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:labelText];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:FONT_LINE_SPACING];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [labelText length])];
        self.label.attributedText = attributedString;

        [self.caption setAttributedText:attributedString];
	}
	self.cellType = model.cellType;

	switch (self.cellType)
	{
		case kCellTypeCaption :
			[self.label setBackgroundColor:[UIColor clearColor]];
			self.caption.hidden = NO;
            
			self.imageview.hidden = NO;
            self.label.hidden = YES;
			if (model.image)
			{
				[self.imageview setImage:model.image];
			}
			break;

		case kCellTypeNoCaption :
			[self.label setBackgroundColor:[UIColor clearColor]];
			self.caption.hidden = YES;
            self.label.hidden = YES;
			self.imageview.hidden = NO;
			if (model.image)
			{
				[self.imageview setImage:model.image];
			}
			break;

		case kCellTypeWireframe :
			[self.label setBackgroundColor:[UIColor blackColor]];
			self.caption.hidden = YES;
			self.imageview.hidden = YES;
            self.label.hidden = NO;
			break;

		default :
			break;
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