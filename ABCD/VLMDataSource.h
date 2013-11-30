//
//  VLMDataSource.h
//  Cartoonist
//
//  Created by David Lu on 11/29/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CollectionViewCellConfigureBlock)(id cell, id item);

@interface VLMDataSource : NSObject<UICollectionViewDataSource>

- (id)initWithItems:(NSArray *)anItems
        cellIdentifier:(NSString *)aCellIdentifier
        cellChoiceIdentifier:(NSString *)aCellChoiceIdentifier
        configureCellBlock:(CollectionViewCellConfigureBlock)aConfigureCellBlock
        configureCellChoiceBlock:(CollectionViewCellConfigureBlock)aConfigureCellChoiceBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)isItemAtIndexPathChoice:(NSIndexPath *)indexPath;
- (BOOL)isItemAtIndexChoice:(NSInteger)index;

@end
