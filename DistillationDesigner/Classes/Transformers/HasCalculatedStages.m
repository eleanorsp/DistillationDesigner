//
//  HasCalculatedStages.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "HasCalculatedStages.h"


@implementation HasCalculatedStages

/*
 Takes as input the Design Mode,
 returns if the design mode is currently DetermineStagesMode
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
    if ( [ aValue intValue] == DetermineStagesMode )
		return [NSNumber numberWithBool:YES];
    else
		return [NSNumber numberWithBool:NO];
}


@end
