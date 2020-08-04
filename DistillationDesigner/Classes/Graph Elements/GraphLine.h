//
//  GraphLine.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 09/03/2008.
//  Copyright 2008 Crumpets Farm. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GraphLine : NSObject 
{
	NSPoint startPoint;
	NSPoint endPoint;
}


- (id) initWithStartPoint: (NSPoint) start endPoint: (NSPoint) end;

//
// Intersection Methods for the Line and other lines.
//
- (BOOL) determineIntersectionPoint: (GraphLine* ) otherLine intersectionPoint: (NSPoint*) thePoint;
- (BOOL) determineIntersectionPoints: (NSMutableArray*) lines intersectionPoints: (NSMutableArray*) thePoints;

//
// Return the Gradient of the Line.
//
- (CGFloat) gradient;


@property NSPoint startPoint;
@property NSPoint endPoint;



@end
