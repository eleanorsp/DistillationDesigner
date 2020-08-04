//
//  WillCalculateQTransformer.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/03/2008.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WillCalculateQTransformer.h"


@implementation WillCalculateQTransformer

/*
 Takes as input the Axis Type,
 returns if the object should be editable
 */


- (id) initWithMcCabeThiele: (McCabeThiele *) associatedMcCabeThiele
{
    if ( (self = [super init] ) )
	{
		itsMcCabeThiele = associatedMcCabeThiele;
	
	}
	
	return self;
}


+ (Class)transformedValueClass
{
    return [NSNumber class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)aValue
{
	// TBD
	return [NSNumber numberWithBool:YES];
}

@end
