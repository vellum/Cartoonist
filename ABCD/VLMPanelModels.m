//
//  VLMPanelModels.m
//  Cartoonist
//
//  Created by David Lu on 12/3/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMPanelModels.h"
#import "VLMPanelModel.h"

@implementation VLMPanelModels
@synthesize models;

- (VLMPanelModels *)init
{
	self = [super init];
	if (self)
	{
		self.models = [[NSMutableArray alloc] init];
		self.selectedIndex = 0;
		self.index = -1000;
	}
	return self;
}

- (void)setSelectedIndex:(NSInteger)index
{
	if (self.sourceNode)
	{
		NSInteger current = [[self.sourceNode objectForKey:@"selected"] integerValue];
		if (current != index)
		{
			[self.sourceNode setObject:[NSNumber numberWithInteger:index] forKey:@"selected"];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedNewBranch" object:nil];
		}
	}
}

- (NSString *)selectedLabelString
{
    NSInteger curIndex = [[self.sourceNode objectForKey:@"selected"] integerValue];
    VLMPanelModel *model = (VLMPanelModel *)[self.models objectAtIndex:curIndex];
    return model.name;
}
@end