//
//  ASWrapperSpecSnapshotTests.mm
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


#import "ASLayoutSpecSnapshotTestsHelper.h"
#import <AsyncDisplayKit/ASBackgroundLayoutSpec.h>

@interface ASWrapperSpecSnapshotTests : ASLayoutSpecSnapshotTestCase
@end

@implementation ASWrapperSpecSnapshotTests

- (void)testWrapperSpecWithOneElementShouldSizeToElement
{
  ASDisplayNode *child = ASDisplayNodeWithBackgroundColor([UIColor redColor], {50, 50});
  
  ASLayoutContext layoutContext = ASLayoutContextMake(CGSizeZero, CGSizeMake(INFINITY, INFINITY), ASPrimitiveTraitCollectionMakeDefault());
  [self testWithChildren:@[child] layoutContext:layoutContext identifier:nil];
}

- (void)testWrapperSpecWithMultipleElementsShouldSizeToLargestElement
{
  ASDisplayNode *firstChild = ASDisplayNodeWithBackgroundColor([UIColor redColor], {50, 50});
  ASDisplayNode *secondChild = ASDisplayNodeWithBackgroundColor([UIColor greenColor], {100, 100});
  
  ASLayoutContext layoutContext = ASLayoutContextMake(CGSizeZero, CGSizeMake(INFINITY, INFINITY), ASPrimitiveTraitCollectionMakeDefault());
  [self testWithChildren:@[secondChild, firstChild] layoutContext:layoutContext identifier:nil];
}

- (void)testWithChildren:(NSArray *)children layoutContext:(ASLayoutContext)layoutContext identifier:(NSString *)identifier
{
  ASDisplayNode *backgroundNode = ASDisplayNodeWithBackgroundColor([UIColor whiteColor]);

  NSMutableArray *subnodes = [NSMutableArray arrayWithArray:children];
  [subnodes insertObject:backgroundNode atIndex:0];

  ASLayoutSpec *layoutSpec =
  [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:
   [ASWrapperLayoutSpec
    wrapperWithLayoutElements:children]
   background:backgroundNode];
  
  [self testLayoutSpec:layoutSpec layoutContext:layoutContext subnodes:subnodes identifier:identifier];
}

@end
