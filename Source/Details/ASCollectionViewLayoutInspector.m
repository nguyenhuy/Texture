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
ASSizeRange NodeConstrainedSizeForScrollDirection(ASCollectionView *collectionView) {
  CGSize maxSize = collectionView.bounds.size;
  UIEdgeInsets contentInset = collectionView.contentInset;
  if (ASScrollDirectionContainsHorizontalDirection(collectionView.scrollableDirections)) {
    maxSize.width = CGFLOAT_MAX;
    maxSize.height -= (contentInset.top + contentInset.bottom);
  } else {
    maxSize.width -= (contentInset.left + contentInset.right);
    maxSize.height = CGFLOAT_MAX;
  }
  return ASSizeRangeMake(CGSizeZero, maxSize);
}

#pragma mark - ASCollectionViewLayoutInspector

@implementation ASCollectionViewLayoutInspector {
  struct {
    unsigned int implementsConstrainedSizeForNodeAtIndexPath:1;
  } _delegateFlags;
}

#pragma mark ASCollectionViewLayoutInspecting

- (void)didChangeCollectionViewDelegate:(id<ASCollectionDelegate>)delegate
{
  if (delegate == nil) {
    memset(&_delegateFlags, 0, sizeof(_delegateFlags));
  } else {
    _delegateFlags.implementsConstrainedSizeForNodeAtIndexPath = [delegate respondsToSelector:@selector(collectionNode:constrainedSizeForItemAtIndexPath:)];
  }
}

- (ASSizeRange)collectionView:(ASCollectionView *)collectionView constrainedSizeForNodeAtIndexPath:(NSIndexPath *)indexPath
{
  if (_delegateFlags.implementsConstrainedSizeForNodeAtIndexPath) {
    return [collectionView.asyncDelegate collectionNode:collectionView.collectionNode constrainedSizeForItemAtIndexPath:indexPath];
  }
  
  return NodeConstrainedSizeForScrollDirection(collectionView);
}

- (ASScrollDirection)scrollableDirections
{
  return ASScrollDirectionNone;
}

@end
