//
//  DataPlotInformation.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 20/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "DataPlotInformation.h"


@implementation DataPlotInformation

- (id) initUsingDataSet: (DataSet*) plotSet
{
    if ( self )
    {
	if ( plotSet != nil )
	{
	    dataSet = plotSet;
	    
	    xData = [ [ dataSet selectedSource ] xColumnData];
	    yData = [ [ dataSet selectedSource ] yColumnData];
	    zData = [ [ dataSet selectedSource ] zColumnData];
	}
    }
	
    return self;
}

- (void) dealloc
{
//    [dataSet release];
//    
//    [super dealloc];
}



//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
    self = [ super init];
    
    dataSet = [ coder decodeObject ];    
    [ self setXData:[ coder decodeObject ]];
    [ self setYData:[ coder decodeObject ]];
    [ self setZData:[ coder decodeObject ]];

    [ self setPointColour:[ coder decodeObject ] ];
    [ coder decodeValueOfObjCType:@encode(PointType) at:&pointType ];
   
    [ self setLineColour:[ coder decodeObject ] ];
    [ coder decodeValueOfObjCType:@encode(LineType) at:&lineType ];
    
    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
    [ coder encodeObject: [ self dataSet ] ];
    [ coder encodeObject: [ self xData ] ];
    [ coder encodeObject: [ self yData ] ];
    [ coder encodeObject: [ self zData ] ];

    [ coder encodeObject: [ self pointColour ] ];
    [ coder encodeValueOfObjCType:@encode(PointType) at:&pointType ];

    [ coder encodeObject: [ self lineColour ] ];
    [ coder encodeValueOfObjCType:@encode(LineType) at:&lineType ];

    return;
}


//- (DataSet*) dataSet
//{
//    return dataSet;
//}

- (void) setXData: (NSString*) xColumnName
{
    xData = xColumnName;

    return;
}

- (void) setYData: (NSString*) yColumnName
{
    yData = yColumnName;

    return;
}

- (void) setZData: (NSString*) zColumnName
{
    zData = zColumnName;
    
    return;
}

- (NSString*) xData {
    return xData;
}
- (NSString*) yData {
    return yData;
}

- (NSString*) zData {
    return zData;
}

- (NSColor*) pointColour {
    return pointColour;
}

- (void) setPointColour: (NSColor*) itsColour
{
    pointColour = itsColour;
    
    return;
}

- (PointType) pointType {
    return pointType;
}

- (void) setPointType: (PointType) type
{
    pointType = type;
    return;
}

- (LineType) lineType
{
    return lineType;
}

- (void) setLineType: (LineType) type
{
    lineType = type;
    
    return;
}

- (NSColor*) lineColour
{
    return lineColour;
}

- (void) setLineColour: (NSColor*) itsColour
{
    lineColour = itsColour;
    
    return;
}

/*
 - (NSColor*) skirtColour
{
    return skirtColour;
}

- (void) setSkirtColour: (NSColor*) itsColour
{
    skirtColour = itsColour;
    
    return;
}

*/

@synthesize dataSet;
@end
