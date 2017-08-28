//
//  ASDimension.mm
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

#import <AsyncDisplayKit/ASDimension.h>

#import <AsyncDisplayKit/CoreGraphics+ASConvenience.h>

#import <AsyncDisplayKit/ASAssert.h>

#pragma mark - ASDimension

ASDimension const ASDimensionAuto = {ASDimensionUnitAuto, 0};

ASOVERLOADABLE ASDimension ASDimensionMake(NSString *dimension)
{
  if (dimension.length > 0) {
    
    // Handle points
    if ([dimension hasSuffix:@"pt"]) {
      return ASDimensionMake(ASDimensionUnitPoints, ASCGFloatFromString(dimension));
    }
    
    // Handle auto
    if ([dimension isEqualToString:@"auto"]) {
      return ASDimensionAuto;
    }
  
    // Handle percent
    if ([dimension hasSuffix:@"%"]) {
      return ASDimensionMake(ASDimensionUnitFraction, (ASCGFloatFromString(dimension) / 100.0));
    }
  }
  
  return ASDimensionAuto;
}

NSString *NSStringFromASDimension(ASDimension dimension)
{
  switch (dimension.unit) {
    case ASDimensionUnitPoints:
      return [NSString stringWithFormat:@"%.0fpt", dimension.value];
    case ASDimensionUnitFraction:
      return [NSString stringWithFormat:@"%.0f%%", dimension.value * 100.0];
    case ASDimensionUnitAuto:
      return @"Auto";
  }
}

#pragma mark - ASLayoutSize

ASLayoutSize const ASLayoutSizeAuto = {ASDimensionAuto, ASDimensionAuto};

#pragma mark - ASLayoutContext

struct _Range {
  CGFloat min;
  CGFloat max;
  
  /**
   Intersects another dimension range. If the other range does not overlap, this size range "wins" by returning a
   single point within its own range that is closest to the non-overlapping range.
   */
  _Range intersect(const _Range &other) const
  {
  CGFloat newMin = MAX(min, other.min);
  CGFloat newMax = MIN(max, other.max);
  if (newMin <= newMax) {
    return {newMin, newMax};
  } else {
    // No intersection. If we're before the other range, return our max; otherwise our min.
    if (min < other.min) {
      return {max, max};
    } else {
      return {min, min};
    }
  }
  }
};

ASLayoutContext ASLayoutContextIntersect(ASLayoutContext layoutContext, ASLayoutContext otherLayoutContext)
{
  ASPrimitiveTraitCollection traitCollection = layoutContext.traitCollection;
  // Make sure contexts have the same trait collection, otherwise we need to ask for one to use in the result.
  ASDisplayNodeCAssertTrue(ASPrimitiveTraitCollectionIsEqualToASPrimitiveTraitCollection(traitCollection,
                                                                                         otherLayoutContext.traitCollection));
  auto w = _Range({layoutContext.min.width, layoutContext.max.width}).intersect({otherLayoutContext.min.width, otherLayoutContext.max.width});
  auto h = _Range({layoutContext.min.height, layoutContext.max.height}).intersect({otherLayoutContext.min.height, otherLayoutContext.max.height});
  return {{w.min, h.min}, {w.max, h.max}, traitCollection};
}

NSString *NSStringFromASLayoutContext(ASLayoutContext layoutContext)
{
  // 17 field length copied from iOS 10.3 impl of NSStringFromCGSize.
  if (CGSizeEqualToSize(layoutContext.min, layoutContext.max)) {
    return [NSString stringWithFormat:@"{{%.*g, %.*g}, %@}",
            17, layoutContext.min.width,
            17, layoutContext.min.height,
            NSStringFromASPrimitiveTraitCollection(layoutContext.traitCollection)];
  }
  return [NSString stringWithFormat:@"{{%.*g, %.*g}, {%.*g, %.*g}, %@}",
          17, layoutContext.min.width,
          17, layoutContext.min.height,
          17, layoutContext.max.width,
          17, layoutContext.max.height,
          NSStringFromASPrimitiveTraitCollection(layoutContext.traitCollection)];
}

#if YOGA
#pragma mark - Yoga - ASEdgeInsets
ASEdgeInsets const ASEdgeInsetsZero = {};

extern ASEdgeInsets ASEdgeInsetsMake(UIEdgeInsets edgeInsets)
{
  ASEdgeInsets asEdgeInsets = ASEdgeInsetsZero;
  asEdgeInsets.top = ASDimensionMake(edgeInsets.top);
  asEdgeInsets.left = ASDimensionMake(edgeInsets.left);
  asEdgeInsets.bottom = ASDimensionMake(edgeInsets.bottom);
  asEdgeInsets.right = ASDimensionMake(edgeInsets.right);
  return asEdgeInsets;
}
#endif
