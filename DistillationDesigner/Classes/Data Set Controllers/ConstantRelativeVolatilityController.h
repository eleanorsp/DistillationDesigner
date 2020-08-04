//
//  ConstantRelativeVolatilityController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/01/2011.
//  Copyright 2011 Spenceley Consultancy Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ManualDataSetController.h"

@interface ConstantRelativeVolatilityController : ManualDataSetController <NSTableViewDataSource>
{
}

//
// Callbacks
//
- (IBAction) dataEntered: (id) sender;


@end
