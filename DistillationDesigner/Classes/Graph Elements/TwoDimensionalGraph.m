//
//  2DGraph.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <CoreServices/CoreServices.h>

#import "TwoDimensionalGraph.h"
#import "TwoDPlotInformation.h"

#import "PreferencesController.h"


@implementation TwoDimensionalGraph

- (id)init
{
    self = [super init];
    if (self) 
    {
        // Initialise the graph arrays
		title = @"Undefined 2-D Graph";
		graphOrSubview = NO;
		showTicks = YES;
		
		[ self setXAxis: [ [ Axis alloc] init ] ];
		[ self setYAxis: [ [ Axis alloc] init ] ];
    }
    
    return self;
}


//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
    if ( ( self = [ self init ] ) )
    {    
    }
    
    // Dont forget to add the rest.
    
    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
//    [ super encodeWithCoder: coder ];
    [ coder encodeObject: [ self xAxis ] ];
    [ coder encodeObject: [ self yAxis ] ];
    [ coder encodeValueOfObjCType:@encode(BOOL) at:&showTicks ];

    return;
}


- (bool) setXAxis: (Axis*) axis
{
    xAxis = axis;
    
    return TRUE;
}

- (bool) setYAxis: (Axis*) axis
{
    yAxis = axis;
    
    return TRUE;
}

- (Axis*) xAxis
{
    return xAxis;
}

- (Axis*) yAxis
{
    return yAxis;
}

- (void) drawGraph:(CGContextRef) gc
{
    if ( xAxis == nil || yAxis == nil)
		return;
    	
	[ self prepareGraphBounds: plotArea ];

    NSRect backgroundArea;
    backgroundArea.origin.x = (float) xMinPosition;
    backgroundArea.origin.y = (float) yMinPosition;
    backgroundArea.size.height = (float) (yMaxPosition - yMinPosition);
    backgroundArea.size.width = (float) (xMaxPosition - xMinPosition);
    [ self drawBackground:gc area:backgroundArea ];

	[ self drawAxisLines: gc ];
	[ self drawAxisTitles: gc ];
    
    return;
}

- (void) prepareGraphBounds: (NSRect) rect
{
	[ super prepareGraphBounds:rect ];
	
	yTick = rect.size.height*0.007;
	xTick = rect.size.width*0.007;
    textHeight = rect.size.height*0.017;
    xTextYPosition = yMinPosition - (rect.size.height*0.03);
    yTextXPosition = xMinPosition; // - (rect.size.height*0.06);	
	
	return;
}

- (void) drawBackground: (CGContextRef) gc
				   area: (NSRect) rect
{
	yMinPosition = rect.origin.y;
    yMaxPosition =  rect.origin.y + rect.size.height;
    xMinPosition = rect.origin.x;
    xMaxPosition = rect.origin.x + rect.size.width;
  
    // Draw Background First
    //
    // xTicks
    CGFloat xGap = xMaxPosition - xMinPosition;
    if ( backgroundStyle == BOTH || backgroundStyle == ALTERNATE_X )
    {
		if ( [ xAxis axisType ] == LINEAR )
		{
			NSInteger ticks = [ xAxis majorTicks ];
			NSInteger i;
			for( i = 0; i < ticks; i += 2 )
			{				
				CGFloat xPosition = xMinPosition + (( xGap/ticks ) * i);
				CGFloat xPositionEnd = xMinPosition + (( xGap/ticks ) * (i+1));
			
				CGContextBeginPath( gc );
				[ backgroundColour set];
				CGContextMoveToPoint( gc, xPosition, yMinPosition );
				CGContextAddLineToPoint( gc, xPosition, yMaxPosition );		
				CGContextAddLineToPoint( gc, xPositionEnd, yMaxPosition );		
				CGContextAddLineToPoint( gc, xPositionEnd, yMinPosition );		
				CGContextAddLineToPoint( gc, xPosition, yMinPosition );
				CGContextClosePath( gc );
				CGContextFillPath( gc ); 
			}
		}
		else //Logarithmic
		{
			CGFloat minSize = [ xAxis minValue ];
			CGFloat maxSize = [ xAxis maxValue ];
			CGFloat range = maxSize - minSize;
			double logIntervals;
			CGFloat remainder = modf( log10( range ), &logIntervals );
			
			if ( remainder > 0 )
				logIntervals++;
			
			NSInteger interval = (int) logIntervals;
			NSInteger i;
			for ( i = 0; i < interval; i += 2 )
			{
				CGFloat xPosition = xMinPosition + (( xGap/interval ) * i);
				CGFloat xPositionEnd = xMinPosition + (( xGap/interval ) * (i+1));
				
				CGContextBeginPath( gc );
				[ backgroundColour set];
				CGContextMoveToPoint( gc, xPosition, yMinPosition );
				CGContextAddLineToPoint( gc, xPosition, yMaxPosition );		
				CGContextAddLineToPoint( gc, xPositionEnd, yMaxPosition );		
				CGContextAddLineToPoint( gc, xPositionEnd, yMinPosition );		
				CGContextAddLineToPoint( gc, xPosition, yMinPosition );		
				CGContextFillPath( gc ); 		
			}
		}
    }
    
    CGFloat yGap = yMaxPosition - yMinPosition;
    if ( backgroundStyle == BOTH || backgroundStyle == ALTERNATE_Y )
    {
		if ( [ yAxis axisType ] == LINEAR )
		{
			NSInteger ticks = [ yAxis majorTicks ];
			NSInteger i;
			for( i = 0; i < ticks; i += 2 )
			{				
				CGFloat yPosition = yMinPosition + (( yGap/ticks ) * i);
				CGFloat yPositionEnd = yMinPosition + (( yGap/ticks ) * (i+1));
				
				CGContextBeginPath( gc );
				[ backgroundColour set];
				CGContextMoveToPoint( gc, xMinPosition, yPosition );
				CGContextAddLineToPoint( gc, xMaxPosition, yPosition );		
				CGContextAddLineToPoint( gc, xMaxPosition, yPositionEnd );		
				CGContextAddLineToPoint( gc, xMinPosition, yPositionEnd );		
				CGContextAddLineToPoint( gc, xMinPosition, yPosition );
				CGContextFillPath( gc ); 
			}
		}
		else //Logarithmic
		{
			CGFloat minSize = [ yAxis minValue ];
			CGFloat maxSize = [ yAxis maxValue ];
			CGFloat range = maxSize - minSize;
			double logIntervals;
			CGFloat remainder = modf( log10( range ), &logIntervals );
			
			if ( remainder > 0 )
				logIntervals++;
			
			NSInteger interval = (int) logIntervals;
			NSInteger i;
			for ( i = 0; i < interval; i += 2 )
			{
				CGFloat yPosition = yMinPosition + (( yGap/interval ) * i);
				CGFloat yPositionEnd = yMinPosition + (( yGap/interval ) * (i+1));
				
				CGContextBeginPath( gc );
				[ backgroundColour set];
				CGContextMoveToPoint( gc, xMinPosition, yPosition );
				CGContextAddLineToPoint( gc, xMaxPosition, yPosition );		
				CGContextAddLineToPoint( gc, xMaxPosition, yPositionEnd );		
				CGContextAddLineToPoint( gc, xMinPosition, yPositionEnd );		
				CGContextAddLineToPoint( gc, xMinPosition, yPosition );	
				CGContextFillPath( gc ); 		
			}
		}
    }
    
    if (backgroundStyle == SOLID_FILL)
    {
		CGContextBeginPath( gc );
		[ backgroundColour set];
		CGContextMoveToPoint( gc, xMinPosition, yMinPosition );
		CGContextAddLineToPoint( gc, xMinPosition, yMaxPosition );		
		CGContextAddLineToPoint( gc, xMaxPosition, yMaxPosition );		
		CGContextAddLineToPoint( gc, xMaxPosition, yMinPosition );		
		CGContextAddLineToPoint( gc, xMinPosition, yMinPosition );
		CGContextClosePath( gc );
		CGContextFillPath( gc ); 
    }
    
    return;
}


//
// Draws the Axis Lines onto the View.
//
- (void) drawAxisLines: (CGContextRef) gc
{
	// Draw X Axis Lines
    //
    CGContextBeginPath( gc );
    CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]);
	
    [[ xAxis majorLineColour ] set];
    CGContextMoveToPoint( gc, xMinPosition-xTick, yMinPosition );
    CGContextAddLineToPoint( gc, xMaxPosition, yMinPosition );
    CGContextStrokePath( gc );
    
    // xTicks
    CGFloat xGap = xMaxPosition - xMinPosition;
    CGFloat xValueGap = ([ xAxis maxValue ] - [ xAxis minValue ])/(double) [xAxis majorTicks];
    NSNumberFormatter *numberFormatter =  [[NSNumberFormatter alloc] init];
    [numberFormatter setFormat:@"#,##0.00"];
    
    if ( [ xAxis axisType ] == LINEAR )
    {
		NSInteger ticks = [ xAxis majorTicks ];
		
		NSInteger i;
		for( i = 0; i <= ticks; i++ )
		{				
			CGFloat xPosition = xMinPosition + (( xGap/ticks ) * i);
			
			CGContextBeginPath( gc );
			if ( i == 0 || i == ticks)
				CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]);
			else if ( xAxis.showMinor == NO )
				CGContextSetLineWidth( gc, [ xAxis minorLineThickness ]);
			else
				CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]);
			
			[[ xAxis majorLineColour ] set];
			
			CGContextMoveToPoint( gc, xPosition, yMinPosition-yTick );
			if ( [ xAxis showMajor ] == TRUE )
				CGContextAddLineToPoint( gc, xPosition, yMaxPosition );		
			else
				CGContextAddLineToPoint( gc, xPosition, yMinPosition);		
			CGContextStrokePath( gc ); 
			
			// Draw the Labels.
			//
			CGFloat xValue = [ xAxis minValue ] + (xValueGap*i);
			NSString* value = [numberFormatter stringFromNumber: [NSNumber numberWithDouble:xValue ] ];
			CGContextSelectFont (gc, 
								 "Gill Sans Light",
								 textHeight,
								 kCGEncodingMacRoman); 
			CGContextSetCharacterSpacing (gc, 2);
			
			CGContextSetTextDrawingMode (gc, kCGTextFillStroke);
			CGContextSetRGBFillColor (gc, 0, 0, 0, 1);
			CGContextSetRGBStrokeColor (gc, 0, 0, 0, 1);
			
			CGAffineTransform myTextTransform = CGAffineTransformMakeRotation(-0.0);
			CGContextSetTextMatrix( gc, myTextTransform );
			CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]);
			CGContextShowTextAtPoint (gc, xPosition, xTextYPosition,  [value cStringUsingEncoding:NSASCIIStringEncoding ], [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding] ); 	    
			
			// Draw the minor lines.
			//
			if ( i < ticks && [ xAxis showMinor ] == TRUE )
			{
				NSInteger j;
				NSInteger minorTicks = [ xAxis minorTicks ];
				for ( j = 1; j < minorTicks; j++ )
				{
					CGFloat xMinorPos = xPosition + ( xGap/(ticks * minorTicks) * j);
					
					CGContextBeginPath( gc );
					CGContextSetLineWidth( gc, [ xAxis minorLineThickness ]);
					[[ xAxis minorLineColour ] set];
					
					//	    float dash[] = { 2, 1 }; 
					//	    CGContextSetLineDash ( gc,  1, dash, 2  );
					
					CGContextMoveToPoint( gc, xMinorPos, yMinPosition );
					CGContextAddLineToPoint( gc, xMinorPos, yMaxPosition );		
					CGContextStrokePath( gc ); 
				}
			}
		}
    }
    else // LOGARITHMIC
    {
		CGFloat minSize = [ xAxis minValue ];
		CGFloat maxSize = [ xAxis maxValue ];
		CGFloat range = maxSize - minSize;
		double logIntervals;
		CGFloat remainder = modf( log10( range ), &logIntervals );
		
		if ( remainder > 0 )
			logIntervals++;
		
		NSInteger interval = (int) logIntervals;
		NSInteger i;
		for ( i = 0; i <= interval; i++ )
		{
			double xPosition = xMinPosition + (( xGap/interval ) * i);
			
			CGContextBeginPath( gc );
			//	    CGContextSetLineDash ( gc, 0, nil, 0);
			CGContextSetLineWidth( gc, [ xAxis majorLineThickness ]);
			[[ xAxis majorLineColour ] set];
			
			CGContextMoveToPoint( gc, xPosition, yMinPosition-yTick );
			if ( [ xAxis showMajor ] == TRUE )
				CGContextAddLineToPoint( gc, xPosition, yMaxPosition );		
			else
				CGContextAddLineToPoint( gc, xPosition, yMinPosition );		
			CGContextStrokePath( gc ); 
			
			if ( i < interval && [ xAxis showMinor ] == TRUE )
			{
				NSInteger j;
				NSInteger minorTicks = [ xAxis minorTicks ];
				for ( j = 1; j < minorTicks; j++ )
				{
					CGFloat tickGap = log10( ( ( (CGFloat) j)/minorTicks) * 10.0 );
					CGFloat xMinorPos = xPosition + ( (xGap/interval) * tickGap );
					
					CGContextBeginPath( gc );
					CGContextSetLineWidth( gc, [ xAxis minorLineThickness ] );
					[[ xAxis minorLineColour ] set];
					
					///	    float dash[] = { 1,1 }; 
					//	    CGContextSetLineDash ( gc,  1, dash, 2 );
					
					CGContextMoveToPoint( gc, xMinorPos, yMinPosition );
					CGContextAddLineToPoint( gc, xMinorPos, yMaxPosition );		
					CGContextStrokePath( gc ); 
				}
			}
		}
    }
	
	// Draw Y Axis
	//
	CGContextBeginPath( gc );
	[[ yAxis majorLineColour ] set];
	CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]);

	CGContextMoveToPoint( gc, xMinPosition, yMinPosition - yTick );
	CGContextAddLineToPoint( gc, xMinPosition, yMaxPosition );
	CGContextStrokePath( gc );

	CGFloat yGap = yMaxPosition - yMinPosition;
	CGFloat yValueGap = ([ yAxis maxValue ] - [ yAxis minValue ])/(double) [yAxis majorTicks];

	// yTicks
	if ( [ yAxis axisType ] == LINEAR )
	{
		NSInteger ticks = [ yAxis majorTicks ];
		NSInteger i;
		for( i = 0; i <= ticks; i++ )
		{
			CGFloat yPosition = yMinPosition + (( yGap/ticks ) * i);
			
			CGContextBeginPath( gc );
			[[ yAxis majorLineColour ] set];
			if ( i == 0 || i == ticks )
				CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]);
			else if ( yAxis.showMinor == NO )
				CGContextSetLineWidth( gc, [ yAxis minorLineThickness ]);
			else
				CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]);
			
			CGContextMoveToPoint( gc, xMinPosition-xTick, yPosition );
			if ( [ yAxis showMajor ] == TRUE )
				CGContextAddLineToPoint( gc, xMaxPosition, yPosition );		
			else
				CGContextAddLineToPoint( gc, xMinPosition, yPosition );		
			CGContextStrokePath( gc ); 
			
			// Draw the Labels.
			//
			CGFloat yValue = [ yAxis minValue ] + (yValueGap*i);
			NSString* value = [numberFormatter stringFromNumber: [NSNumber numberWithDouble:yValue ] ];
			CGContextSelectFont (gc, 
								 "Gill Sans Light",
								 textHeight,
								 kCGEncodingMacRoman); 
			CGContextSetCharacterSpacing (gc, 2);
			CGContextSetTextDrawingMode( gc, kCGTextInvisible );
			
			const char* yAxisText = [ value cStringUsingEncoding:NSASCIIStringEncoding ];
			CGPoint textStart = CGContextGetTextPosition( gc );
			CGContextShowText( gc, yAxisText, strlen( yAxisText ) );
			CGPoint textEnd = CGContextGetTextPosition( gc );			
			NSInteger maxTextLength = textEnd.x - textStart.x;
			
			CGContextSetTextDrawingMode (gc, kCGTextFillStroke);
			CGContextSetRGBFillColor (gc, 0, 0, 0, 1);
			CGContextSetRGBStrokeColor (gc, 0, 0, 0, 1);
			
			CGAffineTransform myTextTransform = CGAffineTransformMakeRotation(-0.0);
			CGContextSetTextMatrix (gc, myTextTransform);
			CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]);
			CGContextShowTextAtPoint (gc, xMinPosition - xTick - maxTextLength, yPosition, yAxisText, [value lengthOfBytesUsingEncoding:NSASCIIStringEncoding] );
			
			if ( i < ticks && [ yAxis showMinor ] == TRUE )
			{
				NSInteger j;
				NSInteger minorTicks = [ yAxis minorTicks ];
				for ( j = 1; j < minorTicks; j++ )
				{
					double yMinorPos = yPosition + ( yGap/(ticks * minorTicks) * j);
					
					CGContextBeginPath( gc );
					[[ yAxis minorLineColour ] set];
					CGContextSetLineWidth( gc, [ yAxis minorLineThickness ]);
					
					CGContextMoveToPoint( gc, xMinPosition, yMinorPos );
					CGContextAddLineToPoint( gc, xMaxPosition, yMinorPos );		
					CGContextStrokePath( gc ); 
				}
			}
		}
	}
	else // LOGARITHMIC
	{
		double minSize = [ yAxis minValue ];
		double maxSize = [ yAxis maxValue ];
		double range = maxSize - minSize;
		double logIntervals;
		double remainder = modf( log10( range ), &logIntervals );
		
		if ( remainder > 0 )
			logIntervals++;
		
		int interval = (int) logIntervals;
		int i;
		for ( i = 0; i <= interval; i++ )
		{
			double yPosition = yMinPosition + (( yGap/interval ) * i);
			
			CGContextBeginPath( gc );
			[[ yAxis majorLineColour ] set];
			CGContextSetLineWidth( gc, [ yAxis majorLineThickness ]);
			
			CGContextMoveToPoint( gc, xMinPosition-xTick, yPosition );
			if ( [ yAxis showMajor ] == TRUE )
				CGContextAddLineToPoint( gc, xMaxPosition, yPosition );		
			else
				CGContextAddLineToPoint( gc, xMaxPosition, yPosition );		
			CGContextStrokePath( gc ); 
			
			if ( i < interval && [ yAxis showMinor ] == TRUE )
			{
				int j;
				int minorTicks = [ yAxis minorTicks ];
				for ( j = 1; j < minorTicks; j++ )
				{
					double tickGap = log10( ( ( (double) j)/minorTicks) * 10.0 );
					double yMinorPos = yPosition + ( (yGap/interval) * tickGap );
					
					CGContextBeginPath( gc );
					
					[[ yAxis minorLineColour ] set];
					CGContextSetLineWidth( gc, [ yAxis minorLineThickness ]);
					
					// float dash[] = { 1,1 }; 
					//    CGContextSetLineDash ( gc,  1, dash, 2  );
					CGContextMoveToPoint( gc, xMinPosition, yMinorPos );
					CGContextAddLineToPoint( gc, xMaxPosition, yMinorPos );		
					CGContextStrokePath( gc ); 
				}
			}
		}
	}

	return;
}



- (void) drawAxisTitles: (CGContextRef) gc
{
	// Draw the XAxis
	//
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

	int textSizeLength = (5.5 * [ xAxis.axisTitle length ])/2;
	CGFloat xCenteredPosition = ( xPositionDifference/2 ) - textSizeLength + xMinPosition;

	CGFloat yTopPosition =  yMinPosition - (yMinPosition - plotArea.origin.y)/2;
	CGContextShowTextAtPoint (gc, xCenteredPosition, yTopPosition,  [ xAxis.axisTitle cStringUsingEncoding:NSASCIIStringEncoding ], [xAxis.axisTitle lengthOfBytesUsingEncoding:NSASCIIStringEncoding] ); 	    
	
	CGFloat xPosition =  xMinPosition - (xMinPosition - plotArea.origin.x)/1.7;
	
	textSizeLength = (5.5 * [  yAxis.axisTitle length ])/2;
	CGFloat yCenteredPosition = ( yPositionDifference/2 ) - textSizeLength + yMinPosition;

	// Rotate by 90 convert to radians.
	//
	CGAffineTransform myYTextTransform = CGAffineTransformMakeRotation( 90 * 3.14159265359/180 );
	CGContextSetTextMatrix (gc, myYTextTransform);
	CGContextShowTextAtPoint (gc, xPosition, yCenteredPosition,  [yAxis.axisTitle cStringUsingEncoding:NSASCIIStringEncoding ], [yAxis.axisTitle lengthOfBytesUsingEncoding:NSASCIIStringEncoding] ); 	    
	
	return;
}




- (void) setDataSetToPlot:(DataSet*) dataSet
		   select:(BOOL) selectThisSet
{
    TwoDPlotInformation* plotInfoWithDataSet = (TwoDPlotInformation*) [ self containsDataSet:dataSet ];
    
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


@synthesize showTicks;
@end
