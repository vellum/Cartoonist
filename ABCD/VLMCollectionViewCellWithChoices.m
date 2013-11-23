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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setScrollview:[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kItemSize.width, kItemSize.height)]];
        [self.scrollview setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self.scrollview setAutoresizesSubviews:NO];
        [self.scrollview setBackgroundColor:[UIColor clearColor]];
        [self.scrollview setClipsToBounds:NO];
        [self.scrollview setContentSize:CGSizeMake(kItemSize.width*2, kItemSize.height)];
        [self.scrollview setPagingEnabled:YES];
        [self.scrollview setShowsHorizontalScrollIndicator:NO];
        [self.contentView addSubview:self.scrollview];
        
        UIView *A = [[UIView alloc] initWithFrame:CGRectMake(kItemPadding, kItemPadding, kItemSize.width-kItemPadding*2, kItemSize.height-kItemPaddingBottom)];
        [A setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [self.scrollview addSubview:A];
        
        UIView *B = [[UIView alloc] initWithFrame:CGRectMake(kItemSize.width+kItemPadding, kItemPadding, kItemSize.width-kItemPadding*2, kItemSize.height-kItemPaddingBottom)];
        [B setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
        [self.scrollview addSubview:B];
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

@end
