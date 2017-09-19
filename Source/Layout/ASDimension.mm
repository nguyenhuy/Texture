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
