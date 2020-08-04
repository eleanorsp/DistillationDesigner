//
//  McCabeThieleAppController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 02/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "McCabeThieleAppController.h"
#import "McCabeThieleDocument.h"
#import "DataSet.h"

@interface McCabeThieleAppController (Private)


@end


@implementation McCabeThieleAppController

#pragma mark GLOBAL_FUNCTIONS 
//
+ (void) initialize 
{
	// Sort out some default values.
	//
	NSMutableDictionary* defaultValues = [ NSMutableDictionary dictionary ];
	
	NSColor* vapourcolour = [ NSColor colorWithDeviceRed:1.0 green:0.6 blue:0.6 alpha:0.8 ];
	NSColor* liquidcolour = [ NSColor colorWithDeviceRed:0.6 green:0.6 blue:1.0 alpha:0.8 ];
	NSColor* stagecolour = [ NSColor colorWithDeviceRed:0.6 green:1.0 blue:0.5 alpha:0.5 ];
	NSColor* skirtcolour = [ NSColor colorWithDeviceRed:1.0 green:0.6 blue:0.5 alpha:0.5 ];

	NSData* vapourColourData = [ NSArchiver archivedDataWithRootObject: vapourcolour ];
	NSData* liquidColourData = [ NSArchiver archivedDataWithRootObject: liquidcolour ];
	NSData* lineColourData = [ NSArchiver archivedDataWithRootObject: [ NSColor blackColor ] ];
	NSData* fillStageColourData = [ NSArchiver archivedDataWithRootObject: stagecolour ];
	NSData* skirtColourData = [ NSArchiver archivedDataWithRootObject: skirtcolour ];

	[ defaultValues setObject:vapourColourData forKey: DD_VapourColourKey ];	
	[ defaultValues setObject:liquidColourData forKey: DD_LiquidColourKey ];	
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey: DD_ShowMinorAxisKey ];
	[ defaultValues setObject:lineColourData forKey: DD_StageLineColourKey ];	
	[ defaultValues setObject:fillStageColourData forKey: DD_StageFillColourKey ];	
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey: DD_FillStagesKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:5 ] forKey: DD_NumberMinorIntervalsKey ];
	
	[ defaultValues setObject:[ NSNumber numberWithInt:5 ] forKey: DD_OptimalXAxisMajorIntervalsKey ];

	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey: DD_OptimalShowYAxisBandingKey ];
	[ defaultValues setObject:fillStageColourData forKey: DD_OptimalYAxisBandingColourKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:10 ] forKey: DD_OptimalYAxisMajorIntervalsKey ];
	
	[ defaultValues setObject:skirtColourData forKey: DD_OptimalLineColourKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:0 ] forKey: DD_OptimalPlotLineSkirtKey ];
	
	[ defaultValues setObject:vapourColourData forKey: DD_BPVapourColourKey ];	
	[ defaultValues setObject:liquidColourData forKey: DD_BPLiquidColourKey ];
	[ defaultValues setObject:[ NSNumber numberWithBool:YES ] forKey: DD_BPShowMinorAxisKey ];
	[ defaultValues setObject:[ NSNumber numberWithInt:5 ] forKey: DD_BPNumberMinorIntervalsKey ];

	 // Register the Dictionary
	 //
	 [[ NSUserDefaults standardUserDefaults ] registerDefaults: defaultValues ];
	 
	 NSLog(@"Registered Defaults: %@" , defaultValues );
	
//#ifdef BETA_TEST
//    
//    NSDateComponents *components = [[NSDateComponents alloc] init];
//    [components setDay:1];
//    [components setMonth:5];
//    [components setYear:2011]; // 1st May 2011.
//    
//    NSCalendar* betaEndCalendar = [ [ NSCalendar alloc ] initWithCalendarIdentifier: NSGregorianCalendar ];
//    NSDate* betaEndDate = [ betaEndCalendar dateFromComponents:components ];
//    NSDate* now = [ NSDate date ];
//    
//    if ( [ now compare: betaEndDate ] == NSOrderedDescending )
//	{
//		NSAlert *alert = [[NSAlert alloc] init];
//		[alert addButtonWithTitle:@"Okay"];
//		
//		[alert setMessageText: @"Beta Test Version Expired" ];
//		[alert setInformativeText:@"The beta test version has now expired. This Application will now quit."];
//		[alert setAlertStyle:NSCriticalAlertStyle];
//		
//		NSInteger returnValue = [ alert runModal ];
//		if ( returnValue == NSAlertFirstButtonReturn  )
//		{
//			exit(0);
//		}
//	}
//#endif 
	
	
	 return;
}

#pragma mark INITIALISE
//
- (id) init
{
	self = [super init];
    if (self) 
	{	
		sharedDatasets = nil;
	}
	
	return self;
}


//
//
- (NSMutableArray*) sharedDatasets
{
	NSLog(@"McCabeThieleAppController: sharedDatasets" );

	if ( sharedDatasets == nil )
	{
		sharedDatasets = [ [ NSMutableArray alloc ] init ];
		
		// Listen to changes.
		[ self addObserver: (McCabeThieleAppController*) self 
				forKeyPath: ObsKey_AppDelegate_sharedDatasets
				   options: NSKeyValueObservingOptionNew
				   context: nil ];
		//
		// Test Harness.
		//
		DataSet* testDataSet = [ [ DataSet alloc ] initWithTestData ];
		testDataSet.name = @"Ethanol/Water";
		// [ selectedDataSet setTestData ];
		[ sharedDatasets addObject:testDataSet ];	
		
		[ self prepareExportDatasetSubMenu ];
	}

	return sharedDatasets;
}
	   
// Routine to 
- (void) observeValueForKeyPath:(NSString *)keyPath 
					   ofObject:(id)object 
						 change:(NSDictionary *)change 
						context:(void *)context 
{
	if ( [keyPath isEqualToString: ObsKey_AppDelegate_sharedDatasets] == YES ) 
	{
		[ self prepareExportDatasetSubMenu ];
	}
	
	return;
}

//
// Generate a unique Data Set Name.
//
+ (NSString*) createUniqueDataSetName: (NSString*) setName
{    
	NSLog(@"McCabeThieleAppController: createUniqueDataSetName" );
	
    NSString* uniqueName = setName;
    NSInteger count = 0;
    bool found = YES;
    while (found == YES )
    {
		found = NO;
		
		McCabeThieleAppController* mcCabeThieleAppDelegate = (McCabeThieleAppController*) [ NSApplication sharedApplication ].delegate;
		
		for ( DataSet *dataSet in mcCabeThieleAppDelegate.sharedDatasets )
		{
			if ( [ uniqueName compare:[ dataSet name] ] == NSOrderedSame )
			{
				found = YES;
				count++;
				
				NSString* countStr = [ NSString stringWithFormat:@" %d", count]; 
				uniqueName = [ setName stringByAppendingString:countStr ];
				
				break; // From while loop.
			}
		}
    }
    
    return uniqueName;
}

#pragma mark IB_ACTION
//
// Display the preferences panel for the application.
//
- (IBAction) showPreferencesPanel: (id) sender
{
	 if ( !prefController )
	 {
		prefController = [ [PreferencesController alloc] init ];
	 }
	 
	 [ prefController showWindow: self ];
	 
	 return;
}
	 
//
// Display the preferences panel for the application.
//
- (IBAction) showDatasetsPanel: (id) sender
{
	if ( !dataSetWindowController )
    {
		dataSetWindowController = [DataSetWindowController alloc];
		[ dataSetWindowController initUsingDataSet: sharedDatasets ];
    }
	
	dataSetWindowController.isStandalone = YES;
    [ dataSetWindowController showWindow: self ];
	
	return;
}




//
// Menu Actions 
//
- (IBAction) zoomIn: (id) sender
{
	// find the current document and pass on the command to it.
	//
	NSDocumentController* mainDocumentController = [ NSDocumentController sharedDocumentController ];
	McCabeThieleDocument* currentDocument = [ mainDocumentController currentDocument ];
	
	[ currentDocument zoomIn: sender ];
}

- (IBAction) zoomOut: sender
{
	// find the current document and pass on the command to it.
	//
	NSDocumentController* mainDocumentController = [ NSDocumentController sharedDocumentController ];
	McCabeThieleDocument* currentDocument = [ mainDocumentController currentDocument ];
	
	[ currentDocument zoomOut: sender ];
}

- (IBAction) print: (id) sender
{
	NSPrintInfo* printInfo = [ NSPrintInfo sharedPrintInfo ];
	NSPrintOperation* printOperation;
	
	NSView* view = [ [ [ NSDocumentController sharedDocumentController ] currentDocument ] contentView ];
	printOperation = [ NSPrintOperation printOperationWithView:  view
													 printInfo: printInfo ];
	[ printOperation setShowsPrintPanel:YES ];
	[ printOperation runOperation ];
}

- (IBAction) exportDataSet: (id) sender
{	
	// First Get the Export Menu Item
	NSMenu* mainMenu = [[ NSApplication sharedApplication ] mainMenu ];
	NSMenuItem* fileMenuItem = [ mainMenu itemWithTitle: @"File" ];
	NSMenu* fileMenu = [ fileMenuItem submenu ];
	NSMenuItem* exportMenuItem = [ fileMenu itemWithTitle: @"Export Dataset" ];
	NSMenu* exportSubMenu = [ exportMenuItem submenu ];
	int menuPosition = [ exportSubMenu indexOfItem: sender ];
	
	DataSet* dataset = [ sharedDatasets objectAtIndex: menuPosition ];
	
	NSSavePanel* savePanel = [ NSSavePanel savePanel ];
	[ savePanel setTitle: [ NSString stringWithFormat: @"Export Dataset: %@", dataset.name ] ];

	/* set up new attributes */
	[ savePanel setRequiredFileType: @"data" ];
	
	/* display the NSSavePanel */
	[ savePanel beginWithCompletionHandler: ^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) 
		{
			/* if successful, save file under designated name */
			if (result == NSFileHandlingPanelOKButton ) 
			{
				@try 
				{
					[ dataset.selectedSource exportDataFile: [ savePanel URL ] ];
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

- (IBAction) importDataset: (id) sender
{
	NSOpenPanel* importPanel = [ NSOpenPanel openPanel ];
    [ importPanel setAllowsMultipleSelection:NO ];
	[ importPanel setTitle: @"Import Dataset" ];
    
    // Run the open panel.
    //
	[ importPanel beginWithCompletionHandler: ^(NSInteger result) {
		if (result == NSFileHandlingPanelOKButton) 
		{
			NSString* path = [ importPanel filename ];
			NSArray* fileNames = [ importPanel filenames ];	
			if ( [ fileNames count ] > 0 )
			{
				NSString* fileName = [ fileNames objectAtIndex: 0 ];
				
				// Create a new data set from the file name.
				DataSet* newDataSet = [ [ DataSet alloc] initWithSourceType: FROM_FILE ];
				[ newDataSet setName: [ McCabeThieleAppController createUniqueDataSetName: fileName ] ];
				
				// Get the source to load its data.
				//
				BOOL success = YES;
				FileDataSource* fileSource = (FileDataSource*) [ newDataSet setSelectedDataSource: FROM_FILE ];
				@try
				{
					[ fileSource loadDataFromFile: fileName ];
				}
				@catch (NSException* exception)
				{
					if ( [ exception.name isEqualToString: EXCEPTION_OldFileVersion ] == YES )
					{
						NSAlert *alert = [ NSAlert alertWithMessageText: [ exception reason ]
														  defaultButton: @"Okay"
														alternateButton: nil
															otherButton: nil
											  informativeTextWithFormat: @"Please resave in the new format.", nil ];
						
						[ alert setAlertStyle: NSInformationalAlertStyle ];
						[ alert runModal ];	   
					}
					else 
					{
						// TBD Deal with the error like a bad formatting issue.
						//
						NSAlert *alert = [[NSAlert alloc] init];
						[alert addButtonWithTitle:@"Okay"];
						
						NSString* message = [ NSString stringWithString:@"Unable to load the data file" ];
						[ alert setMessageText:message ];
						[ alert setInformativeText:[ exception reason ] ];
						[ alert setAlertStyle:NSCriticalAlertStyle ];
						[ alert runModal ];
						
						success = NO;
					}
				}
				@finally 
				{
					if ( success == YES ) 
					{
						// Add it to the datasets list add this controller.
						//
						[ sharedDatasets addObject: newDataSet ];
						
						// Now open the dataset panel and select it.
						[ self showDatasetsPanel: self ];
						dataSetWindowController.selectedDataSet = newDataSet;
						
					}
				}
			}
		}
	} ];
	 

	
}


#pragma mark METHODS

- (void) prepareExportDatasetSubMenu
{
	// First Get the Export Menu Item
	NSMenu* mainMenu = [[ NSApplication sharedApplication ] mainMenu ];
	NSMenuItem* fileMenuItem = [ mainMenu itemWithTitle: @"File" ];
	NSMenu* fileMenu = [ fileMenuItem submenu ];
	NSMenuItem* exportMenuItem = [ fileMenu itemWithTitle: @"Export Dataset" ];
	NSMenu* exportSubMenu = [ exportMenuItem submenu ];
	[ exportSubMenu removeAllItems ];
	
	// 
	//
	for (DataSet* dataSet in sharedDatasets )
	{
		NSMenuItem* menuItem = [ [ NSMenuItem alloc ] initWithTitle: dataSet.name 
															 action: @selector(exportDataSet:)
													  keyEquivalent: @"" ];
		[ menuItem setTarget: self ];
		
		[ exportSubMenu addItem: menuItem ];
	}

	return;
}

@end
