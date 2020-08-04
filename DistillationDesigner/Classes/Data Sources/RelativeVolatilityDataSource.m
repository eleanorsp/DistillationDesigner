//
//  RelativeVolatilityDataSource.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 08/01/2011.
//  Copyright 2011 Spenceley Consultancy Ltd. All rights reserved.
//

#define CALCULATED_POINTS 100
#define IDEAL_GAS_CONSTANT 8.314472

#import "RelativeVolatilityDataSource.h"


@implementation RelativeVolatilityDataSource

// Properties
//
@synthesize relativeVolatility;

#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{    
	self = [ super initWithCoder: coder ];
	
	relativeVolatility = [coder decodeObjectForKey:@"relativeVolatility"];
			
    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
	[ super encodeWithCoder: coder ];
	
    [ coder encodeObject:relativeVolatility forKey:@"relativeVolatility" ];

	return;
}

#pragma mark METHODS

//
// Methods
//
- (BOOL) isCompleteToCalculateRelVol
{
	NSLog(@"DataSetWindowController: isCompleteToCalculateRelVol" );

	if ( xBoilingPoint != nil && yBoilingPoint != nil &&
		 xLatentHeat != nil && yLatentHeat != nil && relativeVolatility != nil )
		return YES;
	else 
		return NO;
}

//
// Methods
//
// Calculate the VLE from the relative volatity data.
- (void) buildVLEFromRelativeVolatityData
{
	NSLog(@"DataSetWindowController: buildVLEFromRelativeVolatityData" );

	// Clear down existing data.
	//
	data = [ [ NSMutableArray alloc ] init ];
	smoothedData = data;

	// Lets go for CALCULATED_POINTS points.
	//
	double frac = 1.0/CALCULATED_POINTS;
	double averageLatentHeat = ([ xLatentHeat doubleValue ] + [ yLatentHeat doubleValue ]) / 2.0;
//	double xtempKelvin = [ xBoilingPoint doubleValue ] + 273.15;
	double ytempKelvin = [ yBoilingPoint doubleValue ] + 273.15;
	
	for (int i = 0; i <= CALCULATED_POINTS; i++ )
	{
		NSNumber* xvalue = [ [ NSNumber alloc ] initWithDouble: frac*i ];
		
		double yFrac = [ relativeVolatility doubleValue ] * [ xvalue doubleValue ]/ (1 + ( ( [ relativeVolatility doubleValue ] - 1 ) * [ xvalue doubleValue ] ) );
		NSNumber* yvalue = [ [ NSNumber alloc ] initWithDouble: yFrac ];

		double temperature = ytempKelvin / ( ( (IDEAL_GAS_CONSTANT/averageLatentHeat) * ytempKelvin * log(1 + ( ( [ relativeVolatility doubleValue ]-1) * [ xvalue doubleValue ] ) ) ) + 1 );
		NSNumber* zvalue = [ [ NSNumber alloc ] initWithDouble: temperature - 273.15 ];
		
		NSMutableArray* twoDData = [ [ NSMutableArray alloc ] initWithObjects: xvalue, yvalue, zvalue, nil ];
		[ data addObject: twoDData ];
	}
	
	return;
}

@end
