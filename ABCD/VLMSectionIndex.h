//
//  VLMSectionIndex.h
//  Cartoonist
//
//  Created by David Lu on 1/30/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VLMDataSource;
typedef void (^SectionIndexSelectionBlock)(CGFloat page);

@interface VLMSectionIndex : UIView

@property (nonatomic, copy) SectionIndexSelectionBlock selectionBlock;
- (void)establishMarkersWithDataSource:(VLMDataSource *)dataSource collectionView:(UICollectionView *)cv;
- (void)show;
- (void)hide;
@end
