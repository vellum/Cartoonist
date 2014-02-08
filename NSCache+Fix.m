//
//  NSCache+Fix.m
//  Cartoonist
//
//  Created by David Lu on 2/8/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "NSCache+Fix.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>


@implementation NSCache (Fix)

+ (void)load
{
    //swizzle init
    Method a = class_getInstanceMethod(self, @selector(init));
    Method b = class_getInstanceMethod(self, @selector(init_NSCF));
    method_exchangeImplementations(a, b);
    
    //swizzle dealloc - yeah, I went there
    a = class_getInstanceMethod(self, NSSelectorFromString(@"dealloc"));
    b = class_getInstanceMethod(self, @selector(dealloc_NSCF));
    method_exchangeImplementations(a, b);
}

- (id)init_NSCF
{
    if ((self = [self init_NSCF]))
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc_NSCF
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self dealloc_NSCF];
}

@end