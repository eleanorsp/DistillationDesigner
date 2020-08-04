//
//  DonateWindowController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 17/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DonateWindowController : NSWindowController 
{
	Boolean iveDonated;
	NSString* donateURL;
}

- (IBAction) callDonationWebBrowser: (id) sender;


@property Boolean iveDonated;
@property (retain) NSString* donateURL;

@end
