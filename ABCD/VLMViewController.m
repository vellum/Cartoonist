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

#import "VLMConstants.h"
#import "VLMPanelModels.h"
#import "VLMSpinner.h"
#import "VLMAnimButton.h"

#import "VLMCollectionViewCell.h"
#import "VLMWireframeCell.h"
#import "VLMStaticImageCell.h"
#import "VLMCollectionViewCellWithChoices.h"
#import "VLMSectionIndex.h"

typedef enum
{
	kZoomNormal,
	kZoomOverview
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
//@property (nonatomic, strong) VLMAnimButton *qbutton;
@property CGFloat pinchvelocity;
@property CGFloat lastKnownScale;
@property CGPoint spinnerCenterPortrait;
@property CGPoint spinnerCenterLandscape;
@property (nonatomic, strong) VLMSectionIndex *sectionIndexView;

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

#define SHOULD_HIT_TEST_TAPS NO

static UIDeviceOrientation theOrientation;

+ (UIDeviceOrientation)orientation
{
    return theOrientation;
}

#pragma mark - Boilerplate

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;//|UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)loadView
{
	[self setNeedsStatusBarAppearanceUpdate];
	[self setCurrentPage:0];
	[self setZoomMode:kZoomNormal];
	[self setZoomEnabled:YES];
	[self setScreensizeMultiplier:2.0f];
	[self setIsArtificiallyScrolling:NO];
    [self setPinchvelocity:0];
    [self setLastKnownScale:-1.0f];
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
    [self.view addSubview:self.secretScrollview];
    [self.secretScrollview setUserInteractionEnabled:NO];
    [self.secretScrollview setHidden:YES];
    [self.secretScrollview setShowsHorizontalScrollIndicator:NO];
    [self.secretScrollview setShowsVerticalScrollIndicator:NO];
    [self.secretScrollview setDirectionalLockEnabled:NO];
    [self.secretScrollview setBounces:YES];
    
	// overlay when we are zoomed out
	VLMGradient *gradient = [[VLMGradient alloc] initWithFrame:self.view.frame];
	[gradient setAlpha:0.0f];
	[gradient setUserInteractionEnabled:NO];
	[self.view addSubview:gradient];
	[self setOverlay:gradient];
    
	// touch capture view detects kinds of gestures and decides what behavior to trigger
	[self setupCaptureView];
    
    CGRect spinframe = CGRectMake(
                                  self.capture.frame.size.width/2.0f-SPINNER_DIAMETER/2.0f,
                                  self.capture.frame.size.height - (self.capture.frame.size.height-kItemSize.height) - SPINNER_DIAMETER - kItemPadding*4 - 4,
                                  SPINNER_DIAMETER, SPINNER_DIAMETER);

    self.spinner = [[VLMSpinner alloc] initWithFrame:spinframe];
    [self.view addSubview:self.spinner];
    self.spinnerCenterPortrait = self.spinner.center;
    self.spinnerCenterLandscape = CGPointMake(self.spinner.center.x - kItemSize.width/2.0f + 64, self.spinner.center.y);
    
    /*
    [self setQbutton:[[VLMAnimButton alloc] initWithFrame:
                      CGRectMake(self.capture.frame.size.width/2.0f-25.0f,
                                 self.capture.frame.size.height - (self.capture.frame.size.height-kItemSize.height) - 50.0f - kItemPadding*2,
                                 50.0f,
                                 50.0f)
                      ]];
    [self.qbutton setImage:[UIImage imageNamed:@"qbutton"] forState:UIControlStateNormal];
    [self.view addSubview:self.qbutton];
    */

    
    
	// listen for decision tree changes
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(needsUpdateContent:)
												 name:@"decisionTreeUpdated"
											   object:nil];
    
    // listen for rotation changes
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                           selector:@selector(deviceOrientationDidChange)
                               name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // FIXME : this may not be accurate, unless one can guarantee that the app is launched in portrait
    theOrientation = UIDeviceOrientationPortrait;
    
    [self.view setClipsToBounds:YES];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    CGFloat indexWidth = 20.0f;
    self.sectionIndexView = [[VLMSectionIndex alloc] initWithFrame:CGRectMake(self.view.frame.size.width-indexWidth, 0, indexWidth, self.view.frame.size.height)];
    [self.view addSubview:self.sectionIndexView];
    
    
    // FIXME: there's a bug when choice cells are selected:
    // the collectionviewcell doesn't get populated
    // it's 
    SectionIndexSelectionBlock sectionSelectionBlock = ^(CGFloat page){
        if (page==self.currentPage) {
            return;
        }
        /*
        
        [UIView animateWithDuration:ZOOM_DURATION
                              delay:0.0f
                            options:ZOOM_OPTIONS
                         animations:^{
                             [self.collectionView setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height
                                                                               - self.collectionView.contentInset.top)];
                         }
                         completion:^(BOOL completed) {
                             [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                       
                         }
         ];
         */
        [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height) animated:YES];

        self.currentPage = page;
    };
    [self.sectionIndexView setSelectionBlock:sectionSelectionBlock];
    
    
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
        if (self.zoomMode==kZoomOverview) {
            return YES;
        }
        return NO;
    };
    
	ZoomPageBlock zoomPageBlock = ^(CGFloat zoomAmount, CGFloat zoomVelocity, BOOL ended)
	{
		if (!self.zoomEnabled)
		{
			return;
		}
        
		CGFloat lb = 1 / self.screensizeMultiplier;
		CGFloat page = roundf(self.secretScrollview.contentOffset.y / kItemSize.height);
        CGFloat multiplierA = 0.2f;
        CGFloat multiplierB = 0.1f;
        self.pinchvelocity = zoomVelocity;
		switch (self.zoomMode)
		{
			case kZoomNormal :
            if (!ended)
            {
                CGFloat s = zoomAmount;
                if (s < lb)
                {
                    CGFloat dif = s - lb;
                    s = lb + dif * multiplierA;
                    self.pinchvelocity = 0;
                }
                if ([self.dataSource isItemAtIndexChoice:page])
                {
                    if (s > CHOICE_SCALE)
                    {
                        CGFloat dif = s - CHOICE_SCALE;
                        s = CHOICE_SCALE + dif * multiplierA;
                        self.pinchvelocity = 0;
                    }
                }
                else
                {
                    if (s > 1.0f)
                    {
                        CGFloat dif = s - 1.0f;
                        s = 1.0f + dif * multiplierA;
                        self.pinchvelocity = 0;
                    }
                    CGFloat gradientopa = 1 - ( s - lb ) / ( 1 - lb );
                    if (gradientopa>1) {
                        gradientopa = 1;
                    } else if (gradientopa<0){
                        gradientopa = 0;
                    }
                    [self.overlay setAlpha:gradientopa withLabelsHidden:YES];
                }
                
                
                [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
                [self setLastKnownScale:s];
            }
            else
            {
                // squish down
                if (zoomAmount < 1)
                {
                    // lower than lower bound, so gently return to lower bound
                    if (zoomAmount<=lb) {
                        [self switchZoom:kZoomOverview targetPage:-1 shouldBounce:NO];
                    // otherwise bounce
                    } else {
                        [self switchZoom:kZoomOverview targetPage:-1 shouldBounce:YES];
                    }
                }
                // stretch, so gently return to normal
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
                        [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:NO];
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
            
			case kZoomOverview :
            if (!ended)
            {
                CGFloat s = lb + (zoomAmount - 1);
                if (s < lb)
                {
                    CGFloat dif = s - lb;
                    s = lb + dif * multiplierB;
                    self.pinchvelocity = 0;
                }
                if ([self.dataSource isItemAtIndexChoice:page])
                {
                    if (s > CHOICE_SCALE)
                    {
                        CGFloat dif = s - CHOICE_SCALE;
                        s = CHOICE_SCALE + dif * multiplierA;
                        self.pinchvelocity = 0;
                    }
                }
                else
                {
                    if (s > 1.0f)
                    {
                        CGFloat dif = s - 1.0f;
                        s = 1.0f + dif * multiplierA;
                        self.pinchvelocity = 0;
                    }
                    CGFloat gradientopa = 1 - ( s - lb ) / ( 1 - lb );
                    if (gradientopa>1) {
                        gradientopa = 1;
                    } else if (gradientopa<0){
                        gradientopa = 0;
                    }
                    [self.overlay setAlpha:gradientopa withLabelsHidden:YES];

                }

                [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
                [self setLastKnownScale:s];
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
                    [self switchZoom:kZoomOverview targetPage:-1 shouldBounce:NO];
                }
                else
                {
                    
                    if ([self.dataSource isItemAtIndexChoice:page])
                    {
                        
                        if (zoomAmount>1.45f) {
                            [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                             animations:^{
                                                 [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, CHOICE_SCALE, CHOICE_SCALE, 1.0f)];
                                                 
                                             } completion:^(BOOL completed) {
                                             }
                             
                             ];
                            [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:NO];
                        } else {
                            [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:YES];
                        }
                        
                        

                    }
                    else
                    {
                        // gentle scale
                        if (zoomAmount>1.5f) {
                            [UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
                                             animations:^{
                                                 [self.collectionView.layer setTransform:CATransform3DIdentity];
                                             } completion:^(BOOL completed) {
                                             }
                             
                             ];
                            [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:NO];
                        // bounce
                        } else {
                            [self switchZoom:kZoomNormal targetPage:-1 shouldBounce:YES];
                        }
                    }
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
    
    [self.singlePanelFlow setCheckOverviewBlock:checkOverviewBlock];
    [self.overlay setCheckOverviewBlock:checkOverviewBlock];
}

- (void)setupCollectionView
{
	UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.singlePanelFlow];
    
	[cv setDataSource:self.dataSource];
    
	CGRect frame = UIScreen.mainScreen.bounds;
	[cv setContentOffset:CGPointMake(0, kItemPadding)];

    [cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:[VLMCollectionViewCell CellIdentifier]];
    [cv registerClass:[VLMWireframeCell class] forCellWithReuseIdentifier:[VLMWireframeCell CellIdentifier]];
    [cv registerClass:[VLMStaticImageCell class] forCellWithReuseIdentifier:[VLMStaticImageCell CellIdentifier]];
    [cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:[VLMCollectionViewCell CellIdentifier]];
	[cv registerClass:[VLMCollectionViewCellWithChoices class] forCellWithReuseIdentifier:[VLMCollectionViewCellWithChoices CellIdentifier]];

	[cv setBackgroundColor:[UIColor whiteColor]];
	[cv.panGestureRecognizer setEnabled:NO];
	[cv setClipsToBounds:NO];
    
	[cv setContentInset:UIEdgeInsetsMake(kItemPadding + 0 + frame.size.height / 2, 0, kItemPadding, 0)];
	[cv setShowsVerticalScrollIndicator:NO];
    [cv setShowsHorizontalScrollIndicator:NO];
    
    [self setCollectionView:cv];
	CGSize desiredSize = CGSizeMake(frame.size.width, frame.size.height * self.screensizeMultiplier);
	CGFloat insetY = (desiredSize.height - frame.size.height) / 2.0f;
	self.collectionView.frame = CGRectMake(
                                           0,
                                           -insetY,
                                           desiredSize.width,
                                           desiredSize.height);
	[self.collectionView setContentInset:UIEdgeInsetsMake(-kItemPadding/2.0f + (self.view.frame.size.height-kItemSize.height)/2.0f + insetY, 0, kItemPadding, 0)];
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
        
        NSString *nextlabelstring = [panelModels selectedLabelString];
        [self.overlay setTextNoAnimation:nextlabelstring];
        
        if (self.zoomMode != kZoomNormal) {
            [self checkHorizontalPanEnabled];
        }
	};
    
	VLMDataSource *ds = [[VLMDataSource alloc] initWithConfigureCellBlock:configureCellBlock configureCellChoiceBlock:configureCellChoiceBlock];
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
        /*
        if (page<1.0f) {
            [self.qbutton show];
        }
         */
        [self.sectionIndexView hide];

        
        
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
            [self.secretScrollview setPagingEnabled:YES];

			[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
							 animations:^{
                                 [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                                 if (!shouldBounce) {
                                     [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, CHOICE_SCALE, CHOICE_SCALE, 1.0f)];
                                 }
                             } completion:^(BOOL completed) {
                                 [self setZoomEnabled:YES];
                             }
             
             ];
		}
		else
		{
			[self.capture enableHorizontalPan:NO];
			
            //[self.overlay setTextNoAnimation:@""];
			
            [self.overlay hide];
			[self.secretScrollview.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f, 1.0f, 1.0f)];
			[self.secretScrollview setFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
			[self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self.dataSource numberOfSectionsInCollectionView:self.collectionView])];
			[self.secretScrollview setContentInset:UIEdgeInsetsZero];
            
			[self setZoomEnabled:NO];

            if (shouldBounce) {
                [self animateBounceZoom:1.0f];
            }
            [self.secretScrollview setPagingEnabled:YES];
			[UIView animateWithDuration:ZOOM_DURATION delay:0.0f options:ZOOM_OPTIONS
							 animations:^{
                                 [self.secretScrollview setContentOffset:CGPointMake(0, roundf(page) * kItemSize.height)];
                                 if (!shouldBounce) {
                                     [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, 1.0f, 1.0f, 1.0f)];
                                 }

                             } completion:^(BOOL completed) {
                                 [self setZoomEnabled:YES];
                             }
             
             ];
		}
	}
	else
	{

        [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];
        [self.sectionIndexView show];

        [self.overlay flashScrollIndicator];
        /*
        if (page<1.0f) {
            [self.qbutton hide];
        }
         */
		[self.capture enableHorizontalPan:NO];
		[self.secretScrollview setPagingEnabled:NO];
        
        // if current page is zoomed, hidetextnoanim!
        if (![self.dataSource isItemAtIndexChoice:page])
        {
            [self.overlay hideTextNoAnimation];
        }
        [self.overlay showBaseWithTextHidden];
        
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

                         } completion:^(BOOL completed) {
                             [self setZoomEnabled:YES];
                         }
         
         ];
        
        [self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, [self.dataSource numberOfSectionsInCollectionView:self.collectionView] * kItemSize.height + self.collectionView.contentInset.top*self.screensizeMultiplier)];
	}
}

#pragma mark - Bounce

-(void)animateBounceZoom:(CGFloat)targetZoom
{
    
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    CGFloat currentScale = [[self.collectionView.layer valueForKeyPath: @"transform.scale"] floatValue];
    if (self.lastKnownScale!=-1.0f) {
        currentScale = self.lastKnownScale;
    }
    NSValue * from = [NSNumber numberWithFloat:currentScale];
    NSValue * to = [NSNumber numberWithFloat:targetZoom];
    NSString * keypath = @"transform.scale";

    CGFloat duration = ZOOM_DURATION;
    if ([self.dataSource isItemAtIndexChoice:self.currentPage] && targetZoom>=CHOICE_SCALE) {
        duration *= 1.2f;
    }
    [self.collectionView.layer addAnimation:[self bounceAnimationFrom:from to:to forKeyPath:keypath withDuration:duration] forKey:@"bounce"];
    [self.collectionView.layer setValue:to forKeyPath:keypath];
}


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
     
     // not bad
     [CAMediaTimingFunction functionWithControlPoints:0.52 :1.7 :0.8 :0.8]

     // original version: too zippy
     //[CAMediaTimingFunction functionWithControlPoints:0.5 :1.8 :0.8 :0.8]

     ];
    return  result;
}

#pragma mark - Events & ()

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    [self setLastKnownScale:-1];
	if (self.zoomMode == kZoomNormal)
	{
		[self switchZoom:kZoomOverview targetPage:-1 shouldBounce:YES];
	}
	else
	{
        CGPoint hit = [sender locationInView:self.capture];
        NSLog(@"%@", NSStringFromCGPoint(hit));
        if (hit.y < 60.0f) {
            
            [self.secretScrollview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
            return;
        }
        if (SHOULD_HIT_TEST_TAPS) {
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
    
    [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];
    return;
}


#pragma mark - Secret Scrollview Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	if (scrollView != self.secretScrollview)
	{
		return;
	}
    
	if (self.zoomMode == kZoomOverview)
	{
		CGPoint contentOffset = scrollView.contentOffset;
		contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
		[self.collectionView setContentOffset:contentOffset];
        
        
        CGFloat pctoffset = self.secretScrollview.contentOffset.y / (self.secretScrollview.contentSize.height-self.secretScrollview.frame.size.height*2) ;
        CGFloat windowToContentRatio = self.secretScrollview.frame.size.height/self.secretScrollview.contentSize.height;
        //NSLog(@"%f\t%f", pctoffset, windowToContentRatio);
        [self.overlay setScrollIndicatorPositionAsPercent:pctoffset heightAsPercent:windowToContentRatio shouldFlash:YES];
        
		return;
	}
    
	CGPoint contentOffset = scrollView.contentOffset;
	self.lastKnownContentOffset = contentOffset;
    
	CGFloat page = contentOffset.y / scrollView.frame.size.height;
	CGFloat delta = page - self.currentPage;
	BOOL currentPageIsZoomedOut = [self.dataSource isItemAtIndexChoice:self.currentPage];
	BOOL nextPageIsZoomedOut = NO;
	CGFloat zoomedoutscale = CHOICE_SCALE;
    
    /*
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
    */
    
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
    
    CGFloat pctoffset = self.secretScrollview.contentOffset.y / (self.secretScrollview.contentSize.height-self.secretScrollview.frame.size.height*2) ;
    CGFloat windowToContentRatio = self.secretScrollview.frame.size.height/self.secretScrollview.contentSize.height;
    //NSLog(@"%f\t%f", pctoffset, windowToContentRatio);
    [self.overlay setScrollIndicatorPositionAsPercent:pctoffset heightAsPercent:windowToContentRatio shouldFlash:NO];


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
    
	if (self.zoomMode == kZoomOverview)
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

- (void)deviceOrientationDidChange
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch ([[UIDevice currentDevice] orientation]) {
        case UIDeviceOrientationLandscapeLeft:
            NSLog(@"landscapeL");
            theOrientation = UIDeviceOrientationLandscapeLeft;
            transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0f);
            [self.overlay setOrientation:UIDeviceOrientationLandscapeLeft];
            [self.spinner setCenter:self.spinnerCenterLandscape];
            [self.sectionIndexView setCenter:CGPointMake(self.sectionIndexView.frame.size.width/2.0f, self.sectionIndexView.frame.size.height/2.0f)];
            [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];

            break;

        case UIDeviceOrientationLandscapeRight:
            NSLog(@"LandscapeR");
            theOrientation = UIDeviceOrientationLandscapeLeft;
            transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
            [self.overlay setOrientation:UIDeviceOrientationLandscapeLeft];
            [self.spinner setCenter:self.spinnerCenterLandscape];
            [self.sectionIndexView setCenter:CGPointMake(self.sectionIndexView.frame.size.width/2.0f, self.sectionIndexView.frame.size.height/2.0f)];
            [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];

            break;
        
        case UIDeviceOrientationPortrait:
            NSLog(@"portrait");
            theOrientation = UIDeviceOrientationPortrait;
            transform = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0f);
            [self.overlay setOrientation:UIDeviceOrientationPortrait];
            [self.spinner setCenter:self.spinnerCenterPortrait];
            [self.sectionIndexView setCenter:CGPointMake(self.view.frame.size.width-self.sectionIndexView.frame.size.width/2.0f, self.sectionIndexView.frame.size.height/2.0f)];
            [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];

            break;
        
        case UIDeviceOrientationPortraitUpsideDown:
            NSLog(@"portrait upsidedown");
            theOrientation = UIDeviceOrientationPortrait;
            transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
            [self.overlay setOrientation:UIDeviceOrientationPortrait];
            [self.spinner setCenter:self.spinnerCenterPortrait];
            [self.sectionIndexView setCenter:CGPointMake(self.view.frame.size.width-self.sectionIndexView.frame.size.width/2.0f, self.sectionIndexView.frame.size.height/2.0f)];
            [self.sectionIndexView establishMarkersWithDataSource:self.dataSource collectionView:self.collectionView];

            break;
        
        default:
            return;
    }
    [UIView animateWithDuration:ROT_DURATION delay:0.0f options:ROT_OPTIONS
					 animations:^{
                         [self.view setTransform:transform];

                     } completion:^(BOOL completed) {

                     }
     
     ];

    // none of these work
    //[self.collectionView.collectionViewLayout invalidateLayout];
    //[self.collectionViewLayout invalidateLayout];
    [self.singlePanelFlow invalidateLayout];
    //[self.collectionView reloadData];
}

- (void)invalidate
{
    [self.collectionViewLayout invalidateLayout];
}
@end