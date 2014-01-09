//
//  VLMGenericFlowLayout.m
//  ABCD
//
//  Created by David Lu on 11/21/13.
//  Copyright (c) 2013 David Lu. All rights reserved.
//

#import "VLMSinglePanelFlowLayout.h"
#import "VLMCollectionViewLayoutAttributes.h"
#import "VLMCollectionViewCell.h"

@interface VLMSinglePanelFlowLayout ()
@property (nonatomic) CGFloat scalevalue;
@end

@implementation VLMSinglePanelFlowLayout

+ (Class)layoutAttributesClass
{
	return [VLMCollectionViewLayoutAttributes class];
}

- (id)init
{
	if (self = [super init])
	{
		[self setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];
		[self setMinimumInteritemSpacing:0.0f];
		[self setMinimumLineSpacing:0.0f];
		[self setItemSize:kItemSize];
		return self;
	}
	return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
	// Very important — needed to re-layout the cells when scrolling.
	return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
	NSArray *layoutAttributesArray = [super layoutAttributesForElementsInRect:rect];

	// We're going to calculate the rect of the collection view visible to the user.
	CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, CGRectGetWidth(self.collectionView.bounds), CGRectGetHeight(self.collectionView.bounds));

	for (UICollectionViewLayoutAttributes *attributes in layoutAttributesArray)
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

#pragma mark - ()

- (CGFloat)scale
{
	return self.scalevalue;
}

- (void)setScale:(CGFloat)value
{
	self.scalevalue = value;

	 CGSize normalSize = kItemSize;
	 CGSize scaledSize = CGSizeMake(normalSize.width, normalSize.height * self.scalevalue);
	 self.itemSize = scaledSize;
	 [self invalidateLayout];
}

#pragma mark - Private Custom Methods

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes forVisibleRect:(CGRect)visibleRect
{
	// We want to skip supplementary views.
	if (attributes.representedElementKind)
	{
		return;
	}

    // not sure why i need to subtract 10 here. might be to account for kitempadding.
	CGFloat distanceFromVisibleRectToItem = CGRectGetMidY(visibleRect) - attributes.center.y - 10.0f;
	CGFloat normalized = distanceFromVisibleRectToItem / self.itemSize.height;

	[(VLMCollectionViewLayoutAttributes *)attributes setTransitionValue : normalized];
	[(VLMCollectionViewLayoutAttributes *)attributes setScaleValue : self.scalevalue];
}

@end