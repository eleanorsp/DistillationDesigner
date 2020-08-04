//
//  BinaryComponents.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 16/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "McCabeThiele.h"
#import "TwoDimensionalGraph.h"

@interface BinaryComponents : TwoDimensionalGraph
{	
	// This should be the accompanying McCabe Thiele held within the document.
	//
	McCabeThiele* actualMcCabeThiele;
	
	NSMutableArray* dewBoundary;
	NSMutableArray* bubbleBoundary;
}

#pragma mark INITIALISE
//
- (id) init;
- (id) initWithMcCabeThiele: (McCabeThiele*) mcCabeThiele;

#pragma mark DRAWING
//
// Drawing Routines.
//
- (void) drawGraph:(CGContextRef) gc;

- (void) drawEquilibriumLines: (CGContextRef) gc;

- (void) drawDewBoundary: (CGContextRef) gc;
- (void) drawBubbleBoundary: (CGContextRef) gc;

- (BOOL) buildBoundaryLines;

@end
