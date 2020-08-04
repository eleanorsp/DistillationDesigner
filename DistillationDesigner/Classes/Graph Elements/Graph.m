//
//  Graph.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "Graph.h"
#import "TwoDPlotInformation.h"

@implementation Graph

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialise the graph arrays
        axes = [ [NSMutableArray alloc] init];
		plotDataSets = [ [NSMutableArray alloc] init];
		
		backgroundStyle = ALTERNATE_X;
		backgroundColour = [ NSColor cyanColor];
		
		graphOrSubview = NO;
		title = @"Ethanol/Water";
		tabTitle = @"McCabe Thiele";
		
		plotArea.origin.x = 0;
		plotArea.origin.y = 0;
		plotArea.size.height = 619;
		plotArea.size.width = 638;
    }
    
    return self;
}

//
// Setup the Archiving.
//
// Don't archive any of it 
/*
- (id) initWithCoder:(NSCoder* ) coder
{
    [ super init];
    
    axes = [ coder decodeObject ];
    plotDataSets = [ coder decodeObject ];
    
    [ self setTitle:[ coder decodeObject ] ];
    [ self setTabTitle:[ coder decodeObject ] ];

    [ coder decodeValueOfObjCType:@encode(BOOL) at:&graphOrSubview ];

    [ self setBackgroundColour:[ coder decodeObject ] ];
    [ coder decodeValueOfObjCType:@encode(GraphBackgroundStyle) at:&backgroundStyle ];
    
    // Dont forget to add the rest.

    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
    [ coder encodeObject: [ self axes ] ];
    [ coder encodeObject: [ self plotDataSets ] ];
    [ coder encodeObject: [ self title ] ];
    [ coder encodeObject: [ self tabTitle ] ];
    
    [ coder encodeValueOfObjCType:@encode(BOOL) at:&graphOrSubview ];
    [ coder encodeObject: [ self backgroundColour ] ];
    [ coder encodeValueOfObjCType:@encode(GraphBackgroundStyle) at:&backgroundStyle ];
    
    return;
}
*/

#pragma mark DRAWING 
//
- (void) drawGraph: (CGContextRef) gc
{
	[ self prepareGraphBounds: plotArea ];
	
    CGContextBeginPath( gc );
    CGContextMoveToPoint(gc, 0, 0);
    CGContextAddLineToPoint( gc, 500 + plotArea.origin.x, 500 + plotArea.origin.y);
    CGContextStrokePath( gc );
}

- (void) drawAxisTitles: (CGContextRef) gc
{
	// void.
	return;
}

- (void) drawBackground: (CGContextRef) gc
				   area: (NSRect) rect
{
	// void.
	return;
}

- (void) prepareGraphBounds:(NSRect) rect
{
	// Initial Graph Bounds (5% either side)
    //
	yMinPosition = rect.size.height*0.14 + rect.origin.y;
	yMaxPosition =  rect.size.height*0.96 + rect.origin.y;
	xMinPosition = rect.size.width*0.15 + rect.origin.x;
	xMaxPosition = rect.size.width*0.95 + rect.origin.x;
	xPositionDifference = xMaxPosition - xMinPosition;
	yPositionDifference = yMaxPosition - yMinPosition;
		
	return;
}


- (void) drawTitle: (CGContextRef) gc
{
	CGFloat titleHeight = plotArea.size.height*0.019;
	CGContextSelectFont (gc, 
					 "Gill Sans Light",
					 titleHeight,
					 kCGEncodingMacRoman); 
	CGContextSetCharacterSpacing (gc, 2);
	CGContextSetTextDrawingMode (gc, kCGTextFillStroke);
	CGContextSetRGBFillColor (gc, 0, 0, 0, 1);
	CGContextSetRGBStrokeColor (gc, 0, 0, 0, 1);
	CGAffineTransform myTextTransform = CGAffineTransformMakeRotation(-0.0);
	CGContextSetTextMatrix (gc, myTextTransform);
	
	int textSizeLength = (titleHeight * [ title length ])/3.7;
	CGFloat xCenteredPosition = ( xPositionDifference/2 ) - textSizeLength + xMinPosition;
	
	CGFloat yTopPosition =  yMaxPosition + 10;
	
	CGAffineTransform myYTextTransform = CGAffineTransformMakeRotation(-0.0 );
	CGContextSetTextMatrix (gc, myYTextTransform);
	CGContextShowTextAtPoint (gc, xCenteredPosition, yTopPosition,  [title cStringUsingEncoding:NSASCIIStringEncoding ], [title lengthOfBytesUsingEncoding:NSASCIIStringEncoding] ); 	    

	return;
}




#pragma mark GETS_AND_SETS
//
- (NSString*) title
{
    return title;
}

- (void) setTitle: (NSString*) string
{
    title = string;
    
    return;
}

- (NSString*) tabTitle
{
    return tabTitle;
}

- (void) setTabTitle: (NSString*) string
{
    tabTitle = string;
    
    return;
}


//- (NSMutableArray*) axes
//{
//    return axes;
//}

//- (NSMutableArray*) plotDataSets
//{
//    return plotDataSets;
//}
//
//- (BOOL) isGraphOrSubView
//{
//    return graphOrSubview;
//}

- (void) setBackgroundColour: (NSColor*) colour
{
    backgroundColour = colour;
}

- (NSColor*) backgroundColour
{
    return backgroundColour;
}

//- (GraphBackgroundStyle) backgroundStyle
//{
//    return backgroundStyle;
//}


- (void) setDataSetToPlot:(DataSet*) dataSet
		   select:(BOOL) selectThisSet
{
    TwoDPlotInformation* plotInfoWithDataSet = ( TwoDPlotInformation*) [ self containsDataSet:dataSet ];

    if ( selectThisSet == YES && plotInfoWithDataSet == nil )
    {
	TwoDPlotInformation* newDataPlot = [[ TwoDPlotInformation alloc] initUsingDataSet:dataSet ];
	[ plotDataSets addObject:newDataPlot];
    }
    else if ( selectThisSet == NO && plotInfoWithDataSet != nil )
    {
	[ plotDataSets removeObject:plotInfoWithDataSet ];
    }
    
    return;
}

//
// Check if the Graph is already managing this dataset.
//
- (DataPlotInformation*) containsDataSet:(DataSet*) thisDataSet
{
    DataPlotInformation* plotObject;
	
    for (plotObject in plotDataSets) 
    {
	if ( [ plotObject dataSet ] == thisDataSet )
	    return plotObject;
    }
    
    return nil;
}

// Normalise the Data Point into the Coordinates.
//
- (NSPoint) normalisePoint: (NSPoint) n
{
	// Do nothing since we do not know the graph limits.
	return n;
}

#pragma mark PROPERTIES 
//
@synthesize graphOrSubview;
@synthesize axes;
@synthesize plotDataSets;

@synthesize yMinPosition;
@synthesize yMaxPosition;
@synthesize xMinPosition;
@synthesize xMaxPosition;

@synthesize plotArea;

@synthesize backgroundStyle;

@end
