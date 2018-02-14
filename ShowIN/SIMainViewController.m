//
//  SIMainViewController.m
//  ShowIN
//
//  Created by Weiling Xi on 12/26/17.
//  Copyright © 2017 Weiling Xi. All rights reserved.
//

#import "SIMainViewController.h"

@interface SIMainViewController () <CLLocationManagerDelegate, GMSMapViewDelegate, UISearchBarDelegate>

@property (nonatomic, strong) CLLocationManager *locmanager;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) UIButton *navigationButton;
@property (nonatomic, strong) UIButton *clearButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UITextView *navDetails;

@property (atomic, strong) CLLocation *currlocation;
@property (atomic, strong) CLLocation *destinationLoc;
@property (nonatomic, strong) NSString *destinationString;

@property (nonatomic, strong) GMSPolyline *polyline;

@end

@implementation SIMainViewController {
    NSURLSession *_session;
}

- (void)loadView {
    SIMainView *mainView = [[SIMainView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.view = mainView;
    self.mapView = mainView.mapView;
    self.navigationButton = mainView.navigationButton;
    [self.navigationButton addTarget:self action:@selector(_startNavigation:) forControlEvents:UIControlEventTouchUpInside];
    
    self.clearButton = mainView.clearButton;
    [self.clearButton addTarget:self action:@selector(_clear:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navDetails = mainView.navDetails;
    self.searchBar = mainView.searchBar;
    self.searchBar.delegate = self;
    
    self.mapView.delegate = self;
    self.mapView.settings.indoorPicker = YES;
    self.mapView.settings.myLocationButton = YES;
    self.mapView.settings.scrollGestures = YES;
    self.mapView.settings.zoomGestures = YES;
    self.mapView.settings.compassButton = YES;
    self.mapView.myLocationEnabled = YES;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    //self.navigationButton.enabled = NO;
    //self.clearButton.enabled = NO;
    
    // Setup location services
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Please enable location services");
        return;
    }
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    self.locmanager = [[CLLocationManager alloc] init];
    if ([self.locmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locmanager requestWhenInUseAuthorization];
    }
    self.locmanager.delegate = self;
    self.locmanager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locmanager.distanceFilter = 5.0f;
    [self.locmanager startUpdatingLocation];
    
    [self _setupURLSession];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"Please authorize location services");
        return;
    }
    
    NSLog(@"CLLocationManager error: %@", error.localizedFailureReason);
    return;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    self.currlocation = location;
    
//    if (self.locationMarker == nil) {
//        self.locationMarker = [[GMSMarker alloc] init];
//        self.locationMarker.position = location.coordinate;
//
//        // Animated walker images derived from an www.angryanimator.com tutorial.
//        // See: http://www.angryanimator.com/word/2010/11/26/tutorial-2-walk-cycle/
//
//        NSArray *frames = @[[UIImage imageNamed:@"step1"],
//                            [UIImage imageNamed:@"step2"],
//                            [UIImage imageNamed:@"step3"],
//                            [UIImage imageNamed:@"step4"],
//                            [UIImage imageNamed:@"step5"],
//                            [UIImage imageNamed:@"step6"],
//                            [UIImage imageNamed:@"step7"],
//                            [UIImage imageNamed:@"step8"]];
//
//        self.locationMarker.icon = [UIImage animatedImageWithImages:frames duration:1];
//        self.locationMarker.groundAnchor = CGPointMake(0.5f, 0.97f);
//        self.locationMarker.map = self.mapView;
//    } else {
//        [CATransaction begin];
//        [CATransaction setAnimationDuration:0.04f];
//        self.locationMarker.position = location.coordinate;
//        [CATransaction commit];
//    }
    
    GMSCameraUpdate *move = [GMSCameraUpdate setTarget:location.coordinate zoom:17];
    [self.mapView animateWithCameraUpdate:move];
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    [self.searchBar resignFirstResponder];
    self.destinationLoc = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    NSLog(@"map tapped. lati: %f, long:%f", coordinate.latitude, coordinate.longitude);
    self.navDetails.text = [NSString stringWithFormat:@"Destination location is lati: %f, long:%f", coordinate.latitude, coordinate.longitude];
}

- (void)mapView:(GMSMapView *)mapView didTapPOIWithPlaceID:(NSString *)placeID
           name:(NSString *)name
       location:(CLLocationCoordinate2D)location {
    self.destinationLoc = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    NSLog(@"You tapped %@: %@, %f/%f", name, placeID, location.latitude, location.longitude);
    GMSMarker *infoMarker = [[GMSMarker alloc] init];
    infoMarker = [GMSMarker markerWithPosition:location];
    infoMarker.snippet = placeID;
    infoMarker.title = name;
    infoMarker.opacity = 0;
    CGPoint pos = infoMarker.infoWindowAnchor;
    pos.y = 1;
    infoMarker.infoWindowAnchor = pos;
    infoMarker.map = mapView;
    mapView.selectedMarker = infoMarker;
}

#pragma mark - UISearchBarDelegate

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    [self.searchBar isFirstResponder];
    return YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if(self.searchBar.text != nil){
        self.navigationButton.enabled = YES;
        self.destinationString = searchBar.text;
    }
}


- (void)_startNavigation: (id)sender {
    self.navDetails.text = self.searchBar.text;
    [self.searchBar resignFirstResponder];
    
    GMSMutablePath *path = [GMSMutablePath path];
    
    /*
    NSArray<CLLocation *> *pathCoordinates = [self _defaultPathCoordinates];
    for (CLLocation *location in pathCoordinates) {
        [path addLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    }
    
    self.polyline = [GMSPolyline polylineWithPath:path];
    self.polyline.strokeColor = [UIColor blueColor];
    self.polyline.strokeWidth = 5.f;
    self.polyline.map = self.mapView;

    NSLog(@"navigation tapped");*/
    
    [self _fetchPathCoordinatesWithCompletion:^(GMSPolyline *polyline){
        if (polyline) {
            self.polyline = polyline;
            self.polyline.strokeColor = [UIColor blueColor];
            self.polyline.strokeWidth = 5.f;
            self.polyline.map = self.mapView;
        } else {
            NSLog(@"Error");
            [self _showErrorAlert];
        }
    }];
}

- (void)_clear: (id)sender {
    [self _clear];
    NSLog(@"clear tapped");
}

- (void)_clear
{
    [self.mapView clear];
    self.destinationLoc = nil;
}

- (NSArray<CLLocation *> *)_defaultPathCoordinates
{
    return @[self.currlocation, self.destinationLoc];
}

- (void)_showErrorAlert
{
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Error"
                                            message:@"Something went wrong, please try again later."
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action){
                                                         [self _clear];
                                                     }];

    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Network Request

- (void)_setupURLSession
{
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
}

- (void)_fetchPathCoordinatesWithCompletion:(void (^)(GMSPolyline *polyline))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSURLRequest *request = [self _buildPathCoordinatesRequest];
        [self _submitTaskWithRequest:request completion:^(BOOL success, NSData *data) {
            if (!success || !data) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil);
                });
            } else {
                NSError *error;
                NSDictionary *parsedData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil);
                    });
                    return;
                }
                
//                GMSPath *path =[GMSPath pathFromEncodedPath:parsedData[@"routes"][0][@"overview_polyline"][@"points"]];
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
//                    completion(singleLine);
//                });
                for(int i=0; i<[parsedData[@"routes"][0] count]; i++){
                    GMSPath *path =[GMSPath pathFromEncodedPath:parsedData[@"routes"][0][@"overview_polyline"][@"points"]];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
                        completion(singleLine);
                    });

                }
                
                
                
            }
        }];
    });
}

- (NSURLRequest *)_buildPathCoordinatesRequest
{
    NSURL *url = [NSURL URLWithString:@"https://maps.googleapis.com/maps/api/directions/json"];
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];

    NSString *originValueString =
        [NSString stringWithFormat:@"%f,%f", self.currlocation.coordinate.latitude, self.currlocation.coordinate.longitude];
    NSURLQueryItem *originQuery = [[NSURLQueryItem alloc] initWithName:@"origin" value:originValueString];

    NSString *destinationValueString =
        [NSString stringWithFormat:@"%f,%f", self.destinationLoc.coordinate.latitude, self.destinationLoc.coordinate.longitude];
    NSURLQueryItem *destinationQuery = [[NSURLQueryItem alloc] initWithName:@"destination" value:destinationValueString];
    
    NSURLQueryItem *keyQuery = [[NSURLQueryItem alloc] initWithName:@"key" value:@"AIzaSyBGCNNQL6nn_XDjHHanw7FplLu8sXcmVdE"];

    NSURLQueryItem *modeQuery = [[NSURLQueryItem alloc] initWithName:@"mode" value:@"walking"];

    components.queryItems = @[originQuery, destinationQuery, keyQuery, modeQuery];
    NSURLRequest *request = [NSURLRequest requestWithURL:components.URL];
    return request;
}

- (void)_submitTaskWithRequest:(NSURLRequest *)request completion:(void (^)(BOOL success, NSData *data))completion
{
    NSURLSessionDataTask *task =
    [_session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                    if (error || ![response isKindOfClass:[NSHTTPURLResponse class]]) {
                        completion(NO, nil);
                        return;
                    }
                    
                    NSInteger statusCode = [((NSHTTPURLResponse *)response) statusCode];
                    if (statusCode != 200) {
                        completion(NO, nil);
                        return;
                    }

                    completion(YES, data);
                }];
    [task resume];
}

@end
