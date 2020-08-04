//
//  DataSet.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 06/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//
  
#import <Cocoa/Cocoa.h>

#import "DataSource.h"
#import "FileDataSource.h"
#import "RelativeVolatilityDataSource.h"
 
@interface DataSet : NSObject <NSCoding>
{
    NSString* name;
    DataSourceType sourceType;
    DataSource* selectedSource;
    
    // Temporary keep hold of the other datasources selected for this DataSet.
    //
    NSMutableDictionary* dataSources; // ( DataSourceType, NSMutableDictionary dataset_to_plot )
}

#pragma mark INITIALISE

- (id) initWithSourceType: (DataSourceType) sourceType;
- (id) initWithInitialValues;
- (id) initWithTestData;


#pragma mark GETS_SETS

- (DataSource*) setSelectedDataSource: (DataSourceType) type;

// 
- (NSString*) getDataSourceTypeDescription;
- (NSString*) getDataSourceTypeDescription:(DataSourceType) sourceType;
- (DataSourceType) getDataSourceTypeFromDescription:(NSString*) sourceDescription;
- (void) setInitialData;

#pragma mark TESTDATA 
//
// Test Information
//
- (void) setTestData;

#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder;
- (void) encodeWithCoder: (NSCoder* ) coder;

#pragma mark PROPERTIES 
//
@property (retain) NSMutableDictionary* dataSources;
@property (retain) DataSource* selectedSource;
@property (copy, readwrite) NSString* name;
@property DataSourceType sourceType;

@end
