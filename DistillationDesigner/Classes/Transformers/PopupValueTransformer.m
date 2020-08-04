//
//  PopupValueTransformer.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 06/10/2004.
//  Copyright 2004 __MyCompanyName__. All rights reserved.
//

#import "PopupValueTransformer.h"


@implementation PopupValueTransformer

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
    NSInteger val = [ aValue intValue];
    
    return [NSNumber numberWithInt: val ];
}

@end
