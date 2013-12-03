//
//  VLMCollectionViewCellWithChoices.h
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ChoosePageBlock)(CGFloat page, NSString *text);

@interface VLMCollectionViewCellWithChoices : UICollectionViewCell<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollview;
@property (nonatomic, copy) ChoosePageBlock choosePageBlock;

- (void)setDelegate:(id)scrollViewDelegate;

@end
