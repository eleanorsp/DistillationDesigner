//
//  ManualDataSetController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 09/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "ManualDataSetController.h"

#import "FileDataSource.h"
#import "DataSource.h"
 

@implementation ManualDataSetController

#pragma mark INITIALISE 

- (void)setContent:(id)content
{
	NSLog(@"ManualDataSetController: setContent" );

    [ super setContent:content ];
    
    // Initialise Table Columns.
    [ self initialiseTableView ];
	
}

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
		[ headerCell setSelectable:YES];
		[ headerCell setEditable:YES ];
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
- (IBAction) selectedTableRow: (id) sender
{
	NSLog(@"ManualDataSetController: selectedTableRow" );

    NSInteger selectedRow = [ tableView selectedRow];
    
    bool enable = ( selectedRow >= 0 );
    [ deleteDataButton setEnabled:enable];
//    [ columnNameTextField setEditable:enable];
    
    return;
}

- (IBAction) headerNameUpdated: (id) sender
{
    return;
}

- (IBAction) addDataRow: (id) sender
{
	NSLog(@"ManualDataSetController: addDataRow" );

    [ [ self content] addNewRow ];
    [ self updateTableView];
    
    return;
}

//
// Removes the selected data row.
//
- (IBAction) deleteDataRow: (id) sender
{
	NSLog(@"ManualDataSetController: deleteDataRow" );

    int selectedRow = [ tableView selectedRow];
    
    if ( selectedRow < 0 )
		return; // Nothing selected.
    
    [ [ self content] deleteRow:selectedRow ];
    [ self updateTableView];
    
    return;
}

//
// Export the current data to a file for sharing
//
- (IBAction) exportData: (id) sender
{
	NSLog(@"ManualDataSetController: exportData:" );
	
	NSSavePanel* savePanel = [ NSSavePanel savePanel ];
	
	/* set up new attributes */
	[ savePanel setRequiredFileType: @"data" ];
	
	/* display the NSSavePanel */
	[ savePanel beginSheetModalForWindow:  mainPanel
					   completionHandler:
		^(NSInteger result) 
		{
			if (result == NSFileHandlingPanelOKButton) {
			   /* if successful, save file under designated name */
			   if (result == NSFileHandlingPanelOKButton ) 
			   {
				   @try 
				   {
					   DataSource* dataSource = [ self content];
					   [ dataSource exportDataFile: [ savePanel URL ] ];
				   }
				   @catch (NSException* exception )
				   {
					   // Deal with the error like a bad formatting issue.
					   //
					   NSAlert *alert = [[NSAlert alloc] init];
					   [alert addButtonWithTitle: NSLocalizedString( @"Okay", @"" ) ];
					   
					   NSString* message = [ NSString stringWithString: NSLocalizedString( @"Unable to export the data to a file", @"" ) ];
					   [alert setMessageText: message ];
					   [alert setInformativeText: [ exception reason ] ];
					   [alert setAlertStyle: NSCriticalAlertStyle ];
					   [ alert runModal ];	   
				   }
			   }
			}
		} ];
	
	return;
}

#pragma mark TABLE 
//
// Implement the All Table Controls in this controller via these methods.
//
- (int) numberOfRowsInTableView:(NSTableView*) thetableView
{
	NSLog(@"ManualDataSetController: numberOfRowsInTableView" );

    if ( thetableView == tableView )
    {
		DataSource* manualSource = [ self content ];
		return [ manualSource.data count ];
    }
    
    return 0; 
}

- (void) updateTableView
{
    // Tell the DataSet to update itself.
    //
    [ tableView reloadData];
    
    return;
}

- (id) tableView:(NSTableView* ) theTableView
	     objectValueForTableColumn:(NSTableColumn*) tableColumn
	     row:(int) rowIndex
{
	NSLog( @"ManualDataSetController: tableView: objectValueForTableColumn: row:" );

    // Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	// DataSource* dataSource = [ self content ];
	if ( [ identifier compare: @"Temperature °C" ] == 0 )
		arrayIndex = 2;
	else if ( [ identifier compare: @"In Vapour Phase (y)" ] == 0 )
		arrayIndex = 1;
	
	// Get the information.
    if ( theTableView == tableView )
    {
		DataSource* dataSource = [ self content];
		NSArray* array = [ dataSource.data objectAtIndex:rowIndex ];     
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
	NSLog( @"ManualDataSetController: tableView: setObjectValue: forTableColumn: row:" );

     // Get the column identifier.
	int arrayIndex = 0;
    NSString* identifier = [ tableColumn identifier];
	DataSource* dataSource = [ self content ];

	if ( [ identifier compare: @"Temperature °C" ] == 0 )
		arrayIndex = 2;
	else if ( [ identifier compare: @"In Vapour Phase (y)" ] == 0 )
		arrayIndex = 1;
		    
    // Get the information.
    if ( theTableView == tableView )
    {
		NSMutableArray* data = dataSource.data;
		NSMutableArray* array = [ data objectAtIndex:rowIndex ];     
		
		[ array replaceObjectAtIndex:arrayIndex withObject: anObject]; 
    }
    
    return;
}

#pragma mark PROPERTIES
//
@synthesize deleteDataButton;
@synthesize numberDimensions;
@synthesize addDataButton;
@synthesize tableView;
@synthesize temperatureFormatter;
@synthesize compositionFormatter;
@synthesize sourceKeys;
@end
