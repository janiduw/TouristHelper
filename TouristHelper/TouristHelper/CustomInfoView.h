//
//  CustomInfoView.h
//  TouristHelper
//
//  Created by Janidu Wanigasuriya on 9/7/15.
//  Copyright (c) 2015 IttyBIttyApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomInfoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *bannerImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *address;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumber;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
