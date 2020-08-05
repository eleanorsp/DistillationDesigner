//
//  McCabeThieleDocument.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 20/09/2004.
//  Copyright Crumpets Farm 2004 . All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import "McCabeGraphView.h"
#import "McCabeThiele.h"
#import "OptimalMcCabeThiele.h"
#import "BinaryComponents.h"

#import "DataSetWindowController.h"
#import "GraphPlotController.h"
#import "QLineWindowController.h"
#import "PrintPanelViewController.h"

@interface McCabeThieleDocument : NSDocument
{
	// Composition Items.
	//
	IBOutlet NSScrollView* compositionScrollView;
	
	// Specification Items.
    IBOutlet NSButton* mcCabeThielePlotButton;
	IBOutlet NSButton* qlineCalculateButton;
	IBOutlet NSButton* defineQlineButton;
	
	IBOutlet NSPopUpButton* dataSourcePopupMenu;
	
	IBOutlet NSTabView* mainTabView;
    IBOutlet NSTabViewItem*	mcCabeThieletabView;
	IBOutlet NSScrollView *mcCabeScrollview;
	
	// Component Textfields
	//
	IBOutlet NSTextField* topCompTextField;
	IBOutlet NSTextField* bottomCompTextField;
	IBOutlet NSTextField* feedCompTextField;
	IBOutlet NSTextField* errorMessageTextField;
	IBOutlet NSTextField* minRatioTextField; 
	IBOutlet NSTextField* optimalFactorTextField;
	
	IBOutlet NSPopUpButton* displayUnitPopupMenu;
	IBOutlet NSTextField* topUnitLabel;
	IBOutlet NSTextField* feedUnitLabel;
	IBOutlet NSTextField* bottomUnitLabel;
	
	// Optimisation Items
	IBOutlet NSButton* optimalMcCabePlotButton;
	IBOutlet NSTextField* minRefluxFactor;
	IBOutlet NSTextField* maxRefluxFactor;
	IBOutlet NSButton* totalRefluxButton;
	
	IBOutlet NSTabViewItem*	optimiseTabView;
	IBOutlet NSScrollView *optimiseScrollview;
	
    // NIB Items
    IBOutlet GraphPlotController* mcCabeGraphController;
	IBOutlet GraphPlotController* optimumGraphController;
	IBOutlet GraphPlotController* compositionGraphController;
	
    IBOutlet DataSetWindowController* dataSetWindowController;
	IBOutlet QLineWindowController* qlineWindowController;
	
	IBOutlet PrintPanelViewController* printPanelViewController;
	
	IBOutlet NSArrayController* dataController;
	
	// The graphs
	//
	IBOutlet BinaryComponents* binaryComponents;
	IBOutlet McCabeThiele* mcCabeThiele;
	IBOutlet OptimalMcCabeThiele* optimalCabeThiele;
	
	// The views
	//
	GraphView* binaryComponentsGraphView;
	McCabeGraphView* mcCabeThieleGraphView;
	GraphView* optimalGraphView;
	
	NSSize viewSize;
	// 
	Boolean stagesCanBeCalculated;
	Boolean showMinRefluxAlert;
	
    // Data of the document.
    //
    NSMutableArray* datasets;
	NSString* selectedComponent;
    
    NSFontManager* fontManager;
}

#pragma mark INITIALISE 
//
// Initialise/Set up Methods
//
- (McCabeGraphView*) addMcCabeGraphView: (McCabeThiele*) itsGraph;
- (GraphView*) addOptimalGraphView: (OptimalMcCabeThiele*) graph;
- (GraphView*) addBinaryComponentsGraphView: (BinaryComponents*) binaryComponentGraph;

#pragma mark IB_ACTION 
//
// Action Methods
//
- (IBAction) plotBoilingPointGraph: (id) sender;
- (IBAction) plotMcCabeThieleGraph: (id) sender;
- (IBAction) showDataSetPanel: (id) sender;
- (IBAction) showQLinePanel: (id) sender;
- (IBAction) updateFractionalComposition: (id) sender;

- (IBAction) updateSelectedDataSource: (id) sender;
- (IBAction) zoomIn: (id) sender;
- (IBAction) zoomOut: (id) sender;
- (IBAction) calculateMinRefluxRatio: (id) sender;

- (IBAction) startMinRefluxRatio: (id) sender;
- (void) defineMinumumRefluxDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;

// Calculates the stages between the predefined reflux range.
- (IBAction) plotOptimalRefluxGraph: (id) sender;

// Update the view to the selected units.
//
- (IBAction) displayUnitDidChange: (id) sender;

// Update the McCabeArtifacts in a graphical way.
//
- (IBAction) updateMcCabeArtifacts: (id) sender;
- (IBAction) updateMinReflux: (id) sender;

// Setup routine to start manually dragging the min reflux line.
- (void) initiateManualSettingOfMinimumReflux;

// Help
- (IBAction) showCompositionHelp: (id) sender;
- (IBAction) showRminRefluxHelp: (id) sender;

#pragma mark LOAD_SAVE 
//
// Saving Information to persistent storage
//
// Document Saving and Loading Routines
//
- (NSData *) dataOfType:(NSString *)typeName error:(NSError **) outError;

// Loading Data.
//
// Sets the contents of this document by reading from data of a specified type and returns YES if successful.
- (BOOL) readFromData:(NSData *)data 
			   ofType:(NSString *)typeName 
				error:(NSError **)outError;


#pragma mark NOTIFICATION 
//
// Notification Methods.
//
- (void) dataSetUpdated: (NSNotification*) notification;
//
// Update if the qLine is updated else where.
//
- (void) qLineUpdated: (NSNotification*) notification;
//
// For TextFields.
- (void) controlTextDidChange:(NSNotification *)aNotification;

#pragma mark PRINTING
- (void) printShowingPrintPanel:(BOOL)showPanels;


#pragma mark UNDO 
// 
// Undo methods
//
- (void) startObservingMcCabeThiele: (McCabeThiele* ) observedMcCabeThiele;
- (void) stopObservingMcCabeThiele: (McCabeThiele* ) observedMcCabeThiele;
- (void) startObservingOptimumMcCabeThiele: (OptimalMcCabeThiele* ) observedOptimumMcCabeThiele;
- (void) stopObservingOptimumMcCabeThiele: (OptimalMcCabeThiele* ) observedOptimumMcCabeThiele;

// The route which is called when observing.
//
- (void) observeValueForKeyPath: (NSString* ) keyPath ofObject: (id) object
						 change: (NSDictionary* ) change
						context: (void* ) context;

// The routine which will force the Undo.
//
- (void) changeKeyPath: (NSString* ) keyPath ofObject: (id) object
			   toValue: (id) newValue;

#pragma mark DELEGATE

// Delegate for the NSFormatters
//
- (BOOL) control: (NSControl *) control didFailToFormatString: (NSString * ) stringPtr errorDescription: (NSString*) error;
//
// Alert sheet did end.
- (void) formattingErrorExistingDatasetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo;


#pragma mark GETS_SETS
//
//- (void) setSelectedDataSet: (DataSet*) dataset;
//- (DataSet*) getSelectedDataSet;

#pragma mark PROPERTIES
//
// @property (retain) GraphPlotController* graphController;
@property (retain) NSButton* mcCabeThielePlotButton;
@property (retain) DataSetWindowController* dataSetWindowController;
@property (retain) NSMutableArray* datasets;
@property (retain) McCabeThiele* mcCabeThiele;
@property (retain) OptimalMcCabeThiele* optimalCabeThiele;

@property (retain) NSFontManager* fontManager;
@property (retain) NSString* selectedComponent;

@property Boolean stagesCanBeCalculated;


@end
