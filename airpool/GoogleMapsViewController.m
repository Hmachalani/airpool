//
//  MapsViewController.m
//  airpool
//
//  Created by Henri Machalani on 5/19/15.
//  Copyright (c) 2015 airpool inc. All rights reserved.
//

#import "GoogleMapsViewController.h"


@interface GoogleMapsViewController () <GMSMapViewDelegate, CLLocationManagerDelegate>

//instance variables
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) GMSMarker *marker;
@property (nonatomic) GMSMapView *mapView;
@property (nonatomic) GMSGeocoder *geocoder;
@property (nonatomic) GMSAddress *startLocationAddress;

@property (weak, nonatomic) IBOutlet UIView *mapViewContainer;


//properties
@property (nonatomic) CLLocation * startLocation;

@property (nonatomic) BOOL isFirstGeoUpdate;
@property (nonatomic) UIImageView *lePin;

@property (nonatomic) UIButton *requestButton;

@property (weak, nonatomic) IBOutlet UILabel *fromLocation;

@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UIView *clockView;
@property (weak, nonatomic) IBOutlet UIView *addressView;


@end

@implementation GoogleMapsViewController

NSString *const API_KEY = @"AIzaSyANwK1-_P5Bk4Wj8FBSr4dr9mY5flM5_R4";


- (void)viewDidLoad {
    [super viewDidLoad];
    [GMSServices provideAPIKey:API_KEY];

    //inits
    self.isFirstGeoUpdate=true;
    self.lePin = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"lePinImage"]];
    self.geocoder=[[GMSGeocoder alloc] init];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    
    // style stuff //
    
    UIColor *borderColor=[UIColor colorWithRed:0.58 green:0.54 blue:0.54 alpha:1.0];
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, self.navigationBarView.frame.size.height, self.navigationBarView.frame.size.width, 0.5f);
    bottomBorder.backgroundColor = borderColor.CGColor;
    [self.navigationBarView.layer addSublayer:bottomBorder];
    
    self.clockView.layer.borderWidth=0.5f;
    self.clockView.layer.borderColor=borderColor.CGColor;
    
   
    self.addressView.layer.borderWidth=0.5f;
    self.addressView.layer.borderColor=borderColor.CGColor;
    
   
    /*
    CALayer *leftBorderClock = [CALayer layer];
    leftBorderClock.frame = CGRectMake( 0.0f,0.0f, 0.5f, self.clockView.frame.size.height);
    leftBorderClock.backgroundColor = [UIColor colorWithRed:0.58 green:0.54 blue:0.54 alpha:1.0].CGColor;
    [self.clockView.layer addSublayer:leftBorderClock];
     */
    
    
    
    // location stuff //
    
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestAlwaysAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    
    

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.868
                                                            longitude:151.2086
                                                                 zoom:17];
    
    
    self.mapView = [GMSMapView mapWithFrame:[[UIScreen mainScreen] bounds] camera:camera];
    
    
    [self.mapViewContainer addSubview: self.mapView];
    
    CGPoint hello=CGPointMake (self.mapView.frame.size.width/2+10, self.mapView.frame.size.height/2-5);
    NSLog(@"width %f and height %f",hello.x, hello.y);
    [self.lePin setCenter:hello];
    
    self.mapView.delegate=self;
    //[self.view addSubview:self.mapView];
    [self.mapViewContainer addSubview:self.lePin];

    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
}

- (void) viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    UIColor *borderColor=[UIColor colorWithRed:0.58 green:0.54 blue:0.54 alpha:1.0];

    
    [self roundCorners:self.addressView
               corners:(UIRectCornerTopLeft|UIRectCornerBottomLeft)
                radius:5.0f
                 color:borderColor
           borderWidth:0.5f];
    
    [self roundCorners:self.clockView
               corners:(UIRectCornerTopRight|UIRectCornerBottomRight)
                radius:5.0f
                 color:borderColor
           borderWidth:0.5f];
}


- (void) updateMarker:(CLLocationCoordinate2D) position
{
    /*
    if(self.marker==nil)
    {
        self.marker= [[GMSMarker alloc] init];
        self.marker.position = position;
        self.marker.snippet = @"You";
        self.marker.appearAnimation = kGMSMarkerAnimationPop;
        self.marker.map = self.mapView;
        //TODO: Set icon using [self.marker setIcon]
    }else
    {
        self.marker.position = position;
    }
     */
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
    //zz  self.point.coordinate = [mapView centerCoordinate];
    NSLog(@"did pan to new location");
    
    
    CGPoint centerPoint= [mapView center];
    CLLocationCoordinate2D centerCoordinate = [mapView.projection coordinateForPoint:centerPoint];
    NSLog(@"coordinates: %f and %f",centerCoordinate.latitude, centerCoordinate.longitude);
    
    [self.geocoder reverseGeocodeCoordinate:centerCoordinate completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
            if(response!=nil && response.results.count>0)
            {
                self.startLocationAddress=response.firstResult;
                NSLog(@"Placemark is:%@",self.startLocationAddress.thoroughfare);
                self.fromLocation.text=self.startLocationAddress.thoroughfare;
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
    
    self.startLocation = newLocation;

    if (self.startLocation != nil) {
        
       
        if(self.isFirstGeoUpdate)
        {
            GMSCameraPosition *camera =  [GMSCameraPosition cameraWithLatitude:self.startLocation.coordinate.latitude
                                                                     longitude:self.startLocation.coordinate.longitude
                                                                          zoom:17];
            
            [self.mapView setCamera:camera];
            self.isFirstGeoUpdate=false;
        }
        
    
        
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



#pragma mark - Helper functions
-(void)roundCorners:(UIView *)view corners:(UIRectCorner)corners radius:(CGFloat)radius color:(UIColor *) color borderWidth:(CGFloat)borderWidth
{

    CGRect bounds = view.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:corners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    view.layer.mask = maskLayer;
    
    CAShapeLayer*   frameLayer = [CAShapeLayer layer];
    frameLayer.frame = bounds;
    frameLayer.path = maskPath.CGPath;
    frameLayer.strokeColor = color.CGColor;
    frameLayer.fillColor = nil;
    frameLayer.lineWidth = borderWidth*2;
    
    [view.layer addSublayer:frameLayer];
}

@end
