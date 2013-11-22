//
//  VLMFrameModel.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMFrameModel.h"

@implementation VLMFrameModel

+(instancetype)frameModelWithName:(NSString *)name image:(UIImage *)image
{
    VLMFrameModel *model = [[VLMFrameModel alloc] init];
    
    model.name = name;
    model.image = image;
    
    return model;
}

@end
