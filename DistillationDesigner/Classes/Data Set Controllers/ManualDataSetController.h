//
//  ManualDataSetController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 09/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ManualDataSetController : NSObjectController 
{
    IBOutlet NSTableView* tableView;
    IBOutlet NSButton* addDataButton;
    IBOutlet NSButton* deleteDataButton;
    IBOutlet NSFormatter* temperatureFormatter;
    IBOutlet NSFormatter* compositionFormatter;

	IBOutlet NSPanel* mainPanel; 

	// IB Defined
	//
	// xColumnData
	// yColumnData
	
    // Keep hold of the keys in an array to ensure
    // array consistency.
    //
    NSArray* sourceKeys;
    int numberDimensions;
}

#pragma mark IB_ACTIONS 
//
// Actions
//
- (IBAction) headerNameUpdated: (id) sender;
- (IBAction) selectedTableRow: (id) sender;

- (IBAction) addDataRow: (id) sender;
- (IBAction) deleteDataRow: (id) sender;
- (IBAction) exportData: (id) sender;

//- (IBAction) moveRow: (id) sender;

// Overwritten Methods
//
- (void)setContent:(id) content;

#pragma mark TABLE 
//
// Class Methods.
//
- (void) initialiseTableView;
- (void) updateTableView;

// Implement the Manual Data Source Table Controls in this controller via these methods.
//
- (int) numberOfRowsInTableView:(NSTableView*) theTableView;
- (id) tableView:(NSTableView* ) theTableView
	     objectValueForTableColumn:(NSTableColumn*) tableColumn
	     row:(int) rowIndex;

- (void) tableView:(NSTableView *) theTableView
    setObjectValue:(id) anObject
    forTableColumn:(NSTableColumn*) tableColumn
	       row:(int) rowIndex;

#pragma mark PROPERTIES  
//
@property (retain) NSArray* sourceKeys;
@property (retain) NSFormatter* temperatureFormatter;
@property (retain) NSFormatter* compositionFormatter;
@property (retain) NSButton* addDataButton;
@property int numberDimensions;
@property (retain) NSButton* deleteDataButton;
@property (retain) NSTableView* tableView;
@end
