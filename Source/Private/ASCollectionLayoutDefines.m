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
#import <AsyncDisplayKit/ASLayoutContext.h>

extern ASLayoutContext *ASLayoutContextForCollectionLayoutThatFitsViewportSize(CGSize viewportSize, ASScrollDirection scrollableDirections, ASPrimitiveTraitCollection traitCollection)
{
  CGSize min = CGSizeZero;
  CGSize max = CGSizeMake(INFINITY, INFINITY);
  if (ASScrollDirectionContainsVerticalDirection(scrollableDirections) == NO) {
    min.height = viewportSize.height;
    max.height = viewportSize.height;
  }
  if (ASScrollDirectionContainsHorizontalDirection(scrollableDirections) == NO) {
    min.width = viewportSize.width;
    max.width = viewportSize.width;
  }
  return [ASLayoutContext layoutContextWithMinSize:min maxSize:max traitCollection:traitCollection];
}
