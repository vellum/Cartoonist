//
//  VLMCaptureView.h
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZoomPageBlock)(CGFloat zoomBy);

@interface VLMCaptureView:UIView <UIGestureRecognizerDelegate>

@property (nonatomic, copy) ZoomPageBlock zoomPageBlock;

- (void)addHorizontalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)addVerticalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)removeAnyHorizontalGestureRecognizers;
- (void)enableHorizontalPan:(BOOL)shouldEnable;
@end
