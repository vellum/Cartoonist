//
//  VLMCollectionViewCell.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kItemPadding 10.0f
#define kItemPaddingBottom 10.0f
#define kItemSize CGSizeMake(320, 568-36)

@interface VLMCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImage *image;

@end
