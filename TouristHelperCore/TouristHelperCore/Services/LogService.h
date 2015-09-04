//
//  LogService.h
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Service that provides logging
 */
@interface LogService : NSObject

/**
 *  Provides a shared instance of logging service
 *
 *  @return LogService
 */
+ (instancetype)sharedInstance;

/**
 *  Sets up logging
 */
- (void)setup;

/**
 *  Log level Info
 *
 *  @param format Log message
 */
- (void)logInfoWithFormat:(NSString *)format, ...;

/**
 *  Log level Debug
 *
 *  @param format Log message
 */
- (void)logDebugWithFormat:(NSString *)format, ...;

/**
 *  Log level Error
 *
 *  @param format Log message
 */
- (void)logErrorWithFormat:(NSString *)format, ...;

@end
