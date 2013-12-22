//
//  VLMParser.m
//  Cartoonist
//
//  Created by David Lu on 12/12/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMParser.h"
#import "VLMPanelModel.h"
#import "VLMPanelModels.h"

@implementation VLMParser

static inline BOOL IsEmpty(id thing)
{
	return [thing isKindOfClass:[NSNull class]]
		   || thing == nil
		   || ([thing respondsToSelector:@selector(length)]
			   && [(NSData *)thing length] == 0)
		   || ([thing respondsToSelector:@selector(count)]
			   && [(NSArray *)thing count] == 0);
}

- (id)init
{
	if (self = [super init])
	{
		return self;
	}
	return nil;
}

- (VLMPanelModel *)panelModelFromNode:(NSMutableDictionary *)node
{
	NSString *caption = (NSString *)[node objectForKey:@"caption"];
	NSString *imageName = (NSString *)[node objectForKey:@"image"];

	if (IsEmpty(caption))
	{
		caption = @"";
	}
	if (IsEmpty(imageName))
	{
		imageName = @"";
	}


	// FIXME: i think it's wasteful to load image at outset. it should be lazy loaded.
	UIImage *image = [UIImage imageNamed:imageName];

	return [VLMPanelModel panelModelWithName:caption image:image];
}

- (VLMPanelModels *)panelModelsFromNode:(NSMutableDictionary *)node
{
	VLMPanelModels *models = [[VLMPanelModels alloc] init];
	NSArray *children = [node objectForKey:@"children"];

	for (NSMutableDictionary *child in children)
	{
		NSString *imagename = [child objectForKey:@"image"];
		NSString *caption = [child objectForKey:@"caption"];

		if (IsEmpty(caption))
		{
			caption = @"";
		}

		if (IsEmpty(imagename))
		{
			imagename = @"";
		}

		VLMPanelModel *model = [VLMPanelModel panelModelWithName:caption image:[UIImage imageNamed:imagename]];
		[models.models addObject:model];
		[models setSourceNode:node];
	}
	return models;
}

- (NSMutableArray *)parseRootNode:(NSMutableDictionary *)root keepReference:(BOOL)shouldKeep
{
	// NSLog(@"%@", root);

	NSMutableArray *list = [NSMutableArray array];

	[self parseSequence:root intoArray:list];

	// keep a reference to the root node so that when the player makes a choice,
	// we can re-parse the tree and generate a new array
	if (shouldKeep)
	{
		self.rootNode = root;
	}

	return list;
}

- (void)parseSequence:(NSMutableDictionary *)sequence intoArray:(NSMutableArray *)array
{
	for (NSMutableDictionary *node in [sequence objectForKey : @"nodes"])
	{
		// NSLog(@"node");
		// detect type and add correct class instance to list
		NSString *type = [node objectForKey:@"type"];

		// if node is type choice,
		if ([type isEqualToString:@"joint"])
		{
			// NSLog(@"joint");
			// add node to list
			VLMPanelModels *pm = [self panelModelsFromNode:node];
            [pm setIndex:array.count];
			[array addObject:pm];

			// recursively parse child sequences
			NSArray *children = [node objectForKey:@"children"];

			// extract selected index, write a default if needed
			NSInteger index = 0;

			if ([pm.sourceNode objectForKey:@"selected"])
			{
				index = [[pm.sourceNode objectForKey:@"selected"] integerValue];
				// NSLog(@"found existing index: %i", index);
			}
			else
			{
				[sequence setObject:[NSNumber numberWithInteger:index] forKey:@"selected"];
			}
			// NSLog(@"selected index is %i", index);
			NSMutableDictionary *selectedChild = [children objectAtIndex:index];
			[self parseSequence:selectedChild intoArray:array];
		}
		else
		{
			// NSLog(@"not joint");
			// add node to list
            VLMPanelModel *mod = [self panelModelFromNode:node];
            [mod setIndex:array.count];
			[array addObject:mod];
		}
		// NSLog(@"array count: %i", [array count]);
		// get selection state,
		// get selected child
		// parse its sequence
	}
}

@end