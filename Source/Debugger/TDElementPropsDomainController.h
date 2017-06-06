//
//  TDElementPropsDomainController.h
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

#import <PonyDebugger/PDCSSDomain.h>
#import <PonyDebugger/PDDomainController.h>

@class TDElementPropsDomainController, TDDOMContext;

NS_ASSUME_NONNULL_BEGIN

@protocol TDElementPropsDomainControllerDataSource <NSObject>

- (TDDOMContext *)contextForElementPropsDomainController:(TDElementPropsDomainController *)controller;

@end

@interface TDElementPropsDomainController : PDDomainController <PDCSSCommandDelegate>

@property (nonatomic, strong) PDCSSDomain *domain;
@property (nonatomic, weak) id<TDElementPropsDomainControllerDataSource> dataSource;

+ (TDElementPropsDomainController *)defaultInstance;

@end

NS_ASSUME_NONNULL_END

#endif
