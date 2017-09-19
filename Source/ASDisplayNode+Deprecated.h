//
//  ASDisplayNode.mm
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

#import <AsyncDisplayKit/ASDisplayNode.h>
#import <AsyncDisplayKit/ASDimension+Deprecated.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASDisplayNode (Deprecated)

/**
 * @abstract Return the constrained size range used for calculating layout.
 *
 * @return The minimum and maximum constrained sizes used by calculateLayoutThatFits:.
 */
@property (nonatomic, strong, readonly, nullable) ASSizeRange constrainedSizeForCalculatedLayout ASDISPLAYNODE_DEPRECATED_MSG("Use .contextForCalculatedLayout instead.");

/**
 * @abstract Transitions the current layout with a new constrained size. Must be called on main thread.
 *
 * @param constrainedSize The new constrained size to measure against.
 * @param animated Animation is optional, but will still proceed through your `animateLayoutTransition` implementation with `isAnimated == NO`.
 * @param shouldMeasureAsync Measure the layout asynchronously.
 * @param completion Optional completion block called only if a new layout is calculated.
 * It is called on main, right after the measurement and before -animateLayoutTransition:.
 *
 * @discussion If the passed constrainedSize is the the same as the node's current constrained size, this method is noop. If passed YES to shouldMeasureAsync it's guaranteed that measurement is happening on a background thread, otherwise measaurement will happen on the thread that the method was called on. The measurementCompletion callback is always called on the main thread right after the measurement and before -animateLayoutTransition:.
 *
 * @see animateLayoutTransition:
 *
 */
- (void)transitionLayoutWithSizeRange:(ASSizeRange)constrainedSize
                             animated:(BOOL)animated
                   shouldMeasureAsync:(BOOL)shouldMeasureAsync
                measurementCompletion:(nullable void(^)())completion ASDISPLAYNODE_DEPRECATED_MSG("Use -transitionLayoutWithLayoutContext:animated:shouldMeasureAsync:measurementCompletion: instead.");

@end

NS_ASSUME_NONNULL_END
