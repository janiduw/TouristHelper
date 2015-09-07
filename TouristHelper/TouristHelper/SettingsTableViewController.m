//
//  SettingsTableViewController.m
//  TouristHelper
//
//  Created by Janidu Wanigasuriya on 9/6/15.
//  Copyright (c) 2015 IttyBIttyApps. All rights reserved.
//

#import "SettingsTableViewController.h"

@interface SettingsTableViewController ()

@property (strong, nonatomic) NSArray *supportedTypes;

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Keys should be the display value
    self.supportedTypes = [self.supportedSettings allKeys];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.supportedTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *settingType = [self.supportedTypes objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TypeCell" forIndexPath:indexPath];
    cell.textLabel.text = settingType;
    
    [self toggleCheckMarkWithCell:cell activated:[[self.supportedSettings
                                                   objectForKey:settingType] boolValue]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *settingType = [self.supportedTypes objectAtIndex:indexPath.row];
    
    BOOL activated = ![[self.supportedSettings objectForKey:settingType] boolValue];
    
    // Toggle the checkmark based on the state
    [self toggleCheckMarkWithCell:[tableView cellForRowAtIndexPath:indexPath] activated:activated];
    
    // Update the data structure with the selection made
    [self.supportedSettings setObject:[NSNumber numberWithBool:activated] forKey:settingType];
    
    // Notify to save the settings
    [self.delegate didUpdateSettings:self.supportedSettings];
}

/**
 *  Changes the checkmark depending on the state
 *
 *  @param cell
 *  @param activated
 */
- (void)toggleCheckMarkWithCell:(UITableViewCell *)cell activated:(BOOL)activated {
    if(activated){
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    }else {
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
}

@end
