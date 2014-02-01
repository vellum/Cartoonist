//
//  VLMSectionIndex.m
//  Cartoonist
//
//  Created by David Lu on 1/30/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMSectionIndex.h"
#import "VLMDataSource.h"
#import "VLMConstants.h"
#import "VLMViewController.h"

@interface VLMSectionIndex()
@property  NSInteger numSections;
@property (nonatomic, strong) UIView *back;
@property (nonatomic, strong) UIView *contentView;
@end

@implementation VLMSectionIndex

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        [self setUserInteractionEnabled:NO];
        [self setAlpha:0.0f];
        [self setHidden:YES];
        
        self.back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.back setBackgroundColor:[UIColor blackColor]];
        [self.back setUserInteractionEnabled:NO];
        [self.back setAlpha:0.0f];
        [self addSubview:self.back];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.contentView];

        UIPanGestureRecognizer *pgr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [pgr setCancelsTouchesInView:NO];
        [pgr setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:pgr];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] != 1) {
        return;
    }
    [UIView animateWithDuration:ZOOM_DURATION * 0.0f
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.back setAlpha:0.125f];
                     }
					 completion:^(BOOL completed) {
                     }
     ];
    [self handleTouchAt:[[touches anyObject] locationInView:self]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.back setAlpha:0.0f];
                     }
					 completion:^(BOOL completed) {
                     }
     ];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self.back setAlpha:0.0f];
                     }
					 completion:^(BOOL completed) {
                     }
     ];
}

- (void)handleTouch:(UITouch *)touch
{
    CGPoint touchwhere = [touch locationInView:self];
    CGFloat pctY = touchwhere.y / self.frame.size.height;
    
    if (self.numSections) {
        CGFloat selected = floorf(pctY * self.numSections);
        if (self.selectionBlock) {
            self.selectionBlock(selected);
        }
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)pgr
{
    CGPoint touchwhere = [pgr locationInView:self];
    [self handleTouchAt:touchwhere];
}

- (void)handleTouchAt:(CGPoint)touchwhere
{
    CGFloat pctY = touchwhere.y / self.frame.size.height;
    if (self.numSections) {
        CGFloat selected = floorf(pctY * self.numSections);
        if (self.selectionBlock) {
            self.selectionBlock(selected);
        }
    }
}

- (void)establishMarkersWithDataSource:(VLMDataSource *)dataSource collectionView:(UICollectionView *)cv
{
    [[self.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    NSInteger count = [dataSource numberOfSectionsInCollectionView:cv];
    self.numSections = count;
    CGSize size = self.frame.size;
    CGSize unitsize = CGSizeMake(size.width, size.height/(CGFloat)count);
    CGFloat x = roundf(unitsize.width/2.0f);
    for (NSInteger i = 0; i < count; i++)
    {
        BOOL isMarker = [dataSource isItemAtIndexChoice:i];
        if (isMarker) {
            CGPoint center = CGPointMake(x, unitsize.height*i+unitsize.height/2.0f);
            UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1, 1)];
            [v.layer setCornerRadius:0.5f];
            [v setUserInteractionEnabled:NO];
            [v setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.75f]];

            [v setCenter:center];
            [self.contentView addSubview:v];
        }
    }
}

- (void)hide
{
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:0.0f];
                     }
					 completion:^(BOOL completed) {
                         [self setHidden:YES];
                     }
     ];
}

- (void)show
{
    [self setUserInteractionEnabled:YES];
    [self setHidden:NO];
    [UIView animateWithDuration:ZOOM_DURATION
						  delay:0.0f
						options:ZOOM_OPTIONS
					 animations:^{
                         [self setAlpha:1.0f];
                     }
					 completion:^(BOOL completed) {
                     }
     ];
}
@end
