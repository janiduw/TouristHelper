//
//  GmsService.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class Place;

/**
 *  Purpose of this service is to retrieve places of interest
 */
@interface PlaceService : NSObject

@property(nonatomic, strong)NSString *apiKey;

/**
 *  Returns an instance of PlaceService
 *
 *  @return PlacesService
 */
+ (instancetype)sharedInstance;

/**
 *  Retrieves Places of interests sorted by the closest location
 *
 *  @param coordinate coordinate of the current location
 *  @param radius     radius required
 *  @param types      types required (Should be piped)
 *  @param block      async block with places
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)getNearbyPlacesWithCoordinate:(CLLocation *)location
                                                 radius:(NSUInteger)radius
                                         supportedTypes:(NSString *)supportedTypes
                                                  block:(void (^)(NSArray *places, NSError *error))block;

/**
 *  Retreives detail information about the place using the place_id
 *
 *  @param place Place with a valid place_id
 *  @param block Callback Block
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)retrievePlaceDetails:(Place *)place
                                         block:(void (^)(Place *place, NSError *error))block;

/**
 *  Retrieves a place image URL
 *
 *  @param place Description of the place
 *
 *  @return Place with the place image Url
 */
- (NSString *)retrievePlaceImageUrlWithPlace:(Place *)place;

/**
 *  Sorts places according to the distance
 *
 *  @param places
 *  @param currentLocation
 *
 *  @return
 */
- (NSArray *)sortPlacesByDistance:(NSArray *)places
                  currentLocation:(CLLocation *)currentLocation;

/**
 *  Retrieves supported search types
 *
 *  @return NSMutableDictionary of supported types
 */
- (NSDictionary *)getSupportedTypes;

/**
 *  Modifies supported types
 *
 *  @param types
 *
 *  @return BOOL true if succesful with the update
 */
- (BOOL)modifySupportedTypes:(NSMutableDictionary *)types;

@end
