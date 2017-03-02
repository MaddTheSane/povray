//******************************************************************************
///
/// @file /macintosh/previewWindow/macintoshDisplay.mm
///
/// @todo   What's in here?
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
#import <Cocoa/Cocoa.h>
#import "macintoshDisplay.h"
#import "standardMethods.h"
#import "maincontroller.h"
#import "vfe.h"

namespace vfe
{
	vfeMacSession   *gVfeSession=NULL;

	macintoshDisplay::macintoshDisplay(unsigned int w, unsigned int h, GammaCurvePtr gamma, vfeSession *session, bool visible):
	vfeDisplay(w, h, gamma, session, visible)
	{
		@autoreleasepool
		{
			int xstart=0;
			int ystart=0;
			int xend=w;
			int yend=h;
			if ( session != NULL)
			{
				xstart=(int)session->GetFloatOption("Start_Column",1)-1;
				ystart=(int)session->GetFloatOption("Start_Row",1)-1;
				xend=(int)session->GetFloatOption("End_Column",1);
				yend=(int)session->GetFloatOption("End_Row",1);
			}
			if (xstart < 0)
				xstart=0;
			if ( ystart < 0)
				ystart = 0;

			remoteObject *rm=[[remoteObject alloc]initWithObjectsAndKeys:
												[NSNumber numberWithInt:w], @"w",
												[NSNumber numberWithInt:h], @"h",
												[NSNumber numberWithInt:xstart], @"xStart",
												[NSNumber numberWithInt:xend], @"xEnd",
												[NSNumber numberWithInt:ystart], @"yStart",
												[NSNumber numberWithInt:yend], @"yEnd",
												nil];

			[activeRenderPreview performSelectorOnMainThread:@selector(displayInit:)withObject: rm waitUntilDone:YES];
			[rm release];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::Close
	//---------------------------------------------------------------------
	void macintoshDisplay::Initialise(void)
	{

	}

	//---------------------------------------------------------------------
	// macintoshDisplay::Close
	//---------------------------------------------------------------------
	void macintoshDisplay::Close(void)
	{
		@autoreleasepool
		{
			[activeRenderPreview displayClose];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::DrawPixel
	//---------------------------------------------------------------------
	void macintoshDisplay::DrawPixel(unsigned int x, unsigned int y, const RGBA8& colour)
	{
		@autoreleasepool
		{
			[activeRenderPreview DrawPixel:x ypos:y RGBA8Color:colour];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::DrawRectangleFrame
	//---------------------------------------------------------------------
	void macintoshDisplay::DrawRectangleFrame (unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, const RGBA8& colour)
	{
		@autoreleasepool
		{
			[activeRenderPreview DrawRectangleFrame:x1 ypos: y1 xpos2: x2 ypos2: y2 RGBA8Color:colour];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::DrawFilledRectangle
	//---------------------------------------------------------------------
	void macintoshDisplay::DrawFilledRectangle(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, const RGBA8& colour)
	{
		@autoreleasepool
		{
			[activeRenderPreview DrawFilledRectangle:x1 ypos: y1 xpos2: x2 ypos2: y2 RGBA8Color:colour];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::DrawFilledRectangle
	//---------------------------------------------------------------------
	void macintoshDisplay::DrawPixelBlock(unsigned int x1, unsigned int y1, unsigned int x2, unsigned int y2, const RGBA8 *colour)
	{
		@autoreleasepool
		{
			[activeRenderPreview DrawPixelBlock:x1 ypos: y1 xpos2: x2 ypos2: y2 RGBA8Color:colour];
		}
	}

	//---------------------------------------------------------------------
	// macintoshDisplay::Clear
	//---------------------------------------------------------------------
	void macintoshDisplay::Clear(void)
	{
		//NSLog(@"clear");
	}

	//---------------------------------------------------------------------
	// ~macintoshDisplay(void)
	//---------------------------------------------------------------------
	macintoshDisplay::~macintoshDisplay(void)
	{
		//	NSLog(@"deleting");
	}

	//---------------------------------------------------------------------
	// macintoshDisplayCreator
	//---------------------------------------------------------------------
	vfeDisplay *macintoshDisplayCreator (unsigned int width, unsigned int height, GammaCurvePtr gamma, vfeSession *session, bool visible)
	{
		macintoshDisplay *p = new macintoshDisplay (width, height, gamma, session, false) ;
		return p;
	}
}