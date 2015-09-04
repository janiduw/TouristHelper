//
//  Place.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  A model object represeting a place of interest
 */
@interface Place : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSUInteger placeId;
@property (nonatomic, strong) NSString *iconUrl;

/**
 *  Initalizes a place with given attributes
 *
 *  @param attributes
 *
 *  @return Returns a place objects
 */
- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end