//
//  VLMCollectionViewCell.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kItemPadding 9.0f
#define kItemPaddingBottom 9.0f
#define kItemSize CGSizeMake(320, 568.0f-2.0f*(9.0f+9.0f))

@class VLMPanelModel;
@class VLMNarrationCaption;

@interface VLMCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *base;
@property (nonatomic, strong) VLMNarrationCaption *caption;
@property (nonatomic, strong) NSString *imagename;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) UILabel *label;

- (void)configureWithModel:(VLMPanelModel *)model;


@end
