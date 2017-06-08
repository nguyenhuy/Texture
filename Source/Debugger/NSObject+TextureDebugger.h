//
//  NSObject+TextureDebugger.h
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

#import <Foundation/Foundation.h>
#import <AsyncDisplayKit/ASBaseDefines.h>
#import <AsyncDisplayKit/ASDimensionInternal.h>

NS_ASSUME_NONNULL_BEGIN

@class PDCSSRuleMatch, PDDOMNode, TDDOMContext;

@interface NSObject (PDDOMNodeProviding)

- (PDDOMNode *)td_generateDOMNodeWithContext:(TDDOMContext *)context;
- (CGRect)td_frameInWindow;
- (NSArray *)td_children;

@end

@interface ASLayoutElementStyle (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatches;

@end

NS_ASSUME_NONNULL_END

#endif
