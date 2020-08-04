//
//  LoadDataSetController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 23/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "ManualDataSetController.h"

@interface LoadDataSetController : ManualDataSetController 
{
	IBOutlet NSButton* reloadButton;
	IBOutlet NSPopUpButton* separationPopupButton;
	IBOutlet NSPopUpButton* orientationPopupButton;
}


#pragma mark IB_ACTION 
//
// Action Methods
//
//- (IBAction) importDatafile: (id) sender;

@end
