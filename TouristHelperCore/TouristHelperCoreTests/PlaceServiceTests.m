//
//  GmsServiceTests.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PlaceService.h"
#import "TestConstants.h"
#import "Place.h"

@interface PlaceServiceTests : XCTestCase

@end

@interface PlaceServiceTests ()
@property(nonatomic, strong)PlaceService *placeService;
@end

@implementation PlaceServiceTests

- (void)setUp {
    [super setUp];
    self.placeService = [PlaceService sharedInstance];
    self.placeService.apiKey = GMS_TEST_API_KEY;
}

- (void)testInstantiation {
    XCTAssertNotNil([PlaceService sharedInstance]);
}

- (void)testSingleton {
    XCTAssertEqual([PlaceService sharedInstance], [PlaceService sharedInstance]);
}

- (void)testGetNearbyPOIsWithCoordinate {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(-33.8670, 151.1957);
    
    NSString *supportedTypes = [[[self.placeService getSupportedTypes] allKeys] componentsJoinedByString:@"|"];
    
    hxRunInMainLoop(^(BOOL *done) {
        [self.placeService getNearbyPlacesWithCoordinate:coordinate
                                                  radius:500
                                          supportedTypes:supportedTypes
                                                   block:^(NSArray *places, NSError *error) {
                                                       XCTAssertTrue(places.count != 0);
                                                       *done = YES;
                                                   }];
    });
}

- (void)testGetPlaceId {
    
    Place *place = [[Place alloc] init];
    place.placeId = @"ChIJN1t_tDeuEmsRUsoyG83frY4";
    
    hxRunInMainLoop(^(BOOL *done) {
        [self.placeService retrievePlaceDetails:place block:^(Place *place, NSError *error) {
            XCTAssertNotNil(place.phoneNumber);
            XCTAssertNotNil(place.address);
            XCTAssertNotNil(place.aboutUrl);
            *done = YES;
        }];
    });
}

- (void)testRetrievePlaceImageUrlWithPlace {
    Place *place = [[Place alloc] init];
    place.photoRef = @"CmRdAAAAc22vE5aLuIhLUonMiraUViQLa3mDR_ZwrjcLhmjsg-XmR0ti-kEEe67AFxXUQEaZLw30ECAHJOa5dgKARXsbKtlnYXkK_AanvbD-hZVC0gQpLPX-w3230FO7XHeFI6WcEhCFPfYCP9iEwaS4641KysYpGhQFz4-dNwo3COELw0ZDBJ2ue8XHEw";
    NSString *photoUrl = [self.placeService retrievePlaceImageUrlWithPlace:place];
    XCTAssertNotNil(photoUrl);
}

- (void)testGetSupportedTypes {
    NSDictionary *types = [self.placeService getSupportedTypes];
    XCTAssertNotNil(types);
    XCTAssertEqual([types allKeys].count, 7);
}

- (void)testAddSupportedTypes {
    NSMutableDictionary *types = [[self.placeService getSupportedTypes] mutableCopy];
    [types setObject:@YES forKey:@"Cafes"];
    [self.placeService modifySupportedTypes:types];
    
    NSMutableDictionary *modifiedTypes = [[self.placeService getSupportedTypes] mutableCopy];
    XCTAssertEqual([modifiedTypes allKeys].count, 8);
    [modifiedTypes removeObjectForKey:@"Cafes"];
    [self.placeService modifySupportedTypes:modifiedTypes];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

static inline void hxRunInMainLoop(void(^block)(BOOL *done)) {
    __block BOOL done = NO;
    block(&done);
    while (!done) {
        [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow:.1]];
    }
}


@end
