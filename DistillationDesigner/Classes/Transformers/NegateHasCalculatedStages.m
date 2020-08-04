//
//  NegateHasCalculatedStages.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 14/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "NegateHasCalculatedStages.h"

#import "McCabeThiele.h"

@implementation NegateHasCalculatedStages

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
		return [NSNumber numberWithBool:NO];
    else
		return [NSNumber numberWithBool:YES];
}


@end
