//
//  TDElementPropsDomainController.m
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

#import "TDElementPropsDomainController.h"

#import <UIKit/UIKit.h>

#import <PonyDebugger/PDCSSTypes.h>

#import <AsyncDisplayKit/AsyncDisplayKit.h>

#import <AsyncDisplayKit/TDDOMContext.h>

@implementation TDElementPropsDomainController

@dynamic domain;

+ (TDElementPropsDomainController *)defaultInstance;
{
  static TDElementPropsDomainController *defaultInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    defaultInstance = [[TDElementPropsDomainController alloc] init];
  });
  return defaultInstance;
}

+ (Class)domainClass;
{
  return [PDCSSDomain class];
}

#pragma mark - PDCSSCommandDelegate

- (void)domain:(PDDynamicDebuggerDomain *)domain enableWithCallback:(void (^)(id))callback
{
  NSLog(@"CSS Domain enable");
  callback(nil);
}

- (void)domain:(PDDynamicDebuggerDomain *)domain disableWithCallback:(void (^)(id))callback
{
  NSLog(@"CSS Domain disable");
  callback(nil);
}

- (void)domain:(PDCSSDomain *)domain getMatchedStylesForNodeWithNodeId:(NSNumber *)nodeId includePseudo:(NSNumber *)includePseudo includeInherited:(NSNumber *)includeInherited callback:(void (^)(NSArray<PDCSSRuleMatch *> *, NSArray *, NSArray *, id))callback
{
  NSObject *object = [[self context].idToObjectMap objectForKey:nodeId];
  NSLog(@"matched styles for element with id: %@ - %@", nodeId, [object description]);
  
  NSArray<PDCSSRuleMatch *> *matchedRules;
  if (object && [object conformsToProtocol:@protocol(ASLayoutElement)]) {
    NSString *ruleName = @"style";
//    NSString *styleSheetId = [NSString stringWithFormat:@"%@.%@", nodeId.stringValue, ruleName];
    
    NSMutableArray<PDCSSProperty *> *cssProperties = [NSMutableArray array];
    PDCSSProperty *prop = [[PDCSSProperty alloc] init];
    prop.name = @"flex";
    prop.value = @"1.0";
    [cssProperties addObject:prop];
    
    PDCSSStyle *style = [[PDCSSStyle alloc] init];
//    style.styleSheetId = styleSheetId; // Set if editable
    style.cssProperties = cssProperties;
    style.shorthandEntries = @[];
    
    PDCSSSelector *selector = [[PDCSSSelector alloc] init];
    selector.value = ruleName;
    
    PDCSSSelectorList *selectorList = [[PDCSSSelectorList alloc] init];
    selectorList.selectors = @[selector];
    
    PDCSSRule *rule = [[PDCSSRule alloc] init];
//    rule.styleSheetId = styleSheetId;
    rule.selectorList = selectorList;
    rule.origin = PDCSSStyleSheetOriginRegular;
    rule.style = style;
    
    PDCSSRuleMatch *match = [[PDCSSRuleMatch alloc] init];
    match.rule = rule;
    match.matchingSelectors = @[@(0)];
    
    matchedRules = @[match];
  }
  
  callback(matchedRules, @[], @[], nil);
}

#pragma mark Private methods

- (nullable TDDOMContext *)context
{
  return [_dataSource contextForElementPropsDomainController:self];
}

@end

#endif // AS_TEXTURE_DEBUGGER
