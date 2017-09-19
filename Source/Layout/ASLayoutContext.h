//
//  ASLayoutContext.h
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#pragma once
#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASBaseDefines.h>
#import <AsyncDisplayKit/ASTraitCollection.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * An immutable context used to provide a simple constraint to measure layout elements.
 * A context expresses an inclusive range of sizes, as well as the current trait collection.
 */
@interface ASLayoutContext : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, assign, readonly) CGSize min;
@property (nonatomic, assign, readonly) CGSize max;
@property (nonatomic, assign, readonly) ASPrimitiveTraitCollection traitCollection;
/**
 * Whether this context has > 0.1 max width and max height.
 */
@property (nonatomic, assign, readonly) BOOL hasSignificantArea;

/**
 * A layout context with given size range and trait collection. Designated initializer.
 */
+ (instancetype)layoutContextWithMinSize:(CGSize)min
                                 maxSize:(CGSize)max
                         traitCollection:(ASPrimitiveTraitCollection)traitCollection;

/**
 * A layout context with an exact size range.
 */
+ (instancetype)layoutContextWithExactSize:(CGSize)size
                           traitCollection:(ASPrimitiveTraitCollection)traitCollection;

/**
 * A layout context with all dimensions zero.
 */
+ (instancetype)layoutContextWithZeroSizeAndTraitCollection:(ASPrimitiveTraitCollection)traitCollection;

/**
 * A layout context with size range from zero to infinity in both directions.
 */
+ (instancetype)layoutContextWithUnconstrainedSizeRangeAndTraitCollection:(ASPrimitiveTraitCollection)traitCollection;

- (instancetype)init __unavailable;

/**
 * Clamps the provided CGSize between the [min, max] bounds of this context.
 */
- (CGSize)clamp:(CGSize)size;

/**
 * Intersects the size range of this layout context with the one of another layout context.
 * If the size range of the other layout context does not overlap in either dimension, the size range of this layout context
 * "wins" by returning a single point within its own range that is closest to the non-overlapping range.
 */
- (ASLayoutContext *)intersectWithLayoutContext:(ASLayoutContext *)otherLayoutContext;

@end

AS_SUBCLASSING_RESTRICTED
@interface ASMutableLayoutContext : ASLayoutContext

@property (nonatomic, assign) CGSize min;
@property (nonatomic, assign) CGSize max;
@property (nonatomic, assign) ASPrimitiveTraitCollection traitCollection;

@end

NS_ASSUME_NONNULL_END
