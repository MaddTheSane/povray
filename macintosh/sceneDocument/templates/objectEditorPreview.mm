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
#import "objectEditorPreview.h"
#import "objectmap.h"
#import "baseTemplate.h"
#import "tooltipAutomator.h"
#include <cmath>
#import "objectEditorTemplate.h"

// this must be the last file included
#import "syspovdebug.h"

#define kMarginWidth 40.0
typedef double myMatrix[4][4];

static  BOOL MInvers2(myMatrix r,myMatrix m);

#define BezierSteps 40
#define BezierStepsF 40.0
#define CubicSteps 20.0

@implementation objectEditorPreview

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[mBackgroundPicturePopup setAutoenablesItems:NO];
	[self setImageControls];
	
	[ToolTipAutomator setTooltips:@"objectEditorLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			mBackgroundPicturePopup,		@"BackgroundPicturePopup",
			mCenter,								@"Center",
			mShiftLeft,								@"ShiftLeft",
			mShiftRight,							@"ShiftRight",
			mShiftUp,								@"ShiftUp",
			mShiftDown,							@"ShiftDown",
			mShowPictureButton,				@"ShowPictureButton",
			mZoomSlider,							@"ZoomSlider",
			mSizeSlider,							@"SizeSlider",

		nil]
		];

}

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
	[self setImagePath:nil];
	[self setImage:nil];
	
	[super dealloc];
}

// ---------------------------------------------------------------------------
//	backgroundPicturePopup
// ---------------------------------------------------------------------------
-(IBAction) backgroundPicturePopup:(id)sender
{
	NSModalResponse res;
	NSOpenPanel *openPanel;
	switch([mBackgroundPicturePopup indexOfSelectedItem])
	{
		case cBackgroundPictureLoad:
			openPanel=[NSOpenPanel openPanel];
			[openPanel setAllowsMultipleSelection:NO];
			[openPanel setCanChooseDirectories:NO];
			[openPanel setCanChooseFiles:YES];
			[openPanel setAllowedFileTypes:[NSImage imageTypes]];
			res=[openPanel runModal];
			if ( NSOKButton==res)
				[self loadNewBackgroundImage:[[openPanel URL] path]];
			break;
		case cBackgroundPictureReload:
			if ([self imagePath] != nil)
				[self loadNewBackgroundImage:[self imagePath]];
				break;
		case cBackgroundPictureRemove:
			[self setImage:nil];
			[self setImagePath:nil];
			[self setImageControls];
			break;
		case cBackgroundPictureBrighten:	[self brighten]; 	break;
		case cBackgroundPictureDarken:		[self darken];		break;	
		case cBackgroundPictureGrayscale:	[self grayScale];	break;
	}
}

// ---------------------------------------------------------------------------
//	grayScale
// ---------------------------------------------------------------------------
-(void) grayScale
{
	NSBitmapImageRep *rep=[self makeRepBitmap];
	if ( rep == nil)
		return;


	NSInteger BitsSample=[rep bitsPerSample];
	NSInteger BytesPerRow=[rep bytesPerRow];
	NSInteger SamplePixel=[rep samplesPerPixel];
	NSSize imgSize=NSMakeSize([rep pixelsWide],[rep pixelsHigh]) ;

	if ( BitsSample == 8 && (SamplePixel == 3 || SamplePixel == 4))
	{
		for ( long y=0; y<imgSize.height; y++)
		{
			unsigned char* screenptr=[rep bitmapData];
			screenptr+=BytesPerRow*y;
			for ( long x=0; x<imgSize.width; x++)
			{
				double temp=(double)*screenptr+(double)*(screenptr+1)+(double)*(screenptr+2);
				temp/=3.0;
				*screenptr++=(unsigned char)temp;
				*screenptr++=(unsigned char)temp;
				*screenptr++=(unsigned char)temp;
				if ( SamplePixel == 4)
					screenptr++;
			}
		}
		mIsGray=YES;
	}
	[self setNeedsDisplay:YES];
	[self setImageControls];
}

// ---------------------------------------------------------------------------
//	darken
// ---------------------------------------------------------------------------
-(void) darken
{
	NSBitmapImageRep *rep=[self makeRepBitmap];
	if ( rep == nil)
		return;
		
	NSInteger BitsSample=[rep bitsPerSample];
	NSInteger BytesPerRow=[rep bytesPerRow];
	NSInteger SamplePixel=[rep samplesPerPixel];
	NSSize imgSize=NSMakeSize([rep pixelsWide],[rep pixelsHigh]) ;
	if ( BitsSample == 8 && (SamplePixel == 3 || SamplePixel == 4))
	{
		for ( long y=0; y<imgSize.height; y++)
		{
			unsigned char* screenptr=[rep bitmapData];
			screenptr+=BytesPerRow*y;
			for ( long x=0; x<imgSize.width; x++)
			{
				for (int z=1; z<=3; z++)
				{
					double temp=*screenptr;
					temp-=temp*10.0/100.0;
					if ( temp > 255.0)
						temp=255.0;
					*screenptr++=(unsigned char)temp;
				}
				if ( SamplePixel == 4)
					screenptr++;
			}
		}
	}
	[self setNeedsDisplay:YES];
	[self setImageControls];

}

// ---------------------------------------------------------------------------
//	brighten
// ---------------------------------------------------------------------------
-(void) brighten
{
	NSBitmapImageRep *rep=[self makeRepBitmap];
	if ( rep == nil)
		return;
		
	NSInteger BitsSample=[rep bitsPerSample];
	NSInteger BytesPerRow=[rep bytesPerRow];
	NSInteger SamplePixel=[rep samplesPerPixel];
	NSSize imgSize=NSMakeSize([rep pixelsWide],[rep pixelsHigh]) ;
	if ( BitsSample == 8 && (SamplePixel == 3 || SamplePixel == 4))
	{
		for ( long y=0; y<imgSize.height; y++)
		{
			unsigned char* screenptr=[rep bitmapData];
			screenptr+=BytesPerRow*y;
			for ( long x=0; x<imgSize.width; x++)
			{
				for (int z=1; z<=3; z++)
				{
				
					double temp=*screenptr;
					temp+=temp*10.0/100.0;
					if ( temp > 255.0)
						temp=255.0;
					*screenptr++=(unsigned char)temp;
				}
				if ( SamplePixel == 4)
					screenptr++;
			}
		}
	}
	[self setNeedsDisplay:YES];
	[self setImageControls];

}

// ---------------------------------------------------------------------------
//	makeRepBitmap
// ---------------------------------------------------------------------------
-(NSBitmapImageRep *) makeRepBitmap
{
	NSImage *img=[self image];
	if ( img ==nil)
		return nil;

	NSArray *repArray=[img representations];
	if (repArray==nil)
		return nil;

	NSInteger repCount=[repArray count];
	if ( repCount==0)
		return nil ;
		
	id rep=[repArray objectAtIndex:0];

	if (rep == nil)
		return rep;
		
	if ( [ rep isKindOfClass:[NSBitmapImageRep class]]==NO)
	{
		NSData *tiff_data = [[NSData alloc] initWithData:[img TIFFRepresentation]];
		[tiff_data autorelease];
		NSBitmapImageRep *bitmap = [[[NSBitmapImageRep alloc] initWithData:tiff_data]autorelease];
		NSArray *repArray=[img representations];
		if (repArray !=nil)
		{
			for (int x=0; x<[repArray count]; x++)
				[img removeRepresentation:[repArray objectAtIndex:x]];
		}
		[img addRepresentation:bitmap];
		rep=bitmap;
	}	
	return rep;
}

// ---------------------------------------------------------------------------
//	objectmapmapButtons
// ---------------------------------------------------------------------------
-(IBAction) objectPreviewButtons:(id)sender
{
	switch( [sender tag])
	{
		case cShowBackgroundPictureButton: 
			[self setImageControls];
			[self setNeedsDisplay:YES];	
			break;
		case cObjectEditorCenter:	shiftUp=shiftLeft=0.0;	[self setNeedsDisplay:YES];			break;
		case cObjectEditorMoveUp:	shiftUp++;				[self setNeedsDisplay:YES];			break;
		case cObjectEditorMoveRight:shiftLeft++;			[self setNeedsDisplay:YES];			break;
		case cObjectEditorMoveDown: shiftUp--;				[self setNeedsDisplay:YES];			break;
		case cObjectEditorMoveLeft:	shiftLeft--;			[self setNeedsDisplay:YES];			break;
		case cZoomSlider:					
			zoomIn=100.0-[mZoomSlider floatValue]+10.0; 
			[self setNeedsDisplay:YES];
			break;
		case cSizeSlider:					
			sizeIn=[mSizeSlider floatValue]; [self setNeedsDisplay:YES];
			break;
	}
}

// ---------------------------------------------------------------------------
//	setImageControls
// ---------------------------------------------------------------------------
-(void) setImageControls
{
	if ( [self image] == nil)
	{
		[mShowPictureButton setEnabled:NO];
		SetSubViewsOfNSBoxToState(mImageControlsView, NSOffState);
	}
	else
	{
		[mShowPictureButton setEnabled:YES];
		SetSubViewsOfNSBoxToState(mImageControlsView, [mShowPictureButton state]);
	}

	if ( [self imagePath]!=nil)
		[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureReload]setEnabled:YES];
	else
		[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureReload]setEnabled:NO];

	[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureLoad]setEnabled:YES];
	BOOL enabled=NO;
	if ( [self image]!= nil)
		enabled=YES;

	[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureRemove]setEnabled:enabled];
	[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureBrighten]setEnabled:enabled];
	[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureDarken]setEnabled:enabled];
	if ( [self image]!= nil)
	{
		if ( mIsGray == YES)
			enabled=NO;
	}
		[[mBackgroundPicturePopup itemAtIndex:cBackgroundPictureGrayscale]setEnabled:enabled];
}

//---------------------------------------------------------------------
// setImage
//---------------------------------------------------------------------
-(void) setImage:(NSImage *)img
{
	[mImage release];
	mImage=img;
	[mImage retain];
	
}	

//---------------------------------------------------------------------
// image
//---------------------------------------------------------------------
-(NSImage*) image
{
	return mImage;
}

//---------------------------------------------------------------------
// setImagePath
//---------------------------------------------------------------------
-(void) setImagePath:(NSString *)file
{
	[mImagePath release];
	mImagePath=[file copy];
//	[mImagePath retain];
}	

//---------------------------------------------------------------------
// imagePath
//---------------------------------------------------------------------
-(NSString*) imagePath
{
	return mImagePath;
}

//---------------------------------------------------------------------
// loadNewBackgroundImage
//---------------------------------------------------------------------
-(void) loadNewBackgroundImage:(NSString*)file
{
	NSImage *newImage=[[[NSImage alloc]initWithContentsOfFile:[[file copy]autorelease]]autorelease];
	if ( newImage!= nil)
	{
	//	[newImage autorelease];
		[self setImagePath:file];
		[mShowPictureButton setState:NSOnState];
		[self setImage:newImage];
		[self resetImagePosition];
		[self setImageControls];
	}
	
}

//---------------------------------------------------------------------
// resetImagePosition
//---------------------------------------------------------------------
-(void) 	resetImagePosition
{
	shiftLeft=0.0;
	shiftUp=0.0;
	zoomIn=100.0;
	sizeIn=0.0;
	mIsGray=NO;
	
	[self setNeedsDisplay:YES];
}
	
//---------------------------------------------------------------------
// drawSelectedPoint
//---------------------------------------------------------------------
-(void) calculateBackgroundRects
{
	NSSize imageSize=[[self image]size];
	mImageToRect=mRasterFrame;
	float rasterHeight=mRasterFrame.size.height;
	float rasterWidth=mRasterFrame.size.width;

	if ( imageSize.width > imageSize.height)	
	{
		mImageToRect.size.height=rasterHeight * (imageSize.height/imageSize.width);
		mImageToRect.origin.y+=(rasterHeight-mImageToRect.size.height)/2.0;
	}
	else
	{
		mImageToRect.size.width=rasterWidth * (imageSize.width/imageSize.height);
		mImageToRect.origin.x+=(rasterWidth-mImageToRect.size.width)/2.0;
	}
	mImageToRect.origin.x+=shiftLeft;
	mImageToRect.origin.y+=shiftUp;
	mImageToRect.size.width+=imageSize.width*sizeIn/100.0;
	mImageToRect.size.height+=imageSize.height*sizeIn/100.0;
	mImageFromRect=NSMakeRect(0,0,imageSize.width,imageSize.height);
	mImageFromRect.size.width=imageSize.width*zoomIn/100.0;
	mImageFromRect.size.height=imageSize.height*zoomIn/100.0;
	
	mImageFromRect.origin.x=(imageSize.width-mImageFromRect.size.width)/2.0;

	mImageFromRect.origin.y=(imageSize.height-mImageFromRect.size.height)/2.0;
}

//---------------------------------------------------------------------
// drawSelectedPoint
//---------------------------------------------------------------------
-(void)drawSelectedPoint
{
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];
	[[NSColor blackColor]set];
	for( NSUInteger x=0; x<[mMap count]; x++)
	{
		if ([ [mMap tableView] isRowSelected:x])
		{
			mDrawFrame=mPointList[x];
			mDrawFrame=NSInsetRect(mDrawFrame,-5,-5);
			[b appendBezierPathWithOvalInRect:mDrawFrame];
		}
	}
	[b stroke];
	[b removeAllPoints];
}

//---------------------------------------------------------------------
// drawRect
//---------------------------------------------------------------------
- (void)drawRect:(NSRect)aRect
{
	float BeginL=0.0,BeginR=0.0;
	float numberOfLines;
	objectmap *cMap=(objectmap*)mMap;
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

	// leave a little margin left and right
 	mRasterFrame=NSInsetRect(mRasterFrame,kMarginWidth,kMarginWidth);


	// draw background image
	if ( mImage && [mShowPictureButton state]==NSOnState)
	{
		[self calculateBackgroundRects];

		[[self image] drawInRect:mImageToRect fromRect:mImageFromRect operation:NSCompositeSourceOver fraction:1];
	}

	// subtracting these from the local mouse position
	// gives zero, from where our slope starts
	mXToCenter=mRasterFrame.origin.x;
	mYToCenter=mRasterFrame.origin.y;


// release lists and allocate new
	if ( [mMap count]<2)
		return;
	if ( mPointList)
	{
		delete mPointList;
		mPointList=0l;
	}	
	mPointList =new NSRect[[mMap count]+1];
	if ( mPointList==0)
		return;

//calculate points and draw raster
	// mRasterStep holds the size of 1 thenth of the raster
	// it's a square so height or with doesn't matter
//calculate points and draw grid
	if ( [mMap templateType]==menuTagTemplateLathe  || [mMap templateType]==menuTagTemplateSor)
		numberOfLines=10.0f;
	else
		numberOfLines=20.0f;
	mRasterStep=mRasterFrame.size.width/numberOfLines;

	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];

// draw raster
	if ( [mMap buttonState:cRasterButton]==NSOnState)
	{
		[[NSColor grayColor]set];
		for (int y=0; y<=(int)numberOfLines; y++)
		{
			[b moveToPoint: NSMakePoint(mRasterFrame.origin.x,mRasterFrame.origin.y+(y*mRasterStep))];
			[b lineToPoint: NSMakePoint(NSMaxX(mRasterFrame),mRasterFrame.origin.y+( y*mRasterStep))];
		}
		for (int x=0; x<=(int)numberOfLines; x++)
		{
			[b moveToPoint: NSMakePoint(mRasterFrame.origin.x+x*mRasterStep,mRasterFrame.origin.y)];
			[b lineToPoint: NSMakePoint(mRasterFrame.origin.x+x*mRasterStep,NSMaxY(mRasterFrame))];
		}
		[b stroke];
		[b removeAllPoints];
	}

	[[NSColor darkGrayColor]set];
	NSString *theString=nil;
	NSSize textBound;
	float xP,yP;
	NSDictionary *textAttributes= [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont userFontOfSize:9.0], NSFontAttributeName,
						[NSColor blackColor], NSForegroundColorAttributeName,
					nil];
	
	if ( [mMap templateType]==menuTagTemplatePolygon  || [mMap templateType]==menuTagTemplatePrism)
	{
		theString=@"X";
		//get the size of the text;
		textBound=[theString sizeWithAttributes:textAttributes];

		xP=mXToCenter-mRasterStep-textBound.width;
		yP=mYToCenter+(mRasterFrame.size.height/2)-(textBound.height/2);
		[theString drawAtPoint:NSMakePoint(xP,yP) withAttributes:textAttributes];
		[b moveToPoint: NSMakePoint(mXToCenter-mRasterStep,mYToCenter+(mRasterFrame.size.height/2))];
		[b lineToPoint: NSMakePoint(mXToCenter+mRasterFrame.size.width+mRasterStep,mYToCenter+(mRasterFrame.size.height/2))];
		[b stroke];	[b removeAllPoints];

		if ( [mMap templateType]==menuTagTemplatePrism)
			theString=@"Z";
		else
			theString=@"Y";
		
		//get the size of the text;
		textBound=[theString sizeWithAttributes:textAttributes];

		xP=mXToCenter+(mRasterFrame.size.width/2)-(textBound.width/2);
		yP=mYToCenter+mRasterStep+mRasterFrame.size.height+(textBound.height);
		[theString drawAtPoint:NSMakePoint(xP,yP) withAttributes:textAttributes];

		[b moveToPoint: NSMakePoint(mXToCenter+(mRasterFrame.size.width/2), mYToCenter-mRasterStep)];
		[b lineToPoint: NSMakePoint(mXToCenter+(mRasterFrame.size.width/2),mYToCenter+mRasterStep+mRasterFrame.size.height)];
		[b stroke];	[b removeAllPoints];
	}
	else
	{
		theString=@"X";
		//get the size of the text;
		textBound=[theString sizeWithAttributes:textAttributes];

		xP=mXToCenter+mRasterStep+mRasterFrame.size.width;
		yP=mYToCenter-(textBound.height/2);
		[theString drawAtPoint:NSMakePoint(xP,yP) withAttributes:textAttributes];
		[b moveToPoint: NSMakePoint(mXToCenter-mRasterStep,mYToCenter)];
		[b lineToPoint: NSMakePoint(mXToCenter+mRasterFrame.size.width+mRasterStep,mYToCenter)];
		[b stroke];	[b removeAllPoints];


		theString=@"Y";
		//get the size of the text;
		textBound=[theString sizeWithAttributes:textAttributes];

		xP=mXToCenter-(textBound.width/2);
		yP=mYToCenter+mRasterFrame.size.height+mRasterStep;
		[theString drawAtPoint:NSMakePoint(xP,yP) withAttributes:textAttributes];
		[b moveToPoint: NSMakePoint(mXToCenter,mYToCenter-mRasterStep)];
		[b lineToPoint: NSMakePoint(mXToCenter,mYToCenter+mRasterStep+mRasterFrame.size.height)];
		[b stroke];	[b removeAllPoints];
	}

	for (NSUInteger x=0; x<[mMap count]; x++)
	{
		switch ( [mMap templateType])
		{
			case menuTagTemplateSor:
			case menuTagTemplateLathe:
				BeginL=[cMap floatAtRow:x atColumn:cObjectmapXIndex];
				BeginL*=NSWidth(mRasterFrame);
				BeginR=[cMap floatAtRow:x atColumn:cObjectmapYIndex];
				BeginR*=NSHeight(mRasterFrame);
				break;
			case menuTagTemplatePrism:
			case menuTagTemplatePolygon:
				BeginL=([cMap floatAtRow:x atColumn:cObjectmapXIndex]/2.0)+0.5;
				BeginL*=NSWidth(mRasterFrame);
				BeginR=([cMap floatAtRow:x atColumn:cObjectmapYIndex ]/2.0)+0.5;
				BeginR*=NSHeight(mRasterFrame);
				break;
		}
		mDrawFrame.origin.x=mXToCenter+BeginL;
		mDrawFrame.size.width=1;
		mDrawFrame.origin.y=mYToCenter+BeginR;
		mDrawFrame.size.height=1;
		mPointList[x]=NSInsetRect(mDrawFrame,-5,-5);
	}
	
		switch ( [mMap templateType])
	{
		case menuTagTemplatePolygon:		[self drawPolygon];		break;
		case menuTagTemplatePrism:		[self drawPrism];		break;
		case menuTagTemplateSor:			[self drawSor];			break;
		case menuTagTemplateLathe:		[self drawLathe];		break;
		
	}


	[self drawSelectedPoint];


}

// ---------------------------------------------------------------------------
//	mouseDown: theEvent
// ---------------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL keepOn = YES;
    NSPoint mouseLoc;

	BOOL Found=NO;
	BOOL SlopeFound=NO;;
	NSInteger FoundPoint=-1;

	NSInteger LastPoint=-1,ControlPoint=-1,CenterPoint;
	NSInteger LeftPoint=-1,RightPoint=-1;

     mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
	for (NSUInteger counter=0; counter<[mMap count]; counter++)
	{
		if ( [self mouse:mouseLoc inRect:mPointList[counter]] )
		{
			Found=YES;
			FoundPoint=counter;
			if ( [theEvent modifierFlags]&NSShiftKeyMask)
				[mMap selectRow:counter byExtendingSelection:YES];	//will make our template select a row
			else
				[mMap selectRow:counter byExtendingSelection:NO];	//will make our template select a row
			break;
		}
		
	}
	[self setNeedsDisplay:YES];
   while (keepOn && (Found || SlopeFound)) 
  {
		[self getLastPoint:FoundPoint lastPoint:LastPoint];
		if ( LastPoint == -1)
			[self getControlPoint:FoundPoint controlPoint:ControlPoint centerPoint:CenterPoint event:theEvent];
		[self getLeftRightPoint:FoundPoint leftPoint:LeftPoint rightPoint:RightPoint event:theEvent];

		theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask |  NSLeftMouseDraggedMask];
		mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		BOOL shifted=NO;
		if ( [theEvent modifierFlags]&NSShiftKeyMask)
			shifted=YES;

		switch ([theEvent type]) 
		{
		    case NSLeftMouseDragged:
		    	if( [theEvent deltaX] || [theEvent deltaY])	//did we move?
		    	{
		    		float x,y;
		    		y=mouseLoc.y;
	    			x=mouseLoc.x;

					x-=mXToCenter; 
					y-=mYToCenter;
					if ( [mMap templateType] == menuTagTemplatePolygon || [mMap templateType]==menuTagTemplatePrism )
					{
					
						x=(x*2/(float)NSWidth(mRasterFrame))-1;
						y=(y*2/(float)NSHeight(mRasterFrame))-1;
					}
					else
					{
						x/=(float)NSWidth(mRasterFrame);
						y/=(float)NSWidth(mRasterFrame);
					}	

					[self setPointToMin:x thePoint:FoundPoint];
					if ( [mMap templateType] == menuTagTemplateSor)
					{
						if ( LeftPoint != -1 && y <= [mMap floatAtRow:LeftPoint atColumn:cObjectmapYIndex])
							y=[mMap floatAtRow:LeftPoint atColumn:cObjectmapYIndex]+0.001;
						if ( RightPoint != -1 && y >= [mMap floatAtRow:RightPoint atColumn:cObjectmapYIndex])
							y=[mMap floatAtRow:RightPoint atColumn:cObjectmapYIndex]-0.001;
					}						

					float tempHeight=[mMap floatAtRow:FoundPoint atColumn:cObjectmapYIndex];
					float tempLocation=[mMap floatAtRow:FoundPoint atColumn:cObjectmapXIndex];

					[mMap setFloat:y atRow:FoundPoint atColumn:cObjectmapYIndex];
					[mMap setFloat:x atRow:FoundPoint atColumn:cObjectmapXIndex];

					if ( shifted==YES)	//shift key pressed
					{
						tempHeight-=y;
						tempLocation-=x;
						for( NSInteger ct=0; ct<[mMap count]; ct++)
						{	
							if ( ct!=FoundPoint && [[mMap tableView] isRowSelected:ct])
							{
								float temp=[mMap floatAtRow:ct atColumn:cObjectmapYIndex];
								temp-=tempHeight;
								[mMap setFloat:temp atRow:ct atColumn:cObjectmapYIndex];

								temp=[mMap floatAtRow:ct atColumn:cObjectmapXIndex];
								temp-=tempLocation;
								[self setPointToMin:temp thePoint:ct];
								[mMap setFloat:temp atRow:ct atColumn:cObjectmapXIndex];
							}
						}

					}
					else	//shift key not pressed
					{
						if ( LastPoint != -1)
						{
							[mMap setFloat:y atRow:LastPoint atColumn:cObjectmapYIndex];
							float t=x;
							[self setPointToMin:t thePoint:LastPoint];
							[mMap setFloat:t atRow:LastPoint atColumn:cObjectmapXIndex];
						}	
						else if ( ControlPoint != -1)
							[self calculateControlPoint:FoundPoint controlPoint:ControlPoint centerPoint:CenterPoint];

						if ( [mMap templateType] != menuTagTemplateSor)
						{
							if ( LeftPoint != -1)
							{
								float t=-1*(tempHeight-[mMap floatAtRow:FoundPoint atColumn:cObjectmapYIndex]);
								t+=[mMap floatAtRow:LeftPoint atColumn:cObjectmapYIndex];
								[mMap setFloat:t atRow:LeftPoint atColumn:cObjectmapYIndex];

								t=-1*(tempLocation-[mMap floatAtRow:FoundPoint atColumn:cObjectmapXIndex]);
								t+=[mMap floatAtRow:LeftPoint atColumn:cObjectmapXIndex];
								[self setPointToMin:t thePoint:LeftPoint];
								[mMap setFloat:t atRow:LeftPoint atColumn:cObjectmapXIndex];
								
							}				
							if ( RightPoint != -1)
							{
								float t=-1*(tempHeight-[mMap floatAtRow:FoundPoint atColumn:cObjectmapYIndex]);
								t+=[mMap floatAtRow:RightPoint atColumn:cObjectmapYIndex];
								[mMap setFloat:t atRow:RightPoint atColumn:cObjectmapYIndex];

								t=-1*(tempLocation-[mMap floatAtRow:FoundPoint atColumn:cObjectmapXIndex]);
								t+=[mMap floatAtRow:RightPoint atColumn:cObjectmapXIndex];
								[self setPointToMin:t thePoint:RightPoint];
								[mMap setFloat:t atRow:RightPoint atColumn:cObjectmapXIndex];
							}				
						}
					}//if ( shifted==YES)	//shift key pressed
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
		}//switch ([theEvent type]) 
	};
	
	return;
}

// ---------------------------------------------------------------------------
//	setPointToMin: thePoint
// ---------------------------------------------------------------------------
//	See if a point can be les then zero
// ---------------------------------------------------------------------------

-(void) setPointToMin:(float & ) theValue thePoint:(NSInteger&)thePoint
{
	if ( [mMap templateType] == menuTagTemplateLathe )
	{
			if ( thePoint >=2 && thePoint < ([mMap count]-1) && theValue < 0.0)
				theValue=0.0;
	}
	else if ( [mMap templateType] == menuTagTemplateSor && theValue < 0.0)
			theValue =0.0;
			
}	


// ---------------------------------------------------------------------------
//	calculateControlPoint: controlPoint: centerPoint
// ---------------------------------------------------------------------------
-(void) calculateControlPoint:(NSInteger)SelectedPoint controlPoint:(NSInteger&)ControlPoint centerPoint:(NSInteger&)CenterPoint
{
	double sx=[mMap floatAtRow:SelectedPoint atColumn:cObjectmapXIndex];
	double sy=[mMap floatAtRow:SelectedPoint atColumn:cObjectmapYIndex];
	double cx=[mMap floatAtRow:ControlPoint atColumn:cObjectmapXIndex];
	double cy=[mMap floatAtRow:ControlPoint atColumn:cObjectmapYIndex];
	double tx=[mMap floatAtRow:CenterPoint atColumn:cObjectmapXIndex];
	double ty=[mMap floatAtRow:CenterPoint atColumn:cObjectmapYIndex];
	double A=(sy-ty)/(sx-tx);
	double B;

	#define Epsilon 0.001
	double angle=atan(A);
	
	if ( (sx-tx) > Epsilon)
		B=3.1415926535897932384626+angle;
	else if ( ( (sx-tx) > -Epsilon && (sx-tx) < Epsilon ) && ((sy-ty) > 0.0))
		B=-(3.1415926535897932384626 /2);
	else if ( ( (sx-tx) > -Epsilon && (sx-tx) < Epsilon ) && ((sy-ty) <= 0.0))
		B=(3.1415926535897932384626 /2);
	else
		B=angle;

	double d=sqrt(pow((cx-tx),2)+pow((cy-ty),2));
	[mMap setFloat:(d*cos(B))+tx atRow:ControlPoint atColumn:cObjectmapXIndex];
	if ( [mMap templateType] == menuTagTemplateLathe)
	{
		if ( [mMap floatAtRow:ControlPoint atColumn:cObjectmapXIndex] < 0.0)
			[mMap setFloat:0.0  atRow:ControlPoint atColumn:cObjectmapXIndex];
	}
	[mMap setFloat:(d*sin(B))+ty atRow:ControlPoint atColumn:cObjectmapYIndex];
	

}

// ---------------------------------------------------------------------------
//	getLastPoint: lastPoint
// ---------------------------------------------------------------------------
//	See if some point has to follow the selected point
// LastPoint is set to pointnumber or -1 if not
// ---------------------------------------------------------------------------
-(void) getLastPoint:(NSInteger&)SelectedPoint lastPoint:(NSInteger&)LastPoint 
{
	NSInteger NumberOfPoints=[mMap count]-1;	//index of last point  (!= number of points)

	LastPoint=-1;
	switch ( [mMap templateType])
	{
		case menuTagTemplatePolygon:
			if ( SelectedPoint==0 ) 
				LastPoint=NumberOfPoints;
			else if ( SelectedPoint == NumberOfPoints ) 
				LastPoint=1;
			break;
		case menuTagTemplatePrism:
			switch ( [mMap buttonState:cSplineTypePopUp])
			{
				case cLinearSpline:
					if ( SelectedPoint==0 ) 
						LastPoint=NumberOfPoints;
					else if ( SelectedPoint==NumberOfPoints ) 
						LastPoint=1;
					break;
				case cQuadraticSpline:
					if ( SelectedPoint==1 ) 
						LastPoint=NumberOfPoints;
					else if ( SelectedPoint==NumberOfPoints ) 
						LastPoint=2;
					break;
				case cCubicSpline:
					if ( SelectedPoint==1 ) 
						LastPoint=NumberOfPoints-1;
					else if ( SelectedPoint==NumberOfPoints-1 ) 
						LastPoint=2;
					break;
				case cBezierSpline:
					if ( SelectedPoint==0 ) 
						LastPoint=NumberOfPoints;
					else if ( SelectedPoint==NumberOfPoints ) 
						LastPoint=1;
					else if  ( (SelectedPoint+1) % 4 == 0)
						LastPoint=SelectedPoint+1;
					else if ( ((SelectedPoint+1)-1) % 4 == 0)
						LastPoint=SelectedPoint-1;
			}
			break;
		case menuTagTemplateLathe:
			switch ( [mMap buttonState:cSplineTypePopUp])
			{
				case cBezierSpline:
					if ( SelectedPoint == 0 || SelectedPoint == NumberOfPoints)
						return;
					if  ( (SelectedPoint+1) % 4 == 0 )
						LastPoint=SelectedPoint+1;
					else if ( ((SelectedPoint+1)-1) % 4 == 0)
						LastPoint=SelectedPoint-1;
			}
			break;
	}
}

// ---------------------------------------------------------------------------
//	getControlPoint: controlPoint: centerPoiont
// ---------------------------------------------------------------------------
//	See if some controlPoint point has to follow the selected point
// LastPoint is set to pointnumber or -1 if not
// ---------------------------------------------------------------------------
-(void) getControlPoint:(NSInteger) SelectedPoint controlPoint:(NSInteger&)ControlPoint centerPoint:(NSInteger&)CenterPoint event:(NSEvent*)event
{
	NSInteger NumberOfPoints=[mMap count]-1;	//index of last point  (!= number of points)
	ControlPoint=-1;

	if ( [event modifierFlags]&NSAlternateKeyMask)
		return;
	
	if ( [mMap buttonState:cSplineTypePopUp] != cBezierSpline)	//only bezier
		return;
	
	if ( SelectedPoint+1 == 1 || SelectedPoint == NumberOfPoints)
		return;
	if ( SelectedPoint+1 == NumberOfPoints -1 )
	{
		if ( [mMap templateType] == menuTagTemplateLathe)
			return;
		ControlPoint=1;
		CenterPoint=0;
		return;
	}	
	if ( (((SelectedPoint+1)/2) & 1)	&& ((SelectedPoint+1) % 2==0))	// ControlPoint connect with previous point
	{
		if ( SelectedPoint == 1)
		{
			if ( [mMap templateType] == menuTagTemplateLathe)
				return;
			ControlPoint=NumberOfPoints-1;
			CenterPoint=SelectedPoint-1;
			return;
		}
		ControlPoint=SelectedPoint-3;
		CenterPoint=SelectedPoint-1;
		
		return;
	}
	
		
	if ( (SelectedPoint+1) % 4 == 0 || ((SelectedPoint+1)-1) % 4 == 0)	//no control Point
		return;
	//must be control point and next is ahead
	CenterPoint=SelectedPoint+1;
	ControlPoint=SelectedPoint+3;
	return;
}

// ---------------------------------------------------------------------------
//	getLeftRightPoint:leftPoint:rightPoint
// ---------------------------------------------------------------------------
//	Find controlPoints connected to the selected point
// ---------------------------------------------------------------------------
-(void) getLeftRightPoint:(NSInteger) SelectedPoint leftPoint:(NSInteger&)LeftPoint rightPoint:(NSInteger&)RightPoint event:(NSEvent*)event
{
	NSInteger NumberOfPoints=[mMap count]-1;	//index of last point  (!= number of points)

	LeftPoint=RightPoint=-1;
	if ( [mMap templateType]==menuTagTemplateSor)
	{
		if ( SelectedPoint == 0|| SelectedPoint == NumberOfPoints)	// control point
			return;
		if ( SelectedPoint == 1)
		{
			RightPoint=SelectedPoint+1;
			return;
		}
		if ( SelectedPoint == NumberOfPoints-1)
		{
			LeftPoint=SelectedPoint-1;
			return;
		}
		if ( NumberOfPoints> 4 )
		{
			LeftPoint=SelectedPoint-1;
			RightPoint=SelectedPoint+1;
			return;
		}
	}	
			
	if ([mMap templateType] != menuTagTemplateLathe && [mMap templateType] != menuTagTemplatePrism)
		return;
		
	if ( [event modifierFlags]&NSAlternateKeyMask)
		return;
		
	if ( [mMap buttonState:cSplineTypePopUp] != cBezierSpline)
		return;
		
	// corrrect spline type and object start looking
	if ( SelectedPoint == 0)
	{
		if ( [mMap templateType] == menuTagTemplateLathe)
			LeftPoint=-1;
		else
			LeftPoint = NumberOfPoints-1;
		RightPoint=SelectedPoint+1;
		return;
	}
	if ( SelectedPoint == NumberOfPoints)
	{
		LeftPoint=SelectedPoint-1;
		if ( [mMap templateType] ==menuTagTemplateLathe)
			RightPoint=-1;
		else
			RightPoint=2;
		return;
	}
	if ( (SelectedPoint+1) % 4 ==0)	// redPoint
	{
		LeftPoint=SelectedPoint-1;
		RightPoint=SelectedPoint+2;
		return;
	}
	else if ( ((SelectedPoint+1)-1) % 4 ==0)	// redPoint
	{
		LeftPoint=SelectedPoint-2;
		RightPoint=SelectedPoint+1;
		return;
	}
	return;
}

//---------------------------------------------------------------------
// drawPolygon
//---------------------------------------------------------------------
-(void) drawPolygon
{
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];
	
	if ( [mMap buttonState:cCurveButton]==NSOnState)
	{
		BOOL FirstLine=YES;
		[[NSColor blueColor]set];
		for (NSUInteger x=0; x<[mMap count]; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);
			if ( FirstLine)
			{
				[b moveToPoint: mDrawFrame.origin];
				FirstLine=NO;
			}
			else
				[b lineToPoint: mDrawFrame.origin];
		}
		
		[b stroke];
		[b removeAllPoints];
	}
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

//---------------------------------------------------------------------
// drawPrism
//---------------------------------------------------------------------
-(void) drawPrism
{
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];
	for (NSUInteger x=0; x<[mMap count]; x++)
	{
		mDrawFrame=NSInsetRect(mPointList[x],2,2);
		if ( [mMap buttonState:cPointButton]==NSOnState)
		{
			if ( [mMap buttonState:cSplineTypePopUp]<=cCubicSpline || ((x+1)==1 || ((x+1)%4 ==0 ) || ((x+1)%4==1)))
			{
				[[NSColor redColor]set];
				[b appendBezierPathWithOvalInRect:mDrawFrame];
				[b fill];
				[b stroke];
				[b removeAllPoints];
			}
		}
		if (  [mMap buttonState:cSlopeButton]==NSOnState && ((x+1)!=1 && ((x+1)%4 !=0 ) && ((x+1)%4 !=1)))
		{
			if ( [mMap buttonState:cSplineTypePopUp] >cCubicSpline )
			{
				[[NSColor greenColor]set];
				[b appendBezierPathWithOvalInRect:mDrawFrame];
				[b fill];
				[b stroke];
				[b removeAllPoints];
			}
		}
	}
	[self drawQubicQuadratic];


	if ( [mMap buttonState:cSlopeButton]==NSOnState)
	{
		if ( [mMap buttonState:cSplineTypePopUp] >cCubicSpline )
		{
			[[NSColor greenColor]set];
			for (NSUInteger x=0; x<[mMap count]; x+=2)
			{
				mDrawFrame=NSInsetRect(mPointList[x],5,5);
				[b moveToPoint: mDrawFrame.origin];
				mDrawFrame=NSInsetRect(mPointList[x+1],5,5);
				[b lineToPoint: mDrawFrame.origin];
				[b stroke];
				[b removeAllPoints];
			}
		}
	}		


	[self drawBezier];

}

//---------------------------------------------------------------------
// drawSor
//---------------------------------------------------------------------
-(void) drawSor
{
	double A, B, C, D, w, k[4];
	myMatrix Mat;
	NSRect DrawFrame1,DrawFrame2,DrawFrame3;
	[[NSColor blueColor]set];
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];

	if ( [mMap buttonState:cCurveButton]==NSOnState)
	{
		for (NSUInteger x=0; x<[mMap count]-3; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);
			DrawFrame1=NSInsetRect(mPointList[x+1],5,5);
			DrawFrame2=NSInsetRect(mPointList[x+2],5,5);
			DrawFrame3=NSInsetRect(mPointList[x+3],5,5);

			k[0] = DrawFrame1.origin.x * DrawFrame1.origin.x;
			k[1] = DrawFrame2.origin.x * DrawFrame2.origin.x;
			k[2] = (double) ( (double)(DrawFrame2.origin.x - mDrawFrame.origin.x) / (double)(DrawFrame2.origin.y - mDrawFrame.origin.y));
			k[3] = (double)((double)(DrawFrame3.origin.x - DrawFrame1.origin.x) /(double) (DrawFrame3.origin.y - DrawFrame1.origin.y));

			k[2] *= 2.0 * DrawFrame1.origin.x;
			k[3] *= 2.0 * DrawFrame2.origin.x;

			w = DrawFrame1.origin.y;

			Mat[0][0] = w * w * w;
			Mat[0][1] = w * w;
			Mat[0][2] = w;
			Mat[0][3] = 1.0;

			Mat[2][0] = 3.0 * w * w;
			Mat[2][1] = 2.0 * w;
			Mat[2][2] = 1.0;
			Mat[2][3] = 0.0;

			w = DrawFrame2.origin.y;

			Mat[1][0] = w * w * w;
			Mat[1][1] = w * w;
			Mat[1][2] = w;
			Mat[1][3] = 1.0;

			Mat[3][0] = 3.0 * w * w;
			Mat[3][1] = 2.0 * w;
			Mat[3][2] = 1.0;
			Mat[3][3] = 0.0;

			if ( MInvers2(Mat, Mat))
			continue;

			/* Calculate coefficients of cubic patch. */
			A = k[0] * Mat[0][0] + k[1] * Mat[0][1] + k[2] * Mat[0][2] + k[3] * Mat[0][3];
			B = k[0] * Mat[1][0] + k[1] * Mat[1][1] + k[2] * Mat[1][2] + k[3] * Mat[1][3];
			C = k[0] * Mat[2][0] + k[1] * Mat[2][1] + k[2] * Mat[2][2] + k[3] * Mat[2][3];
			D = k[0] * Mat[3][0] + k[1] * Mat[3][1] + k[2] * Mat[3][2] + k[3] * Mat[3][3];
			BOOL FirstLine=YES;
			double Tx,Ty;

			for ( double T=DrawFrame1.origin.y; T<=DrawFrame2.origin.y; T+=(double)((double)(DrawFrame2.origin.y-DrawFrame1.origin.y))/CubicSteps)
			{
				Tx = sqrt((T*T*T*A)+(B*T*T)+(C*T)+D);
				if (std::isnan(Tx)) // division by zero, restore to 0.0 to avoid crash
				{
					Tx=0.0;
				}
				Ty = T;
				if ( FirstLine)
				{
					[b moveToPoint: NSMakePoint(Tx,Ty)];
					FirstLine=NO;
				}
				else
					[b lineToPoint:NSMakePoint(Tx,Ty)];
			}
			[b lineToPoint:NSMakePoint(DrawFrame2.origin.x,DrawFrame2.origin.y)];
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

//---------------------------------------------------------------------
// drawLathe
//---------------------------------------------------------------------
-(void) drawLathe;
{
	[self drawPrism];
}

//---------------------------------------------------------------------
// drawBezier
//---------------------------------------------------------------------
-(void) drawBezier
{
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];
	if (	([mMap buttonState:cSplineTypePopUp] ==cLinearSpline || [mMap buttonState:cSplineTypePopUp] ==cBezierSpline )&& [mMap buttonState:cCurveButton]==NSOnState)
	{
	
		BOOL FirstLine=YES;
		[[NSColor blueColor]set];
		for (NSUInteger x=0; x<[mMap count]; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);

			if ([mMap buttonState:cSplineTypePopUp] ==cLinearSpline)
			{
				if ( FirstLine)
				{
					[b moveToPoint: NSMakePoint(mDrawFrame.origin.x,mDrawFrame.origin.y)];
					FirstLine=NO;
				}
				else
					[b lineToPoint: NSMakePoint(mDrawFrame.origin.x,mDrawFrame.origin.y)];
			}
			else if ((x+1==1 ||  ((x+1)%4==1)))
			{
				double U=0.0;
				double c[4][2];
				for (NSInteger y=x,t=0; y<=x+3; y++,t++)
				{
					NSRect tempRect=NSInsetRect(mPointList[y],5,5);
					c[t][0]=tempRect.origin.x;
					c[t][1]=tempRect.origin.y;
				}
				BOOL firstdot=YES;
				for ( int teller=1; teller<=BezierSteps; teller++, U+=(1.0/(BezierStepsF-1.0)))
				{
					double px=(c[0][0]*pow(1-U,3) + c[1][0]*3*U*pow(1-U,2) + c[2][0]*3*(1-U)*pow(U,2) +c[3][0]*pow(U,3));
					double py=(c[0][1]*pow(1-U,3) + c[1][1]*3*U*pow(1-U,2) + c[2][1]*3*(1-U)*pow(U,2) + c[3][1]*pow(U,3));
					if ( firstdot)
					{
						[b moveToPoint: NSMakePoint(px,py)];
						firstdot=NO;
					}
					else
						[b lineToPoint: NSMakePoint(px,py)];
				}
			}
		}
		[b stroke];
		[b removeAllPoints];
	}
}

//---------------------------------------------------------------------
// drawQubicQuadratic
//---------------------------------------------------------------------
-(void) drawQubicQuadratic
{
	NSRect DrawFrame1,DrawFrame2,DrawFrame3;
	[[NSColor blueColor]set];
	NSBezierPath *b=[NSBezierPath bezierPath];
	[b setLineWidth:1];

	if ( [mMap buttonState:cCurveButton]==NSOnState && [mMap buttonState:cSplineTypePopUp] ==cQuadraticSpline)
	{
		for (NSUInteger x=0; x<[mMap count]-2; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);
			DrawFrame1=NSInsetRect(mPointList[x+1],5,5);
			DrawFrame2=NSInsetRect(mPointList[x+2],5,5);
			double A =  0.0;
			double B =  0.5 * mDrawFrame.origin.x - 1.0 * DrawFrame1.origin.x + 0.5 * DrawFrame2.origin.x;
			double C = -0.5 * mDrawFrame.origin.x + 0.5 * DrawFrame2.origin.x;
			double D = 1.0 * DrawFrame1.origin.x;

			double A2 =  0.0;
			double B2 =  0.5 * mDrawFrame.origin.y - 1.0 * DrawFrame1.origin.y + 0.5 * DrawFrame2.origin.y;
			double C2 = -0.5 * mDrawFrame.origin.y + 0.5 * DrawFrame2.origin.y;
			double D2 = 1.0 * DrawFrame1.origin.y;
			BOOL FirstLine=YES;
			double Tx,Ty;
			for ( double T=0.0; T<=1.0; T+=(1.0/CubicSteps))
			{
				Tx = A*T*T*T+B*T*T+C*T+D;
				Ty = A2*T*T*T+B2*T*T+C2*T+D2;
				if ( FirstLine)
				{
					[b moveToPoint: NSMakePoint(Tx,Ty)];
					FirstLine=NO;
				}
				else
					[b lineToPoint:NSMakePoint(Tx,Ty)];
			}
			[b lineToPoint:NSMakePoint(DrawFrame2.origin.x,DrawFrame2.origin.y)];
		}
		[b stroke];
		[b removeAllPoints];
	}
	else if ( [mMap buttonState:cCurveButton]==NSOnState && [mMap buttonState:cSplineTypePopUp] ==cCubicSpline)
	{
		for (NSUInteger x=0; x<[mMap count]-3; x++)
		{
			mDrawFrame=NSInsetRect(mPointList[x],5,5);
			DrawFrame1=NSInsetRect(mPointList[x+1],5,5);
			DrawFrame2=NSInsetRect(mPointList[x+2],5,5);
			DrawFrame3=NSInsetRect(mPointList[x+3],5,5);

			double A = -0.5 * mDrawFrame.origin.x + 1.5 * DrawFrame1.origin.x- 1.5 * DrawFrame2.origin.x + 0.5 *DrawFrame3.origin.x;
			double B =    	    mDrawFrame.origin.x - 2.5 * DrawFrame1.origin.x + 2.0 * DrawFrame2.origin.x - 0.5 * DrawFrame3.origin.x;
			double C = -0.5 * mDrawFrame.origin.x                  + 0.5 * DrawFrame2.origin.x;
			double D =           DrawFrame1.origin.x;

			double A2 = -0.5 * mDrawFrame.origin.y + 1.5 * DrawFrame1.origin.y- 1.5 * DrawFrame2.origin.y + 0.5 *DrawFrame3.origin.y;
			double B2 =      	  mDrawFrame.origin.y - 2.5 * DrawFrame1.origin.y + 2.0 * DrawFrame2.origin.y - 0.5 * DrawFrame3.origin.y;
			double C2 = -0.5 * mDrawFrame.origin.y                  + 0.5 * DrawFrame2.origin.y;
			double D2 =            DrawFrame1.origin.y;



			BOOL FirstLine=YES;
			double Tx,Ty;
			for ( double T=0.0; T<=1.0; T+=(1.0/CubicSteps))
			{
				Tx = A*T*T*T+B*T*T+C*T+D;
				Ty = A2*T*T*T+B2*T*T+C2*T+D2;
				if ( FirstLine)
				{
					[b moveToPoint: NSMakePoint(Tx,Ty)];
					FirstLine=NO;
				}
				else
					[b lineToPoint:NSMakePoint(Tx,Ty)];
			}
			[b lineToPoint:NSMakePoint(DrawFrame2.origin.x,DrawFrame2.origin.y)];
		}
		[b stroke];
		[b removeAllPoints];
	}

}


@end

static  BOOL MInvers2(myMatrix r,myMatrix m)
{
  double d00, d01, d02, d03;
  double d10, d11, d12, d13;
  double d20, d21, d22, d23;
  double d30, d31, d32, d33;
  double m00, m01, m02, m03;
  double m10, m11, m12, m13;
  double m20, m21, m22, m23;
  double m30, m31, m32, m33;
  double D;

  m00 = m[0][0];  m01 = m[0][1];  m02 = m[0][2];  m03 = m[0][3];
  m10 = m[1][0];  m11 = m[1][1];  m12 = m[1][2];  m13 = m[1][3];
  m20 = m[2][0];  m21 = m[2][1];  m22 = m[2][2];  m23 = m[2][3];
  m30 = m[3][0];  m31 = m[3][1];  m32 = m[3][2];  m33 = m[3][3];

  d00 = m11*m22*m33 + m12*m23*m31 + m13*m21*m32 - m31*m22*m13 - m32*m23*m11 - m33*m21*m12;
  d01 = m10*m22*m33 + m12*m23*m30 + m13*m20*m32 - m30*m22*m13 - m32*m23*m10 - m33*m20*m12;
  d02 = m10*m21*m33 + m11*m23*m30 + m13*m20*m31 - m30*m21*m13 - m31*m23*m10 - m33*m20*m11;
  d03 = m10*m21*m32 + m11*m22*m30 + m12*m20*m31 - m30*m21*m12 - m31*m22*m10 - m32*m20*m11;

  d10 = m01*m22*m33 + m02*m23*m31 + m03*m21*m32 - m31*m22*m03 - m32*m23*m01 - m33*m21*m02;
  d11 = m00*m22*m33 + m02*m23*m30 + m03*m20*m32 - m30*m22*m03 - m32*m23*m00 - m33*m20*m02;
  d12 = m00*m21*m33 + m01*m23*m30 + m03*m20*m31 - m30*m21*m03 - m31*m23*m00 - m33*m20*m01;
  d13 = m00*m21*m32 + m01*m22*m30 + m02*m20*m31 - m30*m21*m02 - m31*m22*m00 - m32*m20*m01;

  d20 = m01*m12*m33 + m02*m13*m31 + m03*m11*m32 - m31*m12*m03 - m32*m13*m01 - m33*m11*m02;
  d21 = m00*m12*m33 + m02*m13*m30 + m03*m10*m32 - m30*m12*m03 - m32*m13*m00 - m33*m10*m02;
  d22 = m00*m11*m33 + m01*m13*m30 + m03*m10*m31 - m30*m11*m03 - m31*m13*m00 - m33*m10*m01;
  d23 = m00*m11*m32 + m01*m12*m30 + m02*m10*m31 - m30*m11*m02 - m31*m12*m00 - m32*m10*m01;

  d30 = m01*m12*m23 + m02*m13*m21 + m03*m11*m22 - m21*m12*m03 - m22*m13*m01 - m23*m11*m02;
  d31 = m00*m12*m23 + m02*m13*m20 + m03*m10*m22 - m20*m12*m03 - m22*m13*m00 - m23*m10*m02;
  d32 = m00*m11*m23 + m01*m13*m20 + m03*m10*m21 - m20*m11*m03 - m21*m13*m00 - m23*m10*m01;
  d33 = m00*m11*m22 + m01*m12*m20 + m02*m10*m21 - m20*m11*m02 - m21*m12*m00 - m22*m10*m01;

  D = m00*d00 - m01*d01 + m02*d02 - m03*d03;
  if (D == 0.0)
  {
    return YES; //("Singular matrix in MInvers2.\n");
  }


  r[0][0] =  d00/D; r[0][1] = -d10/D;  r[0][2] =  d20/D; r[0][3] = -d30/D;
  r[1][0] = -d01/D; r[1][1] =  d11/D;  r[1][2] = -d21/D; r[1][3] =  d31/D;
  r[2][0] =  d02/D; r[2][1] = -d12/D;  r[2][2] =  d22/D; r[2][3] = -d32/D;
  r[3][0] = -d03/D; r[3][1] =  d13/D;  r[3][2] = -d23/D; r[3][3] =  d33/D;
	return NO;
}

