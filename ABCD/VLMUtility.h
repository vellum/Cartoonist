//
//  VLMUtility.h
//  Cartoonist
//
//  Created by David Lu on 2/9/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLMUtility : NSObject
+ (NSURL *) URLForImageNamed:(NSString *)imageName;
+ (UIImage *) placeholderForImageNamed:(NSString *)imageName;
+ (NSURL *) URLForRetinaImageNamed:(NSString *)imageName;
+ (NSURL *) URLForNonRetinaImageNamed:(NSString *)imageName;
+ (BOOL) hasCachedImageForURL:(NSURL *)url;
@end
