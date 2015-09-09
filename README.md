# TouristHelper
An application helping out tourists with nearby locations.

![](readme_resources/Screencast_iOS.gif?raw=true)

1. Clone the repository

TouristHelper - The application project
TouristHelperCore - Framework project with reusable components

2. Pod install on TouristHelper

3. Open TouristHelper.xcworkspace to get started

4. Run tests by opening TouristHelperCore.xcworkspace

### Traceability matrix

| Story         | Status        |
| ------------- |:-------------:|
| As a user, I would like to see a map, so that I could browse through locations | Done
| As a user, I would like to see my current location, so that I see my current location on the map | Done
| As a user, I would like to see interesting places in a map, so that I could find an interesting place to visit | Done
| As a user, I would like to find more information about an interesting place, so that I could call visit the place | Done
| As a user, I would like to get a crow path route of my map, so that I could find the best route to take | Done

### High-level architecture

![](readme_resources/highlevel_architecture.png?raw=true)

#### 3rd party libraries/frameworks

| Name         | Reason        |
| ------------- |:-------------:|
| CocoaPods | Dependency management
| GoogleMaps | Map rendering
| AFNetworking | Feature rich API for Networking
| CocoaLumberjack | Managed Logging
| PureLayout | Elegant API for Auto layouts
| TSMessages | UI notifications that are less intrusive

#### Google Maps iOS SDK vs Google Maps Web services

Google Maps iOS SDK only exposes limited set of APIs to do a location search. Therefore I used made requests to the Google Maps Web services.
Google Maps iOS SDK was mainly used for Map rendering.

#### TouristHelperCore

These are the advantages of extracting core services onto a separate framework.

* Improves testability
* Makes core functionality reusable between future applications