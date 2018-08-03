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
	id well=[[[self alloc] init]autorelease];
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

- (BOOL)isEqual:(id)object
{
	return [self equals:object];
}

#define FilterOnStateKey @"filterOnState"
#define FilterKey @"filter"
#define TransmitOnStateKey @"transmitOnState"
#define TransmitKey @"transmit"
#define HasFilterTransmitKey @"hasFilterTransmitKey"
#define GrayOnKey @"grayOn"

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[super encodeWithCoder:encoder];
	if (encoder.allowsKeyedCoding) {
		[encoder encodeInteger:mFilterOnState forKey:FilterOnStateKey];
		[encoder encodeDouble:mFilter forKey:FilterKey];
		[encoder encodeInteger:mTransmitOnState forKey:TransmitOnStateKey];
		[encoder encodeDouble:mTransmit forKey:TransmitKey];
		[encoder encodeBool:mHasFilterTransmit forKey:HasFilterTransmitKey];
		[encoder encodeInteger:mGrayOn forKey:GrayOnKey];
	} else {
		int tmpInt = (int)mFilterOnState;
		float tmpFloat = mFilter;
		[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
		[encoder encodeValueOfObjCType:@encode(float) at:&tmpFloat];
		tmpInt = (int)mTransmitOnState;
		[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
		tmpFloat = mTransmit;
		[encoder encodeValueOfObjCType:@encode(float) at:&tmpFloat];
		[encoder encodeValueOfObjCType:@encode(BOOL) at:&mHasFilterTransmit];
		tmpInt = (int)mGrayOn;
		[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
	}
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	if (self=[super initWithCoder:decoder]) {
		if (decoder.allowsKeyedCoding) {
			mFilterOnState = [decoder decodeIntegerForKey:FilterOnStateKey];
			mFilter = [decoder decodeDoubleForKey:FilterKey];
			mTransmitOnState = [decoder decodeIntegerForKey:TransmitOnStateKey];
			mTransmit = [decoder decodeDoubleForKey:TransmitKey];
			mHasFilterTransmit = [decoder decodeBoolForKey:HasFilterTransmitKey];
			mGrayOn = [decoder decodeIntegerForKey:GrayOnKey];
		} else {
			[decoder decodeValueOfObjCType:@encode(int) at:&mFilterOnState];
			[decoder decodeValueOfObjCType:@encode(float) at:&mFilter];
			[decoder decodeValueOfObjCType:@encode(int) at:&mTransmitOnState];
			[decoder decodeValueOfObjCType:@encode(float) at:&mTransmit];
			[decoder decodeValueOfObjCType:@encode(BOOL) at:&mHasFilterTransmit];
			[decoder decodeValueOfObjCType:@encode(int) at:&mGrayOn];
		}
	}
	return self;
}
//---------------------------------------------------------------------
// withColor
//---------------------------------------------------------------------
+(id) withColor:(NSColor*) color andFilter:(BOOL)filter
{
	id well=[[[self alloc] init]autorelease];
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
-(void) clearFilterTransmit
{
	mFilter=0.0;
	mTransmit=0.0;
	mTransmitOnState=NSOffState;
	mFilterOnState=NSOffState;
}

//---------------------------------------------------------------------
// whiteColor
//---------------------------------------------------------------------
+(id) whiteColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor whiteColor] andFilter:filter];
}

//---------------------------------------------------------------------
// blackColor
//---------------------------------------------------------------------
+(id) blackColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor blackColor] andFilter:filter];
}

//---------------------------------------------------------------------
// redColor
//---------------------------------------------------------------------
+(id) redColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor redColor] andFilter:filter];
}

//---------------------------------------------------------------------
// blueColor
//---------------------------------------------------------------------
+(id) blueColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor blueColor] andFilter:filter];
}


//---------------------------------------------------------------------
// cyanColor
//---------------------------------------------------------------------
+(id) cyanColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor cyanColor] andFilter:filter];
}

//---------------------------------------------------------------------
// magentaColor
//---------------------------------------------------------------------
+(id) magentaColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor magentaColor] andFilter:filter];
}

//---------------------------------------------------------------------
// yellowColorAndFilter
//---------------------------------------------------------------------
+(id) yellowColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor yellowColor] andFilter:filter];
}




//---------------------------------------------------------------------
// greenColor
//---------------------------------------------------------------------
+(id) greenColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor greenColor] andFilter:filter];
}

//---------------------------------------------------------------------
// grayColor
//---------------------------------------------------------------------
+(id) grayColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor grayColor] andFilter:filter];
}

//---------------------------------------------------------------------
// lightGrayColor
//---------------------------------------------------------------------
+(id) lightGrayColorAndFilter:(BOOL)filter
{
	return [self withColor:[NSColor lightGrayColor] andFilter:filter];
}

//---------------------------------------------------------------------
// colorWithCalibratedRed
//---------------------------------------------------------------------
+ (id)colorWithCalibratedRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha filter:(BOOL)filter
{
	return [self withColor:[NSColor colorWithCalibratedRed:red	green:green	blue:blue	alpha:alpha]andFilter:filter];
}

//---------------------------------------------------------------------
// hasFilterTransmit
//---------------------------------------------------------------------
@synthesize hasFilterTransmit=mHasFilterTransmit;

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
@synthesize filterOn=mFilterOnState;

//---------------------------------------------------------------------
// filter
//---------------------------------------------------------------------
@synthesize filter=mFilter;

//---------------------------------------------------------------------
// transmitOn
//---------------------------------------------------------------------
@synthesize transmitOn=mTransmitOnState;


//---------------------------------------------------------------------
// mTransmit
//---------------------------------------------------------------------
@synthesize transmit=mTransmit;

//---------------------------------------------------------------------
// grayOn
//---------------------------------------------------------------------
@synthesize grayOn=mGrayOn;

//---------------------------------------------------------------------
// setFilter:toState
//---------------------------------------------------------------------
-(void) setFilter:(CGFloat)filter toState:(NSControlStateValue)filterOn andTransmit:(CGFloat)transmit toState:(NSControlStateValue)transmitOn
{
	mFilter=filter;
	mFilterOnState=filterOn;
	mTransmit=transmit;
	mTransmitOnState=transmitOn;
}


@end
