//
//  McCabeThieleAppController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 02/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PreferencesController.h"
#import "DonateWindowController.h"
#import "DataSetWindowController.h"

//
// KVO
#define ObsKey_AppDelegate_sharedDatasets @"sharedDatasets"


@interface McCabeThieleAppController : NSObject 
{
	PreferencesController* prefController;
	DonateWindowController* donateWindowController;
	DataSetWindowController* dataSetWindowController;
	
    NSMutableArray* sharedDatasets;
}

@property (readonly) NSMutableArray* sharedDatasets;

//
// Actions
//
//
// Display the preferences panel for the application.
//
- (IBAction) showPreferencesPanel: (id) sender;
- (IBAction) showDatasetsPanel: (id) sender;
- (IBAction) importDataset: (id) sender;

// Zoom In the current graph.
//
- (IBAction) zoomIn: (id) sender;
- (IBAction) zoomOut: (id) sender;

//
// Methods
//
- (void) prepareExportDatasetSubMenu;

//
// Global Methods
//

//
// Generate a unique Data Set Name.
//
+ (NSString*) createUniqueDataSetName: (NSString*) setName;

@end
