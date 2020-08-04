//
//  QLineController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "QLineWindowController.h"


@implementation QLineWindowController

- (id) initUsingMcCabeThiele: (McCabeThiele*) itsMcCabeThiele
{
    self = [ super initWithWindowNibName:@"QLinePanel" ];
    if (self) 
    {
		mcCabeThiele = itsMcCabeThiele;
    }
    
    return self;
}

- (void) awakeFromNib
{	
    [ self setMcCabeThiele:mcCabeThiele ];
}

- (void) windowDidLoad
{	
    NSLog(@"Nib file is loaded");
}

- (IBAction)showWindow:(id)sender
{
    [NSApp beginSheet:[ self window] 
       modalForWindow:[ sender windowForSheet] 
		modalDelegate:self
       didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
		  contextInfo:nil ];
}

- (void) sheetDidEnd: (NSWindow*) sheet
		  returnCode: (int) returnCode
		 contextInfo: (void*) contextInfo
{
	// Make sure the Data Sets are sorted.
	//
}



- (IBAction) applyQLineControllerSheet: (id) sender
{
    // Hide the Sheet.
    [[ self window] orderOut: sender ];
	
    // Return normal event handling.
    [ NSApp endSheet:[ self window] returnCode:1];
	
	NSNotificationCenter* notificationCentre = [NSNotificationCenter defaultCenter ];
	[  notificationCentre postNotificationName:@"qLineSuccessfullyDefined" object:self ];
	
    return;
}


- (IBAction) closeQLineControllerSheet: (id) sender
{
    // Hide the Sheet.
    [[ self window] orderOut: sender ];
	
    // Return normal event handling.
    [ NSApp endSheet:[ self window] returnCode:0];
	
	NSNotificationCenter* notificationCentre = [NSNotificationCenter defaultCenter ];
	[  notificationCentre postNotificationName:@"qLineDefined" object:self ];
	
    return;
}


- (void) setMcCabeThiele: (McCabeThiele*) newMcCabeThiele
{
	mcCabeThiele = newMcCabeThiele;
	
	[ mcCabeThieleController setContent: mcCabeThiele ];
	
	return;
}

- (IBAction) heatInfoEnteredDirectly: (id) sender
{
	[ mcCabeThiele updateOnHeatInfoEnteredDirectly ];
	
	return;
}

- (IBAction) qInfoEnteredDirectly: (id) sender
{
	[ mcCabeThiele updateQInfoEnteredDirectly ];	
	
	return;
}


/*
- (void)controlTextDidBeginEditing:(NSNotification *)aNotification
{
	if ( mcCabeThiele.qInfoEnteredDirectly == NO )
	{
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"Reset Heat Data"];
		[alert addButtonWithTitle:@"Abandon Edit"];
		[alert setMessageText:@"Your editing the qLine Data directly after entering the heat data."];
		[alert setInformativeText:@"This will reset the Heat Data information"];
		[alert setAlertStyle:NSWarningAlertStyle];
		
		[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];

	}
	else
		[ mcCabeThiele updateQInfoEnteredDirectly ];	

	return;
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if (returnCode == NSAlertSecondButtonReturn) 
	{
		mcCabeThiele.qInfoEnteredDirectly = YES;
    }

	[ mcCabeThiele updateQInfoEnteredDirectly ];	

	return;
}
*/

/*
- (void)textDidEndEditing:(NSNotification *)aNotification
{
	[ mcCabeThiele updateQInfoEnteredDirectly ];	

}

- (BOOL)textShouldBeginEditing:(NSText *)textObject
{
	return YES;
}

- (BOOL)textShouldEndEditing:(NSText *)textObject
{
	return YES;
}
 */

@end
