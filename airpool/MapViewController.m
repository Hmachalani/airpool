//
//  MapViewController.m
//  airpool
//
//  Created by Henri Machalani on 5/20/15.
//  Copyright (c) 2015 airpool inc. All rights reserved.
//

#import "MapViewController.h"
@import MapKit; // for MKUserTrackingModeNone


@interface MapViewController ()  <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL isFirstGeoUpdate;
@property (nonatomic) MKPointAnnotation *point;
@property (nonatomic) CLLocation * userLocation;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) MKPlacemark *placemark;

@property (nonatomic) UIImageView *lePin;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //inits
    self.isFirstGeoUpdate=true;
    self.point = [[MKPointAnnotation alloc] init];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    
    self.mapView = [[MKMapView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate=self;
    
    self.lePin = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lePinImage"]];
    self.geocoder=[[CLGeocoder alloc] init];
    
    
    
    self.view=self.mapView;
   
   
    
    CGPoint hello=CGPointMake (self.mapView.frame.size.width/2+10, self.mapView.frame.size.height/2-5);
    NSLog(@"width %f and height %f",hello.x, hello.y);
    [self.lePin setCenter:hello];

    [self.view addSubview:self.lePin];
    
    NSLog(@"center is :%f,%f",self.lePin.center.x, self.lePin.center.y);
}


 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
  //zz  self.point.coordinate = [mapView centerCoordinate];
    NSLog(@"did pan to new location");
    
    CLLocationCoordinate2D center= [mapView centerCoordinate];
    
    CLLocation * location= [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
    
    // Lookup the information for the current location of the user.
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if ((placemarks != nil) && (placemarks.count > 0)) {
                // If the placemark is not nil then we have at least one placemark. Typically there will only be one.
                self.placemark = [placemarks objectAtIndex:0];
                
                // we have received our current location, so enable the "Get Current Address" button
                NSLog(@"Placemark is:%@",self.placemark.name);
            }
            else {
                // Handle the nil case if necessary.
            }
        }];

    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    self.userLocation=newLocation;

    if (self.userLocation != nil) {
        
        if(self.isFirstGeoUpdate)
        {
            MKMapCamera *camera =  [MKMapCamera cameraLookingAtCenterCoordinate:self.userLocation.coordinate
                                                              fromEyeCoordinate:self.userLocation.coordinate
                                                                    eyeAltitude:750];
            
            self.point.coordinate = self.userLocation.coordinate;
            self.point.title = @"Departure location";
            //se ed  lf.point.subtitle = @"I'm here!!!";
            
            [self.mapView setCamera:camera];
          //  [self.mapView addAnnotation:self.point];
            self.isFirstGeoUpdate=false;
        }
        
        
        
        
        // Add an annotation
       
        
        
        
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
