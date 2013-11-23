//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"

@interface VLMCollectionViewCell()
@end

@implementation VLMCollectionViewCell
@synthesize label;

- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;

    CGFloat pad = kItemPadding;

    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, kItemSize.width-pad*2, kItemSize.height-kItemPaddingBottom)];
    [v setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    [v setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.contentView addSubview:v];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    
    [self setLabel:[[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)]];
    [self.label setTextColor:[UIColor blackColor]];
    [self.label setFont:[UIFont fontWithName:@"Helvetica-Bold" size:36.0f]];
    [self.label setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [self.label setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:self.label];
    return self;
}

-(void)prepareForReuse
{
    [self.label setText:@""];
    [super prepareForReuse];
}

-(void)layoutSubviews
{
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
