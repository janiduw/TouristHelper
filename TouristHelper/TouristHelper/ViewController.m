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
#import "CustomInfoView.h"
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <PureLayout/PureLayout.h>
#import <TouristHelperCore/TouristHelperCore.h>
#import <TSMessages/TSMessage.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) GMSMapView *gmsMapView;
@property (strong, nonatomic) PlaceService *placeService;
@property (strong, nonatomic) NSMutableDictionary *supportedTypes;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CustomInfoView *customView;
@property (strong, nonatomic) NSArray *places;
@property (assign, nonatomic) BOOL firstLocationUpdate;
@end

@implementation ViewController

#pragma mark - ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Default location is set to Sydney
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:13];
    
    self.gmsMapView = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds]  camera:camera];
    self.gmsMapView.delegate = self;
    self.gmsMapView.settings.myLocationButton = YES;
    
    self.gmsMapView.myLocationEnabled = YES;
    [self.mapView addSubview:self.gmsMapView];
    
    [[LogService sharedInstance] logInfoWithFormat:@"Added Map view"];
    
    // Size to fit the screen with zero insets
    [self.gmsMapView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
    
    [self.gmsMapView addObserver:self
                      forKeyPath:@"myLocation"
                         options:NSKeyValueObservingOptionNew
                         context:NULL];
    
    self.placeService = [PlaceService sharedInstance];
    self.supportedTypes = [[self.placeService getSupportedTypes] mutableCopy];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    // Retrieve places of interest if coming back from another screen
    if (self.currentLocation) {
        [self retrievePlacesOfInterest:self.currentLocation];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [[LogService sharedInstance] logInfoWithFormat:@"Displaying settings table view"];
    SettingsTableViewController *settingsViewController = (SettingsTableViewController *) segue.destinationViewController;
    settingsViewController.supportedSettings = self.supportedTypes;
    settingsViewController.delegate = self;
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

#pragma mark - SettingsTableViewDelegate

- (void)didUpdateSettings:(NSMutableDictionary *)updatedSettings {
    [self.placeService modifySupportedTypes:updatedSettings];
}


#pragma mark - KVO updates

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CLLocationDistance distanceThreshold = 100.0;
    CLLocation *locationUpdate = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (!self.currentLocation || [locationUpdate distanceFromLocation:
                                  self.currentLocation] > distanceThreshold){
        self.currentLocation = [change objectForKey:NSKeyValueChangeNewKey];
        self.firstLocationUpdate = NO;
    }
    
    if (!self.firstLocationUpdate) {
        
        self.firstLocationUpdate = YES;
        
        // If the first location update has not yet been recieved, then jump to that location.
        GMSCameraPosition *position = [GMSCameraPosition cameraWithTarget:self.currentLocation.coordinate
                                                                     zoom:13];
        [self.gmsMapView animateToCameraPosition:position];
        
        // Retrieve places of interest
        [self retrievePlacesOfInterest:self.currentLocation];
    }
}

#pragma mark - Place retrieval

- (void)retrievePlacesOfInterest:(CLLocation *)currentLocation {
    
    [[LogService sharedInstance] logInfoWithFormat:@"Retrieve places of interest"];
    
    [self showLocationFetchNotification];
    
    // Fetch only enabled supported types
    NSMutableArray *supportedTypes = [NSMutableArray new];
    @autoreleasepool {
        for (NSString *typeKey in [self.supportedTypes allKeys]) {
            if ([[self.supportedTypes valueForKey:typeKey] boolValue]) {
                [supportedTypes addObject:typeKey];
            }
        }
    }
    
    [self.placeService getNearbyPlacesWithCoordinate:currentLocation
                                              radius:1000
                                      supportedTypes:[supportedTypes componentsJoinedByString:@"|"]
                                               block:^(NSArray *places, NSError *error) {
                                                   if (places && places.count != 0) {
                                                       self.places = places;
                                                       [self.gmsMapView clear];
                                                       [self addMarkers:self.places];
                                                       [self drawPath:self.places];
                                                       [self showLocationFetchSuccessNotification:self.places.count];
                                                   }else {
                                                       [self showLocationFetchErrorNotification];
                                                   }
                                               }];
}

#pragma mark - Notifications

-(void)showLocationFetchNotification {
    [TSMessage showNotificationWithTitle:@"Hang on!"
                                subtitle:@"I'm looking for interesting places around you"
                                    type:TSMessageNotificationTypeWarning];
}

-(void)showLocationFetchSuccessNotification:(long)placeCount {
    [TSMessage showNotificationWithTitle:@"Yay!"
                                subtitle:[NSString stringWithFormat:@"I found %ld places" , placeCount]
                                    type:TSMessageNotificationTypeSuccess];
}

-(void)showLocationFetchErrorNotification {
    [TSMessage showNotificationWithTitle:@"Uh-oh!"
                                subtitle:@"I cannot find any places at the moment"
                                    type:TSMessageNotificationTypeError];
}

#pragma mark - Google Map overlays

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    [[LogService sharedInstance] logInfoWithFormat:@"Displaying markerInfoWindow"];
    
    // Initialize a custom view to display POI information
    self.customView = [[[NSBundle mainBundle] loadNibNamed:@"CustomInfoView"
                                                     owner:self
                                                   options:nil] objectAtIndex:0];
    self.customView.layer.cornerRadius = 10;
    self.customView.layer.masksToBounds = YES;
    
    Place *place = (Place *) marker.userData;
    if (place.address) {
        // If details are present set it to the view
        self.customView.address.text = place.address;
        self.customView.name.text = place.name;
        self.customView.phoneNumber.text = place.phoneNumber;
        self.customView.activityIndicator.hidden = YES;
    }else {
        // If not retreve place details
        [self.placeService retrievePlaceDetails:place block:^(Place *place, NSError *error) {
            // Select the marker again for the view to be refreshed
            [mapView setSelectedMarker:marker];
        }];
    }
    
    if(place.photo){
        // If a photo is present display it
        self.customView.bannerImage.image = place.photo;
    }else {
        
        // Retreive the image
        NSURL *url = [NSURL URLWithString:[self.placeService retrievePlaceImageUrlWithPlace:place]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [self.customView.bannerImage setImageWithURLRequest:request
                                           placeholderImage:[UIImage imageNamed:@"placeholder_location"]
                                                    success:^(NSURLRequest *request,
                                                              NSHTTPURLResponse *response, UIImage *image) {
                                                        place.photo = image;
                                                        // Select the marker again for the view to be refreshed
                                                        [mapView setSelectedMarker:marker];
                                                    }
                                                    failure:NULL];
    }
    
    return self.customView;
}

- (void)addMarkers:(NSArray *)places {
    for (Place *place in places) {
        @autoreleasepool {
            GMSMarker *marker = [GMSMarker markerWithPosition:
                                 place.location.coordinate];
            marker.infoWindowAnchor = CGPointMake(0.44f, 0.45f);
            marker.title = place.name;
            marker.map = self.gmsMapView;
            marker.userData = place;
        }
    }
}

- (void)drawPath:(NSArray *)places {
    
    GMSMutablePath *path = [GMSMutablePath path];
    // Path shoudl start at the current location
    [path addCoordinate:self.currentLocation.coordinate];
    
    for (Place *nextPlace in self.places) {
        @autoreleasepool {
            [path addCoordinate:nextPlace.location.coordinate];
        }
    }
    
    // Path should end at the current location
    [path addCoordinate:self.currentLocation.coordinate];
    
    // Add path to the map
    GMSPolyline *pathPolyline = [GMSPolyline polylineWithPath:path];
    pathPolyline.map = self.gmsMapView;
}

@end
