//
//  ASDisplayNodeLayout.h
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
#import <AsyncDisplayKit/ASLayoutContext.h>

@class ASLayout;

/*
 * Represents a connection between an ASLayout and a ASDisplayNode
 * ASDisplayNode uses this to store additional information that are necessary besides the layout
 */
struct ASDisplayNodeLayout {
  ASLayout *layout;
  ASLayoutContext *layoutContext;
  CGSize parentSize;
  BOOL requestedLayoutFromAbove;
  NSUInteger version;
  
  /*
   * Create a new display node layout with
   * @param layout The layout to associate, usually returned from a call to -layoutThatFits:parentSize:
   * @param layoutContext Context used to create the layout
   * @param parentSize Parent size used to create the layout
   * @param version The version of the source layout data – see ASDisplayNode's _layoutVersion. 
   */
  ASDisplayNodeLayout(ASLayout *layout, ASLayoutContext *layoutContext, CGSize parentSize, NSUInteger version)
  : layout(layout), layoutContext(layoutContext), parentSize(parentSize), requestedLayoutFromAbove(NO), version(version) {};
  
  /*
   * Creates a layout without any layout associated. By default this display node layout is dirty.
   */
  ASDisplayNodeLayout()
  : layout(nil), layoutContext([ASLayoutContext layoutContextWithZeroSizeAndTraitCollection:(ASPrimitiveTraitCollectionMakeDefault())]), parentSize({0, 0}), requestedLayoutFromAbove(NO), version(0) {};
  
  /**
   * Returns whether this is valid for a given layout context, parent size, and version
   */
  BOOL isValid(ASLayoutContext *layoutContext, CGSize parentSize, NSUInteger version);
};
