//
//  NSObject+PDCSSRuleMatchesProviding.h
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

@class TDDOMContext, PDCSSRuleMatch, PDCSSProperty;

@interface NSObject (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatchesWithContext:(TDDOMContext *)context;

- (void)td_applyCSSProperty:(PDCSSProperty *)property withRuleMatchName:(NSString *)ruleMatchName;

@end

NS_ASSUME_NONNULL_END

#endif
