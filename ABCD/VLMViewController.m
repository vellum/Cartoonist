//
//  VLMViewController.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMViewController.h"
#import <objc/runtime.h>

// Views
#import "VLMCollectionViewCell.h"
#import "VLMCollectionViewCellWithChoices.h"
#import "VLMCaptureView.h"
#import "VLMGradient.h"

// Models
#import "VLMFrameModel.h"
#import "VLMSelectionModel.h"

//
@interface VLMViewController ()
@property (nonatomic, strong) UICollectionViewFlowLayout *flowA;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowB;
@property (nonatomic, strong) VLMCaptureView *capture;
@property (nonatomic, strong) UIScrollView *secretScrollview;
@property (nonatomic, strong) VLMGradient *overlay;
@property CGFloat currentpage;
- (void)setupModel;
@end

@implementation VLMViewController
@synthesize flowA;
@synthesize capture;
@synthesize secretScrollview;
@synthesize currentpage;
@synthesize overlay;

//Static identifiers for cells and supplementary views
static NSString *CellIdentifier = @"CellIdentifier";
static NSString *HeaderIdentifier = @"HeaderIdentifier";
static NSString *CellChoiceIdentifier = @"CellChoiceIdentifier";

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)loadView{

    [self setCurrentpage:0];
    [self setNeedsStatusBarAppearanceUpdate];

    [self setFlowA:[[UICollectionViewFlowLayout alloc] init]];
    [self.flowA setSectionInset: UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.flowA setMinimumInteritemSpacing:0.0f];
    [self.flowA setMinimumLineSpacing:0.0f];
    [self.flowA setItemSize:kItemSize];
    
    //Create a new collection view with our flow layout and set ourself as delegate and data source
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowA];
    [cv setDataSource:self];
    [cv setDelegate:self];
    [cv setContentOffset:CGPointMake(0, kItemPaddingBottom)];
    
    //Register our classes so we can use our custom subclassed cell and header
    [cv registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    [cv registerClass:[VLMCollectionViewCellWithChoices class] forCellWithReuseIdentifier:CellChoiceIdentifier];

    [cv setBackgroundColor:[UIColor clearColor]];
    
    
    //Finally, set our collectionView (since we are a collection view controller, this also sets self.view)
    [self setCollectionView:cv];
}

- (void)viewDidLoad{
    
    [self setOverlay:[[VLMGradient alloc] initWithFrame:self.view.frame]];
    [self.overlay setAlpha:0.0f];
    [self.view addSubview:self.overlay];
    
    [self setSecretScrollview:[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)]];
    [self.secretScrollview setContentSize:CGSizeMake(kItemSize.width, kItemSize.height * [self numberOfSectionsInCollectionView:self.collectionView])];
    [self.secretScrollview setPagingEnabled:YES];
    [self.secretScrollview setDelegate:self];
    
    [self.collectionView.panGestureRecognizer setEnabled:NO];
    [self.collectionView setClipsToBounds:NO];
    [self.collectionView setContentInset:UIEdgeInsetsMake(kItemPaddingBottom+3, 0, kItemPaddingBottom, 0)];
    
    [self setCapture:[[VLMCaptureView alloc] initWithFrame:self.view.frame]];
    [self.capture setBackgroundColor:[UIColor clearColor]];
    [self.capture addVerticalGestureRecognizer:secretScrollview.panGestureRecognizer];
    [self.view addSubview:self.capture];
}

#pragma mark - secret scrollview delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if ( scrollView != self.secretScrollview ) return;
    
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat page = contentOffset.y/scrollView.frame.size.height;
    CGFloat delta = page - self.currentpage;
    BOOL currentPageIsZoomedOut = (self.currentpage==2);
    BOOL nextPageIsZoomedOut = NO;
    
    if ( delta > 0 ){
            
            if ( fabs(delta) < 1 ) {
                nextPageIsZoomedOut = ( currentpage+1 == 2 );
                if (!currentPageIsZoomedOut) {
                    if (nextPageIsZoomedOut){
                        CGFloat s = 0.9f + 0.1f * (1 - delta);
                        if ( s < 0.9f ) s = 0.9f;
                        if ( s > 1.0f ) s = 1.0f;
                        [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];
                        
                        [self.overlay setAlpha:delta];

                    }
                } else {
                    if (!nextPageIsZoomedOut){
                        CGFloat s = 0.9f + 0.1f * (delta);
                        if ( s < 0.9f ) s = 0.9f;
                        if ( s > 1.0f ) s = 1.0f;
                        [self.collectionView.layer setTransform:CATransform3DScale(CATransform3DIdentity, s, s, 1.0f)];

                        [self.overlay setAlpha:1-delta];

                    }
                }
                
            } else {
                [self setCurrentpage:floorf(page)];
            }
            
        } else {
            
            if (fabs(delta) < 1) {
                nextPageIsZoomedOut = ( self.currentpage-1 == 2 );
                if ( !currentPageIsZoomedOut ){
                    if ( nextPageIsZoomedOut ){
                        CGFloat s = 0.9f + 0.1f * (1-fabs(delta));
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        [self.collectionView.layer setTransform:t];

                        [self.overlay setAlpha:fabs(delta)];

                    }
                } else {
                    if (!nextPageIsZoomedOut){
                        CGFloat s = 0.9f + 0.1f * (fabs(delta));
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        [self.collectionView.layer setTransform:t];

                        [self.overlay setAlpha:1-fabs(delta)];

                    }
                }

            } else {
                [self setCurrentpage:floorf(page)];
            }
        }
        contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
        [self.collectionView setContentOffset:contentOffset];
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat page = contentOffset.y/scrollView.frame.size.height;
    [self setCurrentpage:page];

    
    if (page == 2) {
        [self.capture enableHorizontalPan:YES];
    } else {
        [self.capture enableHorizontalPan:NO];
    }
    /*
    UICollectionViewCell *cell = [self collectionView:self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:page]];
    if ([cell isKindOfClass:[VLMCollectionViewCellWithChoices class]]) {
        
    }
    */
}

#pragma mark - UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 10;
    //Return the smallest of either our curent model index plus one, or our total number of sections.
    //This will show 1 section when we only want to display section zero, etc.
    //It will prevent us from returning 11 when we only have 10 sections.
    //return MIN(currentModelArrayIndex + 1, selectionModelArray.count);
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return 1;
    //Return the number of photos in the section model
    //return [[selectionModelArray[currentModelArrayIndex] models] count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section != 2) {

        VLMCollectionViewCell *cell = (VLMCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        [self configureCell:cell forIndexPath:indexPath];
        [cell.label setText:[NSString stringWithFormat:@"%i", indexPath.section]];
        return cell;

    }

    VLMCollectionViewCellWithChoices *cell = (VLMCollectionViewCellWithChoices *)[collectionView dequeueReusableCellWithReuseIdentifier:CellChoiceIdentifier forIndexPath:indexPath];
    [self.capture addHorizontalGestureRecognizer:cell.scrollview.panGestureRecognizer];
    return cell;
}


#pragma mark - Private Custom Methods

//A handy method to implement — returns the photo model at any index path
-(VLMFrameModel *)photoModelForIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

//Configures a cell for a given index path
-(void)configureCell:(VLMCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
}

- (void)setupModel
{
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

