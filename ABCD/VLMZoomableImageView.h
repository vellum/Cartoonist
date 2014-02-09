//
//  VLMZoomableImageView.h
//  Cartoonist
//
//  Created by David Lu on 2/3/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ZoomOverlayChanged)(CGFloat alpha);
typedef void (^ZoomOverlayHide)();


@interface VLMZoomableImageView : UIView<UIScrollViewDelegate>
- (void)hide;
- (void)show;
- (void)showAlpha:(CGFloat)alpha;
- (void)loadImageNamed:(NSString *)imageName;
@property (nonatomic, copy) ZoomOverlayChanged zoomOverlayChanged;
@property (nonatomic, copy) ZoomOverlayHide zoomOverlayHide;
@end
