//
//  FileDataSource.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 03/05/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DataSource.h"

//
// Exception Types
#define EXCEPTION_OldFileVersion @"OldFileVersionException"

@interface FileDataSource : DataSource 
{
	NSString* fileName;
}

//
// Properties
//
@property (retain) NSString* fileName;

//
// Methods
//

// Read and load the data from a file.
//		@throw NSException on failure to load anything.
- (void) loadDataFromFile: (NSString*) selectedFileName; 

@end
