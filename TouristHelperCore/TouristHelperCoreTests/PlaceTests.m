//
//  PlaceTests.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/5/15.
//  Copyright (c) 2015 IttyBIttyApps. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Place.h"

@interface PlaceTests : XCTestCase

@end

@interface PlaceTests ()
@property (nonatomic, strong) Place *place;
@end

@implementation PlaceTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.place = [[Place alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCanBeCreated {
    XCTAssertNotNil(self.place);
}

- (void)testInitWithAttributes {
    
    NSString *placeName = @"testPlace";
    NSString *placeId = @"12345";
    NSString *icon = @"http://a.png";
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:@[placeName, placeId, icon]
                                                           forKeys:@[@"name", @"place_id", @"icon"]];
    Place *place = [[Place alloc] initWithAttributes:dictionary];
    
    XCTAssertTrue([placeName isEqualToString:place.name]);
    XCTAssertTrue([icon isEqualToString:place.iconUrl]);
    XCTAssertTrue([placeId isEqualToString:place.placeId]);

}

@end
