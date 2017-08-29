//
//  ASCollectionLayoutDefines.m
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASCollectionLayoutDefines.h>

extern ASLayoutContext ASLayoutContextForCollectionLayoutThatFitsViewportSize(CGSize viewportSize, ASScrollDirection scrollableDirections, ASPrimitiveTraitCollection traitCollection)
{
  ASLayoutContext layoutContext = ASLayoutContextMakeWithUnconstrainedSizeRange(traitCollection);
  if (ASScrollDirectionContainsVerticalDirection(scrollableDirections) == NO) {
    layoutContext.min.height = viewportSize.height;
    layoutContext.max.height = viewportSize.height;
  }
  if (ASScrollDirectionContainsHorizontalDirection(scrollableDirections) == NO) {
    layoutContext.min.width = viewportSize.width;
    layoutContext.max.width = viewportSize.width;
  }
  return layoutContext;
}
