//
//  Place.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import "Place.h"
#import <CoreLocation/CoreLocation.h>

@implementation Place

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.name = [attributes valueForKeyPath:@"name"];
    self.placeId = [attributes valueForKeyPath:@"place_id"];
    self.iconUrl = [attributes valueForKeyPath:@"icon"];
    
    NSArray *photos = [attributes valueForKeyPath:@"photos"];
    self.photoRef = [[photos objectAtIndex:0] valueForKeyPath:@"photo_reference"];
    self.location = [[CLLocation alloc] initWithLatitude:[[attributes valueForKeyPath:@"geometry.location.lat"] doubleValue]
                                               longitude:[[attributes valueForKeyPath:@"geometry.location.lng"] doubleValue]];
    return self;
}

@end
