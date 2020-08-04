//
//  BinaryComponents.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 16/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "PreferencesController.h"

#import "BinaryComponents.h"

@implementation BinaryComponents

#pragma mark INITIALISE 
//
- (id) init
{
	if ( ( self = [super init] ) )
	{
		actualMcCabeThiele = nil;
		
		xAxis.maxValue = 1.0;
		xAxis.minValue = 0.0;
		xAxis.minorTicks = 10;
		xAxis.showMinor = YES;
		xAxis.axisTitle = @"Fractional Composition of Component";
		xAxis.majorTicks = 10;
		
		yAxis.maxValue = 100.0;
		yAxis.minValue = 0.0;
		yAxis.minorTicks = 10;
		yAxis.majorTicks = 10;	 
		yAxis.axisTitle = @"Temperature °C";
		
		backgroundStyle = ALTERNATE_Y;
		title = @"Vapour Liquid Equilibrium Diagram";
	}

	return self;
}


- (id) initWithMcCabeThiele: (McCabeThiele*) mcCabeThiele
{
	if ( ( self = [self init] ) )
    {
		actualMcCabeThiele = mcCabeThiele;
	}
	
	return self;
}


#pragma mark DRAWING 
//
//
- (void) drawGraph:(CGContextRef) gc
{
	BOOL boundaryLinesBuilt;
	
	// Ensure the graph knows about the lastest preference settings.
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];

	// Check the Preferences.
	//
	NSNumber* showMinorIntervals = [ defaults objectForKey: DD_BPShowMinorAxisKey ];
	NSNumber* numberMinorIntervals = [ defaults objectForKey: DD_BPNumberMinorIntervalsKey ];
	self.xAxis.minorTicks = [ numberMinorIntervals intValue ];
	self.xAxis.showMinor = [ showMinorIntervals boolValue ];
	self.yAxis.minorTicks = [ numberMinorIntervals intValue ];
	self.yAxis.showMinor = [ showMinorIntervals boolValue ];
		
	boundaryLinesBuilt = [ self buildBoundaryLines ];	
	
	// Set the Axis Titles
	//
	DataSource* selectedSource = actualMcCabeThiele.selectedDataSet.selectedSource;
	NSString* yAxisTitle = [ NSString stringWithString:@"Temperature (Degrees C)" ];
	NSString* xAxisTitle;
	NSString* graphTitle;
	if ( selectedSource != nil )
	{
		xAxisTitle = [ NSString stringWithFormat:@"Mole Fraction of %@", selectedSource.xColumnData ];
		graphTitle = [ NSString stringWithFormat:@"Boiling Point Diagram of %@/%@", selectedSource.xColumnData, selectedSource.yColumnData ];
	}
	else 
	{
		graphTitle = @"Boiling Point Diagram";
		xAxisTitle = @"Mole Fraction";
	}
	
	self.xAxis.axisTitle = xAxisTitle;
	self.yAxis.axisTitle = yAxisTitle;
	self.title = graphTitle;
	
	self.backgroundColour = NO_GRAPHSTYLE;
	[ self prepareGraphBounds: plotArea ];

	NSRect backgroundArea;
    backgroundArea.origin.x = (float) xMinPosition;
    backgroundArea.origin.y = (float) yMinPosition;
    backgroundArea.size.height = (float) (yMaxPosition - yMinPosition);
    backgroundArea.size.width = (float) (xMaxPosition - xMinPosition);
	
//    [ self drawBackground:gc area:backgroundArea ];
	if ( boundaryLinesBuilt == YES )
		[ self drawEquilibriumLines:gc ];
	
	[ self drawAxisLines:gc ];
	[ self drawAxisTitles:gc ];
	[ self drawTitle: gc ];

	return;
}




- (void) drawEquilibriumLines: (CGContextRef) gc
{	
	// Ensure the graph knows about the lastest preference settings.
	// NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	[ self drawDewBoundary: gc ];
	[ self drawBubbleBoundary: gc ];

	return;
}

- (void) drawDewBoundary: (CGContextRef) gc
{
	// Ensure the graph knows about the lastest preference settings.
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	NSData* colourAsData = [ defaults objectForKey: DD_BPVapourColourKey ];	
	NSColor* vapourColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];
	
	// Draw Dew Line.
	NSBezierPath* dewPath = [ NSBezierPath bezierPath ];
	
	NSPoint startPoint = ((GraphLine*) [ dewBoundary objectAtIndex:0 ]).startPoint;
   [ dewPath moveToPoint: [ self normalisePoint: startPoint ] ];
   
   for ( GraphLine* line in dewBoundary )
   {
	   [dewPath lineToPoint:[ self normalisePoint: line.endPoint ] ];
   }
   
   [dewPath lineToPoint:NSMakePoint(xMaxPosition, yMaxPosition)];
   [dewPath lineToPoint:NSMakePoint(xMinPosition, yMaxPosition)];
   [dewPath lineToPoint: [ self normalisePoint: startPoint ] ];
   
   [ dewPath closePath ];
   [ vapourColour set ];
   [ dewPath fill ];
   
   [[NSColor blackColor] set];	
   [ dewPath stroke ];	
	
	return;
}

- (void) drawBubbleBoundary: (CGContextRef) gc
{
	// Ensure the graph knows about the lastest preference settings.
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	NSData* colourAsData = [ defaults objectForKey: DD_BPLiquidColourKey ];	
	NSColor* liquidColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];
	
	// Draw Dew Line.
	NSBezierPath* bubblePath = [ NSBezierPath bezierPath ];
	
	NSPoint startPoint;
	
	startPoint = ((GraphLine*) [ bubbleBoundary objectAtIndex:0 ]).startPoint;
	[ bubblePath moveToPoint: [ self normalisePoint: startPoint ] ];
	
	for ( GraphLine* line in bubbleBoundary )
	{
		[bubblePath lineToPoint:[ self normalisePoint: line.endPoint ] ];
	}
	
	[bubblePath lineToPoint:NSMakePoint(xMaxPosition, yMinPosition)];
	[bubblePath lineToPoint:NSMakePoint(xMinPosition, yMinPosition)];
	[bubblePath lineToPoint: [ self normalisePoint: startPoint ] ];
	
	[ bubblePath closePath ];
	[ liquidColour set ];
	[ bubblePath fill ];
	
	[[NSColor blackColor] set];	
	[ bubblePath stroke ];	
	
	return;							   
}


//
//
- (BOOL) buildBoundaryLines
{
	CGFloat minTemp;
	CGFloat maxTemp;
							   
	DataSource* selectedSource = actualMcCabeThiele.selectedDataSet.selectedSource;
	
	// Make sure it is sorted correctly.
	[ selectedSource sortDataSet ];

	//	NSMutableArray* dataArray = [ selectedSource data ];
	NSMutableArray* dataArray = [ selectedSource smoothedData ];
		
	if ( dewBoundary == nil )
		dewBoundary = [ [ NSMutableArray alloc ] initWithCapacity: [dataArray count ] ];
	else // Clear out whats already there.
		[ dewBoundary removeAllObjects ];

	if ( bubbleBoundary == nil )
		bubbleBoundary = [ [ NSMutableArray alloc ] initWithCapacity: [dataArray count ] ];
	else // Clear out whats already there.
		[ bubbleBoundary removeAllObjects ];
	
	if ( dataArray == nil )
		return NO;
	else if ( [ dataArray count ] == 0 )
		return NO;
	
	// Find out which way the compositions are going wrt its temperature
	//
	
	// Find the intersection between the Equilibrium Lines and the Qline.
	//
	NSPoint dewStartPoint = NSMakePoint( 0.0, 0.0 );
	NSPoint bubbleStartPoint = NSMakePoint( 0.0, 0.0 );
	NSPoint dewEndPoint;
	NSPoint bubbleEndPoint;
	
	BOOL firstDataItem = YES;
	CGFloat startTemp = [ [ [ dataArray objectAtIndex: 0 ] objectAtIndex: 2 ] floatValue ];
	CGFloat endTemp = [ [ [ dataArray objectAtIndex: dataArray.count-1 ] objectAtIndex: 2 ] floatValue ];
	BOOL swapValues = ( startTemp > endTemp );
	
	for ( NSMutableArray* dataItem in dataArray )
	{		
		NSNumber* xValue = [ dataItem objectAtIndex:0 ];
		NSNumber* x1Value = [ dataItem objectAtIndex:1 ];
		NSNumber* yValue = [ dataItem objectAtIndex:2 ];
		
		if ( swapValues == NO )
		{
			dewEndPoint = NSMakePoint( [ xValue floatValue ], [ yValue floatValue ] );
			bubbleEndPoint = NSMakePoint( [ x1Value floatValue ], [ yValue floatValue ] );	
		}
		else 
		{
			dewEndPoint = NSMakePoint( [ x1Value floatValue ], [ yValue floatValue ] );
			bubbleEndPoint = NSMakePoint( [ xValue floatValue ], [ yValue floatValue ] );
		}

		if ( firstDataItem == NO )
		{
			GraphLine* dewNewLine = [ [ GraphLine alloc ] initWithStartPoint:dewStartPoint endPoint: dewEndPoint ];
			GraphLine* bubbleNewLine = [ [ GraphLine alloc ] initWithStartPoint:bubbleStartPoint endPoint: bubbleEndPoint ];
			
			// Check if the Points are the same and therefore there is no line, just a point.
			//
			if ( NSEqualPoints(dewStartPoint, dewEndPoint) == NO )
				[ dewBoundary addObject: dewNewLine ]; 		
			
			if ( NSEqualPoints(bubbleStartPoint, bubbleEndPoint) == NO )
				[ bubbleBoundary addObject: bubbleNewLine ]; 	
			
			if ( minTemp > [ yValue floatValue ])
				minTemp =  [ yValue floatValue ];
			if ( maxTemp < [ yValue floatValue ])
				maxTemp =  [ yValue floatValue ];			
		}
		else
		{
			firstDataItem = NO;
			minTemp =  [ yValue floatValue ];
			maxTemp =  [ yValue floatValue ];
		}
		
		dewStartPoint = dewEndPoint;
		bubbleStartPoint = bubbleEndPoint;
	}
	
	// Update the graph to the maximum value.
	// Round up to the nearest 10. TBD
	//
	CGFloat gap = ( maxTemp - minTemp ) * 0.05;
	NSDecimalNumber* minValue = [ NSDecimalNumber decimalNumberWithString: [ NSString stringWithFormat: @"%f", minTemp - gap ] ];
	NSDecimalNumber* maxValue = [ NSDecimalNumber decimalNumberWithString: [ NSString stringWithFormat: @"%f", maxTemp + gap ]];
	
	NSDecimalNumberHandler* roundUp = [ NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode: NSRoundUp 
																							  scale: 0
																				   raiseOnExactness: NO
																					raiseOnOverflow: NO
																				   raiseOnUnderflow: NO
																				raiseOnDivideByZero: NO ];
	
	NSDecimalNumberHandler* roundDown = [ NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode: NSRoundDown 
																							  scale: 0
																				   raiseOnExactness: NO
																					raiseOnOverflow: NO
																				   raiseOnUnderflow: NO
																				raiseOnDivideByZero: NO ];									   
									   
	minValue = [ minValue decimalNumberByRoundingAccordingToBehavior: roundDown ];
	maxValue = [ maxValue decimalNumberByRoundingAccordingToBehavior: roundUp ];
		
	yAxis.minValue = [ minValue floatValue ];
	yAxis.maxValue = [ maxValue floatValue ];

	xAxis.minValue = 0.0;
	xAxis.maxValue = 1.0;
							   
	return YES;
}

// Normalise the Data Point into the Coordinates.
// 
- (NSPoint) normalisePoint: (NSPoint) n
{
	// Do nothing since we do not know the graph limits.
	//
	NSPoint point = NSMakePoint( ( (n.x-xAxis.minValue)/(xAxis.maxValue-xAxis.minValue) * xPositionDifference) + xMinPosition, ((n.y-yAxis.minValue)/(yAxis.maxValue-yAxis.minValue)  * yPositionDifference) + yMinPosition );
	return point;
}

@end
