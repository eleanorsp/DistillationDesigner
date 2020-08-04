//
//  McCabeGraphView.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 02/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "GraphView.h"
#import "McCabeThiele.h"

@interface McCabeGraphView : GraphView 
{
	NSPoint minimumPoint;
	NSPoint maximumPoint;
	NSDecimalNumber* topComposition;
	
	// private variables that track state
    BOOL dragging;
    NSPoint lastDragLocation;
	// private variables that track state
	BOOL minRefluxStarted;
}

// Initiate the Min Reflux Identification.
//
- (void) startMinRefluxReview;

// -----------------------------------
// Handle Mouse Events 
// -----------------------------------

- (void) mouseDown: (NSEvent *) event;
- (void) mouseDragged: (NSEvent *) event;
- (void) mouseUp: (NSEvent *) event;


// -----------------------------------
// Modify the MinReflux Line by location 
// -----------------------------------

// Make sure the selection is within limits.
//
- (BOOL) isPointInMinRefluxGraphLimits:(NSPoint)testPoint;
//
// Define the Rectangule Limits which the Min Drag can work.
- (NSRect) calculatedItemBounds;
//
// Define the offset Line.
- (void) offsetLineByX:(CGFloat)x andY:(CGFloat)y;


// -----------------------------------
// Gets and Sets through property values.
// -----------------------------------
//
@property BOOL minRefluxStarted;


@end
