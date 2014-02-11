//
//  VLMUtility.m
//  Cartoonist
//
//  Created by David Lu on 2/9/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import "VLMUtility.h"
#import "SDWebImageManager.h"
#import "SDImageCache.h"

@implementation VLMUtility

+ (NSURL *) URLForImageNamed:(NSString *)imageName
{
    return ([[UIScreen mainScreen] scale] <= 1) ? [VLMUtility URLForNonRetinaImageNamed:imageName] : [VLMUtility URLForRetinaImageNamed:imageName];
    //return [VLMUtility URLForNonRetinaImageNamed:imageName];
}

+ (NSURL *) URLForRetinaImageNamed:(NSString *)imageName
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *imageFolder = [[resourcePath stringByAppendingPathComponent:@"Images"] copy];
    NSString *fileName = [imageName stringByAppendingString:@"@2x.png"];
    NSString *filePath = [imageFolder stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    return url;
}

+ (NSURL *) URLForNonRetinaImageNamed:(NSString *)imageName
{
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *imageFolder = [[resourcePath stringByAppendingPathComponent:@"Images"] copy];
    NSString *fileName = [imageName stringByAppendingString:@".png"];
    NSString *filePath = [imageFolder stringByAppendingPathComponent:fileName];
    NSURL *url = [NSURL fileURLWithPath:filePath];
    return url;
}

+ (BOOL) hasCachedImageForURL:(NSURL *)url
{
    SDImageCache * cache = [[SDWebImageManager sharedManager] imageCache];
    BOOL ret = [cache imageFromDiskCacheForKey:[url absoluteString]]!=nil;
    return ret;
}

+ (UIImage *)cachedImageForURL:(NSURL *)url
{
    SDImageCache * cache = [[SDWebImageManager sharedManager] imageCache];
    return [cache imageFromDiskCacheForKey:[url absoluteString]];
}

+ (UIImage *) placeholderForImageNamed:(NSString *)imageName
{
    /*
    // look in Thumb subfolder
    NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
    NSString *imageFolder = [[[resourcePath stringByAppendingPathComponent:@"Images"] stringByAppendingPathComponent:@"Thumb"] copy];
    NSString *fileName = [imageName stringByAppendingString:@".png"];
    NSString *filePath = [imageFolder stringByAppendingPathComponent:fileName];
    return [UIImage imageWithContentsOfFile:filePath];
    */
    // use standard placeholder (dots)
    return [UIImage imageNamed:@"placeholder-panel"];
    
    // use thumbs stored in xcassets (system-optimized cache)
    //return [UIImage imageNamed:imageName];
}

@end
