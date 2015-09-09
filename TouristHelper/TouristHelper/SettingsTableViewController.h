//
//  SettingsTableViewController.h
//  TouristHelper
//
//  Created by Janidu Wanigasuriya on 9/6/15.
//  Copyright (c) 2015 IttyBIttyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsTableViewDelegate <NSObject>
@required
- (void)didUpdateSettings:(NSMutableDictionary *)updatedSettings;
@end

@interface SettingsTableViewController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary *supportedSettings;
@property (weak, nonatomic)id <SettingsTableViewDelegate> delegate;

@end
