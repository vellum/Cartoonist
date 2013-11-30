//
//  VLMCollectionViewCell.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kItemPadding 5.0f
#define kItemPaddingBottom 5.0f
#define kItemSize CGSizeMake(320, 568-20)

@interface VLMCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UIView *caption;
@property (nonatomic, strong) NSString *imagename;
@property (nonatomic, strong) UIView *base;

- (void)configureImage:(NSString *)filename;

@end
