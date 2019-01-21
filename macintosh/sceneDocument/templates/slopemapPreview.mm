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
#import "slopeMap.h"

// this must be the last file included
#import "syspovdebug.h"

#define kMarginWidth 40.0
@implementation slopemapPreview

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	if ( mPointList)
	{
		delete mPointList;
		mPointList=0l;
	}	
	if ( mSlopePointList)
	{
		delete mSlopePointList;
		mSlopePointList=0l;
	}	
	[super dealloc];
}

//---------------------------------------------------------------------
// drawSelectedPoint
//---------------------------------------------------------------------
-(void)drawSelectedPoint
{
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];

	if ( [mMap selectedRow]!= dNoRowSelected)
	{
		if ( mSlopeFound!=-1 && 	 [mMap buttonState:cSlopeButton]==NSOnState)
		{
			[[NSColor magentaColor]set];
			mDrawFrame=NSInsetRect(mSlopePointList[mSlopeFound],5,5);
			[b moveToPoint: NSMakePoint(mDrawFrame.origin.x,mRasterFrame.origin.y-40)];
			[b lineToPoint:NSMakePoint(mDrawFrame.origin.x,NSMaxY(mRasterFrame)+40)];
			[b stroke];
			[b removeAllPoints];
		}
		else
		{
			mDrawFrame=mPointList[ [mMap selectedRow]];
		}
		mDrawFrame=NSInsetRect(mDrawFrame,-5,-5);
		[[NSColor blackColor]set];
		[b appendBezierPathWithOvalInRect:mDrawFrame];
		[b stroke];
		[b removeAllPoints];
	}
}
//---------------------------------------------------------------------
// drawRect
//---------------------------------------------------------------------
- (void)drawRect:(NSRect)aRect
{
	double BeginL,BeginR;

	slopemap *cMap=(slopemap*)mMap;
	mFrame=[self bounds];
	// turn aliassing off otherwize the result is not nice :-)
	[[NSGraphicsContext currentContext] setShouldAntialias:YES];
	float inset;
	//erase preview
	[[NSColor whiteColor]set];
	NSRectFill(mFrame);
	if ( cMap==nil)	//safety
		return;
	
	// draw a gray frame 
	[[NSColor controlShadowColor]set];
	
	// get the frame of our view
	NSFrameRect(mFrame);
	mRasterFrame=mFrame;
	
	// raster is a square.
	// if the view is a rect, make sure the raster is a square
	
	if ( mRasterFrame.size.width < mRasterFrame.size.height)
	{
		inset=( mRasterFrame.size.height- mRasterFrame.size.width);
	 	mRasterFrame=NSInsetRect(mRasterFrame,0,inset/2);
	}
	else if ( mRasterFrame.size.width > mRasterFrame.size.height)
	{
		inset=mRasterFrame.size.width-mRasterFrame.size.height;
	 	mRasterFrame=NSInsetRect(mRasterFrame,inset/2,0);
	}

	// leve a little margin left and right
 	mRasterFrame=NSInsetRect(mRasterFrame,kMarginWidth,kMarginWidth);
	
	// subtracting these from the local mouse position
	// gives zero, from where our slope starts
	xToCenter=mRasterFrame.origin.x;
	yToCenter=mRasterFrame.origin.y;


// release lists and allocate new
	NSUInteger outRows=[mMap count];
	if ( outRows<2)
		return;
	if ( mPointList)
	{
		delete mPointList;
		mPointList=0l;
	}	
	mPointList =new NSRect[outRows+1];
	if ( mPointList==0)
		return;

	if ( mSlopePointList)
	{
		delete mSlopePointList;
		mSlopePointList=0l;
	}	
	mSlopePointList =new NSRect[outRows+1];
	if ( mSlopePointList==0)
		return;

//calculate points and draw raster
	// mRasterStep holds the size of 1 thenth of the raster
	// it's a square so height or with doesn't matter
	mRasterStep=mRasterFrame.size.width/10.0f;

	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];

// draw raster
	if ( [mMap buttonState:cRasterButton]==NSOnState)
	{
		[[NSColor grayColor]set];
		for (int y=0; y<=(int)10.0f; y++)
		{
			[b moveToPoint: NSMakePoint(mRasterFrame.origin.x,mRasterFrame.origin.y+(y*mRasterStep))];
			[b lineToPoint: NSMakePoint(NSMaxX(mRasterFrame),mRasterFrame.origin.y+( y*mRasterStep))];
		}
		for (int x=0; x<=(int)10.0f; x++)
		{
			[b moveToPoint: NSMakePoint(mRasterFrame.origin.x+x*mRasterStep,mRasterFrame.origin.y)];
			[b lineToPoint: NSMakePoint(mRasterFrame.origin.x+x*mRasterStep,NSMaxY(mRasterFrame))];
		}
		[b stroke];
		[b removeAllPoints];
	}
	
	for (NSUInteger x=0; x<[mMap count]; x++)
	{
		BeginL=[cMap floatAtRow:x atColumn:cSlopemapLocationIndex];
		BeginL*=NSWidth(mRasterFrame);
		BeginR=[cMap floatAtRow:x atColumn:cSlopemapHeightIndex];
		BeginR*=NSHeight(mRasterFrame);

		mDrawFrame.origin.x=xToCenter+BeginL;
		mDrawFrame.size.width=1;
		mDrawFrame.origin.y=yToCenter+BeginR;
		mDrawFrame.size.height=1;
		mPointList[x]=NSInsetRect(mDrawFrame,-5,-5);
	}

	if ( [mMap buttonState:cSlopeButton]==NSOnState)
	{
		[[NSColor greenColor]set];
		for (NSUInteger x=0; x<[mMap count]; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);
			[b moveToPoint: mDrawFrame.origin];

			mSlopePointList[x].origin.x=mDrawFrame.origin.x+mRasterStep;
			mSlopePointList[x].size.width=1;

			mSlopePointList[x].origin.y=mDrawFrame.origin.y + (mRasterStep*[cMap floatAtRow:x atColumn:cSlopemapSlopeIndex]);
			mSlopePointList[x].size.height=1;
			
			[b lineToPoint: mSlopePointList[x].origin];
			[b stroke];
			[b removeAllPoints];

			mSlopePointList[x]=NSInsetRect(mSlopePointList[x],-3,-3);
			[b appendBezierPathWithOvalInRect:mSlopePointList[x]];
			[b fill];
			[b stroke];
			[b removeAllPoints];
			mSlopePointList[x]=NSInsetRect(mSlopePointList[x],-2,-2);

		}
	}

	[self drawSelectedPoint];

	double T=0.0;
	double T2,T3,C1,C2,C3,C4,Vx,Vy;
	double P1x,P1y,S1x,S1y;
	double P2x,P2y,S2x,S2y;
	
	#define Copies 30.0

	if ( [mMap buttonState:cCurveButton]==NSOnState)
	{
		[[NSColor blueColor]set];
		for (NSUInteger x=0; x<[mMap count]-1; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);

			P1x=NSMinX(mDrawFrame);
			

			P1y=NSMinY(mDrawFrame);

			S1y=[cMap floatAtRow:x atColumn:cSlopemapSlopeIndex];

			
			mDrawFrame=NSInsetRect(mPointList[x+1],5,5);
			P2x=NSMinX(mDrawFrame);
			
			P2y=NSMinY(mDrawFrame);

			if ( (P1x == P2x ) && (P1y==P2y))
				continue;

			S2y=[cMap floatAtRow:x+1 atColumn:cSlopemapSlopeIndex];
			
			S1x=S2x=(double)NSWidth(mRasterFrame);
			S1y*=S1x;
			S2y*=S1x;
			T=0.0;
			BOOL firstdot=YES;
			while ( T <= 1.0)
			{
				T2=T*T;
				T3=T2*T;
				C1 = (2.0*T3 - 3.0*T2 +  1.0);
				C2 = (-2.0*T3 + 3.0*T2      );
				C3 = (   T3 - 2*T2 + T   );
				C4 = (   T3 -   T2          );
				Vx = P1x*C1 + P2x*C2 + S1x*C3 + S2x*C4;
				Vy = P1y*C1 + P2y*C2 + S1y*C3 + S2y*C4;
				if ( firstdot)
				{
					[b moveToPoint: NSMakePoint(Vx,Vy)];
					firstdot=NO;
				}
				else
					[b lineToPoint: NSMakePoint(Vx,Vy)];
				T = T + (1.0/Copies); 
			}
			[b lineToPoint: NSMakePoint(P2x,P2y)];
		}
	}
	[b stroke];
	[b removeAllPoints];
	if ( [mMap buttonState:cPointButton]==NSOnState)
	{
		[[NSColor redColor]set];
		for (NSUInteger x=0; x<[mMap count]; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],2,2);
			[b appendBezierPathWithOvalInRect:mDrawFrame];
			[b fill];
			[b stroke];
			[b removeAllPoints];
		}
	}

}
- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL keepOn = YES;
    NSPoint mouseLoc;

	BOOL PointFound=NO;
	BOOL SlopeFound=NO;;
	long FoundPoint=-1;
	mSlopeFound=-1;

    mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for (NSUInteger counter=0; counter<[mMap count]; counter++)
	{
		if ( [self mouse:mouseLoc inRect:mPointList[counter]] )
		{
			PointFound=YES;
			FoundPoint=counter;
		}
		else	if ([mMap buttonState:cSlopeButton]==NSOnState && [self mouse:mouseLoc inRect:mSlopePointList[counter]])
		{
			SlopeFound=YES;
			mSlopeFound=FoundPoint=counter;
		}
		if( PointFound || SlopeFound)
		{	
			[mMap selectTableRow:counter];	//will make our template select a row
			break;
		}
		
	}
	CGFloat oldh=mouseLoc.y;
	[self setNeedsDisplay:YES];
    while (keepOn && (PointFound || SlopeFound)) 
    {
		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |  NSLeftMouseDraggedMask];
		mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		switch ([theEvent type]) 
		{
		    case NSLeftMouseDragged:
		    	if( [theEvent deltaX] || [theEvent deltaY])	//dit we move?
		    	{
		    		double x,y;
		    		y=mouseLoc.y;
		    		if ( mSlopeFound==-1)
		    			x=mouseLoc.x;
		    		else
		    			x=oldh;

					x-=xToCenter; 
					y-=yToCenter;

					x/=(double)NSWidth(mRasterFrame);
					y/=(double)NSHeight(mRasterFrame);

					if ( PointFound )
					{
						[mMap setFloat:y atRow:FoundPoint atColumn:cSlopemapHeightIndex];
						[mMap setFloat:x atRow:FoundPoint atColumn:cSlopemapLocationIndex];
					}
					else
					{
						y=(mouseLoc.y - yToCenter);
						y=y - ([mMap floatAtRow:FoundPoint atColumn:cSlopemapHeightIndex]*mRasterFrame.size.height);
						y=y/mRasterStep;
						[mMap setFloat:y atRow:FoundPoint atColumn:cSlopemapSlopeIndex];
					}
					[self setNeedsDisplay:YES];
					[mMap reloadData];
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
	return;
}


@end


