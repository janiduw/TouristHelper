//
//  GmsService.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import "PlaceService.h"
#import "GmsAPIClient.h"
#import "Place.h"
#import "LogService.h"

@implementation PlaceService

NSString *NEARBY_SEARCH = @"place/nearbysearch/json?location=%f,%f&radius=%d&key=%@";

+ (instancetype)sharedInstance {
    static PlaceService *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PlaceService alloc] init];
    });
    
    return _sharedInstance;
}

- (NSURLSessionDataTask *)getNearbyPlacesWithCoordinate:(CLLocationCoordinate2D)coordinate
                                                 radius:(NSUInteger)radius
                                                  block:(void (^)(NSArray *places, NSError *error))block{
    
    // Format the GET request to include required parameters
    NSString *getRequest = [NSString stringWithFormat:NEARBY_SEARCH,
                            coordinate.latitude, coordinate.longitude, radius, self.apiKey];
    
    return [[GmsAPIClient sharedClient] GET:getRequest parameters:nil
                                    success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                        
                                        
                                        NSArray *placesFromResponse = [JSON valueForKeyPath:@"results"];
                                        [[LogService sharedInstance] logInfoWithFormat:@"Retrieved Places with count %d", placesFromResponse.count];
                                        
                                        // Parse JSON results to Place objects
                                        NSMutableArray *mutablePlaces = [NSMutableArray
                                                                         arrayWithCapacity:[placesFromResponse count]];
                                        
                                        @autoreleasepool {
                                            for (NSDictionary *attributes in placesFromResponse) {
                                                Place *place = [[Place alloc] initWithAttributes:attributes];
                                                [mutablePlaces addObject:place];
                                            }
                                        }
                                        
                                        if (block) {
                                            // Invoke Async callback
                                            block([NSArray arrayWithArray:mutablePlaces], nil);
                                        }
                                        
                                    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        if (block) {
                                            block([NSArray array], nil);
                                        }
                                    }];
}

@end
