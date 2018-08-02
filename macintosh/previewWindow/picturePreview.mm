//******************************************************************************
///
/// @file /macintosh/previewWindow/picturePreview.mm
///
/// preview window control
///
/// @copyright
/// @parblock
///
/// Unofficial Macintosh GUI port of POV-Ray 3.x.x
/// Copyright 2002-2017 Yvo Smellenbergh
///
/// This port of POV-Ray is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as
/// published by the Free Software Foundation, either version 3 of the
/// License, or (at your option) any later version.
///
/// This port of POV-Ray is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <http://www.gnu.org/licenses/>.
///
/// ----------------------------------------------------------------------------
///
/// This unofficial port of POV-Ray is based on the Persistence of Vision Ray
/// Tracer ('POV-Ray') version 3.x.x, Copyright 1991-2017 Persistence of Vision
/// Raytracer Pty. Ltd.
/// ----------------------------------------------------------------------------
///
/// POV-Ray is based on the popular DKB raytracer version 2.12.
/// DKBTrace was originally written by David K. Buck.
/// DKBTrace Ver 2.0-2.12 were written by David K. Buck & Aaron A. Collins.
///
/// @endparblock
///
//******************************************************************************
#import "MainController.h"
#import "PicturePreview.h"
#import "ToolTipAutomator.h"
#import "rendererGUIBridge.h"
#import <limits>
#import <algorithm>

// this must be the last file included
#import "syspovdebug.h"

#define makeFloat float alpha=( 255.0 - (float) a ) / 255.0;

@implementation picturePreview

//---------------------------------------------------------------------
// windowShouldClose
//---------------------------------------------------------------------
- (BOOL)windowShouldClose:(id)sender
{
	[[self window]orderOut:self];
	
	return NO;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
- (void)awakeFromNib
{
	gPicturePreview=self;
	[[self window]setDelegate:self];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"renderState"
		object:nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(newSelectionInPreferencesPanelSet:)
		name:@"newSelectionInPreferencesPanelSet"
		object:nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(pauseStatusChanged:)
		name:@"pauseStatusChanged"
		object:nil];

	[self initializeToolbar];

	[super awakeFromNib];
 }
//---------------------------------------------------------------------
// pauseStatusChanged
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) pauseStatusChanged:(NSNotification *) notification
{
	if (gIsPausing==YES)
	{
		[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarContinue"]];
	[mPauseToolbarItem setToolTip: dPvtbContinueTooltip];
	[mPauseToolbarItem setLabel: dPvtbContinueLabel];
	}
	else
	{
		[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarPause"]];
	[mPauseToolbarItem setToolTip: dPvtbPauseTooltip];
	[mPauseToolbarItem setLabel: dPvtbPauseLabel];
	}
}


//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{

	NSNumber *number=[[notification userInfo] objectForKey: @"renderStarted"];
	if ( number)
	{
		if ( [number boolValue] == NO)
		{
			mCutItemState=NSOnState;
			mStopItemState=NSOffState;
			mPauseItemState=NSOffState;
			[mCutToolbarItem setEnabled:YES];
			[mStopToolbarItem setEnabled:NO];
			[mPauseToolbarItem setEnabled:NO];
			[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarPause"]];
		}
		else
		{
			mCutItemState=NSOffState;
			mStopItemState=NSOnState;
			mPauseItemState=NSOnState;
			[mCutToolbarItem setEnabled:NO];
			[mStopToolbarItem setEnabled:YES];
			[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarPause"]];
			[mPauseToolbarItem setEnabled:YES];
		}
		
	}
}

//---------------------------------------------------------------------
// resetCutButton
//---------------------------------------------------------------------
-(void) resetCutButton
{
	mCanCut=NO;
	[scrollView setDocumentCursor:nil]; //[NSCursor crosshairCursor]];
	[[[self window] toolbar]setSelectedItemIdentifier:nil];
}

//---------------------------------------------------------------------
// cutButton
//---------------------------------------------------------------------
-(IBAction) cutButton:(id) sender
{
	[scrollView setDocumentCursor:[NSCursor crosshairCursor]];
	mCanCut=YES;
}

//---------------------------------------------------------------------
// stopButton
//---------------------------------------------------------------------
-(IBAction) stopButton:(id) sender
{
	[[renderDispatcher sharedInstance] abortThread];
}

//---------------------------------------------------------------------
// pauseButton
//---------------------------------------------------------------------
-(IBAction) pauseButton:(id) sender
{
	/*mach_port_t machTID = pthread_mach_thread_np(pthread_self());
	NSLog(@"current in preview: %x", machTID);*/
	[[renderDispatcher sharedInstance] pauseThread];
	if ( gIsPausing==YES)
		[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarContinue"]];
	else
		[mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarPause"]];
}

//---------------------------------------------------------------------
// acceptsFirstResponder
//---------------------------------------------------------------------
- (BOOL)acceptsFirstResponder
{
    return YES;
}

//---------------------------------------------------------------------
// keyDown
//---------------------------------------------------------------------
- (void)keyDown:(NSEvent *)event
{
	switch([event keyCode])
	{
		case 53: // esc
			if ( mCanCut)
				[self resetCutButton];
			break;
		default:
			[super keyDown:event];
	}

}
//---------------------------------------------------------------------
// newSelectionInPreviewwindowSet
//---------------------------------------------------------------------
// notification
// if selection is changed in the preferences panel
// inform preview
//---------------------------------------------------------------------
-(void) newSelectionInPreferencesPanelSet:(NSNotification *) notification
{
	
	NSNumber *start=[[notification userInfo] objectForKey: @"columnStart"];
	NSNumber *end=[[notification userInfo] objectForKey: @"columnEnd"];
	mSelectionRectInPixelFormat.origin.x=[start intValue]-1;
	mSelectionRectInPixelFormat.size.width=[end intValue]-mSelectionRectInPixelFormat.origin.x;

	end=[[notification userInfo] objectForKey: @"rowEnd"];
	start=[[notification userInfo] objectForKey: @"rowStart"];

	mSelectionRectInPixelFormat.origin.y=[start intValue]-1;
	mSelectionRectInPixelFormat.size.height=[end intValue]-mSelectionRectInPixelFormat.origin.y;

	if( mSelectionRectInPixelFormat.origin.x <0)
		mSelectionRectInPixelFormat.origin.x=0;
	if( mSelectionRectInPixelFormat.origin.y <0)
		mSelectionRectInPixelFormat.origin.y=0;

	if( mSelectionRectInPixelFormat.origin.x != 0 || mSelectionRectInPixelFormat.origin.y !=0)
		mHasSelectionRect=YES;
	else if( mSelectionRectInPixelFormat.size.width!= [[[notification userInfo] objectForKey: @"imageSizeX"] intValue] ||
			 mSelectionRectInPixelFormat.size.height !=  [[[notification userInfo] objectForKey: @"imageSizeY"] intValue])
		mHasSelectionRect=YES;
	else
		mHasSelectionRect=NO;
	//
	if ( mHasSelectionRect)
	{
		mSelectionRectInViewFormat=mSelectionRectInPixelFormat;

		if ( [self isFlipped]==NO)	// not flipped meand 0,0 starts at the bottom left. povray starts 0,0 top left
		{
			mSelectionRectInViewFormat.origin.y=[self frame].size.height - mSelectionRectInViewFormat.origin.y -mSelectionRectInViewFormat.size.height;
		}
	}
	[self setNeedsDisplay:YES];
}

//---------------------------------------------------------------------
// mouseDown
//---------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
	if ( mCanCut==NO)	// only if the button is on
		return;
		
    BOOL keepOn = YES;
    NSPoint mouseLoc,mouseStart;

    mouseStart = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	mSelectionRectInViewFormat=NSMakeRect(mouseStart.x, mouseStart.y,1.0,1.0);
	[self setNeedsDisplay:YES];
	#if defined (debugPreview ) && defined (debugPreviewMousedown)
			NSLog(@"In mousedown: mouseStart.x: %f mouseStart.y: %f",mouseStart.x, mouseStart.y);
	#endif
    while (keepOn )
    {
		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |  NSLeftMouseDraggedMask];
		mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		switch ([theEvent type]) 
		{
		    case NSLeftMouseDragged:
		    	if( [theEvent deltaX] || [theEvent deltaY])	//dit we move?
		    	{
	    			NSRect thisRect=NSMakeRect(mouseLoc.x, mouseLoc.y, 1.0,1.0);
	    			[self scrollRectToVisible:thisRect];
		    		if ( mouseLoc.x > mViewPixelsWidth)
		    			mouseLoc.x=mViewPixelsWidth;
		    		if ( mouseLoc.x <0)
		    			mouseLoc.x=0;

		    		if ( mouseLoc.y > mViewPixelsHeight)
		    			mouseLoc.y=mViewPixelsHeight;
		    		if ( mouseLoc.y <0)
		    			mouseLoc.y=0;
						[self setNeedsDisplayInRect:mSelectionRectInViewFormat];
		    		if ( mouseStart.x > mouseLoc.x)
		    		{
		    			mSelectionRectInViewFormat.origin.x = mouseLoc.x;
		    			mSelectionRectInViewFormat.size.width = mouseStart.x-mouseLoc.x;
		    		}
		    		else
		    		{
		    			mSelectionRectInViewFormat.origin.x = mouseStart.x;
		    			mSelectionRectInViewFormat.size.width = mouseLoc.x-mouseStart.x;
		    		}
		    		//y
		    		if ( mouseLoc.y > mouseStart.y)
		    		{
		    			mSelectionRectInViewFormat.origin.y = mouseStart.y;
		    			mSelectionRectInViewFormat.size.height = mouseLoc.y-mouseStart.y;
		    		}
		    		else
		    		{
		    			mSelectionRectInViewFormat.origin.y = mouseLoc.y;
		    			mSelectionRectInViewFormat.size.height = mouseStart.y-mouseLoc.y;
		    		}
		    		mHasSelectionRect=YES;
						[self setNeedsDisplayInRect:mSelectionRectInViewFormat];
		    	}	
	        break;
			case NSLeftMouseUp:
				keepOn = NO;
				break;
			default:
				// Ignore any other kind of event. 
				break;
		}
	};
	if (mHasSelectionRect==YES)
	{
		mSelectionRectInPixelFormat=mSelectionRectInViewFormat;
		
		if ( mOnlyDisplayPart ==YES)
		{
			mSelectionRectInPixelFormat.origin.x += mFirstColumn;
			mSelectionRectInPixelFormat.origin.y += mFirstRow;
			
		}
		
		if ( [self isFlipped]==NO)	// not flipped then 0,0 starts at the bottom left. povray starts 0,0 top left
		{
			mSelectionRectInPixelFormat.origin.y += mSelectionRectInPixelFormat.size.height;
			if ( mSelectionRectInPixelFormat.origin.y > mImagePixelsHeight)
				mSelectionRectInPixelFormat.origin.y = mImagePixelsHeight;
			mSelectionRectInPixelFormat.origin.y = mImagePixelsHeight-mSelectionRectInPixelFormat.origin.y;
		}
		#if defined (debugPreview ) && defined (debugPreviewMousedown)
			NSLog(@"selectionrect: x: %f y: %f, width:%f, height: %f",mSelectionRectInPixelFormat.origin.x+1, mSelectionRectInPixelFormat.origin.y+1, mSelectionRectInPixelFormat.origin.x + mSelectionRectInPixelFormat.size.width, mSelectionRectInPixelFormat.origin.y + mSelectionRectInPixelFormat.size.height);
		#endif
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool:YES], @"yStartsAtTop",
			[NSNumber numberWithInt: mSelectionRectInPixelFormat.origin.x+1] ,	@"columnStart",
			[NSNumber numberWithInt: mSelectionRectInPixelFormat.origin.x + mSelectionRectInPixelFormat.size.width] ,	@"columnEnd",
			[NSNumber numberWithInt: mSelectionRectInPixelFormat.origin.y+1] ,	@"rowStart",
			[NSNumber numberWithInt: mSelectionRectInPixelFormat.origin.y + mSelectionRectInPixelFormat.size.height] ,	@"rowEnd",
			nil];

		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"newSelectionInPreviewwindowSet" 
			object:self 
			userInfo:dict];
		
		[self resetCutButton];
	}
	return;
}

//---------------------------------------------------------------------
// drawRect
//---------------------------------------------------------------------
-(void) drawRect:(NSRect) aRect
{
	@autoreleasepool
	{
		[NSGraphicsContext saveGraphicsState];

		//NSLog(@"%@ ",NSStringFromRect(aRect));
		[super drawRect: aRect];
	
		//	NSFrameRect(aRect);
		// don't draw the selection rect if the size of the window
		// is the size of the selection
		if ( mHasSelectionRect==YES && mOnlyDisplayPart==NO)
		{
			[[NSColor blackColor]set];
			NSFrameRect(mSelectionRectInViewFormat);
		}
		[NSGraphicsContext restoreGraphicsState];
	}
}

//---------------------------------------------------------------------
// dealloc																												*/
//---------------------------------------------------------------------
- (void)dealloc
{
	[ mCutToolbarItem release];
	[ mStopToolbarItem release];
	[ mPauseToolbarItem release];
   [super dealloc];
}
 
//---------------------------------------------------------------------
// displayDrawPixelBlock*/
//---------------------------------------------------------------------
-(void) DrawPixelBlock: (unsigned int) x ypos:(unsigned int) y xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8*) colour
{
	if (mOnlyDisplayPart)
	{
		x-=mFirstColumn;
		x2-=mFirstColumn;
		y-=mFirstRow;
		y2-=mFirstRow;
	}

	[super DrawPixelBlock:x ypos: y xpos2: x2 ypos2: y2 RGBA8Color:colour];
}
//---------------------------------------------------------------------
// DrawPixel*/
//---------------------------------------------------------------------
-(void) DrawPixel: (unsigned int) x ypos:(unsigned int) y RGBA8Color:( const pov_frontend::Display::RGBA8 &) colour
{
	if (mOnlyDisplayPart)
	{
		x-=mFirstColumn;
		y-=mFirstRow;
	}

	[super DrawPixel:x ypos:y RGBA8Color:colour];
}

//---------------------------------------------------------------------
// DrawRectangleFrame
//---------------------------------------------------------------------
-(void) DrawRectangleFrame: (unsigned int) x1 ypos:(unsigned int) y1 xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour
{
	if (mOnlyDisplayPart)
	{
		x1-=mFirstColumn;
		x2-=mFirstColumn;
		y1-=mFirstRow;
		y2-=mFirstRow;
	}
	[super DrawRectangleFrame:x1 ypos:y1 xpos2:x2 ypos2:y2 RGBA8Color:colour];
}

//---------------------------------------------------------------------
// DrawFilledRectangle
//---------------------------------------------------------------------
-(void) DrawFilledRectangle: (unsigned int) x1 ypos:(unsigned int) y1 xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour
{
	if (mOnlyDisplayPart)
	{
		x1-=mFirstColumn;
		x2-=mFirstColumn;
		y1-=mFirstRow;
		y2-=mFirstRow;
	}
	[super DrawFilledRectangle:x1 ypos:y1 xpos2:x2 ypos2:y2 RGBA8Color:colour];
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
  	if ( [aMenuItem action] == @selector(saveDocument:) )
			return NO;
	return YES;
}

//---------------------------------------------------------------------
// saveDocument:
//---------------------------------------------------------------------
-(IBAction) saveDocument:(id)sender
{
}

//---------------------------------------------------------------------
// showWindow
//---------------------------------------------------------------------
-(void) showWindow:(id) sender shouldBecomeFront: (bool) makeFront
{
	if ( [[self window]isVisible]==NO)
	{
		if (makeFront == YES)
		{
			[[self window] makeKeyAndOrderFront:sender ];	// display and make front
		}
		else
		{
			[[self window] orderFront:sender];	// display but keep in same level
		}
	}
}

//---------------------------------------------------------------------
// adjustWindow
//---------------------------------------------------------------------
-(void) adjustWindow
{
	#if defined (debugPreview ) && defined (debugPreviewAdjustWindow)
		NSLog(@"enter AdjustWindow");
	#endif

	NSWindow *win=[self window];
	NSRect oldWindowFrame=[win frame];
	NSScreen *screenToUse=[self screenHoldingLargestPartOfRect:oldWindowFrame];
	NSString *outputName=@"";
	if ( vfe::gVfeSession != NULL)
	{
		pov_base::UCS2String t=		vfe::gVfeSession->GetUCS2StringOption("Output_File_Name",POVMS_ASCIItoUCS2String(""));
		outputName=[NSString stringWithUTF8String:POVMS_UCS2toASCIIString(t).c_str()];
		outputName=[outputName lastPathComponent];
		if ( !(vfe::gVfeSession->GetBoolOption("Output_To_File",false) )) 
		{
			outputName=[outputName stringByDeletingPathExtension];
		outputName=[outputName stringByAppendingString:@" (Not saving)"];
		}
	}
	[[self window] setTitle:outputName];
	[[MainController sharedInstance] previewWindowChangedName:outputName];
	
	// set the new frame size
	// which will also create the buffer
	// and set the color to white

	//set new max size
	NSSize displaySize=[mImage size];
	NSSize frameSize;
	if ([NSScrollView respondsToSelector:@selector(frameSizeForContentSize:horizontalScrollerClass:verticalScrollerClass:borderType:controlSize:scrollerStyle:)])
	{

    Class horizScrollerClass = [[scrollView horizontalScroller] class];
    Class vertScrollerClass = [[scrollView verticalScroller] class];
    
    frameSize = [NSScrollView frameSizeForContentSize:displaySize
									horizontalScrollerClass:horizScrollerClass
									verticalScrollerClass:vertScrollerClass
									borderType:[scrollView borderType]
									controlSize:[[scrollView verticalScroller]controlSize]
									scrollerStyle:[scrollView scrollerStyle]
								 ];

	}
	else
	{
	 frameSize= [NSScrollView frameSizeForContentSize: displaySize
								hasHorizontalScroller:YES
								hasVerticalScroller:YES
								borderType:[[self enclosingScrollView] borderType]
							];
							}

	[win setContentMaxSize: frameSize];

	//follow same minimum as in displayInit
	[win setContentMinSize: NSMakeSize(100,100)];
	[win setContentSize: frameSize];
	//scroll to the top of the image
	[self scrollPoint: NSMakePoint (0,0)];
	
	NSRect newWindowFrame=[win frame];
	NSRect screenRect=[screenToUse visibleFrame];
	// make sure the right side of the preview window
	// remains on the screen by shifting it to the left if needed
	#if defined (debugPreview ) && defined (debugPreviewAdjustWindow)
		NSLog(@"\n");
		NSLog(@"Displaysize: %f, %f\n",displaySize.width, displaySize.height);
		NSLog(@"screen         : x:%f, y:%f, w:%f h:%f\n", screenRect.origin.x,screenRect.origin.y, screenRect.size.width, screenRect.size.height);
		NSLog(@"old frame      : x:%f, y:%f, w:%f h:%f\n", oldWindowFrame.origin.x,oldWindowFrame.origin.y, oldWindowFrame.size.width, oldWindowFrame.size.height);
		NSLog(@"new framebefore: x:%f, y:%f, w:%f h:%f\n", newWindowFrame.origin.x,newWindowFrame.origin.y, newWindowFrame.size.width, newWindowFrame.size.height);
	#endif
	if ( NSEqualRects(newWindowFrame, oldWindowFrame)==NO)
	{
		if (NSWidth(newWindowFrame) >  NSWidth(screenRect))
			newWindowFrame.size.width = NSWidth(screenRect);
		
		if ( (fabs(newWindowFrame.origin.x )+ NSWidth(newWindowFrame)) > NSWidth(screenRect))
		{
			newWindowFrame.origin.x = screenRect.origin.x;
		}	
		newWindowFrame.origin.y=oldWindowFrame.origin.y;
		}
	
		// display the window but keep in same order
		[self showWindow:self shouldBecomeFront:NO];

		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		if ([[defaults objectForKey:@"AlwaysPutPreviewwindowInFrontButton"]intValue] == NSOnState)
		{
			if ( vfe::gVfeSession->RenderingAnimation() == false)	// no animation and option set
				[[self window] makeKeyAndOrderFront:self];	// move to front and make key window
			else if ([[defaults objectForKey:@"OnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton"]intValue] == NSOffState)
				[[self window] makeKeyAndOrderFront:self];	// move to front and make key window
			else if (vfe::gVfeSession->GetCurrentFrame()==1)
				[[self window] makeKeyAndOrderFront:self];	// move to front and make key window

		}
	[win setFrame: newWindowFrame display:NO animate:YES ];

	#if defined (debugPreview ) && defined (debugPreviewAdjustWindow)
		NSLog(@"new frame      : x:%f, y:%f, w:%f f:%f\n", newWindowFrame.origin.x,newWindowFrame.origin.y, newWindowFrame.size.width, newWindowFrame.size.height);
		NSLog(@"exit AdjustWindow");
	#endif

}
#pragma mark -
#pragma mark  Toolbar

//---------------------------------------------------------------------
// validateToolbarItem
//---------------------------------------------------------------------
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{ 
	BOOL ret = YES;
	if ([[toolbarItem itemIdentifier] isEqual:PvtbStopItemIdentifier]) 
	{
		ret=mStopItemState;//[[renderDispatcher sharedInstance] canAbortRender];
	}
	else if ([[toolbarItem itemIdentifier] isEqual:PvtbPauseContinueItemIdentifier])
	{
		ret=mPauseItemState; //[[renderDispatcher sharedInstance] canPauseRender];
	}
	else if ([[toolbarItem itemIdentifier] isEqual:PvtbCutItemIdentifier])
	{
		ret=mCutItemState;//[[renderDispatcher sharedInstance] canStartNewRender];
	}

	return ret;
}

//---------------------------------------------------------------------
// toolbar
//---------------------------------------------------------------------
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar   itemForItemIdentifier:(NSString *)itemIdent
										 willBeInsertedIntoToolbar:(BOOL)willBeInserted
{

		
    if([itemIdent isEqual:PvtbStopItemIdentifier])
		{
			return mStopToolbarItem;
    }
		else if([itemIdent isEqual:PvtbPauseContinueItemIdentifier])
		{
			return mPauseToolbarItem;
    }
		else if([itemIdent isEqual:PvtbCutItemIdentifier])
		{
			return mCutToolbarItem;
		}
   	return nil;

}

//---------------------------------------------------------------------
// toolbarDefaultItemIdentifiers
//---------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
    return [NSArray arrayWithObjects:
        PvtbStopItemIdentifier,
        PvtbPauseContinueItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        PvtbCutItemIdentifier,
        nil];
}

//---------------------------------------------------------------------
// toolbarAllowedItemIdentifiers
//---------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
    return [NSArray arrayWithObjects:
        PvtbStopItemIdentifier,
        PvtbPauseContinueItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        PvtbCutItemIdentifier,
		 nil];
}
- (NSArray *)toolbarSelectableItemIdentifiers: (NSToolbar *)toolbar;
{
    // Optional delegate method: Returns the identifiers of the subset of
    // toolbar items that are selectable. In our case, all of them
    return [NSArray arrayWithObjects:PvtbCutItemIdentifier,nil];
}

//---------------------------------------------------------------------
// toolbarWillAddItem
//---------------------------------------------------------------------
- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
/*    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
    if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier]) {
        [addedItem setToolTip: @"Print Document"];
        [addedItem setTarget:self];
    }
*/
}

//---------------------------------------------------------------------
// toolbarDidRemoveItem
//---------------------------------------------------------------------
- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
// handle removal of items.  We have an item that could be a target, so that needs to be reset
 /*   NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];
    if (removedItem == angleItem) {
        [angleField setTarget:nil];
    }*/
}


//---------------------------------------------------------------------
// initializeToolbar
//---------------------------------------------------------------------
- (void)initializeToolbar
{
	mCutToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PvtbCutItemIdentifier];
	[mCutToolbarItem setLabel: dPvtbCutLabel];
	[mCutToolbarItem setPaletteLabel: dPvtbCutPaletteLabel];
	[mCutToolbarItem setToolTip:dPvtbCutTooltip];
  [mCutToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarCut"]];
	[mCutToolbarItem setTarget: self];
	[mCutToolbarItem setAction: @selector(cutButton:)];

	mStopToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PvtbStopItemIdentifier];
	[mStopToolbarItem setLabel: dPvtbStopLabel];
	[mStopToolbarItem setPaletteLabel: dPvtbStopLabelPaletteLabel];
	[mStopToolbarItem setToolTip:dPvtbStopLabelTooltipLabel];
  [mStopToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarStop"]];
	[mStopToolbarItem setTarget: self];
	[mStopToolbarItem setAction: @selector(stopButton:)];

	mPauseToolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:PvtbPauseContinueItemIdentifier];
	[mPauseToolbarItem setLabel: dPvtbPauseLabel];
	[mPauseToolbarItem setPaletteLabel: dPvtbPauseContinuePaletteLabel];
	[mPauseToolbarItem setToolTip:dPvtbPauseTooltip];
  [mPauseToolbarItem setImage:[NSImage imageNamed: @"PreviewToolbarPause"]];
	[mPauseToolbarItem setTarget: self];
	[mPauseToolbarItem setAction: @selector(pauseButton:)];
	mCutItemState = NSOffState;
	mStopItemState = NSOffState;
	mPauseItemState = NSOffState;
	
   NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:PvtbIdentifier];
   [toolbar setAllowsUserCustomization:YES];
   [toolbar setAutosavesConfiguration:YES];
   [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
   [toolbar setDelegate:self];
   [[self window] setToolbar:toolbar];
   [toolbar release];
}

@end

@implementation pictureScrollView

//---------------------------------------------------------------------
// awakeFromNib (pictureScrollView)
//---------------------------------------------------------------------
-(void) awakeFromNib
{


    [self setDocumentView:subView];
}







@end



