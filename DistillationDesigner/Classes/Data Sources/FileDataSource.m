//
//  FileDataSource.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 03/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import "FileDataSource.h"

@interface FileDataSource (Private) 

- (void) loadDataFromFile_version1: (NSString *) fileContents;
- (void) loadDataFromFile_version2: (NSString *) fileContents;

@end


@implementation FileDataSource

- (void) loadDataFromFile: (NSString*) selectedFileName
{
	// Check to see which data format we have.
	//
	fileName = selectedFileName;
	
	NSError* errorFile = nil;
	NSStringEncoding encoding;
	NSString* fileContents = [ NSString stringWithContentsOfFile:fileName  usedEncoding: &encoding error: &errorFile ];
	if ( errorFile != nil )
	{
		NSString* message = [ NSString stringWithFormat:@"Unable to read the data file. \n Reason: %@", errorFile.domain ];
		NSException* fileException = [NSException
									  exceptionWithName:@"FileContainsWrongContents"
									  reason:message
									  userInfo:nil];
		@throw fileException;		
	}

	NSRange range =  [ fileContents rangeOfString: @"Components:" ];
	if ( range.length == NSNotFound || range.location > 0 )
	{	
		[ self loadDataFromFile_version1: fileContents ];
		
		NSString* message = NSLocalizedString( @"Warning: Old data file version, molecular weight, latent heat and specific heat data are missing for the two components", @"" );
		NSException* fileException = [NSException exceptionWithName: EXCEPTION_OldFileVersion
															 reason: message
														   userInfo: nil];
		@throw fileException;
	}
	else 
		[ self loadDataFromFile_version2: fileContents ];
	
	return;
}

#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{
	self = [ super initWithCoder: coder ];
	
	fileName = [ coder decodeObjectForKey: @"ySpecificHeat" ];

	return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
	[ super encodeWithCoder: coder ];
	
    [ coder encodeObject: fileName forKey:@"File Name" ];

	return;
}

#pragma mark PRIVATE METHODS

// We only deal with data files of the format.
// Component Name 1 \tab Component Name 2
// Data Item 1 must be 0.0 \tab 0.0.
// Last Data Item must be 1.0 \tab 1.0.
//
- (void) loadDataFromFile_version1: (NSString *) fileContents
{	
	// Clear down the existing data.
	//
	[ data removeAllObjects ];
	
	// Prepare an array to hold the files numbers 
	// 	
	// Make sure any \r are replaced with a \n
	NSString* convertedFileContents = [ fileContents stringByReplacingOccurrencesOfString:@"\r" withString:@"\n" ];
	NSEnumerator * lineEnumerator = [ [ convertedFileContents componentsSeparatedByString:@"\n" ] objectEnumerator ]; 
	
	NSString * enumeratedLine; 
	// Prepare to process each line of numbers 
	NSEnumerator * numberEnumerator; 
	
	// First pick off the Component Names.
	enumeratedLine = [ lineEnumerator nextObject ];
	NSEnumerator* componentEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
	xColumnData = [ componentEnumerator nextObject ];
	yColumnData = [ componentEnumerator nextObject ]; 
	zColumnData = [ componentEnumerator nextObject ]; 

	// Now get the data.
	//
	int count = 0;
	NSNumber* xvalue;
	NSNumber* yvalue;
	NSNumber* zvalue;

	while ( ( enumeratedLine = [ lineEnumerator nextObject ] ) ) 
	{ 
		numberEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 

		NSString* xvalueString = [ numberEnumerator nextObject ];
		NSString* yvalueString = [ numberEnumerator nextObject ];
		NSString* zvalueString = [ numberEnumerator nextObject ];

		if ( [ xvalueString length ] == 0 )
		{
			// Ignore.
			NSLog( @"FileDataSource: loadDataFromFile Warning: Bad data in file." );
		}
		else if ( [ yvalueString length ] == 0 )
		{
			NSLog( @"FileDataSource: loadDataFromFile Warning: Bad data in file." );			
		}
		else if ( [ zvalueString length ] == 0 )
		{
			NSLog( @"FileDataSource: loadDataFromFile Warning: Bad data in file." );			
		}		
		else
		{
			xvalue = [ [ NSNumber alloc ] initWithDouble: [ xvalueString doubleValue ] ];
			yvalue = [ [ NSNumber alloc ] initWithDouble: [ yvalueString doubleValue ] ];
			zvalue = [ [ NSNumber alloc ] initWithDouble: [ zvalueString doubleValue ] ];
			
			// Check if the first are 0.0, 0.0
			if ( count == 0 )
			{
				if ( [ xvalue doubleValue ] != 0.0 && [ yvalue doubleValue ] != 0.0 )
				{
					NSException* fileException = [NSException
								   exceptionWithName:@"FileContainsWrongContents"
								   reason:@"File data set does not begin with 0.0 0.0 as initial component values."
								   userInfo:nil];
					@throw fileException;
				}
				
				xBoilingPoint = zvalue;
			}

			count++;
			NSMutableArray* twoDData;
			twoDData = [ [ NSMutableArray alloc ] initWithObjects: xvalue, yvalue, zvalue, nil ];
			[ data addObject: twoDData ];
		}
	} // END WHILE
	
	// Check if the last are 1.0, 1.0
	if ( [ xvalue doubleValue ] != 1.0 && [ yvalue doubleValue ] != 1.0 )
	{
		NSException* fileException = [NSException
										exceptionWithName:@"FileContainsWrongContents"
										reason:@"File data set does not end with 1.0 1.0 as last component values."
										userInfo:nil];
		@throw fileException;
	}
	
	// Set the boiling values.
	yBoilingPoint = zvalue;
	
	return;
}

- (void) loadDataFromFile_version2: (NSString *) fileContents
{	
	// Clear down the existing data.
	//
	[ data removeAllObjects ];
		
	// Make sure any \r are replaced with a \n
	NSString* convertedFileContents = [ fileContents stringByReplacingOccurrencesOfString:@"\r" withString:@"\n" ];
	NSEnumerator * lineEnumerator = [ [ convertedFileContents componentsSeparatedByString:@"\n" ] objectEnumerator ]; 
	
	NSString * enumeratedLine; 
	// Prepare to process each line of numbers 
	NSEnumerator * numberEnumerator; 
	
	// First pick off the Component Names.
	enumeratedLine = [ lineEnumerator nextObject ]; // Components:
	if ( [ enumeratedLine isEqualToString: kFILE_COMPONENTS_TITLE ] == YES )
	{
		enumeratedLine = [ lineEnumerator nextObject ];
		
		NSEnumerator* componentEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
		xColumnData = [ componentEnumerator nextObject ];
		yColumnData = [ componentEnumerator nextObject ]; 
		zColumnData = @"Temperature"; 
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason: [ NSString stringWithFormat: @"Expected to read \'%@\' on the first line.", kFILE_COMPONENTS_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
	
	// Now the molecular weight
	enumeratedLine = [ lineEnumerator nextObject ]; // Molecular Weight:
	if ( [ enumeratedLine isEqualToString:kFILE_MOLECULAR_WEIGHT_TITLE ] == YES )
	{
		enumeratedLine = [ lineEnumerator nextObject ];
		if ( [enumeratedLine isEqualToString: kNOT_SET ] == NO )
		{
			NSEnumerator* molWeightEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
			
			NSString* value = [ molWeightEnumerator nextObject ];
			xMolecularWeight = [ NSNumber numberWithDouble: [ value doubleValue ] ];
			value = [ molWeightEnumerator nextObject ];
			yMolecularWeight = [ NSNumber numberWithDouble: [ value doubleValue ] ]; 		
		}
		else 
		{
			xMolecularWeight = nil;
			yMolecularWeight = nil;
		}
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason: [ NSString stringWithFormat: @"Expected to read \'%@' after \'%@'", kFILE_MOLECULAR_WEIGHT_TITLE, kFILE_COMPONENTS_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
		
	enumeratedLine = [ lineEnumerator nextObject ]; // Latent Heat:
	if ( [ enumeratedLine isEqualToString: kFILE_LATENT_HEAT_TITLE ] == YES )
	{
		if ( [enumeratedLine isEqualToString: kNOT_SET ] == NO )
		{
			enumeratedLine = [ lineEnumerator nextObject ];

			NSEnumerator* latentHeatEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
			NSString* value = [ latentHeatEnumerator nextObject ];
			
			xLatentHeat = [ NSNumber numberWithDouble: [ value doubleValue ] ];
			value = [ latentHeatEnumerator nextObject ];
			yLatentHeat = [ NSNumber numberWithDouble: [ value doubleValue ] ];
		}
		else 
		{
			xLatentHeat = nil;
			yLatentHeat = nil;
		}
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason: [ NSString stringWithFormat: @"Expected to read \'%@\' after \'%@\'", kFILE_LATENT_HEAT_TITLE, kFILE_MOLECULAR_WEIGHT_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
	
	
	enumeratedLine = [ lineEnumerator nextObject ]; // Ignore Specific Heat Capacity:
	if ( [ enumeratedLine isEqualToString: kFILE_SPECIFIC_HEAT_CAPACITY_TITLE ] == YES )
	{
		enumeratedLine = [ lineEnumerator nextObject ];
		if ( [enumeratedLine isEqualToString: kNOT_SET ] == NO )
		{
			NSEnumerator* specificHeatEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
			NSString* value = [ specificHeatEnumerator nextObject ];
			
			xSpecificHeat = [ NSNumber numberWithDouble: [ value doubleValue ] ];
			value = [ specificHeatEnumerator nextObject ];
			ySpecificHeat = [ NSNumber numberWithDouble: [ value doubleValue ] ];
		}
		else 
		{
			xSpecificHeat = nil;
			ySpecificHeat = nil;
		}		
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason: [ NSString stringWithFormat: @"Expected to read \'%@\' after \'%@\'", kFILE_SPECIFIC_HEAT_CAPACITY_TITLE, kFILE_LATENT_HEAT_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
	
	enumeratedLine = [ lineEnumerator nextObject ]; //  Pressure:
	if ( [ enumeratedLine isEqualToString: kFILE_PRESSURE_TITLE ] == YES )
	{
		enumeratedLine = [ lineEnumerator nextObject ];
		if ( [enumeratedLine isEqualToString: kNOT_SET] == NO )
		{			
			pressure = [ NSNumber numberWithDouble: [ enumeratedLine doubleValue ] ];
		}
		else 
		{
			pressure = nil;
		}		
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason:  [ NSString stringWithFormat: @"Expected to read \'%@\' after \'%@\'", kFILE_PRESSURE_TITLE, kFILE_SPECIFIC_HEAT_CAPACITY_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
	
	// Now get the data.
	//
	NSNumber* xvalue;
	NSNumber* yvalue;
	NSNumber* zvalue;
	
	enumeratedLine = [ lineEnumerator nextObject ]; // Ignore FILE_DATA_TITLE
	if ( [ enumeratedLine isEqualToString: kFILE_DATA_TITLE ] == YES )
	{
		enumeratedLine = [ lineEnumerator nextObject ]; // Read the number of data points.
		
		int count = [ enumeratedLine intValue ];
		for ( int counter = 0; counter < count; counter++ )
		{ 
			enumeratedLine = [ lineEnumerator nextObject ];
			if ( enumeratedLine == nil )
			{	
				NSException* fileException = [NSException
											  exceptionWithName:@"FileContainsWrongContents"
											  reason:@"The number of data points is less than expected."
											  userInfo:nil];
				@throw fileException;
			}
				
			numberEnumerator = [ [ enumeratedLine componentsSeparatedByString:@"\t" ] objectEnumerator ]; 
			
			NSString* xvalueString = [ numberEnumerator nextObject ];
			NSString* yvalueString = [ numberEnumerator nextObject ];
			NSString* zvalueString = [ numberEnumerator nextObject ];
			
			if ( xvalueString == nil || [ xvalueString length ] == 0 ||
				 yvalueString == nil || [ yvalueString length ] == 0 ||
				 zvalueString == nil || [ zvalueString length ] == 0 )
			{
				NSException* fileException = [NSException
											  exceptionWithName:@"FileContainsWrongContents"
											  reason:@"Error reading valid data points in the data file."
											  userInfo:nil];
				@throw fileException;
			}	
			else
			{
				xvalue = [ [ NSNumber alloc ] initWithDouble: [ xvalueString doubleValue ] ];
				yvalue = [ [ NSNumber alloc ] initWithDouble: [ yvalueString doubleValue ] ];
				zvalue = [ [ NSNumber alloc ] initWithDouble: [ zvalueString doubleValue ] ];
				
				// Check if the first are 0.0, 0.0
				if ( counter == 0 )
				{
					if ( [ xvalue doubleValue ] != 0.0 && [ yvalue doubleValue ] != 0.0 )
					{
						NSException* fileException = [NSException
													  exceptionWithName:@"FileContainsWrongContents"
													  reason:@"File data set does not begin with 0.0 0.0 as initial component values."
													  userInfo:nil];
						@throw fileException;
					}
					
					xBoilingPoint = zvalue;
				}
				
				NSMutableArray* twoDData;
				twoDData = [ [ NSMutableArray alloc ] initWithObjects: xvalue, yvalue, zvalue, nil ];
				[ data addObject: twoDData ];
			}
		} // END FOR
	}
	else 
	{
		NSException* fileException = [NSException exceptionWithName:@"FileContainsWrongContents"
															 reason: [ NSString stringWithFormat: @"Expected to read \'%@' after \'%@\'", kFILE_DATA_TITLE, kFILE_PRESSURE_TITLE ]
														   userInfo: nil ];
		@throw fileException;
	}
		
	// Check if the last values are 1.0, 1.0
	if ( [ xvalue doubleValue ] != 1.0 && [ yvalue doubleValue ] != 1.0 )
	{
		NSException* fileException = [NSException
									  exceptionWithName:@"FileContainsWrongContents"
									  reason:@"File data set does not end with 1.0 1.0 as last component values."
									  userInfo:nil];
		@throw fileException;
	}
	
	yBoilingPoint = zvalue;
	
	return;
}

#pragma mark PROPERTIES 

@synthesize fileName;


@end
