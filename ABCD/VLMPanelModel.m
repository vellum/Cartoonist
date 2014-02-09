//
//  VLMFrameModel.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMPanelModel.h"

@implementation VLMPanelModel

+ (instancetype)panelModelWithName:(NSString *)name image:(NSString *)image{
    return [VLMPanelModel panelModelWithName:name image:image type:kCellTypeNoCaption];
}

+ (instancetype)panelModelWithName:(NSString *)name image:(NSString *)image type:(CellType)type
{
	VLMPanelModel *model = [[VLMPanelModel alloc] init];
	model.index = -1000;
	model.name = name;
	model.image = image;
	model.cellType = type;
    // NSLog(@"creating panelmodel %@\t%@", name, image);
	return model;
}

@end