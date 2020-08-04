//
//  TwoDPlotInformation.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "TwoDPlotInformation.h"


@implementation TwoDPlotInformation


- (void) dealloc
{
   // [fillAreaColour release];
    
  //  [super dealloc];
}


//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
    self = [ super initWithCoder: coder ];
    
    [ self setFillAreaColour:[ coder decodeObject ] ];
    [ coder decodeValueOfObjCType:@encode(FillAreaType) at:&fillAreaType ];
 //   [ self setFillTransparency:[ coder decodeObject ] ];
    
    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{   
    [ super encodeWithCoder: coder ];

    [ coder encodeObject: [ self fillAreaColour ] ];
    [ coder encodeValueOfObjCType:@encode(LineType) at:&fillAreaType ];
 //   [ coder encodeInt: [ self fillTransparency ] ];
        
    return;
}


- (void) setFillAreaType: (FillAreaType) areaType
{
    fillAreaType = areaType;
    
    return;
}

- (void) setFillTransparency: (int) transparency
{
    fillTransparency = transparency;
    
    return;
}


- (void) setFillAreaColour: (NSColor*) areaColour
{
    fillAreaColour = areaColour;
    
    return;    
}

- (FillAreaType) fillAreaType
{
    return fillAreaType;
}

- (NSColor*) fillAreaColour
{
    return fillAreaColour;
}

- (int) fillTransparency
{
    return fillTransparency;
}

@end
