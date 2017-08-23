//
//  ASDisplayNode+Deprecated.h
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

#import <AsyncDisplayKit/ASDisplayNode.h>

@interface ASDisplayNode (Deprecated)

ASLayoutElementStyleForwardingDeclaration

/**
 * @abstract Called whenever the visiblity of the node changed.
 *
 * @discussion Subclasses may use this to monitor when they become visible.
 *
 * @deprecated @see didEnterVisibleState @see didExitVisibleState
 */
- (void)visibilityDidChange:(BOOL)isVisible ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didEnterVisibleState / -didExitVisibleState instead.");

/**
 * @abstract Called whenever the visiblity of the node changed.
 *
 * @discussion Subclasses may use this to monitor when they become visible.
 *
 * @deprecated @see didEnterVisibleState @see didExitVisibleState
 */
- (void)visibleStateDidChange:(BOOL)isVisible ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didEnterVisibleState / -didExitVisibleState instead.");

/**
 * @abstract Called whenever the the node has entered or exited the display state.
 *
 * @discussion Subclasses may use this to monitor when a node should be rendering its content.
 *
 * @note This method can be called from any thread and should therefore be thread safe.
 *
 * @deprecated @see didEnterDisplayState @see didExitDisplayState
 */
- (void)displayStateDidChange:(BOOL)inDisplayState ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didEnterDisplayState / -didExitDisplayState instead.");

/**
 * @abstract Called whenever the the node has entered or left the load state.
 *
 * @discussion Subclasses may use this to monitor data for a node should be loaded, either from a local or remote source.
 *
 * @note This method can be called from any thread and should therefore be thread safe.
 *
 * @deprecated @see didEnterPreloadState @see didExitPreloadState
 */
- (void)loadStateDidChange:(BOOL)inLoadState ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didEnterPreloadState / -didExitPreloadState instead.");

/**
 * @abstract Cancels all performing layout transitions. Can be called on any thread.
 *
 * @deprecated Deprecated in version 2.0: Use cancelLayoutTransition
 */
- (void)cancelLayoutTransitionsInProgress ASDISPLAYNODE_DEPRECATED_MSG("Use -cancelLayoutTransition instead.");

/**
 * @abstract A boolean that shows whether the node automatically inserts and removes nodes based on the presence or
 * absence of the node and its subnodes is completely determined in its layoutSpecThatFits: method.
 *
 * @discussion If flag is YES the node no longer require addSubnode: or removeFromSupernode method calls. The presence
 * or absence of subnodes is completely determined in its layoutSpecThatFits: method.
 *
 * @deprecated Deprecated in version 2.0: Use automaticallyManagesSubnodes
 */
@property (nonatomic, assign) BOOL usesImplicitHierarchyManagement ASDISPLAYNODE_DEPRECATED_MSG("Set .automaticallyManagesSubnodes instead.");

/**
 * @abstract Indicates that the node should fetch any external data, such as images.
 *
 * @discussion Subclasses may override this method to be notified when they should begin to preload. Fetching
 * should be done asynchronously. The node is also responsible for managing the memory of any data.
 * The data may be remote and accessed via the network, but could also be a local database query.
 */
- (void)fetchData ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didEnterPreloadState instead.");

/**
 * Provides an opportunity to clear any fetched data (e.g. remote / network or database-queried) on the current node.
 *
 * @discussion This will not clear data recursively for all subnodes. Either call -recursivelyClearPreloadedData or
 * selectively clear fetched data.
 */
- (void)clearFetchedData ASDISPLAYNODE_REQUIRES_SUPER ASDISPLAYNODE_DEPRECATED_MSG("Use -didExitPreloadState instead.");

@end
