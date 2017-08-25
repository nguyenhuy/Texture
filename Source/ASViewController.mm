//
//  ASViewController.mm
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

#import <AsyncDisplayKit/ASViewController.h>
#import <AsyncDisplayKit/ASAssert.h>
#import <AsyncDisplayKit/ASDisplayNode+FrameworkPrivate.h>
#import <AsyncDisplayKit/ASLayout.h>
#import <AsyncDisplayKit/ASLog.h>
#import <AsyncDisplayKit/ASTraitCollection.h>
#import <AsyncDisplayKit/ASRangeControllerUpdateRangeProtocol+Beta.h>
#import <AsyncDisplayKit/ASInternalHelpers.h>

@implementation ASViewController
{
  BOOL _ensureDisplayed;
  BOOL _automaticallyAdjustRangeModeBasedOnViewEvents;
  BOOL _parentManagesVisibilityDepth;
  NSInteger _visibilityDepth;
  BOOL _selfConformsToRangeModeProtocol;
  BOOL _nodeConformsToRangeModeProtocol;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  if (!(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
    return nil;
  }
  
  [self _initializeInstance];
  
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
  if (!(self = [super initWithCoder:aDecoder])) {
    return nil;
  }
  
  [self _initializeInstance];
  
  return self;
}

- (instancetype)initWithNode:(ASDisplayNode *)node
{
  if (!(self = [super initWithNibName:nil bundle:nil])) {
    return nil;
  }
  
  _node = node;
  [self _initializeInstance];

  return self;
}

- (void)_initializeInstance
{
  if (_node == nil) {
    return;
  }
  
  _selfConformsToRangeModeProtocol = [self conformsToProtocol:@protocol(ASRangeControllerUpdateRangeProtocol)];
  _nodeConformsToRangeModeProtocol = [_node conformsToProtocol:@protocol(ASRangeControllerUpdateRangeProtocol)];
  _automaticallyAdjustRangeModeBasedOnViewEvents = _selfConformsToRangeModeProtocol || _nodeConformsToRangeModeProtocol;
  
  // In case the node will get loaded
  if (_node.nodeLoaded) {
    // Node already loaded the view
    [self view];
  } else {
    // If the node didn't load yet add ourselves as on did load observer to load the view in case the node gets loaded
    // before the view controller
    __weak __typeof__(self) weakSelf = self;
    [_node onDidLoad:^(__kindof ASDisplayNode * _Nonnull node) {
      if ([weakSelf isViewLoaded] == NO) {
        [weakSelf view];
      }
    }];
  }
}

- (void)dealloc
{
  ASPerformBackgroundDeallocation(&_node);
}

- (void)loadView
{
  // Apple applies a frame and autoresizing masks we need.  Allocating a view is not
  // nearly as expensive as adding and removing it from a hierarchy, and fortunately
  // we can avoid that here.  Enabling layerBacking on a single node in the hierarchy
  // will have a greater performance benefit than the impact of this transient view.
  [super loadView];
  
  if (_node == nil) {
    return;
  }
  
  ASDisplayNodeAssertTrue(!_node.layerBacked);
  
  UIView *view = self.view;
  CGRect frame = view.frame;
  UIViewAutoresizing autoresizingMask = view.autoresizingMask;
  
  // We have what we need, so now create and assign the view we actually want.
  view = _node.view;
  _node.frame = frame;
  _node.autoresizingMask = autoresizingMask;
  self.view = view;
}

- (void)viewWillLayoutSubviews
{
  [super viewWillLayoutSubviews];

  as_activity_scope_verbose(as_activity_create("-[ASViewController viewWillLayoutSubViews]", AS_ACTIVITY_CURRENT, OS_ACTIVITY_FLAG_DEFAULT));

  ASPrimitiveTraitCollection traitCollection = [self primitiveTraitCollectionForUITraitCollection:self.traitCollection];
  ASLayoutContext layoutContext = ASLayoutContextMake(self.view.bounds.size, traitCollection);
  as_log_debug(ASNodeLog(), "Will layout with layoutContext %@: %@", self, NSStringFromASLayoutContext(layoutContext));

  // Call -layoutThatFits: to let the node prepare for a layout that will happen shortly in the layout pass of the view.
  // If the node's layout context didn't change between the last layout pass it's a no-op
  [_node layoutThatFits:layoutContext];
}

- (void)viewDidLayoutSubviews
{
  if (_ensureDisplayed && self.neverShowPlaceholders) {
    _ensureDisplayed = NO;
    [_node recursivelyEnsureDisplaySynchronously:YES];
  }
  [super viewDidLayoutSubviews];
}

ASVisibilityDidMoveToParentViewController;

- (void)viewWillAppear:(BOOL)animated
{
  as_activity_create_for_scope("ASViewController will appear");
  as_log_debug(ASNodeLog(), "View controller %@ will appear", self);

  [super viewWillAppear:animated];

  _ensureDisplayed = YES;

  // A layout pass is forced this early to get nodes like ASCollectionNode, ASTableNode etc.
  // into the hierarchy before UIKit applies the scroll view inset adjustments, if automatic subnode management
  // is enabled. Otherwise the insets would not be applied.
  [_node.view layoutIfNeeded];
  
  if (_parentManagesVisibilityDepth == NO) {
    [self setVisibilityDepth:0];
  }
}

ASVisibilitySetVisibilityDepth;

ASVisibilityViewDidDisappearImplementation;

ASVisibilityDepthImplementation;

- (void)visibilityDepthDidChange
{
  ASLayoutRangeMode rangeMode = ASLayoutRangeModeForVisibilityDepth(self.visibilityDepth);
#if ASEnableVerboseLogging
  NSString *rangeModeString;
  switch (rangeMode) {
    case ASLayoutRangeModeMinimum:
      rangeModeString = @"Minimum";
      break;
      
    case ASLayoutRangeModeFull:
      rangeModeString = @"Full";
      break;
      
    case ASLayoutRangeModeVisibleOnly:
      rangeModeString = @"Visible Only";
      break;
      
    case ASLayoutRangeModeLowMemory:
      rangeModeString = @"Low Memory";
      break;
      
    default:
      break;
  }
  as_log_verbose(ASNodeLog(), "Updating visibility of %@ to: %@ (visibility depth: %zd)", self, rangeModeString, self.visibilityDepth);
#endif
  [self updateCurrentRangeModeWithModeIfPossible:rangeMode];
}

#pragma mark - Automatic range mode

- (BOOL)automaticallyAdjustRangeModeBasedOnViewEvents
{
  return _automaticallyAdjustRangeModeBasedOnViewEvents;
}

- (void)setAutomaticallyAdjustRangeModeBasedOnViewEvents:(BOOL)automaticallyAdjustRangeModeBasedOnViewEvents
{
  if (automaticallyAdjustRangeModeBasedOnViewEvents != _automaticallyAdjustRangeModeBasedOnViewEvents) {
    if (automaticallyAdjustRangeModeBasedOnViewEvents && _selfConformsToRangeModeProtocol == NO && _nodeConformsToRangeModeProtocol == NO) {
      NSLog(@"Warning: automaticallyAdjustRangeModeBasedOnViewEvents set to YES in %@, but range mode updating is not possible because neither view controller nor node %@ conform to ASRangeControllerUpdateRangeProtocol.", self, _node);
    }
    _automaticallyAdjustRangeModeBasedOnViewEvents = automaticallyAdjustRangeModeBasedOnViewEvents;
  }
}

- (void)updateCurrentRangeModeWithModeIfPossible:(ASLayoutRangeMode)rangeMode
{
  if (!_automaticallyAdjustRangeModeBasedOnViewEvents) {
    return;
  }
  
  if (_selfConformsToRangeModeProtocol) {
    id<ASRangeControllerUpdateRangeProtocol> rangeUpdater = (id<ASRangeControllerUpdateRangeProtocol>)self;
    [rangeUpdater updateCurrentRangeWithMode:rangeMode];
  }
  
  if (_nodeConformsToRangeModeProtocol) {
    id<ASRangeControllerUpdateRangeProtocol> rangeUpdater = (id<ASRangeControllerUpdateRangeProtocol>)_node;
    [rangeUpdater updateCurrentRangeWithMode:rangeMode];
  }
}

#pragma mark - Layout Helpers

- (ASInterfaceState)interfaceState
{
  return _node.interfaceState;
}

#pragma mark - ASTraitEnvironment

- (ASPrimitiveTraitCollection)primitiveTraitCollectionForUITraitCollection:(UITraitCollection *)traitCollection
{
  if (self.overrideDisplayTraitsWithTraitCollection) {
    ASTraitCollection *asyncTraitCollection = self.overrideDisplayTraitsWithTraitCollection(traitCollection);
    return [asyncTraitCollection primitiveTraitCollection];
  }
  
  ASDisplayNodeAssertMainThread();
  ASPrimitiveTraitCollection asyncTraitCollection = ASPrimitiveTraitCollectionFromUITraitCollection(traitCollection);
  asyncTraitCollection.containerSize = self.view.frame.size;
  return asyncTraitCollection;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
  [super traitCollectionDidChange:previousTraitCollection];
  
  ASPrimitiveTraitCollection traitCollection = [self primitiveTraitCollectionForUITraitCollection:self.traitCollection];
  traitCollection.containerSize = self.view.bounds.size;
  // TODO: Run another layout pass with this new trait collection
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];

  // TODO: Get the trait collection from node's layout context for calculated layout
//  ASPrimitiveTraitCollection traitCollection = _node.primitiveTraitCollection;
//  traitCollection.containerSize = self.view.bounds.size;
  // TODO: Run another layout pass with this new trait collection
}

@end
