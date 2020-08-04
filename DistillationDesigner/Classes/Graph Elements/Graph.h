//
//  Graph.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//
//  Abstract Class.

#import <Cocoa/Cocoa.h>

#import "DataSet.h"
#import "DataPlotInformation.h"


typedef enum {
    NO_GRAPHSTYLE, 
	ALTERNATE_X, 
	ALTERNATE_Y, 
	BOTH, 
	SOLID_FILL
} GraphBackgroundStyle;


@interface Graph : NSObject
{
    NSMutableArray* axes;
    NSMutableArray* plotDataSets; // Holds only the datasets which require plotting.
    
    NSString* title;
    NSString* tabTitle;
    
    BOOL graphOrSubview;
    
	CGFloat yMinPosition;
    CGFloat yMaxPosition;
    CGFloat xMinPosition;
    CGFloat xMaxPosition;
	
	CGFloat xPositionDifference;
	CGFloat yPositionDifference;
	
	NSRect plotArea;
	
    NSColor* backgroundColour;
    GraphBackgroundStyle backgroundStyle; 
} 


#pragma mark DRAWING 
//
- (void) drawGraph:(CGContextRef) gc;
- (void) drawBackground: (CGContextRef) gc
				   area: (NSRect) rect;

- (void) drawTitle: (CGContextRef) gc;
- (void) drawAxisTitles: (CGContextRef) gc;

- (void) prepareGraphBounds: (NSRect) rect;



#pragma mark GETS_AND_SETS
//
- (void) setTitle: (NSString*) string;
- (NSString*) title;

- (void) setTabTitle: (NSString*) string;
- (NSString*) tabTitle;

- (NSMutableArray*) axes;
- (NSMutableArray*) plotDataSets;

- (void) setBackgroundColour: (NSColor*) colour;
- (NSColor*) backgroundColour;

- (GraphBackgroundStyle) backgroundStyle;



- (BOOL) isGraphOrSubView;

// This will add or remove this dataset to/from the graph.
//
- (void) setDataSetToPlot:(DataSet*) dataSet
		   select:(BOOL) selectThisSet;

// Normalise the Data Point into the Coordinates.
//
- (NSPoint) normalisePoint: (NSPoint) n;

//
// Check if the Graph is already managing this dataset.
//
- (DataPlotInformation*) containsDataSet:(DataSet*) thisDataSet;

#pragma mark PROPERTIES 
//
@property (assign,getter=backgroundColour,setter=setBackgroundColour:) NSColor* backgroundColour;
@property (retain,getter=plotDataSets) NSMutableArray* plotDataSets;
@property (getter=isGraphOrSubView) BOOL graphOrSubview;
@property (assign,getter=tabTitle,setter=setTabTitle:) NSString* tabTitle;
@property (retain,getter=axes) NSMutableArray* axes;
@property (assign,getter=title,setter=setTitle:) NSString* title;

@property CGFloat yMinPosition;
@property CGFloat yMaxPosition;
@property CGFloat xMinPosition;
@property CGFloat xMaxPosition;

@property NSRect plotArea;

@property GraphBackgroundStyle backgroundStyle;

@end
