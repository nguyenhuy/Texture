//
//  ASDimension.h
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
#import <UIKit/UIGeometry.h>
#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASAvailability.h>
#import <AsyncDisplayKit/ASBaseDefines.h>
#import <AsyncDisplayKit/ASTraitCollection.h>

ASDISPLAYNODE_EXTERN_C_BEGIN
NS_ASSUME_NONNULL_BEGIN

#pragma mark -

ASDISPLAYNODE_INLINE BOOL AS_WARN_UNUSED_RESULT ASPointsValidForLayout(CGFloat points)
{
  return ((isnormal(points) || points == 0.0) && points >= 0.0 && points < (CGFLOAT_MAX / 2.0));
}

ASDISPLAYNODE_INLINE BOOL AS_WARN_UNUSED_RESULT ASIsCGSizeValidForLayout(CGSize size)
{
  return (ASPointsValidForLayout(size.width) && ASPointsValidForLayout(size.height));
}

ASDISPLAYNODE_INLINE BOOL AS_WARN_UNUSED_RESULT ASPointsValidForSize(CGFloat points)
{
  return ((isnormal(points) || points == 0.0) && points >= 0.0 && points < (FLT_MAX / 2.0));
}

ASDISPLAYNODE_INLINE BOOL AS_WARN_UNUSED_RESULT ASIsCGSizeValidForSize(CGSize size)
{
  return (ASPointsValidForSize(size.width) && ASPointsValidForSize(size.height));
}

ASDISPLAYNODE_INLINE BOOL ASIsCGPositionPointsValidForLayout(CGFloat points)
{
  return ((isnormal(points) || points == 0.0) && points < (CGFLOAT_MAX / 2.0));
}

ASDISPLAYNODE_INLINE BOOL ASIsCGPositionValidForLayout(CGPoint point)
{
  return (ASIsCGPositionPointsValidForLayout(point.x) && ASIsCGPositionPointsValidForLayout(point.y));
}

ASDISPLAYNODE_INLINE BOOL ASIsCGRectValidForLayout(CGRect rect)
{
  return (ASIsCGPositionValidForLayout(rect.origin) && ASIsCGSizeValidForLayout(rect.size));
}

#pragma mark - ASDimension

/**
 * A dimension relative to constraints to be provided in the future.
 * A ASDimension can be one of three types:
 *
 * "Auto" - This indicated "I have no opinion" and may be resolved in whatever way makes most sense given the circumstances.
 *
 * "Points" - Just a number. It will always resolve to exactly this amount.
 *
 * "Percent" - Multiplied to a provided parent amount to resolve a final amount.
 */
typedef NS_ENUM(NSInteger, ASDimensionUnit) {
  /** This indicates "I have no opinion" and may be resolved in whatever way makes most sense given the circumstances. */
  ASDimensionUnitAuto,
  /** Just a number. It will always resolve to exactly this amount. This is the default type. */
  ASDimensionUnitPoints,
  /** Multiplied to a provided parent amount to resolve a final amount. */
  ASDimensionUnitFraction,
};

typedef struct {
  ASDimensionUnit unit;
  CGFloat value;
} ASDimension;

/**
 * Represents auto as ASDimension
 */
extern ASDimension const ASDimensionAuto;

/**
 * Returns a dimension with the specified type and value.
 */
ASOVERLOADABLE ASDISPLAYNODE_INLINE ASDimension ASDimensionMake(ASDimensionUnit unit, CGFloat value)
{
  if (unit == ASDimensionUnitAuto ) {
    ASDisplayNodeCAssert(value == 0, @"ASDimension auto value must be 0.");
  } else if (unit == ASDimensionUnitPoints) {
    ASDisplayNodeCAssertPositiveReal(@"Points", value);
  } else if (unit == ASDimensionUnitFraction) {
    ASDisplayNodeCAssert( 0 <= value && value <= 1.0, @"ASDimension fraction value (%f) must be between 0 and 1.", value);
  }
  ASDimension dimension;
  dimension.unit = unit;
  dimension.value = value;
  return dimension;
}

/**
 * Returns a dimension with the specified points value.
 */
ASOVERLOADABLE ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASDimension ASDimensionMake(CGFloat points)
{
  return ASDimensionMake(ASDimensionUnitPoints, points);
}

/**
 * Returns a dimension by parsing the specified dimension string.
 * Examples: ASDimensionMake(@"50%") = ASDimensionMake(ASDimensionUnitFraction, 0.5)
 *           ASDimensionMake(@"0.5pt") = ASDimensionMake(ASDimensionUnitPoints, 0.5)
 */
ASOVERLOADABLE AS_WARN_UNUSED_RESULT extern ASDimension ASDimensionMake(NSString *dimension);

/**
 * Returns a dimension with the specified points value.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASDimension ASDimensionMakeWithPoints(CGFloat points)
{
  ASDisplayNodeCAssertPositiveReal(@"Points", points);
  return ASDimensionMake(ASDimensionUnitPoints, points);
}

/**
 * Returns a dimension with the specified fraction value.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASDimension ASDimensionMakeWithFraction(CGFloat fraction)
{
  ASDisplayNodeCAssert( 0 <= fraction && fraction <= 1.0, @"ASDimension fraction value (%f) must be between 0 and 1.", fraction);
  return ASDimensionMake(ASDimensionUnitFraction, fraction);
}

/**
 * Returns whether two dimensions are equal.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT BOOL ASDimensionEqualToDimension(ASDimension lhs, ASDimension rhs)
{
  return (lhs.unit == rhs.unit && lhs.value == rhs.value);
}

/**
 * Returns a NSString representation of a dimension.
 */
extern AS_WARN_UNUSED_RESULT NSString *NSStringFromASDimension(ASDimension dimension);

/**
 * Resolve this dimension to a parent size.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT CGFloat ASDimensionResolve(ASDimension dimension, CGFloat parentSize, CGFloat autoSize)
{
  switch (dimension.unit) {
    case ASDimensionUnitAuto:
      return autoSize;
    case ASDimensionUnitPoints:
      return dimension.value;
    case ASDimensionUnitFraction:
      return dimension.value * parentSize;
  }
}

#pragma mark - ASLayoutSize

/**
 * Expresses a size with relative dimensions. Only used for calculations internally in ASDimension.h
 */
typedef struct {
  ASDimension width;
  ASDimension height;
} ASLayoutSize;

extern ASLayoutSize const ASLayoutSizeAuto;

/*
 * Creates an ASLayoutSize with provided min and max dimensions.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT ASLayoutSize ASLayoutSizeMake(ASDimension width, ASDimension height)
{
  ASLayoutSize size;
  size.width = width;
  size.height = height;
  return size;
}

/**
 * Resolve this relative size relative to a parent size.
 */
ASDISPLAYNODE_INLINE CGSize ASLayoutSizeResolveSize(ASLayoutSize layoutSize, CGSize parentSize, CGSize autoSize)
{
  return CGSizeMake(ASDimensionResolve(layoutSize.width, parentSize.width, autoSize.width),
                    ASDimensionResolve(layoutSize.height, parentSize.height, autoSize.height));
}

/*
 * Returns a string representation of a relative size.
 */
ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT NSString *NSStringFromASLayoutSize(ASLayoutSize size)
{
  return [NSString stringWithFormat:@"{%@, %@}",
          NSStringFromASDimension(size.width),
          NSStringFromASDimension(size.height)];
}

#if YOGA

#pragma mark - ASEdgeInsets

typedef struct {
  ASDimension top;
  ASDimension left;
  ASDimension bottom;
  ASDimension right;
  ASDimension start;
  ASDimension end;
  ASDimension horizontal;
  ASDimension vertical;
  ASDimension all;
} ASEdgeInsets;

extern ASEdgeInsets const ASEdgeInsetsZero;

extern ASEdgeInsets ASEdgeInsetsMake(UIEdgeInsets edgeInsets);

#endif

NS_ASSUME_NONNULL_END
ASDISPLAYNODE_EXTERN_C_END
