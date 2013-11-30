//
//  VLMCollectionViewLayoutAttributes.m
//  Cartoonist
//
//  Created by David Lu on 11/27/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewLayoutAttributes.h"

@implementation VLMCollectionViewLayoutAttributes


-(id)copyWithZone:(NSZone *)zone
{
    VLMCollectionViewLayoutAttributes *attributes = [super copyWithZone:zone];
    
    attributes.transitionValue = self.transitionValue;
    
    return attributes;
}
- (BOOL)isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![[other class] isEqual:[self class]]) {
        return NO;
    }
    if ([((VLMCollectionViewLayoutAttributes *) other) transitionValue] != [self transitionValue]) {
        return NO;
    }
    
    return YES;
}


@end
