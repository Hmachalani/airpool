//
//  MapsViewController.h
//  airpool
//
//  Created by Henri Machalani on 5/19/15.
//  Copyright (c) 2015 airpool inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import <CoreLocation/CoreLocation.h>

@interface GoogleMapsViewController : UIViewController<CLLocationManagerDelegate>


//methods
- (void) updateMarker:(CLLocationCoordinate2D) position;


@end
