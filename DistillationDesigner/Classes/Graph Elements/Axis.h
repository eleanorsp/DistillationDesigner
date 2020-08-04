//
//  Axis.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
    LINEAR, LOGARITHMIC
} AxisType;

typedef enum {
    XAXIS, YAXIS, ZAXIS
} AxisCoordinate;

@interface Axis : NSObject <NSCoding>
{
    double minValue;
    bool useMinValue;
    double maxValue;
    bool useMaxValue;
    
    int minorTicks;
    int majorTicks;
    
    double majorLineThickness;
    double minorLineThickness;

    int majorLinePattern;
    int minorLinePattern;
    
    NSColor* minorLineColour;
    NSColor* majorLineColour;
    NSColor* colour;
    
    bool showMinor;
    bool showMajor;
    
    AxisType axisType;
    NSString* axisTitle;
    NSFont* axisFont;
}


@property double minValue;
@property bool useMinValue;

@property double maxValue;
@property bool useMaxValue;

@property int majorTicks;
@property int minorTicks;

@property bool showMinor;
@property bool showMajor;


@property double majorLineThickness;
@property double minorLineThickness;

@property int minorLinePattern;
@property int majorLinePattern;

@property AxisType axisType;

@property (assign, getter=axisColour,setter= setAxisColour:) NSColor* colour;
@property (assign,getter=axisTitle,setter=setAxisTitle:) NSString* axisTitle;
@property (assign,getter=majorLineColour,setter=setMajorLineColour:) NSColor* majorLineColour;
@property (assign,getter=minorLineColour,setter=setMinorLineColour:) NSColor* minorLineColour;

@end
