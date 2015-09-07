//
//  GmsService.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

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
 *  Retrieves Places of interests
 *
 *  @param coordinate coordinate of the location
 *  @param radius     radius required
 *  @param types      types required (Should be piped)
 *  @param block      async block with places
 *
 *  @return NSURLSessionDataTask
 */
- (NSURLSessionDataTask *)getNearbyPlacesWithCoordinate:(CLLocationCoordinate2D)coordinate
                                                 radius:(NSUInteger)radius
                                         supportedTypes:(NSString *)supportedTypes
                                                  block:(void (^)(NSArray *places, NSError *error))block;
/**
 *  Retrieves supported search types
 *
 *  @return NSMutableDictionary of supported types
 */
- (NSDictionary *)getSupportedTypes;

- (BOOL)modifySupportedTypes:(NSMutableDictionary *)types;

@end
