//
//  VLMCollectionViewCell.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMConstants.h"
#import "VLMPanelModel.h"

@class VLMNarrationCaption;
@class VLMPaddedLabel;

@interface VLMCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIView *base;
@property (nonatomic) CGRect coverFrame;
@property (nonatomic) CGRect normalFrame;
@property (nonatomic) CellType cellType;

- (void)configureWithModel:(VLMPanelModel *)model;
+ (CGSize)idealItemSize;
+ (NSString *)CellIdentifier;
+ (CGFloat)itemPadding;
@end
