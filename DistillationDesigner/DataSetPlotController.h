//
//  DataSetPlotController.h
//  DistillationDesigner
//
//  Created by Martin Spenceley on 19/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Graph.h"
#import "TwoDPlotInformation.h"

@interface DataSetPlotController : NSObjectController 
{
    // Content is the DataPlotInformation.
    //
    IBOutlet NSTableView* dataSetTableView;
    IBOutlet NSPopUpButton* xDimensionPopupButton;
    IBOutlet NSPopUpButton* yDimensionPopupButton;
    IBOutlet NSPopUpButton* zDimensionPopupButton;
    
    Graph* selectedGraph;
    int selectedRow;
    
    TwoDPlotInformation* selectedDataPlotInfo;
    
    NSMutableArray* localDimensions;
}

// Action Methods
- (IBAction) selectDataSetPlotInfo: (id) sender;

//
// Associate the selected graph with the controller.
//
- (void) setupSelectedGraph: (Graph*) graph;

- (TwoDPlotInformation*) selectedDataPlotInfo;

//
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

@property (retain) NSPopUpButton* yDimensionPopupButton;
@property (retain) NSPopUpButton* xDimensionPopupButton;
@property (retain) NSPopUpButton* zDimensionPopupButton;
@property (assign,setter=setupSelectedGraph:) Graph* selectedGraph;
@property (retain,getter=selectedDataPlotInfo) TwoDPlotInformation* selectedDataPlotInfo;
@property (retain) NSTableView* dataSetTableView;
@property int selectedRow;
@property (retain) NSMutableArray* localDimensions;
@end
