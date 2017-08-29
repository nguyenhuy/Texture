//
//  ASRatioLayoutSpec.mm
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

#import <AsyncDisplayKit/ASRatioLayoutSpec.h>

#import <algorithm>
#import <tgmath.h>
#import <vector>

#import <AsyncDisplayKit/ASLayoutSpec+Subclasses.h>

#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASInternalHelpers.h>

#pragma mark - ASRatioLayoutSpec

@implementation ASRatioLayoutSpec
{
  CGFloat _ratio;
}

#pragma mark - Lifecycle

+ (instancetype)ratioLayoutSpecWithRatio:(CGFloat)ratio child:(id<ASLayoutElement>)child
{
  return [[self alloc] initWithRatio:ratio child:child];
}

- (instancetype)initWithRatio:(CGFloat)ratio child:(id<ASLayoutElement>)child;
{
  if (!(self = [super init])) {
    return nil;
  }

  ASDisplayNodeAssertNotNil(child, @"Child cannot be nil");
  ASDisplayNodeAssert(ratio > 0, @"Ratio should be strictly positive, but received %f", ratio);
  _ratio = ratio;
  self.child = child;

  return self;
}

#pragma mark - Setter / Getter

- (void)setRatio:(CGFloat)ratio
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  _ratio = ratio;
}

#pragma mark - ASLayoutElement

- (ASLayout *)calculateLayoutThatFits:(ASLayoutContext)layoutContext
{
  std::vector<CGSize> sizeOptions;
  
  if (ASPointsValidForSize(layoutContext.max.width)) {
    sizeOptions.push_back(ASLayoutContextClamp(layoutContext, {
      layoutContext.max.width,
      ASFloorPixelValue(_ratio * layoutContext.max.width)
    }));
  }
  
  if (ASPointsValidForSize(layoutContext.max.height)) {
    sizeOptions.push_back(ASLayoutContextClamp(layoutContext, {
      ASFloorPixelValue(layoutContext.max.height / _ratio),
      layoutContext.max.height
    }));
  }

  // Choose the size closest to the desired ratio.
  const auto &bestSize = std::max_element(sizeOptions.begin(), sizeOptions.end(), [&](const CGSize &a, const CGSize &b){
    return std::fabs((a.height / a.width) - _ratio) > std::fabs((b.height / b.width) - _ratio);
  });

  // If there is no max size in *either* dimension, we can't apply the ratio, so just pass our size range through.
  const ASLayoutContext childContext = (bestSize == sizeOptions.end()) ? layoutContext : ASLayoutContextIntersect(layoutContext, ASLayoutContextMake(*bestSize, *bestSize, layoutContext.traitCollection));
  const CGSize parentSize = (bestSize == sizeOptions.end()) ? ASLayoutElementParentSizeUndefined : *bestSize;
  ASLayout *sublayout = [self.child layoutThatFits:childContext parentSize:parentSize];
  sublayout.position = CGPointZero;
  return [ASLayout layoutWithLayoutElement:self size:sublayout.size sublayouts:@[sublayout]];
}

@end

#pragma mark - ASRatioLayoutSpec (Debugging)

@implementation ASRatioLayoutSpec (Debugging)

#pragma mark - ASLayoutElementAsciiArtProtocol

- (NSString *)asciiArtName
{
  return [NSString stringWithFormat:@"%@ (%.1f)", NSStringFromClass([self class]), self.ratio];
}

@end
