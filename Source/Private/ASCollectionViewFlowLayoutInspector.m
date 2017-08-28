//
//  ASCollectionViewFlowLayoutInspector.m
//  Texture
//
//  Copyright (c) 2014-present, Facebook, Inc.  All rights reserved.
//  This source code is licensed under the BSD-style license found in the
//  LICENSE file in the /ASDK-Licenses directory of this source tree. An additional
//  grant of patent rights can be found in the PATENTS file in the same directory.
//
//  Modifications to this file made after 4/13/2017 are: Copyright (c) 2017-present,
//  Pinterest, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASCollectionViewFlowLayoutInspector.h>
#import <AsyncDisplayKit/ASCollectionView.h>
#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASEqualityHelpers.h>
#import <AsyncDisplayKit/ASCollectionView+Undeprecated.h>
#import <AsyncDisplayKit/ASCollectionNode.h>

#define kDefaultItemSize CGSizeMake(50, 50)

#pragma mark - ASCollectionViewFlowLayoutInspector

@interface ASCollectionViewFlowLayoutInspector ()
@property (nonatomic, weak) UICollectionViewFlowLayout *layout;
@end
 
@implementation ASCollectionViewFlowLayoutInspector {
  struct {
    unsigned int implementsLayoutContextForHeaderWithTraitCollection:1;
    unsigned int implementsSizeRangeForHeaderDeprecated:1;
    unsigned int implementsReferenceSizeForHeaderDeprecated:1;
    unsigned int implementsLayoutContextForFooterWithTraitCollection:1;
    unsigned int implementsSizeRangeForFooterDeprecated:1;
    unsigned int implementsReferenceSizeForFooterDeprecated:1;
    unsigned int implementsLayoutContextForItemAtIndexPathWithTraitCollection:1;
    unsigned int implementsConstrainedSizeForNodeAtIndexPathDeprecated:1;
    unsigned int implementsConstrainedSizeForItemAtIndexPathDeprecated:1;
  } _delegateFlags;
}

#pragma mark Lifecycle

- (instancetype)initWithFlowLayout:(UICollectionViewFlowLayout *)flowLayout;
{
  NSParameterAssert(flowLayout);
  
  self = [super init];
  if (self != nil) {
    _layout = flowLayout;
  }
  return self;
}

#pragma mark ASCollectionViewLayoutInspecting

- (void)didChangeCollectionViewDelegate:(id<ASCollectionDelegate>)delegate;
{
  if (delegate == nil) {
    memset(&_delegateFlags, 0, sizeof(_delegateFlags));
  } else {
    _delegateFlags.implementsLayoutContextForHeaderWithTraitCollection = [delegate respondsToSelector:@selector(collectionNode:layoutContextForHeaderInSection:withTraitCollection:)];
    _delegateFlags.implementsSizeRangeForHeaderDeprecated = [delegate respondsToSelector:@selector(collectionNode:sizeRangeForHeaderInSection:)];
    _delegateFlags.implementsReferenceSizeForHeaderDeprecated = [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)];
    _delegateFlags.implementsLayoutContextForFooterWithTraitCollection = [delegate respondsToSelector:@selector(collectionNode:layoutContextForFooterInSection:withTraitCollection:)];
    _delegateFlags.implementsSizeRangeForFooterDeprecated = [delegate respondsToSelector:@selector(collectionNode:sizeRangeForFooterInSection:)];
    _delegateFlags.implementsReferenceSizeForFooterDeprecated = [delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)];
    _delegateFlags.implementsLayoutContextForItemAtIndexPathWithTraitCollection = [delegate respondsToSelector:@selector(collectionNode:layoutContextForItemAtIndexPath:withTraitCollection:)];
    _delegateFlags.implementsConstrainedSizeForNodeAtIndexPathDeprecated = [delegate respondsToSelector:@selector(collectionView:constrainedSizeForNodeAtIndexPath:)];
    _delegateFlags.implementsConstrainedSizeForItemAtIndexPathDeprecated = [delegate respondsToSelector:@selector(collectionNode:constrainedSizeForItemAtIndexPath:)];
  }
}

- (ASLayoutContext)collectionView:(ASCollectionView *)collectionView layoutContextForNodeAtIndexPath:(NSIndexPath *)indexPath withTraitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  ASCollectionNode *collectionNode = collectionView.collectionNode;
  ASLayoutContext result;
  if (_delegateFlags.implementsLayoutContextForItemAtIndexPathWithTraitCollection) {
    result = [collectionView.asyncDelegate collectionNode:collectionNode layoutContextForItemAtIndexPath:indexPath withTraitCollection:traitCollection];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  } else if (_delegateFlags.implementsConstrainedSizeForItemAtIndexPathDeprecated) {
    result = [collectionView.asyncDelegate collectionNode:collectionNode constrainedSizeForItemAtIndexPath:indexPath];
    result.traitCollection = traitCollection;
  } else if (_delegateFlags.implementsConstrainedSizeForNodeAtIndexPathDeprecated) {
    result = [collectionView.asyncDelegate collectionView:collectionView constrainedSizeForNodeAtIndexPath:indexPath];
    result.traitCollection = traitCollection;
#pragma clang diagnostic pop
  } else {
    // With 2.0 `collectionView:constrainedSizeForNodeAtIndexPath:` was moved to the delegate. Assert if not implemented on the delegate but on the data source
    ASDisplayNodeAssert([collectionView.asyncDataSource respondsToSelector:@selector(collectionView:constrainedSizeForNodeAtIndexPath:)] == NO, @"collectionView:constrainedSizeForNodeAtIndexPath: was moved from the ASCollectionDataSource to the ASCollectionDelegate.");
    result = ASLayoutContextMakeWithUnconstrainedSizeRange(traitCollection);
  }

  // If we got no size range:
  if (ASLayoutContextEqualToLayoutContext(result, ASLayoutContextMakeWithUnconstrainedSizeRange(traitCollection))) {
    // Use itemSize if they set it.
    CGSize itemSize = _layout.itemSize;
    if (CGSizeEqualToSize(itemSize, kDefaultItemSize) == NO) {
      result = ASLayoutContextMake(itemSize, traitCollection);
    } else {
      // Compute constraint from scroll direction otherwise.
      result = NodeLayoutContextForScrollDirection(collectionView, traitCollection);
    }
  }

  return result;
}

- (ASLayoutContext)collectionView:(ASCollectionView *)collectionView layoutContextForSupplementaryNodeOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath withTraitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  ASCollectionNode *collectionNode = collectionView.collectionNode;
  ASLayoutContext result;
  if (ASObjectIsEqual(kind, UICollectionElementKindSectionHeader)) {
    if (_delegateFlags.implementsLayoutContextForHeaderWithTraitCollection) {
      result = [[self delegateForCollectionView:collectionView] collectionNode:collectionNode layoutContextForHeaderInSection:indexPath.section withTraitCollection:traitCollection];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    } else if (_delegateFlags.implementsSizeRangeForHeaderDeprecated) {
      result = [[self delegateForCollectionView:collectionView] collectionNode:collectionNode sizeRangeForHeaderInSection:indexPath.section];
      result.traitCollection = traitCollection;
    } else if (_delegateFlags.implementsReferenceSizeForHeaderDeprecated) {
      CGSize exactSize = [[self delegateForCollectionView:collectionView] collectionView:collectionView layout:_layout referenceSizeForHeaderInSection:indexPath.section];
      result = ASLayoutContextMake(exactSize, traitCollection);
#pragma clang diagnostic pop
    } else {
      result = ASLayoutContextMake(_layout.headerReferenceSize, traitCollection);
    }
  } else if (ASObjectIsEqual(kind, UICollectionElementKindSectionFooter)) {
    if (_delegateFlags.implementsLayoutContextForFooterWithTraitCollection) {
      result = [[self delegateForCollectionView:collectionView] collectionNode:collectionNode layoutContextForFooterInSection:indexPath.section withTraitCollection:traitCollection];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    } else if (_delegateFlags.implementsSizeRangeForFooterDeprecated) {
      result = [[self delegateForCollectionView:collectionView] collectionNode:collectionNode sizeRangeForFooterInSection:indexPath.section];
      result.traitCollection = traitCollection;
    } else if (_delegateFlags.implementsReferenceSizeForFooterDeprecated) {
      CGSize exactSize = [[self delegateForCollectionView:collectionView] collectionView:collectionView layout:_layout referenceSizeForFooterInSection:indexPath.section];
      result = ASLayoutContextMake(exactSize, traitCollection);
#pragma clang diagnostic pop
    } else {
      result = ASLayoutContextMake(_layout.footerReferenceSize, traitCollection);
    }
  } else {
    ASDisplayNodeFailAssert(@"Unexpected supplementary kind: %@", kind);
    return ASLayoutContextMakeWithZeroSize(traitCollection);
  }

  if (_layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
    result.min.width = result.max.width = CGRectGetWidth(collectionView.bounds);
  } else {
    result.min.height = result.max.height = CGRectGetHeight(collectionView.bounds);
  }
  return result;
}

- (NSUInteger)collectionView:(ASCollectionView *)collectionView supplementaryNodesOfKind:(NSString *)kind inSection:(NSUInteger)section
{
  ASCollectionNode *collectionNode = collectionView.collectionNode;
  ASPrimitiveTraitCollection traitCollection = collectionNode ? collectionNode.layoutContext.traitCollection : ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext layoutContext = [self collectionView:collectionView
               layoutContextForSupplementaryNodeOfKind:kind
                                           atIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]
                                   withTraitCollection:traitCollection];
  if (_layout.scrollDirection == UICollectionViewScrollDirectionVertical) {
    return (layoutContext.max.height > 0 ? 1 : 0);
  } else {
    return (layoutContext.max.width > 0 ? 1 : 0);
  }
}

- (ASScrollDirection)scrollableDirections
{
  return (self.layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) ? ASScrollDirectionHorizontalDirections : ASScrollDirectionVerticalDirections;
}

#pragma mark - Private helpers

- (id<ASCollectionDelegateFlowLayout>)delegateForCollectionView:(ASCollectionView *)collectionView
{
  return (id<ASCollectionDelegateFlowLayout>)collectionView.asyncDelegate;
}

@end
