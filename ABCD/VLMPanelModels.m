//
//  VLMPanelModels.m
//  Cartoonist
//
//  Created by David Lu on 12/3/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMPanelModels.h"

@implementation VLMPanelModels
@synthesize models;

-(VLMPanelModels *)init
{
    self.models = [[NSMutableArray alloc] init];
    return self;
}

@end
