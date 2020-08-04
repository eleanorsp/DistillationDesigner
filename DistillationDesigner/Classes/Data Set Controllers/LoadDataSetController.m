//
//  LoadDataSetController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 23/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "FileDataSource.h"

#import "LoadDataSetController.h"


@implementation LoadDataSetController

#pragma mark INITIALISE 

- (void) initialiseTableView
{
	NSLog(@"ManualDataSetController: initialiseTableView" );
	
    NSArray* tableColumns = [ tableView tableColumns ];
    NSInteger i;
    for ( i = [ tableColumns count]-1; i >=0 ; i-- )
    {
		NSTableColumn* tableColumn = [ tableColumns objectAtIndex:i];
		NSString* identifierString = [tableColumn identifier];
		
		if ( [ identifierString compare:@"RowCount"] != 0 )
		{
			// Remove the Column.
			//
			[ tableView removeTableColumn:tableColumn];
		}
    }
	
    // Now Add the New Columns.
    //
    DataSource* source = (DataSource*) [ self content];
    if ( source == nil )
		return;
    NSMutableArray* sourceData = [ source data];
    if ( sourceData == nil )
		return;
	
   // NSArray* sourceColumnNames = [ source allColumnData ];
    for ( i = 0; i < 3; i++ )
    {
		NSString* columnName; 
		if ( i == 0 )
			columnName = @"Temperature °C";
		else if ( i == 1 )
			columnName = @"In Liquid Phase (x)";
		else
			columnName = @"In Vapour Phase (y)";
		
		NSTableColumn* tableColumn = [ [ NSTableColumn alloc] initWithIdentifier:columnName];
		NSTextFieldCell* headerCell = [ tableColumn headerCell];
		[ headerCell setSelectable:NO];
		[ headerCell setEditable:NO ];
		[ headerCell setTitle:columnName];
		[ headerCell setEnabled:YES ];
		//	[ headerCell setAction:SEL @"headerNameUpdated"];
		[ headerCell setAlignment:NSCenterTextAlignment];
		
		// TBD find out what the data is 
		NSTextFieldCell* dataCell = [ tableColumn dataCell];
		if ( i == 0 )
			[ dataCell setFormatter:temperatureFormatter];
		else
			[ dataCell setFormatter:compositionFormatter];
		
		[ dataCell setAlignment:NSRightTextAlignment];
		[ dataCell setDrawsBackground:NO];
		[ dataCell setEditable:NO];
		[ dataCell setSelectable:NO ];
		//	[ dataCell d:[ NSColor blueColor]];
		//	[ tableColumn setDataCell:dataCell];	
		[ tableView addTableColumn:tableColumn];
    }
    
	[ tableView sizeToFit ];
    [ tableView setUsesAlternatingRowBackgroundColors:YES];
    [ self selectedTableRow: tableView];
    [ self updateTableView];
	
    return;
}


#pragma mark IB_ACTION 
//
// Action Methods
//
//
// Implement the All Table Controls in this controller via these methods.
//

#pragma mark TABLE 
//
- (int) numberOfRowsInTableView:(NSTableView*) thetableView
{
	NSLog(@"LoadDataSetController: numberOfRowsInTableView" );
	
    if ( thetableView == tableView )
    {
		FileDataSource* loadedSource = [ self content ];
		return [ loadedSource.data count ];
    }
    
    return 0; 
}

- (void) updateTableView
{
	NSLog(@"LoadDataSetController: updateTableView" );

    // Tell the DataSet to update itself.
    //
    [ tableView reloadData];
    
    return;
}

- (id) tableView:(NSTableView* ) theTableView
objectValueForTableColumn:(NSTableColumn*) tableColumn
			 row:(int) rowIndex
{
	NSLog(@"LoadDataSetController: tableView" );

    // Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	FileDataSource* loadedSource = [ self content ];
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
			   row:(int) rowIndex
{        
	NSLog(@"LoadDataSetController: tableView" );

	// Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	FileDataSource* loadedSource = [ self content ];
	
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


/*

 */


@end



