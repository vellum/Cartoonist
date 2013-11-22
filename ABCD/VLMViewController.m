//
//  VLMViewController.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMViewController.h"

//Views
#import "VLMCollectionViewCell.h"

//Models
#import "VLMFrameModel.h"
#import "VLMSelectionModel.h"



// private methods
@interface VLMViewController (Private)
- (void)setupModel;
@end

// public methods
@interface VLMViewController ()
@property (nonatomic, strong) UICollectionViewFlowLayout *flowA;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowB;

@end


// storing internal state
@implementation VLMViewController{

    // array of selection objects
    // i'm thinking that each model contains one (a frame) or many options (a joint on decision tree)
    NSArray *selectionModelArray;
    
    // current index within the selectionModelArray
    NSUInteger currentModelArrayIndex;
    
    UIScrollView *secretScrollview;
    
    CGFloat currentpage;
    
}
@synthesize flowA;
@synthesize flowB;

//Static identifiers for cells and supplementary views
static NSString *CellIdentifier = @"CellIdentifier";
static NSString *HeaderIdentifier = @"HeaderIdentifier";

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)loadView{
    currentpage = 0;
    [self setNeedsStatusBarAppearanceUpdate];

    UICollectionViewFlowLayout *a = [[UICollectionViewFlowLayout alloc] init];
    self.flowA = a;
    self.flowA.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.flowA.minimumInteritemSpacing = 0.0f;
    self.flowA.minimumLineSpacing = 0.0f;
    self.flowA.itemSize = kItemSize;

    self.flowB = [[UICollectionViewFlowLayout alloc] init];
    self.flowB.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.flowB.minimumInteritemSpacing = 0.0f;
    self.flowB.minimumLineSpacing = 0.0f;
    self.flowB.itemSize = CGSizeMake(320, 440);

    
    //Create a new collection view with our flow layout and set ourself as delegate and data source
    UICollectionView *surveyCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowA];
    surveyCollectionView.dataSource = self;
    surveyCollectionView.delegate = self;
    surveyCollectionView.contentOffset = CGPointMake(0, kItemPaddingBottom);
    
    //Register our classes so we can use our custom subclassed cell and header
    [surveyCollectionView registerClass:[VLMCollectionViewCell class] forCellWithReuseIdentifier:CellIdentifier];
    
    //Set up the collection view geometry to cover the whole screen in any orientation and other view properties
    //surveyCollectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //surveyCollectionView.opaque = NO;
    //surveyCollectionView.backgroundColor = [UIColor clearColor];
    surveyCollectionView.backgroundColor = [UIColor redColor];
    
    
    //Finally, set our collectionView (since we are a collection view controller, this also sets self.view)
    self.collectionView = surveyCollectionView;
    
    //Set up our model
    [self setupModel];
    
    //We start at zero
    currentModelArrayIndex = 0;
    
    
    
    
    
    
    
    
}

- (void)viewDidLoad{
    secretScrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)];
    // should reference numitems in section
    secretScrollview.contentSize = CGSizeMake(kItemSize.width, kItemSize.height*10);
    secretScrollview.pagingEnabled = YES;
    [secretScrollview setDelegate:self];
    
    
    //[self.collectionView addGestureRecognizer:secretScrollview.panGestureRecognizer];
    [self.collectionView.panGestureRecognizer setEnabled:NO];
    [self.collectionView setClipsToBounds:NO];
    
    
    UIView *capture = [[UIView alloc] initWithFrame:self.view.frame];
    [capture setBackgroundColor:[UIColor colorWithRed:1 green:0 blue:0 alpha:0.5]];
    [self.view addSubview:capture];
    
    [capture addGestureRecognizer:secretScrollview.panGestureRecognizer];
    
    //UICollectionView *a = self.collectionView;
    self.collectionView.contentInset = UIEdgeInsetsMake(kItemPaddingBottom+3, 0, kItemPaddingBottom, 0);

    //CATransform3D t = CATransform3DScale(a.layer.transform, 0.75f, 0.75f, 1.0f);
    //a.layer.transform = t;
    
}

#pragma mark - secret scrollview delegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == secretScrollview) { //ignore collection view scrolling callbacks
        CGPoint contentOffset = scrollView.contentOffset;
        
        CGFloat page = contentOffset.y/scrollView.frame.size.height;
        //NSLog(@"known page: %f, scrollval %f",currentpage   ,page);
        
        //NSLog(@"delta %f", page-currentpage);
        /*
        if (floorf(page)==2) {
            contentOffset.y = contentOffset.y - kItemPaddingBottom * 2  ;
            self.collectionView.contentOffset = contentOffset;
        } else {
            contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
            self.collectionView.contentOffset = contentOffset;
        }
         */
        CGFloat delta = page - currentpage;
        
        BOOL currentPageIsZoomedOut = (currentpage==2);
        BOOL nextPageIsZoomedOut = NO;
        
        NSLog(@"%f", delta);
        
        
        
        if ( delta > 0 ){

            if ( fabs(delta) < 1 ) {
                nextPageIsZoomedOut = ( currentpage+1 == 2 );
                if (!currentPageIsZoomedOut) {
                    if (nextPageIsZoomedOut){
                        
                        CGFloat s = 0.9f + 0.1f * (1 - delta);
                        if ( s < 0.9f ) s = 0.9f;
                        if ( s > 1.0f ) s = 1.0f;
                        self.collectionView.layer.transform = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        
                    }
                } else {
                    if (!nextPageIsZoomedOut){
                        CGFloat s = 0.9f + 0.1f * (delta);
                        if ( s < 0.9f ) s = 0.9f;
                        if ( s > 1.0f ) s = 1.0f;
                        self.collectionView.layer.transform = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                    }
                }
                
            } else {
                currentpage = floorf(page);
                nextPageIsZoomedOut = ( currentpage+1 == 2 );
                /*
                if (nextPageIsZoomedOut){
                    [UIView animateWithDuration:0.5f animations:^{
                        self.collectionView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 1.0f);
                    }];
                } else {
                    [UIView animateWithDuration:0.5f animations:^{
                        self.collectionView.layer.transform = CATransform3DIdentity;
                    }];
                }
                 */
            }
            
        } else {
            
            if (fabs(delta) < 1) {
                
                nextPageIsZoomedOut = ( currentpage-1 == 2 );
                
                if ( !currentPageIsZoomedOut ){
                    if ( nextPageIsZoomedOut ){
                        CGFloat s = 0.9f + 0.1f * (1-fabs(delta));
                        UIView *a = self.collectionView;
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        a.layer.transform = t;
                    }
                } else {
                    if (!nextPageIsZoomedOut){
                        CGFloat s = 0.9f + 0.1f * (fabs(delta));
                        UIView *a = self.collectionView;
                        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
                        a.layer.transform = t;
                    }
                }

            } else {
                currentpage = floorf(page);
                nextPageIsZoomedOut = ( currentpage-1 == 2 );
                /*
                if (nextPageIsZoomedOut){
                    [UIView animateWithDuration:0.5f animations:^{
                        self.collectionView.layer.transform = CATransform3DScale(CATransform3DIdentity, 0.9, 0.9, 1.0f);
                    }];
                } else {
                    [UIView animateWithDuration:0.5f animations:^{
                        self.collectionView.layer.transform = CATransform3DIdentity;
                    }];
                }
                 */
            }
        }
        
        //CGFloat h = self.collectionView.frame.size.height;
        //contentOffset.y /= scrollView.frame.size.height;
        //contentOffset.y *= h;
        contentOffset.y = contentOffset.y - self.collectionView.contentInset.top;
        self.collectionView.contentOffset = contentOffset;
    }
}

- (void) scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    CGFloat page = targetContentOffset->y/scrollView.frame.size.height;
    page = floorf(page);
    //currentpage = page;
    NSLog(@"newpage: %f", page);
    /*
    if ( page == 2 ){
        
        //[self.flowA invalidateLayout];
        //[self.collectionView setCollectionViewLayout:self.flowB animated:YES];
        self.collectionView.contentOffset = CGPointMake(0, kItemPaddingBottom);

        CGFloat s = 0.9f;
        UIView *a = self.collectionView;
        CGFloat x = -16.0f - 2;//-20;
        CGFloat y = -32.0f;
        CGFloat w = 320.0f * 1.0f/s;
        CGFloat h = 568.0f * 1.0f/s;
        a.frame = CGRectMake(x, y, w, h);
        self.collectionView.contentOffset = CGPointMake(0, kItemPaddingBottom/s);
        CATransform3D t = CATransform3DScale(CATransform3DIdentity, s, s, 1.0f);
        a.layer.transform = t;

        

    } else {
        self.collectionView.contentOffset = CGPointMake(0, 0);
        UIView *a = self.collectionView;
        a.layer.transform = CATransform3DIdentity;
        a.frame = CGRectMake(0, 0, 320, 568);
        
    }
     */
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //CGFloat page = scrollView.contentOffset.y/scrollView.frame.size.height;
    //page = floorf(page);
    //currentpage = page;
    NSLog(@"did end decel");
    
    CGPoint contentOffset = scrollView.contentOffset;
    CGFloat page = contentOffset.y/scrollView.frame.size.height;
    currentpage = page;
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
    VLMCollectionViewCell *cell = (VLMCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    //Configure the cell
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}


#pragma mark - Private Custom Methods

//A handy method to implement — returns the photo model at any index path
-(VLMFrameModel *)photoModelForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= selectionModelArray.count) return nil;
    if (indexPath.row >= [[selectionModelArray[indexPath.section] models] count]) return nil;
    
    return [selectionModelArray[indexPath.section] models][indexPath.item];
}

//Configures a cell for a given index path
-(void)configureCell:(VLMCollectionViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    //Set the image for the cell
    [cell setImage:[[self photoModelForIndexPath:indexPath] image]];
    
    //By default, assume the cell is not disabled and not selected

    //If the cell is not in our current last index, disable it
    if (indexPath.section < currentModelArrayIndex)
    {
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end

@implementation VLMViewController(Private)
- (void)setupModel{
    NSMutableArray *mutableArray = [NSMutableArray array];
    
    [mutableArray addObjectsFromArray:@[
    [VLMSelectionModel selectionModelWithPhotoModels:@[[VLMFrameModel frameModelWithName:@"A" image:Nil]]],
    [VLMSelectionModel selectionModelWithPhotoModels:@[[VLMFrameModel frameModelWithName:@"B" image:Nil]]],
    [VLMSelectionModel selectionModelWithPhotoModels:@[[VLMFrameModel frameModelWithName:@"C" image:Nil]]],
    [VLMSelectionModel selectionModelWithPhotoModels:@[[VLMFrameModel frameModelWithName:@"D" image:Nil]]]]];
    
    
    
    selectionModelArray = [NSArray arrayWithArray:mutableArray];

}
@end
