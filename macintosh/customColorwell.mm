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
#import "customColorwell.h"

// this must be the last file included
#import "syspovdebug.h"


@implementation MPFTColorWell

- (void)drawRect:(NSRect)rect
{
	[super drawRect:rect];
	//	NSRect bd=rect;
	rect.origin.x+=10;
	rect.origin.y-=10;
	NSDictionary *tempDict= [NSDictionary dictionaryWithObjectsAndKeys:
													 [NSFont userFontOfSize:9.0], NSFontAttributeName,
													 [NSColor blackColor], NSForegroundColorAttributeName,
													 [NSColor whiteColor], NSBackgroundColorAttributeName,
													 nil];
	NSAttributedString *st=nil;

	if ( [self filterOn]==NSOnState)
	{
		st=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"F %.1f",[self filter]] attributes:tempDict];

		[st drawInRect:rect];
		[st release];
	}
	rect.origin.y-=10;

	if ( [self transmitOn]==NSOnState)
	{
		st=[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"T %.1f",[self transmit]]attributes:tempDict];

		[st drawInRect:rect];
		[st release];
	}

}

//---------------------------------------------------------------------
// withColor
//---------------------------------------------------------------------
+(id) withColor:(id) color andFilter:(BOOL)filter
{
	id well=[[[MPColorWell alloc] init]autorelease];
	if ( well)
	{
		[well setHasFilterTransmit:YES];
		[well setColor:color];
		[well clearFilterTransmit];
	}
	return well;
}
//---------------------------------------------------------------------
// hasFilterTransmit
//---------------------------------------------------------------------
-(BOOL) hasFilterTransmit
{
	return YES;
}

//---------------------------------------------------------------------
// hasFilterTransmit
//---------------------------------------------------------------------
-(void) setHasFilterTransmit:(BOOL)filter
{
}

//---------------------------------------------------------------------
// encodeWithCoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[super encodeWithCoder:encoder];
}

//---------------------------------------------------------------------
// initWithCoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	self=[super initWithCoder:decoder];
	return self;
}
@end

@implementation MPColorWell

//---------------------------------------------------------------------
// initWithCoder
//---------------------------------------------------------------------
-(BOOL) equals:(id)com
{
	BOOL ret=YES;
	NSColor *cl=[self color];
	NSColor *cl2=[com color];
	if ( [cl isEqual:cl2]==NO)
		return NO;

	if ( [self filter] != [com filter])
		return NO;

	if ( [self filterOn] != [com filterOn])
		return NO;

	if ( [self transmit] != [com transmit])
		return NO;

	if ( [self transmitOn] != [com transmitOn])
		return NO;

	if ( [self grayOn] != [com grayOn])
		return NO;

	return ret;
}

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[super encodeWithCoder:encoder];
	[encoder encodeValueOfObjCType:@encode(int) at:&mFilterOnState];
	[encoder encodeValueOfObjCType:@encode(float) at:&mFilter];
	[encoder encodeValueOfObjCType:@encode(int) at:&mTransmitOnState];
	[encoder encodeValueOfObjCType:@encode(float) at:&mTransmit];
	[encoder encodeValueOfObjCType:@encode(BOOL) at:&mHasFilterTransmit];
	[encoder encodeValueOfObjCType:@encode(int) at:&mGrayOn];
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	self=[super initWithCoder:decoder];
	[decoder decodeValueOfObjCType:@encode(int) at:&mFilterOnState];
	[decoder decodeValueOfObjCType:@encode(float) at:&mFilter];
	[decoder decodeValueOfObjCType:@encode(int) at:&mTransmitOnState];
	[decoder decodeValueOfObjCType:@encode(float) at:&mTransmit];
	[decoder decodeValueOfObjCType:@encode(BOOL) at:&mHasFilterTransmit];
	[decoder decodeValueOfObjCType:@encode(int) at:&mGrayOn];
	return self;
}
//---------------------------------------------------------------------
// withColor
//---------------------------------------------------------------------
+(id) withColor:(id) color andFilter:(BOOL)filter
{
	id well=[[[MPColorWell alloc] init]autorelease];
	if ( well)
	{
		[well setHasFilterTransmit:filter];
		[well setColor:color];
		[well clearFilterTransmit];
	}
	return well;
}

//---------------------------------------------------------------------
// clearFilterTransmit
//---------------------------------------------------------------------
-(id) clearFilterTransmit
{
	mFilter=0.0;
	mTransmit=0.0;
	mTransmitOnState=NSOffState;
	mFilterOnState=NSOffState;
	return self;
}

//---------------------------------------------------------------------
// whiteColor
//---------------------------------------------------------------------
+(id) whiteColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor whiteColor] andFilter:filter];
}

//---------------------------------------------------------------------
// blackColor
//---------------------------------------------------------------------
+(id) blackColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor blackColor] andFilter:filter];
}

//---------------------------------------------------------------------
// redColor
//---------------------------------------------------------------------
+(id) redColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor redColor] andFilter:filter];
}

//---------------------------------------------------------------------
// blueColor
//---------------------------------------------------------------------
+(id) blueColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor blueColor] andFilter:filter];
}


//---------------------------------------------------------------------
// cyanColor
//---------------------------------------------------------------------
+(id) cyanColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor cyanColor] andFilter:filter];
}

//---------------------------------------------------------------------
// magentaColor
//---------------------------------------------------------------------
+(id) magentaColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor magentaColor] andFilter:filter];
}

//---------------------------------------------------------------------
// yellowColorAndFilter
//---------------------------------------------------------------------
+(id) yellowColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor yellowColor] andFilter:filter];
}




//---------------------------------------------------------------------
// greenColor
//---------------------------------------------------------------------
+(id) greenColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor greenColor] andFilter:filter];
}

//---------------------------------------------------------------------
// grayColor
//---------------------------------------------------------------------
+(id) grayColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor grayColor] andFilter:filter];
}

//---------------------------------------------------------------------
// lightGrayColor
//---------------------------------------------------------------------
+(id) lightGrayColorAndFilter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor lightGrayColor] andFilter:filter];
}

//---------------------------------------------------------------------
// colorWithCalibratedRed
//---------------------------------------------------------------------
+ (id)colorWithCalibratedRed:(float)red green:(float)green blue:(float)blue alpha:(float)alpha filter:(BOOL)filter
{
	return [MPColorWell withColor:[NSColor colorWithCalibratedRed:red	green:green	blue:blue	alpha:alpha]andFilter:filter];
}

//---------------------------------------------------------------------
// hasFilterTransmit
//---------------------------------------------------------------------
-(BOOL) hasFilterTransmit
{
	return mHasFilterTransmit;
}

//---------------------------------------------------------------------
// setHasFilterTransmit
//---------------------------------------------------------------------
-(void) setHasFilterTransmit:(BOOL)filter
{
	mHasFilterTransmit=filter;
}

//---------------------------------------------------------------------
// mouseDown
//---------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{
	if ([self isEnabled]==YES)
	{
		id target=[self target];
		SEL action=[self action];
		if ( target != nil && action != nil)
			[self sendAction:action to:target];
	}
}


//---------------------------------------------------------------------
// filterOn
//---------------------------------------------------------------------
-(int) filterOn
{
	return mFilterOnState;
}

//---------------------------------------------------------------------
// filter
//---------------------------------------------------------------------
-(float) filter
{
	return mFilter;
}

//---------------------------------------------------------------------
// transmitOn
//---------------------------------------------------------------------
-(int) transmitOn
{
	return mTransmitOnState;
}


//---------------------------------------------------------------------
// mTransmit
//---------------------------------------------------------------------
-(float) transmit
{
	return mTransmit;
}

//---------------------------------------------------------------------
// grayOn
//---------------------------------------------------------------------
-(int) grayOn
{
	return mGrayOn;
}

-(void) setGrayOn:(int)gray
{
	mGrayOn=gray;
}

//---------------------------------------------------------------------
// setFilter:toState
//---------------------------------------------------------------------
-(void) setFilter:(float)filter toState:(int)filterOn andTransmit:(float)transmit toState:(int)transmitOn
{
	mFilter=filter;
	mFilterOnState=filterOn;
	mTransmit=transmit;
	mTransmitOnState=transmitOn;
}


@end
