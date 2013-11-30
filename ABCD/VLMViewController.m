//
//  VLMViewController.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMViewController.h"
#import <objc/runtime.h>

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
    [flow setSectionInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    [flow setMinimumInteritemSpacing:0.0f];
    [flow setMinimumLineSpacing:0.0f];
    [flow setItemSize:kItemSize];
    [self setSinglePanelFlow:flow];
    
    CollectionViewCellConfigureBlock configureCellBlock = ^(VLMCollectionViewCell *cell, VLMPanelModel *photo)
    {
        //[cell configureImage:photo.name];
    };
    
    CollectionViewCellConfigureBlock configureCellChoiceBlock = ^(VLMCollectionViewCellWithChoices *cell, VLMPanelModel *photo)
    {
        [self.capture addHorizontalGestureRecognizer:cell.scrollview.panGestureRecognizer];
        NSLog(@"here");
    };

    VLMDataSource *ds = [[VLMDataSource alloc] initWithItems:nil cellIdentifier:CellIdentifier cellChoiceIdentifier:CellChoiceIdentifier configureCellBlock:configureCellBlock configureCellChoiceBlock:configureCellChoiceBlock];
    [self setDataSource:ds];

    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.singlePanelFlow];
    [cv setDataSource:ds];
    //[cv setDelegate:self];
    [cv setContentOffset:CGPointMake(0, kItemPaddingBottom)];
    [cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    [cv registerClass:[VLMCollectionViewCellWithChoices class] forCellWithReuseIdentifier:CellChoiceIdentifier];
    [cv setBackgroundColor:[UIColor clearColor]];
    [cv.panGestureRecognizer setEnabled:NO];
    [cv setClipsToBounds:NO];
    [cv setContentInset:UIEdgeInsetsMake(kItemPaddingBottom+3, 0, kItemPaddingBottom, 0)];
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
    
    
}

#pragma mark - secret scrollview delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ( scrollView != self.secretScrollview ) return;
    
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat page = contentOffset.y/scrollView.frame.size.height;
    CGFloat delta = page - self.currentPage;
    BOOL currentPageIsZoomedOut = (self.currentPage==2);
    BOOL nextPageIsZoomedOut = NO;
    
    CGFloat zoomedoutscale = 0.875f;
    
    
    if ( delta > 0 ){
            
            if ( fabs(delta) < 1 ) {
                nextPageIsZoomedOut = ( currentPage+1 == 2 );
                if (!currentPageIsZoomedOut) {
                    if (nextPageIsZoomedOut){
                        CGFloat s = zoomedoutscale + (1-zoomedoutscale) * (1 - delta);
                        if ( s < zoomedoutscale ) s = zoomedoutscale;
                        if ( s > 1.0f ) s = 1.0f;
                        [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
                        
                        [self.overlay setAlpha:delta];

                    }
                } else {
                    if (!nextPageIsZoomedOut){
                        CGFloat s = zoomedoutscale + (1-zoomedoutscale) * (delta);
                        if ( s < zoomedoutscale ) s = zoomedoutscale;
                        if ( s > 1.0f ) s = 1.0f;
                        [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];

                        [self.overlay setAlpha:1-delta];

                    }
                }
                
            } else {
                [self setCurrentPage:floorf(page)];
            }
            
        } else {
            
            if (fabs(delta) < 1)
            {
                nextPageIsZoomedOut = ( self.currentPage-1 == 2 );
                if ( !currentPageIsZoomedOut )
                {
                    if ( nextPageIsZoomedOut )
                    {
                        CGFloat s = zoomedoutscale + (1-zoomedoutscale) * (1-fabs(delta));
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        [self.collectionView.layer setTransform:t];
                        [self.overlay setAlpha:fabs(delta)];
                    }
                }
                else
                {
                    if (!nextPageIsZoomedOut)
                    {
                        CGFloat s = zoomedoutscale + (1-zoomedoutscale) * (fabs(delta));
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        [self.collectionView.layer setTransform:t];
                        [self.overlay setAlpha:1-fabs(delta)];
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
    [self setCurrentPage:scrollView.contentOffset.y/scrollView.frame.size.height];
    if (self.currentPage == 2)
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

