//
//  OptimumMcCabeThiele.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 10/04/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TwoDimensionalGraph.h"
#import "McCabeThiele.h"
#import "GraphLine.h"

@interface OptimalMcCabeThiele : TwoDimensionalGraph
{	
	NSMutableArray* stagesArray; // Array of Reflux Ratio vs number of stages.
	NSNumber* minimumReflux;
	NSNumber* maximumReflux;
	
	int calculationSteps;
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

- (void) drawOptimumLine: (CGContextRef) gc;

#pragma mark CALCULATIONS 
//
// Calculation Routines.
//
- (void) generateOptimalStages;
- (void) generateStagesAtTotalReflux;

#pragma mark ARCHIVING 
//
// Archiving Routines
//
- (id) initWithCoder:(NSCoder *)coder;
- (void) encodeWithCoder:(NSCoder *)coder;

#pragma mark PROPERTIES 
//
@property(copy, readwrite) NSNumber* minimumReflux;
@property(copy, readwrite) NSNumber* maximumReflux;
@property(assign, readwrite) McCabeThiele* actualMcCabeThiele;

@property int calculationSteps;

@end
