//
//  HittaJonenViewController.h
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-13.
//  Copyright Önders et Gonas HB 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HittaJonenAppDelegate.h"


@interface HittaJonenViewController : UIViewController{
	IBOutlet UISwitch *updateSwitch,*stealthSwitch;
	HittaJonenAppDelegate *appDelegate;
}

-(IBAction) updateSwitchChangedValue;
-(IBAction) stealthSwitchChangedValue;

@end

