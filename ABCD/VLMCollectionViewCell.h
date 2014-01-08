//
//  VLMCollectionViewCell.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMConstants.h"

@class VLMPanelModel;
@class VLMNarrationCaption;
@class VLMPaddedLabel;

@interface VLMCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *base;
@property (nonatomic, strong) VLMNarrationCaption *caption;
@property (nonatomic, strong) NSString *imagename;
@property (nonatomic, strong) UIImageView *imageview;
@property (nonatomic, strong) VLMPaddedLabel *label;

- (void)configureWithModel:(VLMPanelModel *)model;
+ (CGSize)idealItemSize;

@end
