//
//  DataPlotInformation.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 20/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DataSet.h"

typedef enum {
    NO_POINT_TYPE, POINT, CROSS, X, STAR
} PointType;

typedef enum {
    NO_LINE, POINT_TO_POINT, CURVE, VERTICAL_LINES, LINEAR_REGRESSION, 
} LineType;


@interface DataPlotInformation : NSObject <NSCoding>
{
    DataSet* dataSet;
    
    // X, Y and Z information from the data set.
    NSString* xData;
    NSString* yData;
    NSString* zData;
    
    NSColor* pointColour;
    PointType pointType;
    
    LineType lineType;
    NSColor* lineColour;
}

- (id) initUsingDataSet: (DataSet*) plotSet;

//
// Gets and Sets.
//
- (void) setXData: (NSString*) xColumnName;
- (void) setYData: (NSString*) yColumnName;
- (void) setZData: (NSString*) zColumnName;

- (NSString*) xData;
- (NSString*) yData;
- (NSString*) zData;

- (DataSet*) dataSet;

- (NSColor*) pointColour;
- (void) setPointColour: (NSColor*) itsColour;

- (PointType) pointType;
- (void) setPointType: (PointType) type;

- (LineType) lineType;
- (void) setLineType: (LineType) type;

- (NSColor*) lineColour;
- (void) setLineColour: (NSColor*) itsColour;

//- (NSColor*) skirtColour;
//- (void) setSkirtColour: (NSColor*) itsColour;

//- (void) plotData:(CGContextRef)gc
//	graphSize:(NSSize) size
//	   xrange:(NSSize) xBounds
//	   yrange:(NSSize) yBounds;

@property (assign,getter=zData,setter=setZData:) NSString* zData;
@property (assign,getter=xData,setter=setXData:) NSString* xData;
@property (assign,getter=pointColour,setter=setPointColour:) NSColor* pointColour;
@property (retain,getter=dataSet) DataSet* dataSet;
@property (assign,getter=lineColour,setter=setLineColour:) NSColor* lineColour;
@property (assign,getter=yData,setter=setYData:) NSString* yData;
@end
