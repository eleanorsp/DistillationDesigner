//
//  DataSource.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#define X_AXIS @"X-Axis"
#define Y_AXIS @"Y-Axis"
#define UNDEFINED @"Undefined"
#define ROW_COUNT @"Row Count"

#define kFILE_COMPONENTS_TITLE @"Components:"
#define kFILE_MOLECULAR_WEIGHT_TITLE  @"Molecular Weight (g/mol):"
#define kFILE_LATENT_HEAT_TITLE @"Latent Heat (J/mol):"
#define kFILE_SPECIFIC_HEAT_CAPACITY_TITLE @"Specific Heat Capacity (J/mol.degreesC):"
#define kFILE_PRESSURE_TITLE @"Pressure (kPa):"
#define kFILE_DATA_TITLE @"VLE Data (x (mol frac),y (mol frac),temperature (degreesC) ):"
#define kNOT_SET @"Not Set"


//
// Array Sort Method
//
NSInteger xDataSort (id num1, id num2, void *context);

typedef enum {
    NOT_SET, MANUAL, FROM_EXISTING_SET, FROM_FILE, VIA_CONSTANT_REL_VOL, FROM_LIVE_FEED, FROM_DATABASE
} DataSourceType;

typedef enum {
     DIRECTION_UP, DIRECTION_DOWN
} RowDirectionType;


@interface DataSource : NSObject <NSCoding>
{
    NSMutableArray* data; // NSMutableArray* of NSArray* ).
	NSMutableArray* smoothedData; // NSMutableArray* of NSArray* ).

    NSMutableDictionary* formaters; // ( Column Name, formatter).
    
    // Default X, Y, Z information.
    NSString* xColumnData;
    NSString* yColumnData;
	NSString* zColumnData;
	
	NSNumber* xMolecularWeight; // g/mol
	NSNumber* yMolecularWeight;
	
	NSNumber* xLatentHeat;
	NSNumber* yLatentHeat;

	NSNumber* xSpecificHeat;
	NSNumber* ySpecificHeat;
	
	NSNumber* xBoilingPoint; // 'C
	NSNumber* yBoilingPoint; // 'C
	
	NSNumber* pressure;		// KPa
}

#pragma mark PROPERTIES 
//
// Return the Size of Data held in the source.
//
@property (retain) NSString* xColumnData;
@property (retain) NSString* yColumnData;
@property (retain) NSString* zColumnData;

@property (retain) NSNumber* xMolecularWeight;
@property (retain) NSNumber* yMolecularWeight;

@property (retain) NSNumber* xLatentHeat;
@property (retain) NSNumber* yLatentHeat;

@property (retain) NSNumber* xSpecificHeat;
@property (retain) NSNumber* ySpecificHeat;

@property (retain) NSMutableArray* data;
@property (retain) NSMutableArray* smoothedData;

@property (retain) NSNumber* xBoilingPoint;
@property (retain) NSNumber* yBoilingPoint;

@property (retain) NSNumber* pressure;

#pragma mark GETS_SETS
//
// Returns the DataSet which needs to be plotted.
//
- (NSArray*) allColumnData;

#pragma mark DATA_MANIPULATION 
//
// Data Manipulation.
//
- (BOOL) addNewRow;
- (BOOL) deleteRow: (NSUInteger) rowNumber;

- (BOOL) sortDataSet;
- (void) smoothDataPoints;

- (BOOL) checkUniqueXData; 
- (void) setInitialData;

- (BOOL) hasMolWeightsDefined;

#pragma mark FORMATTER 
//
// Set the Formatter for the columns.
//
//- (void) setFormatter: (NSString*) columnName
//	    formatter: (NSFormatter*) formatter;
//- (NSFormatter*) formaterForColumn: (NSString*) name;

#pragma mark TESTDATA 
//
// Test Information
//
- (void) setTestSourceData;

#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder;
- (void) encodeWithCoder: (NSCoder* ) coder;

// Export DataSource to a readable format. 
// @throws expection on successful save.
- (void) exportDataFile: (NSURL*) fileURL;

@end
