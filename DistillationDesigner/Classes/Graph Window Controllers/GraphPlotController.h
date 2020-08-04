//
//  GraphPlotController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 19/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GraphPlotController : NSObjectController 
{
    IBOutlet NSTableView* selectDataSetsToPlotTable;
    
    // Graph* selectedGraph found in content.
    NSMutableArray* graphsInTabViews; // Allow subset selection.
    NSMutableArray* plotDataSets;     // Data sets that can be plotted. 
}

// Initialisation 
//
- (void) setDataSetArray: (NSMutableArray*) sets;

// Implement the Data Set Table Controls in this controller via these methods.
//
- (int) numberOfRowsInTableView:(NSTableView*) theTableView;
- (id) tableView:(NSTableView* ) theTableView
	     objectValueForTableColumn:(NSTableColumn*) tableColumn
	     row:(int) rowIndex;

- (void) tableView:(NSTableView *) theTableView
    setObjectValue:(id) anObject
    forTableColumn:(NSTableColumn*) tableColumn
	       row:(int) rowIndex;

@property (retain) NSMutableArray* graphsInTabViews;
@property (retain) NSMutableArray* plotDataSets;
@property (retain) NSTableView* selectDataSetsToPlotTable;

@end
