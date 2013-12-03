//
//  VLMCollectionViewCellWithChoices.m
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCellWithChoices.h"
#import "VLMCollectionViewCell.h"

@interface VLMCollectionViewCellWithChoices()
@end

@implementation VLMCollectionViewCellWithChoices
@synthesize scrollview;
@synthesize choosePageBlock;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        [self setScrollview:[[UIScrollView alloc] initWithFrame:CGRectMake(kItemPadding, 0, kItemSize.width-kItemPadding, kItemSize.height)]];
        [self.scrollview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.scrollview setAutoresizesSubviews:NO];
        [self.scrollview setBackgroundColor:[UIColor clearColor]];
        [self.scrollview setClipsToBounds:NO];
        [self.scrollview setPagingEnabled:YES];
        [self.scrollview setShowsHorizontalScrollIndicator:NO];
        [self.scrollview setTag:1000];
        [self.scrollview setDelegate:self];
        [self.contentView addSubview:self.scrollview];
        
        NSInteger numPages = 3;
        [self.scrollview setContentSize:CGSizeMake((kItemSize.width-kItemPadding)*numPages, kItemSize.height)];
        for (NSInteger i = 0; i < numPages; i++)
        {
            UIView *B = [[UIView alloc] initWithFrame:CGRectMake((kItemSize.width-kItemPadding)*i, kItemPadding, kItemSize.width-kItemPadding*2, kItemSize.height-kItemPaddingBottom)];
            [B setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
            [self.scrollview addSubview:B];
        }
        
    }
    return self;
}

- (void)setDelegate:(id)scrollViewDelegate
{
    //[self.scrollview setDelegate:scrollViewDelegate];
}


#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"%f", scrollView.contentOffset.x);
    CGFloat page = scrollview.contentOffset.x / scrollview.frame.size.width;
    NSLog(@"%f", page);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"scrollviewdidend");
    CGFloat page = scrollview.contentOffset.x / scrollview.frame.size.width;
    if ( self.choosePageBlock ){
        self.choosePageBlock(page,[NSString stringWithFormat:@"%f", page]);
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
