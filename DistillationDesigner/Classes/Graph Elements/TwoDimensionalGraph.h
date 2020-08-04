//
//  TwoDimensionalGraph.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "Graph.h"
#import "Axis.h"

@interface TwoDimensionalGraph : Graph 
{    
    Axis* xAxis;
    Axis* yAxis;

    BOOL showTicks;
	
	CGFloat yTick;
    CGFloat xTick;
    CGFloat textHeight;
    CGFloat xTextYPosition;
    CGFloat yTextXPosition;
}

- (id) initWithCoder:(NSCoder* ) coder;


- (bool) setXAxis: (Axis*) axis;
- (bool) setYAxis: (Axis*) axis;

- (Axis*) xAxis;
- (Axis*) yAxis;

- (void) drawGraph:(CGContextRef) gc;

- (void) drawAxisLines: (CGContextRef) gc;
//					at: (NSPoint) origin;

- (void) drawAxisTitles: (CGContextRef) gc;
//					 at: (NSPoint) origin;

- (void) prepareGraphBounds: (NSRect) rect;

@property BOOL showTicks;



@end
