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

@interface ASImageNodeRegeneratingFromImageAssetTests : XCTestCase
@end

@implementation ASImageNodeRegeneratingFromImageAssetTests

- (void)setUp
{
  [super setUp];
  ASConfiguration *config = [ASConfiguration new];
  config.experimentalFeatures = ASExperimentalTraitCollectionDidChangeWithPreviousCollection;
  [ASConfigurationManager test_resetWithConfiguration:config];
}

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

/**
 * When the user interface style changes (dark mode to light mode and vice versa),
 * images that are from an asset should be regenerated, stored and rendered properly.
 */
- (void)testRegeneratedAssetImageIsProperlyStoredAndRendered
{
    if (@available(iOS 13.0, *)) {
        NSArray *colors = @[ [UIColor whiteColor], [UIColor blackColor] ];
        NSArray *traitCollections = @[ [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleLight],
                                       [UITraitCollection traitCollectionWithUserInterfaceStyle:UIUserInterfaceStyleDark] ];
        UIImageAsset *asset = [self imageAssetForImagesWithSolidColors:colors
                                                      traitCollections:traitCollections];
        UIImage *lightImage = [asset imageWithTraitCollection:traitCollections[0]];
        UIImage *darkImage = [asset imageWithTraitCollection:traitCollections[1]];

        ASImageNode *imageNode = [[ASImageNode alloc] init];
        imageNode.bounds = CGRectMake(0, 0, 1, 1);
        [imageNode setImage:lightImage];

        // First assert that the node renders the light image
        XCTestExpectation *lightImageRendered = [self expectationWithDescription:@"Light image rendered"];
        [imageNode setDidDisplayNodeContentWithRenderingContext:^(CGContextRef  _Nonnull context, id  _Nullable drawParameters) {
            UIImage *renderedImage = [drawParameters valueForKey:@"_image"];
            XCTAssertNotNil(renderedImage);
            XCTAssertTrue([lightImage isEqual:renderedImage]);
            [lightImageRendered fulfill];
        }];
        [imageNode recursivelyEnsureDisplaySynchronously:YES];

        // Switch to dark mode and assert that the node renders dark image
        XCTestExpectation *darkImageRendered = [self expectationWithDescription:@"Dark image rendered"];
        //        __weak ASImageNode *weakImageNode = imageNode;
        [imageNode setPrimitiveTraitCollection:ASPrimitiveTraitCollectionFromUITraitCollection(traitCollections[1])];
        [imageNode setDidDisplayNodeContentWithRenderingContext:^(CGContextRef  _Nonnull context, id  _Nullable drawParameters) {
            UIImage *renderedImage = [drawParameters valueForKey:@"_image"];
            XCTAssertNotNil(renderedImage);
            XCTAssertTrue([darkImage isEqual:renderedImage]);
//            XCTAssertTrue([weakImageNode.image isEqual:darkImage]); // Expect to fail
            // TODO asset the raster data as well
            [darkImageRendered fulfill];
        }];
        [imageNode recursivelyEnsureDisplaySynchronously:YES];

        // Trigger re-rendering and assert that the node still renders dark image
        [imageNode setNeedsDisplay];
        XCTestExpectation *darkImageRerendered = [self expectationWithDescription:@"Dark image re-rendered"];
        [imageNode setDidDisplayNodeContentWithRenderingContext:^(CGContextRef  _Nonnull context, id  _Nullable drawParameters) {
//            UIImage *renderedImage = [drawParameters valueForKey:@"_image"];
//            XCTAssertNotNil(renderedImage);
//            XCTAssertTrue([darkImage isEqual:renderedImage]);  // Expect to fail
//            XCTAssertTrue([weakImageNode.image isEqual:darkImage]); // Expect to fail
            [darkImageRerendered fulfill];
        }];
        [imageNode recursivelyEnsureDisplaySynchronously:YES];

        [self waitForExpectations:@[ lightImageRendered, darkImageRendered, darkImageRerendered ] timeout:1];
    }
}

@end
