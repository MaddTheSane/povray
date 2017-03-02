//******************************************************************************
///
/// @file /macintosh/previewWindow/picturePreviewBase.mm
///
/// Base class for preview, used by picturePreview and materialpreview
///
/// @copyright
/// @parblock
///
/// Unofficial Macintosh GUI port of POV-Ray 3.7
/// Copyright 2002-2016 Yvo Smellenbergh
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
/// Tracer ('POV-Ray') version 3.7, Copyright 1991-2016 Persistence of Vision
/// Raytracer Pty. Ltd.
///
/// ----------------------------------------------------------------------------
///
/// POV-Ray is based on the popular DKB raytracer version 2.12.
/// DKBTrace was originally written by David K. Buck.
/// DKBTrace Ver 2.0-2.12 were written by David K. Buck & Aaron A. Collins.
///
/// @endparblock
///
//******************************************************************************
#import <limits>
#import <algorithm>
#import "picturePreviewBase.h"
#import "sceneDocument.h"

#import "rendererGUIBridge.h"

extern BOOL gOnlyDisplayPart;
extern BOOL gDontErasePreveiw;

@class picturePreview;
pthread_mutex_t minMaxMutex = PTHREAD_MUTEX_INITIALIZER;

@implementation picturePreviewBase
//---------------------------------------------------------------------
// remoteMac_Parse_Error
//---------------------------------------------------------------------
-(void) remoteMac_Parse_Error: (remoteObject*)remoteobject
{
	//@autoreleasepool is set in fucntion Mac_Parse_Error() in renderGUIBridge.mm
	NSString *file=[[remoteobject dict]objectForKey:@"fileName"];
	if ( file == nil)
		return;
	SceneDocument *document=[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:file] display:YES error:nil];
	if ( document)
	{
			int n=[[[remoteobject dict]objectForKey:@"lineNo"] intValue];
			[document selectLine:(unsigned)n];
	}
		
}

//---------------------------------------------------------------------
// windowDidChangeBackingPropertiesNotification
//---------------------------------------------------------------------
-(void) windowDidChangeBackingPropertiesNotification:(NSNotification *) notification
{
	#ifdef debugPreview
		NSLog(@"Enter windowDidChangeBackingPropertiesNotification");
	#endif

  if ( mCreatingPicturePreviewBase == NO) // no scaling for material preview
  	{
		mBackingScaleFactor=1.0f;
		mViewPixelsWidth = (CGFloat)mImagePixelsWidth;
		mViewPixelsHeight = (CGFloat)mImagePixelsHeight;
		return;
	}
	NSWindow *windowSendingNotification = (NSWindow *)[notification object];
	NSWindow *ownWindow=[self window];

	if (windowSendingNotification == ownWindow	)
	{
		CGFloat newBackingScaleFactor = [windowSendingNotification backingScaleFactor];
		CGFloat oldBackingScaleFactor = [[[notification userInfo]
										  objectForKey:@"NSBackingPropertyOldScaleFactorKey"]
										 doubleValue];
		if ( newBackingScaleFactor != oldBackingScaleFactor)
		{
			mBackingScaleFactor = newBackingScaleFactor;
			mViewPixelsWidth = (CGFloat)mImagePixelsWidth/mBackingScaleFactor;
			mViewPixelsHeight = (CGFloat)mImagePixelsHeight/mBackingScaleFactor;
			
			#ifdef debugPreview
				NSLog(@"New mBackingScaleFactor: %f",mBackingScaleFactor);
			#endif
			if (mImage != nil)
			{
				#ifdef debugPreview
					NSLog(@"Setting mImage size to: width:%f height:%f",mViewPixelsWidth, mViewPixelsHeight);
				#endif
				[mImage setSize:NSMakeSize(mViewPixelsWidth, mViewPixelsHeight)];
			}
			[self setFrameSize:NSMakeSize(mViewPixelsWidth, mViewPixelsHeight)];
			[self adjustWindow];
		
		}
	}
	#ifdef debugPreview
		NSLog(@"exit windowDidChangeBackingPropertiesNotification");
	#endif
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
- (void)awakeFromNib
{
	#ifdef debugPreview
		NSLog(@"Enter awakeFromNib");
	#endif
	// set some starting values to avoid crashes

	mBackingScaleFactor=1.0f;
	mImagePixelsHeight=220;
	mImagePixelsWidth=220;
	mViewPixelsWidth = (CGFloat)mImagePixelsWidth;
	mViewPixelsHeight = (CGFloat)mImagePixelsHeight;
	mCreatingPicturePreviewBase=[ self isKindOfClass:[picturePreview class]];

	if ( mCreatingPicturePreviewBase == NO) // no scaling for material preview
		mBackingScaleFactor=1.0f;
	else if ( [self window] != nil && [[self window] respondsToSelector:@selector(backingScaleFactor)])
	 	mBackingScaleFactor = [[self window] backingScaleFactor];

	mViewPixelsWidth=(CGFloat)mImagePixelsWidth/mBackingScaleFactor;
	mViewPixelsHeight=(CGFloat)mImagePixelsHeight / mBackingScaleFactor;

	#ifdef debugPreview
		NSLog(@"New mBackingScaleFactor: %f",mBackingScaleFactor);
	#endif

	mImage=[[NSImage alloc]init];

	//[mImage setFlipped:YES];
	[[self window] setOpaque:YES];

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(vfeSessionStoppedRendering:)
	 name:@"vfeSessionStoppedRendering"
	 object:nil];
	 
	 //not available on 10.6
    if ([[self window] respondsToSelector:@selector(windowDidChangeBackingProperties:)])
	 {
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(windowDidChangeBackingPropertiesNotification:)
		 name:NSWindowDidChangeBackingPropertiesNotification
		 object:nil];
	 }
	mBackgroundImagePattern=[[NSImage imageNamed:@"background.png"]retain];
	#ifdef debugPreview
		NSLog(@"exit awakeFromNib");
	#endif
 }

//---------------------------------------------------------------------
// displayInit
//---------------------------------------------------------------------
-(void) displayInit: (remoteObject*)remoteobject
{
	@autoreleasepool
	{
	#ifdef debugPreview
		NSLog(@"enter display init");
	#endif
//	mCreatingPicturePreviewBase=[ self isKindOfClass:[picturePreview class]];

	BOOL returnValue=YES;
	mEraseDisplayOnStart=YES;
	NSString *newInputFileName=@"";
	if ( vfe::gVfeSession != NULL)
	{
		pov_base::UCS2String t=	vfe::gVfeSession->GetUCS2StringOption("Input_File_Name",POVMS_ASCIItoUCS2String(""));
		newInputFileName=[NSString stringWithUTF8String:POVMS_UCS2toASCIIString(t).c_str()];
	}



	mImagePixelsWidth=[[[remoteobject dict]objectForKey:@"w"]intValue];
	mImagePixelsHeight=[[[remoteobject dict]objectForKey:@"h"]intValue];
	mFirstColumn=[[[remoteobject dict]objectForKey:@"xStart"]intValue];
	mLastColumn=[[[remoteobject dict]objectForKey:@"xEnd"]intValue];
	mFirstRow=[[[remoteobject dict]objectForKey:@"yStart"]intValue];
	mLastRow=[[[remoteobject dict]objectForKey:@"yEnd"]intValue];
	#ifdef debugPreview
		NSLog(@"mPiwelsWidth: %ld mPixelsHeight: %ld mFirstColumn: %ld mLastColumn: %ld mFirstRow: %ld mLastRow: %ld", mImagePixelsWidth, mImagePixelsHeight, mFirstColumn, mLastColumn, mFirstRow, mLastRow);
	#endif

	// erase the preview window or not?
	if ( gDontErasePreveiw == YES && mCreatingPicturePreviewBase == YES)
		// doing the same scene as the one before?
		if ([newInputFileName isEqualToString:[self inputFileName]] == YES)
			// same with and hight as previous render?
			if ( mImagePixelsHeight == mPreviousPixelsHight && mImagePixelsWidth == mPreviousPixelsWidth)
					mEraseDisplayOnStart=NO; // don't erase when we start
	
	// store the current size of the picture in absolute pixels (no points )
	mPreviousPixelsHight=mImagePixelsHeight;
	mPreviousPixelsWidth=mImagePixelsWidth;
	
	[self setInputFileName:newInputFileName];

	// should fix this later
	mOnlyDisplayPart=gOnlyDisplayPart;
		
	if (mOnlyDisplayPart)
	{
		mImagePixelsWidth = mLastColumn-mFirstColumn;
		mImagePixelsHeight = mLastRow-mFirstRow;
	}

	[self displayClose];		// remove the NSTimer to redraw the screen if exists
	mViewPixelsWidth=(CGFloat)mImagePixelsWidth/mBackingScaleFactor;
	mViewPixelsHeight=(CGFloat)mImagePixelsHeight / mBackingScaleFactor;

	NSRect currentRect=[self frame];
	if ( mEraseDisplayOnStart == YES || currentRect.size.width!= mViewPixelsWidth || currentRect.size.height != mViewPixelsHeight)
	{
		[self _destroyCache];
		[self _createCache];
	}
	#ifdef debugPreview
		NSLog(@"Setting selfFrame to: width:%f height:%f",mViewPixelsWidth, mViewPixelsHeight);
	#endif

	[self setFrameSize:NSMakeSize(mViewPixelsWidth, mViewPixelsHeight)];

	// set variables for forceDisplayUpdate to know which area needs
	// redrawing 3 times a second.
	yMin=xMin=INT_MAX;
	yMax=xMax=- INT_MAX;

	mDisplayUpdater = [[NSTimer timerWithTimeInterval:updateTimerInterval
								target:self
   							selector:@selector(forceDisplayUpdate:)
   							userInfo:nil
   							repeats:YES] retain];
   [[NSRunLoop mainRunLoop] addTimer:mDisplayUpdater forMode:NSDefaultRunLoopMode];

	[self adjustWindow];
	[self setNeedsDisplay:YES];
	[remoteobject setReturnValue:returnValue];
	}
}

//---------------------------------------------------------------------
// adjustWindow
//---------------------------------------------------------------------
-(void) adjustWindow
{


}

//---------------------------------------------------------------------
// _createCache
//---------------------------------------------------------------------
- (void)_createCache
{
	@autoreleasepool
	{
#ifdef debugPreview
		NSLog(@"enter _createCache");
	#endif
    // create our image cache.
    // We'll use 8 bits per pixel ARGB interleaved for best performance

  
    // rowBytes needs to be divisible by 16 for best performance
    // (it should trigger Quartz to use altivec on G4 machines)
    // this will determine the smallest number of 16 byte chunks that
    // we can use, multiplied by four since we have one byte for
    // each of red, green, blue, and alpha
    mImageRowBytes = (((int)(mImagePixelsWidth / 16) + 1) * 16) * 4;

    mImageCache = [	[NSBitmapImageRep alloc]
							initWithBitmapDataPlanes:NULL
				            pixelsWide:mImagePixelsWidth
				            pixelsHigh:mImagePixelsHeight
				            bitsPerSample:8 
				            samplesPerPixel:4			/*4 for alpha*/ 
				            hasAlpha:YES 					/* yes for alpha*/
				            isPlanar:NO
				            colorSpaceName:@"NSCalibratedRGBColorSpace" //NSDeviceRGBColorSpace
				            bytesPerRow:0//mImageRowBytes
							bitsPerPixel:(8 * 4) ];
				
	#ifdef debugPreview
		NSLog(@"Setting mImage size to: width:%f height:%f",mViewPixelsWidth, mViewPixelsHeight);
	#endif
	[mImage setSize:NSMakeSize(mViewPixelsWidth, mViewPixelsHeight)];
	[mImage addRepresentation:mImageCache];

	#ifdef useImageForBackground
		#ifdef debugPreview
			NSLog(@"creating backgroundinmage");
		#endif
		mBackgroundImage = [[NSImage alloc]initWithSize:NSMakeSize(mViewPixelsWidth,mViewPixelsHeight)];
		[mBackgroundImage lockFocus];
		[[NSColor colorWithPatternImage:mBackgroundImagePattern]set];
		[NSBezierPath fillRect:NSMakeRect(0, 0,mViewPixelsWidth, mViewPixelsHeight)];
		[mBackgroundImage unlockFocus];
	#endif
	#ifdef debugPreview
		NSLog(@"exit _createCache");
	#endif
	}
}

	
//---------------------------------------------------------------------
// _destroyCache
//---------------------------------------------------------------------
- (void)_destroyCache
{
	#ifdef debugPreview
		NSLog(@"enter _destroyCache");
	#endif

    // clean up the caches.  We are zeroing out the pointers so that we
    // don't mistakenly try to use an invalid (freed) pointer.
	[mImage removeRepresentation:mImageCache];
	[mImageCache release];
	mImageCache = nil;

	#ifdef useImageForBackground
		#ifdef debugPreview
			NSLog(@"releasing backgroundinmage");
		#endif
		[mBackgroundImage release];
		mBackgroundImage=nil;
	#endif
	
	#ifdef debugPreview
		NSLog(@"exit _destroyCache");
	#endif
}
//---------------------------------------------------------------------
// dealloc																												*/
//---------------------------------------------------------------------
- (void)dealloc
{
	@autoreleasepool
	{

		   // make sure we release all the resources we allocated, so we don't leak memory
	[self _destroyCache];
	[mImage release];
	[mBackgroundImagePattern release];
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self setInputFileName:nil];
	#ifdef useImageForBackground
		#ifdef debugPreview
			NSLog(@"releasing in dealloc backgroundinmage");
		#endif
		[mBackgroundImage release];
		mBackgroundImage=nil;
	#endif
	[super dealloc];
}
}

//---------------------------------------------------------------------
// vfeSessionStoppedRendering
//---------------------------------------------------------------------
// notification
// notification send in RendererGUIBridge ProcessSession()
// Update the preview and remove the updateTimer
//---------------------------------------------------------------------
-(void) vfeSessionStoppedRendering:(NSNotification *) notification
{
	[self displayClose];
}

//---------------------------------------------------------------------
// drawRect
//---------------------------------------------------------------------
-(void) drawRect:(NSRect) aRect
{
//	@autoreleasepool in super
	{
#ifdef debugPreview
		NSLog(@"drawing image:%d",(mImage==NULL));
  #endif

	NSPoint toPoint;
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];
	if ( [self isFlipped]==YES)
		toPoint=NSMakePoint(0, mViewPixelsHeight);
	else
			toPoint=NSMakePoint(0,0);

	#ifdef useImageForBackground
		#ifdef debugPreview
			NSLog(@"copying backgroundinmage (from nsimage)");
		#endif

		[mBackgroundImage drawInRect:aRect fromRect:aRect operation:NSCompositeCopy fraction:1.0];
	#else
		#ifdef debugPreview
			NSLog(@"drawing background image");
		#endif
		NSRect rect=[self bounds];
		[[NSColor colorWithPatternImage:mBackgroundImagePattern]set];
		[NSBezierPath fillRect:rect];
	#endif

	[mImage drawInRect:aRect fromRect:aRect operation:NSCompositeSourceOver fraction:1.0];

//	[mImage drawAtPoint:toPoint fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}
}


//---------------------------------------------------------------------
// hideAndReleaseContent
// Just before a render, release memory for the content and hide the window
//---------------------------------------------------------------------
- (void) hideAndReleaseContent
{
	[[self window]close];
	[self _destroyCache];
}

//---------------------------------------------------------------------
// initWithFrame
//---------------------------------------------------------------------
- (id)initWithFrame:(NSRect)frameRect
{
    id ret = [super initWithFrame:frameRect];
    if (!ret) 
    	return nil;

    // create our image cache.
    // this isn't strictly necessary, since drawRect: will trigger creation when it needs
    // a cache if it finds that it doesn't have one.  By doing this now, we're soaking up
    // the cache creation time during app launch instead of during an operation that
    // might be timed and recorded by the user.
 //   [self _createCache];
    return ret;
}



//---------------------------------------------------------------------
// setInputFileName
//---------------------------------------------------------------------
-(void) setInputFileName:(NSString *)fileName
{
	[mInputFileName release];
	mInputFileName=fileName;
	[mInputFileName retain];
}


//---------------------------------------------------------------------
// inputFileName
//---------------------------------------------------------------------
-(NSString*) inputFileName
{
	return mInputFileName;
}

//---------------------------------------------------------------------
// screenHoldingLargestPartOfRect
//---------------------------------------------------------------------
// go through a list of all screens and return the screen
// which holds the largest part of NSRect rect.
// If none found, return the main screen
//---------------------------------------------------------------------
-(NSScreen*) screenHoldingLargestPartOfRect:(NSRect) rect
{
	//get an array of all the screens available
	NSArray *screensArray=[NSScreen screens];
	NSScreen *winScreen=nil;
	id screenObj=nil;
	float intersectionArea = 0.0f;
	float s = 0.0f;

	//find the screen where the origin of the window is on
	NSEnumerator *screenEnumerator=[screensArray objectEnumerator ];
	while ((screenObj=[screenEnumerator nextObject]))
	{
		if (NSIntersectsRect(rect, [screenObj visibleFrame]) == YES)
		{
			NSRect intersectionRect=NSIntersectionRect(rect, [screenObj visibleFrame]);
			s = NSWidth(intersectionRect) * NSHeight(intersectionRect);
			if ( s > intersectionArea)
			{
				intersectionArea=s;
				winScreen=screenObj;
			}
		}
	};

	// in case we did not find the screen the window origin is on
	// use the main window
	if ( winScreen ==nil)
		winScreen=[NSScreen mainScreen];
	
	
	return winScreen;
}

//---------------------------------------------------------------------
// displayClose																										*/
//---------------------------------------------------------------------
-(void) displayClose
{
	//@autoreleasepool is set in macintoshDisplay::Close
	if ( mDisplayUpdater != nil)
	{
		[mDisplayUpdater invalidate];
		[mDisplayUpdater release];
		mDisplayUpdater=nil;
	}
	// make sure the whole image is drawn
	[self setNeedsDisplay:YES];
}

//---------------------------------------------------------------------
// forceDisplayUpdate
//---------------------------------------------------------------------
-(void) forceDisplayUpdate: (NSTimer *)aTimer
{
	// is there anything to draw?
	pthread_mutex_lock(&minMaxMutex);
	if ( xMin != INT_MAX)
	{
	if ( [self isFlipped]==YES)
		mUpdateRect.origin.y=yMin/mBackingScaleFactor;
	else	// cocoa y-coordinates are from left bottom to left up
		mUpdateRect.origin.y=(mImagePixelsHeight-1-yMax)/mBackingScaleFactor; // data in imagebuffer is left top to left bottom
	mUpdateRect.origin.x=xMin/mBackingScaleFactor;
	mUpdateRect.size.width=((xMax-xMin)+mBackingScaleFactor)/mBackingScaleFactor;
	mUpdateRect.size.height=((yMax-yMin)+mBackingScaleFactor)/mBackingScaleFactor;

	[self setNeedsDisplayInRect:mUpdateRect];
	yMin=xMin=FLT_MAX;
	yMax=xMax= -FLT_MAX;
}
	pthread_mutex_unlock(&minMaxMutex);
}


//---------------------------------------------------------------------
// displayDrawPixelBlock*/
//---------------------------------------------------------------------
-(void) DrawPixelBlock: (unsigned int) x ypos:(unsigned int) y xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8*) colour
{

	//@autoreleasepool is set in macintoshDisplay::DrawPixelBlock

		if ( gApplicationAlreadyReceivedStopResquest == NO) // only draw if we are not aborting
		{
			pthread_mutex_lock(&minMaxMutex);
			y2=y2 < (mImagePixelsHeight-1) ? y2 : (mImagePixelsHeight-1);
			x2=x2 < (mImagePixelsWidth-1) ? x2 : (mImagePixelsWidth-1);

			unsigned char *bitmapDataPointer=[mImageCache bitmapData];
			NSInteger rowBytes=[mImageCache bytesPerRow];
			unsigned char *ptr2;
			for(unsigned int ypos = y, i = 0; ypos <= y2; ypos++)
			{
				ptr2 = bitmapDataPointer + (rowBytes*ypos);
				for(unsigned int xpos =x; xpos <= x2; xpos++, i++)
				{
					ptr2[(4*xpos)]=colour[i].red;
					ptr2[4*xpos+1]=colour[i].green;
					ptr2[4*xpos+2]=colour[i].blue;
					ptr2[4*xpos+3]=colour[i].alpha;
				}
			}
		}
		xMin=fmin(xMin,x);
		yMin=fmin(yMin,y);
		xMax=fmax(xMax,x2);
		yMax=fmax(yMax,y2);
		pthread_mutex_unlock(&minMaxMutex);

}

//---------------------------------------------------------------------
// DrawPixel*/
//---------------------------------------------------------------------
-(void) DrawPixel: (unsigned int) x ypos:(unsigned int) y RGBA8Color:( const pov_frontend::Display::RGBA8 &) colour
{
	//@autoreleasepool is set in macintoshDisplay::DrawPixel

		NSUInteger colourArray[4];
		if ( gApplicationAlreadyReceivedStopResquest == NO) // only draw if we are not aborting
		{
			pthread_mutex_lock(&minMaxMutex);

			colourArray[0]=(NSUInteger)((float)colour.red * (float)colour.alpha / 255.0f);
			colourArray[1]=(NSUInteger)((float)colour.green * (float)colour.alpha / 255.0f);
			colourArray[2]=(NSUInteger)((float)colour.blue * (float)colour.alpha / 255.0f);
			colourArray[3]=(NSUInteger)colour.alpha;
			[mImageCache setPixel:colourArray atX:x y:y];

			xMin=fmin(xMin,x);
			yMin=fmin(yMin,y);
			xMax=fmax(xMax,x+1);
			yMax=fmax(yMax,y+1);
			pthread_mutex_unlock(&minMaxMutex);
		}

}


//---------------------------------------------------------------------
// DrawRectangleFrame
//---------------------------------------------------------------------
-(void) DrawRectangleFrame: (unsigned int) x1 ypos:(unsigned int) y1 xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour
{
	//@autoreleasepool is set in macintoshDisplay::DrawRectangleFrame

		NSUInteger colourArray[4];
		if ( gApplicationAlreadyReceivedStopResquest == NO) // only draw if we are not aborting
		{
			pthread_mutex_lock(&minMaxMutex);

			colourArray[0]=(NSUInteger)((float)colour.red * (float)colour.alpha / 255.0f);
			colourArray[1]=(NSUInteger)((float)colour.green * (float)colour.alpha / 255.0f);
			colourArray[2]=(NSUInteger)((float)colour.blue * (float)colour.alpha / 255.0f);
			colourArray[3]=(NSUInteger)colour.alpha;

			for(unsigned int ypos = y1; ypos <= y2; ypos++)
			{
				[mImageCache setPixel:colourArray atX:x1 y:ypos];
				[mImageCache setPixel:colourArray atX:x2 y:ypos];
			}
			for(unsigned int xpos =x1; xpos <= x2; xpos++)
			{
				[mImageCache setPixel:colourArray atX:xpos y:y1];
				[mImageCache setPixel:colourArray atX:xpos y:y2];
			}
			xMin=fmin(xMin,x1);
			yMin=fmin(yMin,y1);
			xMax=fmax(xMax,x2);
			yMax=fmax(yMax,y2);
			pthread_mutex_unlock(&minMaxMutex);
		}
	}


//---------------------------------------------------------------------
// DrawFilledRectangle
//---------------------------------------------------------------------
-(void) DrawFilledRectangle: (unsigned int) x1 ypos:(unsigned int) y1 xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour
{
	//@autoreleasepool is set in macintoshDisplay::DrawFilledRectangle

		if ( gApplicationAlreadyReceivedStopResquest == NO) // only draw if we are not aborting
		{
			pthread_mutex_lock(&minMaxMutex);
			y2=y2 < (mImagePixelsHeight-1) ? y2 : (mImagePixelsHeight-1);
			x2=x2 < (mImagePixelsWidth-1) ? x2 : (mImagePixelsWidth-1);

			int copys=0;
			unsigned char *bitmapDataPointer=[mImageCache bitmapData];
			NSInteger rowBytes=[mImageCache bytesPerRow];
			unsigned char *ptr2;

			bitmapDataPointer+= rowBytes * y1;
			bitmapDataPointer+= x1 * 4l;
			ptr2=bitmapDataPointer;

			for(int cx=x1; cx <= x2; cx++)
			{
				*ptr2++=colour.red;			*ptr2++=colour.green;			*ptr2++=colour.blue;			*ptr2++=colour.alpha;
				copys++;
			}
	
			//first byte to draw
			ptr2=bitmapDataPointer;
			//second line
			ptr2+=rowBytes;
			for(int cy=y1+1; cy<=y2; cy++)
			{
				memcpy( ptr2,bitmapDataPointer,(long)copys*4l);
				ptr2+=rowBytes;
			}

			xMin=fmin(xMin,x1);
			yMin=fmin(yMin,y1);
			xMax=fmax(xMax,x2);
			yMax=fmax(yMax,y2);
			pthread_mutex_unlock(&minMaxMutex);
		}

}

@end

