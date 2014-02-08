//
//  VLMApplicationData.h
//  Cartoonist
//
//  Created by David Lu on 2/7/14.
//  Copyright (c) 2014 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLMApplicationData : NSObject
+ (VLMApplicationData *) sharedInstance;
@property (nonatomic, strong) NSCache *imageCache;
@end
