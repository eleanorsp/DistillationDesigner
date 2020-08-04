//
//  DataSource.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 07/10/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//

#import "DataSource.h"

extern double blendData(int k, int t, int *u, double v);  // calculate the blending value

#pragma mark EXTERNAL_FUNCTION 
// 
//
NSInteger xDataSort(id num1, id num2, void *context)
{
    NSNumber* v1 = [num1 objectAtIndex:0 ];
    NSNumber* v2 = [num2 objectAtIndex:0 ];
    
	return [ v1 compare: v2 ];
}

/*********************************************************************
 
 Parameters:
 n          - the number of control points minus 1
 t          - the degree of the polynomial plus 1
 control    - control point array made up of point stucture
 output     - array in which the calculate spline points are to be put
 num_output - how many points on the spline are to be calculated
 
 Pre-conditions:
 n+2>t  (no curve results if n+2<=t)
 control array contains the number of points specified by n
 output array is the proper size to hold num_output point structures
 
 
 **********************************************************************/
//
// Grabbed this code from the Internet.
//
typedef struct point {
	double x;
	double y;
	double z;
} cpoint;


void compute_intervals(int *u, int n, int t)   // figure out the knots
{
	int j;
	
	for (j=0; j<=n+t; j++)
	{
		if (j<t)
			u[j]=0;
		else
			if ((t<=j) && (j<=n))
				u[j]=j-t+1;
			else
				if (j>n)
					u[j]=n-t+2;  // if n-t=-2 then we're screwed, everything goes to 0
	}
}

void compute_point(int *u, int n, int t, double v, cpoint *control,
				  cpoint *output)
{
	int k;
	double temp;
	
	// initialize the variables that will hold our outputted point
	output->x=0;
	output->y=0;
	output->z=0;
	
	for (k=0; k<=n; k++)
	{
		temp = blendData(k,t,u,v);  // same blend is used for each dimension coordinate
		output->x = output->x + (control[k]).x * temp;
		output->y = output->y + (control[k]).y * temp;
		output->z = output->z + (control[k]).z * temp;
	}
}

double blendData(int k, int t, int *u, double v)  // calculate the blending value
{
	double value;
	
	if (t==1)			// base case for the recursion
	{
		if ((u[k]<=v) && (v<u[k+1]))
			value=1;
		else
			value=0;
	}
	else
	{
		if ((u[k+t-1]==u[k]) && (u[k+t]==u[k+1]))  // check for divide by zero
			value = 0;
		else
			if (u[k+t-1]==u[k]) // if a term's denominator is zero,use just the other
				value = (u[k+t] - v) / (u[k+t] - u[k+1]) * blendData(k+1, t-1, u, v);
			else
				if (u[k+t]==u[k+1])
					value = (v - u[k]) / (u[k+t-1] - u[k]) * blendData(k, t-1, u, v);
				else
					value = (v - u[k]) / (u[k+t-1] - u[k]) * blendData(k, t-1, u, v) +
					(u[k+t] - v) / (u[k+t] - u[k+1]) * blendData(k+1, t-1, u, v);
	}
	return value;
}


void bspline(int n, int t, cpoint *control, cpoint *output, int num_output)
{
	int *u;
	double increment,interval;
	cpoint calcxyz;
	int output_index;
	
	u = malloc( sizeof(int) * (n+t+1) );
	compute_intervals(u, n, t);
	
	increment=(double) (n-t+2)/(num_output-1);  // how much parameter goes up each time
	interval=0;
	
	for (output_index=0; output_index<num_output-1; output_index++)
	{
		compute_point(u, n, t, interval, control, &calcxyz);
		output[output_index].x = calcxyz.x;
		output[output_index].y = calcxyz.y;
		output[output_index].z = calcxyz.z;
		interval=interval+increment;  // increment our parameter
	}
	output[num_output-1].x=control[n].x;   // put in the last point
	output[num_output-1].y=control[n].y;
	output[num_output-1].z=control[n].z;
	
	free( u );
}



@implementation DataSource

#pragma mark INITIALISE
//
- (id) init
{
    if ( (self = [super init]) ) 
    {
		data = [ [ NSMutableArray alloc] init ];
		
		xColumnData = UNDEFINED;
		yColumnData = UNDEFINED;
		zColumnData = UNDEFINED;

    }
    
    return self;
}


#pragma mark GETS_SETS
//
//
//
- (NSArray*) allColumnData
{
	NSMutableArray* columnTitles = [ [ NSMutableArray alloc ] initWithCapacity:3 ];
	
	[ columnTitles addObject:xColumnData ];
	[ columnTitles addObject:yColumnData ];
	[ columnTitles addObject:zColumnData ];
	
	return columnTitles;
}

#pragma mark DATA_MANIPULATION 
//
// Adds a new default row of information with zeros as their value.
//
- (BOOL) addNewRow
{
	NSNumber* xNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* yNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* zNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];

	NSMutableArray* twoDData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: twoDData ];
	
    return YES;
}

// 
// Removes a row at line number.
//
- (BOOL) deleteRow: (NSUInteger) rowNumber
{
	if ( rowNumber >= [ data count ] )
		return NO;
		
	[ data removeObjectAtIndex:rowNumber ];

    return YES;
}

- (BOOL) sortDataSet
{
/*	NSMutableArray* tempData = [ [ NSMutableArray alloc ] init ];
	int position = 0;

	for ( NSMutableArray *xyData in data )
	{
		BOOL added = NO;
		
		for ( tempPosition = 0; tempPosition < [ tempData count ]; tempPosition++ )
		{
			NSMutableArray* tempxyData = [ tempData objectAtIndex:tempPosition ];
			if ( [ tempxyData objectAtIndex: 0 ] > [ xyData objectAtIndex: 0 ] )
			{
				[ tempData insertObject:xyData atIndex:tempPosition ];
				added = YES;
				
				break; // From for loop.
			}
		}
		
		if ( added == NO )
			[ tempData addObject:xyData ];
	}
	
	data = tempData;
*/	
	[ data sortUsingFunction:xDataSort context:nil ]; 

	return YES;
}

//
// Checks to see if the x-axis data is unique.
//
// TBD
- (BOOL) checkUniqueXData
{
	NSMutableArray* sortedArray = [ [ NSMutableArray alloc ] initWithArray: [ data sortedArrayUsingFunction: xDataSort context: nil ] ];
	
	int position;
	for ( position = 0; position < [ sortedArray count ] -1; position++ )
	{	
		//NSMutableArray* currentData = [ sortedArray objectAtIndex:position ];
		//NSMutableArray* nextData = [ sortedArray objectAtIndex:position+1 ];
		
//		if ( xDataSort(currentData, nextData, nil) == NSOrderedSame )
//			return NO;
	}
	
	return YES;
}


- (BOOL) hasMolWeightsDefined
{
	NSLog(@"DataSource: canConvertMolFracsToWeightFrac" );
	
	if ( yMolecularWeight == nil || [ yMolecularWeight doubleValue ] <= 0 )
		return NO;
	if ( xMolecularWeight == nil || [ xMolecularWeight doubleValue ] <= 0 )
		return NO;

	return YES;
}

#pragma mark TESTDATA 
//
// Test Information
//
- (void) setTestSourceData
{
	NSMutableArray* xyCompTempData;
	NSNumber* xNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* yNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* zNumber = [ [ NSNumber alloc ] initWithDouble:100 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

	xNumber = [ [ NSNumber alloc ] initWithDouble:0.019 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.170 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:95.5 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.072 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.389 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:89.0 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.097 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.438 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:86.7 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.124 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.470 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:85.3 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.166 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.509 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:84.1 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.234 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.545 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:82.7 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.261 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.558 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:82.3 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.327 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.583 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:81.5 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.397 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.612 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:80.7 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.508 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.656 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:79.8 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.520 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.660 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:79.7 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.573 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.684 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:79.3 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.676 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.739 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:78.74 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

    xNumber = [ [ NSNumber alloc ] initWithDouble:0.747 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.782 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:78.24 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
    
    xNumber = [ [ NSNumber alloc ] initWithDouble:0.894 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.894 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:78.15 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
    
    xNumber = [ [ NSNumber alloc ] initWithDouble:1.0 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:1.0 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:78.1];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
    
	xColumnData = @"Ethanol";
	yColumnData = @"Water";
	zColumnData = @"Temperature";
	
	xMolecularWeight = [ [ NSNumber alloc ] initWithDouble: 46.0634 ];
	yMolecularWeight = [ [ NSNumber alloc ] initWithDouble: 18.0152 ];
    
    xLatentHeat = [ [ NSNumber alloc ] initWithDouble: 	38600.0 ];
    yLatentHeat = [ [ NSNumber alloc ] initWithDouble: 40650.0 ];
    
    xSpecificHeat = [ [ NSNumber alloc ] initWithDouble: 112.4 ];
    ySpecificHeat = [ [ NSNumber alloc ] initWithDouble: 75.327 ];
    
    pressure = [ [ NSNumber alloc ] initWithDouble: 98.0655 ]; // kPa
	
	[ self smoothDataPoints ];

	return;
}


- (void) setInitialData
{
	NSMutableArray* xyCompTempData;
	NSNumber* xNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* yNumber = [ [ NSNumber alloc ] initWithDouble:0.0 ];
	NSNumber* zNumber = [ [ NSNumber alloc ] initWithDouble:10 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.1 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.1 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:11 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.2 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.2 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:12 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.3 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.3 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:13 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.4 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.4 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:14 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.5 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.5 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:15 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.6 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.6 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:16 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

	xNumber = [ [ NSNumber alloc ] initWithDouble:0.7 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.7 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:17 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:0.8 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.8 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:18 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];

	xNumber = [ [ NSNumber alloc ] initWithDouble:0.9 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:0.9 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:19 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xNumber = [ [ NSNumber alloc ] initWithDouble:1.0 ];
	yNumber = [ [ NSNumber alloc ] initWithDouble:1.0 ];
	zNumber = [ [ NSNumber alloc ] initWithDouble:20 ];
	xyCompTempData = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
	[ data addObject: xyCompTempData ];
	
	xColumnData = @"Component 1";
	yColumnData = @"Component 2";
	zColumnData = @"Temperature";
	
	return;
}


- (void) smoothDataPoints
{
	int i;
	int n = [ data count ];           // number of control points = n+1
	int t = 4;           // degree of polynomial = t-1
	
	cpoint *pts;          // allocate our control point array
	pts = malloc( sizeof(cpoint) * n );

	int count = 0;
	for ( NSMutableArray* dataPoint in data )
	{
		pts[ count ].x = [ [ dataPoint objectAtIndex:0 ] doubleValue ];  
		pts[ count ].y = [ [ dataPoint objectAtIndex:1 ] doubleValue ];
		pts[ count ].z = [ [ dataPoint objectAtIndex:2 ] doubleValue ];
		count++;
	}
	
	int resolution = [ data count ] * 10;  // how many points our in our output array
	cpoint *out_pts;
	out_pts = malloc( sizeof(cpoint) * resolution );
	
	bspline(n-1, t, pts, out_pts, resolution);
	
	smoothedData = [ [ NSMutableArray alloc ] init ];
	for ( i = 0;  i < resolution; i++ )
	{
		NSNumber* xNumber = [ [ NSNumber alloc ] initWithDouble: out_pts[ i ].x ];
		NSNumber* yNumber = [ [ NSNumber alloc ] initWithDouble: out_pts[ i ].y ];
		NSNumber* zNumber = [ [ NSNumber alloc ] initWithDouble: out_pts[ i ].z ];
		NSMutableArray* smoothedDataPoint = [ [ NSMutableArray alloc ] initWithObjects: xNumber, yNumber, zNumber, nil ];
		
		[ smoothedData addObject: smoothedDataPoint ];
	}
	
	free( out_pts );
	
	return;
}






#pragma mark ARCHIVING 
//
// Setup the Archiving.
//
- (id) initWithCoder:(NSCoder* ) coder
{    
	data = [coder decodeObjectForKey:@"data"];
	
	xColumnData = [coder decodeObjectForKey:@"xColumnData"];
	yColumnData = [coder decodeObjectForKey:@"yColumnData"];
	zColumnData = [coder decodeObjectForKey:@"zColumnData"];
	
	xMolecularWeight = [ coder decodeObjectForKey: @"xMolecularWeight" ];
	yMolecularWeight = [ coder decodeObjectForKey: @"yMolecularWeight" ];

	xBoilingPoint = [ coder decodeObjectForKey: @"xBoilingPoint" ];
	yBoilingPoint = [ coder decodeObjectForKey: @"yBoilingPoint" ];

	xLatentHeat = [ coder decodeObjectForKey: @"xLatentHeat" ];
	yLatentHeat = [ coder decodeObjectForKey: @"yLatentHeat" ];

	xSpecificHeat = [ coder decodeObjectForKey: @"xSpecificHeat" ];
	ySpecificHeat = [ coder decodeObjectForKey: @"ySpecificHeat" ];
	
	[ self smoothDataPoints ];

    return self;
}

- (void) encodeWithCoder: (NSCoder* ) coder
{
    [ coder encodeObject:data forKey:@"data" ];
    [ coder encodeObject:xColumnData forKey:@"xColumnData" ];
    [ coder encodeObject:yColumnData forKey:@"yColumnData" ];
    [ coder encodeObject:zColumnData forKey:@"zColumnData" ];

	[ coder encodeObject:xMolecularWeight forKey:@"xMolecularWeight" ];
    [ coder encodeObject:yMolecularWeight forKey:@"yMolecularWeight" ];

	[ coder encodeObject:xBoilingPoint forKey:@"xBoilingPoint" ];
    [ coder encodeObject:yBoilingPoint forKey:@"yBoilingPoint" ];
	
	[ coder encodeObject:xLatentHeat forKey:@"xLatentHeat" ];
	[ coder encodeObject:yLatentHeat forKey:@"yLatentHeat" ];

	[ coder encodeObject:xSpecificHeat forKey:@"xSpecificHeat" ];
	[ coder encodeObject:ySpecificHeat forKey:@"ySpecificHeat" ];
	
    return;
}


// Export DataSource to a readable format. 
//
- (void) exportDataFile: (NSURL*) fileURL
{
	NSLog( @"DataSource: exportDataFile with %@", [ fileURL absoluteString ] );
						
	NSError* errorFile = nil;
	NSStringEncoding encoding;
	
	NSMutableString* fileContents = [ NSMutableString stringWithCapacity: 200 ];
	
	[ fileContents appendString: kFILE_COMPONENTS_TITLE ];
	[ fileContents appendFormat: @"\n%@\t%@\n", xColumnData, yColumnData ];

	[ fileContents appendString: kFILE_MOLECULAR_WEIGHT_TITLE ];
	[ fileContents appendFormat: @"\n%@\t%@\n", [ xMolecularWeight stringValue ], [ yMolecularWeight stringValue ] ];

	[ fileContents appendString: kFILE_LATENT_HEAT_TITLE ];
	if ( xLatentHeat == nil || yLatentHeat == nil )
		[ fileContents appendFormat: @"\n%@\n", kNOT_SET ];
	else 
		[ fileContents appendFormat: @"\n%@\t%@\n", [ xLatentHeat stringValue ], [ yLatentHeat stringValue ] ];

	[ fileContents appendString: kFILE_SPECIFIC_HEAT_CAPACITY_TITLE ];
	if ( xSpecificHeat == nil || ySpecificHeat == nil )
		[ fileContents appendFormat: @"\n%@\n", kNOT_SET ];
	else 
		[ fileContents appendFormat: @"\n%@\t%@\n", [ xSpecificHeat stringValue ], [ ySpecificHeat stringValue ] ];
	
	[ fileContents appendString: kFILE_PRESSURE_TITLE ];
	if ( pressure == nil )
		[ fileContents appendFormat: @"\n%@\n", kNOT_SET ];
	else 
		[ fileContents appendFormat: @"\n%@\n", [ pressure stringValue ] ];
	 
	// Now get the data.
	//
	[ fileContents appendString: kFILE_DATA_TITLE ];
	[ fileContents appendFormat: @"\n%d\n", data.count ];

	for ( NSArray* dataArray in data )
	{
		[ fileContents appendFormat: @"%@\t%@\t%@\n", [ [ dataArray objectAtIndex: 0 ] stringValue ], 
													  [ [ dataArray objectAtIndex: 1 ] stringValue ], 
													  [ [ dataArray objectAtIndex: 2 ] stringValue ] ];
	}
	
	NSError* error = nil;
	if ( [ fileContents writeToURL: fileURL
						 atomically: YES
						   encoding: NSUTF8StringEncoding 
							  error: &error ] == NO )
	{
		NSString* message = [ NSString stringWithFormat:@"Unable to export the data file. \n Reason: %@", [ error localizedDescription ] ];
		NSException* fileException = [NSException
									  exceptionWithName:@"FileFailedToSave"
									  reason:message
									  userInfo:nil];
		@throw fileException;		
	}
	
	return;
}

#pragma mark PROPERTIES 
//
@synthesize yColumnData;
@synthesize xColumnData;
@synthesize zColumnData;

@synthesize xMolecularWeight;
@synthesize yMolecularWeight;

@synthesize xLatentHeat;
@synthesize yLatentHeat;

@synthesize xSpecificHeat;
@synthesize ySpecificHeat;

@synthesize xBoilingPoint;
@synthesize yBoilingPoint;

@synthesize pressure;

@synthesize data;
@synthesize smoothedData;


@end