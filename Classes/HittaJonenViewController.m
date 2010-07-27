//
//  HittaJonenViewController.m
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-13.
//  Copyright Önders et Gonas HB 2010. All rights reserved.
//

#import "HittaJonenViewController.h"
#import "HittaJonenAppDelegate.h"

@implementation HittaJonenViewController




// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
  }
    return self;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

}
*/

-(IBAction) updateSwitchChangedValue {
	if(updateSwitch.on) {
		NSLog(@"Location enabled");
		[appDelegate.locationManager startUpdatingLocation];
	} else {
		NSLog(@"Location disabled");
		[appDelegate.locationManager stopUpdatingLocation];
	}
}
-(IBAction) stealthSwitchChangedValue {
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	appDelegate = [UIApplication sharedApplication].delegate;
	

}



/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)dealloc {
    [super dealloc];
}

@end
