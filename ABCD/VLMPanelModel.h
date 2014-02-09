//
//  VLMFrameModel.h
//  ABCD
//
//  Created by David Lu on 11/20/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kCellTypeUndefined,
	kCellTypeWireframe,
	kCellTypeCaption,
	kCellTypeNoCaption
} CellType;


@interface VLMPanelModel : NSObject


+ (instancetype)panelModelWithName:(NSString *)name image:(NSString *)image;

+ (instancetype)panelModelWithName:(NSString *)name image:(NSString *)image type:(CellType)type;

@property (nonatomic) NSInteger index;
@property (nonatomic) CellType cellType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *image;

@end