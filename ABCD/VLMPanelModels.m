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

- (VLMPanelModels *)init
{
    self = [super init];
    if (self) {
        self.models = [[NSMutableArray alloc] init];
        self.selectedIndex = 0;
    }
	return self;
}

- (void)setSelectedIndex:(NSInteger)index
{
	if (self.sourceNode)
	{
		NSInteger current = [[self.sourceNode objectForKey:@"selected"] integerValue];
		//NSLog(@"cur %i    update %i", current, index);
		if (current != index)
		{
			[self.sourceNode setObject:[NSNumber numberWithInteger:index] forKey:@"selected"];
			 [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedNewBranch" object:nil];
		}
	}
}

@end