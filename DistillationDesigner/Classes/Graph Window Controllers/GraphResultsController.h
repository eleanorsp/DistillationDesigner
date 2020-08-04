//
//  GraphResultsController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 19/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GraphResultsController : NSArrayController 
{
    IBOutlet NSTableView* selectDataSetsToPlotTable;
    IBOutlet NSObjectController* graphController; // Gets the Selected Graph
    
    // Graph* selectedGraph found in content.
    NSMutableArray* graphsInTabViews;
    NSMutableArray* plotDatasets;   
}

// Implement the Data Set Table Controls in this controller via these methods.
//
//- (int) numberOfRowsInTableView:(NSTableView*) theTableView;
//- (id) tableView:(NSTableView* ) theTableView
//	     objectValueForTableColumn:(NSTableColumn*) tableColumn
//	     row:(int) rowIndex;

//- (void) tableView:(NSTableView *) theTableView
//    setObjectValue:(id) anObject
//    forTableColumn:(NSTableColumn*) tableColumn
//	       row:(int) rowIndex;


@property (retain) NSMutableArray* plotDatasets;
@property (retain) NSMutableArray* graphsInTabViews;
@property (retain) NSTableView* selectDataSetsToPlotTable;
@property (retain) NSObjectController* graphController;
@end
