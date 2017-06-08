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
#import <AsyncDisplayKit/NSObject+TextureDebugger.h>

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
    id<ASLayoutElement> element = (id<ASLayoutElement>)object;
    matchedRules = [element.style td_generateCSSRuleMatches];
  }
  
  callback(matchedRules, nil, nil, nil);
}

#pragma mark Private methods

- (nullable TDDOMContext *)context
{
  return [_dataSource contextForElementPropsDomainController:self];
}

@end

#endif // AS_TEXTURE_DEBUGGER
