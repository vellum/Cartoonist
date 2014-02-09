//
//  VLMCachableImageView.m
//  Cartoonist
//
//  Created by David Lu on 2/8/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <objc/runtime.h>
#import "VLMCachableImageView.h"
#import "VLMApplicationData.h"
#import "UIImage+Resize.h"
#import "UIImage+Alpha.h"
#import "VLMDataSource.h"

// constant key for thread-safe objc_set/get
static char * const kCacheImageAssociationKey = "VLM_CacheImageName";
static char * const kCacheIndexAssociationKey = "VLM_CacheIndexPath";

@implementation VLMCachableImageView

// populate with placeholder by default
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
        self.image = [UIImage imageNamed:@"placeholder-panel"];
    }
    return self;
}

- (void)loadImageNamed:(NSString*)imageName
{
    VLMApplicationData *appdata = [VLMApplicationData sharedInstance];
    NSCache *cache = appdata.imageCache;

    if ([cache objectForKey:imageName])
    {
        // image has been cached, so populate the imageview
        UIImage *image = (UIImage *)[cache objectForKey:imageName];
        [self setImage:image];
    }
    else
    {
        // image hasn't been cached, so populate with placeholder
        [self setImage:[UIImage imageNamed:@"placeholder-panel"]];

        // build a file path
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *imageFolder = [[resourcePath stringByAppendingPathComponent:@"Images"] copy];
        NSString *fileName = [imageName stringByAppendingString:@".png"];
        NSString *filePath = [imageFolder stringByAppendingPathComponent:fileName];

        // get ready to load image in background
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);

        // use associated objects and compare imagenames to see if we should continue once we have a resized image.
        objc_setAssociatedObject(self,
                                 kCacheImageAssociationKey,
                                 imageName,
                                 OBJC_ASSOCIATION_COPY_NONATOMIC);
        
        //
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            if (!image) {
                objc_setAssociatedObject(self,
                                         kCacheImageAssociationKey,
                                         nil,
                                         OBJC_ASSOCIATION_COPY_NONATOMIC);
                return;
            }
            CGFloat scale = [UIScreen mainScreen].scale;
            UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                                bounds:CGSizeMake(self.frame.size.height*scale, self.frame.size.height*scale)
                                                  interpolationQuality:kCGInterpolationHigh];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *requestedImageName =
                    (NSString *)objc_getAssociatedObject(self, kCacheImageAssociationKey);
                
                if (requestedImageName) {
                    if ([requestedImageName isEqualToString:imageName]) {
                        [self setImage:resizedImage];
                    }
                    [cache setObject:resizedImage forKey:requestedImageName];
                }
                
                objc_setAssociatedObject(self,
                                         kCacheImageAssociationKey,
                                         nil,
                                         OBJC_ASSOCIATION_COPY_NONATOMIC);
                

            });
        });
    }
}

@end
