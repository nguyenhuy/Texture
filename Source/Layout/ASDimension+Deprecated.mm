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

#import <AsyncDisplayKit/ASDimension+Deprecated.h>
#import <AsyncDisplayKit/ASLayoutContext.h>

#pragma mark - ASSizeRange

ASSizeRange const ASSizeRangeZero = ASSizeRangeMake(CGSizeZero);

ASSizeRange const ASSizeRangeUnconstrained = ASSizeRangeMake({0, 0}, { INFINITY, INFINITY });

ASOVERLOADABLE ASSizeRange ASSizeRangeMake(CGSize min, CGSize max)
{
  return [ASLayoutContext layoutContextWithMinSize:min maxSize:max traitCollection:ASPrimitiveTraitCollectionMakeDefault()];
}

ASOVERLOADABLE ASSizeRange ASSizeRangeMake(CGSize exactSize)
{
  return [ASLayoutContext layoutContextWithExactSize:exactSize traitCollection:ASPrimitiveTraitCollectionMakeDefault()];
}

BOOL ASSizeRangeHasSignificantArea(ASSizeRange sizeRange)
{
  return sizeRange.hasSignificantArea;
}

CGSize ASSizeRangeClamp(ASSizeRange sizeRange, CGSize size)
{
  return [sizeRange clamp:size];
}

ASSizeRange ASSizeRangeIntersect(ASSizeRange sizeRange, ASSizeRange otherSizeRange)
{
  return [sizeRange intersectWithLayoutContext:otherSizeRange];
}

BOOL ASSizeRangeEqualToSizeRange(ASSizeRange lhs, ASSizeRange rhs)
{
  return [lhs isEqual:rhs];
}

NSString *NSStringFromASSizeRange(ASSizeRange sizeRange)
{
  return sizeRange.description;
}
