//
//  AxisStateTransformer.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 01/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "AxisStateTransformer.h"
#import "Axis.h"

@implementation AxisStateTransformer

/*
 Takes as input the Axis Type,
 returns if the object should be editable
 */

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
	if ( [ aValue intValue] == LINEAR )
	return [NSNumber numberWithBool:YES];
    else
	return [NSNumber numberWithBool:NO];
}


@end