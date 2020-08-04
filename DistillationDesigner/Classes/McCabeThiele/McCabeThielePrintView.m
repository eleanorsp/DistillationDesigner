//
//  McCabeThielePrintView.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 26/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "McCabeThielePrintView.h"

#import "GraphView.h"
#import "McCabeThiele.h"
#import "OptimalMcCabeThiele.h"
#import "PrintPanelViewController.h"

@implementation McCabeThielePrintView


//
//
- (id) initWithBinaryView: (GraphView*) binaryView 
		 mcCabeThieleView: (GraphView*) mcCabeView 
			  optimumView: (GraphView*) optView
				printInfo: (NSPrintInfo *) printInfo
{
	NSRange pageRange;
	NSRect frame;
	
	// Get Useful data out of the print info.
	//
	paperSize = [ printInfo paperSize ];
	leftMargin = [ printInfo leftMargin ];
	topMargin = [ printInfo topMargin ];
	
	binaryComponentsView = binaryView;
	mcCabeThieleView = mcCabeView;
	optimumView = optView;
	
	[ self knowsPageRange: &pageRange ];
	
	// The view must be big enough.
	//
	frame = NSUnionRect( [ self rectForPage: pageRange.location ], [ self rectForPage: NSMaxRange(pageRange) - 1 ]);

	self = [ super initWithFrame:frame ];
	
	// The attributes of the text to be printed.
	//
	textAttributes = [[ NSMutableDictionary alloc ] init];
	[ textAttributes setObject: [NSFont fontWithName:@"Helvetica" size: 10.0 ]
					forKey: NSFontAttributeName ];

	return self;
}



- (BOOL) knowsPageRange: (NSRange *) range
{
	int pageCount = 0;
	range->location = 1;
	
	// NSPrintPanel* printPanel = [ NSPrintPanel printPanel ];
	//PrintPanelViewController* mcCabePrintPanelView = (PrintPanelViewController*) [ printPanel accessoryView ];
	NSPrintOperation* currentOperation = [ NSPrintOperation currentOperation ];
	NSPrintPanel* printPanel = [ currentOperation printPanel ];
	
	NSArray *accessoryControllers = [ printPanel accessoryControllers ];
	for ( NSViewController* accessoryController in accessoryControllers	)
	{
		if ( [ accessoryController isKindOfClass: [ PrintPanelViewController class ] ] == YES )
		{
			PrintPanelViewController* mcCabePrintPanelView = (PrintPanelViewController*) accessoryController;
			if ( mcCabePrintPanelView.printEquilibriumGraph == YES )
				pageCount++;
		
			if ( mcCabePrintPanelView.printMcCabeThieleGraph == YES )
				pageCount++;
			
			if ( mcCabePrintPanelView.printOptimisationGraph == YES )
				pageCount++;
			
			if ( pageCount == 0 )
				range->length = 1;
			else
				range->length = pageCount;
			
			return YES;
		}
	}
	
	// If nothing is setup yet, set up with a maximum three pages.
	//
	range->length = 3;
	
	return YES;
}

- (NSRect) rectForPage: (int) page 
{
	NSRect result;
	result.size = paperSize;
	
	// Page numbers start at 1.
	//
	result.origin.y = (page - 1) * paperSize.height;
	result.origin.x = 0.0;
	
	return result;
}


- (NSRect) rectForView: (int) viewNumber
{
	NSRect result;
	
	result.size.height = paperSize.height - ( topMargin );
	result.size.width = paperSize.width - ( 2 * leftMargin );
	
	result.origin.x = 0;
	result.origin.y	= (viewNumber * paperSize.height);
	
	return result;
}

- (NSRect) rectForGraph: (NSRect) viewRect
{
	NSRect topRect = viewRect;
	topRect.size.height = topRect.size.width;
	topRect.origin.y = topRect.origin.y + ( viewRect.size.height - viewRect.size.width );
	topRect.origin.x = topRect.origin.x + 50;
	
	return topRect;
}

- (void)drawRect:(NSRect)rect 
{
    // Drawing code here.
	int viewCount = 0;
	NSRect drawRect = [ self rectForView: viewCount ];
	NSRect tempRect;

	// Now we want a square rect from the view to draw the graph.
	NSRect bottomRect;
	NSRect topRect;
	
	NSPrintOperation* currentOperation = [ NSPrintOperation currentOperation ];
	NSPrintPanel* printPanel = [ currentOperation printPanel ];
	
	NSArray *accessoryControllers = [ printPanel accessoryControllers ];
	for ( NSViewController* accessoryController in accessoryControllers	)
	{
		if ( [ accessoryController isKindOfClass: [ PrintPanelViewController class ] ] == YES )
		{
			PrintPanelViewController* mcCabePrintPanelView = (PrintPanelViewController*) accessoryController;
			
			if ( mcCabePrintPanelView.printEquilibriumGraph == YES )
			{
				topRect = [ self rectForGraph: drawRect ];	
				if ( binaryComponentsView != nil )
				{
					tempRect = binaryComponentsView.itsGraph.plotArea;
					binaryComponentsView.itsGraph.plotArea = topRect;
					if ( NSIntersectsRect(rect, drawRect ) == YES )
						[ binaryComponentsView drawRect: topRect ];
					
					binaryComponentsView.itsGraph.plotArea = tempRect;
					
					bottomRect = drawRect;
					bottomRect.size.height = drawRect.size.height - topRect.size.height;
					
					viewCount++;
				}
			}
			
			if ( mcCabePrintPanelView.printMcCabeThieleGraph == YES )
			{
				drawRect = [ self rectForView: viewCount ];
				topRect = [ self rectForGraph: drawRect ];	
				if ( mcCabeThieleView != nil )
				{
					tempRect = mcCabeThieleView.itsGraph.plotArea;
					mcCabeThieleView.itsGraph.plotArea = topRect;
					
					if ( NSIntersectsRect(rect, drawRect ) == YES )
						[ mcCabeThieleView drawRect: topRect ];
					
					mcCabeThieleView.itsGraph.plotArea =  tempRect;
					
					bottomRect = drawRect;
					if ( mcCabePrintPanelView.printMcCabeInputData == YES )
					{
						bottomRect.size.height = drawRect.size.height - topRect.size.height;
						bottomRect.origin.x = [ mcCabeThieleView itsGraph ].xMinPosition;
						
						NSString* mcCabeThieleString = [ self buildMcCabeThieleData ];
						[ mcCabeThieleString drawInRect:bottomRect withAttributes:textAttributes ];
					}
					
					if ( mcCabePrintPanelView.printMcCabeResults == YES )
					{
					//	bottomRect = drawRect;
						bottomRect.size.height = drawRect.size.height - topRect.size.height;
						bottomRect.origin.x = [ mcCabeThieleView itsGraph ].xMinPosition;
						
						// Push it further down if the Input data is to be printed.
						//
						if (  mcCabePrintPanelView.printMcCabeInputData == YES)
							bottomRect.origin.y = bottomRect.origin.y - bottomRect.size.height + 170;
						
						//bottomRect.origin.x = [ mcCabeThieleView itsGraph ].xMinPosition;
						
						NSString* mcCabeThieleString = [ self buildMcCabeThieleResultsData ];
						[ mcCabeThieleString drawInRect:bottomRect withAttributes:textAttributes ];
					}
					
					viewCount++;
				}
			}
			
			if ( mcCabePrintPanelView.printOptimisationGraph == YES )
			{	
				drawRect = [ self rectForView: viewCount ];
				topRect = [ self rectForGraph: drawRect ];	
				if ( optimumView != nil )
				{
					tempRect = optimumView.itsGraph.plotArea;
					optimumView.itsGraph.plotArea = topRect;
					
					if ( NSIntersectsRect(rect, drawRect ) == YES )
						[ optimumView drawRect: topRect ];
					
					optimumView.itsGraph.plotArea = tempRect;
					
					bottomRect = drawRect;
					bottomRect.size.height = drawRect.size.height - topRect.size.height;
					bottomRect.origin.x = [ mcCabeThieleView itsGraph ].xMinPosition;
					
					NSString* optimumString = [ self buildOptimumData ];
					[ optimumString drawInRect:bottomRect withAttributes:textAttributes ];
					
					viewCount++;
				}
			}
			
		}
	} // end for
	return;
}

- (NSString*) buildMcCabeThieleData
{
	McCabeThiele* mcCabeThiele = (McCabeThiele*) mcCabeThieleView.itsGraph;
	
	NSString* string = [ NSString localizedStringWithFormat:@"Compositions:\n\tDistillate:\t %5.3f\n\tFeed:  \t %5.3f\n\tBottom:\t %5.3f",
						[ mcCabeThiele.topComp floatValue], [ mcCabeThiele.feedComp floatValue], [ mcCabeThiele.bottomComp floatValue] ];
	NSString* refluxString = [ NSString localizedStringWithFormat:@"\n\nq-Line:\t %7.3f\n\nReflux Ratio:\n\tMinimum Reflux:\t %7.3f\n\tReflux Factor:\t %7.3f\n\tShown Reflux Ratio:\t %7.3f",
							  [ mcCabeThiele.qLine floatValue],[ mcCabeThiele.minRefluxRatio floatValue], 
							  [ mcCabeThiele.optimalRefluxRatioFactor floatValue], [ mcCabeThiele refluxRatio ]];

	
	string = [ string stringByAppendingString:refluxString ];

	return string;
}

- (NSString*) buildMcCabeThieleResultsData
{
	McCabeThiele* mcCabeThiele = (McCabeThiele*) mcCabeThieleView.itsGraph;

	NSString* resultsString = [ NSString localizedStringWithFormat:@"\n\nResults:\n\tNumber of Stages:\t %d\n\tFeed at Stage:\t\t %d",
							   mcCabeThiele.theorecticalStages, mcCabeThiele.feedPointAtStage ];

	return resultsString;
}

- (NSString*) buildOptimumData
{
	OptimalMcCabeThiele* opMcCabeThiele = (OptimalMcCabeThiele*) optimumView.itsGraph;
	
	NSString* string = [ NSString localizedStringWithFormat:@"Number Stages at Total Reflux:\t %d\n",
						opMcCabeThiele.actualMcCabeThiele.stagesAtTotalReflux ];
	
	return string;
}


@end
