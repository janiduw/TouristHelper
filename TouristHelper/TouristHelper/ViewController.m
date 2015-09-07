//
//  ViewController.m
//  TouristHelper
//
//  Created by Janidu Wanigasuriya on 9/3/15.
//  Copyright (c) 2015 Janiduw. All rights reserved.
//

@import GoogleMaps;

#import "ViewController.h"

#import "Constants.h"
#import "UIImageView+AFNetworking.h"
#import <PureLayout/PureLayout.h>
#import <TouristHelperCore/TouristHelperCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) GMSMapView *gmsMapView;
@property (assign, nonatomic) BOOL firstLocationUpdate;
@property (strong, nonatomic) PlaceService *placeService;
@property (strong, nonatomic) NSMutableDictionary *supportedTypes;
@property (strong, nonatomic) CLLocation *currentLocation;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    
    self.gmsMapView = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds]  camera:camera];
    self.gmsMapView.settings.myLocationButton = YES;
    
    self.gmsMapView.myLocationEnabled = YES;
    [self.mapView addSubview:self.gmsMapView];
    
    // Size to fit the screen with zero insets
    [self.gmsMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.gmsMapView addObserver:self
                      forKeyPath:@"myLocation"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    self.placeService = [[PlaceService alloc] init];
    self.placeService.apiKey = GMS_API_KEY;
    
    self.supportedTypes = [[[PlaceService sharedInstance] getSupportedTypes] mutableCopy];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    SettingsTableViewController *settingsViewController = (SettingsTableViewController *) segue.destinationViewController;
    settingsViewController.supportedSettings = self.supportedTypes;
    settingsViewController.delegate = self;
}

#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    self.currentLocation = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (!self.firstLocationUpdate) {
        
        self.firstLocationUpdate = YES;
        
        // If the first location update has not yet been recieved, then jump to that location.
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:self.currentLocation.coordinate
                                                                     zoom:12];
        [self.gmsMapView animateToCameraPosition:position];
        
        // Retrieve places of interest
        [self retrievePlacesOfInterest:self.currentLocation.coordinate];
    }
}

- (void)retrievePlacesOfInterest:(CLLocationCoordinate2D)coordinate {
    NSString *supportedTypes = [[self.supportedTypes allKeys] componentsJoinedByString:@"|"];
    
    [self.placeService getNearbyPlacesWithCoordinate:coordinate
                                              radius:1000
                                      supportedTypes:supportedTypes
                                               block:^(NSArray *places, NSError *error) {
                                                   
                                                   [self.gmsMapView clear];
                                                   
                                                   @autoreleasepool {
                                                       for (Place *place in places) {
                                                           GMSMarker *marker = [GMSMarker markerWithPosition:place.location];
                                                           marker.title = place.name;
                                                           marker.map = self.gmsMapView;
                                                       }
                                                   }
                                               }];
}

#pragma mark - SettingsTableViewDelegate

- (void)didUpdateSettings:(NSMutableDictionary *)updatedSettings {
    [self.placeService modifySupportedTypes:updatedSettings];
    // Retrieve places of interest
    [self retrievePlacesOfInterest:self.currentLocation.coordinate];
}

- (void)dealloc {
    [self.gmsMapView removeObserver:self
                         forKeyPath:@"myLocation"
                            context:NULL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
