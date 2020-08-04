//
//  GraphBackgroundTransformer.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 05/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "GraphBackgroundTransformer.h"

#import "Graph.h"

@implementation GraphBackgroundTransformer

/*
 Takes as input the Graph Background Type,
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
    if ( [ aValue intValue] == NO_GRAPHSTYLE )
	return [NSNumber numberWithBool:NO];
    else
	return [NSNumber numberWithBool:YES];
}

@end
