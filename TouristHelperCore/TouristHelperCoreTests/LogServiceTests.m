//
//  LogServiceTest.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "LogService.h"

@interface LogServiceTests : XCTestCase

@end

@implementation LogServiceTests

- (void)setUp {
    [super setUp];
    [[LogService sharedInstance] setup];
}

- (void)testLogInfo {
    [[LogService sharedInstance] logInfoWithFormat:@"Info %@ %@ www", @"First Arg", @"Second Arg"];
    XCTAssert(YES, @"Pass");
}

- (void)testLogDebug {
    [[LogService sharedInstance] logDebugWithFormat:@"Debug %@ %@ www", @"First Arg", @"Second Arg"];
    XCTAssert(YES, @"Pass");
}

- (void)testLogError {
    [[LogService sharedInstance] logErrorWithFormat:@"Error %@ %@ www", @"First Arg", @"Second Arg"];
    XCTAssert(YES, @"Pass");
}

@end
