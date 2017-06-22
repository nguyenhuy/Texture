//
//  NSObject+PDCSSRuleMatchesProviding.m
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

#import <AsyncDisplayKit/NSObject+PDCSSRuleMatchesProviding.h>

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASCollectionElement.h>
#import <AsyncDisplayKit/ASLayoutElementStylePrivate.h>
#import <AsyncDisplaykit/ASRectTable.h>
#import <AsyncDisplayKit/TDDOMContext.h>

#import <PonyDebugger/PDCSSTypes.h>
#import <PonyDebugger/NSObject+KVSC.h>

#define kTDRuleMatchNameProps @"props"
#define kTDRuleMatchNameStyle @"style"
#define kTDRuleMatchNameMeasurement @"measurement"

#pragma mark - Helpers and Commons

ASDISPLAYNODE_INLINE AS_WARN_UNUSED_RESULT PDCSSRuleMatch * PDCSSRuleMatchForNodeWithId(NSNumber *nodeId, NSString *ruleName, NSArray<PDCSSProperty *> *properties, BOOL editable)
{
  PDCSSStyle *style = [[PDCSSStyle alloc] init];
  if (editable) {
    style.styleSheetId = [NSString stringWithFormat:@"%@.%@", nodeId.stringValue, ruleName];
  }
  style.cssProperties = properties;
  style.shorthandEntries = @[];
  
  PDCSSSelectorList *selectorList = [PDCSSSelectorList selectorListWithSelectors:@[ [PDCSSValue valueWithText:ruleName] ]];
  
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

@interface NSObject (PDCSSPropertiesProviding)

- (NSArray<NSString *> *)td_ruleMatchNames;

- (BOOL)td_isRuleMatchWithNameEditable:(NSString *)ruleMatchName;

- (NSArray<PDCSSProperty *> *)td_CSSProperties;

@end

@implementation NSObject (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  return @[];
}

- (NSArray<NSString *> *)td_ruleMatchNames
{
  return @[ kTDRuleMatchNameProps ];
}

- (BOOL)td_isRuleMatchWithNameEditable:(NSString *)ruleMatchName
{
  return YES;
}

- (NSArray<PDCSSRuleMatch *> *)td_generateCSSRuleMatchesWithContext:(TDDOMContext *)context
{
  NSNumber *objectId = [context idForObject:self];
  if (objectId == nil) {
    return @[];
  }
  
  NSMutableArray<PDCSSRuleMatch *> *result = [NSMutableArray array];
  for (NSString *ruleMatchName in [self td_ruleMatchNames]) {
    PDCSSRuleMatch *ruleMatch = [self td_generateCSSRuleMatchWithName:ruleMatchName objectId:objectId];
    if (ruleMatch != nil) {
      [result addObject:ruleMatch];
    }
  }
  return result;
}

- (PDCSSRuleMatch *)td_generateCSSRuleMatchWithName:(NSString *)ruleMatchName objectId:(NSNumber *)objectId
{
  if ([kTDRuleMatchNameProps isEqualToString:ruleMatchName]) {
    return PDCSSRuleMatchForNodeWithId(objectId,
                                       ruleMatchName,
                                       [self td_CSSProperties],
                                       [self td_isRuleMatchWithNameEditable:ruleMatchName]);
  }
  
  return nil;
}


- (void)td_applyCSSProperty:(PDCSSProperty *)property withRuleMatchName:(NSString *)ruleMatchName
{
  [self PD_setValueString:property.value forKeyPath:property.name];
}

@end

@implementation ASLayoutElementStyle (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  return @[
           [PDCSSProperty propertyWithName:@"width" value:NSStringFromASDimension(self.width)],
           [PDCSSProperty propertyWithName:@"height" value:NSStringFromASDimension(self.height)],
           [PDCSSProperty propertyWithName:@"minWidth" value:NSStringFromASDimension(self.minWidth)],
           [PDCSSProperty propertyWithName:@"maxWidth" value:NSStringFromASDimension(self.maxWidth)],
           [PDCSSProperty propertyWithName:@"minHeight" value:NSStringFromASDimension(self.minHeight)],
           [PDCSSProperty propertyWithName:@"maxHeight" value:NSStringFromASDimension(self.maxHeight)],
           [PDCSSProperty propertyWithName:@"layoutPosition" value:NSStringFromCGPoint(self.layoutPosition)],
           [PDCSSProperty propertyWithName:@"spacingBefore" value:@(self.spacingBefore).stringValue],
           [PDCSSProperty propertyWithName:@"spacingAfter" value:@(self.spacingAfter).stringValue],
           [PDCSSProperty propertyWithName:@"flexGrow" value:@(self.flexGrow).stringValue],
           [PDCSSProperty propertyWithName:@"flexShrink" value:@(self.flexShrink).stringValue],
           [PDCSSProperty propertyWithName:@"flexBasis" value:NSStringFromASDimension(self.flexBasis)],
           [PDCSSProperty propertyWithName:@"alignSelf" value:@(self.alignSelf).stringValue], // Enum
           [PDCSSProperty propertyWithName:@"ascender" value:@(self.ascender).stringValue],
           [PDCSSProperty propertyWithName:@"descender" value:@(self.descender).stringValue],
           ];
}

@end

#pragma mark - Layout specs

@implementation ASLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<NSString *> *)td_ruleMatchNames
{
  return @[ kTDRuleMatchNameProps, kTDRuleMatchNameStyle ];
}

- (BOOL)td_isRuleMatchWithNameEditable:(NSString *)ruleMatchName
{
  return NO;
}

- (PDCSSRuleMatch *)td_generateCSSRuleMatchWithName:(NSString *)ruleMatchName objectId:(NSNumber *)objectId
{
  if ([kTDRuleMatchNameStyle isEqualToString:ruleMatchName]) {
    return PDCSSRuleMatchForNodeWithId(objectId,
                                       ruleMatchName,
                                       [self.style td_CSSProperties],
                                       [self td_isRuleMatchWithNameEditable:ruleMatchName]);
  }
  
  return [super td_generateCSSRuleMatchWithName:ruleMatchName objectId:objectId];
}

- (void)td_applyCSSProperty:(PDCSSProperty *)property withRuleMatchName:(NSString *)ruleMatchName
{
  if ([kTDRuleMatchNameStyle isEqualToString:ruleMatchName]) {
    property.name = [NSString stringWithFormat:@"%@.%@", @"style", property.name];
  }
  [super td_applyCSSProperty:property withRuleMatchName:ruleMatchName];
}

@end

@implementation ASStackLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"direction" value:@(self.direction).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"spacing" value:@(self.spacing).stringValue]];
  [result addObject:[PDCSSProperty propertyWithName:@"justifyContent" value:@(self.justifyContent).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"alignItems" value:@(self.alignItems).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"flexWrap" value:@(self.flexWrap).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"alignContent" value:@(self.alignContent).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"concurrent" value:@(self.concurrent).stringValue]];
  return result;
}

@end

@implementation ASInsetLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"insets" value:NSStringFromUIEdgeInsets(self.insets)]];
  return result;
}

@end

@implementation ASCenterLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"centeringOptions" value:@(self.centeringOptions).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"sizingOptions" value:@(self.sizingOptions).stringValue]]; // Enum
  return result;
}

@end

@implementation ASRatioLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"ratio" value:@(self.ratio).stringValue]];
  return result;
}

@end

@implementation ASRelativeLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"horizontalPosition" value:@(self.horizontalPosition).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"verticalPosition" value:@(self.verticalPosition).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"sizingOption" value:@(self.sizingOption).stringValue]]; // Enum
  return result;
}

@end

@implementation ASAbsoluteLayoutSpec (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"sizing" value:@(self.sizing).stringValue]]; // Enum
  return result;
}

@end

#pragma mark - Display nodes

@implementation ASDisplayNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"hitTestSlop" value:NSStringFromUIEdgeInsets(self.hitTestSlop)]];
  return result;
}

- (NSArray<NSString *> *)td_ruleMatchNames
{
  return @[ kTDRuleMatchNameProps, kTDRuleMatchNameStyle, kTDRuleMatchNameMeasurement ];
}

- (BOOL)td_isRuleMatchWithNameEditable:(NSString *)ruleMatchName
{
  // Measurement rule match is not editable, others are.
  return ([kTDRuleMatchNameMeasurement isEqualToString:ruleMatchName] == NO);
}

- (PDCSSRuleMatch *)td_generateCSSRuleMatchWithName:(NSString *)ruleMatchName objectId:(NSNumber *)objectId
{
  if ([kTDRuleMatchNameStyle isEqualToString:ruleMatchName]) {
    return PDCSSRuleMatchForNodeWithId(objectId,
                                       ruleMatchName,
                                       [self.style td_CSSProperties],
                                       [self td_isRuleMatchWithNameEditable:ruleMatchName]);
  }
  
  if ([kTDRuleMatchNameMeasurement isEqualToString:ruleMatchName]) {
    NSArray<PDCSSProperty *> *cssProps = @[
                                           [PDCSSProperty propertyWithName:@"sizeRange"
                                                                     value:NSStringFromASSizeRange(self.constrainedSizeForCalculatedLayout)],
                                           [PDCSSProperty propertyWithName:@"calculatedSize"
                                                                     value:NSStringFromCGSize(self.calculatedSize)]
                                           ];
    
    return PDCSSRuleMatchForNodeWithId(objectId,
                                       ruleMatchName,
                                       cssProps,
                                       [self td_isRuleMatchWithNameEditable:ruleMatchName]);
  }
  
  return [super td_generateCSSRuleMatchWithName:ruleMatchName objectId:objectId];
}

- (void)td_applyCSSProperty:(PDCSSProperty *)property withRuleMatchName:(NSString *)ruleMatchName
{
  if ([kTDRuleMatchNameStyle isEqualToString:ruleMatchName]) {
    property.name = [NSString stringWithFormat:@"%@.%@", @"style", property.name];
    [super td_applyCSSProperty:property withRuleMatchName:ruleMatchName];
    [self setNeedsLayout];
    [self.supernode setNeedsLayout];
    [self.supernode layoutIfNeeded];
  } else {
    [super td_applyCSSProperty:property withRuleMatchName:ruleMatchName];
  }
}

@end

@implementation ASTextNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"attributedText" value:self.attributedText.string]];
  [result addObject:[PDCSSProperty propertyWithName:@"truncationAttributedText" value:self.truncationAttributedText.string]];
  [result addObject:[PDCSSProperty propertyWithName:@"additionalTruncationMessage" value:self.additionalTruncationMessage.string]];
  [result addObject:[PDCSSProperty propertyWithName:@"truncationMode" value:@(self.truncationMode).stringValue]]; // Enum
  [result addObject:[PDCSSProperty propertyWithName:@"truncated" value:@(self.truncated).stringValue]]; // BOOL
  [result addObject:[PDCSSProperty propertyWithName:@"maximumNumberOfLines" value:@(self.maximumNumberOfLines).stringValue]];
  [result addObject:[PDCSSProperty propertyWithName:@"lineCount" value:@(self.lineCount).stringValue]];
  [result addObject:[PDCSSProperty propertyWithName:@"placeholderEnabled" value:@(self.placeholderEnabled).stringValue]]; // BOOL
  [result addObject:[PDCSSProperty propertyWithName:@"placeholderColor" value:NSHexStringFromColor(self.placeholderColor)]];
  [result addObject:[PDCSSProperty propertyWithName:@"placeholderInsets" value:NSStringFromUIEdgeInsets(self.placeholderInsets)]];
  [result addObject:[PDCSSProperty propertyWithName:@"shadowPadding" value:NSStringFromUIEdgeInsets(self.shadowPadding)]];
  
  return result;
}

@end

@implementation ASImageNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"placeholderColor" value:NSHexStringFromColor(self.placeholderColor)]];
  return result;
}

@end

@implementation ASNetworkImageNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"URL" value:self.URL.absoluteString]];
  return result;
}

@end

@implementation ASVideoNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"assetURL" value:self.assetURL.absoluteString]];
  return result;
}

@end

@implementation ASVideoPlayerNode (PDCSSRuleMatchesProviding)

- (NSArray<PDCSSProperty *> *)td_CSSProperties
{
  NSMutableArray<PDCSSProperty *> *result = [NSMutableArray arrayWithArray:[super td_CSSProperties]];
  [result addObject:[PDCSSProperty propertyWithName:@"assetURL" value:self.assetURL.absoluteString]];
  return result;
}

@end

#endif
