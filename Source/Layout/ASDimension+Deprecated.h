//
//  ASDimension+Deprecated.h
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

#pragma once
#import <AsyncDisplayKit/ASDimension.h>

ASDISPLAYNODE_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN

#pragma mark - ASSizeRange

// TODO Mass rename ASSizeRange in the framework and deprecated needed APIs
typedef ASLayoutContext ASSizeRange;

/**
 * A size range with all dimensions zero.
 */
extern ASSizeRange const ASSizeRangeZero;

/**
 * A size range from zero to infinity in both directions.
 */
extern ASSizeRange const ASSizeRangeUnconstrained;

/**
 * Returns whether a size range has > 0.1 max width and max height.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT BOOL ASSizeRangeHasSignificantArea(ASSizeRange sizeRange)
{
  return ASLayoutContextHasSignificantArea(sizeRange);
}

/**
 * Creates an ASSizeRange with provided min and max size.
 */
ASOVERLOADABLE ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASSizeRange ASSizeRangeMake(CGSize min, CGSize max)
{
  return ASLayoutContextMake(min, max, ASPrimitiveTraitCollectionMakeDefault());
}

/**
 * Creates an ASSizeRange with provided size as both min and max.
 */
ASOVERLOADABLE ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASSizeRange ASSizeRangeMake(CGSize exactSize)
{
  return ASLayoutContextMake(exactSize, exactSize, ASPrimitiveTraitCollectionMakeDefault());
}

/**
 * Clamps the provided CGSize between the [min, max] bounds of this ASSizeRange.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT CGSize ASSizeRangeClamp(ASSizeRange sizeRange, CGSize size)
{
  return ASLayoutContextClamp(sizeRange, size);
}

/**
 * Intersects another size range. If the other size range does not overlap in either dimension, this size range
 * "wins" by returning a single point within its own range that is closest to the non-overlapping range.
 */
extern AS_WARN_UNUSED_RESULT ASSizeRange ASSizeRangeIntersect(ASSizeRange sizeRange, ASSizeRange otherSizeRange);

/**
 * Returns whether two size ranges are equal in min and max size.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT BOOL ASSizeRangeEqualToSizeRange(ASSizeRange lhs, ASSizeRange rhs)
{
  return ASLayoutContextEqualToLayoutContext(lhs, rhs);
}

/**
 * Returns a string representation of a size range
 */
extern AS_WARN_UNUSED_RESULT NSString *NSStringFromASSizeRange(ASSizeRange sizeRange);

NS_ASSUME_NONNULL_END
ASDISPLAYNODE_EXTERN_C_END
