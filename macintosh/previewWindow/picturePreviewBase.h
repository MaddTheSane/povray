//******************************************************************************
///
/// @file /macintosh/previewWindow/picturePreviewBase.h
///
/// Base class for preview, used by picturePreview and materialpreview
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
#import <Cocoa/Cocoa.h>
#import <limits>
#import "syspovconfig.h"
#import "standardMethods.h"
#import "povray.h"
#import "display.h"

// check /platform/macintosh/syspovdebug.h
// for various switches to turn on debugging the preview window


#define updateTimerInterval 0.05
#define useImageForBackground
#define xResetMinValue FLT_MAX
#define xResetMaxValue FLT_MIN


@interface picturePreviewBase : NSView <NSWindowDelegate,NSToolbarDelegate>
{

	pthread_mutex_t mMinMaxLock;
	
	NSBitmapImageRep *mImageCache;
	NSImage *mImage;
	#ifdef useImageForBackground
		NSImage *mBackgroundImage;
	#endif
	NSUInteger mImageRowBytes;
	CGFloat mBackingScaleFactor;
	// effectieve pixel width and height of the image and also the image buffer
	NSInteger mImagePixelsWidth, mImagePixelsHeight;
	CGFloat mViewPixelsWidth, mViewPixelsHeight;

	NSInteger mPreviousPixelsWidth, mPreviousPixelsHight;

	NSInteger mFirstColumn, mLastColumn;
	NSInteger mFirstRow, mLastRow;

	NSTimer *mDisplayUpdater;
	CGFloat yMin;
	CGFloat yMax;
	CGFloat xMin;
	CGFloat xMax;

//	NSRect mUpdateRect;
	BOOL mOnlyDisplayPart;
	BOOL mCreatingPicturePreviewBase;
	NSString *mInputFileName;
	BOOL mEraseDisplayOnStart;
	NSImage *mBackgroundImagePattern;
}
-(void) vfeSessionStoppedRendering:(NSNotification *) notification;
-(void) windowDidChangeBackingPropertiesNotification:(NSNotification *) notification;

-(void) DrawPixelBlock: (unsigned int) x ypos:(unsigned int) y xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color: (const pov_frontend::Display::RGBA8*) colour;
-(void) DrawPixel: (unsigned int) x ypos:(unsigned int) y RGBA8Color:( const pov_frontend::Display::RGBA8&) colour;
-(void) DrawRectangleFrame:  (unsigned int) x ypos:(unsigned int) y xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour;

-(void) DrawFilledRectangle: (unsigned int) x ypos:(unsigned int) y xpos2:(unsigned int)x2 ypos2:(unsigned int) y2 RGBA8Color:( const pov_frontend::Display::RGBA8&) colour;

-(void) setInputFileName:(NSString *)fileName;
-(NSString*) inputFileName;
-(void) displayInit: (remoteObject*)remoteobject;
-(void) remoteMac_Parse_Error: (remoteObject*)remoteobject;
-(NSScreen*) screenHoldingLargestPartOfRect:(NSRect) rect;

- (void) adjustWindow;

- (void) displayClose;
- (void) forceDisplayUpdate: (NSTimer *)aTimer;
- (void) hideAndReleaseContent;

- (void)_createCache;
- (void)_destroyCache;
 

// overridden from a superclass:
- (id)		initWithFrame:(NSRect)frameRect;
- (void)	awakeFromNib;
- (void)	dealloc;
- (void)	drawRect:(NSRect) aRect;

@end
