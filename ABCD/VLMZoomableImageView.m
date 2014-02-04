//
//  VLMZoomableImageView.m
//  Cartoonist
//
//  Created by David Lu on 2/3/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMZoomableImageView.h"
#import "VLMConstants.h"
#import "UIScrollView+BDDRScrollViewAdditions.h"

@interface VLMZoomableImageView ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation VLMZoomableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor blackColor]];
        [self setUserInteractionEnabled:NO];
        [self setAlpha:0.0f];
        //[self setDelegate:self];
        
        [self setImageView:[[UIImageView alloc] initWithFrame:CGRectMake(0,0,1024,1024)]];
        [self.imageView setCenter:self.center];

        self.scrollView = [[UIScrollView alloc] initWithFrame:frame];
        self.scrollView.bddr_centersContent = YES;
        self.scrollView.bddr_doubleTapZoomInEnabled = YES;
        self.scrollView.bddr_doubleTapZoomsToMinimumZoomScaleWhenAtMaximumZoomScale = NO;
        self.scrollView.bddr_twoFingerZoomOutEnabled = YES;
        self.scrollView.bddr_oneFingerZoomEnabled = YES;
        
        //UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hide)];
        //[self addGestureRecognizer:tgr];
        
        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pgr];
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)pgr
{
    if (self.scrollView.zoomScale>1) {
        return;
    }
    CGPoint translation = [pgr translationInView:self];
    CGFloat alpha = 1 + (translation.y/320);

    switch (pgr.state) {
            case UIGestureRecognizerStateBegan:
            break;
            
            case UIGestureRecognizerStateChanged:
            if (alpha < 0) {
                alpha = 0;
            }
            [self setAlpha:alpha];
            // update outside
            break;
            
            case UIGestureRecognizerStateEnded:
            case UIGestureRecognizerStateCancelled:
            if (self.alpha<0.75) {
                [self hide];
                // update outside
            } else {
                [self show];
                // update outside
            }
            break;
        default:
            break;
    }
}

- (void)hide
{
    if (self.zoomOverlayHide) {
        self.zoomOverlayHide();
    }
    [self setUserInteractionEnabled:NO];
	[UIView animateWithDuration:ZOOM_DURATION*2
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:0.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

- (void)show
{
    [self setUserInteractionEnabled:YES];
	[UIView animateWithDuration:ZOOM_DURATION*2
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:1.0f];
                     }
     
					 completion:^(BOOL completed) {
                     }
     
     ];
}

- (void)showAlpha:(CGFloat)alpha
{
    self.scrollView.zoomScale = 1.0f;
    [self setAlpha:alpha];
    [self setUserInteractionEnabled:NO];
}

- (void) setAlpha:(CGFloat)alpha{
    [super setAlpha:alpha];
    if (!self.imageView) {
        return;
    }
    alpha-=0.5f;
    if (alpha<0) {
        alpha=0;
    }
    alpha*=2.0f;
    [self.imageView setAlpha:alpha];
    if (self.userInteractionEnabled&&self.zoomOverlayChanged) {
        self.zoomOverlayChanged(self.alpha);
    }
}

- (void)setImage:(UIImage *)image
{
    if (![self.imageView.image isEqual:image]) {
        [self.imageView setImage:image];
        [self.imageView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.width)];
        [self.scrollView setMinimumZoomScale:0.5f];
        [self.scrollView setMaximumZoomScale:5.0f];
        [self.scrollView setContentSize:self.imageView.frame.size];
        [self.scrollView setBouncesZoom:YES];
        [self addSubview:self.scrollView];
        [self.scrollView addSubview:self.imageView];
        [self.scrollView setDelegate:self];
        [self.scrollView setBounces:YES];
    }
    [self.scrollView setZoomScale:1.0f];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"%f", scrollView.zoomScale);
    NSLog(@"%@", NSStringFromCGRect(self.imageView.frame));
    if (scrollView.zoomScale <= 1 ) {
        [self setAlpha:scrollView.zoomScale];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if (scale<1) {
        //[self.scrollView setZoomScale:1.0f animated:YES];
        [self hide];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
