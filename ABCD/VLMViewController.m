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
#import "VLMConstants.h"
#import "VLMSpinner.h"
#import "VLMAnimButton.h"

typedef enum
{
	kZoomNormal,
	kZoomZoomedOut
} ZoomMode;

@interface VLMViewController ()
@property (nonatomic, strong) VLMCaptureView *capture;
@property (nonatomic, strong) VLMDataSource *dataSource;
@property (nonatomic, strong) VLMGradient *overlay;
@property (nonatomic, strong) UIScrollView *secretScrollview;
@property (nonatomic, strong) VLMSinglePanelFlowLayout *singlePanelFlow;
@property ZoomMode zoomMode;
@property CGFloat currentPage;
@property BOOL zoomEnabled;
@property CGFloat screensizeMultiplier;
@property CGPoint lastKnownContentOffset;
@property BOOL isArtificiallyScrolling;
@property NSInteger lastKnownChoicePage;
@property (nonatomic, strong) VLMSpinner *spinner;
@property (nonatomic, strong) VLMAnimButton *qbutton;

@property CGRect fuckA;
@property CGRect fuckB;
@end

@implementation VLMViewController
@synthesize capture;
@synthesize currentPage;
@synthesize dataSource;
@synthesize overlay;
@synthesize secretScrollview;
@synthesize singlePanelFlow;
@synthesize zoomMode;
@synthesize zoomEnabled;
@synthesize screensizeMultiplier;

static NSString *CellIdentifier = @"CellIdentifier";
static NSString *HeaderIdentifier = @"HeaderIdentifier";
static NSString *CellChoiceIdentifier = @"CellChoiceIdentifier";

#define SHOULD_HIT_TEST_TAPS NO

#pragma mark - Boilerplate

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (void)loadView
{
	[self setNeedsStatusBarAppearanceUpdate];
	[self setCurrentPage:0];
	[self setZoomMode:kZoomNormal];
	[self setZoomEnabled:YES];
	[self setScreensizeMultiplier:2.0f];
	[self setIsArtificiallyScrolling:NO];
}

- (void)viewDidLoad
{
	// data source for collection view
	[self setupDataSource];
    
	// flow layout with customizations
	VLMSinglePanelFlowLayout *flow = [[VLMSinglePanelFlowLayout alloc] init];
	[self setSinglePanelFlow:flow];
    
	// collection view
	[self setupCollectionView];
    
	// offscreen scrollview used as a proxy for scrolling the collection view
	// this is a hack so that adjacent items can be visible
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
	[scrollView setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self.dataSource numberOfSectionsInCollectionView:self.collectionView])];
	[scrollView setPagingEnabled:YES];
	[scrollView setDelegate:self];
	[self setSecretScrollview:scrollView];
    
	// overlay when we are zoomed out
	VLMGradient *gradient = [[VLMGradient alloc] initWithFrame:self.view.frame];
	[gradient setAlpha:0.0f];
	[gradient setUserInteractionEnabled:NO];
	[self.view addSubview:gradient];
	[self setOverlay:gradient];
    
	// touch capture view detects kinds of gestures and decides what behavior to trigger
	[self setupCaptureView];
    
    CGFloat side = 36.0f;
    CGRect spinframe = CGRectMake(self.capture.frame.size.width/2.0f-side/2.0f, self.capture.frame.size.height - side * 3.5f, side, side);

    self.fuckA = spinframe;
    self.fuckB = CGRectMake(spinframe.origin.x, self.capture.frame.size.height/2.0f + side/4 + kItemSize.height/8.0f, side, side);
    self.spinner = [[VLMSpinner alloc] initWithFrame:spinframe];
    [self.view addSubview:self.spinner];
    
    
    [self setQbutton:[[VLMAnimButton alloc] initWithFrame:
                      CGRectMake(self.capture.frame.size.width/2.0f-25.0f,
                                 self.capture.frame.size.height - (self.capture.frame.size.height-kItemSize.height) - 50.0f - kItemPadding*2,
                                 50.0f,
                                 50.0f)
                      ]];
    [self.qbutton setImage:[UIImage imageNamed:@"qbutton"] forState:UIControlStateNormal];
    [self.view addSubview:self.qbutton];
    

    
    
	// listen for decision tree changes
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

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark - Setup

- (void)setupCaptureView
{
	VLMCaptureView *cap = [[VLMCaptureView alloc] initWithFrame:self.view.frame];
    
	[cap setBackgroundColor:[UIColor clearColor]];
	[cap addVerticalGestureRecognizer:secretScrollview.panGestureRecognizer];
	[self.view addSubview:cap];
	[self setCapture:cap];
    
    CheckOverviewBlock checkOverviewBlock = ^()
    {
        if (self.zoomMode==kZoomZoomedOut) {
            return YES;
        }
        return NO;
    };
    
	ZoomPageBlock zoomPageBlock = ^(CGFloat zoomAmount, BOOL ended)
	{
		if (!self.zoomEnabled)
		{
			return;
		}
        
		CGFloat lb = 1 / self.screensizeMultiplier;
		CGFloat page = roundf(self.secretScrollview.contentOffset.y / kItemSize.height);
        
		switch (self.zoomMode)
		{
			case kZoomNormal :
            if (!ended)
            {
                CGFloat s = zoomAmount;
                if (s < lb)
                {
                    CGFloat dif = s - lb;
                    s = lb + dif*0.1f;
                }
                if ([self.dataSource isItemAtIndexChoice:page])
                {
                    if (s > CHOICE_SCALE)
                    {
                        CGFloat dif = s - CHOICE_SCALE;
                        s = CHOICE_SCALE + dif*0.1f;
                    }
                }
                else
                {
                    if (s > 1.0f)
                    {
                        CGFloat dif = s - 1.0f;
                        s = 1.0f + dif*0.1f;
                    }
                }
                [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
            }
            else
            {
                if (zoomAmount < 1)
                {
                    [self switchZoom:kZoomZoomedOut targetPage:-1 shouldBounce:NO];
                }
                else
                {
                    
                    if ([self.dataSource isItemAtIndexChoice:page])
                    {
                        [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                         animations:^{
                                             [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, CHOICE_SCALE, CHOICE_SCALE, 1.0f)];

                                         } completion:^(BOOL completed) {
                                         }
                         
                         ];
                    }
                    else
                    {
                        [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                         animations:^{
                                             [self.collectionView.layer setTransform:CATransform3DIdentity];
                                         } completion:^(BOOL completed) {
                                         }
                         
                         ];
                        [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:NO];
                    }
                }
            }
            break;
            
			case kZoomZoomedOut :
            if (!ended)
            {
                CGFloat s = lb + (zoomAmount - 1);
                if (s < lb)
                {
                    CGFloat dif = s - lb;
                    s = lb + dif*0.1f;
                }
                if ([self.dataSource isItemAtIndexChoice:page])
                {
                    if (s > CHOICE_SCALE)
                    {
                        CGFloat dif = s - CHOICE_SCALE;
                        s = CHOICE_SCALE + dif*0.1f;
                    }
                }
                else
                {
                    if (s > 1.0f)
                    {
                        CGFloat dif = s - 1.0f;
                        s = 1.0f + dif*0.1f;
                    }
                }
                
                [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
            }
            else
            {
                if (zoomAmount < 1)
                {
                    [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                     animations:^{
                                          [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, lb, lb, 1.0f)];
                                         
                                     } completion:^(BOOL completed) {
                                     }
                     
                     ];
                    [self switchZoom:kZoomZoomedOut targetPage:-1 shouldBounce:NO];
                }
                else
                {
                    if ([self.dataSource isItemAtIndexChoice:page])
                    {
                        [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                         animations:^{
                                             [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, CHOICE_SCALE, CHOICE_SCALE, 1.0f)];
                                             
                                         } completion:^(BOOL completed) {
                                         }
                         
                         ];
                    }
                    else
                    {
                        [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                         animations:^{
                                             [self.collectionView.layer setTransform:CATransform3DIdentity];
                                         } completion:^(BOOL completed) {
                                         }
                         
                         ];
                    }
                    [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:NO];
                }
            }
            break;
            
			default :
            break;
		}
	};
	UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
	[self.capture addGestureRecognizer:tgr];
	[self.capture setZoomPageBlock:zoomPageBlock];
    [self.capture setCheckOverviewBlock:checkOverviewBlock];
}

- (void)setupCollectionView
{
	UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.singlePanelFlow];
    
	[cv setDataSource:self.dataSource];
    
	CGRect frame = UIScreen.mainScreen.bounds;
	[cv setContentOffset:CGPointMake(0, kItemPaddingBottom)];
	[cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
	[cv registerClass:[VLMCollectionViewCellWithChoices class] forCellWithReuseIdentifier:CellChoiceIdentifier];
	[cv setBackgroundColor:[UIColor whiteColor]];
	[cv.panGestureRecognizer setEnabled:NO];
	[cv setClipsToBounds:NO];
	[cv setContentInset:UIEdgeInsetsMake(kItemPaddingBottom + 3 + frame.size.height / 2, 0, kItemPaddingBottom, 0)];
	[self setCollectionView:cv];
	CGSize desiredSize = CGSizeMake(frame.size.width, frame.size.height * self.screensizeMultiplier);
	CGFloat insetY = (desiredSize.height - frame.size.height) / 2.0f;
	self.collectionView.frame = CGRectMake(
                                           0,
                                           -insetY,
                                           desiredSize.width,
                                           desiredSize.height);
	[self.collectionView setContentInset:UIEdgeInsetsMake(kItemPaddingBottom + 3 + insetY, 0, kItemPaddingBottom, 0)];
}

- (void)setupDataSource
{
	CollectionViewCellConfigureBlock configureCellBlock = ^(VLMCollectionViewCell *cell, VLMPanelModel *panelModel)
	{
		[cell configureWithModel:panelModel];
	};
    
	ChoosePageBlock choosePageBlock = ^(CGFloat page, NSString *text) {
		if (self.zoomMode != kZoomNormal)
		{
			[self.overlay setTextNoAnimation:text];
		}
		else
		{
			[self.overlay setText:text];
		}
	};
    
	ScrollPageBlock scrollPageBlock = ^(CGFloat primaryAlpha, NSString *primary, CGFloat secondaryAlpha, NSString *secondary) {
        self.lastKnownChoicePage = self.currentPage;
		if (self.zoomMode != kZoomNormal)
		{
		}
		else
		{
			[self.overlay setAlpha:primaryAlpha forText:primary andAlpha:secondaryAlpha forText2:secondary];
		}
	};
    
	CollectionViewCellConfigureBlock configureCellChoiceBlock = ^(VLMCollectionViewCellWithChoices *cell, VLMPanelModels *panelModels)
	{
		// NSLog(@"configurecellchoiceblock %@", cell.scrollview.panGestureRecognizer ? @"exists" : @"notexists");
		[self.capture removeAnyHorizontalGestureRecognizers];
		[self.capture addHorizontalGestureRecognizer:cell.scrollview.panGestureRecognizer];
		[cell setChoosePageBlock:choosePageBlock];
		[cell setScrollPageBlock:scrollPageBlock];
		[cell configureWithModel:panelModels];
        
        if (self.zoomMode != kZoomNormal) {
            [self checkHorizontalPanEnabled];
        }
	};
    
	VLMDataSource *ds = [[VLMDataSource alloc] initWithCellIdentifier:CellIdentifier cellChoiceIdentifier:CellChoiceIdentifier configureCellBlock:configureCellBlock configureCellChoiceBlock:configureCellChoiceBlock];
    
	[self setDataSource:ds];
}

#pragma mark - () & Event Handling

- (void)switchZoom:(ZoomMode)mode targetPage:(NSInteger)targetPage shouldBounce:(BOOL)shouldBounce
{
	if (mode == self.zoomMode)
	{
		return;
	}
	self.zoomMode = mode;
    
    //NSLog(@"switchzoom");
    
	CGRect frame = UIScreen.mainScreen.bounds;
	CGFloat page = roundf(self.secretScrollview.contentOffset.y / kItemSize.height);
    
    if (targetPage > -1) {
        page = targetPage;
    }
	if (self.zoomMode == kZoomNormal)
	{
        if (page<1.0f) {
            [self.qbutton show];
        }
        
        
		[self.capture enableHorizontalPan:NO];
		if ([self.dataSource isItemAtIndexChoice:page])
		{
			[self.capture enableHorizontalPan:YES];
            
			// get selected child's name
			// and apply to the gradient text
			NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:page];
			VLMPanelModels *model = (VLMPanelModels *)[self.dataSource itemAtIndexPath:path];
            
			NSInteger selectedind = [[model.sourceNode objectForKey:@"selected"] integerValue];
            
			VLMPanelModel *m = (VLMPanelModel *)[model.models objectAtIndex:selectedind];
			[self.overlay setTextNoAnimation:m.name];
            [self.overlay setText:m.name];
            
			[self.secretScrollview.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f, 1.0f, 1.0f)];
			[self.secretScrollview setFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
			[self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self.dataSource numberOfSectionsInCollectionView:self.collectionView])];
			[self.secretScrollview setContentInset:UIEdgeInsetsZero];
			[self setZoomEnabled:NO];
            
            if (shouldBounce) {
                [self animateBounceZoom:CHOICE_SCALE];
            }
			[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
							 animations:^{
                                 [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                                 if (!shouldBounce) {
                                     [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, CHOICE_SCALE, CHOICE_SCALE, 1.0f)];
                                 }
                                 [self.spinner setFrame:self.fuckA];
                             } completion:^(BOOL completed) {
                                 [self.secretScrollview setPagingEnabled:YES];
                                 [self setZoomEnabled:YES];
                             }
             
             ];
		}
		else
		{
			[self.capture enableHorizontalPan:NO];
			[self.overlay setTextNoAnimation:@""];
			[self.overlay hide];
			[self.secretScrollview.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f, 1.0f, 1.0f)];
			[self.secretScrollview setFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
			[self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self.dataSource numberOfSectionsInCollectionView:self.collectionView])];
			[self.secretScrollview setContentInset:UIEdgeInsetsZero];
            
            
			[self setZoomEnabled:NO];

            if (shouldBounce) {
                [self animateBounceZoom:1.0f];
            }
			[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
							 animations:^{
                                 [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                                 if (!shouldBounce) {
                                     [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f, 1.0f, 1.0f)];
                                 }
                                 [self.spinner setFrame:self.fuckA];

                             } completion:^(BOOL completed) {
                                 [self.secretScrollview setPagingEnabled:YES];
                                 [self setZoomEnabled:YES];
                             }
             
             ];
		}
	}
	else
	{
        if (page<1.0f) {
            [self.qbutton hide];
        }
		[self.capture enableHorizontalPan:NO];
		[self.secretScrollview setPagingEnabled:NO];
		if ([self.dataSource isItemAtIndexChoice:page])
		{
		}
		else
		{
			[self.overlay setTextNoAnimation:@""];
		}
		[self.overlay show];
        
		CGSize desiredSize = CGSizeMake(frame.size.width, frame.size.height * self.screensizeMultiplier);
		CGFloat insetY = (desiredSize.height - frame.size.height) / 2.0f;
        
        
		self.secretScrollview.frame = CGRectMake(
                                                 0,
                                                 -insetY,
                                                 desiredSize.width,
                                                 desiredSize.height);
        
		[self.secretScrollview.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f / self.screensizeMultiplier, 1.0f / self.screensizeMultiplier, 1.0f)];
		[self setZoomEnabled:NO];

        if (shouldBounce) {
            [self animateBounceZoom:1.0f/self.screensizeMultiplier];
        }
        
		[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
						 animations:^{
                             if (!shouldBounce) {
                                 [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f / self.screensizeMultiplier, 1.0f / self.screensizeMultiplier, 1.0f)];
                                 
                             }
                             
                             [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                             [self.spinner setFrame:self.fuckB];

                         } completion:^(BOOL completed) {
                             [self setZoomEnabled:YES];
                         }
         
         ];
        
		CGFloat h = kItemSize.height;
		h *= [self.dataSource numberOfSectionsInCollectionView:self.collectionView];
		h += insetY * 2;
        
		[self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, h)];
	}
}

-(void)animateBounceZoom:(CGFloat)targetZoom
{
    CGFloat currentScale = [[self.collectionView.layer valueForKeyPath: @"transform.scale"] floatValue];
    NSValue * from = [NSNumber numberWithFloat:currentScale];
    NSValue * to = [NSNumber numberWithFloat:targetZoom];
    NSString * keypath = @"transform.scale";

    [self.collectionView.layer addAnimation:[self bounceAnimationFrom:from to:to forKeyPath:keypath withDuration:ZOOM_DURATION] forKey:@"bounce"];
    [self.collectionView.layer setValue:to forKeyPath:keypath];
}

#pragma mark - CAAnimations

-(CABasicAnimation *)bounceAnimationFrom:(NSValue *)from
                                      to:(NSValue *)to
                              forKeyPath:(NSString *)keypath
                            withDuration:(CFTimeInterval)duration
{
    CABasicAnimation * result = [CABasicAnimation animationWithKeyPath:keypath];
    [result setFromValue:from];
    [result setToValue:to];
    [result setDuration:duration];
    
    
    //[result setTimingFunction:[CAMediaTimingFunction functionWithControlPoints:.5 :1.8 :.8 :0.8]];
    [result setTimingFunction:
     
     // gentler but still zippy
     //[CAMediaTimingFunction functionWithControlPoints:0.52 :1.667 :0.8 :0.8]
     
     // not bad
     [CAMediaTimingFunction functionWithControlPoints:0.52 :1.7 :0.8 :0.8]

     // original version: too zippy
     //[CAMediaTimingFunction functionWithControlPoints:0.5 :1.8 :0.8 :0.8]

     ];
    return  result;
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
	if (self.zoomMode == kZoomNormal)
	{
		[self switchZoom:kZoomZoomedOut targetPage:-1 shouldBounce:YES];
	}
	else
	{
        if (SHOULD_HIT_TEST_TAPS) {
            CGPoint hit = [sender locationInView:self.collectionView];
            //NSLog(@"hit point %f, %f", hit.x, hit.y);
            
            // uncomment to allow whitespace hits
            //hit.x = self.collectionView.frame.size.width/2.0f;
            
            
            NSIndexPath *hitpath = [self.collectionView indexPathForItemAtPoint:hit];
            //NSLog(@"hit %d", hitpath.section);
            if (hitpath) {
                self.currentPage = hitpath.section;
                if ([self.dataSource isItemAtIndexPathChoice:hitpath]) {
                    self.lastKnownChoicePage = hitpath.section;
                }
                [self switchZoom:kZoomNormal targetPage:hitpath.section shouldBounce:YES];
            } else {
                //[self switchZoom:kZoomNormal targetPage:-1];
            }
            
        } else {
            [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:YES];
        }
	}
}

- (void)needsUpdateContent:(NSNotification *)notification
{
    [self.spinner show];
    [self.capture resetHGR];
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.001f];
}

- (void)refresh
{
    [self.secretScrollview setContentSize:CGSizeMake(self.secretScrollview.frame.size.width, [self.dataSource numberOfSectionsInCollectionView:self.collectionView] * self.secretScrollview.frame.size.height)];
    [self.collectionView reloadData];
    //[self checkHorizontalPanEnabled];
    [self.spinner hideWithDelay:0.4f];
    return;
}


#pragma mark - Secret Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView != self.secretScrollview)
	{
		return;
	}
    
	if (self.zoomMode == kZoomZoomedOut)
	{
		CGPoint contentOffset = scrollView.contentOffset;
		contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
		[self.collectionView setContentOffset:contentOffset];
		return;
	}
    
	CGPoint contentOffset = scrollView.contentOffset;
	self.lastKnownContentOffset = contentOffset;
    
	CGFloat page = contentOffset.y / scrollView.frame.size.height;
	CGFloat delta = page - self.currentPage;
	BOOL currentPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:self.currentPage];
	BOOL nextPageIsZoomedOut = NO;
	CGFloat zoomedoutscale = CHOICE_SCALE;
    
    if (page<=0.125f) {

        CGFloat qbuttonAlpha = 1 - 8*page;
        if (qbuttonAlpha<0) {
            qbuttonAlpha = 0;
        } else if (qbuttonAlpha>1) {
            qbuttonAlpha = 1;
        }
        [self.qbutton setAlpha:qbuttonAlpha];
    
    } else {
        [self.qbutton setAlpha:0];
        
    }
    
	if (delta > 0)
	{
		if (fabs(delta) < 1)
		{
			nextPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:currentPage + 1];
            
			NSString *nextLabel = [self.dataSource labelAtIndex:(self.currentPage + 1)];
            
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
					[self.overlay setTextNoAnimation:nextLabel];
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
			[self setCurrentPage:roundf(page)];
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
					NSString *nextLabel = [self.dataSource labelAtIndex:(self.currentPage - 1)];
                    
					CGFloat s = zoomedoutscale + (1 - zoomedoutscale) * (1 - fabs(delta));
					CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
					[self.collectionView.layer setTransform:t];
					[self.overlay setAlpha:fabs(delta)];
                    
					[self.overlay setTextNoAnimation:nextLabel];
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
			[self setCurrentPage:roundf(page)];
		}
	}
	contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
	[self.collectionView setContentOffset:contentOffset];
    
    [self checkHorizontalPanEnabled];

}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
	if (scrollView != self.secretScrollview)
	{
		return;
	}
    
	if (self.isArtificiallyScrolling)
	{
		return;
	}
    
	if (self.zoomMode == kZoomZoomedOut)
	{
		CGFloat targetpage = roundf(targetContentOffset->y / kItemSize.height);
		if (velocity.y == 0)
		{
			[self performSelector:@selector(mew) withObject:self afterDelay:0.001f];
			return;
		}
		targetContentOffset->y = roundf(targetpage) * kItemSize.height;
		[self setCurrentPage:targetpage];

        // FIXME: should there be a check here?
        
		return;
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if (self.zoomMode != kZoomNormal)
	{
		return;
	}
	[self setCurrentPage:scrollView.contentOffset.y / kItemSize.height];
    [self checkHorizontalPanEnabled];
}

- (void)checkHorizontalPanEnabled
{
	if (self.zoomMode == kZoomNormal)
	{
        if ([self.dataSource isItemAtIndexChoice:self.currentPage])
        {
            [self.capture enableHorizontalPan:YES];
        }
        else
        {
            [self.capture enableHorizontalPan:NO];
        }


    } else {
        [self.capture enableHorizontalPan:NO];
    }
}

- (void)mew
{
	CGFloat targetpage = roundf(self.secretScrollview.contentOffset.y / kItemSize.height);
    
	[self setIsArtificiallyScrolling:YES];
	[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
					 animations:^{
                         [self.secretScrollview setContentOffset:CGPointMake(0, roundf(targetpage) * kItemSize.height)];
                     } completion:^(BOOL completed) {
                         [self setIsArtificiallyScrolling:NO];
                     }
     
     ];
}

@end