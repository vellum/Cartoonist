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
#import "VLMViewController.h"
#import "UIImageView+WebCache.h"
#import "VLMUtility.h"

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

+ (NSString *)CellIdentifier
{
    return @"VLMCollectionViewCellWithChoicesID";
}
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

- (void)configureWithModel:(VLMPanelModels *)models
{
	NSInteger numPages = [models.models count];

	[self.scrollview setContentSize:CGSizeMake((kItemSize.width - kItemPadding) * numPages, kItemSize.height)];
	[self setPanels:models];


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
		CGRect rect = CGRectMake((kItemSize.width - kItemPadding) * i, kItemPadding, kItemSize.width - kItemPadding * 2, kItemSize.height - kItemPadding);

		if (model.cellType != kCellTypeWireframe)
		{
            UIView *croppie = [[UIView alloc] initWithFrame:rect];
            [croppie setClipsToBounds:YES];
            [croppie setUserInteractionEnabled:NO];
            
            //NSLog(@"not celltypewire");
			UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, rect.size.height, rect.size.height)];
			[imageview setContentMode:UIViewContentModeScaleAspectFill];
            
			[imageview setClipsToBounds:NO];
            if (model.image && [model.image length]>0) {

                NSURL *url = [VLMUtility URLForImageNamed:model.image];
                UIImage *placeholder = [VLMUtility placeholderForImageNamed:model.image];
                [imageview setImageWithURL:url placeholderImage:placeholder];
            
            }
            [imageview setCenter:CGPointMake(rect.size.width/2.0f, rect.size.height/2.0f)];
            [croppie addSubview:imageview];
            
			[self.scrollview addSubview:croppie];
			[self.subviews addObject:imageview];
		}
		else
		{
			//NSLog(@"celltypewire");
			UIView *placeholder = [[UIView alloc] initWithFrame:rect];
			[placeholder setBackgroundColor:[UIColor blackColor]];
			[self.scrollview addSubview:placeholder];
			[self.subviews addObject:placeholder];
		}
	}
	NSInteger selected = [[models.sourceNode objectForKey:@"selected"] integerValue];
	[self.scrollview setContentOffset:CGPointMake(selected * (kItemSize.width - kItemPadding), 0)];
	[self updatePage:selected];
    
    [self applyLayoutAttributes:nil];
}


- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
	[super applyLayoutAttributes:layoutAttributes];
    if (UIDeviceOrientationIsPortrait([VLMViewController orientation])) {
        for (NSInteger i = 0; i < [self.scrollview.subviews count]; i++)
        {
            UIView *subview = (UIView *)[self.scrollview.subviews objectAtIndex:i];
            if ([subview.subviews count] > 0) {
                UIView *iv = [subview.subviews objectAtIndex:0];
                iv.transform = CGAffineTransformMakeRotation(0.0f);
            }
        }
    } else {
        for (NSInteger i = 0; i < [self.scrollview.subviews count]; i++)
        {
            UIView *subview = (UIView *)[self.scrollview.subviews objectAtIndex:i];
            if ([subview.subviews count] > 0) {
                UIView *iv = [subview.subviews objectAtIndex:0];
                iv.transform = CGAffineTransformMakeRotation(M_PI/2.0f);
            }
        }
    }
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
	[NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // we might be flipping back and forth between options, so wait half a second before requesting a reloaddata
    // (while sections reload, horizontal pan gesture recognizers are torn down and reconstructed.
	[self performSelector:@selector(notifyPageChange:) withObject:[NSNumber numberWithInteger:page] afterDelay:0.5f];
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

@end