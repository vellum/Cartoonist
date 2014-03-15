//
//  main.m
//  ABCD
//
//  Created by David Lu on 11/19/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLMAppDelegate.h"
#import "VLMConstants.h"

#ifdef PRESENT_TOUCHES
#import "QTouchposeApplication.h"
#endif

int main(int argc, char * argv[])
{
    @autoreleasepool {
#ifdef PRESENT_TOUCHES
        return UIApplicationMain(argc, argv,
                                 NSStringFromClass([QTouchposeApplication class]),
                                 NSStringFromClass([VLMAppDelegate class]));
#else
    return UIApplicationMain(argc, argv, nil, NSStringFromClass([VLMAppDelegate class]));
#endif
    }

}
