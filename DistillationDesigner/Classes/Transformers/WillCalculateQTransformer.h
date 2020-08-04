//
//  WillCalculateQTransformer.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "McCabeThiele.h"


@interface WillCalculateQTransformer : NSValueTransformer
{
	McCabeThiele* itsMcCabeThiele;
	
}

//
// Initialisation.
//
- (id) initWithMcCabeThiele: (McCabeThiele *) associatedMcCabeThiele;

@end
