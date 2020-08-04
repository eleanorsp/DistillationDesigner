//
//  QLineController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "McCabeThiele.h"

@interface QLineWindowController : NSWindowController 
{
	IBOutlet NSObjectController* mcCabeThieleController;

	McCabeThiele* mcCabeThiele;
}

// 
// Initialisation Routines.
//
- (id) initUsingMcCabeThiele: (McCabeThiele*) itsMcCabeThiele;

// Actions.
//
- (IBAction) closeQLineControllerSheet: (id) sender;
- (IBAction) heatInfoEnteredDirectly: (id) sender;
- (IBAction) qInfoEnteredDirectly: (id) sender;

//
// Delegate Notification on the QLine data.
//

// 
// Gets and Sets.
//
- (void) setMcCabeThiele: (McCabeThiele*) newMcCabeThiele;

@end
