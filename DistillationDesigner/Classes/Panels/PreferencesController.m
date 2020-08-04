//
//  PreferencesController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 13/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "PreferencesController.h"

NSString* DD_VapourColourKey = @"DD_VapourColour";
NSString* DD_LiquidColourKey = @"DD_LiquidColour";
NSString* DD_ShowMinorAxisKey = @"DD_ShowMinorAxis";
NSString* DD_NumberMinorIntervalsKey = @"DD_NumberMinorIntervals";

NSString* DD_StageFillColourKey = @"DD_StageFillColour";
NSString* DD_StageLineColourKey = @"DD_StageLineColour";
NSString* DD_FillStagesKey = @"DD_FillStages";

//Optimal
NSString* DD_OptimalShowMinorLinesKey = @"DD_OptimalShowMinorLines";
NSString* DD_OptimalNumberMinorIntervalsKey = @"DD_OptimalNumberMinorIntervals";

NSString* DD_OptimalXAxisMajorIntervalsKey = @"DD_OptimalXAxisMajorIntervals";

NSString* DD_OptimalShowYAxisBandingKey = @"DD_OptimalShowYAxisBanding";
NSString* DD_OptimalYAxisBandingColourKey = @"DD_OptimalYAxisBandingColour";
NSString* DD_OptimalYAxisMajorIntervalsKey = @"DD_OptimalYAxisMajorIntervals";

NSString* DD_OptimalLineColourKey = @"DD_OptimalLineColour";
NSString* DD_OptimalPlotLineSkirtKey = @"DD_OptimalPlotLineSkirt";

// Boiling Point
NSString* DD_BPVapourColourKey = @"DD_BPVapourColour";
NSString* DD_BPLiquidColourKey = @"DD_BPLiquidColour";
NSString* DD_BPShowMinorAxisKey = @"DD_BPShowMinorAxis";
NSString* DD_BPNumberMinorIntervalsKey = @"DD_BPNumberMinorIntervals";



@implementation PreferencesController

#pragma mark INITIALISE
//
- (id) init
{
	NSLog(@"PreferencesController: init" );
	
    self = [ super initWithWindowNibName:@"Preferences" ];
    if (self) 
    {
	}
    
    return self;
}


#pragma mark WINDOW_CONTROL
//
- (void) windowDidLoad
{
	NSLog(@"Preferences Window did load" );
	
	NSString* iden = [ prefBoilingPoint itemIdentifier ];
	[ toolBar setSelectedItemIdentifier:iden];
}

- (void)close
{
	NSLog(@"PreferencesController: close" );

	// Save the new colours to the NSUserDefaults.
	//
	// read the value of the user default with key aKey
	// and return it in aColor
	
	[ super close ];
}


#pragma mark GETS_SETS
//
// Translating the NSData into the NSColour Objects for the Bindings.
//
- (NSColor* ) DD_VapourColour
{
	NSLog(@"PreferencesController: DD_VapourColour" );

	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_VapourColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}

- (NSColor* ) DD_LiquidColour
{
	NSLog(@"PreferencesController: DD_LiquidColour" );

	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_LiquidColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}

- (NSColor* ) DD_StageLineColour
{
	NSLog(@"PreferencesController: DD_StageLineColour" );

	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_StageLineColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}


- (NSColor* ) DD_StageFillColour
{
	NSLog(@"PreferencesController: DD_StageFillColour" );

	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_StageFillColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}

- (NSColor* ) DD_OptimalYAxisBandingColour
{
	NSLog(@"PreferencesController: DD_OptimalYAxisBandingColour" );
	
	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_OptimalYAxisBandingColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}

- (NSColor* ) DD_OptimalLineColour
{
	NSLog(@"PreferencesController: DD_OptimalLineColourKey" );
	
	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_OptimalLineColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];	
}

- (NSColor* ) DD_BPVapourColour
{
	NSLog(@"PreferencesController: DD_BPVapourColour" );
	
	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_BPVapourColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}

- (NSColor* ) DD_BPLiquidColour
{
	NSLog(@"PreferencesController: DD_BPLiquidColour" );
	
	NSUserDefaults* defaults;
	NSData* colourAsData;
	
	defaults = [ NSUserDefaults standardUserDefaults ];
	colourAsData = [ defaults objectForKey: DD_BPLiquidColourKey ];
	
	return [ NSKeyedUnarchiver unarchiveObjectWithData:colourAsData ];
}


- (void) setDD_LiquidColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_LiquidColour" );

	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_LiquidColourKey];
	
	return;
}

- (void) setDD_VapourColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_VapourColour" );

	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_VapourColourKey];
	
	return;
}

- (void) setDD_StageLineColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_StageLineColour" );

	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_StageLineColourKey];
	
	return;
}

- (void) setDD_StageFillColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_StageFillColour" );

	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_StageFillColourKey];
	
	return;
}

- (void) setDD_OptimalYAxisBandingColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_OptimalYAxisBandingColour" );
	
	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_OptimalYAxisBandingColourKey];
	
	return;
}

- (void) setDD_OptimalLineColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_OptimalLineColourKey" );
	
	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_OptimalLineColourKey];
	
	return;
}

- (void) setDD_BPLiquidColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_BPLiquidColour" );
	
	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_BPLiquidColourKey];
	
	return;
}

- (void) setDD_BPVapourColour: (NSColor*) newColor
{
	NSLog(@"PreferencesController: setDD_BPVapourColour" );
	
	NSData *theData=[NSArchiver archivedDataWithRootObject:newColor];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:DD_BPVapourColourKey];
	
	return;
}


#pragma mark DATA_MANIPULATION 
//
// Reset the Vapour/Liquid Colours.
//
- (IBAction) resetMcCabeValues: (id) sender
{
	// Reset the Vapour/Liquid Colours.
	//
	NSLog(@"PreferencesController: resetMcCabeValues" );
}


// Reset the Optimal Information
//
- (IBAction) resetOptimalValues: (id) sender
{
	// Reset the Vapour/Liquid Colours.
	//
	NSLog(@"PreferencesController: resetOptimalValues" );
}


#pragma mark IB_ACTION
//
- (IBAction) showTabPanel: (id) sender
{
	if ( sender == prefBoilingPoint )
	{
		[ tabView selectTabViewItemAtIndex: 2 ];
	}
	else if ( sender == prefMcCabeThiele )
		[ tabView selectTabViewItemAtIndex: 1 ];
	else
		[ tabView selectTabViewItemAtIndex: 0 ];
	
	return;
}


#pragma mark DELEGATE

// Return the items which can be selected.
//
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	NSMutableArray *theArray = [NSMutableArray new];
	NSToolbarItem *currentItem;
	for (currentItem in [toolbar items]) {
		[theArray addObject:[currentItem itemIdentifier]];
	}
	
	return theArray;
}


@end
