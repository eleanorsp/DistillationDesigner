//
//  GraphView.h
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//
 
#import <Cocoa/Cocoa.h>
#import "Graph.h"

@interface GraphView : NSView 
{
    // NSMutableArray* graphsToView; later plot multiple graphs.±
    Graph* itsGraph;
    
    NSSize graphScale; // Manages the scaling for the graph within the view
    NSString* plotName;
	
	double zoomFactor;	
}

// Support Dragging of (Graph) Images from the View.
- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) isLocal;


@property (retain) Graph* itsGraph;
@property (retain) NSString* plotName;
@property NSSize graphScale;
@property double zoomFactor;



@end
