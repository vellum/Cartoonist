//
//  VLMCollectionViewCellWithChoices.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCellWithChoices.h"
#import "VLMCollectionViewCell.h"
#import "VLMPanelModels.h"
#import "VLMPanelModel.h"

@interface VLMCollectionViewCellWithChoices ()
@property (nonatomic, strong) NSMutableArray *subviews;
@property (nonatomic, strong) VLMPanelModels *panels; // this should be a weak reference
@end

@implementation VLMCollectionViewCellWithChoices
@synthesize scrollview;
@synthesize choosePageBlock;
@synthesize scrollPageBlock;
@synthesize subviews;
@synthesize panels;

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		[self setScrollview:[[UIScrollView alloc] initWithFrame:CGRectMake(kItemPadding, 0, kItemSize.width - kItemPadding, kItemSize.height)]];
		[self.scrollview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
		[self.scrollview setAutoresizesSubviews:NO];
		[self.scrollview setBackgroundColor:[UIColor clearColor]];
		[self.scrollview setClipsToBounds:NO];
		[self.scrollview setPagingEnabled:YES];
		[self.scrollview setShowsHorizontalScrollIndicator:NO];
		[self.scrollview setTag:1000];
		[self.scrollview setDelegate:self];
		[self.contentView addSubview:self.scrollview];

		[self setSubviews:[[NSMutableArray alloc] init]];
	}
	return self;
}

- (void)setDelegate:(id)scrollViewDelegate
{
	// [self.scrollview setDelegate:scrollViewDelegate];
}

- (void)configureWithModel:(VLMPanelModels *)models
{
	NSInteger numPages = [models.models count];

	[self.scrollview setContentSize:CGSizeMake((kItemSize.width - kItemPadding) * numPages, kItemSize.height)];
	[self setPanels:models];


	// TBD: query data for the *selected* item and make sure the scrollview presents this as centered

	// remove all children
	//
	for (NSInteger i = 0; i < [self.subviews count]; i++)
	{
		UIView *subview = (UIView *)[self.subviews objectAtIndex:i];
		[subview removeFromSuperview];
	}
	[self.subviews removeAllObjects];

	// add as many as makes sense
	for (NSInteger i = 0; i < numPages; i++)
	{
		VLMPanelModel *model = (VLMPanelModel *)[models.models objectAtIndex:i];
		CGRect rect = CGRectMake((kItemSize.width - kItemPadding) * i, kItemPadding, kItemSize.width - kItemPadding * 2, kItemSize.height - kItemPaddingBottom);

		if (model.cellType != kCellTypeWireframe)
		{
			UIImageView *imageview = [[UIImageView alloc] initWithFrame:rect];
			[imageview setContentMode:UIViewContentModeScaleAspectFill];
			[imageview setClipsToBounds:YES];
			[imageview setImage:model.image];
			[imageview setBackgroundColor:[UIColor lightGrayColor]];
			[self.scrollview addSubview:imageview];
			[self.subviews addObject:imageview];
		}
		else
		{
			UIView *placeholder = [[UIView alloc] initWithFrame:rect];
			[placeholder setBackgroundColor:[UIColor blackColor]];
			[self.scrollview addSubview:placeholder];
			[self.subviews addObject:placeholder];
		}
	}
	NSInteger selected = [[models.sourceNode objectForKey:@"selected"] integerValue];
	[self.scrollview setContentOffset:CGPointMake(selected * (kItemSize.width - kItemPadding), 0)];
	[self updatePage:selected];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	// NSLog(@"%f", scrollView.contentOffset.x);
	CGFloat page = scrollview.contentOffset.x / scrollview.frame.size.width;

	// NSLog(@"%f", page);

	if (self.scrollPageBlock)
	{
		NSInteger lowerbound = floor(page);
		NSInteger upperbound = ceil(page);
		if (lowerbound < 0)
		{
			lowerbound = 0;
		}
		if (lowerbound > [self.panels.models count] - 1)
		{
			lowerbound = [self.panels.models count] - 1;
		}
		if (upperbound < 0)
		{
			upperbound = 0;
		}
		if (upperbound > [self.panels.models count] - 1)
		{
			upperbound = [self.panels.models count] - 1;
		}

		// object at lowerbound is displayed at
		CGFloat alpha1 = 1 - (page - lowerbound);
		VLMPanelModel *model1 = [self.panels.models objectAtIndex:lowerbound];

		// object at upperbound is displayed at
		CGFloat alpha2 = page - lowerbound;
		VLMPanelModel *model2 = [self.panels.models objectAtIndex:upperbound];

		[NSObject cancelPreviousPerformRequestsWithTarget:self];
		self.scrollPageBlock(alpha1, model1.name, alpha2, model2.name);
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	// NSLog(@"scrollviewdidend");
	CGFloat page = scrollview.contentOffset.x / scrollview.frame.size.width;
	NSInteger pageAsInt = floor(page);

	[self updatePage:pageAsInt];
}

- (void)updatePage:(NSInteger)page
{
	/*
	 *  // NSLog(@"updatePage");
	 *  if (self.choosePageBlock)
	 *  {
	 *          VLMPanelModel *model = [self.panels.models objectAtIndex:page];
	 *          self.choosePageBlock(page, model.name);
	 *  }
	 */
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // we might be flipping back and forth between options, so wait half a second before requesting a reloaddata
    // (while sections reload, horizontal pan gesture recognizers are torn down and reconstructed.
	[self performSelector:@selector(notifyPageChange:) withObject:[NSNumber numberWithInteger:page] afterDelay:0.5f];
	//[self performSelector:@selector(notifyPageChange:) withObject:[NSNumber numberWithInteger:page] afterDelay:0.01f];
}

- (void)notifyPageChange:(NSNumber *)page
{
	if (self.choosePageBlock)
	{
		NSInteger p = [page integerValue];
		VLMPanelModel *model = [self.panels.models objectAtIndex:p];
		self.choosePageBlock(p, model.name);
		[self.panels setSelectedIndex:p];
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