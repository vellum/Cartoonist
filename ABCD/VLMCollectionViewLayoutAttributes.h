//
//  VLMCollectionViewLayoutAttributes.h
//  Cartoonist
//
//  Created by David Lu on 11/27/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMCollectionViewLayoutAttributes : UICollectionViewLayoutAttributes

@property (nonatomic, assign) CGFloat transitionValue;
@property (nonatomic, assign) CGFloat scaleValue;
@property (nonatomic, assign) UIDeviceOrientation orientationValue;
@property BOOL isOverview;
@end
