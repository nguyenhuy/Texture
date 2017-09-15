//
//  ASAbsoluteLayoutSpecSnapshotTests.m
//  Texture
//
//  Created by Huy Nguyen on 18/10/15.
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

#import "ASLayoutSpecSnapshotTestsHelper.h"

#import <AsyncDisplayKit/ASAbsoluteLayoutSpec.h>
#import <AsyncDisplayKit/ASBackgroundLayoutSpec.h>

@interface ASAbsoluteLayoutSpecSnapshotTests : ASLayoutSpecSnapshotTestCase
@end

@implementation ASAbsoluteLayoutSpecSnapshotTests

- (void)testSizingBehaviour
{
  ASPrimitiveTraitCollection traitCollection = ASPrimitiveTraitCollectionMakeDefault();
  [self testWithLayoutContext:ASLayoutContextMake(CGSizeMake(150, 200), CGSizeMake(INFINITY, INFINITY), traitCollection)
               identifier:@"underflowChildren"];
  [self testWithLayoutContext:ASLayoutContextMake(CGSizeZero, CGSizeMake(50, 100), traitCollection)
               identifier:@"overflowChildren"];
  // Expect the spec to wrap its content because children sizes are between constrained size
  [self testWithLayoutContext:ASLayoutContextMake(CGSizeZero, CGSizeMake(INFINITY / 2, INFINITY / 2), traitCollection)
               identifier:@"wrappedChildren"];
}

- (void)testChildrenMeasuredWithAutoMaxSize
{
  ASDisplayNode *firstChild = ASDisplayNodeWithBackgroundColor([UIColor redColor], (CGSize){50, 50});
  firstChild.style.layoutPosition = CGPointMake(0, 0);
  
  ASDisplayNode *secondChild = ASDisplayNodeWithBackgroundColor([UIColor blueColor], (CGSize){100, 100});
  secondChild.style.layoutPosition = CGPointMake(10, 60);

  ASLayoutContext layoutContext = ASLayoutContextMake(CGSizeMake(10, 10), CGSizeMake(110, 160), ASPrimitiveTraitCollectionMakeDefault());
  [self testWithChildren:@[firstChild, secondChild] layoutContext:layoutContext identifier:nil];
}

- (void)testWithLayoutContext:(ASLayoutContext)layoutContext identifier:(NSString *)identifier
{
  ASDisplayNode *firstChild = ASDisplayNodeWithBackgroundColor([UIColor redColor], (CGSize){50, 50});
  firstChild.style.layoutPosition = CGPointMake(0, 0);
  
  ASDisplayNode *secondChild = ASDisplayNodeWithBackgroundColor([UIColor blueColor], (CGSize){100, 100});
  secondChild.style.layoutPosition = CGPointMake(0, 50);
  
  [self testWithChildren:@[firstChild, secondChild] layoutContext:layoutContext identifier:identifier];
}

- (void)testWithChildren:(NSArray *)children layoutContext:(ASLayoutContext)layoutContext identifier:(NSString *)identifier
{
  ASDisplayNode *backgroundNode = ASDisplayNodeWithBackgroundColor([UIColor whiteColor]);

  NSMutableArray *subnodes = [NSMutableArray arrayWithArray:children];
  [subnodes insertObject:backgroundNode atIndex:0];

  ASLayoutSpec *layoutSpec =
  [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:
   [ASAbsoluteLayoutSpec
    absoluteLayoutSpecWithChildren:children]
   background:backgroundNode];
  
  [self testLayoutSpec:layoutSpec layoutContext:layoutContext subnodes:subnodes identifier:identifier];
}

@end
