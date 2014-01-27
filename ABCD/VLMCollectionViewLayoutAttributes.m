//
//  VLMCollectionViewLayoutAttributes.m
//  Cartoonist
//
//  Created by David Lu on 11/27/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMViewController.h"

@implementation VLMCollectionViewLayoutAttributes


-(id)copyWithZone:(NSZone *)zone
{
    VLMCollectionViewLayoutAttributes *attributes = [super copyWithZone:zone];
    
    attributes.transitionValue = self.transitionValue;
    attributes.scaleValue = self.scaleValue;
    attributes.isOverview = self.isOverview;
    attributes.orientationValue = self.orientationValue;
    
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
    if ([(VLMCollectionViewLayoutAttributes *) other scaleValue] != [self scaleValue]) {
        return NO;
    }
    if ([(VLMCollectionViewLayoutAttributes *) other isOverview] != [self isOverview]) {
        return NO;
    }
    if ([(VLMCollectionViewLayoutAttributes *) other orientationValue] != [self orientationValue]) {
        return NO;
    }
    return YES;
}


@end
