//
//  RelativeVolatilityDataSource.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 08/01/2011.
//  Copyright 2011 Spenceley Consultancy Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DataSource.h"

@interface RelativeVolatilityDataSource : DataSource 
{	
	NSNumber* relativeVolatility;
}

//
// Properties
//
@property (retain) NSNumber* relativeVolatility;

//
// Methods
//
- (BOOL) isCompleteToCalculateRelVol;

//
// Calculate the VLE from the relative volatity data.
- (void) buildVLEFromRelativeVolatityData;


@end
