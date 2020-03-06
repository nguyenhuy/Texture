// TODO: Update snapshot  tests here as well? https://github.com/TextureGroup/Texture/commit/1961a5a94838b86935cbf60a14de0f9a4a4f0dae#diff-a00c5214a77e580ae672284b693c37f7R193
// TODO: Compare image address instead of isEqual: because we want the least number of objects retained

//
//  ASImageNodeRegeneratingFromImageAssetTests.m
//  Texture
//
//  Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <AsyncDisplayKit/ASWeakMap.h>

@interface ASImageNode (ASImageNodeRegeneratingFromImageAssetTests)
- (UIImage *)sourceImage; // Input for the node's latest render operation
- (UIImage *)resultImage; // Result of the node's latest render operation
@end

@implementation ASImageNode (ASImageNodeRegeneratingFromImageAssetTests)

- (ASWeakMapEntry *)contentsCacheEntry
{
  return [self valueForKey:@"_weakCacheEntry"];
}

- (UIImage *)sourceImage
{
  return [self.contentsCacheEntry.key valueForKey:@"image"];
}

- (UIImage *)resultImage
{
  return self.contentsCacheEntry.value;
}

@end

@interface ASImageNodeRegeneratingFromImageAssetTests : XCTestCase

@property (nonatomic, strong) ASImageNode *imageNode;
@property (nonatomic, strong) UITraitCollection *lightMode API_AVAILABLE(ios(13));
@property (nonatomic, strong) UITraitCollection *darkMode API_AVAILABLE(ios(13));

@end

@implementation ASImageNodeRegeneratingFromImageAssetTests

- (void)setUp
{
  [super setUp];
  ASConfiguration *config = [ASConfiguration new];
  config.experimentalFeatures = ASExperimentalTraitCollectionDidChangeWithPreviousCollection;
  [ASConfigurationManager test_resetWithConfiguration:config];

  self.imageNode = [[ASImageNode alloc] init];
  self.imageNode.bounds = CGRectMake(0, 0, 10, 10);

  if (AS_AVAILABLE_IOS(13)) {
    self.lightMode = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight];
    self.darkMode = [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark];
  }
}

#pragma mark - Helper methods

- (UIImageAsset *)imageAssetForImagesWithSolidColors:(NSArray<UIColor *> *)colors
                                    traitCollections:(NSArray<UITraitCollection *> *)traitCollections
{
  XCTAssertEqual(colors.count, traitCollections.count);

  UIImageAsset *result = [[UIImageAsset alloc] init];

  for (NSUInteger i = 0; i < colors.count; i++) {
    UIColor *color = colors[i];
    UITraitCollection *traitCollection = traitCollections[i];
    UIImage *image = [UIImage as_resizableRoundedImageWithCornerRadius:0.0 cornerColor:nil fillColor:color];
    [result registerImage:image withTraitCollection:traitCollection];
  }

  return result;
}

- (void)triggerFirstRenderingWithImage:(UIImage *)sourceImage
                   withTraitCollection:(UITraitCollection *)traitCollection
{
  [self.imageNode setPrimitiveTraitCollection:ASPrimitiveTraitCollectionFromUITraitCollection(traitCollection)];
  [self.imageNode setImage:sourceImage];
  [self.imageNode recursivelyEnsureDisplaySynchronously:YES];
  XCTAssertNotNil(self.imageNode.sourceImage);
  XCTAssertTrue([self.imageNode.sourceImage isEqual:sourceImage]);
  XCTAssertNotNil(self.imageNode.resultImage);
}

- (void)testRegenerateThroughTraitCollectionChanges:(NSArray<UITraitCollection *> *)traitCollections
                                     withImageAsset:(UIImageAsset *)asset
{
  for (UITraitCollection *traitCollection in traitCollections) {
    UIImage *lastResultImage = self.imageNode.resultImage;
    UIImage *currentSourceImage = [asset imageWithTraitCollection:traitCollection];

    [self.imageNode setPrimitiveTraitCollection:ASPrimitiveTraitCollectionFromUITraitCollection(traitCollection)];
    [self.imageNode recursivelyEnsureDisplaySynchronously:YES];

    XCTAssertNotNil(self.imageNode.sourceImage);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:currentSourceImage]);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:self.imageNode.image]);

    XCTAssertNotNil(self.imageNode.resultImage);
    XCTAssertFalse([self.imageNode.resultImage isEqual:lastResultImage]);
    lastResultImage = self.imageNode.resultImage;

    [self.imageNode setNeedsDisplay];
    [self.imageNode recursivelyEnsureDisplaySynchronously:YES];

    XCTAssertNotNil(self.imageNode.sourceImage);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:currentSourceImage]);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:self.imageNode.image]);

    XCTAssertTrue([self.imageNode.resultImage isEqual:lastResultImage]);
  }
}

- (void)testAvoidRegeneratingThroughTraitCollectionChanges:(NSArray<UITraitCollection *> *)traitCollections
{
  UIImage *sourceImage = self.imageNode.sourceImage;
  UIImage *resultImage = self.imageNode.resultImage;

  for (UITraitCollection *traitCollection in traitCollections) {
    [self.imageNode setPrimitiveTraitCollection:ASPrimitiveTraitCollectionFromUITraitCollection(traitCollection)];
    [self.imageNode recursivelyEnsureDisplaySynchronously:YES];

    XCTAssertNotNil(self.imageNode.sourceImage);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:sourceImage]);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:self.imageNode.image]);

    XCTAssertNotNil(self.imageNode.resultImage);
    XCTAssertTrue([self.imageNode.resultImage isEqual:resultImage]);

    [self.imageNode setNeedsDisplay];
    [self.imageNode recursivelyEnsureDisplaySynchronously:YES];

    XCTAssertNotNil(self.imageNode.sourceImage);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:sourceImage]);
    XCTAssertTrue([self.imageNode.sourceImage isEqual:self.imageNode.image]);

    XCTAssertTrue([self.imageNode.resultImage isEqual:resultImage]);
  }
}

#pragma mark - Tests

/**
 * When the user interface style changes (light mode to dark mode and vice versa)
 * and each mode has its own image in the asset, ASImageNode needs to regenerate
 * its source image and re-render.
 */
- (void)testRegenerateIfEachModeHasItsOwnImageInAsset
{
  if (AS_AVAILABLE_IOS(13)) {
    UIImageAsset *asset = [self imageAssetForImagesWithSolidColors:@[ [UIColor whiteColor], [UIColor blackColor] ]
                                                  traitCollections:@[ self.lightMode, self.darkMode ]];

    [self triggerFirstRenderingWithImage:[asset imageWithTraitCollection:self.lightMode]
                     withTraitCollection:self.lightMode];

    [self testRegenerateThroughTraitCollectionChanges:@[ self.darkMode, self.lightMode ]
                                       withImageAsset:asset];
  }
}

/**
 * When the user interface style changes (light mode to dark mode and vice versa)
 * and all modes share the same CGImage but their UIImages are slightly different,
 * ASImageNode needs to regenerate its source image and re-render.
 */
- (void)testRegenerateEvenIfAllModesShareTheSameCGImageInAsset
{
  if (AS_AVAILABLE_IOS(13)) {
    UIImageAsset *asset = [self imageAssetForImagesWithSolidColors:@[ [UIColor whiteColor] ]
                                                  traitCollections:@[ self.lightMode ]];
    UIImage *sourceImageForLightMode = [asset imageWithTraitCollection:self.lightMode];
    UIImage *sourceImageForDarkMode = [sourceImageForLightMode imageWithTintColor:[UIColor blackColor]];
    [asset registerImage:sourceImageForDarkMode withTraitCollection:self.darkMode];

    XCTAssertTrue(CFEqual(sourceImageForLightMode.CGImage, sourceImageForDarkMode.CGImage));

    [self triggerFirstRenderingWithImage:sourceImageForLightMode withTraitCollection:self.lightMode];

    [self testRegenerateThroughTraitCollectionChanges:@[ self.darkMode, self.lightMode ]
                                       withImageAsset:asset];
  }
}

/**
 * When the user interface style changes (light mode to dark mode and vice versa)
 * and the image asset has 1 image for 1 particular mode, ASImageNode needs to
 * avoid regenerating and re-rendering, but keeps the rendered image throughout instead.
 */
- (void)testAvoidRegeneratingIfOnlyOneModeHasItsOwnImageInAsset
{
  if (AS_AVAILABLE_IOS(13)) {
    UIImageAsset *asset = [self imageAssetForImagesWithSolidColors:@[ [UIColor whiteColor] ]
                                                  traitCollections:@[ self.lightMode ]];
    UIImage *sourceImage = [asset imageWithTraitCollection:self.lightMode];

    [self triggerFirstRenderingWithImage:sourceImage withTraitCollection:self.lightMode];

    [self testAvoidRegeneratingThroughTraitCollectionChanges:@[ self.darkMode, self.lightMode ]];
  }
}

/**
 * When the user interface style changes (light mode to dark mode and vice versa)
 * and its image's trait collection is undefinied except display scale (common for images downloaded by PINRemoteImage),
 * ASImageNode needs to avoid regenerating and re-rendering, but keeps the rendered image throughout instead.
 */
- (void)testAvoidRegeneratingIfImageHasUndefiniedTraitCollectionExceptDisplayScale
{
  if (AS_AVAILABLE_IOS(13)) {
    UIImage *sourceImage = [UIImage as_resizableRoundedImageWithCornerRadius:0.0
                                                                 cornerColor:nil
                                                                   fillColor:[UIColor whiteColor]];
    XCTAssertNotNil(sourceImage.imageAsset);
    XCTAssertNotNil(sourceImage.traitCollection);
    CGFloat displayScale = sourceImage.traitCollection.displayScale;
    XCTAssertGreaterThanOrEqual(displayScale, 1.0);
    // The image's trait collection has nothing but a display scale
    XCTAssertTrue([sourceImage.traitCollection isEqual:[UITraitCollection traitCollectionWithDisplayScale:displayScale]]);


    [self triggerFirstRenderingWithImage:sourceImage withTraitCollection:self.lightMode];

    [self testAvoidRegeneratingThroughTraitCollectionChanges:@[ self.darkMode, self.lightMode ]];
  }
}

@end
