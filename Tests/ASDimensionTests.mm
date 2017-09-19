//
//  ASDimensionTests.mm
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

#import <XCTest/XCTest.h>
#import "ASXCTExtensions.h"
#import <AsyncDisplayKit/ASDimension.h>
#import <AsyncDisplayKit/ASLayoutContext.h>


@interface ASDimensionTests : XCTestCase
@end

@implementation ASDimensionTests

- (void)testCreatingDimensionUnitAutos
{
  XCTAssertNoThrow(ASDimensionMake(ASDimensionUnitAuto, 0));
  XCTAssertThrows(ASDimensionMake(ASDimensionUnitAuto, 100));
  ASXCTAssertEqualDimensions(ASDimensionAuto, ASDimensionMake(@""));
  ASXCTAssertEqualDimensions(ASDimensionAuto, ASDimensionMake(@"auto"));
}

- (void)testCreatingDimensionUnitFraction
{
  XCTAssertNoThrow(ASDimensionMake(ASDimensionUnitFraction, 0.5));
  ASXCTAssertEqualDimensions(ASDimensionMake(ASDimensionUnitFraction, 0.5), ASDimensionMake(@"50%"));
}

- (void)testCreatingDimensionUnitPoints
{
  XCTAssertNoThrow(ASDimensionMake(ASDimensionUnitPoints, 100));
  ASXCTAssertEqualDimensions(ASDimensionMake(ASDimensionUnitPoints, 100), ASDimensionMake(@"100pt"));
}

- (void)testIntersectingOverlappingSizeRangesReturnsTheirIntersection
{
  //  range: |---------|
  //  other:      |----------|
  // result:      |----|

  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext *range = [ASLayoutContext layoutContextWithMinSize:{0,0} maxSize:{10,10} traitCollection:traitCollection];
  ASLayoutContext *other = [ASLayoutContext layoutContextWithMinSize:{7,7} maxSize:{15,15} traitCollection:traitCollection];
  ASLayoutContext *result = [range intersectWithLayoutContext:other];
  ASLayoutContext *expected = [ASLayoutContext layoutContextWithMinSize:{7,7} maxSize:{10,10} traitCollection:traitCollection];
  XCTAssertEqualObjects(result, expected, @"Expected %@ but got %@", expected, result);
}

- (void)testIntersectingSizeRangeWithRangeThatContainsItReturnsSameRange
{
  //  range:    |-----|
  //  other:  |---------|
  // result:    |-----|

  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext *range = [ASLayoutContext layoutContextWithMinSize:{2,2} maxSize:{8,8} traitCollection:traitCollection];
  ASLayoutContext *other = [ASLayoutContext layoutContextWithMinSize:{0,0} maxSize:{10,10} traitCollection:traitCollection];
  ASLayoutContext *result = [range intersectWithLayoutContext:other];
  ASLayoutContext *expected = [ASLayoutContext layoutContextWithMinSize:{2,2} maxSize:{8,8} traitCollection:traitCollection];
  XCTAssertEqualObjects(result, expected, @"Expected %@ but got %@", expected, result);
}

- (void)testIntersectingSizeRangeWithRangeContainedWithinItReturnsContainedRange
{
  //  range:  |---------|
  //  other:    |-----|
  // result:    |-----|

  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext *range = [ASLayoutContext layoutContextWithMinSize:{0,0} maxSize:{10,10} traitCollection:traitCollection];
  ASLayoutContext *other = [ASLayoutContext layoutContextWithMinSize:{2,2} maxSize:{8,8} traitCollection:traitCollection];
  ASLayoutContext *result = [range intersectWithLayoutContext:other];
  ASLayoutContext *expected = [ASLayoutContext layoutContextWithMinSize:{2,2} maxSize:{8,8} traitCollection:traitCollection];
  XCTAssertEqualObjects(result, expected, @"Expected %@ but got %@", expected, result);
}

- (void)testIntersectingSizeRangeWithNonOverlappingRangeToRightReturnsSinglePointNearestOtherRange
{
  //  range: |-----|
  //  other:          |---|
  // result:       *

  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext *range = [ASLayoutContext layoutContextWithMinSize:{0,0} maxSize:{5,5} traitCollection:traitCollection];
  ASLayoutContext *other = [ASLayoutContext layoutContextWithMinSize:{10,10} maxSize:{15,15} traitCollection:traitCollection];
  ASLayoutContext *result = [range intersectWithLayoutContext:other];
  ASLayoutContext *expected = [ASLayoutContext layoutContextWithMinSize:{5,5} maxSize:{5,5} traitCollection:traitCollection];
  XCTAssertEqualObjects(result, expected, @"Expected %@ but got %@", expected, result);
}

- (void)testIntersectingSizeRangeWithNonOverlappingRangeToLeftReturnsSinglePointNearestOtherRange
{
  //  range:          |---|
  //  other: |-----|
  // result:          *

  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  ASLayoutContext *range = [ASLayoutContext layoutContextWithMinSize:{10,10} maxSize:{15,15} traitCollection:traitCollection];
  ASLayoutContext *other = [ASLayoutContext layoutContextWithMinSize:{0,0} maxSize:{5,5} traitCollection:traitCollection];
  ASLayoutContext *result = [range intersectWithLayoutContext:other];
  ASLayoutContext *expected = [ASLayoutContext layoutContextWithMinSize:{10,10} maxSize:{10,10} traitCollection:traitCollection];
  XCTAssertEqualObjects(result, expected, @"Expected %@ but got %@", expected, result);
}

@end
