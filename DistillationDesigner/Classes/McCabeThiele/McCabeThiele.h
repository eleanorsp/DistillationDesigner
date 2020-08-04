//
//  McCabeThiele.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 03/02/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "TwoDimensionalGraph.h"
#import "GraphLine.h"

typedef enum {
	 DetermineMinimumRefluxMode, DetermineStagesMode
} DesignMode;

typedef enum {
	DISPLAY_MOL_FRAC, DISPLAY_WEIGHT_WEIGHT
} DesignFracType;


@interface McCabeThiele : TwoDimensionalGraph <NSCopying>
{
    NSNumber* feedComp;
    NSNumber* bottomComp;
    NSNumber* topComp;
	
	NSNumber* feedWeightFrac;
	NSNumber* bottomWeightFrac;
	NSNumber* topWeightFrac;
	
	DesignFracType displayFracType;
    
    NSNumber* optimalRefluxRatioFactor;
    NSNumber* minRefluxRatio;
	BOOL minRefluxCalculated;
    NSNumber* qLine;
	
	DataSet* selectedDataSet;
	NSMutableArray* lineArray; // Equilibrium Line(s) array.

	// The Lines to Draw the Vertial Compositions.
	GraphLine* rectifyingLine;
	GraphLine* strippingLine; // strippingLine.
	
	GraphLine* qLineLine;
	GraphLine* minRefluxLine;
	
	// Error Information.
	//
	NSMutableArray* badMinRefluxIntersectionPoints; 
	//
	// 
	NSMutableArray* stageArray;
	
	//
	// Information for Calculating the Q-Line.
	//
	NSNumber* feedBubblePoint;
	NSNumber* feedTemperature;
	
	double heatToVapouriseFeed;
	double latentHeatOfFeed;
	double specificHeatOfFeed;
	
	// Calculated number of theorectical stages.
	//
	int theorecticalStages;
	int feedPointAtStage;
	int stagesAtTotalReflux;

	//
	// The Current Design Mode.
	//
	DesignMode mode;
}

#pragma mark DRAWING 
//
// Drawing Routines.
//
- (void) drawGraph:(CGContextRef) gc;

// Normalise the Data Point into the Coordinates.
//
- (NSPoint) normalisePoint: (NSPoint) point;

- (void) drawVapourLiquidBoundary: (CGContextRef) gc;
- (void) drawQLine: (CGContextRef) gc inMode: (DesignMode) temp;
- (void) drawRectifyingLine: (CGContextRef) gc inMode: (DesignMode) temp;
- (void) drawStages: (CGContextRef) gc;

- (void) drawCompositionLines: (CGContextRef) gc;

#pragma mark CALCULATIONS 
//
// Calculation Routines.
//
- (BOOL) calcRectifyingLine;
- (BOOL) calculateQLine;
- (BOOL) calculateMinReflux;
- (BOOL) calcTheorecticalStages;
- (BOOL) calcTheorecticalStagesAtTotalReflux;
- (BOOL) calcOtherAssociatedFractionFrom: (NSNumber*) fraction;
- (void) updateAllUndisplayedFractions;

- (NSNumber*) convertFractionFrom: (NSNumber*) fraction 
					 fractionType: (DesignFracType) fracType
			  molWeightOfFraction: (NSNumber*) molWeight
				 molWeightOfOther: otherMolWeight;

// Calculate the Minimum Reflux from the Y value at X = zero.
//
- (CGFloat) setMinRefluxAtYAtXzero: (CGFloat) yAtXzero;

// Rebuild the Min Reflux Line
- (BOOL) rebuildMinRefluxLine;

- (void) updateOnHeatInfoEnteredDirectly;
- (void) updateQInfoEnteredDirectly;
- (double) qSlope;
- (double) refluxRatio;
- (BOOL) buildEquilibriumLines;

// Sets the mode and will reset any calculations not applicable to the new mode.
//
- (void) setMode: (DesignMode) newMode;
- (DesignMode) getMode;

// Check to see if there is enough information to calculate the QLine
//
- (BOOL) canCalculateQLine;
- (BOOL) canCalculateStages;

#pragma mark PROPERTIES 
//
@property(copy, readwrite) NSNumber* feedComp;
@property(copy, readwrite) NSNumber* bottomComp;
@property(copy, readwrite) NSNumber* topComp;

@property(copy, readwrite) NSNumber* feedWeightFrac;
@property(copy, readwrite) NSNumber* bottomWeightFrac;
@property(copy, readwrite) NSNumber* topWeightFrac;

@property(copy, readwrite) NSNumber* optimalRefluxRatioFactor;
@property(copy, readwrite) NSNumber* minRefluxRatio;

@property(copy, readwrite) NSNumber* qLine;

@property(copy, readwrite) NSNumber* feedBubblePoint;
@property(copy, readwrite) NSNumber* feedTemperature;

@property (assign, readwrite) DesignFracType displayFracType;

@property double heatToVapouriseFeed;
@property double latentHeatOfFeed;
@property double specificHeatOfFeed;
@property int theorecticalStages;
@property int feedPointAtStage;
@property int stagesAtTotalReflux;

@property (readwrite) DataSet* selectedDataSet;

// Line Information.
@property(copy, readwrite) GraphLine* rectifyingLine;
@property(copy, readwrite) GraphLine*  minRefluxLine;



@end
