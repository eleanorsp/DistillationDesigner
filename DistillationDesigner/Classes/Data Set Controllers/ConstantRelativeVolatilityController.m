//
//  ConstantRelativeVolatilityController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/01/2011.
//  Copyright 2011 Spenceley Consultancy Ltd. All rights reserved.
//

#import "ConstantRelativeVolatilityController.h"

#import "RelativeVolatilityDataSource.h"

@implementation ConstantRelativeVolatilityController

#pragma mark IBActions

- (IBAction) dataEntered: (id) sender
{
	NSLog( @"ConstantRelativeVolatilityController: dataEntered:" );
	
	RelativeVolatilityDataSource* source = (RelativeVolatilityDataSource*) [ self content];

	if ( [ source isCompleteToCalculateRelVol ] == YES )
	{
		[ source buildVLEFromRelativeVolatityData ];
		[ tableView reloadData];
		[ tableView sizeLastColumnToFit ];
		[ tableView sizeToFit ];
	}


	return;
}


#pragma mark METHODS
	

#pragma mark TABLE 
//
- (NSInteger) numberOfRowsInTableView:(NSTableView*) thetableView
{
	NSLog(@"ConstantRelativeVolatilityController: numberOfRowsInTableView" );
	
    if ( thetableView == tableView )
    {
		RelativeVolatilityDataSource* loadedSource = [ self content ];
		return [ loadedSource.data count ];
    }
    
    return 0; 
}

- (void) updateTableView
{
	NSLog(@"ConstantRelativeVolatilityController: updateTableView" );
	
    // Tell the DataSet to update itself.
    //
    [ tableView reloadData];
	[ tableView sizeLastColumnToFit ];
    
    return;
}

- (id) tableView:(NSTableView* ) theTableView
objectValueForTableColumn:(NSTableColumn*) tableColumn
			 row:(NSInteger) rowIndex
{
	NSLog(@"ConstantRelativeVolatilityController: tableView" );
	
    // Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	RelativeVolatilityDataSource* loadedSource = [ self content ];
	
	if ( [ identifier compare: @"Temperature °C" ] == 0 )
		arrayIndex = 2;
	else if ( [ identifier compare: @"In Vapour Phase (y)" ] == 0 )
		arrayIndex = 1;
	
	// Get the information.
    if ( theTableView == tableView )
    {
		NSArray* array = [ loadedSource.data objectAtIndex:rowIndex ];     
		if ( [ identifier compare:@"RowCount" ] == 0 )
			return [[ NSNumber alloc] initWithInt:rowIndex+1 ];
		else
			return [ array objectAtIndex:arrayIndex ];
    }    
    
    return nil;
}


- (void) tableView:(NSTableView *) theTableView
	setObjectValue:(id) anObject
    forTableColumn:(NSTableColumn*) tableColumn
			   row:(NSInteger) rowIndex
{        
	NSLog(@"ConstantRelativeVolatilityController: tableView: setObjectValue:" );
	
	// Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	RelativeVolatilityDataSource* loadedSource = [ self content ];
	
	if ( [ identifier compare: @"Temperature °C" ] == 0 )
		arrayIndex = 2;
	else if ( [ identifier compare: @"In Vapour Phase (y)" ] == 0 )
		arrayIndex = 1;
	
    // Get the information.
    if ( theTableView == tableView )
    {
		NSMutableArray* data = loadedSource.data;
		NSMutableArray* array = [ data objectAtIndex:rowIndex ];     
		
		[ array replaceObjectAtIndex:arrayIndex withObject: anObject]; 
    }
    
    return;
}


@end
