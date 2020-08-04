//
//  DataSet.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 06/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//
  
#import "DataSet.h"


@implementation DataSet

#pragma mark INITIALISE 
// 
// Initialisation routines.
//
- (id) init
{
	if ( ( self = [super init] ) ) 
    {
		dataSources = [[ NSMutableDictionary alloc ] init];
		[ self setSelectedDataSource: MANUAL ];
	}
	
	return self;
}

- (id) initWithSourceType: (DataSourceType) itsSourceType
{
    if ( ( self = [super init] ) ) 
    {
		sourceType = itsSourceType;
		dataSources = [[ NSMutableDictionary alloc ] init];
		[ self setSelectedDataSource: sourceType ];
    }
    
    return self;
}

- (id) initWithInitialValues
{
	if ( ( self = [super init] ) ) 
    {
		sourceType = MANUAL;
		dataSources = [[ NSMutableDictionary alloc ] init];
		[ self setSelectedDataSource: sourceType ];
		
		//
		// Initialise the set with data.
		//
		[ self setInitialData ];
    }
    
    return self;
}


- (id) initWithTestData
{
	if ( ( self = [super init] ) ) 
    {
		sourceType = MANUAL;
		dataSources = [[ NSMutableDictionary alloc ] init];
		[ self setSelectedDataSource: sourceType ];
		
		//
		// Initialise the set with data.
		//
		[ self setTestData ];
    }
    
    return self;
}

#pragma mark GETS_SETS
//
// If the selected data source is not present create one.
// 
//
- (DataSource*) setSelectedDataSource: (DataSourceType) type
{
    DataSource* newSelected = [ dataSources objectForKey:[ self getDataSourceTypeDescription:type ] ];
    
    // If we have not got it, create a new temporary one.
    //
    if ( newSelected == nil )
    {
		switch ( type )
		{
			case MANUAL:
				newSelected = [ [ DataSource alloc] init ];
				[ dataSources setValue:newSelected forKey:[ self getDataSourceTypeDescription: type ] ];
				break;
			
			case FROM_FILE:
				newSelected = [ [ FileDataSource alloc ] init ];
				[ dataSources setValue:newSelected forKey:[ self getDataSourceTypeDescription: type ] ];
				break;

			case VIA_CONSTANT_REL_VOL:
				newSelected = [ [ RelativeVolatilityDataSource alloc ] init ];
				[ dataSources setValue: newSelected forKey: [ self getDataSourceTypeDescription: type ] ];
				break;
				
			default: NSLog( @"Source type is not yet implemented" );
				break;
		}
    }
    
    sourceType = type;
    selectedSource = newSelected;
    
    return selectedSource;
}

//
// Get the Data Source Name.
//
- (NSString*) getDataSourceTypeDescription
{
    return [ self getDataSourceTypeDescription:sourceType ];
}

- (NSString*) getDataSourceTypeDescription:(DataSourceType) theSourceType
{
    switch ( theSourceType )
    {
		case NOT_SET:
			 return @"Not Set";
			
		case MANUAL:
			 return @"Manual Input";
			
		case FROM_EXISTING_SET:
			 return @"Existing Set: ";
			
		case FROM_FILE: 
			 return @"From File";
		
		case FROM_LIVE_FEED:
			 return @"From Live Feed";
		
		case FROM_DATABASE:
			 return @"From Database";
			
		case VIA_CONSTANT_REL_VOL:
			return @"Constant Rel. Volatility";
			 
		default:
			return @"Not Set";

    }
}

- (DataSourceType) getDataSourceTypeFromDescription:(NSString*) sourceDescription
{
	if ( [ sourceDescription compare:@"Not Set" ] == 0 )
		return NOT_SET;
	else if ( [ sourceDescription compare:@"Manual Input" ] == 0 )
		return MANUAL;
	else if ( [ sourceDescription compare:@"Existing Set" ] == 0 )
		return FROM_EXISTING_SET;
	else if ( [ sourceDescription compare:@"From File" ] == 0 )
		return FROM_FILE;
	else if ( [ sourceDescription compare: @"From Live Feed"] == 0 )
		return FROM_LIVE_FEED;
	else if ( [ sourceDescription compare:  @"From Database"] == 0 )
		return FROM_DATABASE;
	else
		return NOT_SET;
}

- (void) setInitialData
{
	[ selectedSource setInitialData ];
	
	return;
}

#pragma mark TESTDATA 
//
// Test Information
//
- (void) setTestData
{
	[ selectedSource setTestSourceData ];
	
	return;
}




#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
    self = [ super init];
	
    name = [ coder decodeObjectForKey:@"name"];
 //   [ coder decodeValueOfObjCType:@encode(DataSourceType) at:&sourceType ];
	
	NSString* sourceTypeString = [ coder decodeObjectForKey:@"sourceType" ]; 
	sourceType = [ self getDataSourceTypeFromDescription:sourceTypeString ];
	selectedSource = [ coder decodeObjectForKey:@"selectedSource" ];
	
	// Add it to the dataSources.
	//
	[ dataSources setValue:selectedSource forKey:[ self getDataSourceTypeDescription: sourceType ] ];
	
    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
    [ coder encodeObject:name forKey:@"name" ];

	NSString* sourceTypeString = [ self getDataSourceTypeDescription: sourceType ];	
    [ coder encodeObject:sourceTypeString forKey:@"sourceType" ];
    [ coder encodeObject:selectedSource forKey:@"selectedSource" ];
	
	// We'll ignore what is in the dictionary.
	
    return;
}


#pragma mark PROPERTIES 
//
@synthesize dataSources;
@synthesize selectedSource;
@synthesize sourceType;
@synthesize name;

@end
