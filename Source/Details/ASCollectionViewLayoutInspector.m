//
//  ASCollectionViewLayoutInspector.m
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

#import <AsyncDisplayKit/ASCollectionViewLayoutInspector.h>

#import <AsyncDisplayKit/ASCollectionView.h>
#import <AsyncDisplayKit/ASCollectionView+Undeprecated.h>
#import <AsyncDisplayKit/ASCollectionNode.h>

#pragma mark - Helper Functions

// Returns a constrained size to let the cells layout itself as far as possible based on the scrollable direction
// of the collection view
ASLayoutContext *NodeLayoutContextForScrollDirection(ASCollectionView *collectionView, ASPrimitiveTraitCollection traitCollection) {
  CGSize maxSize = collectionView.bounds.size;
  UIEdgeInsets contentInset = collectionView.contentInset;
  if (ASScrollDirectionContainsHorizontalDirection(collectionView.scrollableDirections)) {
    maxSize.width = CGFLOAT_MAX;
    maxSize.height -= (contentInset.top + contentInset.bottom);
  } else {
    maxSize.width -= (contentInset.left + contentInset.right);
    maxSize.height = CGFLOAT_MAX;
  }
  return [ASLayoutContext layoutContextWithMinSize:CGSizeZero maxSize:maxSize traitCollection:traitCollection];
}

#pragma mark - ASCollectionViewLayoutInspector

@implementation ASCollectionViewLayoutInspector {
  struct {
    unsigned int implementsLayoutContextForItemAtIndexPathWithTraitCollection:1;
    unsigned int implementsConstrainedSizeForNodeAtIndexPathDeprecated:1;
    unsigned int implementsConstrainedSizeForItemAtIndexPathDeprecated:1;
  } _delegateFlags;
}

#pragma mark ASCollectionViewLayoutInspecting

- (void)didChangeCollectionViewDelegate:(id<ASCollectionDelegate>)delegate
{
  if (delegate == nil) {
    memset(&_delegateFlags, 0, sizeof(_delegateFlags));
  } else {
    _delegateFlags.implementsLayoutContextForItemAtIndexPathWithTraitCollection = [delegate respondsToSelector:@selector(collectionNode:layoutContextForItemAtIndexPath:withTraitCollection:)];
    _delegateFlags.implementsConstrainedSizeForNodeAtIndexPathDeprecated = [delegate respondsToSelector:@selector(collectionView:constrainedSizeForNodeAtIndexPath:)];
    _delegateFlags.implementsConstrainedSizeForItemAtIndexPathDeprecated = [delegate respondsToSelector:@selector(collectionNode:constrainedSizeForItemAtIndexPath:)];
  }
}

- (ASLayoutContext *)collectionView:(ASCollectionView *)collectionView layoutContextForNodeAtIndexPath:(NSIndexPath *)indexPath withTraitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  ASCollectionNode *collectionNode = collectionView.collectionNode;
  ASLayoutContext *unconstrainedLayoutContext = [ASLayoutContext layoutContextWithUnconstrainedSizeRangeAndTraitCollection:traitCollection];
  ASLayoutContext *result;
  if (_delegateFlags.implementsLayoutContextForItemAtIndexPathWithTraitCollection) {
    result = [collectionView.asyncDelegate collectionNode:collectionNode layoutContextForItemAtIndexPath:indexPath withTraitCollection:traitCollection];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  } else if (_delegateFlags.implementsConstrainedSizeForItemAtIndexPathDeprecated) {
    ASMutableLayoutContext *mutableResult = [[collectionView.asyncDelegate collectionNode:collectionNode constrainedSizeForItemAtIndexPath:indexPath] mutableCopy];
    mutableResult.traitCollection = traitCollection;
    result = mutableResult;
  } else if (_delegateFlags.implementsConstrainedSizeForNodeAtIndexPathDeprecated) {
    ASMutableLayoutContext *mutableResult = [[collectionView.asyncDelegate collectionView:collectionView constrainedSizeForNodeAtIndexPath:indexPath] mutableCopy];
    mutableResult.traitCollection = traitCollection;
    result = mutableResult;
#pragma clang diagnostic pop
  } else {
    // With 2.0 `collectionView:constrainedSizeForNodeAtIndexPath:` was moved to the delegate. Assert if not implemented on the delegate but on the data source
    ASDisplayNodeAssert([collectionView.asyncDataSource respondsToSelector:@selector(collectionView:constrainedSizeForNodeAtIndexPath:)] == NO, @"collectionView:constrainedSizeForNodeAtIndexPath: was moved from the ASCollectionDataSource to the ASCollectionDelegate.");
    result = unconstrainedLayoutContext;
  }

  if ([result isEqual:unconstrainedLayoutContext]) {
    result = NodeLayoutContextForScrollDirection(collectionView, traitCollection);
  }
  return result;
}

- (ASScrollDirection)scrollableDirections
{
  return ASScrollDirectionNone;
}

@end
