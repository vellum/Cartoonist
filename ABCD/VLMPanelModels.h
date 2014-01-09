//
//  VLMPanelModels.h
//  Cartoonist
//
//  Created by David Lu on 12/3/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLMPanelModels : NSObject
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSMutableArray *models;
@property (nonatomic, weak) NSMutableDictionary *sourceNode;
- (void)setSelectedIndex:(NSInteger)index;
- (NSString *)selectedLabelString;
@end