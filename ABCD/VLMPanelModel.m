//
//  VLMFrameModel.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMPanelModel.h"

@implementation VLMPanelModel

+ (instancetype)panelModelWithName:(NSString *)name image:(UIImage *)image
{
	VLMPanelModel *model = [[VLMPanelModel alloc] init];
    model.index = -1000;
	model.name = name;
	model.image = image;
	//NSLog(@"creating panelmodel %@\t%@", name, image);
	return model;
}

@end