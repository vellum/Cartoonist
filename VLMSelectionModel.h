//
//  VLMSelectionModel.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSUInteger VLMSelectionModelNoSelectionIndex;

@interface VLMSelectionModel : NSObject

+(instancetype)selectionModelWithPhotoModels:(NSArray *)photoModels;

@property (nonatomic, strong, readonly) NSArray *models;
@property (nonatomic, assign) NSUInteger selectedModelIndex;
@property (nonatomic, readonly) BOOL hasBeenSelected;


@end
