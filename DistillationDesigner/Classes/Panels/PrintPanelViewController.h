//
//  PrintPanelViewController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 23/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class McCabeThieleDocument;


@interface PrintPanelViewController : NSViewController <NSPrintPanelAccessorizing>
{
	NSPrintOperation* printOperation;
	McCabeThieleDocument* mcCabeThieleDocument;
	
	Boolean printEquilibriumGraph;
	Boolean printMcCabeThieleGraph;
	Boolean printMcCabeInputData;
	Boolean printMcCabeResults;
	Boolean printOptimisationGraph;
}

- (id)initWithPrintOperation:(NSPrintOperation *)aPrintOperation document:(McCabeThieleDocument *)aDocument;

- (IBAction) updatePrintView: (id) sender;

@property Boolean printEquilibriumGraph;
@property Boolean printMcCabeThieleGraph;
@property Boolean printMcCabeInputData;
@property Boolean printMcCabeResults;
@property Boolean printOptimisationGraph;

@end
