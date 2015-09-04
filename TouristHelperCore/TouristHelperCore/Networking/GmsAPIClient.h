//
//  GmsAPIClient.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

/**
 *  Google Mapping Service API Client
 */
@interface GmsAPIClient : AFHTTPSessionManager

/**
 *  Provides a shared instance of GmsAPIClient
 *
 *  @return GmsAPIClient
 */
+ (instancetype)sharedClient;


@end
