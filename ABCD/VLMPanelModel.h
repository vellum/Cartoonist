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
	kCellTypeWireframe,
	kCellTypeCaption,
    kCellTypeNoCaption
} CellType;


@interface VLMPanelModel : NSObject

+ (instancetype)panelModelWithName:(NSString *)name image:(UIImage *)image;

@property (nonatomic) NSInteger index;
@property (nonatomic) CellType cellType;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) UIImage *image;

@end