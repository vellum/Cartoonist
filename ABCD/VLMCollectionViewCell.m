//
//  VLMCollectionViewCell.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewCell.h"

@implementation VLMCollectionViewCell
{
    UIImageView *imageView;
}


- (id)initWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame])) return nil;

    //imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    //imageView.backgroundColor = [UIColor colorWithWhite:0.9f alpha:1.0f];
    //imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //[self.contentView addSubview:imageView];
    
    CGFloat pad = kItemPadding;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(pad, pad, kItemSize.width-pad*2, kItemSize.height-kItemPaddingBottom)];
    [v setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:1.0f]];
    v.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //[v.layer setCornerRadius:4.0f];
    //[v.layer setShouldRasterize:YES];
    [self.contentView addSubview:v];
    [self.contentView setBackgroundColor:[UIColor clearColor]];
    
    return self;
}



-(void)prepareForReuse
{
    [super prepareForReuse];
    [self setImage:nil];
}

-(void)layoutSubviews
{
    //imageView.frame = CGRectInset(self.bounds, 10, 10);
}

-(void)setImage:(UIImage *)image
{
    _image = image;
    imageView.image = image;
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
