//
//  HittaJonenAppDelegate.h
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-13.
//  Copyright Önders et Gonas HB 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@class HittaJonenViewController;
@class OEGCommitQueue;


@interface HittaJonenAppDelegate : NSObject <UIApplicationDelegate,CLLocationManagerDelegate> {
    UIWindow *window;
    UITabBarController *viewController;
	CLLocationManager *locationManager;
	OEGCommitQueue *commitQueue;

}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *viewController;

@property (nonatomic, retain) IBOutlet OEGCommitQueue *commitQueue;
@property (nonatomic, retain) IBOutlet CLLocationManager *locationManager;
@end

