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
#import "colormap.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation ColorCell
-(BOOL) isGrayScale
{
	return mUseGrayScale;
}
-(void) setIsGrayScale:(BOOL) is
{
	mUseGrayScale=is;
}

- (void) drawWithFrame: (NSRect) cellFrame inView: (NSView*) controlView 
{
	NSRect square = NSInsetRect (cellFrame, 0.5, 0.5);	// move in half a point to put the lines on even point boundries
	
	// draw a black border around the color
	[[NSColor blackColor] set];
	[NSBezierPath strokeRect: square];

	// inset the color 2 points from the border and draw it
	if ( [self isGrayScale]==YES)
	{
		float grayValue=[[self objectValue] redComponent]*0.297 +
								[[self objectValue] greenComponent]*0.589 +
								[[self objectValue] blueComponent]*0.114;
																				 
		NSColor *newColor=[NSColor colorWithCalibratedRed:grayValue green:grayValue	 blue:grayValue	alpha:1.0];
		[newColor drawSwatchInRect: NSInsetRect (square, 2.0, 2.0)];	// as per Scott Anguish
	}
	else
		[(NSColor*) [self objectValue] drawSwatchInRect: NSInsetRect (square, 2.0, 2.0)];	// as per Scott Anguish
	
}

@end

@implementation colormap

//---------------------------------------------------------------------
// standardMapWithView
//---------------------------------------------------------------------
+(id) standardMapWithView:(id)view
{
	colormap *c=[[colormap alloc] init];
	[c makeDefaultMap];
	[c setPreview:view];
	[c autorelease];
	return c;
}
//---------------------------------------------------------------------
// rainbowMapWithView
//---------------------------------------------------------------------
+(id) rainbowMapWithView:(id)view
{
	colormap *c=[[colormap alloc] init];
	[c makeRainbowMap];
	[c setPreview:view];
	[c autorelease];
	return c;
}
//---------------------------------------------------------------------
// blackAndWhiteMapWithView
//---------------------------------------------------------------------
+(id) blackAndWhiteMapWithView:(id)view
{
	colormap *c=[[colormap alloc] init];
	[c makeBlackAndWhiteMap];
	[c setPreview:view];
	[c autorelease];
	return c;
}	

//---------------------------------------------------------------------
// makeDefaultMap
//---------------------------------------------------------------------
// creates a default map from white to red
// from 0.0 to 1.0
//---------------------------------------------------------------------
-(void) makeDefaultMap
{

	[self setArray:
		[NSMutableArray arrayWithObjects:
			[NSMutableArray arrayWithObjects:
				//location											//color
				[NSNumber numberWithFloat:0.0], 	[[NSColor whiteColor]colorUsingColorSpaceName:NSCalibratedRGBColorSpace], 	
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location											//color
				[NSNumber numberWithFloat:1.0], 	[[NSColor redColor]colorUsingColorSpaceName:NSCalibratedRGBColorSpace], 	
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
		nil]
	];

	mFilterOn=NSOffState;
	mTransmitOn=NSOffState;
	mUseGrayColorOn=NSOffState;
	[self setViewDirty];
}

//---------------------------------------------------------------------
// makeBlackAndWhiteMap
//---------------------------------------------------------------------
// creates a default b@w map
//---------------------------------------------------------------------

-(void) makeBlackAndWhiteMap
{
	[self setArray:
		[NSMutableArray arrayWithObjects:
			[NSMutableArray arrayWithObjects:
				//location											//color
				[NSNumber numberWithFloat:0.0], 	[[NSColor whiteColor]colorUsingColorSpaceName:NSCalibratedRGBColorSpace], 	
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location											//color
				[NSNumber numberWithFloat:1.0], 	[[NSColor blackColor]colorUsingColorSpaceName:NSCalibratedRGBColorSpace], 	
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
		nil]
	];
	mFilterOn=NSOffState;
	mTransmitOn=NSOffState;
	mUseGrayColorOn=NSOffState;
	[self setViewDirty];

}

//---------------------------------------------------------------------
// makeRainbowMap
//---------------------------------------------------------------------
// creates a default rainbow map
//---------------------------------------------------------------------
-(void) makeRainbowMap
{
	[self setArray:
		[NSMutableArray arrayWithObjects:
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.000], 	[NSColor colorWithCalibratedRed:1.0 green:0.5 blue:1.0 alpha:1.0], 	//violet
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.100], 	[NSColor colorWithCalibratedRed:1.0 green:0.5 blue:1.0 alpha:1.0], 	//violet2
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.214], 	[NSColor colorWithCalibratedRed:0.5 green:0.5 blue:1.0 alpha:1.0], 	//indigo
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.328], 	[NSColor colorWithCalibratedRed:0.2 green:0.2 blue:1.0 alpha:1.0], 	//blue
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.442], 	[NSColor colorWithCalibratedRed:0.2 green:1.0 blue:1.0 alpha:1.0], 	//cyan
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.556], 	[NSColor colorWithCalibratedRed:0.2 green:1.0 blue:0.2 alpha:1.0], 	//green
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.670], 	[NSColor colorWithCalibratedRed:1.0 green:1.0 blue:0.2 alpha:1.0], 	//yellow
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.784], 	[NSColor colorWithCalibratedRed:1.0 green:0.5 blue:0.2 alpha:1.0], 	//orange
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:0.900], 	[NSColor colorWithCalibratedRed:1.0 green:0.2 blue:0.2 alpha:1.0], 	//red1
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
			[NSMutableArray arrayWithObjects:
				//location
				[NSNumber numberWithFloat:1.000], 	[NSColor colorWithCalibratedRed:1.0 green:0.2 blue:0.2 alpha:1.0], 	//red2
				[NSNumber numberWithFloat:0.0], 	[NSNumber numberWithFloat:0.0],	nil],
		nil]
	];
	mFilterOn=NSOffState;
	mTransmitOn=NSOffState;
	mUseGrayColorOn=NSOffState;
	[self setViewDirty];

}

//---------------------------------------------------------------------
// replaceEntryAtIndex:withObject
//---------------------------------------------------------------------
-(void)replaceEntryAtIndex:(unsigned int) index withObject:(NSColor *) color
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	[entry replaceObjectAtIndex:cColormapColorIndex withObject:color];
	[self setViewDirty];
}



//---------------------------------------------------------------------
// redAtIndex
//---------------------------------------------------------------------
-(NSString *) redAtIndex:(unsigned int) index
{
	NSColor *cl=[self objectAtRow: index atColumn:cColormapColorIndex];
	return [NSString stringWithFormat:FloatFormat,[cl redComponent]];
}

//---------------------------------------------------------------------
// greenAtIndex
//---------------------------------------------------------------------
-(NSString *) greenAtIndex:(unsigned int) index
{
	NSColor *cl=[self objectAtRow: index atColumn:cColormapColorIndex];
	return [NSString stringWithFormat:FloatFormat,[cl greenComponent]];
}

//---------------------------------------------------------------------
// blueAtIndex
//---------------------------------------------------------------------
-(NSString *) blueAtIndex:(unsigned int) index
{
	NSColor *cl=[self objectAtRow: index atColumn:cColormapColorIndex];
	return [NSString stringWithFormat:FloatFormat,[cl blueComponent]];
}

//---------------------------------------------------------------------
// insertEntryAtIndex
//---------------------------------------------------------------------
-(void) insertEntryAtIndex:(int)index
{
	float locationTop,redTop, greenTop, blueTop, filterTop,transmitTop;
	float locationEnd,redEnd, greenEnd, blueEnd, filterEnd,transmitEnd;
	if ( index <0)
		return;
		
	int entries=[self count];
	if ( index+1 > entries)
		index--;
		
	if (index == 0)	//insert before first entry
		locationTop=redTop=greenTop=blueTop=filterTop=transmitTop=0.0;
	else
	{
		NSMutableArray *topArray=[mMapArray objectAtIndex:index-1];
		locationTop=[[topArray objectAtIndex:cColormapLocationIndex]floatValue];
		filterTop=[[topArray objectAtIndex:cColormapFilterIndex]floatValue];
		transmitTop=[[topArray objectAtIndex:cColormapTransmitIndex]floatValue];
		NSColor *topColor=[topArray objectAtIndex:cColormapColorIndex];
		redTop=[topColor redComponent];
		greenTop=[topColor greenComponent];
		blueTop=[topColor blueComponent];
	}
//	NSLog(@"top green: %f",greenTop);
	
	NSMutableArray *endArray=[mMapArray objectAtIndex:index];
	locationEnd=[[endArray objectAtIndex:cColormapLocationIndex]floatValue];
	filterEnd=[[endArray objectAtIndex:cColormapFilterIndex]floatValue];
	transmitEnd=[[endArray objectAtIndex:cColormapTransmitIndex]floatValue];
	NSColor *endColor=[endArray objectAtIndex:cColormapColorIndex];
	redEnd=[endColor redComponent];
	greenEnd=[endColor greenComponent];
	blueEnd=[endColor blueComponent];
//	NSLog(@"end green:%f",greenEnd);
	
	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
		[NSString stringWithFormat:FloatFormat,locationTop+(locationEnd-locationTop)/2.0],
		[NSColor colorWithCalibratedRed:redTop+(redEnd-redTop)/2.0  green:greenTop+(greenEnd-greenTop)/2.0	 blue:blueTop+(blueEnd-blueTop)/2.0	alpha:1.0],
		[NSString stringWithFormat:FloatFormat,filterTop+(filterEnd-filterTop)/2.0],
		[NSString stringWithFormat:FloatFormat,transmitTop+(transmitEnd-transmitTop)/2.0],
		nil];
	[mMapArray insertObject:newArray atIndex:index];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// addEntry
//---------------------------------------------------------------------
-(void) addEntry
{
	NSMutableArray *old=[mMapArray objectAtIndex:[self count]-1];
	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
											[[[old objectAtIndex:cColormapLocationIndex]copy]autorelease],
											[[[old objectAtIndex:cColormapColorIndex]copy]autorelease],
											[[[old objectAtIndex:cColormapFilterIndex]copy]autorelease],
											[[[old objectAtIndex:cColormapTransmitIndex]copy]autorelease],
											nil];
	[mMapArray addObject:newArray];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// setRed:atIndex
//---------------------------------------------------------------------
-(void) setRed:(NSString *)red atIndex:(unsigned int) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	NSColor *cl=[entry objectAtIndex:cColormapColorIndex];
	NSColor *newColor=[NSColor colorWithCalibratedRed:[red floatValue] green:[cl redComponent] blue:[cl blueComponent]	alpha:1.0];
	[entry replaceObjectAtIndex:cColormapColorIndex withObject:newColor];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// setGreen:atIndex
//---------------------------------------------------------------------
-(void) setGreen:(NSString *)green atIndex:(unsigned int) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	NSColor *cl=[entry objectAtIndex:cColormapColorIndex];
	NSColor *newColor=[NSColor colorWithCalibratedRed:[cl redComponent] green:[green floatValue] blue:[cl blueComponent]	alpha:1.0];
	[entry replaceObjectAtIndex:cColormapColorIndex withObject:newColor];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// setBlue:atIndex
//---------------------------------------------------------------------
-(void) setBlue:(NSString *)blue atIndex:(unsigned int) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	NSColor *cl=[entry objectAtIndex:cColormapColorIndex];
	NSColor *newColor=[NSColor colorWithCalibratedRed:[cl redComponent] green:[cl greenComponent] blue:[blue floatValue]	alpha:1.0];
	[entry replaceObjectAtIndex:cColormapColorIndex withObject:newColor];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// setButtonState:forButton
//---------------------------------------------------------------------
-(void) setButtonState:(int) state forButton:(int)button
{
	switch ( button)
	{
		case cFilterButton:			mFilterOn=state; 	break;
		case cTransmitButton:		mTransmitOn=state;	break;
		case cGrayColorButton:	mUseGrayColorOn=state;	break;
	}
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buttonState
//---------------------------------------------------------------------
-(int) buttonState:(int)button
{
	switch ( button)
	{
		case cFilterButton:			return mFilterOn; 	break;
		case cTransmitButton:		return mTransmitOn;	break;
		case cGrayColorButton:	return mUseGrayColorOn;	break;
		default:
		return NSOffState;
	}
}

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[encoder encodeObject:mMapArray];
	[encoder encodeValueOfObjCType:@encode(int) at:&mUseGrayColorOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mFilterOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mTransmitOn];
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	[self setArray:[decoder decodeObject]];
	[decoder decodeValueOfObjCType:@encode(int) at:&mUseGrayColorOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mFilterOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mTransmitOn];
	return self;
}


@end
