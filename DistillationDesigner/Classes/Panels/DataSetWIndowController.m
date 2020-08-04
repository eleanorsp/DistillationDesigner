//
//  DataSetController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 06/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "McCabeThieleAppController.h"

#import "RelativeVolatilityDataSource.h"

#import "DataSetWindowController.h"
#import "PopupValueTransformer.h"

#import	"McCabeThieleDocument.h"

@implementation DataSetWindowController

#pragma mark INITIALISE 
//
- (id) initUsingDataSet: (NSMutableArray*) sets
{
	NSLog(@"DataSetWindowController: initUsingDataSet" );

    self = [ super initWithWindowNibName:@"DataSetPanel" ];
    if (self) 
    {
		datasets = sets;
		selectedDataSet = nil;
    }
    
    return self;
}

- (void) awakeFromNib
{
	NSLog(@"DataSetWindowController: awakeFromNib" );

    [ [self window ] setAlphaValue:1.0 ];
    [ [self window ] setOpaque:NO ];
	
//	NSRect frame = self.window.frame;
//	NSRect smallRect = NSMakeRect( frame.origin.x, frame.origin.y, frame.size.width, 140 );
//	[ self.window setFrame: smallRect display: NO];

    [ self setDataSourceOption:dataSetTableView ];
	[ dataSetTableView setDelegate: self ];
}

- (void) windowDidLoad
{
	NSLog(@"DataSetWindowController: windowDidLoad" );
	[ super windowDidLoad ];
	
	if ( isStandalone == YES )
	{
		[ self.window setStyleMask: NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask ];
		[ applyButton setHidden: YES ];
	}
	
	return;
}

#pragma mark IB_ACTION
//
- (IBAction)showWindow:(id)sender
{
	NSLog(@"DataSetWindowController: showWindow" );

	if ( isStandalone == YES )
	{
		[ super showWindow: sender ];
	}
	else
	{
		[NSApp beginSheet:[ self window] 
		   modalForWindow:[ sender windowForSheet] 
			modalDelegate:self
		   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
			  contextInfo:nil ];
		
		[ dataSetTableView reloadData ];
	}
		
	return;
}

- (void) sheetDidEnd: (NSWindow*) sheet
	  returnCode: (int) returnCode
	 contextInfo: (void*) contextInfo
{
	NSLog(@"DataSetWindowController: sheetDidEnd" );

	// Make sure the Data Sets are sorted.
	//
	for ( DataSet* dataSet in datasets )
	{
		[ [ dataSet selectedSource ] sortDataSet ];
	}
}


- (IBAction) closeDataControllerSheet: (id) sender
{
	NSLog(@"DataSetWindowController: closeDataControllerSheet" );

	// Make sure the data points are resmoothed.
	//
	for ( DataSet* dataSet in datasets )
	{
		[ [ dataSet selectedSource ] sortDataSet ];
		[ [ dataSet selectedSource ] smoothDataPoints ];
	}
	
    // Hide the Sheet.
    [[ self window] orderOut: sender ];

    // Return normal event handling.
    [ NSApp endSheet:[ self window] returnCode:1];

    NSNotificationCenter* notificationCentre = [NSNotificationCenter defaultCenter ];
	
	NSDictionary* userInfo = nil;
	if ( selectedDataSet != nil )
		userInfo = [ NSDictionary dictionaryWithObject: selectedDataSet forKey: ObsKey_DataSetWindow_SelectedDataSet ];
	[  notificationCentre postNotificationName:@"DataSetsUpdated" object: self userInfo: userInfo ];

    return;
}


//
// Set the Data Source which will be used with the DataSet.
//
- (IBAction) setDataSourceOption: (id) sender
{
	NSLog(@"DataSetWindowController: setDataSourceOption" );

    NSInteger selectedRow = [ dataSetTableView selectedRow];
    if ( selectedRow >= 0 )
    {
		// [ dataSourcePopup setEnabled:YES ];	 
		self.selectedDataSet = [ datasets objectAtIndex:selectedRow ];
    }
	else
		self.selectedDataSet = nil;
  
	[ self showSelectedDataSourcePanel ];  
	
    return;
}


//
// Adds a new dataset to the document.
//
- (IBAction) addDataSet: (id) sender
{
	NSLog(@"DataSetWindowController: addDataSet" );

    DataSet* newDataSet = [ [ DataSet alloc] initWithInitialValues ];
    [ newDataSet setName: [ McCabeThieleAppController createUniqueDataSetName:@"Undefined Data Set "] ];

    [ datasets addObject:newDataSet];
    self.selectedDataSet = newDataSet;
    
    [ self updateFromDataSet ];
    
    // Now select it
    //
    NSIndexSet* index = [ [ NSIndexSet alloc] initWithIndex: ( [dataSetTableView numberOfRows] -1 ) ];
    [ dataSetTableView selectRowIndexes:index byExtendingSelection:NO];
    
    [ self setDataSourceOption:dataSetTableView ];
    
    return;
}

//
// Adds a new dataset to the document.
//
- (IBAction) addRelativeVolatilityDataset: (id) sender
{
	NSLog(@"DataSetWindowController: addRelativeVolatilityDataset:" );
	
	// Create a new data set from the file name.
	DataSet* newDataSet = [ [ DataSet alloc] initWithSourceType: VIA_CONSTANT_REL_VOL ];
	
	// Get the source to load its data.
	//
	BOOL success = YES;
	RelativeVolatilityDataSource* relVolSource = (RelativeVolatilityDataSource*) newDataSet.selectedSource;	
    [ newDataSet setName: [ McCabeThieleAppController createUniqueDataSetName:@"Relative Volatility Data Set"] ];
	
    [ datasets addObject:newDataSet];
    self.selectedDataSet = newDataSet;
    
    [ self updateFromDataSet ];
    
    // Now select it
    //
    NSIndexSet* index = [ [ NSIndexSet alloc] initWithIndex: ( [dataSetTableView numberOfRows] -1 ) ];
    [ dataSetTableView selectRowIndexes:index byExtendingSelection:NO];
    
    [ self setDataSourceOption: dataSetTableView ];
	
}


//
// Deletes data set from the document.
//
- (IBAction) deleteDataSet: (id) sender
{
	NSLog(@"DataSetWindowController: deleteDataSet" );

	if ( selectedDataSet != nil )
	{
		NSAlert *alert = [ NSAlert alertWithMessageText: [ NSString stringWithFormat: @"Are you sure you want to delete the dataset: \'%@\'?", selectedDataSet.name ] 
										  defaultButton: @"Okay"
										alternateButton: @"Cancel"
											otherButton: nil
							  informativeTextWithFormat: @"This action cannot be undone.", nil ];
		[ alert setAlertStyle: NSInformationalAlertStyle ];
		
		if ( [ alert runModal ] == NSAlertDefaultReturn ) 
		{
			NSInteger selectedRow = [ dataSetTableView selectedRow];
			if ( selectedRow >= 0 )
			{
				[ datasets removeObjectAtIndex:selectedRow ];
				[ self updateFromDataSet ];
				[ self setDataSourceOption:dataSetTableView ];
			}		
		}
	}
		
    return;
}

//
// Imports a new Data set.
//
- (void) importDataSet:(id) sender
{
    NSOpenPanel* panel = [ NSOpenPanel openPanel ];
    [ panel setAllowsMultipleSelection:NO ];
	[ panel setTitle: @"Import Dataset" ];
    
    // Run the open panel.
    //
    [ panel beginSheetForDirectory:nil
							  file:nil
							 types:nil
					modalForWindow:[ sender window ] 
					 modalDelegate:self
					didEndSelector: @selector(openPanelDidEnd:returnCode:contextInfo:)
					   contextInfo:NULL ];
    
    return;
}

// 
// select the image and import it into the TableView
//
- (void) openPanelDidEnd:(NSOpenPanel *) openPanel
			  returnCode:(int) returnCode
			 contextInfo:(void *) x
{
    NSString *path;

	if ( returnCode == NSOKButton )
    {
		path = [ openPanel filename ];
		NSArray* fileNames = [ openPanel filenames ];	
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
					[ datasets addObject: newDataSet ];
					self.selectedDataSet = newDataSet;
					
					[ loadDataSetController setContent: fileSource ];
					[ manualDataSetController setContent: nil ];
					
					[ self updateFromDataSet ];
					
					//
					// Now select it in the list.
					//
					NSIndexSet* index = [ [ NSIndexSet alloc] initWithIndex: ( [dataSetTableView numberOfRows] -1 ) ];
					[ dataSetTableView selectRowIndexes:index byExtendingSelection:NO];
					
					[ self setDataSourceOption:dataSetTableView ];	 					
				}
			}
		}
    }
	
	return;
}

- (IBAction) reloadDataSet: (id) sender // Clear the existing dataset with the reloaded one.
{
	if ( [ [ selectedDataSet selectedSource ] isKindOfClass: [ FileDataSource class ] ] == YES )
	{
		FileDataSource* fileSource = (FileDataSource*) [ selectedDataSet selectedSource ];

		@try
		{
			[ fileSource loadDataFromFile: fileSource.fileName ];
			[ self updateFromDataSet ];
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
				[alert setMessageText:message ];
				[alert setInformativeText:[ exception reason ] ];
				[alert setAlertStyle:NSCriticalAlertStyle];
				[ alert runModal ];
			}
		}
	}
	
	return;
}

- (IBAction) downloadData: (id) sender
{
	NSLog(@"DataSetWindowController: downloadData:" );
	
	NSURL* url = [ [ NSURL alloc ] initWithString:@"http://www.thecrumpery.com/thecrumpery/Distillation_Designer_Data_Files.html" ];
	
	[[NSWorkspace sharedWorkspace] openURL: url ];
	
	return;
}

- (IBAction) showDataSetHelp: (id) sender
{
	NSLog(@"DataSetWindowController: downloadData:" );
		
	NSString *locBookName = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	
	[[NSHelpManager sharedHelpManager] openHelpAnchor: @"about"
											   inBook: locBookName ];
	
//	CFBundleRef myApplicationBundle = NULL;
//    CFTypeRef myBookName = NULL;
//    OSStatus err = noErr;
//	
//    myApplicationBundle = CFBundleGetMainBundle();// 1
//    if (myApplicationBundle == NULL) 
//	{err = fnfErr; 
//	}
//	
//    myBookName = CFBundleGetValueForInfoDictionaryKey( myApplicationBundle,
//													   CFSTR("CFBundleHelpBookName"));
//    if (myBookName == NULL) 
//	{
//		err = fnfErr; 
//	}
//	
//    if (CFGetTypeID(myBookName) != CFStringGetTypeID()) 
//	{// 3
//        err = paramErr;
//    }
//	
//    if (err == noErr) 
//		err = AHLookupAnchor(myBookName, CFSTR("About") );// 4
//    
//	DebugLog( @"%d", err );

	return;	
}


#pragma mark DATASET 
//
// Checks to see if we alrady have this dataset loaded if so, give the user a chance to use the
// existing dataset else rename this new dataset to something unique.
//
- (void) manageNewDatasetFrom: (NSDocument*) currentDocument
{
	NSLog(@"DataSetWindowController: manageNewDatasetFrom" );

	McCabeThieleDocument* currentLoadedDocument = (McCabeThieleDocument*) currentDocument;
    NSString* uniqueName = [ McCabeThieleAppController createUniqueDataSetName: currentLoadedDocument.mcCabeThiele.selectedDataSet.name ];
		
	if ( [ uniqueName compare:  currentLoadedDocument.mcCabeThiele.selectedDataSet.name ] != NSOrderedSame )
	{
		// we've got a duplicate name.
		// deal with it.
		//
		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"Add Data Set as New"];
		[alert addButtonWithTitle:@"Replace with Existing Data Set"];
		
		NSString* message = [ NSString stringWithFormat:@"Distillation Designer aleady has a data set loaded with the name: %@", currentLoadedDocument.mcCabeThiele.selectedDataSet.name ];
		[alert setMessageText: message  ];
		NSString* informative = [ NSString stringWithFormat:@"Do you wish to use the existing data set or load the new one as: %@", uniqueName ];
		[alert setInformativeText: informative ];
		[alert setAlertStyle:NSWarningAlertStyle];
		
	//	[alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(alertExistingDatasetDidEnd:returnCode:contextInfo:) contextInfo:(__bridge void * _Nullable)(currentLoadedDocument) ];
	}
	else // new to application.
		[ datasets addObject: currentLoadedDocument.mcCabeThiele.selectedDataSet ];
	
	return;
}


- (void) alertExistingDatasetDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
	NSLog(@"DataSetWindowController: alertExistingDatasetDidEnd" );

	McCabeThieleDocument* currentDocument = (McCabeThieleDocument*) CFBridgingRelease(contextInfo);

	NSString* uniqueName = [ McCabeThieleAppController createUniqueDataSetName: currentDocument.mcCabeThiele.selectedDataSet.name ];
    if (returnCode == NSAlertFirstButtonReturn) 
	{
		// rebuild the unique name
		DataSet* documentsDataset = currentDocument.mcCabeThiele.selectedDataSet;
		
		documentsDataset.name = uniqueName;
		
		// Add this new dataset to the application.
		//
		[ datasets addObject: documentsDataset ];
	}
	else
	{
		// Find the data set with the same name.
		for ( DataSet *dataSet in datasets )
		{
			if ( [ uniqueName compare:[ selectedDataSet name] ] == NSOrderedSame )
			{
				currentDocument.mcCabeThiele.selectedDataSet = dataSet;
			}
		}
	}
	
	return;
}

// Updates the User Interface
//
- (void ) updateFromDataSet
{
	NSLog(@"DataSetWindowController: updateFromDataSet" );

    // Tell the DataSet to update itself.
    //
    [ dataSetTableView reloadData];
	
	McCabeThieleAppController* mcCabeThieleAppDelegate = (McCabeThieleAppController*) [ NSApplication sharedApplication ].delegate;
	[ mcCabeThieleAppDelegate prepareExportDatasetSubMenu ];

    
    return;
}


- (void) showSelectedDataSourcePanel
{
	DataSourceType type = NOT_SET;
	type = [ selectedDataSet sourceType ];
	
	NSRect frame = self.window.frame;
	NSRect newRect = NSMakeRect( frame.origin.x, frame.origin.y, frame.size.width, 645 );
	
	switch (type)
	{
		case MANUAL:
		{
			if ( [ self.window isVisible ] == YES )
				[ self.window setFrame: newRect display: YES animate: YES ];
			
			[ dataSourceView selectTabViewItemAtIndex: 0 ];
			[ manualDataSetController setContent:[ selectedDataSet selectedSource] ];
			[ loadDataSetController setContent: nil ];
			[ relativeVolatilityController setContent: nil ];			
			break;			
		}
						
		case FROM_FILE:
		{
			if ( [ self.window isVisible ] == YES )
				[ self.window setFrame: newRect display: YES animate: YES ];
			
			[ dataSourceView selectTabViewItemAtIndex: 1 ];
			[ loadDataSetController setContent: [ selectedDataSet selectedSource] ];
			[ manualDataSetController setContent: nil ];
			[ relativeVolatilityController setContent: nil ];
			break;
			
		}
						
		case VIA_CONSTANT_REL_VOL:
		{
			if ( [ self.window isVisible ] == YES )
				[ self.window setFrame: newRect display: YES animate: YES ];
			
			[ dataSourceView selectTabViewItemAtIndex: 2 ];
			[ manualDataSetController setContent: nil ];
			[ loadDataSetController setContent: nil ];
			[ relativeVolatilityController setContent: [ selectedDataSet selectedSource] ];
			break;
		}
			
		case NOT_SET:
		default:
		{
			[ dataSourceView selectTabViewItemAtIndex: 3 ];
			[ loadDataSetController setContent: nil ];
			[ manualDataSetController setContent: nil ];
			[ relativeVolatilityController setContent: nil ];
	
			NSRect smallRect = NSMakeRect( frame.origin.x, frame.origin.y, frame.size.width, 220 );
			[ self.window setFrame: smallRect display: YES animate: YES ];			
			break;			
		}
	}

	return;
}

#pragma mark TABLE_DELEGATE
//
// Implement the All Table Controls in this controller via these methods.
//
- (int) numberOfRowsInTableView:(NSTableView*) thetableView
{
	NSLog(@"DataSetWindowController: numberOfRowsInTableView" );

    if ( thetableView == dataSetTableView )
    {
		return [ datasets count];
    }
    
    return 0; 
}

- (id) tableView:(NSTableView* ) theTableView
	     objectValueForTableColumn:(NSTableColumn*) tableColumn
	     row:(int) rowIndex
{
	NSLog(@"DataSetWindowController: tableView objectValueForTableColumn" );

    // Get the column identifier.
    NSString* identifier = [ tableColumn identifier];
    
    // Get the information.
    if ( theTableView == dataSetTableView )
    {
		DataSet* dataSet = [ datasets objectAtIndex:rowIndex ];
		
		if ( [ identifier compare:@"sourceType" ] == 0 )
		{
			return [ dataSet getDataSourceTypeDescription ];
		}
		else
			 return [ dataSet valueForKey:identifier ];
    }    
    
    return nil;
}


- (void) tableView:(NSTableView *) theTableView
    setObjectValue:(id) anObject
    forTableColumn:(NSTableColumn*) tableColumn
	       row:(int) rowIndex
{
//	NSLog(@"DataSetWindowController: tableView" );

    // Get the column identifier.
    id identifier = [ tableColumn identifier];
    
	if ( identifier == nil )
		return; 
	
	// Get the information.
    //
	if ( theTableView == dataSetTableView )
    {
		DataSet* dataSet = [ datasets objectAtIndex:rowIndex ];
		
		if ( [ (NSString*) identifier compare:@"name" ] == 0 )
			[ dataSet setName: anObject ];
		else
			[ dataSet setSelectedDataSource:  [dataSet getDataSourceTypeFromDescription:anObject ] ];
    }
    
    return;
}


// Delegate Methods
//
- (BOOL)tableView:(NSTableView *) aTableView shouldSelectRow:(NSInteger)rowIndex
{
	NSLog(@"DataSetWindowController: shouldSelectRow" );

	if ( selectedDataSet != nil )
	{
		if ( [ selectedDataSet sourceType ] == MANUAL )
		{
			DataSource* selectedSource = [ selectedDataSet selectedSource ];
		
			return [ selectedSource checkUniqueXData ];
		}
	}
	
	return YES;
}



		
#pragma mark PROPERTIES

@synthesize dataSetPanel;
@synthesize dataSourcePopup;
@synthesize fileNameTextField;
@synthesize datasets;

- (DataSet*) selectedDataSet
{
	return selectedDataSet;
}

- (void) setSelectedDataSet: (DataSet*) newDataSet
{	
	if ( newDataSet != nil )
	{
		NSUInteger selectedIndex = [ datasets indexOfObject: newDataSet ];
		
		NSIndexSet* indexSet = [ NSIndexSet indexSetWithIndex: selectedIndex ];
		[ dataSetTableView selectRowIndexes: indexSet byExtendingSelection: NO ];		
	}

	[ self willChangeValueForKey: @"selectedDataSet" ];
	selectedDataSet = newDataSet;
	[ self didChangeValueForKey: @"selectedDataSet" ];

	[ self showSelectedDataSourcePanel ];
	
	return; 
}

@synthesize dataSourceTableView;
@synthesize dataSetTableView;
@synthesize browseFilesButton;
@synthesize dataSourceView;
@synthesize manualDataSetController;
@synthesize isStandalone;
@end

