//
//  McCabeThieleDocument.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 20/09/2004.
//  Copyright Crumpets Farm 2004 . All rights reserved.
//

#import "McCabeThieleDocument.h"
#import "McCabeThielePrintView.h"

#import "McCabeThieleAppController.h"

#import "AxisStateTransformer.h"
#import "GraphBackgroundTransformer.h"
#import "HasCalculatedStages.h"
#import "NegateHasCalculatedStages.h"

@implementation McCabeThieleDocument

NSString *suppressManualRefluxRatioAlert = @"suppressManualRefluxRatioAlert";

#pragma mark INITIALISE 
// 
// Initialise Methods
//
- (id)init
{
    self = [super init];
    if (self) 
	{			
		NSValueTransformer *transformer = [[AxisStateTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"AxisStateTransformer"];
		
		transformer = [[GraphBackgroundTransformer alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"GraphBackgroundTransformer"];
	
		transformer = [[HasCalculatedStages alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"HasCalculatedStages"];

		transformer = [[NegateHasCalculatedStages alloc] init];
		[NSValueTransformer setValueTransformer:transformer forName:@"NegateHasCalculatedStages"];
		
		viewSize.height = 600;
		viewSize.width = 600;
		stagesCanBeCalculated = NO;
		
		// Assume this will not change.
		//
		McCabeThieleAppController* mcCabeThieleAppDelegate = (McCabeThieleAppController*) [ NSApplication sharedApplication ].delegate;
		datasets = mcCabeThieleAppDelegate.sharedDatasets;
		showMinRefluxAlert = NSOffState;
	}
	
    return self;
}

- (void) finalize
{
	if ( mcCabeThiele != nil )
		[ self stopObservingMcCabeThiele: mcCabeThiele ];
	if ( optimalCabeThiele != nil )
		[ self stopObservingOptimumMcCabeThiele: optimalCabeThiele ];
	
    [super finalize];
}


- (NSString *) windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"McCabeThieleDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	NSLog(@"McCabeThieleDocument: windowControllerDidLoadNib:" );

    [super windowControllerDidLoadNib:aController];
    
	if ( mcCabeThiele == nil )
	{
		mcCabeThiele = [ [ McCabeThiele alloc ] init ];
		
		// Add the Undo stuff.
		//
		// [ self startObservingMcCabeThiele:mcCabeThiele ];
		
		optimalCabeThiele = [ [ OptimalMcCabeThiele alloc ] initWithMcCabeThiele:mcCabeThiele ];
		binaryComponents = [ [ BinaryComponents alloc ] initWithMcCabeThiele: mcCabeThiele ];
	}
	
	[ dataController setContent: datasets ];

    // Add any code here that needs to be executed once the windowController has loaded the document's window
	mcCabeThieleGraphView = [ self addMcCabeGraphView: mcCabeThiele ];
    [ mcCabeGraphController setContent:mcCabeThiele ];

	// Keep the Bounds information.
    [ mcCabeThieleGraphView setFrameSize: viewSize ];
    // Reapply the bounds.
    [ mcCabeThieleGraphView setBoundsSize: mcCabeThieleGraphView.graphScale ];
    [ mcCabeThieleGraphView setNeedsDisplay:TRUE ];
	
	// Now the other graph
	optimalGraphView = [ self addOptimalGraphView: optimalCabeThiele ];
	[ optimumGraphController setContent:optimalCabeThiele ];
	
    // Keep the Bounds information.
    [ optimalGraphView setFrameSize: viewSize ];
    // Reapply the bounds.
    [ optimalGraphView setBoundsSize: mcCabeThieleGraphView.graphScale ];
    [ optimalGraphView setNeedsDisplay:TRUE ];
	
	// and the binary component graph.
	binaryComponentsGraphView = [ self addBinaryComponentsGraphView: binaryComponents ];
	[ compositionGraphController setContent:binaryComponents ];
	// Keep the Bounds information.
    [ binaryComponentsGraphView setFrameSize: viewSize ];
    // Reapply the bounds.
    [ binaryComponentsGraphView setBoundsSize: mcCabeThieleGraphView.graphScale ];
    [ binaryComponentsGraphView setNeedsDisplay:TRUE ];
	
	// Update the PopupMenu.
	[ dataSourcePopupMenu removeAllItems ];
	[ dataSourcePopupMenu setEnabled:NO ];

	// Associate the datasets with their very own controller.
	//	
    NSNotificationCenter* notificationCentre = [NSNotificationCenter defaultCenter ];
    [ notificationCentre addObserver:self 
			    selector:@selector(dataSetUpdated:) 
				name:@"DataSetsUpdated"
			      object:nil ];
	
	[ notificationCentre addObserver:self 
							selector:@selector(qLineUpdated:) 
								name:@"qLineDefined"
							  object:nil ];
	
	if ( [ self isDocumentEdited ] == YES )
	{
		// Force an update of all the graphics/lines.
		[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];
		[ optimalGraphView setNeedsDisplay: TRUE ];
	}
		
	[ self updateMcCabeArtifacts: self ];
	[ self displayUnitDidChange: self ];

	// Add the Undo stuff.
	//
	[ self startObservingMcCabeThiele:mcCabeThiele ];
	[ self startObservingOptimumMcCabeThiele: optimalCabeThiele ];
	
    return;
}


#pragma mark LOAD_SAVE 
// 
// Load and Save Functions.
//
//
// Saving Data.
//
- (NSData *) dataOfType:(NSString *)typeName error:(NSError **) outError
{
	NSLog(@"McCabeThieleDocument: dataOfType: error:" );

	*outError = nil;
	
    NSMutableData *data = [[NSMutableData alloc] init];
	
    NSKeyedArchiver *archiver;
	archiver = [[NSKeyedArchiver alloc]
				initForWritingWithMutableData: data];
    [archiver setOutputFormat: NSPropertyListXMLFormat_v1_0 ];

	[archiver encodeObject: mcCabeThiele.selectedDataSet  forKey: @"selectedDataSet" ];
    [archiver encodeObject: mcCabeThiele  forKey: @"mcCabeThiele"];
	[archiver encodeObject: optimalCabeThiele  forKey: @"optimalCabeThiele" ];

    [archiver finishEncoding];
	
	// Creating an NSError object is optional. If you do choose to create one, fill it with more
	// detailed information about what went wrong. Cocoa can infer that an NSData object
	// could not be created, from the fact that this method returns nil. What the NSError does
	// is give you a chance to show *why* it couldn't be created.
	
	// It's actually rather pointless in this demo, as NSKeyedArchiver didn't tell us why it
	// returned nil. Still, it illustrates how to return more  detailed info, should such info be
	// available to begin with.
	
	// See NSError docs for details
	/*
	NSDictionary *errorDictionary = [NSDictionary
									 dictionaryWithObject:@"Failed to create keyed archive for unknown reason."
									 forKey:NSLocalizedDescriptionKey];
	
	*error = [NSError errorWithDomain:@"invalid.whatever" code:-1 userInfo:errorDictionary];
	*/
    return data;	
}



// Loading Data.
// Sets the contents of this document by reading from data of a specified type and returns YES if successful.
//
- (BOOL) readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{	
	NSLog(@"McCabeThieleDocument: readFromData: ofType: error:" );

    NSKeyedUnarchiver* keyedUnarchiver = [ [ NSKeyedUnarchiver alloc ] initForReadingWithData:data];
	
	*outError = nil;
	
    // graphsInTabViews = [ fileData valueForKey:@"graphsInTabViews" ];    
	@try
	{
		McCabeThiele* tempMcCabeThiele;
		OptimalMcCabeThiele* tempOptimalCabeThiele;
		DataSet* tempDataset;
		
		tempDataset = [keyedUnarchiver decodeObjectForKey: @"selectedDataSet"];
		tempMcCabeThiele = [keyedUnarchiver decodeObjectForKey: @"mcCabeThiele"];
		tempOptimalCabeThiele = [ keyedUnarchiver decodeObjectForKey: @"optimalCabeThiele" ];
		tempOptimalCabeThiele.actualMcCabeThiele = tempMcCabeThiele;
	
		// Now remove the existing data.
		//
		[ self stopObservingMcCabeThiele: mcCabeThiele ];
		[ self stopObservingOptimumMcCabeThiele: optimalCabeThiele ];

		// Transfer the loaded to the managed data objects within the Document.
		//
		mcCabeThiele = tempMcCabeThiele;
		optimalCabeThiele = tempOptimalCabeThiele;
		binaryComponents = [ [ BinaryComponents alloc ] initWithMcCabeThiele: tempMcCabeThiele ];
		
		// Update the Views and Controllers with the new data.
		//
		mcCabeThieleGraphView.itsGraph = mcCabeThiele;
		[ mcCabeGraphController setContent: mcCabeThiele ];
		
		optimalGraphView.itsGraph = optimalCabeThiele;
		[ optimumGraphController setContent: optimalCabeThiele ];
		
		binaryComponentsGraphView.itsGraph = binaryComponents;
		[ compositionGraphController setContent:binaryComponents ];
				
		// Set the existing data with the undo.
		//
		[ self startObservingMcCabeThiele: mcCabeThiele ];
		[ self startObservingOptimumMcCabeThiele: optimalCabeThiele ];
		
		
		// Check if the imported Dataset already exists
		//
		BOOL found = NO;
		for ( DataSet* loadedSet in datasets )
		{
			if ( [ loadedSet.name compare: tempDataset.name ] == NSOrderedSame )
			{
				// Find out if the user want to use the existing data set or
				// add this as a 'new' dataset.
				//
				NSAlert *alert = [[NSAlert alloc] init];
				[alert addButtonWithTitle:@"Load Dataset"];
				[alert addButtonWithTitle:@"Use existing Dataset"];
				
				NSString* message = [ NSString stringWithFormat:@"Data Set being loaded: %@, already exists.", loadedSet.name ];
				[alert setMessageText:message ];
				[alert setInformativeText:@"Do you wish to load the dataset as new or use the existing data set with this design?"];
				[alert setAlertStyle:NSInformationalAlertStyle];
				
				NSInteger returnValue = [ alert runModal ];
				if ( returnValue == NSAlertFirstButtonReturn  )
				{
					NSString* uniqueDatasetName = [ McCabeThieleAppController createUniqueDataSetName: tempDataset.name ];
					tempDataset.name = uniqueDatasetName;
	
					[ self.datasets addObject:tempDataset ];
					
					mcCabeThiele.selectedDataSet = tempDataset;
				}
				else
				{
					mcCabeThiele.selectedDataSet = loadedSet;
				}
				
				found = YES;
				break; // From for loop.
			}
		}
		
		if ( found == NO )
			[ self.datasets addObject: tempDataset ];
	 }
	 @catch (id anError)
	 {
		 *outError = [NSError errorWithDomain:NSCocoaErrorDomain code:1 userInfo: [anError userInfo]];
		 
		 return NO;
	 }
  
//	[ self updateChangeCount: NSChangeReadOtherContents ];
	[ self updateMcCabeArtifacts: self ];
//	[ self updateOptimumMcCabeArtifacts: self ];

	
    return YES;
}


#pragma mark IB_ACTION 
//
// Action Methods
//
- (IBAction) updateSelectedDataSource: (id) sender
{
	NSLog(@"McCabeThieleDocument: updateSelectedDataSource:" );

	DataSource* selectedSource = [ mcCabeThiele.selectedDataSet selectedSource ];

	[ dataSourcePopupMenu removeAllItems ];
	
	if ( selectedSource != nil )
	{
		NSArray* componentTitles = [ selectedSource allColumnData ];
		[ dataSourcePopupMenu addItemsWithTitles: componentTitles ];
		[ dataSourcePopupMenu selectItemAtIndex: 0 ];
		selectedComponent = [ componentTitles objectAtIndex:0 ];
		
		[ dataSourcePopupMenu setEnabled:YES ];
	}
	else
		[ dataSourcePopupMenu setEnabled:NO ];

	// Make sure the graph knows about the change.
	//
	// 
	[ mcCabeThiele updateAllUndisplayedFractions ];
	
	// Update the view.
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];  
	[ binaryComponentsGraphView setNeedsDisplay:TRUE ];  

	if ( [ selectedSource hasMolWeightsDefined ] == NO )
	{
		[ displayUnitPopupMenu setEnabled: NO ];
		[ displayUnitPopupMenu selectItemAtIndex: 0 ];
		[ self displayUnitDidChange: self ];
	}
	
	return;
}

//
// 
// Adds a McCabe Graph View to the Interface
//
- (McCabeGraphView*) addMcCabeGraphView: (McCabeThiele* ) itsGraph
{    
	NSLog(@"McCabeThieleDocument: addMcCabeGraphView:" );

	[ mcCabeScrollview setBackgroundColor: [ NSColor whiteColor ] ];
    // add view
    McCabeGraphView* mcCabeGraphView = [ [McCabeGraphView alloc] initWithFrame: [mcCabeScrollview frame] ];
    [ mcCabeGraphView setBoundsSize: [ mcCabeGraphView graphScale ] ];    

    [mcCabeScrollview setDocumentView: mcCabeGraphView ]; 
    mcCabeGraphView.itsGraph = itsGraph;
    [ mcCabeGraphView setNeedsDisplay:TRUE ];  
    	
    return mcCabeGraphView;
}

// Adds a Generic Graph View to the Interface
//
- (GraphView*) addOptimalGraphView: (OptimalMcCabeThiele* ) itsGraph
{    
	NSLog(@"McCabeThieleDocument: addOptimalGraphView:" );

	[ optimiseScrollview setBackgroundColor: [ NSColor whiteColor ] ];
    // add view
    optimalGraphView = [ [GraphView alloc] initWithFrame: [optimiseScrollview frame] ];
    [ optimalGraphView setBoundsSize: [ optimalGraphView graphScale ] ];    
	
    [optimiseScrollview setDocumentView: optimalGraphView ]; 
    optimalGraphView.itsGraph = itsGraph;
    [ optimalGraphView setNeedsDisplay:TRUE ];  
	
    return optimalGraphView;
}

// Adds a Generic Graph View for the Binary Component Graph to the Interface
//
- (GraphView*) addBinaryComponentsGraphView: (BinaryComponents*) binaryComponentGraph
{
	NSLog(@"McCabeThieleDocument: addBinaryComponentsGraphView:" );

	[ compositionScrollView setBackgroundColor: [ NSColor whiteColor ] ];

	// add view
	binaryComponentsGraphView = [ [GraphView alloc] initWithFrame: [compositionScrollView frame] ];
	[ binaryComponentsGraphView setBoundsSize: [ binaryComponentsGraphView graphScale ] ];    

	[compositionScrollView setDocumentView: binaryComponentsGraphView ]; 
	binaryComponentsGraphView.itsGraph =  binaryComponentGraph;
	[ binaryComponentsGraphView setNeedsDisplay:TRUE ];  

	return binaryComponentsGraphView;
}



- (IBAction) showDataSetPanel: (id) sender
{
	NSLog(@"McCabeThieleDocument: showDataSetPanel:" );

    // Get the shared Controller used by all documents.
	
    if ( !dataSetWindowController )
    {
		dataSetWindowController = [DataSetWindowController alloc];
		[ dataSetWindowController initUsingDataSet: datasets ];
    }

    [ dataSetWindowController showWindow:self ];
    
    return;
}


- (IBAction) showQLinePanel: (id) sender
{
	NSLog(@"McCabeThieleDocument: showQLinePanel:" );

    if ( !qlineWindowController )
    {
		qlineWindowController = [ [QLineWindowController alloc] initUsingMcCabeThiele: mcCabeThiele ];
    }
	
    [ qlineWindowController showWindow:self ];
    
    return;
}


// Zoom In on the currently selected Graph.
//
- (IBAction) zoomIn: (id) sender
{
	NSLog(@"McCabeThieleDocument: zoomIn:" );

	NSSize currentViewSize; 
	GraphView* currentView;

	if ( [ mainTabView selectedTabViewItem ] == mcCabeThieletabView )
		currentView = mcCabeThieleGraphView;
	else if ( [ mainTabView selectedTabViewItem ] == optimiseTabView )// Its the optimal graph
		currentView = optimalGraphView;
	else
		currentView = binaryComponentsGraphView;

	double zoomFactor = currentView.zoomFactor;
	zoomFactor = zoomFactor * 1.1;
	
	NSRect viewFrame = [  currentView frame ];
	currentViewSize.height = viewFrame.size.height * (zoomFactor/100);
	currentViewSize.width = viewFrame.size.width * (zoomFactor/100);
	// Keep the Bounds information.
	[ currentView setFrameSize:currentViewSize ];
	// Reapply the bounds.
	[ currentView setBoundsSize: currentViewSize ];

	NSRect newRect;
	newRect.size = currentViewSize;
	currentView.itsGraph.plotArea = newRect;
	[ currentView setNeedsDisplay:TRUE ];		

	return;
}

// Zoom Out on the currently selected graph.
//
- (IBAction) zoomOut: (id) sender
{
	NSLog(@"McCabeThieleDocument: zoomOut:" );

	NSSize currentViewSize; 
	GraphView* currentView;
	
	if ( [ mainTabView selectedTabViewItem ] == mcCabeThieletabView )
		currentView = mcCabeThieleGraphView;
	else if ( [ mainTabView selectedTabViewItem ] == optimiseTabView )// Its the optimal graph
		currentView = optimalGraphView;
	else
		currentView = binaryComponentsGraphView;
			
	double zoomFactor = currentView.zoomFactor;
	zoomFactor = zoomFactor * 0.9;
	
	NSRect viewFrame = [  currentView frame ];
	currentViewSize.height = viewFrame.size.height * (zoomFactor/100);
	currentViewSize.width = viewFrame.size.width * (zoomFactor/100);
	// Keep the Bounds information.
	[ currentView setFrameSize:currentViewSize ];
	// Reapply the bounds.
	[ currentView setBoundsSize: currentViewSize ];

	NSRect newRect;
	newRect.size = currentViewSize;
	currentView.itsGraph.plotArea = newRect;
	[ currentView setNeedsDisplay:TRUE ];		

	return;
}

- (IBAction) startMinRefluxRatio: (id) sender
{
	NSLog(@"McCabeThieleDocument: startMinRefluxRatio:" );

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults boolForKey:suppressManualRefluxRatioAlert] ) 
	{
		[ self initiateManualSettingOfMinimumReflux ];
	}
	else
	{
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Okay"];
		
		NSString* message = [ NSString stringWithString:@"Manually set the minimum reflux ratio." ];
		[alert setMessageText:message ];
		[alert setInformativeText:@"Select the red rectifying line and drag it to your chosen minmimum value.\nBut do not cross the equilibrium line before the q-line!"];
		[alert setAlertStyle:NSInformationalAlertStyle];
		[ alert setShowsSuppressionButton: YES ];
		[ alert beginSheetModalForWindow:[ self windowForSheet ] modalDelegate:self didEndSelector:@selector(defineMinumumRefluxDidEnd:returnCode:contextInfo:) contextInfo:nil ];
	}
	
	
	return;
}

// End routine for the Alert.
//
- (void)defineMinumumRefluxDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	NSLog(@"McCabeThieleDocument: defineMinumumRefluxDidEnd: returnCode: contextInfo:" );

	if ([[alert suppressionButton] state] == NSOnState) {
        // Suppress this alert from now on.
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

		[defaults setBool:YES forKey:suppressManualRefluxRatioAlert];
    }
	
	[ self initiateManualSettingOfMinimumReflux ];
	return;
}


// Setup routine manually dragging the min reflux line.
//
- (void) initiateManualSettingOfMinimumReflux
{
	NSLog(@"McCabeThieleDocument: initiateManualSettingOfMinimumReflux" );

	[ mcCabeThiele setMode: DetermineMinimumRefluxMode ];
	
	// Start dragging
	NSString* footerMessage = @"Start Dragging Distilate Line for Minimum Reflux";
	[ errorMessageTextField setStringValue:footerMessage ];
	
	if ([ mcCabeThiele calcRectifyingLine ] == YES )
	{
		CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
		
		[ mcCabeThiele drawRectifyingLine:gc inMode: DetermineMinimumRefluxMode ];
		[ mcCabeThieleGraphView startMinRefluxReview ];
		[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];	
	}
	
	return;
}


// Action for when the user wishes the system to calculate the minimum reflux.
//
- (IBAction) calculateMinRefluxRatio: (id) sender
{
	NSLog(@"McCabeThieleDocument: calculateMinRefluxRatio:" );

	NSUndoManager* undoMgr = [ self undoManager ];
	
	NSNumber *currentValue = [ NSNumber numberWithDouble: [ mcCabeThiele.minRefluxRatio doubleValue ] ];
	[undoMgr registerUndoWithTarget:mcCabeThiele
							   selector:@selector(setMinRefluxRatio:)
							   object:currentValue] ;
							  
	[ undoMgr setActionName:@"Rmin Calculation" ]; 
	
	// Ignore what goes on in the calculation.
	[ undoMgr disableUndoRegistration ];
							  
	if ([ mcCabeThiele calculateMinReflux ] == YES )
	{
		[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];	
	}

	[ undoMgr enableUndoRegistration ];

	[ self updateMinReflux:sender ];
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];	

	return;
}


// If the input data is being entered then we will still need to
// sort out the minimum reflux ratio.
//
- (IBAction) updateMcCabeArtifacts: (id) sender
{		
	NSLog(@"McCabeThieleDocument: updateMcCabeArtifacts:" );

	[ mcCabeThiele setMode: DetermineMinimumRefluxMode ];
	// Reset any results
	mcCabeThiele.theorecticalStages = 0;
	mcCabeThiele.feedPointAtStage = 0;

	NSString* errorString = @"";
	if ( mcCabeThiele.displayFracType == DISPLAY_WEIGHT_WEIGHT && (
		 mcCabeThiele.selectedDataSet.selectedSource.xMolecularWeight == nil ||
		 mcCabeThiele.selectedDataSet.selectedSource.yMolecularWeight == nil ) )
	{
		errorString = [ errorString stringByAppendingString: @"Warning: Component molecular weights not set. " ];	
	}
	else 
	{
		// Check if we have enough data so we can plot the graph.
		//
		if ( [ mcCabeThiele canCalculateQLine ] == NO )
		{
			[ defineQlineButton setEnabled:NO ];
			[ qlineCalculateButton setEnabled:NO ];
		}
		else
		{
			[ qlineCalculateButton setEnabled:YES ];
			[ defineQlineButton setEnabled:YES ];
		}
		
		self.stagesCanBeCalculated = [ mcCabeThiele canCalculateStages ];
		
		//
		// Check for decent values in the compositions.
		//
		double feedCompValue = [ mcCabeThiele.feedComp doubleValue ];
		double topCompValue = [ mcCabeThiele.topComp doubleValue ];
		double bottomCompValue = [ mcCabeThiele.bottomComp doubleValue ];
		
		NSColor* badColourIssue = [ NSColor colorWithDeviceRed:.7 green:.1 blue: 0.1 alpha:1 ];
		if ( topCompValue <= feedCompValue )
		{
			[ topCompTextField setTextColor:badColourIssue ];
			errorString = [ errorString stringByAppendingString: @"Warning: Distillate less than or equal to Feed. " ];
		}
		else if ( topCompValue <= bottomCompValue )
		{
			[ topCompTextField setTextColor:badColourIssue ];
			errorString = [ errorString stringByAppendingString: @"Warning: Distillate less than or equal to Bottom. " ];
		}
		else
			[ topCompTextField setTextColor: [ NSColor blackColor ] ];
		
		if ( feedCompValue > topCompValue )
		{
			[ feedCompTextField setTextColor:badColourIssue ];
			// errorString = [ errorString stringByAppendingString: @"Warning: Feed less than Distillate. " ];
		}
		else if ( feedCompValue <= bottomCompValue )
		{
			[ feedCompTextField setTextColor:badColourIssue ];
			if ( [ errorString length ] == 0 )
				errorString = [ errorString stringByAppendingString: @"Warning: Feed less than or equal to Bottom. " ];
		}
		else
			[ feedCompTextField setTextColor: [ NSColor blackColor ] ];
		
		
		if ( bottomCompValue >= topCompValue )
		{
			[ bottomCompTextField setTextColor:badColourIssue ];
			// errorString = [ errorString stringByAppendingString: @"Bottom >= Distillate. " ];
		}
		else if ( bottomCompValue >= feedCompValue )
		{
			[ bottomCompTextField setTextColor:badColourIssue ];
			// errorString = [ errorString stringByAppendingString: @"Feed <= Bottom. " ];
		}	
		else if ( bottomCompValue == 0 )
		{
			[ bottomCompTextField setTextColor:badColourIssue ];
			errorString = [ errorString stringByAppendingString: @"Bottom cannot equal 0.0." ];
			
		}
		else
			[ bottomCompTextField setTextColor: [ NSColor blackColor ]  ];
		
		//
		// Check the Reflux values.
		//
		if ( [ mcCabeThiele.minRefluxRatio doubleValue ] == 0 )
		{
			[ minRatioTextField setTextColor:badColourIssue ];
			if ( [ errorString length ] == 0 )
				errorString = [ errorString stringByAppendingString: @"Warning: Min. Reflux Ratio cannot be 0. " ];
		}
		else
			[ minRatioTextField setTextColor: [ NSColor blackColor ]  ];
		
		if ( [ mcCabeThiele.optimalRefluxRatioFactor doubleValue ] == 1.0 )
		{
			[ optimalFactorTextField setTextColor:badColourIssue ];
			if ( [ errorString length ] == 0 )
				errorString = [ errorString stringByAppendingString: @"Warning: Optimum Reflux cannot be 1.0. " ];
		}
		else
			[ optimalFactorTextField setTextColor: [ NSColor blackColor ]  ];		
	}
	
	[ errorMessageTextField setStringValue: errorString ];
	
	//
	// Force a redraw.
	//
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];		

	return;
}

- (IBAction) updateMinReflux: (id) sender
{
	NSLog(@"McCabeThieleDocument: updateMinReflux:" );

	[ mcCabeThiele setMode: DetermineMinimumRefluxMode ];
	[ mcCabeThiele rebuildMinRefluxLine ];
	
	// Force a redraw.
	//
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];		
	
	[ self updateMcCabeArtifacts: sender ];
	
	return;
}

//
// We can now plot the McCabe Thiele Graph.
//
- (IBAction) plotBoilingPointGraph: (id) sender
{
	NSLog(@"McCabeThieleDocument: plotBoilingPointGraph:" );

	[ binaryComponentsGraphView setNeedsDisplay:YES ];
	[ binaryComponentsGraphView display ];
	
	return;
}	

//
// We can now plot the McCabe Thiele Graph.
//
- (IBAction) plotMcCabeThieleGraph: (id) sender
{
	NSLog(@"McCabeThieleDocument: plotMcCabeThieleGraph:" );

	// We should double check if all the information has been entered.
	//		
	[ mcCabeThiele calcTheorecticalStages ]; 
	
	//
	// Reapply the bounds.
	//
    [ mcCabeThieleGraphView setNeedsDisplay:TRUE ];
	
	return;
}

- (IBAction) plotOptimalRefluxGraph: (id) sender
{	
	NSLog(@"McCabeThieleDocument: plotOptimalRefluxGraph:" );

	// We should double check if all the information has been entered.
	//	
	[ optimalCabeThiele generateOptimalStages ];
	[ optimalCabeThiele generateStagesAtTotalReflux ];

	//
	// Reapply the bounds.
	//
	[ optimalGraphView setNeedsDisplay: TRUE ];
}

- (IBAction) displayUnitDidChange: (id) sender
{
	NSLog(@"McCabeThieleDocument: printOperationWithSettings:" );
	
	if ( mcCabeThiele.displayFracType == DISPLAY_MOL_FRAC )
	{
		[ topUnitLabel setStringValue: @"mol. frac" ];
		[ feedUnitLabel setStringValue: @"mol. frac" ];
		[ bottomUnitLabel setStringValue: @"mol. frac " ];
		
		[ topCompTextField unbind: @"value" ];
		[ topCompTextField bind: @"value" 
					   toObject: mcCabeGraphController
					withKeyPath: @"selection.topComp" 
						options: nil ];
		
		[ bottomCompTextField unbind: @"value" ];
		[ bottomCompTextField bind: @"value" 
					   toObject: mcCabeGraphController
					withKeyPath: @"selection.bottomComp" 
						options: nil ];
		
		[ feedCompTextField unbind: @"value" ];
		[ feedCompTextField bind: @"value" 
					   toObject: mcCabeGraphController
					withKeyPath: @"selection.feedComp" 
						options: nil ];
	}
	else 
	{
		[ topUnitLabel setStringValue: @"w/w" ];
		[ feedUnitLabel setStringValue: @"w/w" ];
		[ bottomUnitLabel setStringValue: @"w/w" ];
		
		[ topCompTextField unbind: @"value" ];
		[ topCompTextField bind: @"value" 
					   toObject: mcCabeGraphController
					withKeyPath: @"selection.topWeightFrac" 
						options: nil ];
		
		[ bottomCompTextField unbind: @"value" ];
		[ bottomCompTextField bind: @"value" 
						  toObject: mcCabeGraphController
					   withKeyPath: @"selection.bottomWeightFrac" 
						   options: nil ];
		
		[ feedCompTextField unbind: @"value" ];
		[ feedCompTextField bind: @"value" 
					   toObject: mcCabeGraphController
					withKeyPath: @"selection.feedWeightFrac" 
						options: nil ];
	}	

	return;
}

- (IBAction) updateFractionalComposition: (id) sender
{
	NSDictionary* dictionary = [ sender infoForBinding: @"value" ];
	NSObject* object = [ dictionary valueForKey: NSObservedObjectKey ];
	NSString* keyPath = [ dictionary valueForKey: NSObservedKeyPathKey ];
	NSNumber* number = [ object valueForKeyPath: keyPath ];

	[ mcCabeThiele calcOtherAssociatedFractionFrom: number ];
	[ mcCabeThiele calculateQLine ];
	
	// Force a redraw.
	//
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];	
	
	return;
}

// Help
- (IBAction) showCompositionHelp : (id) sender
{
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"composition"
											   inBook: locBookName ];	
	return;
}

- (IBAction) showRminRefluxHelp : (id) sender
{
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"rmin"
											   inBook: locBookName ];
	
	return;
}


#pragma mark  Print Support 

- (void) printShowingPrintPanel:(BOOL)showPanels 
{
	NSLog(@"McCabeThieleDocument: printShowingPrintPanel:" );

    // Obtain a custom view that will be printed
	NSPrintInfo *printInfo = [ self printInfo ];
	NSPrintPanel* printPanel = nil;

	McCabeThielePrintView* mcCabeThielePrintView = [ [ McCabeThielePrintView alloc ] initWithBinaryView: binaryComponentsGraphView 
																					  mcCabeThieleView: mcCabeThieleGraphView
																								optimumView: optimalGraphView
																								printInfo: printInfo ];	
	
	//
	// Construct the print operation and setup Print panel
    NSPrintOperation *op = [NSPrintOperation
							printOperationWithView: mcCabeThielePrintView
							printInfo:[self printInfo]];
	// [ NSPrintOperation setCurrentOperation:op ];
	
	NSString* jobTitle = [ NSString stringWithFormat:@"Distillation Designer: %@", [ self displayName ] ];
	[ op setJobTitle: jobTitle];
	
    if (showPanels) 
	{
		printPanel = [ op printPanel ];
		if ( printPanelViewController == nil )
		{
			printPanelViewController = [ [ PrintPanelViewController alloc ] initWithPrintOperation: op document:(McCabeThieleDocument *)self ];
		}
		[printPanel addAccessoryController: printPanelViewController];
    }
	
    // Run operation, which shows the Print panel if showPanels was YES
	[op runOperationModalForWindow: [ mainTabView window ]
						  delegate: self
					didRunSelector: @selector(printOperationDidRun:success:contextInfo:)
					   contextInfo: nil ];

}
 

- (void)printOperationDidRun:(NSPrintOperation *)printOperation
					 success:(BOOL)success
				 contextInfo:(void *)info 
{
	NSLog(@"McCabeThieleDocument: printOperationDidRun: success: contextInfo: " );

    if (success) 
	{
        // Can save updated NSPrintInfo, but only if you have
        // a specific reason for doing so
        // [self setPrintInfo: [printOperation printInfo]];
    }
}

- (NSPrintOperation *)printOperationWithSettings:(NSDictionary *) printSettings error:(NSError **)outError
{
	NSLog(@"McCabeThieleDocument: printOperationWithSettings:" );

    NSPrintInfo *printInfo = [NSPrintInfo sharedPrintInfo];
	
    // Get the window from the first window controller (presumably the document has only one window)
    NSWindow *window = [[[self windowControllers] objectAtIndex: 1]  
						window];
    NSView *printableView = [window contentView];
	
    // Construct the print operation and setup Print panel
    NSPrintOperation *printJob = [ NSPrintOperation
								  printOperationWithView:  
								  printableView printInfo: printInfo];
	
	
    return printJob;
}





#pragma mark NOTIFICATION 
//
// Notification Methods
//
- (void) dataSetUpdated: (NSNotification*) notification
{
	NSLog(@"McCabeThieleDocument: dataSetUpdated:" );

	[ dataController setContent: datasets ];
	[ dataController rearrangeObjects ];
	
	NSDictionary* userInfo = [ notification userInfo ];
	if ( userInfo != nil )
		mcCabeThiele.selectedDataSet = [ userInfo objectForKey: ObsKey_DataSetWindow_SelectedDataSet ];
	else 
		mcCabeThiele.selectedDataSet = nil;
	
	// Make sure the graph knows about the change.
	// 
	[ mcCabeThiele updateAllUndisplayedFractions ];
	
	[ mcCabeThieleGraphView setNeedsDisplay:TRUE ];
	[ binaryComponentsGraphView setNeedsDisplay:TRUE ];  

	if ( [ mcCabeThiele.selectedDataSet.selectedSource hasMolWeightsDefined ] == NO )
	{
		[ displayUnitPopupMenu setEnabled: NO ];
		[ displayUnitPopupMenu selectItemAtIndex: 0 ];
		[ self displayUnitDidChange: self ];
	}
	
	return;
}

// Update if the qLine is updated else where.
//
- (void) qLineUpdated: (NSNotification*) notification
{
	NSLog(@"McCabeThieleDocument: qLineUpdated:" );

	[ self updateMcCabeArtifacts:self ];
	return;
}


#pragma mark UNDO 
// 
// Undo methods
//
- (void) startObservingMcCabeThiele: (McCabeThiele* ) observedMcCabeThiele
{
	NSLog(@"McCabeThieleDocument: startObservingMcCabeThiele:" );

	[ observedMcCabeThiele addObserver: self
					forKeyPath: @"feedComp"
					   options: NSKeyValueObservingOptionOld
					   context: NULL ];

	[ observedMcCabeThiele addObserver: self
					forKeyPath: @"bottomComp"
					   options: NSKeyValueObservingOptionOld
					   context: NULL ];
	
	[ observedMcCabeThiele addObserver: self
					forKeyPath: @"topComp"
					   options: NSKeyValueObservingOptionOld
					   context: NULL ];

	[ observedMcCabeThiele addObserver: self
							forKeyPath: @"qLine"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];

	[ observedMcCabeThiele addObserver: self
							forKeyPath: @"minRefluxRatio"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];

	[ observedMcCabeThiele addObserver: self
							forKeyPath: @"optimalRefluxRatioFactor"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];
		
	return;
}

- (void) stopObservingMcCabeThiele: (McCabeThiele* ) observedMcCabeThiele
{
	NSLog(@"McCabeThieleDocument: stopObservingMcCabeThiele:" );

	[ observedMcCabeThiele removeObserver:self forKeyPath:@"feedComp" ];
	[ observedMcCabeThiele removeObserver:self forKeyPath:@"bottomComp" ];
	[ observedMcCabeThiele removeObserver:self forKeyPath:@"topComp" ];
	[ observedMcCabeThiele removeObserver:self forKeyPath:@"qLine" ];
	[ observedMcCabeThiele removeObserver:self forKeyPath:@"minRefluxRatio" ];
	[ observedMcCabeThiele removeObserver:self forKeyPath:@"optimalRefluxRatioFactor" ];
	
	return;
}

- (void) startObservingOptimumMcCabeThiele: (OptimalMcCabeThiele* ) observedOptimumMcCabeThiele
{
	NSLog(@"McCabeThieleDocument: startObservingOptimumMcCabeThiele:" );

	[ observedOptimumMcCabeThiele addObserver: self
							forKeyPath: @"minimumReflux"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];

	[ observedOptimumMcCabeThiele addObserver: self
							forKeyPath: @"maximumReflux"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];
	
	[ observedOptimumMcCabeThiele addObserver: self
							forKeyPath: @"calculationSteps"
							   options: NSKeyValueObservingOptionOld
							   context: NULL ];
	
	return;
}


- (void) stopObservingOptimumMcCabeThiele: (OptimalMcCabeThiele* ) observedOptimumMcCabeThiele
{
	NSLog(@"McCabeThieleDocument: stopObservingOptimumMcCabeThiele:" );

	[ observedOptimumMcCabeThiele removeObserver:self forKeyPath:@"minimumReflux" ];
	[ observedOptimumMcCabeThiele removeObserver:self forKeyPath:@"maximumReflux" ];
	[ observedOptimumMcCabeThiele removeObserver:self forKeyPath:@"calculationSteps" ];

	return;
}


// The route which is called when observing.
//
- (void) observeValueForKeyPath: (NSString* ) keyPath ofObject: (id) object
						 change: (NSDictionary* ) change
						context: (void* ) context
{
	NSLog(@"McCabeThieleDocument: observeValueForKeyPath: ofObject: change: context:" );

	NSUndoManager* undoMgr = [ self undoManager ];
	id oldValue = [  change objectForKey:NSKeyValueChangeOldKey ];
	NSLog(@"Old value %@", oldValue );
	
	[ [ undoMgr prepareWithInvocationTarget:self ] changeKeyPath: keyPath
													 ofObject: object
													  toValue: oldValue ];
	
	[ undoMgr setActionName:@"Edit" ];
	
	return;
}

// The routine which will force the Undo.
//
- (void) changeKeyPath: (NSString* ) keyPath 
			  ofObject: (id) object
			   toValue: (id) newValue
{
	NSLog(@"McCabeThieleDocument: changeKeyPath: ofObject: toValue:" );

	// setValue:forKeyPath will cause the key-value observing method
	// to be called, which takes care of the undo stuff
	[ object setValue: newValue forKeyPath: keyPath ];
	
	return;
}

#pragma mark DELEGATE
//
// Delegate for NSFormatter controls within the window.
//
- (BOOL) control: (NSControl *) control
	didFailToFormatString: (NSString * ) stringPtr
		 errorDescription: (NSString*) error
{
	NSLog(@"McCabeThieleDocument: control: didFailToFormatString: errorDescription:" );

	if ( [ error compare:@"Formatting error." ] == NSOrderedSame )
	{	
		if ( control == topCompTextField ||
			 control == bottomCompTextField ||
			 control == feedCompTextField ) 
		{
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Okay"];

			NSString* message = [ NSString stringWithFormat:@"The entered data: %@ is not within the required range.", stringPtr ];
			[alert setMessageText:message ];
			[alert setInformativeText:@"Re-enter a value between 0.0 to 1.0"];
			[alert setAlertStyle:NSWarningAlertStyle ];

			[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(formattingErrorExistingDatasetDidEnd:returnCode:contextInfo:) contextInfo:CFBridgingRetain(control) ];

			//  NSTextField* problemTextField = (NSTextField*) control;
			[ control setDoubleValue:0.0 ];
			
			return YES;
		}
		else if ( control == optimalFactorTextField )
		{
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Okay"];
			
			NSString* message = [ NSString stringWithFormat:@"The entered data: %@ is less than an allowable value of 1.0.", stringPtr ];
			[alert setMessageText:message ];
			[alert setInformativeText:@"Re-enter a value greater than 1.0"];
			[alert setAlertStyle:NSWarningAlertStyle ];
			
			[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(formattingErrorExistingDatasetDidEnd:returnCode:contextInfo:) contextInfo:CFBridgingRetain(control) ];
			
			//  NSTextField* problemTextField = (NSTextField*) control;
			[ control setDoubleValue:1.0 ];
			
			return YES;			
		}
		else if ( control == minRatioTextField )
		{
			NSAlert *alert = [[NSAlert alloc] init];
			[alert addButtonWithTitle:@"Okay"];
			
			NSString* message = [ NSString stringWithFormat:@"The entered data: %@ is less than or equal to an allowable value of 0.0.", stringPtr ];
			[alert setMessageText:message ];
			[alert setInformativeText:@"Re-enter a value greater than 0.0"];
			[alert setAlertStyle:NSWarningAlertStyle ];
			
			[alert beginSheetModalForWindow:[self windowForSheet] modalDelegate:self didEndSelector:@selector(formattingErrorExistingDatasetDidEnd:returnCode:contextInfo:) contextInfo:CFBridgingRetain(control) ];
			
			//  NSTextField* problemTextField = (NSTextField*) control;
			[ control setDoubleValue:0.0 ];
			
			return YES;			
			
		}
	}
	return NO;
}


- (void) formattingErrorExistingDatasetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	NSLog(@"McCabeThieleDocument: formattingErrorExistingDatasetDidEnd" );
	
	// Force the focus back to the back text field.
	//
	[ (__bridge NSTextField*) contextInfo selectText: [self windowForSheet] ];

	return;	
}

//
// Delegate from the NSTextFields.
//
//- (void) controlTextDidEndEditing:(NSNotification *)aNotification;
- (void) controlTextDidChange:(NSNotification *)aNotification;

{
	NSLog(@"McCabeThieleDocument: controlTextDidChange:" );

	[ self updateMcCabeArtifacts: [ aNotification object ] ];
	
	return;	
}

#pragma mark GETS_SETS
//
/*
- (void) setSelectedDataSet: (DataSet*) dataset
{
	// NSLog("dataset is a %@", [ dataset className ] );
    selectedDataSet = dataset;
	
	// feed the dataset down to the graph object.
	mcCabeThiele.selectedDataSet = selectedDataSet;
}

- (DataSet*) getSelectedDataSet
{
	return selectedDataSet;
}
*/

/*
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    //we aren't particularily interested in this so we will do nothing
    //this is one of the methods that we do not have to implement
}

- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) 
		== NSDragOperationGeneric)
    {
        //this means that the sender is offering the type of operation we want
        //return that we want the NSDragOperationGeneric operation that they 
		//are offering
        return NSDragOperationGeneric;
    }
    else
    {
        //since they aren't offering the type of operation we want, we have 
		//to tell them we aren't interested
        return NSDragOperationNone;
    }
}


- (void)draggingEnded:(id <NSDraggingInfo>)sender
{
    //we don't do anything in our implementation
    //this could be ommitted since NSDraggingDestination is an infomal
    //protocol and returns nothing
    NSManagedObject* selectedFact = [ factsController selection ];
    NSManagedObjectContext *context = [factsController managedObjectContext]; 
    [ context refreshObject:selectedFact mergeChanges:NO ];
    
	
}


- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard *paste = [sender draggingPasteboard];
    //gets the dragging-specific pasteboard from the sender
    NSArray *types = [NSArray arrayWithObjects:NSTIFFPboardType, 
					  NSFilenamesPboardType, nil];
    //a list of types that we can accept
    NSString *desiredType = [paste availableTypeFromArray:types];
    NSData *carriedData = [paste dataForType:desiredType];
    
    if (nil == carriedData)
    {
        //the operation failed for some reason
        NSRunAlertPanel(@"Paste Error", @"Sorry, but the past operation failed", 
						nil, nil, nil);
        return NO;
    }
    else
    {
		NSImage* newImage;
        //the pasteboard was able to give us some meaningful data
        if ([desiredType isEqualToString:NSTIFFPboardType])
        {
            //we have TIFF bitmap data in the NSData object
            newImage = [ [NSImage alloc] initWithData:carriedData]; // autorelease ];
            [self setImage:newImage];
			
			//we are no longer interested in this so we need to release it
        }
        else if ([desiredType isEqualToString:NSFilenamesPboardType])
        {
            //we have a list of file names in an NSData object
            NSArray *fileArray = 
			[paste propertyListForType:@"NSFilenamesPboardType"];
			//be caseful since this method returns id.  
			//We just happen to know that it will be an array.
            NSString *path = [fileArray objectAtIndex:0];
			//assume that we can ignore all but the first path in the list
            newImage = [ [ NSImage alloc] initWithContentsOfFile:path]; // autorelease ];
			
            if (nil == newImage)
            {
                //we failed for some reason
                NSRunAlertPanel(@"File Reading Error", 
								[NSString stringWithFormat:
								 @"Sorry, but I failed to open the file at \"%@\"",
								 path], nil, nil, nil);
                return NO;
            }
            else
            {
                //newImage is now a new valid image
                [self setImage:newImage];
            }
        }
        else
        {
            //this can't happen
            NSAssert(NO, @"This can't happen");
            return NO;
        }
		
		if ( newImage != nil )
		{
			NSManagedObject* selectedFact = [ factsController selection ];
			NSLog(@" SelectedFact %@", [ selectedFact valueForKey:@"name" ] );
			NSMutableArray* images = [ selectedFact valueForKey:@"images_rel" ]; 
			
			NSManagedObjectContext *context = [factsController managedObjectContext]; 
			NSManagedObject* factImage = [ NSEntityDescription
										  insertNewObjectForEntityForName:@"FactImage" 
										  inManagedObjectContext:context];
			NSData *imageData = [NSArchiver archivedDataWithRootObject:newImage ];
			
			[factImage setValue:imageData forKey:@"theImage"];
			[factImage setValue:@"file" forKey:@"fileName"];
			[factImage setValue:[ NSDate new ] forKeyPath:@"addedDate" ];;
			
			[ images addObject: factImage ];
			
			[newImage release];
		}
		
    }
    
    [self setNeedsDisplay:YES];    //redraw us with the new image
    [self display ]; //redraw us with the new image
	
    return YES;
}


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    //re-draw the view with our new data
    [self setNeedsDisplay:YES];
    
    NSManagedObjectContext *context = [factsController managedObjectContext]; 
    [ context processPendingChanges ];
    
    NSNotificationCenter* notificationCentre = [NSNotificationCenter defaultCenter ];
    [  notificationCentre postNotificationName:@"Data_FactImageAdded" object: nil ];
}
*/



#pragma mark PROPERTIES

@synthesize fontManager;
@synthesize mcCabeThielePlotButton;
@synthesize dataSetWindowController;
@synthesize selectedComponent;
@synthesize datasets;
@synthesize stagesCanBeCalculated;
@synthesize mcCabeThiele;
@synthesize optimalCabeThiele;


@end
