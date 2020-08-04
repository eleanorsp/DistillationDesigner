//
 //  GraphView.m
//  DistillationDesigner
//
//  Created by Eleanor Spenceley on 21/09/2004.
//  Copyright 2004 Crumpets Farm. All rights reserved.
//
 
#import "GraphView.h"

#import <Cocoa/Cocoa.h>

@interface GraphView (Private)

CGRect convertToCGRect(NSRect inRect);

@end

@implementation GraphView

- (id) initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    itsGraph = nil;
	graphScale = frameRect.size;
	zoomFactor = 100.0;
	
	// [self registerForDraggedTypes:[NSImage imagePasteboardTypes]];

    return self;
}


- (void) drawRect:(NSRect)rect
{
    CGContextRef gc = [[NSGraphicsContext currentContext] graphicsPort];
    
    CGContextSetGrayFillColor(gc, 1.0, 1.0);
    CGContextFillRect(gc, convertToCGRect(rect));
    
	NSLog( @"Rect origin x: %f y: %f size: height %f width %f", rect.origin.x, rect.origin.y, rect.size.height, rect.size.width );
    [ itsGraph drawGraph: gc ];
	
    return;
}

// A convenience function to get a CGRect from an NSRect. You can also use the
// *(CGRect *)&nsRect sleight of hand, but this way is a bit clearer.
CGRect convertToCGRect(NSRect inRect)
{
    return CGRectMake(inRect.origin.x, inRect.origin.y, inRect.size.width, inRect.size.height);
}

/*
- (void)writeDataToPasteboard:(NSPasteboard *)pasteboard
{
	// declare types
	[pasteboard declareTypes: [NSArray arrayWithObjects:NSStringPboardType, NSPDFPboardType, nil] owner:self];
	
	//copy string to the pasteboard
	[pasteboard setString:@"graph" forType:NSStringPboardType];
	
	//copy pdf to the pasteboard
	NSRect r = [self bounds];
	NSData *pdf = [self dataWithPDFInsideRect:r];
	[pasteboard setData:pdf forType:NSPDFPboardType];
	
	return;
}
*/

//
// Support Dragging of (Graph) Images from the View.
//
- (NSDragOperation) draggingSourceOperationMaskForLocal: (BOOL) isLocal
{
	return NSDragOperationCopy;
}


-(void)mouseDragged:(NSEvent *)event
{
	NSRect imageBounds;
	NSPasteboard* dragPasteboard;
	NSImage* anImage;
	NSImage* tempImage;
	NSPoint point;
	NSSize size = [ self bounds ].size; 
	
	anImage = [[ NSImage alloc ] initWithSize: size ];
	tempImage = [[ NSImage alloc ] initWithSize: size ];
	
	// Create a rect in which we will draw the graph.
	//
	imageBounds.origin = NSMakePoint(0, 0); 
	imageBounds.size = size;
	
	// Draw the graph on the image.
	[ anImage lockFocus ];
	[ self drawRect: imageBounds ];
	[ anImage unlockFocus ];
	
	// [ anImage dissolveToPoint: NSZeroPoint fraction: .5]; // Reduce it by 50%
	[ anImage setScalesWhenResized:YES];//we want the image to resize
	NSSize smallSize;
	smallSize.width = 200;
	smallSize.height = 200;
	[ anImage setSize: smallSize ];
  //  [ anImage setSize:[self bounds].size];//change to the size we are displaying
	
	[ tempImage lockFocus ];
	[ anImage dissolveToPoint: NSZeroPoint fraction: .5];
	[ tempImage unlockFocus ];
	
	// Get the location of the drag event.
	point = [ self convertPoint: [event locationInWindow ] fromView:nil ];
	// Drag from the centre of the image.
	point.x = point.x - 30;
	point.y = point.y - 30;
	
	// Get the pasteboard.
	//
	dragPasteboard = [ NSPasteboard pasteboardWithName:NSDragPboard ];
	
	// Put the image onto the pasteboard.
	//
	//add the image types we can send the data as(we'll send the actual data when it's requested)
    [dragPasteboard declareTypes:[NSArray arrayWithObject: NSTIFFPboardType] owner:self];
    [dragPasteboard declareTypes:[NSArray arrayWithObject: NSPDFPboardType] owner:self];

	// [dragPasteboard addTypes:[NSArray arrayWithObject:NSPDFPboardType] owner:self];
	[dragPasteboard addTypes:[NSArray arrayWithObject:NSFilesPromisePboardType] owner:self];

	// NSData* pdfData = [self dataWithPDFInsideRect:[self bounds]];
	// [ self writeDataToPasteboard: dragPasteboard ];
	
	// Start the Drag
	[ self dragImage: tempImage 
				  at: point 
			  offset: NSMakeSize(0,0) 
			   event:event 
		  pasteboard:dragPasteboard 
			  source: self 
		   slideBack: YES ];
	
	return;
}

- (void)magnifyWithEvent:(NSEvent *)event 
{
	NSLog( @"Magnification value is %f", [event magnification] );
    NSSize newSize;
    newSize.height = self.frame.size.height * ([event magnification] + 1.0);
    newSize.width = self.frame.size.width * ([event magnification] + 1.0);
    [self setFrameSize:newSize];
	
	// Reapply the bounds.
	[ self setBoundsSize: newSize ];
	
	NSRect newRect;
	newRect.size = newSize;
	itsGraph.plotArea = newRect;
	[ self setNeedsDisplay:TRUE ];	
	
	return;
}

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    /*------------------------------------------------------
	 method called by pasteboard to support promised 
	 drag types.
	 --------------------------------------------------------*/
    //sender has accepted the drag and now we need to send the data for the type we promised
	if([type compare: NSPDFPboardType]==NSOrderedSame)
	{
		[sender setData:[self dataWithPDFInsideRect:[self bounds]] forType:NSPDFPboardType];
    }
	else if([type compare: NSTIFFPboardType]==NSOrderedSame)
	{
		NSRect imageBounds;
		NSSize size = [ self bounds ].size; 

		//set data for TIFF type on the pasteboard as requested
		NSImage* anImage = [[ NSImage alloc ] initWithSize: size ];
		
		// Create a rect in which we will draw the graph.
		//
		imageBounds.origin = NSMakePoint(0, 0); 
		imageBounds.size = size;
		
		// Draw the graph on the image.
		[ anImage lockFocus ];
		[ self drawRect: imageBounds ];
		[ anImage unlockFocus ];
		
		[sender setData:[anImage TIFFRepresentation] forType:NSTIFFPboardType];
    }
	else if([type compare:NSFilesPromisePboardType]==NSOrderedSame)
	{
		[sender setPropertyList:[NSArray arrayWithObject:@"pdf"] forType:NSFilesPromisePboardType];
	}
	
	return;
}

// - gets called by the drag and drop destination if it was an accepted type
// - good place to write the file since it's a quick operation
//-----------------------------------------------------------------------------
- (NSArray *)namesOfPromisedFilesDroppedAtDestination:(NSURL *)dropDestination
{
	NSFileManager	 *fm;
	NSString	 *basePath;
	NSString	 *path;
	int	 i;
	unsigned int	modFlags;
	
	// again check for control key to see if don't draw background
	modFlags = [[NSApp currentEvent] modifierFlags];
	// if (modFlags & NSShiftKeyMask) drawBackground = false;
	
	// determine a valid name for the file to write to
	fm = [NSFileManager defaultManager];
	basePath = [[dropDestination path] stringByAppendingPathComponent:[[self window] title]];
	path = [basePath stringByAppendingPathExtension:@"pdf"];
	i = 1;
	while ([fm fileExistsAtPath:path])
	{
		path = [[basePath stringByAppendingFormat:@"-%i", i++] stringByAppendingPathExtension:@"pdf"];
	}
	NSRect rect = [ self frame ];
	rect.origin.x = 0;
	rect.origin.y = 0;
	
	[ [self dataWithPDFInsideRect:rect] writeToFile:path atomically:YES];
	
	return [NSArray arrayWithObject:[path lastPathComponent]];
}



#pragma mark PROPERTIES 
//
@synthesize plotName;
@synthesize itsGraph;
@synthesize graphScale;
@synthesize zoomFactor;


@end
