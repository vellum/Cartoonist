//
//  VLMFrameModel.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMPanelModel.h"

@implementation VLMPanelModel

+(instancetype)frameModelWithName:(NSString *)name image:(UIImage *)image
{
    VLMPanelModel *model = [[VLMPanelModel alloc] init];
    
    model.name = name;
    model.image = image;
    
    return model;
}

@end
