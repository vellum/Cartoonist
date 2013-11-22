//
//  VLMSelectionModel.m
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMSelectionModel.h"

const NSUInteger VLMSelectionModelNoSelectionIndex = -1;

@interface VLMSelectionModel ()

@property (nonatomic, strong) NSArray *models;

@end

@implementation VLMSelectionModel

+(instancetype)selectionModelWithPhotoModels:(NSArray *)photoModels
{
    VLMSelectionModel *model = [[VLMSelectionModel alloc] init];
    
    model.models = photoModels;
    model.selectedModelIndex = VLMSelectionModelNoSelectionIndex;
    
    return model;
}

-(BOOL)hasBeenSelected
{
    return self.selectedModelIndex != VLMSelectionModelNoSelectionIndex;
}

@end
