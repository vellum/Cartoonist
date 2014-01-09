//
//  VLMGenericFlowLayout.h
//  ABCD
//
//  Created by David Lu on 11/21/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^CheckOverviewBlock)();

@interface VLMSinglePanelFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, copy) CheckOverviewBlock checkOverviewBlock;

- (CGFloat)scale;
- (void)setScale:(CGFloat)value;

@end
