//
//  McCabeThielePrintView.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 26/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GraphView;

@interface McCabeThielePrintView : NSView 
{
	GraphView* binaryComponentsView;
	GraphView* mcCabeThieleView;
	GraphView* optimumView;
	
	NSSize paperSize;
	float leftMargin;
	float topMargin;
	
	NSMutableDictionary* textAttributes;
	
}


- (id) initWithBinaryView: (GraphView*) binaryView 
		 mcCabeThieleView: (GraphView*) mcCabeView 
			  optimumView: (GraphView*) optView
				printInfo: (NSPrintInfo *) printInfo;


- (BOOL) knowsPageRange: (NSRange *) range;
- (NSRect) rectForView: (int) viewNumber;
- (NSRect) rectForPage: (int) page; 
- (NSRect) rectForGraph: (NSRect) viewRect;

- (void) drawRect: (NSRect) r;

// String building routines.
//
- (NSString*) buildMcCabeThieleData;
- (NSString*) buildMcCabeThieleResultsData;
- (NSString*) buildOptimumData;




@end
