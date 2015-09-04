//
//  LogService.m
//  TouristHelperCore
//
//  Created by Janidu Wanigasuriya on 9/4/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

#import "LogService.h"
#import <CocoaLumberjack/CocoaLumberjack.h>

@implementation LogService

#ifdef DEBUG
static const NSUInteger ddLogLevel = DDLogLevelAll;
#else
static const NSUInteger ddLogLevel = DDLogLevelOff;
#endif

+ (instancetype)sharedInstance {
    
    static LogService *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LogService alloc] init];
    });
    
    return _sharedInstance;
}

- (void)setup {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}

- (void)logInfoWithFormat:(NSString *)format, ... {
    va_list argList;
    va_start(argList, format);
    NSString *infoLog = [[NSString alloc] initWithFormat: format arguments: argList];
    DDLogInfo(infoLog, nil);
    va_end(argList);
}

- (void)logDebugWithFormat:(NSString *)format, ... {
    va_list argList;
    va_start(argList, format);
    NSString *infoLog = [[NSString alloc] initWithFormat: format arguments: argList];
    DDLogDebug(infoLog, nil);
    va_end(argList);
}

- (void)logErrorWithFormat:(NSString *)format, ... {
    va_list argList;
    va_start(argList, format);
    NSString *infoLog = [[NSString alloc] initWithFormat: format arguments: argList];
    DDLogError(infoLog, nil);
    va_end(argList);
}

@end
