//
//  DonateWindowController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 17/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "DonateWindowController.h"


@implementation DonateWindowController

- (id) init
{
	NSLog(@"DonateWindowController: init" );
	
    self = [ super initWithWindowNibName:@"Donate" ];
    if (self) 
    {
		donateURL = [ NSString stringWithString:@"http://www.crumpetsfarm.com" ];

	}
    
    return self;
}


#pragma mark WINDOW_CONTROL
//
- (void) windowDidLoad
{
	NSLog(@"DonateWindowController Window did load" );
}

- (void)close
{
	NSLog(@"DonateWindowController: close" );
	
	// Save the new colours to the NSUserDefaults.
	//
	// read the value of the user default with key aKey
	// and return it in aColor
	
	[ super close ];
}


- (IBAction) callDonationWebBrowser: (id) sender
{
	NSURL* url = [ [ NSURL alloc ] initWithString:@"https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=Eleanorws%40mac%2ecom&item_name=Eleanor%20Spenceley%20%40%20the%20Crumpery&item_number=Distillation%20Designer&no_shipping=0&no_note=1&tax=0&currency_code=GBP&lc=GB&bn=PP%2dDonationsBF&charset=UTF%2d8" ];
	
	[[NSWorkspace sharedWorkspace] openURL: url ];
}



@synthesize iveDonated;
@synthesize donateURL;


@end
