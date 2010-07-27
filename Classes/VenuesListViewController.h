//
//  VenuesListViewController.h
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-15.
//  Copyright 2010 Önders et Gonas HB. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Venue;


@interface VenuesListViewController : UITableViewController {
	IBOutlet UIButton *reloadButton;


	NSArray *venues;
	Venue *currentVenue;
}

-(IBAction) reloadButtonPressed;
-(BOOL) checkin:(int)venueId;


@end
