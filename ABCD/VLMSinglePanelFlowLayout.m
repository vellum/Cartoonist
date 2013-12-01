//
//  VLMGenericFlowLayout.m
//  ABCD
//
//  Created by David Lu on 11/21/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMSinglePanelFlowLayout.h"
#import "VLMCollectionViewLayoutAttributes.h"

@implementation VLMSinglePanelFlowLayout

+(Class)layoutAttributesClass
{
    return [VLMCollectionViewLayoutAttributes class];
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    // Very important — needed to re-layout the cells when scrolling.
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];
    
    // We're going to calculate the rect of the collection view visible to the user.
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    for (UICollectionViewLayoutAttributes* attributes in layoutAttributesArray)
    {
        [self applyLayoutAttributes:attributes forVisibleRect:visibleRect];
    }
    
    return layoutAttributesArray;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [super layoutAttributesForItemAtIndexPath:indexPath];
    
    // We're going to calculate the rect of the collection view visible to the user.
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));
    
    [self applyLayoutAttributes:attributes forVisibleRect:visibleRect];
    
    return attributes;
}

#pragma mark - Private Custom Methods

-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect
{
    // We want to skip supplementary views.
    if (attributes.representedElementKind) return;
    
    CGFloat distanceFromVisibleRectToItem = CGRectGetMidY(visibleRect) - attributes.center.y;
    CGFloat normalized = distanceFromVisibleRectToItem / self.itemSize.height;
    [(VLMCollectionViewLayoutAttributes *)attributes setTransitionValue:normalized];

}

@end
