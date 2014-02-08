//
//  VLMApplicationData.m
//  Cartoonist
//
//  Created by David Lu on 2/7/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMApplicationData.h"

@implementation VLMApplicationData

+ (VLMApplicationData *) sharedInstance {
    static dispatch_once_t once;
    static VLMApplicationData *instance;
    dispatch_once(&once, ^{
        instance = [[VLMApplicationData alloc] init];
    });
    return instance;
}

- (VLMApplicationData *) init
{
    self = [super init];
	if (self)
	{
		self.imageCache = [[NSCache alloc] init];
        [self.imageCache setName:@"VLMImageCache"];
	}
	return self;
}

// FIXME: add something to listen for memory warnings and empty the cache when needed
@end
