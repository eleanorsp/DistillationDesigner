//
//  TwoDPlotInformation.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DataPlotInformation.h"

typedef enum {
    NONE, FILL_ABOVE, FILL_BELOW 
} FillAreaType;

@interface TwoDPlotInformation : DataPlotInformation 
{        
    FillAreaType fillAreaType;
    int fillTransparency;
    NSColor* fillAreaColour;
}

// 
// Gets and Sets
//
- (void) setFillAreaType: (FillAreaType) areaType;
- (void) setFillTransparency: (int) fillTransparency;
- (void) setFillAreaColour: (NSColor*) areaColour;

- (FillAreaType) fillAreaType;
- (NSColor*) fillAreaColour;
- (int) fillTransparency;

@property (getter=fillTransparency,setter=setFillTransparency:) int fillTransparency;
@property (assign,getter=fillAreaColour,setter=setFillAreaColour:) NSColor* fillAreaColour;

@end
