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

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"began");
    if ([touches count] != 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] != 1) {
        return;
    }
    UITouch *touch = [touches anyObject];
    [self handleTouch:touch];
}

- (void)handleTouch:(UITouch *)touch
{
    CGPoint touchwhere = [touch locationInView:self];
    CGFloat pctY = touchwhere.y / self.frame.size.height;
    
    if (self.numSections) {
        CGFloat selected = floorf(pctY * self.numSections);
        NSLog(@"move to %f", selected);
        if (self.selectionBlock) {
            NSLog(@"here");
            self.selectionBlock(selected);
        }
    }
}

- (void)establishMarkersWithDataSource:(VLMDataSource *)dataSource collectionView:(UICollectionView *)cv
{
	// remove all children
	//
    [[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSInteger count = [dataSource numberOfSectionsInCollectionView:cv];
    self.numSections = count;

    CGSize size = self.frame.size;
    CGSize unitsize = CGSizeMake(size.width, size.height/(CGFloat)count);
    CGFloat x = UIDeviceOrientationIsPortrait([VLMViewController orientation]) ? unitsize.width - 10 : 10;
    
    for (NSInteger i = 0; i < count; i++)
    {
        BOOL isMarker = [dataSource isItemAtIndexChoice:i];
        if (isMarker) {
            // put a marker in our view
            
            CGPoint center = CGPointMake(x, unitsize.height*i+unitsize.height/2.0f);
            UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 4, 4)];
            [v.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:0.25f].CGColor];
            [v.layer setBorderWidth:0.5f];
            [v.layer setCornerRadius:2.0f];
            [v setUserInteractionEnabled:NO];
            [v setBackgroundColor:[UIColor clearColor]];
            [v setCenter:center];
            [self addSubview:v];
        } else {
            
            CGPoint center = CGPointMake(x, unitsize.height*i+unitsize.height/2.0f);
            UIView *v = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 1, 1)];
            [v.layer setCornerRadius:1.0f];
            [v setUserInteractionEnabled:NO];
            [v setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:0.25f]];
            [v setCenter:center];
            [self addSubview:v];
            
        }
    }
}


- (void)hide{
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
- (void)show{
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
