//
//  McCabeThiele.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 03/02/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
// 
 
#import "McCabeThiele.h"
#import "PreferencesController.h"

@implementation McCabeThiele


#pragma mark PROPERTIES 
//
@synthesize feedComp;
@synthesize bottomComp;
@synthesize topComp;

@synthesize feedWeightFrac;
@synthesize bottomWeightFrac;
@synthesize topWeightFrac;

@synthesize displayFracType;

@synthesize optimalRefluxRatioFactor;
@synthesize minRefluxRatio;
@synthesize qLine;

@synthesize selectedDataSet;
@synthesize feedBubblePoint;
@synthesize feedTemperature;

@synthesize heatToVapouriseFeed;
@synthesize latentHeatOfFeed;
@synthesize specificHeatOfFeed;
@synthesize theorecticalStages;
@synthesize feedPointAtStage;
@synthesize stagesAtTotalReflux;

@synthesize rectifyingLine;
@synthesize minRefluxLine;


#pragma mark INITIALISE 

- init
{
    if ( (self = [super init] ))
    {
        feedComp = [NSDecimalNumber zero];
        bottomComp = [NSDecimalNumber zero];
        topComp = [NSDecimalNumber zero];
        optimalRefluxRatioFactor = [ NSNumber numberWithDouble: 1.0 ];
        minRefluxRatio = [NSDecimalNumber zero];
        qLine = [NSDecimalNumber zero];

        feedBubblePoint = [NSDecimalNumber zero];
		feedTemperature = [NSDecimalNumber zero];
		
		xAxis.maxValue = 1.0;
		xAxis.minValue = 0.0;
		xAxis.minorTicks = 10;
		xAxis.majorTicks = 10;
		
		yAxis.maxValue = 1.0;
		yAxis.minValue = 0.0;
		yAxis.minorTicks = 10;
		yAxis.majorTicks = 10;	 
		
		backgroundStyle = NO_GRAPHSTYLE;
		displayFracType = DISPLAY_MOL_FRAC; 
		
		lineArray = [ [ NSMutableArray alloc ] init ];
		
		mode = DetermineMinimumRefluxMode;
	}

    return self;
}



#pragma mark DRAWING 

- (void) drawGraph:(CGContextRef) gc
{
	// Check the Preferences.
	//
	NSNumber* showMinor = [  [ NSUserDefaults standardUserDefaults ] objectForKey: DD_ShowMinorAxisKey ];
	NSNumber* numberIntervals = [  [ NSUserDefaults standardUserDefaults ] objectForKey: DD_NumberMinorIntervalsKey ];
	
	self.xAxis.showMinor = [ showMinor boolValue ];
	self.xAxis.minorTicks = [ numberIntervals intValue ];
	self.yAxis.showMinor = [ showMinor boolValue ];
	self.yAxis.minorTicks = [ numberIntervals intValue ];
	
	// Set the Axis Titles
	//
	DataSource* selectedSource = selectedDataSet.selectedSource;
	NSString* xAxisTitle;
	NSString* yAxisTitle;
	NSString* graphTitle;
	
	if ( selectedSource != nil )
	{
		xAxisTitle = [ NSString stringWithFormat:@"Mole Fraction of %@ in Liquid Phase (x)", selectedSource.xColumnData ];
		yAxisTitle = [ NSString stringWithFormat:@"Mole Fraction of %@ in Vapour Phase (y)", selectedSource.xColumnData ];
		graphTitle = [ NSString stringWithFormat:@"McCabe-Thiele for %@/%@ Binary Mixture at Reflux Ratio = %5.3f", selectedSource.xColumnData, selectedSource.yColumnData, [ self refluxRatio ] ];
	}
	else 
	{
		xAxisTitle = @"Mole Fraction in Liquid Phase (x)";
		yAxisTitle = @"Mole Fraction in Vapour Phase (y)";
		graphTitle = @"McCabe-Thiele Diagram";
	}

	self.xAxis.axisTitle = xAxisTitle;
	self.yAxis.axisTitle = yAxisTitle;
	self.title = graphTitle;
	
	[ super drawGraph:gc ];
	[ self drawTitle: gc ];

	[ self drawCompositionLines: gc ];
	[ self drawQLine: gc inMode: mode ];
	[ self drawRectifyingLine: gc inMode: mode ];
	
	if ( mode == DetermineStagesMode )
		[ self drawStages: gc ];

	return;
}

// Normalise the Data Point into the Coordinates.
// 
- (NSPoint) normalisePoint: (NSPoint) n
{
	// Do the points within the bounds.
	//
	return NSMakePoint( (n.x * xPositionDifference) + xMinPosition, (n.y * yPositionDifference) + yMinPosition );
}

// 
/*- (void) drawVapourLiquidBoundary: (CGContextRef) gc
{								 
	NSInteger xDifference = xMaxPosition - xMinPosition;
	NSInteger yDifference = yMaxPosition - yMinPosition;
	CGFloat xPosition;
	CGFloat yPosition;
	
	DataSource* selectedSource = [ selectedDataSet selectedSource ];
	[ selectedSource sortDataSet ];
	
	NSColor* intermediateColour = [ NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:1.0 ];
	[ intermediateColour set ];
	
	CGFloat lastx = xMinPosition;
	CGFloat lasty = yMinPosition;
	
	CGFloat earliestx = 0.0;
	CGFloat earliesty = 0.0;
	int pointCount = 0;
	
	CGContextBeginPath( gc );
	CGContextMoveToPoint( gc, xMinPosition, yMinPosition );

	NSMutableArray* dataArray = [ selectedSource data ];
	for ( NSMutableArray* dataItem in dataArray )
	{
		NSNumber* xValue = [ dataItem objectAtIndex:0 ];
		NSNumber* yValue = [ dataItem objectAtIndex:1 ];
		
		xPosition = ( [ xValue floatValue ] * xDifference ) + xMinPosition;
		yPosition = ( [ yValue floatValue ] * yDifference ) + yMinPosition;
		
	    if ( pointCount == 2 )
		{
			CGContextAddCurveToPoint( gc, earliestx, earliesty, lastx, lasty, xPosition, yPosition );	
			pointCount = 0;
		}
		else
			pointCount++;
		
		earliestx = lastx;
		earliesty = lasty;
		
		lastx = xPosition;
		lasty = yPosition;

	}
	
	if ( pointCount == 1 )
	//	CGContextAddLineToPoint( gc, xPosition, yPosition );	
		CGContextAddQuadCurveToPoint( gc, lastx, lasty, xPosition, yPosition );	
	else if ( pointCount == 2 )
		CGContextAddQuadCurveToPoint( gc, lastx, lasty, xPosition, yPosition );	

	CGContextAddLineToPoint( gc, xMaxPosition, yMaxPosition );	
	CGContextAddLineToPoint( gc, xMinPosition, yMinPosition );
	CGContextClosePath( gc );
	CGContextFillPath( gc );

	return;
}
*/

//
// Draws the Vapur Liquid Boundary from the currently selected data set.
//
- (void) drawVapourLiquidBoundary: (CGContextRef) gc
{
	NSBezierPath* equilibriumPath = [ NSBezierPath bezierPath ];

	NSPoint startPoint;
	
	[equilibriumPath setLineWidth:0.5]; // Has no effect.
	[[NSColor whiteColor] set];
	
	if ( [ self buildEquilibriumLines ] == NO )
	{
		// Just return there's nothing to draw here.
		return;
	}
	
	startPoint = NSMakePoint(xMinPosition, yMinPosition);
	[equilibriumPath moveToPoint: startPoint ];
	
	for ( GraphLine* line in lineArray )
	{
		[equilibriumPath lineToPoint:[ self normalisePoint: line.endPoint ] ];
	}
//	[equilibriumPath setFlatness:20.7];
    
	[equilibriumPath lineToPoint:NSMakePoint(xMaxPosition, yMaxPosition)];
	[equilibriumPath lineToPoint:NSMakePoint(xMinPosition, yMinPosition)];

	[ equilibriumPath closePath ];
	[ equilibriumPath fill ];
	[[NSColor blackColor] set];	
	[ equilibriumPath stroke ];
	
	/*
	// Try the append.
	NSBezierPath* equilibriumTestPath = [ NSBezierPath bezierPath ];
	[equilibriumTestPath setFlatness:10.6];

	[equilibriumTestPath setLineWidth:0.5]; // Has no effect.
	
	NSPointArray points;
	
	// The extra 3 are for start, end and back to start.
	//
	points = (NSPoint *) calloc([lineArray count] + 3, sizeof(NSPoint));
	
	int i = 0;
	points[i] = NSMakePoint(xMinPosition, yMinPosition);
	i++; // Increment.
	
	for ( GraphLine* line in lineArray )
	{
		points[i] = [ self normalisePoint: line.endPoint ];
		i++;
	}
	//	[equilibriumPath setFlatness:20.7];
    
	points[i] = NSMakePoint(xMaxPosition, yMaxPosition);
	i++;
	points[i] = NSMakePoint(xMinPosition, yMinPosition);
	i++;

	[ equilibriumTestPath appendBezierPathWithPoints: points count:i ];
	[[NSColor redColor] set];	
	[ equilibriumTestPath stroke ];
	
	free( points );
	*/
	
	return;
}


// Build the plotting lines from the Equilibrium data.
// (note this is in real data not the graph coordinates.
//
- (BOOL) buildEquilibriumLines
{
	NSLog( @"McCabeThiele: buildEquilibriumLines" );
	DataSource* selectedSource = [ selectedDataSet selectedSource ];
	
	// Make sure it is sorted correctly.
	// [ selectedSource sortDataSet ];
	NSMutableArray* dataArray = [ selectedSource smoothedData ];
	
	if ( dataArray == nil )
		return NO;
	
	if ( lineArray == nil )
		lineArray = [ [ NSMutableArray alloc ] initWithCapacity: [dataArray count ] ];
	else // Clear out whats already there.
		[ lineArray removeAllObjects ];
	
	// Find the intersection between the Equilibrium Lines and the Qline.
	//
	NSPoint startPoint = NSMakePoint( 0.0, 0.0 );
	for ( NSMutableArray* dataItem in dataArray )
	{		
		NSNumber* xValue = [ dataItem objectAtIndex:0 ];
		NSNumber* yValue = [ dataItem objectAtIndex:1 ];
		
		NSPoint endPoint = NSMakePoint( [ xValue floatValue ], [ yValue floatValue ] );
		GraphLine* newLine = [ [ GraphLine alloc ] initWithStartPoint:startPoint endPoint: endPoint ];
		
		// Check if the Points are the same and therefore there is no line, just a point.
		//
		if ( NSEqualPoints(startPoint, endPoint) == NO )
			[ lineArray addObject: newLine ]; 
		
		startPoint = endPoint;
	}

	return YES;
}

// 
// Draws the Background Vapour and Liquid Colours as well as
// the Vapour/Liquid Boundary.
//
- (void) drawBackground: (CGContextRef) gc
		   area: (NSRect) rect
{
	[ super drawBackground:gc area:rect ];

	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	CGContextBeginPath( gc );
	[ [ NSColor blackColor ] set ];
	CGContextMoveToPoint( gc, xMinPosition, yMinPosition );
	CGContextAddLineToPoint( gc, xMaxPosition, yMaxPosition );	
	CGContextStrokePath( gc );
	
	NSData* colourAsData = [ defaults objectForKey: DD_LiquidColourKey ];	
	NSColor* liquidColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];

	[ liquidColour set ];
	
	CGContextBeginPath( gc );
	CGContextMoveToPoint( gc, xMinPosition, yMinPosition );
	CGContextAddLineToPoint( gc, xMaxPosition, yMaxPosition );
	CGContextAddLineToPoint( gc, xMaxPosition, yMinPosition );		
	CGContextAddLineToPoint( gc, xMinPosition, yMinPosition );		
	CGContextClosePath( gc );
	CGContextFillPath( gc );
	
	colourAsData = [ defaults objectForKey: DD_VapourColourKey ];	
	NSColor* vapourColour = [ NSUnarchiver unarchiveObjectWithData:colourAsData ];
	[ vapourColour set ];
	
	CGContextBeginPath( gc );
	CGContextMoveToPoint( gc, xMinPosition, yMinPosition );
	CGContextAddLineToPoint( gc, xMaxPosition, yMaxPosition );
	CGContextAddLineToPoint( gc, xMinPosition, yMaxPosition );		
	CGContextAddLineToPoint( gc, xMinPosition, yMinPosition );		
	CGContextClosePath( gc );
	CGContextFillPath( gc );	
	
	[ self drawVapourLiquidBoundary: gc ];
	
	return;
}

//
// Draws the Top Line
//
- (void) drawRectifyingLine: (CGContextRef) gc inMode: (DesignMode) temp
{
	CGContextBeginPath( gc );
	
	if ( mode == DetermineMinimumRefluxMode )
	{
		[ [ NSColor redColor ] set ];
	
		CGContextSetLineDash ( gc, 0, nil, 0);
		CGContextSetLineWidth( gc, [ xAxis majorLineThickness ] *.8);
	
		NSPoint normalisedPoint = [ self normalisePoint: minRefluxLine.startPoint ];
		CGContextMoveToPoint( gc, normalisedPoint.x,  normalisedPoint.y );

		normalisedPoint = [ self normalisePoint: minRefluxLine.endPoint ];
		CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
		CGContextStrokePath( gc ); 
		
		// Draw the rectifyingLine if it has been calculcated.
		//
		if ( rectifyingLine != nil )
		{
			CGContextBeginPath( gc );

			[ [ NSColor blueColor ] set ];

			CGFloat dash[] = { 1, 3 }; 
			CGContextSetLineDash ( gc,  1, dash, 2  );
			CGContextSetLineWidth( gc, [ xAxis majorLineThickness ] *.8);
			
			NSPoint normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
			CGContextMoveToPoint( gc, normalisedPoint.x,  normalisedPoint.y );
			
			normalisedPoint = [ self normalisePoint: rectifyingLine.endPoint ];
			CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
			CGContextStrokePath( gc ); 			
		}
	}
	else // DetermineStagesMode
	{
		// Draw the rectifying line if present.
		//
		[ [ NSColor blackColor ] set ];

		CGContextSetLineWidth( gc, [ xAxis majorLineThickness ] *.8);
		
		NSPoint normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
		CGContextMoveToPoint( gc, normalisedPoint.x,  normalisedPoint.y );
		
		normalisedPoint = [ self normalisePoint: rectifyingLine.endPoint ];
		CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
	
		// Now the Stripping Line
		//
		if ( strippingLine != nil )
		{
			NSPoint normalisedPoint = [ self normalisePoint: strippingLine.endPoint ];
			CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
		}
		CGContextStrokePath( gc ); 
	}
	
	return;
}


//
// Draws the Vertical Compositions Lines for Bottom, Feed and Distillate.
//
- (void) drawCompositionLines: (CGContextRef) gc
{
	NSInteger xDifference = xMaxPosition - xMinPosition;
	NSInteger yDifference = yMaxPosition - yMinPosition;

	CGFloat dash[] = { 4, 1 }; 

	if ( [ feedComp floatValue ] > 0 )
	{
		CGContextBeginPath( gc );
		CGContextSetRGBStrokeColor ( gc, 0, .5, 0, 1 );
		CGContextSetLineDash ( gc,  1, dash, 2  );
		CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]+0.3);
		
		CGFloat xValue = xDifference* [feedComp floatValue ] + xMinPosition;
//		CGFloat yValue = yMaxPosition;
		CGFloat yValue = yDifference* [feedComp floatValue ] + yMinPosition;
		
		CGContextMoveToPoint( gc, xValue, yMinPosition );
		CGContextAddLineToPoint( gc, xValue, yValue );		
		CGContextStrokePath( gc ); 
	}

	if ( [ bottomComp floatValue ] > 0 )
	{
		CGContextBeginPath( gc );
		CGContextSetRGBStrokeColor ( gc, 0, .5, 0, 1 );
		CGContextSetLineDash ( gc,  1, dash, 2  );
		CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]+0.3);
		
		CGFloat xValue = xDifference* [ bottomComp floatValue ] + xMinPosition;
		//CGFloat yValue = yMaxPosition;
		CGFloat yValue = yDifference* [ bottomComp floatValue ] + yMinPosition;
		
		CGContextMoveToPoint( gc, xValue, yMinPosition );
		CGContextAddLineToPoint( gc, xValue, yValue );		
		CGContextStrokePath( gc ); 
	}

	if ( [ topComp floatValue ] > 0 )
	{
		CGContextBeginPath( gc );
		CGContextSetRGBStrokeColor ( gc, 0, .5, 0, 1 );
		CGContextSetLineDash ( gc,  1, dash, 2  );
		CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]+0.3);
		
		CGFloat xValue = xDifference* [ topComp floatValue ] + xMinPosition;
//		CGFloat yValue = yMaxPosition;
		CGFloat yValue = yDifference* [ topComp floatValue ] + yMinPosition;
		
		CGContextMoveToPoint( gc, xValue, yMinPosition );
		CGContextAddLineToPoint( gc, xValue, yValue );		
		CGContextStrokePath( gc ); 
	}
	
	return;
}


- (void) drawStages: (CGContextRef) gc
{	
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	NSData* colourAsData = [ defaults objectForKey: DD_StageLineColourKey ];	
	NSColor* stageLineColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];
	
	colourAsData = [ defaults objectForKey: DD_StageFillColourKey ];	
	NSColor* fillStageColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];
	
	NSBezierPath* stagesPath = [ NSBezierPath bezierPath ];

	[stagesPath setLineWidth:0.5]; // Has no effect.
		
	NSPoint normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
	[ stagesPath moveToPoint:normalisedPoint ];
	
	for ( GraphLine* line in stageArray )
	{
		normalisedPoint = [ self normalisePoint: line.endPoint ];
		[stagesPath lineToPoint:normalisedPoint ];
	}
    
	NSNumber* fillstages = [  [ NSUserDefaults standardUserDefaults ] objectForKey: DD_FillStagesKey ];
	BOOL fillStagesWithColour = [ fillstages boolValue ];
	if ( fillStagesWithColour == YES )
	{
		[ fillStageColour set ];
		normalisedPoint = [ self normalisePoint: strippingLine.endPoint ];
		//	CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
		[ stagesPath lineToPoint: normalisedPoint ];
		
		normalisedPoint = [ self normalisePoint: strippingLine.startPoint ];
		//	CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
		[ stagesPath lineToPoint: normalisedPoint ];
		
		normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
		// CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
		[ stagesPath lineToPoint: normalisedPoint ];
		
		[ stagesPath closePath ];
		[ stagesPath fill ];

	}
	
	[ stageLineColour set];
	[ stagesPath stroke ];
		
	//CGContextSetLineDash ( gc, 0, nil, 0);
	//CGContextSetLineWidth( gc, [ xAxis majorLineThickness ] + 0.2 );
	
	//NSPoint normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
	//CGContextMoveToPoint( gc, normalisedPoint.x,  normalisedPoint.y );
	
	//for ( GraphLine* line in stageArray )
	//{
	//	normalisedPoint = [ self normalisePoint: line.endPoint ];
	//	CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
	//}

	//normalisedPoint = [ self normalisePoint: strippingLine.endPoint ];
	//CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );

	//normalisedPoint = [ self normalisePoint: strippingLine.startPoint ];
	//CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );

	//normalisedPoint = [ self normalisePoint: rectifyingLine.startPoint ];
	//CGContextAddLineToPoint( gc, normalisedPoint.x,normalisedPoint.y );
	
	

	return;
}


#pragma mark CALCULATIONS 
//
// Calculation Routines.
//
//
// Determine the RectifyLine based on the mode which we find ourselves.
// 
- (BOOL) calcRectifyingLine
{	
	
	rectifyingLine = nil;
	strippingLine = nil;
	
	if ( topComp != nil )
	{
		CGFloat xValue = [ topComp floatValue ];
		CGFloat yValue = [ topComp floatValue ];
		
		rectifyingLine = [ [ GraphLine alloc ] init ];
		
		rectifyingLine.startPoint = NSMakePoint(xValue, yValue);
		
		if ( mode == DetermineMinimumRefluxMode )
		{
			if ( [ optimalRefluxRatioFactor doubleValue ] >= 1.0 )
			{
				CGFloat thetaValue = [ topComp floatValue ] / ( 1 + self.refluxRatio );
				
				// Determine the intersection between the QLine and the rectifyling line.
				//
				rectifyingLine.endPoint = NSMakePoint(0.0, thetaValue);
			}
			else
				rectifyingLine = nil;
		}
		else 
		{
			CGFloat thetaValue = [ topComp floatValue ] / ( 1 + self.refluxRatio );
			
			// Determine the intersection between the QLine and the rectifyling line.
			//
			rectifyingLine.endPoint = NSMakePoint(0.0, thetaValue);
			
			NSPoint intersectionPoint;
			if ( [ rectifyingLine determineIntersectionPoint: qLineLine intersectionPoint: &intersectionPoint ] == YES )
			{
				rectifyingLine.endPoint = intersectionPoint;
				
				if ( bottomComp == nil || [ bottomComp floatValue ] == 0.0 )
					return NO;
				
				// Now calculate the stripping section.
				//
				if ( strippingLine == nil )
					strippingLine = [ [ GraphLine alloc ] init ];
				
				strippingLine.startPoint = intersectionPoint;
				strippingLine.endPoint = NSMakePoint( [ bottomComp floatValue ], [ bottomComp floatValue ] );
				
				return YES;
			}
			else
				return NO;
		}
		
		return YES;
	}
	else
	{
		rectifyingLine.endPoint = NSMakePoint(xMinPosition, yMinPosition);
		rectifyingLine.startPoint = NSMakePoint(xMinPosition, yMaxPosition);
		
		return NO;
	}
}

- (BOOL) calcTheorecticalStages
{	
	[ self setMode: DetermineStagesMode ];
	
	if ( [ self calcRectifyingLine ] == YES )
	{
		stageArray = [ [ NSMutableArray alloc ] init ];

		CGFloat xComp = [ topComp floatValue ];	
		NSPoint startPoint = NSMakePoint( xComp, xComp );
		NSMutableArray* thePoints = [ [ NSMutableArray alloc ] init ];
		
		int count = 0;
		self.feedPointAtStage = 0;
		self.theorecticalStages = 0;
		while ( xComp > [ bottomComp floatValue ] )
		{
			GraphLine* horizontalLine = [ [ GraphLine alloc ] init ];
			horizontalLine.startPoint = startPoint;
			horizontalLine.endPoint = NSMakePoint( 0.0, startPoint.y );
			
			// Find out where the horizontalLine intersects the Equilibrium line.
			//
			// NSLog( @"calcTheorecticalStages: intersection point %d", [ thePoints count ] );
			if ( [ horizontalLine determineIntersectionPoints: lineArray intersectionPoints: thePoints ] == YES )
			{
				NSPoint endPoint = [[ thePoints objectAtIndex:0 ] pointValue];
				horizontalLine.endPoint = endPoint;
				
				GraphLine* verticalLine = [ [ GraphLine alloc ] init ];
				verticalLine.startPoint = endPoint;
				verticalLine.endPoint = NSMakePoint( endPoint.x, endPoint.x );
				
				// Find out where the horizontalLine intersects the Rectifying Line.
				//
				if ( endPoint.x > rectifyingLine.endPoint.x )
				{
					// We are still in the rectifying section.
					//
					NSPoint intersectionPoint;
					if ( [ verticalLine determineIntersectionPoint: rectifyingLine intersectionPoint: &intersectionPoint ] == YES )
					{
						verticalLine.endPoint = intersectionPoint;
					}
					else
					{
						// WHAT we cannot get here...!
						NSLog( @"Error intersection in endPoint->x" );
					}
				}
				// Find out where the horizontalLine intersects the Stripping Line.
				//
				else if ( endPoint.x > strippingLine.endPoint.x &&
						  endPoint.x < strippingLine.startPoint.x )
				{
					// We are still in the rectifying section.
					//
					NSPoint intersectionPoint;
					if ( [ verticalLine determineIntersectionPoint: strippingLine intersectionPoint: &intersectionPoint ] == YES )
					{
						verticalLine.endPoint = intersectionPoint;
					}
					else
					{
						// WHAT we cannot get here...!
						NSLog( @"Error intersection 2 in endPoint->x" );
					}					
				}
				else // We are passed the Bottom Comp.
					verticalLine.endPoint = NSMakePoint( endPoint.x, endPoint.x );
				
				// Add the lines to the stage array.
				[ stageArray addObject: horizontalLine ];
				[ stageArray addObject: verticalLine ];
				count++;

				// Track where the feed Point has been crossed. 
				if ( endPoint.x < rectifyingLine.endPoint.x && startPoint.x > rectifyingLine.endPoint.x )
					self.feedPointAtStage = count;
				
				if ( endPoint.x < [ bottomComp floatValue ] )
				{
					self.theorecticalStages = count;
					return YES;
				}
				else if ( count > 10000 ) // WOW!!!!!!
				{
					return NO;
				}
				else
				{
					xComp = endPoint.x;
					startPoint = verticalLine.endPoint; // Move to the next step.
				}
			}
			else
			{
				// NO! Do something here cause this cannot happen.....
				return NO;
			}
		}
	}
	
	return NO;
}

- (BOOL) calcTheorecticalStagesAtTotalReflux
{
	McCabeThiele* tempMcCabeThiele = [ self copy ];
	
	tempMcCabeThiele.optimalRefluxRatioFactor = [ NSNumber numberWithDouble:10000000 ];
	if ( [ tempMcCabeThiele calcTheorecticalStages ] == YES )
	{	
		self.stagesAtTotalReflux = tempMcCabeThiele.theorecticalStages;
		return YES;
	}
	
	return NO;
}

- (void) drawQLine: (CGContextRef) gc inMode: (DesignMode) temp
{
	if ( qLine == nil )
		return;
	
	NSPoint startPoint = [ self normalisePoint: qLineLine.startPoint ];
	NSPoint endPoint = [ self normalisePoint: qLineLine.endPoint ];
	
	CGContextBeginPath( gc );
	CGContextMoveToPoint( gc, startPoint.x, startPoint.y );
	
	if ( temp == DetermineMinimumRefluxMode )
		[ [ NSColor redColor ] set ];
	else
	{
		[ [ NSColor blueColor ] set ];
		CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]/2 );
		CGContextSetLineDash ( gc, 0, nil, 0);
	}
	
	CGContextAddLineToPoint( gc, endPoint.x, endPoint.y );
	CGContextStrokePath( gc ); 
	
	return;
}


- (BOOL) calculateQLine
{
	CGFloat x1;
	CGFloat y1;

	qLineLine = nil; // Reset the QLine Line.
	
	if ( qLine == nil )
	 return NO;
	
	if ( qLineLine == nil )
		qLineLine = [ [ GraphLine alloc ] init ];
	 
	double qSlope = [ self qSlope ];
	double c = [ feedComp floatValue] - qSlope*[ feedComp floatValue];
	
	if ( qSlope < 1.0 && qSlope > 0.0 )
	{
		x1 = 0.0;
		y1 = c;
		//(qSlope * ([ feedComp floatValue])) + [ feedComp floatValue] + c;
	}
	else if ( qSlope == 0.0 )
	{
		y1 = [ feedComp floatValue ];
		x1 = 0.0;
	}
	else
	{
		y1 = 1.0;
		x1 = ( (y1 - [ feedComp floatValue ])/qSlope ) + [ feedComp floatValue ];
	}
	qLineLine.startPoint = NSMakePoint( [feedComp floatValue ], [feedComp floatValue ] );
	qLineLine.endPoint = NSMakePoint( x1, y1 );
	

	// Find the temporary limit of the qLine.
	//
	DataSource* selectedSource = [ selectedDataSet selectedSource ];
	// [ selectedSource sortDataSet ];
	NSMutableArray* dataArray = [ selectedSource smoothedData ];
	NSPoint startPoint = NSMakePoint( 0.0, 0.0 );	
	
	// Find the intersection between the Equilibrium Lines and the Qline.
	//
	NSMutableArray* lines = [ [ NSMutableArray alloc ] initWithCapacity: [dataArray count ] ];
	for ( NSMutableArray* dataItem in dataArray )
	{		
		NSNumber* xValue = [ dataItem objectAtIndex:0 ];
		NSNumber* yValue = [ dataItem objectAtIndex:1 ];

		NSPoint endPoint = NSMakePoint( [ xValue floatValue ], [ yValue floatValue ] );
		GraphLine* newLine = [ [ GraphLine alloc ] initWithStartPoint:startPoint endPoint: endPoint ];
		
		[ lines addObject: newLine ];
		
		startPoint = endPoint;
	}
			
	NSMutableArray* thePoints = [ [ NSMutableArray alloc ] init ];
	if ( [ qLineLine determineIntersectionPoints: lines intersectionPoints: thePoints ] == YES )
	{
		// Assume only one intersection point...
		//
		qLineLine.startPoint = NSMakePoint( [feedComp floatValue ], [feedComp floatValue ] );

		NSPoint intersectionPoint = [[ thePoints objectAtIndex:0 ] pointValue];		
		qLineLine.endPoint = NSMakePoint( intersectionPoint.x, intersectionPoint.y );
		
		return YES;
	}

	// Nothing found so keep the qLine to the Boundary.
	//	
	return NO;
}

- (BOOL) calculateMinReflux
{	
	// Reset the minReflux Information.
	//
	minRefluxRatio = nil;
	badMinRefluxIntersectionPoints = nil;
	
	// Check to see if the qLineLine has been determined.
	//
	// if ( qLineLine == nil )
		if ( [ self calculateQLine ] == NO )
			return NO;
	
	// Check if the composition has been set.
	//
	if ( topComp != nil && [ topComp floatValue ] != 0.0 )
	{
		minRefluxLine = [ [ GraphLine alloc ]  init ];
		badMinRefluxIntersectionPoints = [ [ NSMutableArray alloc ] init ];
		
		minRefluxLine.startPoint = NSMakePoint( [ topComp floatValue ], [ topComp floatValue ] );
		minRefluxLine.endPoint = qLineLine.endPoint;
		
		// 
		CGFloat gradient = minRefluxLine.gradient;
		if ( gradient < 0.0 )
		{
			gradient = 0.0;
			
			minRefluxLine.endPoint = NSMakePoint( qLineLine.endPoint.x, [ topComp floatValue ] );
		}
		
		// Now calc y where x = 0;
		CGFloat c = (minRefluxLine.startPoint.x ) * gradient;
		CGFloat yatxzero = minRefluxLine.startPoint.y - c;
		
		[ self setMinRefluxAtYAtXzero: yatxzero ];
		
		CGFloat otherGradient = 1.0; // Set at total reflux.
		CGFloat newGradient = gradient;
		CGFloat oldGradient = otherGradient;
		NSLog(@"Gradient %f  otherGradient: %f\n", newGradient, otherGradient );

		do
		{	
			// Now check for any bad intersection points.
			//
			[ minRefluxLine determineIntersectionPoints: lineArray intersectionPoints: badMinRefluxIntersectionPoints ];
			
			Boolean intersectsRightOfQline = NO;	
			int index;
			for ( index = 0; index < [ badMinRefluxIntersectionPoints count ]; index++ )
			{
				NSPoint point = [[ badMinRefluxIntersectionPoints objectAtIndex:index ] pointValue];

				// Check if the point is to the right the qLine
				//
				if ( point.x > qLineLine.endPoint.x )
				{
					// It is then update the minRefluxLine with a new gradient.
					
					intersectsRightOfQline = YES;
					break; // From for loop.
				}
			}
			
			oldGradient = newGradient;
			if ( intersectsRightOfQline == NO )
			{
				// Plot a new gradient
				
				// Define a new distillate line.
				newGradient = (gradient + newGradient)/2;
				otherGradient = oldGradient;
			}
			else
			{
				newGradient = (newGradient + otherGradient)/2;
			}
			
			// Now calc y where x = 0;
			CGFloat val = (minRefluxLine.startPoint.x ) * newGradient;
			yatxzero = minRefluxLine.startPoint.y - val;
			[ self setMinRefluxAtYAtXzero: yatxzero ];

			NSLog(@"Gradient %f  otherGradient: %f\n", newGradient, otherGradient );
			minRefluxLine.endPoint = NSMakePoint(0.0, yatxzero);
		}
		while ( fabs(oldGradient - newGradient) > 0.00001 );	
	}

	minRefluxCalculated = YES;
	
	return YES;
}



	
- (void) updateOnHeatInfoEnteredDirectly
{	
	if ( [ [ feedComp stringValue ] length ] == 0 )
		return;
	
	double feedComp1 = [ feedComp doubleValue ];
	//
	// Try to calculate the Latent Heat of Feed
	//
	if ( selectedDataSet.selectedSource.xLatentHeat != nil && selectedDataSet.selectedSource.yLatentHeat != nil  )
	{
		double feedLatentHeat = ( [ selectedDataSet.selectedSource.xLatentHeat doubleValue ] * feedComp1 ) +
								 ( [ selectedDataSet.selectedSource.yLatentHeat doubleValue ] * ( 1 - feedComp1 ) );
		
		self.latentHeatOfFeed = feedLatentHeat; 
	}
	
	//
	//
	// Try to calculate the Specific Heat of Feed
	// 
	if ( selectedDataSet.selectedSource.xSpecificHeat != nil && selectedDataSet.selectedSource.ySpecificHeat != nil )
	{
		self.specificHeatOfFeed = ( [ selectedDataSet.selectedSource.xSpecificHeat doubleValue] * feedComp1 ) +
								   ( [ selectedDataSet.selectedSource.ySpecificHeat doubleValue ] * ( 1 - feedComp1 ) );
	}
	
	heatToVapouriseFeed = 0.0;
	if ( [ [ feedBubblePoint stringValue ] length ] != 0 &&
		[ [ feedTemperature stringValue ] length ] != 0  )
	{
		CGFloat bubbleTempValue = [ feedBubblePoint doubleValue ];
		CGFloat feedTempValue = [ feedTemperature doubleValue ];

		self.heatToVapouriseFeed = latentHeatOfFeed  + ( ( bubbleTempValue - feedTempValue ) * specificHeatOfFeed);
	}

	self.qLine = [ NSNumber numberWithDouble:  heatToVapouriseFeed /  latentHeatOfFeed   ];	

	return;
}

- (void) updateQInfoEnteredDirectly
{	
	self.qLine = [ NSNumber numberWithDouble: heatToVapouriseFeed/latentHeatOfFeed ];
	
	return;
}


// Given a manual minRefluxLine being entered, this will
// redraw the refluxline to its new position.
//
- (BOOL) rebuildMinRefluxLine
{
	if ( minRefluxLine == nil )
		minRefluxLine = [[ GraphLine alloc ] init ];
	
	minRefluxLine.startPoint = NSMakePoint( [ topComp floatValue ], [ topComp floatValue ] );
	
	// Find the new point at x = 0;
	CGFloat yatxzero = [ topComp floatValue ] / ( 1 + [ minRefluxRatio floatValue ] );
	minRefluxLine.endPoint = NSMakePoint( 0.0, yatxzero );
	
	// Find the intersection point at the QLine.
	NSPoint intersectionPoint;
	if ( [ minRefluxLine determineIntersectionPoint: qLineLine intersectionPoint: &intersectionPoint ] == YES )
		minRefluxLine.endPoint = intersectionPoint;
	
	return YES;
}

//
// Gets and Sets.
//
- (double) qSlope
{
	if ( qLine != nil )
	{
		return [ qLine doubleValue ] / ([ qLine doubleValue ] - 1 );
	}
	
	return 0;
}

//
// Calculate the Reflux Ratio based on the minimum value and the user defined optimal value.
//
- (double) refluxRatio
{
	if ( self.minRefluxRatio != nil && [ self.minRefluxRatio floatValue ] > 0 &&
		self.optimalRefluxRatioFactor != nil && [ self.optimalRefluxRatioFactor floatValue ] > 1.0 )
	{
		return [ self.minRefluxRatio floatValue ] * [ self.optimalRefluxRatioFactor floatValue ];
	}
	else
		return 0.0;
}


//
// Set the Min Reflux Ratio Line and calculate the miniumum reflux.
//
- (CGFloat) setMinRefluxAtYAtXzero: (CGFloat) yAtXzero
{
	if ( topComp == nil || [ topComp floatValue ] == 0.0 )
		return 0.0;
	
//	rectifyingLine = nil;
	
	NSPoint topPoint = NSMakePoint( [ topComp floatValue], [ topComp floatValue ] );

	if ( yAtXzero < 0.0 )
		yAtXzero = 0.0;
	else if ( yAtXzero > [ topComp floatValue ] )
		yAtXzero = [ topComp floatValue ];
	
	NSPoint xZeroPoint = NSMakePoint( 0.0, yAtXzero );

	minRefluxLine = [ [ GraphLine alloc ] initWithStartPoint: topPoint endPoint: xZeroPoint ];
	
	CGFloat minRefluxValue = ( [ topComp  floatValue ] /  yAtXzero ) - 1;
	self.minRefluxRatio = [ NSNumber numberWithFloat: minRefluxValue ] ;
	
	return minRefluxValue;
}

- (void) setMode: (DesignMode) newMode
{
	mode = newMode;
	
	if ( mode == DetermineMinimumRefluxMode )
	{
		// Recalculate the QLine.
		//
		// Reset the mode to determine the minimum reflux.
		//	mcCabeThiele.mode = DetermineMinimumRefluxMode;
		//	[ mcCabeThiele buildEquilibriumLines ];
		if ( [ self calculateQLine ] == YES )
		{
			// Then force the Graph to redraw.
			//
			[ self calcRectifyingLine ];
		}

		// Clear out the other lines.
		//
		[ stageArray removeAllObjects ];
	}
	
	return;
}

- (DesignMode) getMode
{
	return mode;
}


- (BOOL) canCalculateQLine
{
	if ( [ feedComp doubleValue ] == 0.0 )
		return NO;

	if ( [ topComp doubleValue ] == 0.0 )
		return NO;

    if ( [ topComp doubleValue ] < [ feedComp doubleValue ] )
		return NO;
	if ( [ feedComp doubleValue ] < [ bottomComp doubleValue ] )
		return NO;
	
	return YES;
}


- (BOOL) canCalculateStages
{
	if ( displayFracType == DISPLAY_WEIGHT_WEIGHT )
	{
		if ( selectedDataSet.selectedSource.xMolecularWeight == nil ||
			 selectedDataSet.selectedSource.yMolecularWeight == nil )
			return NO;
		
		if ( topWeightFrac == nil || bottomWeightFrac == nil || feedWeightFrac == nil )
			return NO;
	}
		
	if ( [ self canCalculateQLine ] == NO )
		return NO;
	
	if ( [ bottomComp doubleValue ] == 0.0 )
		return NO;
	
	if ( [ minRefluxRatio doubleValue ] == 0.0 )
		return NO;
	
	if ( [ optimalRefluxRatioFactor doubleValue ] == 1.0 )
		return NO;
	
	if ( selectedDataSet == nil ) 
		return NO;
	
	return YES;
}

- (BOOL) calcOtherAssociatedFractionFrom: (NSNumber*) fraction
{
	if ( selectedDataSet.selectedSource.xMolecularWeight == nil && 
		 selectedDataSet.selectedSource.yMolecularWeight == nil )
		return NO;
	
	if ( displayFracType == DISPLAY_MOL_FRAC )
	{
		if ( fraction == feedComp )
		{
			self.feedWeightFrac = [ self convertFractionFrom: fraction 
												fractionType: displayFracType 
										 molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
											molWeightOfOther: selectedDataSet.selectedSource.yMolecularWeight ];
		}
		else if ( fraction == topComp )
		{
			self.topWeightFrac = [ self convertFractionFrom: fraction 
											   fractionType: displayFracType 
										molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
										   molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];	
		}
		else if ( fraction == bottomComp )
		{
			self.bottomWeightFrac = [ self convertFractionFrom: fraction 
												  fractionType: displayFracType 
										   molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
											  molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];		
		}
		else 
			return NO;
	}
	else // DISPLAY_WEIGHT_WEIGHT
	{
		if ( fraction == feedWeightFrac )
		{
			self.feedComp = [ self convertFractionFrom: fraction 
										  fractionType: displayFracType 
								   molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
									  molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];
		}
		else if ( fraction == topWeightFrac )
		{
			self.topComp = [ self convertFractionFrom: fraction 
										 fractionType: displayFracType 
								  molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
									 molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];	
		}
		else if ( fraction == bottomWeightFrac )
		{
			self.bottomComp = [ self convertFractionFrom: fraction 
												  fractionType: displayFracType 
										   molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
											  molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];		
		}
		else 
			return NO;	
	}
	
	return YES;
}

- (void) updateAllUndisplayedFractions
{
	if ( selectedDataSet == nil )
		return; // Abort the updates.
	
	if ( displayFracType == DISPLAY_MOL_FRAC )
	{
		self.feedWeightFrac = [ self convertFractionFrom: feedComp 
											fractionType: displayFracType 
									 molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight
										molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];
	
		self.topWeightFrac = [ self convertFractionFrom: topComp 
										   fractionType: displayFracType 
									molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
									   molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];	
	
		self.bottomWeightFrac = [ self convertFractionFrom: bottomComp 
											  fractionType: displayFracType 
									   molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
										  molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];	
	}
	else 
	{
		self.feedComp = [ self convertFractionFrom: feedWeightFrac 
									  fractionType: displayFracType 
							   molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
								  molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];

		self.topComp = [ self convertFractionFrom: topWeightFrac 
									 fractionType: displayFracType 
							  molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
								 molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];	
	
		self.bottomComp = [ self convertFractionFrom: bottomWeightFrac 
										fractionType: displayFracType 
								 molWeightOfFraction: selectedDataSet.selectedSource.xMolecularWeight 
									molWeightOfOther:selectedDataSet.selectedSource.yMolecularWeight ];		
	}
	
	return;	
}


- (NSNumber*) convertFractionFrom: (NSNumber*) fraction 
					 fractionType: (DesignFracType) fracType
			  molWeightOfFraction: (NSNumber*) molWeight
				 molWeightOfOther: otherMolWeight
{
	if ( fraction == nil || molWeight == nil || otherMolWeight == nil )
		return nil;
	
	if ( fracType == DISPLAY_MOL_FRAC )
	{
		// Calc weight fraction.
		double weight = [ fraction doubleValue ] * [ molWeight doubleValue ];
		double otherWeight = ( 1.0 - [ fraction doubleValue ] ) * [ otherMolWeight doubleValue ];

		return [ NSNumber numberWithDouble: weight/( weight + otherWeight ) ];
	}
	else 
	{
		double mol = [ fraction doubleValue ] / [ molWeight doubleValue ];
		double otherMol = ( 1.0 - [ fraction doubleValue ] ) / [ otherMolWeight doubleValue ];
		
		return [ NSNumber numberWithDouble: mol/( mol + otherMol ) ];
	}	
}




#pragma mark ARCHIVING 
//
// Archiving Routines.
//
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
	
	feedComp = [coder decodeObjectForKey:@"feedComp"];
	bottomComp = [coder decodeObjectForKey:@"bottomComp"];
	topComp = [coder decodeObjectForKey:@"topComp"];
	
	optimalRefluxRatioFactor = [coder decodeObjectForKey:@"optimalRefluxRatioFactor"];
	minRefluxRatio = [coder decodeObjectForKey:@"minRefluxRatio"];
	stagesAtTotalReflux = [ coder decodeIntForKey:@"stagesAtTotalReflux"];
	
	qLine = [coder decodeObjectForKey:@"qLine" ];
	
	// Feed Data Enthalpy information.
	feedBubblePoint  = [coder decodeObjectForKey:@"feedBubblePoint"];
	feedTemperature = [coder decodeObjectForKey:@"feedTemperature"];
	
	// Pick up the selected Data set via it's name.
	//
	selectedDataSet = [coder decodeObjectForKey: @"selectedDataSet" ];
	
	// Check for the old datafile.
	// Old data file...
	NSNumber* latentHeat = [coder decodeObjectForKey:@"comp1LatentHeat"];
	if ( latentHeat != nil )
		selectedDataSet.selectedSource.xLatentHeat = latentHeat;
	latentHeat  = [coder decodeObjectForKey:@"comp2LatentHeat"];
	if ( latentHeat != nil )
		selectedDataSet.selectedSource.yLatentHeat = latentHeat;
	
	NSNumber* specificHeat = [coder decodeObjectForKey:@"comp1SpecificHeat"];
	if ( specificHeat != nil )
		selectedDataSet.selectedSource.xSpecificHeat = specificHeat;
	specificHeat = [coder decodeObjectForKey:@"comp2SpecificHeat"];
	if ( specificHeat != nil )
		selectedDataSet.selectedSource.ySpecificHeat = specificHeat;

	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	// No need to encode its parent there's nothing there.
	//   [super encodeWithCoder:coder];

	[coder encodeObject:feedComp forKey:@"feedComp"];
	[coder encodeObject:bottomComp forKey:@"bottomComp"];
	[coder encodeObject:topComp forKey:@"topComp"];
	
	[coder encodeObject:optimalRefluxRatioFactor forKey:@"optimalRefluxRatioFactor"];
	[coder encodeObject:minRefluxRatio forKey:@"minRefluxRatio"];
	[coder encodeBool:minRefluxCalculated forKey:@"minRefluxCalculated" ];
	[coder encodeInt:stagesAtTotalReflux forKey:@"stagesAtTotalReflux" ];
	
	[coder encodeObject:qLine forKey:@"qLine" ];
	
	// Feed Data Enthalpy information.
	[coder encodeObject:feedBubblePoint forKey:@"feedBubblePoint"];
	[coder encodeObject:feedTemperature forKey:@"feedTemperature"];
	
	// Pick up the selected Data set via it's name.
	//
	[coder encodeObject: selectedDataSet forKey:@"selectedDataSet" ];
	
	return;
}

#pragma mark NSCopying Protocol 

- (id)copyWithZone:(NSZone *)zone
{
	McCabeThiele *newMcCabeThiele = [ [ McCabeThiele allocWithZone:zone ] init ];
	newMcCabeThiele.feedComp = feedComp;
	newMcCabeThiele.bottomComp = bottomComp;
	newMcCabeThiele.topComp = topComp;
	
	newMcCabeThiele.optimalRefluxRatioFactor = optimalRefluxRatioFactor;
	newMcCabeThiele.minRefluxRatio = minRefluxRatio;
	
	newMcCabeThiele.qLine = qLine;
	newMcCabeThiele.feedBubblePoint = feedBubblePoint;
	newMcCabeThiele.feedTemperature = feedTemperature;
	
	newMcCabeThiele.heatToVapouriseFeed = heatToVapouriseFeed;
	newMcCabeThiele.latentHeatOfFeed = latentHeatOfFeed;
	newMcCabeThiele.specificHeatOfFeed = specificHeatOfFeed;
	newMcCabeThiele.theorecticalStages = theorecticalStages;
	
	newMcCabeThiele.selectedDataSet = selectedDataSet;
	
	[ newMcCabeThiele buildEquilibriumLines ];
	[ newMcCabeThiele calculateQLine ];
	[ newMcCabeThiele calcRectifyingLine ];
	
	return newMcCabeThiele;
}

#pragma mark NSKeyValueObserving Protocol

+(NSSet *) keyPathsForValuesAffectingValueForKey:(NSString *)key
{
	if ( [ key isEqualToString: @"qSlope" ] == YES )
		return [ NSSet setWithObject: @"qLine" ];
	else if ( [ key isEqualToString: @"refluxRatio" ] == YES )
		return [ NSSet setWithObjects: @"optimalRefluxRatioFactor", @"minRefluxRatio", nil ];
	else if ( [ key isEqualToString: @"calcTheorecticalStagesAtTotalReflux" ] == YES )
		return [ NSSet setWithObject: @"stagesAtTotalReflux" ];
	else 
		return nil;
}


@end
