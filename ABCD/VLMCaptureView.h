//
//  VLMCaptureView.h
//  Cartoonist
//
//  Created by David Lu on 11/22/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VLMCaptureView:UIView <UIGestureRecognizerDelegate>

- (void)addHorizontalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)addVerticalGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)removeAnyHorizontalGestureRecognizers;

@end
