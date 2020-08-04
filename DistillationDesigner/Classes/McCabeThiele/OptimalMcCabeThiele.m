//
//  OptimumMcCabeThiele.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 10/04/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "OptimalMcCabeThiele.h"

#import "PreferencesController.h"

@implementation OptimalMcCabeThiele


#pragma mark PROPERTIES
//
@synthesize minimumReflux;
@synthesize maximumReflux;
@synthesize calculationSteps;
@synthesize actualMcCabeThiele;

#pragma mark INITIALISE 
//
- (id) init
{
	if ( (self = [super init]) )
    {
		actualMcCabeThiele = nil;
		
		xAxis.maxValue = 2.0;
		xAxis.minValue = 1.0;
		xAxis.minorTicks = 10;
		xAxis.showMinor = FALSE;
		xAxis.axisTitle = @"Reflux Ratio Factor on Rmin";
		
		xAxis.majorTicks = 10;
		yAxis.maxValue = 100.0;
		yAxis.minValue = 0.0;
		yAxis.minorTicks = 10;
		yAxis.majorTicks = 10;	 
		yAxis.axisTitle = @"Number of Theoretical Stages";
		
		backgroundStyle = ALTERNATE_Y;
		
		minimumReflux = [ NSNumber numberWithDouble:1.01 ];
		maximumReflux = [ NSNumber numberWithDouble:10.0 ];
		
		title = @"Theoretical Stages versus Reflux";
		
		calculationSteps = 500;
	}
	
	return self;
}


- (id) initWithMcCabeThiele: (McCabeThiele*) mcCabeThiele
{
	if ( (self = [self init]) )
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
	if ( xAxis == nil || yAxis == nil)
		return;
	
	// Ensure the graph knows about the lastest preference settings.
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	NSNumber* showMinorIntervals = [ defaults objectForKey: DD_OptimalShowMinorLinesKey ];
	NSNumber* numberMinorIntervals = [ defaults objectForKey: DD_OptimalNumberMinorIntervalsKey ];
	self.xAxis.minorTicks = [ numberMinorIntervals intValue ];
	self.xAxis.showMinor = [ showMinorIntervals boolValue ];
	self.yAxis.minorTicks = [ numberMinorIntervals intValue ];
	self.yAxis.showMinor = [ showMinorIntervals boolValue ];

	NSNumber* xAxisInters = [ defaults objectForKey: DD_OptimalXAxisMajorIntervalsKey ];
	self.xAxis.majorTicks = [ xAxisInters intValue ];
	
	NSNumber* showYAxisBanding = [ defaults objectForKey: DD_OptimalShowYAxisBandingKey ];
	NSData* yAxisBandingColour = [ defaults objectForKey: DD_OptimalYAxisBandingColourKey ];
	NSNumber* yAxisInters = [ defaults objectForKey: DD_OptimalYAxisMajorIntervalsKey ];

	self.yAxis.majorTicks = [ yAxisInters intValue ];
	if ( [showYAxisBanding boolValue ] == YES )
	{
		self.backgroundStyle = ALTERNATE_Y;
		
		NSColor* bandingColour = [ NSUnarchiver unarchiveObjectWithData: yAxisBandingColour ];
		self.backgroundColour = bandingColour;
	}	
	else
		self.backgroundColour = NO_GRAPHSTYLE;
		
    // NSRect backgroundArea;
	[ super drawGraph:gc ];
	
 //   [ self drawBackground:gc area:backgroundArea ];
	
	[ self drawOptimumLine: gc ];
	[ self drawAxisLines:gc ];
	[ self drawAxisTitles:gc ];
	[ self drawTitle: gc ];
	
	return;
}

- (void) drawOptimumLine: (CGContextRef) gc
{
	if ( [ stagesArray count ] == 0 )
		return;
	
	// Ensure the graph knows about the lastest preference settings.
	NSUserDefaults* defaults = [ NSUserDefaults standardUserDefaults ];
	
	NSData* colourAsData = [ defaults objectForKey: DD_OptimalLineColourKey ];	
	NSColor* skirtColour = [ NSUnarchiver unarchiveObjectWithData: colourAsData ];
	NSNumber* showLineSkirt = [ defaults objectForKey: DD_OptimalPlotLineSkirtKey ];
	
	//
	NSBezierPath* optimalPath = [ NSBezierPath bezierPath ];
	
	NSPoint startPoint;
	[[NSColor blackColor] set];
	
	NSMutableArray* startPointArray = [ stagesArray objectAtIndex:0 ];
	startPoint = NSMakePoint( [ [ startPointArray objectAtIndex:0 ] floatValue ], [ [ startPointArray objectAtIndex:1 ] floatValue ] );
	[ optimalPath moveToPoint: [ self normalisePoint: startPoint ] ];
	
	NSPoint normalisedPoint;
	NSPoint firstPoint;
	NSPoint lastPoint; 
	int count = 0;
	for ( NSMutableArray* stagesAtReflux in stagesArray )
	{
		NSPoint point = NSMakePoint( [ [ stagesAtReflux objectAtIndex:0 ] floatValue ], [ [ stagesAtReflux objectAtIndex:1 ] floatValue ] );
		
		normalisedPoint = [ self normalisePoint: point ];
		
		NSLog( @"x: %f y: %f", normalisedPoint.x, normalisedPoint.y );
		
		[optimalPath lineToPoint:normalisedPoint ];
	
		if ( count == 0 )
			firstPoint = point;
		else
			lastPoint = point;
		
		count++;
	}
    
	[ skirtColour set];	
	if ( [ showLineSkirt intValue ] != 0 )
	{
		NSColor* transparentSkirt = [ skirtColour colorWithAlphaComponent:0.8 ];
		[ transparentSkirt set ];
		
		NSPoint bottomRightPoint = lastPoint;
		bottomRightPoint.y = self.yAxis.minValue;
		
		normalisedPoint = [ self normalisePoint: bottomRightPoint ];
		[optimalPath lineToPoint:normalisedPoint ];

		NSPoint bottomLeftPoint = bottomRightPoint;
		bottomLeftPoint.x = firstPoint.x;
		[optimalPath lineToPoint: [ self normalisePoint: bottomLeftPoint ] ];
			
		normalisedPoint = [ self normalisePoint: firstPoint ];
		[optimalPath lineToPoint:normalisedPoint ];
		
		[ optimalPath closePath ];
		[ optimalPath fill ];
	}
	
	if ( [ showLineSkirt intValue ] == 2 ) // Line and Skirt. Make the line black.
		[ [ NSColor blackColor ] set ];
	if ( [ showLineSkirt intValue ] != 1 ) // Now show Skirt only
		[ optimalPath stroke ];
	
	// if the stages at total reflux is defined plot it.
/*	if ( stagesAtTotalRelux >= 0 )
	{
		// Define a rect in which to write the total reflux.
		NSPoint point = NSMakePoint( [ maximumReflux floatValue ], stagesAtTotalRelux );
		normalisedPoint = [ self normalisePoint: point ];	
		
		NSRect stringRect; 
		stringRect.origin.x = normalisedPoint.x - 80;
		stringRect.origin.y = normalisedPoint.y - 20;
		stringRect.size.width = 140;
		stringRect.size.height = 30;
		
		NSMutableDictionary* textAttributes = [[ NSMutableDictionary alloc ] init];
		CGFloat titleHeight = plotArea.size.height*0.02;
		[ textAttributes setObject: [NSFont fontWithName:@"Gill Sans Light" size:titleHeight ]
							forKey: NSFontAttributeName ];
									
		NSString* string = [ NSString stringWithFormat:@"Stages at Total Reflux = %d", stagesAtTotalRelux ];
		[ string drawInRect:stringRect withAttributes:textAttributes ];
	}
 */

	return;
}

#pragma mark CALCULATIONS 
//
// Calculation Routines.
//
- (void) generateOptimalStages
{
	int maxStages = 0;
	
	// First clear down the existing data.
	//
	stagesArray = [ [ NSMutableArray alloc ] init ];
	
	if ( [ actualMcCabeThiele canCalculateStages ] == NO )
		return; // TBD...Throw exception here.
	
	// Make sure the min factor is a bit above 1.0.
	//
	// Shallow copy the existing mcCabeThiele.
	McCabeThiele* tempMcCabeThiele = [ actualMcCabeThiele copy ];

	int step;
	for ( step = 0; step <= calculationSteps; step++ )
	{
		double interval = (double) step / (double) calculationSteps;
		double refluxValue = [ minimumReflux doubleValue ] + ( interval * ([ maximumReflux doubleValue ] - [ minimumReflux doubleValue ] ) );
		NSNumber* refluxValueNumber =[  [ NSNumber alloc ] initWithDouble: refluxValue ];
		
		tempMcCabeThiele.optimalRefluxRatioFactor = refluxValueNumber;
		if ( [ tempMcCabeThiele calcTheorecticalStages ] == YES )
		{
			NSNumber* xNumber = refluxValueNumber;
			NSNumber* yNumber = [ [ NSNumber alloc ] initWithInt: tempMcCabeThiele.theorecticalStages ];
			NSMutableArray* twoDData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, nil ];
			
			if ( maxStages < tempMcCabeThiele.theorecticalStages )
				maxStages = tempMcCabeThiele.theorecticalStages;
			
			[ stagesArray addObject:twoDData ];
			
			NSLog( @"reflux: %f stages: %d", refluxValue, tempMcCabeThiele.theorecticalStages );
		}
	}
	
	// Update the graph to the maximum value.
	// Round up to the nearest 10. TBD
	//
	yAxis.maxValue = maxStages;
	xAxis.minValue = [ minimumReflux doubleValue ];
	xAxis.maxValue = [ maximumReflux doubleValue ];
	
	
	return;
}


//+
// Generate a value at a total reflux. 
// Assume use a number big enough like 1000000
//-
- (void) generateStagesAtTotalReflux
{
	// Make sure the min factor is a bit above 1.0.
	//
	
	if ( [ actualMcCabeThiele calcTheorecticalStagesAtTotalReflux ] == YES )
		return;
	else
		NSLog(@"Problem in calculating stages at total reflux" );
	
	return;
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


#pragma mark ARCHIVING 
//
// Archiving Routines.
//
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
	
	calculationSteps = [coder decodeInt32ForKey:@"calculationSteps"];
	maximumReflux = [coder decodeObjectForKey:@"maximumReflux"];
	minimumReflux = [coder decodeObjectForKey:@"minimumReflux"];

	// Get the McCabeThiele from
	
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	// No need to encode its parent there's nothing there.
	//   [super encodeWithCoder:coder];
	
	[coder encodeInt32:calculationSteps forKey:@"calculationSteps"];
	[coder encodeObject:maximumReflux forKey:@"maximumReflux"];
	[coder encodeObject:minimumReflux forKey:@"minimumReflux"];
	
	// Ignore the McCabeThiele.
	//
	
	return;
}

@end
