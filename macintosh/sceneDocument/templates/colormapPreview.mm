//******************************************************************************
///
/// @file <File Name>
///
/// @todo   What's in here?
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
#import "mapPreview.h"
#import "colormap.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation colormapPreview

//---------------------------------------------------------------------
// drawRect
//---------------------------------------------------------------------
- (void)drawRect:(NSRect)aRect
{
	colormap *cMap=(colormap*)mMap;
	NSRect bounds=[self bounds];
	// turn aliassing off otherwize the result is not nice :-)
	[[NSGraphicsContext currentContext] setShouldAntialias:NO];

	//erase preview
	[[NSColor whiteColor]set];
	NSRectFill([self bounds]);

	if ( cMap==nil)	//safety
		return;
	
	// draw a gray frame 
	[[NSColor controlShadowColor]set];
	NSFrameRect(bounds);
	
	//preview is inside drawed frame
 	bounds=NSInsetRect(bounds,1,1);
	float pixels=bounds.size.width;	// number of pixels for whole frame;
		
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];
	for (int element=0; element < [cMap count]-1; element++)
	{

		float startPixel=[cMap floatAtRow:element atColumn:cColormapLocationIndex] *pixels;
		float endPixel=[cMap floatAtRow:element+1 atColumn:cColormapLocationIndex]*pixels;

		NSColor *startColor=[cMap objectAtRow:element atColumn:cColormapColorIndex];
		NSColor *endColor=[cMap objectAtRow:element+1 atColumn:cColormapColorIndex];
		float colorSteps=(float)((int)(endPixel-startPixel));
		float redStart=[startColor redComponent];
		float greenStart=[startColor greenComponent];
		float blueStart=[startColor blueComponent];
		float redStep=([endColor redComponent]-redStart)/colorSteps;	
		float greenStep=([endColor greenComponent]-greenStart)/colorSteps;	
		float blueStep=([endColor blueComponent]-blueStart)/colorSteps;	

		for (int steps=1+startPixel; steps<=endPixel; steps++)
		{
			if ( [cMap buttonState:cGrayColorButton])
			{		
				float grayValue=redStart * 0.297 +	greenStart *0.589 + blueStart* 0.114;
				[[NSColor colorWithCalibratedRed:grayValue green:grayValue	 blue:grayValue	alpha:1.0]set];
			}
			else		
				[[NSColor colorWithCalibratedRed:redStart green:greenStart	 blue:blueStart	alpha:1.0]setStroke];

			redStart+=redStep;
			greenStart+=greenStep;
			blueStart+=blueStep;
			[b moveToPoint: NSMakePoint(steps,bounds.origin.y)];
			[b lineToPoint: NSMakePoint(steps,bounds.size.height)];
			[b stroke];
			[b removeAllPoints];
		}
	}
}

@end


