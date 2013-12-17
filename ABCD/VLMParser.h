//
//  VLMParser.h
//  Cartoonist
//
//  Created by David Lu on 12/12/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLMPanelModel;
@class VLMPanelModels;

@interface VLMParser : NSObject

@property (nonatomic, strong) NSMutableDictionary *rootNode;

- (VLMPanelModel *)panelModelFromNode:(NSMutableDictionary *)node;
- (VLMPanelModels *)panelModelsFromNode:(NSMutableDictionary *)node;
- (NSMutableArray *)parseRootNode:(NSMutableDictionary *)root keepReference:(BOOL)shouldKeep;

// - (NSMutableArray)setPlayerChoiceAtIndex:(NSInteger)index Choice:(NSInteger)choiceIndex

@end