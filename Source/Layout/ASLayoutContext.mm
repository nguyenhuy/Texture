//
//  ASLayoutContext.mm
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASLayoutContext.h>

#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASHashing.h>

struct _Range {
  CGFloat min;
  CGFloat max;

  /**
   Intersects another dimension range. If the other range does not overlap, this size range "wins" by returning a
   single point within its own range that is closest to the non-overlapping range.
   */
  _Range intersect(const _Range &other) const
  {
    CGFloat newMin = MAX(min, other.min);
    CGFloat newMax = MIN(max, other.max);
    if (newMin <= newMax) {
      return {newMin, newMax};
    } else {
      // No intersection. If we're before the other range, return our max; otherwise our min.
      if (min < other.min) {
        return {max, max};
      } else {
        return {min, min};
      }
    }
  }
};

@implementation ASLayoutContext

+ (instancetype)layoutContextWithMinSize:(CGSize)min maxSize:(CGSize)max traitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  return [[self alloc] initWithMinSize:min maxSize:max traitCollection:traitCollection];
}

+ (instancetype)layoutContextWithExactSize:(CGSize)size traitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  return [[self alloc] initWithMinSize:size maxSize:size traitCollection:traitCollection];
}

+ (instancetype)layoutContextWithZeroSizeAndTraitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  return [[self alloc] initWithMinSize:CGSizeZero maxSize:CGSizeZero traitCollection:traitCollection];
}

+ (instancetype)layoutContextWithUnconstrainedSizeRangeAndTraitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  return [[self alloc] initWithMinSize:CGSizeZero maxSize:CGSizeMake(INFINITY, INFINITY) traitCollection:traitCollection];
}

- (instancetype)initWithMinSize:(CGSize)min maxSize:(CGSize)max traitCollection:(ASPrimitiveTraitCollection)traitCollection
{
  self = [super init];
  if (self) {
    ASDisplayNodeCAssertPositiveReal(@"Range min width", min.width);
    ASDisplayNodeCAssertPositiveReal(@"Range min height", min.height);
    ASDisplayNodeCAssertInfOrPositiveReal(@"Range max width", max.width);
    ASDisplayNodeCAssertInfOrPositiveReal(@"Range max height", max.height);
    ASDisplayNodeCAssert(min.width <= max.width,
                         @"Range min width (%f) must not be larger than max width (%f).", min.width, max.width);
    ASDisplayNodeCAssert(min.height <= max.height,
                         @"Range min height (%f) must not be larger than max height (%f).", min.height, max.height);
    _min = min;
    _max = max;
    _traitCollection = traitCollection;
  }
  return self;
}

- (BOOL)hasSignificantArea
{
  static CGFloat const limit = 0.1f;
  return (self.max.width > limit && self.max.height > limit);
}

- (CGSize)clamp:(CGSize)size
{
  return CGSizeMake(MAX(self.min.width, MIN(self.max.width, size.width)),
                    MAX(self.min.height, MIN(self.max.height, size.height)));
}

- (ASLayoutContext *)intersectWithLayoutContext:(ASLayoutContext *)other
{
  ASPrimitiveTraitCollection traitCollection = self.traitCollection;
  // Make sure contexts have the same trait collection, otherwise we need to ask for one to use in the result.
  ASDisplayNodeAssertTrue(ASPrimitiveTraitCollectionIsEqualToASPrimitiveTraitCollection(traitCollection,
                                                                                        other.traitCollection));
  auto w = _Range({self.min.width, self.max.width}).intersect({other.min.width, other.max.width});
  auto h = _Range({self.min.height, self.max.height}).intersect({other.min.height, other.max.height});
  return [ASLayoutContext layoutContextWithMinSize:{w.min, h.min} maxSize:{w.max, h.max} traitCollection:traitCollection];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

#pragma mark - NSMutableCopying

- (id)mutableCopyWithZone:(NSZone *)zone
{
  return [ASMutableLayoutContext layoutContextWithMinSize:self.min maxSize:self.max traitCollection:self.traitCollection];
}

#pragma mark - Equality, hashing and description

- (BOOL)isEqualToLayoutContext:(ASLayoutContext *)other
{
  if (other == nil) {
    return NO;
  }

  return CGSizeEqualToSize(self.min, other.min)
  && CGSizeEqualToSize(self.max, other.max)
  && ASPrimitiveTraitCollectionIsEqualToASPrimitiveTraitCollection(self.traitCollection, other.traitCollection);
}

- (BOOL)isEqual:(id)other
{
  if (self == other) {
    return YES;
  }
  if (! [other isKindOfClass:[ASLayoutContext class]]) {
    return NO;
  }
  return [self isEqualToLayoutContext:other];
}

- (NSUInteger)hash
{
  struct {
    CGSize min;
    CGSize max;
    ASPrimitiveTraitCollection traitCollection;
  } data = {
    self.min,
    self.max,
    self.traitCollection
  };
  return ASHashBytes(&data, sizeof(data));
}

- (NSString *)description
{
  // 17 field length copied from iOS 10.3 impl of NSStringFromCGSize.
  if (CGSizeEqualToSize(self.min, self.max)) {
    return [NSString stringWithFormat:@"{{%.*g, %.*g}, %@}",
            17, self.min.width,
            17, self.min.height,
            NSStringFromASPrimitiveTraitCollection(self.traitCollection)];
  }
  return [NSString stringWithFormat:@"{{%.*g, %.*g}, {%.*g, %.*g}, %@}",
          17, self.min.width,
          17, self.min.height,
          17, self.max.width,
          17, self.max.height,
          NSStringFromASPrimitiveTraitCollection(self.traitCollection)];
}

@end

@implementation ASMutableLayoutContext

@synthesize min, max, traitCollection;

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
  return [ASLayoutContext layoutContextWithMinSize:self.min maxSize:self.max traitCollection:self.traitCollection];
}

@end
