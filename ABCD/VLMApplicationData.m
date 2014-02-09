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
    static dispatch_once_t onceToken;
    static VLMApplicationData *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VLMApplicationData alloc] init];
    });
    return sharedInstance;
}

- (VLMApplicationData *) init
{
    self = [super init];
	if (self)
	{
		[self setImageCache:[[NSCache alloc] init]];
        [self.imageCache setName:@"VLMImageCache"];
	}
	return self;
}

// FIXME: add something to listen for memory warnings and empty the cache when needed
@end
