//
//  VLMAppDelegate.h
//  ABCD
//
//  Created by David Lu on 11/19/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SDWebImageManager.h"
@class VLMViewController;

@interface VLMAppDelegate : UIResponder <UIApplicationDelegate, SDWebImageManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) VLMViewController *viewController;

@end
