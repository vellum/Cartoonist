//
//  VLMZoomableImageView.m
//  Cartoonist
//
//  Created by David Lu on 2/3/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMZoomableImageView.h"
#import "VLMConstants.h"
#import "VLMCollectionViewCell.h"
#import "UIScrollView+BDDRScrollViewAdditions.h"
#import "VLMViewController.h"
#import "VLMCachableImageView.h"

@interface VLMZoomableImageView ()
@property (nonatomic, strong) VLMCachableImageView *imageView;
@property (nonatomic, strong) UIView *back;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation VLMZoomableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:NO];
        [self setAlpha:1.0f];
        
        [self setBack:[[UIView alloc] initWithFrame:frame]];
        [self.back setBackgroundColor:[UIColor blackColor]];
        [self.back setAlpha:0.0f];
        [self.back setUserInteractionEnabled:NO];
        [self addSubview:self.back];

        [self setContainer:[[UIView alloc] initWithFrame:CGRectZero]];
        [self.container setBackgroundColor:[UIColor clearColor]];
        [self.container setClipsToBounds:YES];
        [self.container setBackgroundColor:[UIColor clearColor]];
        [self.container setAutoresizesSubviews:NO];
        
        [self setImageView:[[VLMCachableImageView alloc] initWithFrame:CGRectZero]];
        [self.imageView setCenter:self.center];
        [self.imageView setAlpha:1.0f];
        [self.container addSubview:self.imageView];

        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.bddr_centersContent = YES;
        self.scrollView.bddr_doubleTapZoomInEnabled = NO;
        self.scrollView.bddr_doubleTapZoomsToMinimumZoomScaleWhenAtMaximumZoomScale = NO;
        self.scrollView.bddr_twoFingerZoomOutEnabled = YES;
        self.scrollView.bddr_oneFingerZoomEnabled = NO;
        
        UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
        [tgr setNumberOfTouchesRequired:1.0f];
        [self addGestureRecognizer:tgr];
        
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        //[self addGestureRecognizer:pgr];
        
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.container];
    }
    return self;
}

- (void)hide
{
    CGSize s = kItemSize;
    s.width = s.height-kItemPadding*2;
    
    CGRect f = CGRectMake(0,
                          0,
                          s.width,
                          s.height);
    
    if (self.zoomOverlayHide) {
        self.zoomOverlayHide();
    }

	[UIView animateWithDuration:ZOOM_DURATION*1.0f
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         if (self.scrollView.zoomScale!=1) {
                             [self.scrollView setZoomScale:1.0f];
                         }
                         [self.container setFrame:f];
                         [self.container setCenter:self.center];
                         
                         [self.imageView setFrame:CGRectMake(0, 0, s.width, s.width)];
                         [self.imageView setCenter:CGPointMake(
                                       self.container.frame.size.width/2,
                                       self.container.frame.size.height/2)];
                     }
     
					 completion:^(BOOL completed) {
                         [self setUserInteractionEnabled:NO];
                     }
     ];
    
    [UIView animateWithDuration:ZOOM_DURATION*2.0f
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.container setAlpha:0.0f];
                     }
     
					 completion:^(BOOL completed) {
                         [self setUserInteractionEnabled:NO];
                     }
     ];
    
    [UIView animateWithDuration:ZOOM_DURATION*1.0f
						  delay:ZOOM_DURATION*1.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.back setAlpha:0];
                     }
     
					 completion:^(BOOL completed) {
                     }
     ];
}

- (void)show
{
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.back setAlpha:1.0f];
                         [self.container setAlpha:1.0f];
                         [self.container setFrame:self.frame];
                         [self.imageView setFrame:CGRectMake(
                             0,
                             (self.frame.size.height-self.frame.size.width)/2.0f,
                             self.frame.size.width,
                             self.frame.size.width)];
                     }
					 completion:^(BOOL completed) {
                         [self setUserInteractionEnabled:YES];
                         [self.scrollView setContentSize:self.frame.size];
                     }
     ];
}

- (void)showAlpha:(CGFloat)alpha
{
    [self setUserInteractionEnabled: NO];
    [self.scrollView setZoomScale: 1.0f];
    [self.back setAlpha:alpha*10.0f];
    [self.container setAlpha:alpha==0?0:1];

    CGSize s = kItemSize;
    s.width = s.width + (self.frame.size.width-s.width)*alpha - (1-alpha)*kItemPadding*2;
    s.height = s.height - (s.height-self.frame.size.width)*alpha;

    CGRect f = CGRectMake((self.frame.size.width-s.width)/2.0f-(1-alpha)*kItemPadding*1,
                          (self.frame.size.height-s.height)/2.0f,
                          s.width, s.height);

    [self.container setFrame:f];
    [self.container setCenter:self.center];
    CGFloat twidth = self.container.frame.size.height - alpha*(self.container.frame.size.height-self.container.frame.size.width);
    [self.imageView setFrame:CGRectMake((self.container.frame.size.width-twidth)/2.0f, (self.container.frame.size.height-twidth)/2.0f, twidth, twidth)];
    [self.scrollView setContentSize:self.frame.size];
}



- (void)loadImageNamed:(NSString *)imageName;
{
    [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.height, self.frame.size.height)];
    [self.imageView setCenter:self.center];
    [self.imageView loadImageNamed:imageName];
    
    [self.scrollView setMinimumZoomScale:0.5f];
    [self.scrollView setMaximumZoomScale:5.0f];
    [self.scrollView setContentSize:self.imageView.frame.size];
    [self.scrollView setBouncesZoom:YES];
    [self.scrollView setDelegate:self];
    [self.scrollView setBounces:YES];
    [self.scrollView setZoomScale:1.0f];
    
    CGAffineTransform t;
    if (UIDeviceOrientationIsPortrait([VLMViewController orientation]))
    {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, 0.0f);
    } else {
        t = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI/2.0f);
    }
    if (!CGAffineTransformEqualToTransform(self.imageView.transform, t)){
        self.imageView.transform = t;
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    if (!scrollView.userInteractionEnabled) {
        return nil;
    }
    return self.container;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scale<1) {
        [self hide];
    }
}

- (void)handleTap
{
    [self hide];
}

- (void)handlePan:(UIPanGestureRecognizer *)pgr
{
    CGPoint t = [pgr translationInView:self];
    t.y /= 160.0f;
    
    CGFloat alpha = -t.y;
    alpha = 1 - alpha;
    if (alpha<0) {
        alpha = 0;
    }
    if (alpha>1) {
        alpha=1;    
    }

    switch ([pgr state]) {
        case UIGestureRecognizerStateBegan:
            break;

        case UIGestureRecognizerStateChanged:
            [self showAlpha:alpha];
            break;
            
        case UIGestureRecognizerStateEnded:
            break;
            
        default:
            break;
    }
}

@end
