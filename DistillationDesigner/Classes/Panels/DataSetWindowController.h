//
//  DataSetController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 06/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DataSet.h"
#import "ManualDataSetController.h"
#import "LoadDataSetController.h"
#import "ConstantRelativeVolatilityController.h"

//
// KVO
#define ObsKey_DataSetWindow_SelectedDataSet @"selectedDataSet"

@interface DataSetWindowController : NSWindowController <NSTableViewDelegate>
{
    IBOutlet NSPanel* dataSetPanel;
    IBOutlet NSTableView* dataSetTableView;
    IBOutlet NSPopUpButton* dataSourcePopup;
    
    IBOutlet NSTabView* dataSourceView;
    
    // Data source from file load.
    IBOutlet NSTableView* dataSourceTableView;
    IBOutlet NSTextField* fileNameTextField;
    IBOutlet NSButton* browseFilesButton;
	IBOutlet NSButton* applyButton;
    
    // Manual Entry Data source.
    IBOutlet ManualDataSetController* manualDataSetController;
    IBOutlet LoadDataSetController* loadDataSetController;
    IBOutlet ConstantRelativeVolatilityController* relativeVolatilityController;
    
    NSMutableArray* datasets;
    DataSet* selectedDataSet;  // Local selected data set.
	
	BOOL isStandalone;
}

#pragma mark INITIALISE 
//
// Initialisation 
//
- (id) initUsingDataSet: (NSMutableArray*) sets;

#pragma mark IB_ACTION
// Action Methods
//
// - (IBAction) initialiseDataSourceOption: (id) sender;
- (IBAction) setDataSourceOption: (id) sender;
- (IBAction) addDataSet: (id) sender;
- (IBAction) deleteDataSet: (id) sender;
- (IBAction) importDataSet: (id) sender;
- (IBAction) addRelativeVolatilityDataset: (id) sender;
- (IBAction) downloadData: (id) sender;

- (IBAction) closeDataControllerSheet: (id) sender;
- (IBAction) reloadDataSet: (id) sender; // Clear the existing dataset with the reloaded one.
- (IBAction) showDataSetHelp: (id) sender;

#pragma mark DATA_SET_MANAGMENT

// Checks to see if we alrady have this dataset loaded if so, give the user a chance to use the
// existing dataset else rename this new dataset to something unique.
//
- (void) manageNewDatasetFrom: (NSDocument*) currentDocument;
//
// Return method from an alert generated from the above routine.
//
- (void) alertExistingDatasetDidEnd: (NSAlert *) alert 
						 returnCode:(int)returnCode 
						contextInfo:(void *)contextInfo;

//
// Updates from the DataSet changes downwards...
//
- (void) updateFromDataSet;
- (void) showSelectedDataSourcePanel;


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

// Delegate Methods
//
- (BOOL)tableView:(NSTableView *) aTableView shouldSelectRow:(NSInteger)rowIndex;

#pragma mark PROPERTIES
//
@property (retain) NSPopUpButton* dataSourcePopup;
@property (retain) NSMutableArray* datasets;
@property (retain) NSTabView* dataSourceView;
@property (retain) NSButton* browseFilesButton;
@property (retain) NSTableView* dataSetTableView;
@property (retain) NSTableView* dataSourceTableView;
@property (retain) ManualDataSetController* manualDataSetController;
@property (retain) DataSet* selectedDataSet;
@property (retain) NSPanel* dataSetPanel;
@property (retain) NSTextField* fileNameTextField;
@property BOOL isStandalone;

@end
