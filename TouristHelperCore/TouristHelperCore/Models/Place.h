//
//  Place.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIImage;
@class CLLocation;

/**
 *  A model object represeting a place of interest
 */
@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *photoRef;
@property (nonatomic, strong) UIImage *photo;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, strong) NSString *aboutUrl;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) BOOL visited;
/**
 *  Initalizes a place with given attributes
 *
 *  @param attributes
 *
 *  @return Returns a place objects
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end