//
//  GraphPlotController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 19/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "GraphPlotController.h"

#import "DataSet.h"
#import "Graph.h"

@implementation GraphPlotController

// Initialisation 
//
- (void) setDataSetArray: (NSMutableArray*) sets
{
    plotDataSets = sets;

    return;
}

// Implement the Data Set Table Controls in this controller via these methods.
//
- (int) numberOfRowsInTableView:(NSTableView*) theTableView
{
    return [ plotDataSets count];
}

- (id) tableView:(NSTableView* ) theTableView
	     objectValueForTableColumn:(NSTableColumn*) tableColumn
	     row:(int) rowIndex
{
    // Get the column identifier.
    NSString* identifier = [ tableColumn identifier];    
    DataSet* selectedSet = [ plotDataSets objectAtIndex:rowIndex];

    if ( [ identifier compare:@"plot" ] == 0 )
    {
	Graph* selectGraph = [ self content];
	if ( [ selectGraph containsDataSet:selectedSet] != nil)
	     return [ NSNumber numberWithBool:YES];
	else
	     return [ NSNumber numberWithBool:NO];

	}
    else
	return [ selectedSet name];	
}

- (void) tableView:(NSTableView *) theTableView
    setObjectValue:(id) anObject
    forTableColumn:(NSTableColumn*) tableColumn
	       row:(int) rowIndex
{
    // Get the column identifier.
    NSString* identifier = [ tableColumn identifier];    
    DataSet* selectedSet = [ plotDataSets objectAtIndex:rowIndex];
    
    if ( [ identifier compare:@"plot" ] == 0 )
    {
	Graph* selectGraph = [ self content];
	
	[ selectGraph setDataSetToPlot:selectedSet
			        select: [ anObject boolValue] ];
    }
    
    return;
}

@synthesize selectDataSetsToPlotTable;
@synthesize plotDataSets;
@synthesize graphsInTabViews;
@end
