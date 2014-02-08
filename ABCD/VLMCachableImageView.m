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

@interface VLMCachableImageView()
@end

static char * const kCacheImageAssociationKey = "VLM_CacheImageName";

@implementation VLMCachableImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    }
    return self;
}
- (void)prepareForReuse{
    self.image = nil;
}
- (void)loadImageNamed:(NSString*)fileName
{
    self.image = nil;
    VLMApplicationData *appdata = [VLMApplicationData sharedInstance];
    NSCache *cache = appdata.imageCache;

    if ([cache objectForKey:fileName])
    {
        UIImage *img = (UIImage *)[cache objectForKey:fileName];
        [self setImage:img];
    }
    else
    {
        
        NSString *resourcePath = [[NSBundle mainBundle] resourcePath];
        NSString *imageFolder = [[resourcePath stringByAppendingPathComponent:@"Images"] copy];
        NSString *fn = [fileName stringByAppendingString:@".png"];
        NSString *filePath = [imageFolder stringByAppendingPathComponent:fn];

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0ul);
        // Now, we can’t cancel a block once it begins, so we’ll use associated objects and compare
        // index paths to see if we should continue once we have a resized image.
        objc_setAssociatedObject(self,
                                 kCacheImageAssociationKey,
                                 fileName,
                                 OBJC_ASSOCIATION_RETAIN);
        
        dispatch_async(queue, ^{
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            CGFloat scale = [UIScreen mainScreen].scale;
            UIImage *resizedImage = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill
                                                                bounds:CGSizeMake(self.frame.size.height*scale, self.frame.size.height*scale)
                                                  interpolationQuality:kCGInterpolationHigh];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *requestedImageName =
                (NSString *)objc_getAssociatedObject(self, kCacheImageAssociationKey);
                
                if ([requestedImageName isEqualToString:fileName]) {
                    [self setImage:resizedImage];
                }
                [cache setObject:resizedImage forKey:requestedImageName];
                
            });
        });
    }
}

@end
