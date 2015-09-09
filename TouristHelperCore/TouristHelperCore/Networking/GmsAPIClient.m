//
//  GmsAPIClient.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import "GmsAPIClient.h"

/**
 *  Base URL for GMS
 */
NSString * const GmsAPIClientURLString = @"https://maps.googleapis.com/maps/api/";

@implementation GmsAPIClient

+ (instancetype)sharedClient {
    static GmsAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[GmsAPIClient alloc] initWithBaseURL:[NSURL URLWithString:GmsAPIClientURLString]];
    });
    
    return _sharedClient;
}

@end
