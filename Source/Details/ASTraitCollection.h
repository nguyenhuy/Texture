//
//  ASTraitCollection.h
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


#import <UIKit/UIKit.h>
#import <AsyncDisplayKit/ASBaseDefines.h>

@class ASTraitCollection;
@protocol ASLayoutElement;

NS_ASSUME_NONNULL_BEGIN

ASDISPLAYNODE_EXTERN_C_BEGIN

#pragma mark - ASPrimitiveTraitCollection

typedef struct ASPrimitiveTraitCollection {
  CGFloat displayScale;
  UIUserInterfaceSizeClass horizontalSizeClass;
  UIUserInterfaceIdiom userInterfaceIdiom;
  UIUserInterfaceSizeClass verticalSizeClass;
  UIForceTouchCapability forceTouchCapability;

  CGSize containerSize;
} ASPrimitiveTraitCollection;

/**
 * Creates ASPrimitiveTraitCollection with default values.
 */
extern ASPrimitiveTraitCollection ASPrimitiveTraitCollectionMakeDefault(void);

/**
 * Creates a ASPrimitiveTraitCollection from a given UITraitCollection.
 */
extern ASPrimitiveTraitCollection ASPrimitiveTraitCollectionFromUITraitCollection(UITraitCollection *traitCollection);


/**
 * Compares two ASPrimitiveTraitCollection to determine if they are the same.
 */
extern BOOL ASPrimitiveTraitCollectionIsEqualToASPrimitiveTraitCollection(ASPrimitiveTraitCollection lhs, ASPrimitiveTraitCollection rhs);

/**
 * Returns a string representation of a ASPrimitiveTraitCollection.
 */
extern NSString *NSStringFromASPrimitiveTraitCollection(ASPrimitiveTraitCollection traits);

/**
 * This function will walk the layout element hierarchy and updates the layout element trait collection for every
 * layout element within the hierarchy.
 */
extern void ASTraitCollectionPropagateDown(id<ASLayoutElement> element, ASPrimitiveTraitCollection traitCollection);

ASDISPLAYNODE_EXTERN_C_END

#pragma mark - ASTraitCollection

AS_SUBCLASSING_RESTRICTED
@interface ASTraitCollection : NSObject

@property (nonatomic, assign, readonly) CGFloat displayScale;
@property (nonatomic, assign, readonly) UIUserInterfaceSizeClass horizontalSizeClass;
@property (nonatomic, assign, readonly) UIUserInterfaceIdiom userInterfaceIdiom;
@property (nonatomic, assign, readonly) UIUserInterfaceSizeClass verticalSizeClass;
@property (nonatomic, assign, readonly) UIForceTouchCapability forceTouchCapability;
@property (nonatomic, assign, readonly) CGSize containerSize;

+ (ASTraitCollection *)traitCollectionWithASPrimitiveTraitCollection:(ASPrimitiveTraitCollection)traits;

+ (ASTraitCollection *)traitCollectionWithUITraitCollection:(UITraitCollection *)traitCollection
                                              containerSize:(CGSize)windowSize;


+ (ASTraitCollection *)traitCollectionWithDisplayScale:(CGFloat)displayScale
                                    userInterfaceIdiom:(UIUserInterfaceIdiom)userInterfaceIdiom
                                   horizontalSizeClass:(UIUserInterfaceSizeClass)horizontalSizeClass
                                     verticalSizeClass:(UIUserInterfaceSizeClass)verticalSizeClass
                                  forceTouchCapability:(UIForceTouchCapability)forceTouchCapability
                                         containerSize:(CGSize)windowSize;


- (ASPrimitiveTraitCollection)primitiveTraitCollection;
- (BOOL)isEqualToTraitCollection:(ASTraitCollection *)traitCollection;

@end

NS_ASSUME_NONNULL_END
