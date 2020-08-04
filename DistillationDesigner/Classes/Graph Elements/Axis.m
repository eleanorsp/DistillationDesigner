//
//  Axis.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "Axis.h"


@implementation Axis

- (id)init
{
    self = [super init];
    if (self) 
    {
	// Set some default values.
	minValue = 0;
	maxValue = 1000;
	majorTicks = 10;
	minorTicks = 5;
	showMajor = TRUE;
	showMinor = TRUE;
	axisType = LINEAR;
	axisTitle = @"TEES";
	minorLineThickness = 0.06;
	majorLineThickness = .8;
	majorLineColour = [ NSColor blackColor];
	minorLineColour = [ NSColor blackColor];
    }
    
    return self;
}


//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
    self = [ super init];
    
    [ coder decodeValueOfObjCType:@encode(double) at:&minValue ];
    [ coder decodeValueOfObjCType:@encode(bool) at:&useMinValue ];
    [ coder decodeValueOfObjCType:@encode(double) at:&maxValue ];
    [ coder decodeValueOfObjCType:@encode(bool) at:&useMaxValue ];

    [ coder decodeValueOfObjCType:@encode(int) at:&minorTicks ];
    [ coder decodeValueOfObjCType:@encode(int) at:&majorTicks ];
    
    [ coder decodeValueOfObjCType:@encode(double) at:&majorLineThickness ];
    [ coder decodeValueOfObjCType:@encode(double) at:&minorLineThickness ];
    
    [ coder decodeValueOfObjCType:@encode(int) at:&majorLinePattern ];
    [ coder decodeValueOfObjCType:@encode(int) at:&minorLinePattern ];

    [ self setAxisColour:[ coder decodeObject ] ];
    [ self setMinorLineColour:[ coder decodeObject ] ];
    [ self setMajorLineColour:[ coder decodeObject ] ];
    
    [ coder decodeValueOfObjCType:@encode(int) at:&showMinor ];
    [ coder decodeValueOfObjCType:@encode(int) at:&showMajor ];
    
    [ coder decodeValueOfObjCType:@encode(AxisType) at:&axisType ];
    [ self setAxisTitle:[ coder decodeObject ] ];

    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
    [ coder encodeValueOfObjCType:@encode(double) at:&minValue ];
    [ coder encodeValueOfObjCType:@encode(bool) at:&useMinValue ];
    [ coder encodeValueOfObjCType:@encode(double) at:&maxValue ];
    [ coder encodeValueOfObjCType:@encode(bool) at:&useMaxValue ];
    
    [ coder encodeValueOfObjCType:@encode(int) at:&minorTicks ];
    [ coder encodeValueOfObjCType:@encode(int) at:&majorTicks ];
    
    [ coder encodeValueOfObjCType:@encode(double) at:&majorLineThickness ];
    [ coder encodeValueOfObjCType:@encode(double) at:&minorLineThickness ];
    
    [ coder encodeValueOfObjCType:@encode(int) at:&majorLinePattern ];
    [ coder encodeValueOfObjCType:@encode(int) at:&minorLinePattern ];
    
    [ coder encodeObject: [self axisColour ] ];
    [ coder encodeObject:[ self minorLineColour ] ];
    [ coder encodeObject:[ self majorLineColour ] ];
    
    [ coder encodeValueOfObjCType:@encode(int) at:&showMinor ];
    [ coder encodeValueOfObjCType:@encode(int) at:&showMajor ];
    
    [ coder encodeValueOfObjCType:@encode(AxisType) at:&axisType ];
    [ coder encodeObject:[ self axisTitle ] ];
	
    return;
}



- (void) setMinorLineColour: (NSColor*) lineColour
{
    minorLineColour = lineColour;
    
    return;
}


- (void) setMajorLineColour: (NSColor*) lineColour
{
    majorLineColour = lineColour;

    return;
}

- (void) setAxisTitle: (NSString*) title
{
    axisTitle = title;
    
    return;
}


- (NSColor*) minorLineColour
{
    return minorLineColour;
}


- (NSColor*) majorLineColour
{
    return majorLineColour;
}

- (NSColor*) axisColour
{
    return colour;
}

- (void) setAxisColour:(NSColor *) col
{
	colour = col;
	
	return;
}


- (NSString*) axisTitle
{
    return axisTitle;
}


@synthesize minorLineThickness;
@synthesize majorLinePattern;
@synthesize minorLinePattern;
@synthesize majorLineThickness;

@synthesize minValue;
@synthesize useMinValue;

@synthesize maxValue;
@synthesize useMaxValue;

@synthesize majorTicks;
@synthesize minorTicks;

@synthesize showMinor;
@synthesize showMajor;

@synthesize axisType;


@end
