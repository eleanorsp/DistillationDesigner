//
//  GraphLine.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 09/03/2008.
//  Copyright 2008 GraphLine. All rights reserved.
//

#import "GraphLine.h"


@implementation GraphLine

- (id) initWithStartPoint: (NSPoint) start endPoint: (NSPoint) end
{
	self = [super init];
	if (self) 
    {
		startPoint = start;
		endPoint = end;
	}
	
	return self;
}


- (BOOL) determineIntersectionPoint: (GraphLine* ) otherLine intersectionPoint: (NSPoint*) thePoint
{
	if ( thePoint == nil)
		return NO;
	
	NSPoint P4 = startPoint;
	NSPoint P3 = endPoint;
	NSPoint P2 = otherLine.startPoint;
	NSPoint P1 = otherLine.endPoint;

	//
	CGFloat ua = ( (( P4.x - P3.x ) * ( P1.y - P3.y )) - (( P4.y - P3.y ) * ( P1.x - P3.x )) )/
	( (( P4.y - P3.y ) * ( P2.x - P1.x )) - (( P4.x - P3.x ) * ( P2.y - P1.y )) );
	
	CGFloat ub = ( (( P2.x - P1.x ) * ( P1.y - P3.y )) - (( P2.y - P1.y ) * ( P1.x - P3.x )) ) /
	( (( P4.y - P3.y ) * ( P2.x - P1.x )) - (( P4.x - P3.x ) * ( P2.y - P1.y )) );
	
	// Check if the intersection lies between these two lines.
	//
	if ( ua >= 0 && ua <= 1.0 && ub >= 0 && ub <= 1.0 )
	{
		// They do!
		// So find the point of intersection.
		//

		thePoint->y = P1.y + ( ua * ( P2.y - P1.y ) );
		thePoint->x = P1.x + ( ua * ( P2.x - P1.x ) );
		
		return YES;
	}
	
	return NO;
}


- (BOOL) determineIntersectionPoints: (NSMutableArray*) lines intersectionPoints: (NSMutableArray*) thePoints
{
	// This needs exceptions.
	if ( lines == nil )
		return NO;
	if ( thePoints == nil)
		return NO;
	
	// Clear out any points in the array.
	int index;
	// NSLog(@"Points: %d\n", [ thePoints count ] );
	for ( index = [ thePoints count ]; index > 0; index-- )
	{
		[ thePoints removeObjectAtIndex:index-1];
	}
	
	for ( NSMutableArray* line in lines )
	{		
		NSPoint intersectionPoint;
		
		if ([ self determineIntersectionPoint: (GraphLine*) line intersectionPoint: &intersectionPoint ] == YES )
		{
			NSPoint newPoint;
			newPoint.x = intersectionPoint.x;
			newPoint.y = intersectionPoint.y;
			
			[ thePoints addObject: [NSValue valueWithPoint:newPoint] ];
		}
	}
	
	if ( [ thePoints count ] > 0 )
		return YES;
	else
		return NO;
}

- (CGFloat) gradient
{
	return (startPoint.y - endPoint.y)/(startPoint.x - endPoint.x);
}


@synthesize startPoint;
@synthesize endPoint;

@end
