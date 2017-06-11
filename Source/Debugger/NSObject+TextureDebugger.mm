//
//  NSObject+TextureDebugger.mm
//  Texture
//
//  Copyright (c) 2017-present, Pinterest, Inc.  All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASAvailability.h>

#if AS_TEXTURE_DEBUGGER

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASCollectionElement.h>
#import <AsyncDisplayKit/ASLayoutElementStylePrivate.h>
#import <AsyncDisplaykit/ASRectTable.h>
#import <AsyncDisplayKit/NSObject+TextureDebugger.h>
#import <AsyncDisplayKit/TDDOMContext.h>

#import <PonyDebugger/PDDOMTypes.h>
#import <PonyDebugger/PDCSSTypes.h>

#import <queue>

// Constants defined in the DOM Level 2 Core: http://www.w3.org/TR/DOM-Level-2-Core/core.html#ID-1950641247
static const int kPDDOMNodeTypeElement = 1;

#pragma mark PDDOMNodeProviding

@interface NSObject (TDDOMNodeGenerating)

+ (nonnull NSString *)td_nodeName;

@end

@implementation NSObject (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"object";
}

- (PDDOMNode *)td_generateDOMNodeWithContext:(TDDOMContext *)context
{
  NSNumber *nodeId = [context idForObject:self];
  [context.idToFrameInWindow setRect:[self td_frameInWindow] forKey:nodeId];
  
  PDDOMNode *node = [[PDDOMNode alloc] init];
  node.nodeType = @(kPDDOMNodeTypeElement);
  node.nodeId = nodeId;
  node.nodeName = [[self class] td_nodeName];
  node.attributes = @[ @"description", self.debugDescription ];

  NSMutableArray *nodeChildren = [NSMutableArray array];
  for (id child in [self td_children]) {
    [nodeChildren addObject:[child td_generateDOMNodeWithContext:context]];
  }
  node.children = nodeChildren;
  node.childNodeCount = @(nodeChildren.count);
  
  return node;
}

- (CGRect)td_frameInWindow
{
  return CGRectNull;
}

- (NSArray *)td_children
{
  return @[];
}

@end

@implementation UIApplication (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"application";
}

- (NSArray *)td_children
{
  return self.windows;
}

@end

@implementation CALayer (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"layer";
}

- (PDDOMNode *)td_generateDOMNodeWithContext:(TDDOMContext *)context
{
  // For backing store of a display node (view/layer), let the node handle this job
  ASDisplayNode *displayNode = ASLayerToDisplayNode(self);
  if (displayNode) {
    return [displayNode td_generateDOMNodeWithContext:context];
  }
  
  return [super td_generateDOMNodeWithContext:context];
}

- (CGRect)td_frameInWindow
{
  // FIXME this is probably wrong :(
  return [self convertRect:self.bounds toLayer:nil];
}

- (NSArray *)td_children
{
  return self.sublayers;
}

@end

@implementation UIView (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"view";
}

- (PDDOMNode *)td_generateDOMNodeWithContext:(TDDOMContext *)context
{
  // For backing store of a display node (view/layer), let the node handle this job
  ASDisplayNode *displayNode = ASViewToDisplayNode(self);
  if (displayNode) {
    return [displayNode td_generateDOMNodeWithContext:context];
  }
  
  return [super td_generateDOMNodeWithContext:context];
}

- (CGRect)td_frameInWindow
{
  return [self convertRect:self.bounds toView:nil];
}

- (NSArray *)td_children
{
  return self.subviews;
}

@end

@implementation UIWindow (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"window";
}

@end

@implementation ASLayoutSpec (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"layout-spec";
}

@end

@implementation ASDisplayNode (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"display-node";
}

- (PDDOMNode *)td_generateDOMNodeWithContext:(TDDOMContext *)DOMCcontext
{
  PDDOMNode *rootNode = [super td_generateDOMNodeWithContext:DOMCcontext];
  if (rootNode.childNodeCount.intValue > 0) {
    // If rootNode.children was populated, return right away.
    return rootNode;
  }
  
  /*
   * The rest of this method does 2 things:
   * - Generate the rest of the DOM tree:
   *      ASDisplayNode has a different way to generate DOM children.
   *      That is, from an unflattened layout, a DOM child is generated from the layout element of each sublayout in the layout tree.
   *      In addition, since non-display-node layout elements (e.g layout specs) don't (and shouldn't) store their calculated layout,
   *      they can't generate their own DOM children. So it's the responsibility of the root display node to fill out the gaps.
   * - Calculate the frame in window of some layout elements in the layout tree:
   *      Non-display-node layout elements can't determine their own frame because they don't have a backing store.
   *      Thus, it's also the responsibility of the root display node to calculate and keep track of the frame of each child
   *      and assign to it if need to.
   */
  struct Context {
    PDDOMNode *node;
    ASLayout *layout;
    CGRect frameInWindow;
  };
  
  // Queue used to keep track of sublayouts while traversing this layout in BFS frashion.
  std::queue<Context> queue;
  queue.push({rootNode, self.unflattenedCalculatedLayout, self.td_frameInWindow});
  
  while (!queue.empty()) {
    Context context = queue.front();
    queue.pop();
    
    ASLayout *layout = context.layout;
    NSArray<ASLayout *> *sublayouts = layout.sublayouts;
    PDDOMNode *node = context.node;
    NSMutableArray<PDDOMNode *> *children = [NSMutableArray arrayWithCapacity:sublayouts.count];
    CGRect frameInWindow = context.frameInWindow;
    
    for (ASLayout *sublayout in sublayouts) {
      NSObject<ASLayoutElement> *sublayoutElement = sublayout.layoutElement;
      PDDOMNode *subnode = [sublayoutElement td_generateDOMNodeWithContext:DOMCcontext];
      [children addObject:subnode];
      
      // Non-display-node (sub)elements can't generate their own DOM children and frame in window
      // We calculate the frame and assign to those now
      // We add them to the queue to generate their DOM children later
      if ([sublayout.layoutElement isKindOfClass:[ASDisplayNode class]] == NO) {
        CGRect sublayoutElementFrameInWindow = CGRectNull;
        if (! CGRectIsNull(frameInWindow)) {
          sublayoutElementFrameInWindow = CGRectMake(frameInWindow.origin.x + sublayout.position.x,
                                                     frameInWindow.origin.y + sublayout.position.y,
                                                     sublayout.size.width,
                                                     sublayout.size.height);
        }
        [DOMCcontext.idToFrameInWindow setRect:sublayoutElementFrameInWindow forKey:subnode.nodeId];
        
        queue.push({subnode, sublayout, sublayoutElementFrameInWindow});
      }
    }
    
    node.children = children;
    node.childNodeCount = @(children.count);
  }
  
  return rootNode;
}

- (CGRect)td_frameInWindow
{
  if (self.isNodeLoaded == NO || self.isInHierarchy == NO) {
    return CGRectNull;
  }
  
  if (self.layerBacked) {
    return self.layer.td_frameInWindow;
  } else {
    return self.view.td_frameInWindow;
  }
}

@end

@implementation ASCollectionNode (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"collection-node";
}

- (NSArray *)td_children
{
  // Only show visible nodes for now. This requires user to refresh the browser to update the DOM.
  return self.visibleNodes;
}

@end

@implementation ASTableNode (PDDOMNodeProviding)

+ (NSString *)td_nodeName
{
  return @"table-node";
}

- (NSArray *)td_children
{
  // Only show visible nodes for now. This requires user to refresh the browser to update the DOM.
  return self.visibleNodes;
}

@end

#pragma mark PDCSSRuleMatchesProviding - Helpers and Commons

ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT NSArray<PDCSSProperty *> *PDCSSPropertiesFromASLayoutElementSize(ASLayoutElementSize size)
{
  return @[
           [PDCSSProperty propertyWithName:@"width" value:NSStringFromASDimension(size.width)],
           [PDCSSProperty propertyWithName:@"height" value:NSStringFromASDimension(size.height)],
           [PDCSSProperty propertyWithName:@"minWidth" value:NSStringFromASDimension(size.minWidth)],
           [PDCSSProperty propertyWithName:@"maxWidth" value:NSStringFromASDimension(size.maxWidth)],
           [PDCSSProperty propertyWithName:@"minHeight" value:NSStringFromASDimension(size.minHeight)],
           [PDCSSProperty propertyWithName:@"maxHeight" value:NSStringFromASDimension(size.maxHeight)],
           ];
}

ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT NSArray<PDCSSProperty *> *PDCSSPropertiesFromASStackLayoutElement(id<ASStackLayoutElement> element)
{
  return @[
           [PDCSSProperty propertyWithName:@"spacingBefore" value:@(element.spacingBefore).stringValue],
           [PDCSSProperty propertyWithName:@"spacingAfter" value:@(element.spacingAfter).stringValue],
           [PDCSSProperty propertyWithName:@"flexGrow" value:@(element.flexGrow).stringValue],
           [PDCSSProperty propertyWithName:@"flexShrink" value:@(element.flexShrink).stringValue],
           [PDCSSProperty propertyWithName:@"flexBasis" value:NSStringFromASDimension(element.flexBasis)],
           [PDCSSProperty propertyWithName:@"alignSelf" value:@(element.alignSelf).stringValue], // Enum
           [PDCSSProperty propertyWithName:@"ascender" value:@(element.ascender).stringValue],
           [PDCSSProperty propertyWithName:@"descender" value:@(element.descender).stringValue],
           ];
}

ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT NSArray<PDCSSProperty *> *PDCSSPropertiesFromASAbsoluteLayoutElement(id<ASAbsoluteLayoutElement> element)
{
  return @[ [PDCSSProperty propertyWithName:@"layoutPosition" value:NSStringFromCGPoint(element.layoutPosition)] ];
}

ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT PDCSSRuleMatch *PDCSSRuleMatchWithNameAndProperties(NSString *name, NSArray<PDCSSProperty *> *properties)
{
  PDCSSStyle *style = [[PDCSSStyle alloc] init];
  style.cssProperties = properties;
  style.shorthandEntries = @[];
  
  PDCSSSelectorList *selectorList = [PDCSSSelectorList selectorListWithSelectors:@[ [PDCSSValue valueWithText:name] ]];
  
  PDCSSRule *rule = [[PDCSSRule alloc] init];
  rule.selectorList = selectorList;
  rule.origin = PDCSSStyleSheetOriginRegular;
  rule.style = style;
  
  PDCSSRuleMatch *match = [[PDCSSRuleMatch alloc] init];
  match.rule = rule;
  match.matchingSelectors = @[ @(0) ];
  
  return match;
}


ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT NSString *NSHexStringFromColor(UIColor *color)
{
  const CGFloat *components = CGColorGetComponents(color.CGColor);
  return [NSString stringWithFormat:@"#%02lX%02lX%02lX%02lX",
          lroundf(components[0] * 255),
          lroundf(components[1] * 255),
          lroundf(components[2] * 255),
          lroundf(components[3] * 255)];
}

@implementation NSObject (PDCSSRuleMatchesProviding)

- (NSMutableArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  return [NSMutableArray array];
}

@end

@implementation ASLayoutElementStyle (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:PDCSSRuleMatchWithNameAndProperties(@"absolute_layout_element", PDCSSPropertiesFromASAbsoluteLayoutElement(self))];
  [result addObject:PDCSSRuleMatchWithNameAndProperties(@"size", PDCSSPropertiesFromASLayoutElementSize(self.size))];
  [result addObject:PDCSSRuleMatchWithNameAndProperties(@"stack_layout_element", PDCSSPropertiesFromASStackLayoutElement(self))];
  return result;
}

@end

#pragma mark PDCSSRuleMatchesProviding - Layout specs

@implementation ASLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObjectsFromArray:[self.style td_generateCSSRuleMatches]];
  return result;
}

@end

@implementation ASStackLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[
                                          [PDCSSProperty propertyWithName:@"direction" value:@(self.direction).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"spacing" value:@(self.spacing).stringValue],
                                          [PDCSSProperty propertyWithName:@"justifyContent" value:@(self.justifyContent).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"alignItems" value:@(self.alignItems).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"flexWrap" value:@(self.flexWrap).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"alignContent" value:@(self.alignContent).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"concurrent" value:@(self.concurrent).stringValue],
                                          ];
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"stack_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

@implementation ASInsetLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[ [PDCSSProperty propertyWithName:@"insets" value:NSStringFromUIEdgeInsets(self.insets)] ];
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"inset_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

@implementation ASCenterLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[
                                          [PDCSSProperty propertyWithName:@"centeringOptions" value:@(self.centeringOptions).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"sizingOptions" value:@(self.sizingOptions).stringValue], // Enum
                                          ];
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"center_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

@implementation ASRatioLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[ [PDCSSProperty propertyWithName:@"ratio" value:@(self.ratio).stringValue] ];
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"ratio_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

@implementation ASRelativeLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[
                                          [PDCSSProperty propertyWithName:@"horizontalPosition" value:@(self.horizontalPosition).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"verticalPosition" value:@(self.verticalPosition).stringValue], // Enum
                                          [PDCSSProperty propertyWithName:@"sizingOption" value:@(self.sizingOption).stringValue], // Enum
                                          ];
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"relative_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

@implementation ASAbsoluteLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *specProps = @[ [PDCSSProperty propertyWithName:@"sizing" value:@(self.sizing).stringValue] ]; // Enum
  PDCSSRuleMatch *specRule = PDCSSRuleMatchWithNameAndProperties(@"absolute_layout_spec", specProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray arrayWithArray:[super td_generateCSSRuleMatches]];
  [result addObject:specRule];
  return result;
}

@end

#pragma mark PDCSSRuleMatchesProviding - Display nodes

@implementation ASDisplayNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[ [PDCSSProperty propertyWithName:@"hitTestSlop" value:NSStringFromUIEdgeInsets(self.hitTestSlop)] ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"display_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObjectsFromArray:[self.style td_generateCSSRuleMatches]];
  [result addObject:nodeRule];
  return result;
}

@end

@implementation ASTextNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[
                                         [PDCSSProperty propertyWithName:@"attributedText" value:self.attributedText.string],
                                         [PDCSSProperty propertyWithName:@"truncationAttributedText" value:self.truncationAttributedText.string],
                                         [PDCSSProperty propertyWithName:@"additionalTruncationMessage" value:self.additionalTruncationMessage.string],
                                         [PDCSSProperty propertyWithName:@"truncationMode" value:@(self.truncationMode).stringValue], // Enum
                                         [PDCSSProperty propertyWithName:@"truncated" value:@(self.truncated).stringValue], // BOOL
                                         [PDCSSProperty propertyWithName:@"maximumNumberOfLines" value:@(self.maximumNumberOfLines).stringValue],
                                         [PDCSSProperty propertyWithName:@"lineCount" value:@(self.lineCount).stringValue],
                                         [PDCSSProperty propertyWithName:@"placeholderEnabled" value:@(self.placeholderEnabled).stringValue], // BOOL
                                         [PDCSSProperty propertyWithName:@"placeholderColor" value:NSHexStringFromColor(self.placeholderColor)],
                                         [PDCSSProperty propertyWithName:@"placeholderInsets" value:NSStringFromUIEdgeInsets(self.placeholderInsets)],
                                         [PDCSSProperty propertyWithName:@"shadowPadding" value:NSStringFromUIEdgeInsets(self.shadowPadding)],
                                         ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"text_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:nodeRule];
  return result;
}

@end

@implementation ASImageNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[ [PDCSSProperty propertyWithName:@"placeholderColor" value:NSHexStringFromColor(self.placeholderColor)] ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"image_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:nodeRule];
  return result;
}

@end

@implementation ASNetworkImageNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[ [PDCSSProperty propertyWithName:@"URL" value:self.URL.absoluteString] ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"network_image_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:nodeRule];
  return result;
}

@end

@implementation ASVideoNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[ [PDCSSProperty propertyWithName:@"assetURL" value:self.assetURL.absoluteString] ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"video_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:nodeRule];
  return result;
}

@end

@implementation ASVideoPlayerNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches
{
  NSArray<PDCSSProperty *> *nodeProps = @[ [PDCSSProperty propertyWithName:@"assetURL" value:self.assetURL.absoluteString] ];
  PDCSSRuleMatch *nodeRule = PDCSSRuleMatchWithNameAndProperties(@"video_player_node", nodeProps);
  
  NSMutableArray<PDCSSRuleMatch *> *result = [super td_generateCSSRuleMatches];
  [result addObject:nodeRule];
  return result;
}

@end

#endif
