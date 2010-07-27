//
//  HittaJonenAppDelegate.m
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-13.
//  Copyright Önders et Gonas HB 2010. All rights reserved.
//

#import "HittaJonenAppDelegate.h"
#import "HittaJonenViewController.h"
#import "OEGCommitQueue.h"

@implementation HittaJonenAppDelegate

@synthesize window;
@synthesize viewController;
@synthesize commitQueue,locationManager;


#pragma mark -
#pragma mark Application lifecycle

/*
 Request Token URL: http://foursquare.com/oauth/request_token
 
 Access Token URL: http://foursquare.com/oauth/access_token
 
 Authorize URL: http://foursquare.com/oauth/authorize
 
 
 
 
 
 We currently support hmac-sha1 signed requests
 
 
 
 
 
 Application Name: HittaJonen
 
 Callback URL: http://hittajonen.heroku.com/
 
 Key: AK33CVJQNNMDEXCOLMMRGFNRX2RSI11XBFOCL5FVE1ALGQ0D
 
 Secret: FWF5QWSA43REACYPD0HQFJLJFPSWDA2ANFCFJCZURJMUPI0J
 */


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the view controller's view to the window and display.
	locationManager=[[CLLocationManager alloc] init];
	locationManager.delegate=self;
	locationManager.desiredAccuracy=kCLLocationAccuracyNearestTenMeters;  
	
	commitQueue = [[OEGCommitQueue alloc] init];
	[commitQueue start];
	
	[window addSubview:viewController.view];
    [window makeKeyAndVisible];
	

	

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	//CLLocation *location = [[CLLocation alloc] initWithLatitude:57.6908 longitude:11.9923];
	NSLog(@"%@",[newLocation description]);
	
	//add to update
	
	NSString *url;
	
	/*
	 {"mappoint"=>
	 {"date(1i)"=>"2010", 
	 "time(1i)"=>"2010", 
	 "date(2i)"=>"7", 
	 "time(2i)"=>"7", 
	 "date(3i)"=>"14", 
	 "time(3i)"=>"14", 
	 "time(4i)"=>"14", 
	 "time(5i)"=>"28", 
	 "lat"=>"", 
	 "long"=>""}, "commit"=>"Create", "authenticity_token"=>"SFc711SApqMoBKo/lavFtFtvcuMX9f2FpK4g4aPBDXo="}
	 */
	
	
	//NSMutableDictionary *innerDict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"mappoint[lat]",@"mappoint[long]",nil] 
	//																	forKeys:[NSArray arrayWithObjects:@"40",@"50",nil]];
	
	//NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"mappoint",@"commit",@"authenticity_token",nil] forKeys:[NSArray arrayWithObjects:innerDict,@"Create",@"SFc711SApqMoBKo/lavFtFtvcuMX9f2FpK4g4aPBDXo=",nil]];
	/* 
	 mappoint[lat]
	 mappoint[long]
	 mappoint[type]
	 mappoint[flag]
	 mappoint[comment]
	*/
						
	/* 
	 types:
		0 : just a point
		1 : point with a message
		2 : foursquare
		3 : tweet
	 flags:
		0 : don't show
		1 : show
	 */
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%f",newLocation.coordinate.latitude],[NSString stringWithFormat:@"%f",newLocation.coordinate.longitude],@"0",@"1",@"hummer",nil] forKeys:[NSArray arrayWithObjects:@"mappoint[lat]",@"mappoint[long]",@"mappoint[mType]",@"mappoint[flag]",@"mappoint[comment]",nil]];

	url = [NSString stringWithFormat:@"http://hittajonen.heroku.com/mappoints"];
	
	
	NSLog(@"URL : %@",url);
	[self.commitQueue addCommitToEndpoint:url data:dict delegate:self];	
	
	
	
}
- (void) sendArguments:(NSMutableDictionary *)dict to:(NSString*)to from:(id)from{
		 
	NSString *url;
		 

	url = [NSString stringWithFormat:@"http://192.168.0.195:3000/mappoints/"];

		 
	 NSLog(@"URL : %@",url);
	 [self.commitQueue addCommitToEndpoint:url data:dict delegate:from];	
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
