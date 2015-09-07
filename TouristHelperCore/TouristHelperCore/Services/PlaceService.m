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

NSString *NEARBY_SEARCH = @"place/nearbysearch/json";
NSString *PLACE_DETAIL = @"place/details/json";
NSString *PLACE_PHOTO = @"place/photo?maxwidth=%@&photoreference=%@&key=%@";
NSString *GMSINFO_PLIST_NAME = @"GmsInfo";

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
                                         supportedTypes:(NSString *)supportedTypes
                                                  block:(void (^)(NSArray *places, NSError *error))block{
    
    NSDictionary *params = @{@"location" : [NSString
                                            stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude],
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
                                            block([NSArray arrayWithArray:mutablePlaces], nil);
                                        }
                                        
                                    } failure:^(NSURLSessionDataTask *__unused task, NSError *error) {
                                        if (block) {
                                            block([NSArray array], error);
                                        }
                                    }];
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
    
    NSMutableDictionary *plist = [[self readGmsInfoPlist] mutableCopy];
    [plist setObject:types forKey:@"Types"];
    
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
