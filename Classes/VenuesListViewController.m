//
//  VenuesListViewController.m
//  HittaJonen
//
//  Created by Jonas Enlund on 2010-07-15.
//  Copyright 2010 Önders et Gonas HB. All rights reserved.
//

#import "VenuesListViewController.h"
#import "Venue.h"
#import "HittaJonenAppDelegate.h"
#import "CJSONDeserializer.h"

@implementation VenuesListViewController

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];
	venues = [[NSArray alloc] init];
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(IBAction) reloadButtonPressed {
	NSThread *fetchThread = [[NSThread alloc] initWithTarget:self selector:@selector(fetchVenues) object:nil];
	[fetchThread start];
	[fetchThread release];
}


- (void) fetchVenues {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSLog(@"nu laddar vi lite JSON här va");
	HittaJonenAppDelegate *appDelegate = (HittaJonenAppDelegate *)[UIApplication sharedApplication].delegate;
	
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.foursquare.com/v1/venues.json?geolat=%f&geolong=%f",appDelegate.locationManager.location.coordinate.latitude,appDelegate.locationManager.location.coordinate.longitude]]; 

	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url]; 
	[request setHTTPMethod:@"GET"];
	NSURLResponse *response = nil; 
	NSError *error = nil; 
	NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error]; 
	[request release]; 

	NSString *resultString = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
	
	//while([resultString rangeOfString:@"/*"].location != NSNotFound) {
	//	int i = [resultString rangeOfString:@"/*"].location;
	//	int j = [resultString rangeOfString:@"*/"].location;
	//	resultString = [resultString stringByReplacingCharactersInRange:NSMakeRange(i, j-i+2) withString:@""];
	//}
	
	

	//result = [resultString dataUsingEncoding:NSUTF8StringEncoding];
	//resultString = [resultString substringWithRange:NSMakeRange(1, [resultString length] -2)];
	//result = [resultString dataUsingEncoding:NSUTF8StringEncoding];
	//NSLog(@"%@",resultString);
	NSDictionary *dictionary = [[CJSONDeserializer deserializer] deserializeAsDictionary:result error:&error];
	//NSArray *resultArray = [[CJSONDeserializer deserializer] deserialize:result error:&error];
	NSMutableArray *tempArray = [[NSMutableArray alloc] init];
	
	for (NSDictionary *dicken in [dictionary objectForKey:@"groups"] ) {	
	
		for (NSDictionary *dict in [dicken objectForKey:@"venues"]) {
		
			Venue *venue = [[Venue alloc] init];
			venue.venueId = [[dict objectForKey:@"id"] intValue];
			venue.venueName = [dict objectForKey:@"name"];
			venue.longitude = [dict objectForKey:@"geolong"];
			venue.latitude = [dict objectForKey:@"geolat"];
			

			venue.distance = [[dict objectForKey:@"distance"] floatValue];
			
			[tempArray addObject:venue];
			[venue release];
		}
	}
	
	
	venues = [[NSArray arrayWithArray:tempArray] retain];
	[tempArray release];
	//[resultArray release];
	//[pool release];
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

}


-(void) reloadData {
	[self.view reloadData];
}
	

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [venues count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
	
	cell.textLabel.text = ((Venue *)[venues objectAtIndex:indexPath.row]).venueName;
    
    return cell;
}

- (void) wooaah {
	NSLog(@"wooaah");
}

- (BOOL) checkin:(NSNumber*)venueId {
	/*
# vid - (optional, not necessary if you are 'shouting' or have a venue name). ID of the venue where you want to check-in
# venue - (optional, not necessary if you are 'shouting' or have a vid) if you don't have a venue ID or would rather prefer a 'venueless' checkin, pass the venue name as a string using this parameter. it will become an 'orphan' (no address or venueid but with geolat, geolong)
# shout - (optional) a message about your check-in. the maximum length of this field is 140 characters
# private - (optional). "1" means "don't show your friends". "0" means "show everyone"
# twitter - (optional, defaults to the user's setting). "1" means "send to Twitter". "0" means "don't send to Twitter"
# facebook - (optional, defaults to the user's setting). "1" means "send to Facebook". "0" means "don't send to Facebook"
# geolat - (optional, but recommended)
# geolong - (optional, but recommended)
	 
*/
	
//	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	HittaJonenAppDelegate *appDelegate = (HittaJonenAppDelegate*)[UIApplication sharedApplication].delegate;
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",venueId],@"0",@"0",@"0",nil] forKeys:[NSArray arrayWithObjects:@"vid",@"twitter",@"facebook",@"private",nil]];
	
	
	[appDelegate.commitQueue addCommitToEndpoint:@"http://api.foursquare.com/v1/checkin" data:dict delegate:self];
	
	


	//[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];

	return YES;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//NSThread *checkinThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkin:) object:((Venue *)[venues objectAtIndex:indexPath.row]).venueId];
	//[checkinThread start];
	//[checkinThread release];
	currentVenue = [venues objectAtIndex:indexPath.row];
	NSThread *checkinThread = [[NSThread alloc] initWithTarget:self selector:@selector(checkin:) object:[NSNumber numberWithInt:((Venue *)[venues objectAtIndex:indexPath.row]).venueId]];
	[checkinThread start];
	[checkinThread release];

	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
}


- (void)sendSuccess:(NSInteger)statusCode{
	NSLog(@"statusCode : %d",statusCode);
	if(statusCode == 200) {
		HittaJonenAppDelegate *appDelegate = (HittaJonenAppDelegate*)[UIApplication sharedApplication].delegate;
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",currentVenue.latitude],[NSString stringWithFormat:@"%@",currentVenue.longitude],@"2",@"1",@"hummer",nil] forKeys:[NSArray arrayWithObjects:@"mappoint[lat]",@"mappoint[long]",@"mappoint[mType]",@"mappoint[flag]",@"mappoint[comment]",nil]];
		
		NSString *url = [NSString stringWithFormat:@"http://hittajonen.heroku.com/mappoints.xml"];
		
		NSLog(@"Venue : %@ long : %@ lat : %@",currentVenue.venueName,currentVenue.longitude,currentVenue.latitude);
		NSLog(@"URL : %@",url);
		[appDelegate.commitQueue addCommitToEndpoint:url data:dict delegate:nil];	
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FourSquare" message:[NSString stringWithFormat:@"OK \n%d",statusCode] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
		
	} else {		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FourSquare" message:[NSString stringWithFormat:@"Gick inte \n%d",statusCode] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}


}

- (void)sendFailed:(NSError *)error {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FourSquare" message:[NSString stringWithFormat:@"Gick inte... \n%@",error] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alertView show];
	[alertView release];
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

