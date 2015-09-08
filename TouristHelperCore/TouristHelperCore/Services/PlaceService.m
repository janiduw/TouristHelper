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
#import <math.h>

@implementation PlaceService

static NSString * const NEARBY_SEARCH = @"place/nearbysearch/json";
static NSString * const PLACE_DETAIL = @"place/details/json";
static NSString * const PLACE_PHOTO = @"place/photo?maxwidth=%@&photoreference=%@&key=%@";
static NSString * const GMSINFO_PLIST_NAME = @"GmsInfo";

+ (instancetype)sharedInstance {
    static PlaceService *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[PlaceService alloc] init];
    });
    
    return _sharedInstance;
}

- (NSURLSessionDataTask *)getNearbyPlacesWithCoordinate:(CLLocation *)location
                                                 radius:(NSUInteger)radius
                                         supportedTypes:(NSString *)supportedTypes
                                                  block:(void (^)(NSArray *places, NSError *error))block{
    
    // Prepare GET parameters
    NSDictionary *params = @{@"location" : [NSString
                                            stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude],
                             @"radius"   : [NSNumber numberWithLong:radius],
                             @"types"    : supportedTypes,
                             @"key"      : self.apiKey};
    
    return [[GmsAPIClient sharedClient] GET:NEARBY_SEARCH parameters:params
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
                                            NSArray *sortedArray = [self sortPlacesByDistance:mutablePlaces
                                                                              currentLocation:location];
                                            block(sortedArray, nil);
                                        }
                                        
                                    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        if (block) {
                                            block([NSArray array], error);
                                        }
                                    }];
}

- (NSArray *)sortPlacesByDistance:(NSArray *)places
                  currentLocation:(CLLocation *)currentLocation {
    // Sort places according to the distance
    NSArray *sortedArray;
    sortedArray = [places sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        CLLocation *first = [(Place*)a location];
        CLLocation *second = [(Place*)b location];
        return [currentLocation distanceFromLocation:first] > [currentLocation
                                                               distanceFromLocation:second];
    }];
    return sortedArray;
}

- (Place *)getNextNearbyPlace:(NSArray *)places
             currentLocation:(CLLocation *)currentLocation {
    
    Place *closestLocation;
    CLLocationDistance smallestDistance = CGFLOAT_MAX;
    
    for (Place *place in places) {
        @autoreleasepool {
            if (place.visited) {
                continue;
            }
            
            CLLocationDistance distance = [currentLocation distanceFromLocation:place.location];
            if (distance < smallestDistance) {
                distance = smallestDistance;
                closestLocation = place;
            }
        }
    }
    
    return closestLocation;
}

- (NSURLSessionDataTask *)retrievePlaceDetails:(Place *)place
                                         block:(void (^)(Place *place, NSError *error))block{
    
    NSDictionary *params = @{@"placeid" : place.placeId,
                             @"key"     : self.apiKey};
    
    return [[GmsAPIClient sharedClient] GET:PLACE_DETAIL parameters:params
                                    success:^(NSURLSessionDataTask * __unused task, id JSON) {
                                        
                                        NSArray *placesFromResponse = [JSON valueForKeyPath:@"result"];
                                        [[LogService sharedInstance] logInfoWithFormat:@"Retrieved details"];
                                        
                                        place.address = [placesFromResponse valueForKeyPath:@"formatted_address"];
                                        place.aboutUrl = [placesFromResponse valueForKeyPath:@"url"];
                                        place.phoneNumber = [placesFromResponse valueForKeyPath:@"international_phone_number"];
                                        
                                        if (block) {
                                            block(place, nil);
                                        }
                                        
                                    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        if (block) {
                                            block(nil, error);
                                        }
                                    }];;
}

- (NSDictionary *)getSupportedTypes {
    return [[self readGmsInfoPlist] objectForKey:@"Types"];
}

-(BOOL)modifySupportedTypes:(NSMutableDictionary *)types {
    // Retreive the original plist dictionary and modify that
    NSMutableDictionary *plist = [[self readGmsInfoPlist] mutableCopy];
    [plist setObject:types forKey:@"Types"];
    // Write back to disk
    return [plist writeToFile:[self gmsInfoPlistDocPath] atomically:YES];
}

- (NSString *)retrievePlaceImageUrlWithPlace:(Place *)place {
    return [GmsAPIClientURLString stringByAppendingString:[NSString
                                                           stringWithFormat:PLACE_PHOTO, @"200", place.photoRef, self.apiKey]];
}

/**
 *  Copies the GmsInfoPlist to the documents directory and reads its content
 *
 *  @return Contents of the plist
 */
-(NSDictionary *)readGmsInfoPlist {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSString *docPath = [self gmsInfoPlistDocPath];
    
    // Copy the plist to the documents directory if does not exist
    if (![fileManager fileExistsAtPath:docPath]) {
        [fileManager copyItemAtPath:[self gmsInfoPlistBundlePath] toPath:docPath error:&error];
    }
    
    return [NSDictionary dictionaryWithContentsOfFile:docPath];
}

/**
 *  GmsInfoPlist Bundle Path
 *
 *  @return Path of the GmsInfoPlist
 */
-(NSString *)gmsInfoPlistBundlePath {
    // Plist exist at the bundle of the framework
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    return [bundle pathForResource:GMSINFO_PLIST_NAME ofType:@"plist"];
}

/**
 *  GmsInfoPlist Bundle Path
 *
 *  @return Path of the GmsInfoPlist
 */
-(NSString *)gmsInfoPlistDocPath {
    // Plist exist at the bundle of the framework
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Path where the plist should exist on the documents directory
    return [[paths objectAtIndex:0] stringByAppendingPathComponent:[GMSINFO_PLIST_NAME
                                                                    stringByAppendingString:@".plist"]];
}

@end
