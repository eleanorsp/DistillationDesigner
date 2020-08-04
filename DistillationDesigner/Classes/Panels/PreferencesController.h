//
//  PreferencesController.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 13/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString* DD_StageFillColourKey;
extern NSString* DD_StageLineColourKey;
extern NSString* DD_FillStagesKey;
extern NSString* DD_VapourColourKey;
extern NSString* DD_LiquidColourKey;
extern NSString* DD_ShowMinorAxisKey;
extern NSString* DD_NumberMinorIntervalsKey;
// Optimal
extern NSString* DD_OptimalShowMinorLinesKey;
extern NSString* DD_OptimalNumberMinorIntervalsKey;

extern NSString* DD_OptimalXAxisMajorIntervalsKey;

extern NSString* DD_OptimalShowYAxisBandingKey;
extern NSString* DD_OptimalYAxisBandingColourKey;
extern NSString* DD_OptimalYAxisMajorIntervalsKey;

extern NSString* DD_OptimalLineColourKey;
extern NSString* DD_OptimalPlotLineSkirtKey;
// Boiling Point
extern NSString* DD_BPVapourColourKey;
extern NSString* DD_BPLiquidColourKey;
extern NSString* DD_BPShowMinorAxisKey;
extern NSString* DD_BPNumberMinorIntervalsKey;

@interface PreferencesController : NSWindowController 
{
    IBOutlet NSColorWell* vapourColour;
    IBOutlet NSColorWell* liquidColour;

    IBOutlet NSColorWell* stageLineColour;
    IBOutlet NSColorWell* fillStageColour;
	
	IBOutlet NSColorWell* optimalBandingColour;
    IBOutlet NSColorWell* skirtFillColour;
	
	IBOutlet NSColorWell* BPVapourColour;
    IBOutlet NSColorWell* BPLiquidColour;
	
	IBOutlet NSTabView* tabView;
	IBOutlet NSToolbar* toolBar; 
	IBOutlet NSToolbarItem* prefBoilingPoint;
	IBOutlet NSToolbarItem* prefMcCabeThiele;
	IBOutlet NSToolbarItem* prefOptimum;
	
	
}

#pragma mark GETS_SETS
//
// Translating the NSData into the NSColour Objects for the Bindings.
//
- (NSColor* ) DD_VapourColour;
- (NSColor* ) DD_LiquidColour;

- (NSColor* ) DD_StageLineColour;
- (NSColor* ) DD_StageFillColour;

- (NSColor* ) DD_OptimalYAxisBandingColour;
- (NSColor* ) DD_OptimalLineColour;

- (NSColor* ) DD_BPVapourColour;
- (NSColor* ) DD_BPLiquidColour;

- (void) setDD_VapourColour: (NSColor*) newColor;
- (void) setDD_LiquidColour: (NSColor*) newColor;

- (void) setDD_StageLineColour: (NSColor*) newColor;
- (void) setDD_StageFillColour: (NSColor*) newColor;

- (void) setDD_OptimalYAxisBandingColour: (NSColor*) newColor;
- (void) setDD_OptimalLineColour: (NSColor*) newColor;

- (void) setDD_BPVapourColour: (NSColor*) newColor;
- (void) setDD_BPLiquidColour: (NSColor*) newColor;

#pragma mark DATA_MANIPULATION 
//
// Reset the Vapour/Liquid Colours.
//
- (IBAction) resetMcCabeValues: (id) sender;
- (IBAction) resetOptimalValues: (id) sender;

#pragma mark IB_ACTION
//
- (IBAction) showTabPanel: (id) sender;


@end
