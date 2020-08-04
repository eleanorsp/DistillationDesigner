//
//  main.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 04/02/2008.
//  Copyright Crumpets Farm 2008. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "appStoreValidateReceipt.h"

// in your project define those two somewhere as such:
const NSString * appbundleVersion_global = @"1.1.1";
const NSString * appbundleIdentifier_global = @"DistillationDesigner";

int main(int argc, char *argv[])
{
    // Check the validation
    //
    // put the example receipt on the desktop (or change that path)
#ifdef BETA_TEST
	NSString * pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Resources/samplereceipt"];
#else
	// in your own code you have to do:
	NSString * pathToReceipt = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/_MASReceipt/receipt"];
	// this example is not a bundle so it wont work here.
#endif
	
//	if ( checkAppStoreReceiptAtPath( pathToReceipt ) == NO )
//		exit(173);
        
    return NSApplicationMain(argc,  (const char **) argv);
}
