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
#import <AFNetworking/UIImageView+AFNetworking.h>
#import <PureLayout/PureLayout.h>
#import <TouristHelperCore/TouristHelperCore.h>
#import "CustomInfoView.h"
#import <TSMessages/TSMessage.h>
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;
@property (strong, nonatomic) GMSMapView *gmsMapView;
@property (assign, nonatomic) BOOL firstLocationUpdate;
@property (strong, nonatomic) PlaceService *placeService;
@property (strong, nonatomic) NSMutableDictionary *supportedTypes;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) CustomInfoView *customView;
@property (strong, nonatomic) NSArray *places;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:13];
    
    self.gmsMapView = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds]  camera:camera];
    self.gmsMapView.delegate = self;
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

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillDisappear:animated];
}

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    
    self.customView =  [[[NSBundle mainBundle] loadNibNamed:@"CustomInfoView"
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
        [self.customView.bannerImage setImageWithURLRequest:request placeholderImage:[UIImage imageNamed:@"placeholder_location"]
                                                    success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                                        place.photo = image;
                                                        // Select the marker again for the view to be refreshed
                                                        [mapView setSelectedMarker:marker];
                                                    }
                                                    failure:NULL];
    }
    
    return self.customView;
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
    
    CLLocationDistance distanceThreshold = 2.0;
    CLLocation *locationUpdate = [change objectForKey:NSKeyValueChangeNewKey];
    
    if (!self.currentLocation || [locationUpdate distanceFromLocation:self.currentLocation] > distanceThreshold){
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

- (void)retrievePlacesOfInterest:(CLLocation *)currentLocation {
    
    [self showLocationFetchNotification];
    
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
                                                   if (places) {
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

-(void)showLocationFetchNotification {
    [TSMessage showNotificationWithTitle:@"Hang on!"
                                subtitle:@"I'm looking for interesting places around you"
                                    type:TSMessageNotificationTypeWarning];
}

-(void)showLocationFetchSuccessNotification:(long)placeCount{
    [TSMessage showNotificationWithTitle:@"Yay!"
                                subtitle:[NSString stringWithFormat:@"I found %ld places" , placeCount]
                                    type:TSMessageNotificationTypeSuccess];
}

-(void)showLocationFetchErrorNotification{
    [TSMessage showNotificationWithTitle:@"Uh-oh!"
                                subtitle:@"We cannot do a search at the moment"
                                    type:TSMessageNotificationTypeError];
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
    [path addCoordinate:self.currentLocation.coordinate];
    
    for (Place *nextPlace in self.places) {
        @autoreleasepool {
            [path addCoordinate:nextPlace.location.coordinate];
        }
    }
    
    GMSPolyline *pathPolyline = [GMSPolyline polylineWithPath:path];
    pathPolyline.map = self.gmsMapView;
}
#pragma mark - SettingsTableViewDelegate

- (void)didUpdateSettings:(NSMutableDictionary *)updatedSettings {
    [self.placeService modifySupportedTypes:updatedSettings];
    // Retrieve places of interest
    [self retrievePlacesOfInterest:self.currentLocation];
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
