//
//  PrintPanelViewController.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 23/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "PrintPanelViewController.h"
#import "McCabeThielePrintView.h"

@implementation PrintPanelViewController

- (id) initWithPrintOperation:(NSPrintOperation *)aPrintOperation document:(McCabeThieleDocument *)aDocument 
{
	if (aDocument == nil || aPrintOperation == nil )
		// || (NO == [aDocument respondsToSelector:@selector(setAutoRotate:forPrintOperation:)] && 
		//			   -         nil == [aPrintOperation valueForKeyPath:@"printInfo.dictionary.PDFPrintAutoRotate"])) 
	{
		// [self release];
		self = nil;
	} 
	else if ( ( self = [ super initWithNibName:@"PrintOptionsView" bundle:[NSBundle mainBundle] ] ) )
	{
		printOperation = aPrintOperation;
		mcCabeThieleDocument = aDocument;
	}
	
	printEquilibriumGraph = YES;
	printMcCabeThieleGraph  = YES;
	printMcCabeInputData = YES;
	printMcCabeResults = YES;
	printOptimisationGraph = YES;
	
	return self;
}

+ (void)initialize 
{
//    [self setKeys:[NSArray arrayWithObjects:@"printEquilibriumGraph", @"printMcCabeThieleGraph", nil] triggerChangeNotificationsForDependentKey:@"localizedSummaryItems"];
//    [self setKeys:[NSArray arrayWithObjects:@"representedObject", nil] triggerChangeNotificationsForDependentKey:@"printEquilibriumGraph"];
//	[self setKeys:[NSArray arrayWithObjects:@"representedObject", nil] triggerChangeNotificationsForDependentKey:@"printMcCabeThieleGraph"];
}
	
- (NSString *)nibName 
{
	return @"PrintOptionsView";
}
		
- (void)windowDidLoad 
{
//	[autoRotateButton setState:[self autoRotate] ? NSOnState : NSOffState];
//	[printScalingModeMatrix selectCellWithTag:[self printScalingMode]];
//	[printScalingModeMatrix setEnabled:[document respondsToSelector:@selector(setPrintScalingMode:forPrintOperation:)]];
}

- (NSBundle *)nibBundle 
{
	return [NSBundle mainBundle];
}

- (IBAction) updatePrintView: (id) sender;
{
//	McCabeThielePrintView* printView = ( McCabeThielePrintView* ) [ printOperation view ];
//	[ printView setNeedsDisplay:YES ];
	[self willChangeValueForKey:@"localizedSummaryItems"];
//	[[self valueForKeyPath:@"representedObject.dictionary.printMcCabeThieleGraph"] printMcCabeThieleGraph ];
	[self didChangeValueForKey:@"localizedSummaryItems"];
	
	NSLog(@"view updated" );
}

#pragma mark -
#pragma mark NSPrintPanelAcessorizing Protocol Support
//+
//  Method: keyPathsForValuesAffectingPreview
//
//  Function: Tells "whoever" is observing for the print preview which keys to observe for changes
//-

- (NSSet *) keyPathsForValuesAffectingPreview
{
	return [NSSet setWithObjects: @"printEquilibriumGraph", 
			@"printMcCabeThieleGraph", @"printMcCabeInputData", @"printMcCabeResults", @"printOptimisationGraph", nil ];
				// @"representedObject.horizontalPagination", nil];
}
	
- (NSArray *)localizedSummaryItems 
{
	return [NSArray arrayWithObject: [NSDictionary dictionaryWithObjectsAndKeys: @"printEquilibriumGraph", NSPrintPanelAccessorySummaryItemNameKey,
														[ [ NSNumber numberWithBool: self.printEquilibriumGraph ] stringValue ], NSPrintPanelAccessorySummaryItemDescriptionKey,
													@"printMcCabeThieleGraph", NSPrintPanelAccessorySummaryItemNameKey,
													[ [ NSNumber numberWithBool: self.printMcCabeThieleGraph ] stringValue ],  NSPrintPanelAccessorySummaryItemDescriptionKey,
													@"printMcCabeInputData", NSPrintPanelAccessorySummaryItemNameKey,
													[ [ NSNumber numberWithBool: self.printMcCabeInputData ] stringValue ], NSPrintPanelAccessorySummaryItemDescriptionKey,
													@"printMcCabeResults", NSPrintPanelAccessorySummaryItemNameKey,
													[ [ NSNumber numberWithBool: self.printMcCabeResults ] stringValue ], NSPrintPanelAccessorySummaryItemDescriptionKey,
													@"printOptimisationGraph", NSPrintPanelAccessorySummaryItemNameKey,
													[ [ NSNumber numberWithBool: self.printOptimisationGraph ] stringValue ], NSPrintPanelAccessorySummaryItemDescriptionKey,
													nil]];		
}

	



#pragma mark PROPERTIES

@synthesize printEquilibriumGraph;
@synthesize printMcCabeThieleGraph;
@synthesize printMcCabeInputData;
@synthesize printMcCabeResults;
@synthesize printOptimisationGraph;

@end