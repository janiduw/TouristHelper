//
//  Place.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import "Place.h"

@implementation Place

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.placeId = (NSUInteger) [[attributes valueForKeyPath:@"id"] integerValue];
    self.iconUrl = [attributes valueForKeyPath:@"icon"];
    
    self.location = CLLocationCoordinate2DMake([[attributes valueForKeyPath:@"geometry.location.lat"] doubleValue],
                                               [[attributes valueForKeyPath:@"geometry.location.lng"] doubleValue]);
    return self;
}

@end
