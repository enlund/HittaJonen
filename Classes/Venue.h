//
//  Venue.h
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-15.
//  Copyright 2010 Önders et Gonas HB. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Venue : NSObject {
	int venueId;
	NSString *venueName,*latitude,*longitude;
	float distance;
	/*
	 <id>1560385</id>
	<name>Holländska Cigarrmagasinet</name>
	<address/>
	<city/>
	<state/>
	<geolat>57.684339</geolat>
	<geolong>11.972845</geolong>
	−
	<stats>
	<herenow>0</herenow>
	</stats>
	<distance>347</distance>
	</venue>
	 */
}

@property (nonatomic,retain) NSString *venueName;
@property (nonatomic,retain) NSString *latitude;

@property (nonatomic,retain) NSString *longitude;


@property int venueId;
@property float distance;
@end
