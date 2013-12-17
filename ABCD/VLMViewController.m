//
//  VLMViewController.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

//
// A mobile-first comic book with choose-your-own-adventure influences
// A way for me to draw and write and perhaps do those full time
//
//


#import <objc/runtime.h>
#import "VLMViewController.h"
#import "VLMPanelModels.h"

@interface VLMViewController ()
@end

@implementation VLMViewController

@synthesize capture;
@synthesize currentPage;
@synthesize dataSource;
@synthesize overlay;
@synthesize secretScrollview;
@synthesize singlePanelFlow;

static NSString *CellIdentifier = @"CellIdentifier";
static NSString *HeaderIdentifier = @"HeaderIdentifier";
static NSString *CellChoiceIdentifier = @"CellChoiceIdentifier";

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)loadView
{
	[self setNeedsStatusBarAppearanceUpdate];
}

- (void)viewDidLoad
{
	[self setCurrentPage:0];

	VLMSinglePanelFlowLayout *flow = [[VLMSinglePanelFlowLayout alloc] init];
	[flow setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	[flow setMinimumInteritemSpacing:0.0f];
	[flow setMinimumLineSpacing:0.0f];
	[flow setItemSize:kItemSize];
	[self setSinglePanelFlow:flow];

	CollectionViewCellConfigureBlock configureCellBlock = ^(VLMCollectionViewCell *cell, VLMPanelModel *panelModel)
	{
		// FIXME: uncomment and debug
		[cell configureWithModel:panelModel];
	};

	CollectionViewCellConfigureBlock configureCellChoiceBlock = ^(VLMCollectionViewCellWithChoices *cell, VLMPanelModels *panelModels)
	{
		[self.capture addHorizontalGestureRecognizer:cell.scrollview.panGestureRecognizer];
		ChoosePageBlock choosePageBlock = ^(CGFloat page, NSString *text) {
			[self.overlay setText:text];

			// TBD: update the decision tree, then update the next cells
			// update
			if (page + 1 < [self.collectionView numberOfSections] - 1)
			{
				// update the next cell
				//
			}
		};

		ScrollPageBlock scrollPageBlock = ^(CGFloat primaryAlpha, NSString *primary, CGFloat secondaryAlpha, NSString *secondary) {
			[self.overlay setAlpha:primaryAlpha forText:primary andAlpha:secondaryAlpha forText2:secondary];
		};


		// tbd: restore cell state
		// tbd:
		[cell setChoosePageBlock:choosePageBlock];
		[cell setScrollPageBlock:scrollPageBlock];

		// FIXME: uncomment and debug
		[cell configureWithModel:panelModels];
	};

	VLMDataSource *ds = [[VLMDataSource alloc] initWithCellIdentifier:CellIdentifier cellChoiceIdentifier:CellChoiceIdentifier configureCellBlock:configureCellBlock configureCellChoiceBlock:configureCellChoiceBlock];
	[self setDataSource:ds];

	UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.singlePanelFlow];
	[cv setDataSource:ds];
	[cv setContentOffset:CGPointMake(0, kItemPaddingBottom)];
	[cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
	[cv registerClass:[VLMCollectionViewCellWithChoices class] forCellWithReuseIdentifier:CellChoiceIdentifier];
	[cv setBackgroundColor:[UIColor whiteColor]];
	[cv.panGestureRecognizer setEnabled:NO];
	[cv setClipsToBounds:NO];
	[cv setContentInset:UIEdgeInsetsMake(kItemPaddingBottom + 3, 0, kItemPaddingBottom, 0)];
	[self setCollectionView:cv];

	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
	[scrollView setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self.dataSource numberOfSectionsInCollectionView:self.collectionView])];
	[scrollView setPagingEnabled:YES];
	[scrollView setDelegate:self];
	[self setSecretScrollview:scrollView];

	VLMGradient *gradient = [[VLMGradient alloc] initWithFrame:self.view.frame];
	[gradient setAlpha:0.0f];
	[gradient setUserInteractionEnabled:NO];
	[self.view addSubview:gradient];
	[self setOverlay:gradient];

	VLMCaptureView *cap = [[VLMCaptureView alloc] initWithFrame:self.view.frame];
	[cap setBackgroundColor:[UIColor clearColor]];
	[cap addVerticalGestureRecognizer:secretScrollview.panGestureRecognizer];
	[self.view addSubview:cap];
	[self setCapture:cap];

	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(needsUpdateContent:)
												 name:@"decisionTreeUpdated"
											   object:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)needsUpdateContent:(NSNotification *)notification
{
	NSLog(@"here");
	// self.collectionView.dataSource = Nil;
	// self.collectionView.dataSource = self.dataSource;
	[self.collectionView reloadData];

    [self.secretScrollview setContentSize:CGSizeMake(self.secretScrollview.frame.size.width, [self.dataSource numberOfSectionsInCollectionView:self.collectionView]*self.secretScrollview.frame.size.height)];
}

#pragma mark - secret scrollview delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView != self.secretScrollview)
	{
		return;
	}

	CGPoint contentOffset = scrollView.contentOffset;
	CGFloat page = contentOffset.y / scrollView.frame.size.height;
	CGFloat delta = page - self.currentPage;
	BOOL currentPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:self.currentPage];
	BOOL nextPageIsZoomedOut = NO;

	CGFloat zoomedoutscale = 0.9f;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         // 0.875f;


	if (delta > 0)
	{
		if (fabs(delta) < 1)
		{
			nextPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:currentPage + 1];
			if (!currentPageIsZoomedOut)
			{
				if (nextPageIsZoomedOut)
				{
					CGFloat s = zoomedoutscale + (1 - zoomedoutscale) * (1 - delta);
					if (s < zoomedoutscale)
					{
						s = zoomedoutscale;
					}
					if (s > 1.0f)
					{
						s = 1.0f;
					}
					[self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];

					[self.overlay setAlpha:delta];
				}
			}
			else
			{
				if (!nextPageIsZoomedOut)
				{
					CGFloat s = zoomedoutscale + (1 - zoomedoutscale) * (delta);
					if (s < zoomedoutscale)
					{
						s = zoomedoutscale;
					}
					if (s > 1.0f)
					{
						s = 1.0f;
					}
					[self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];

					[self.overlay setAlpha:1 - delta];
				}
			}
		}
		else
		{
			[self setCurrentPage:floorf(page)];
		}
	}
	else
	{
		if (fabs(delta) < 1)
		{
			nextPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:currentPage - 1];
			if (!currentPageIsZoomedOut)
			{
				if (nextPageIsZoomedOut)
				{
					CGFloat s = zoomedoutscale + (1 - zoomedoutscale) * (1 - fabs(delta));
					CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
					[self.collectionView.layer setTransform:t];
					[self.overlay setAlpha:fabs(delta)];
				}
			}
			else
			{
				if (!nextPageIsZoomedOut)
				{
					CGFloat s = zoomedoutscale + (1 - zoomedoutscale) * (fabs(delta));
					CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
					[self.collectionView.layer setTransform:t];
					[self.overlay setAlpha:1 - fabs(delta)];
				}
			}
		}
		else
		{
			[self setCurrentPage:floorf(page)];
		}
	}
	contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
	[self.collectionView setContentOffset:contentOffset];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	[self setCurrentPage:scrollView.contentOffset.y / scrollView.frame.size.height];

	if ([self.dataSource isItemAtIndexChoice:self.currentPage])
	{
		[self.capture enableHorizontalPan:YES];
	}
	else
	{
		[self.capture enableHorizontalPan:NO];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

@end