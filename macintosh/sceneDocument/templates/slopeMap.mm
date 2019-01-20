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
#import "slopeMap.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation slopemap

//---------------------------------------------------------------------
// standardMapWithView
//---------------------------------------------------------------------
+(id) standardMapWithView:(id)view
{
	slopemap *c=[[slopemap alloc] init];
	[c makeDefaultMap];
	[c setPreview:view];
	[c autorelease];
	return c;
}

//---------------------------------------------------------------------
// makeDefaultMap
//---------------------------------------------------------------------
-(void) makeDefaultMap
{
	[self setArray:
		[NSMutableArray arrayWithObjects:
			[NSMutableArray arrayWithObjects:
				//location											//height										//slope
				[NSNumber numberWithFloat:0.0],  [NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:0.0], nil ],
			[NSMutableArray arrayWithObjects:
				//location											//height										//slope
				[NSNumber numberWithFloat:1.0],  [NSNumber numberWithFloat:1.0],[NSNumber numberWithFloat:0.0], nil ],
		nil]
	];
	mSlopeOn=NSOnState;
	mPointOn=NSOnState;
	mCurveOn=NSOnState;
	mRasterOn=NSOnState;
	[self setViewDirty];
}



//---------------------------------------------------------------------
// insertEntryAtIndex
//---------------------------------------------------------------------
-(void) insertEntryAtIndex:(NSInteger)index
{
	CGFloat locationTop;
	CGFloat locationEnd;

	if ( index <0)
		return;
		
	NSInteger entries=[self count];
	if ( index+1 > entries)
		index--;
		
	if (index == 0)	//insert before first entry
		locationTop=0.0;
	else
	{
		NSMutableArray *topArray=[mMapArray objectAtIndex:index-1];
		locationTop=[[topArray objectAtIndex:cSlopemapLocationIndex]floatValue];
	}
	
	NSMutableArray *endArray=[mMapArray objectAtIndex:index];
	locationEnd=[[endArray objectAtIndex:cSlopemapLocationIndex]floatValue];
	
	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
		[NSString stringWithFormat:FloatFormat,locationTop+(locationEnd-locationTop)/2.0],
		@"1.0",
		@"1.0",
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
											[[[old objectAtIndex:cSlopemapLocationIndex]copy]autorelease],
											[[[old objectAtIndex:cSlopemapHeightIndex]copy]autorelease],
											[[[old objectAtIndex:cSlopemapSlopeIndex]copy]autorelease],
											nil];
	[mMapArray addObject:newArray];
	[self setViewDirty];
}


	
//---------------------------------------------------------------------
// setButtonState:forButton
//---------------------------------------------------------------------
-(void) setButtonState:(NSControlStateValue) state forButton:(NSInteger)button
{
	switch ( button)
	{
		case cSlopeButton:	mSlopeOn=state; 	break;
		case cPointButton:	mPointOn=state;		break;
		case cCurveButton:	mCurveOn=state;		break;
		case cRasterButton:	mRasterOn=state;	break;
	}
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buttonState
//---------------------------------------------------------------------
-(NSControlStateValue) buttonState:(NSInteger)button
{
	switch ( button)
	{
		case cSlopeButton:		return mSlopeOn; 	break;
		case cPointButton:		return mPointOn;	break;
		case cCurveButton:		return mCurveOn;	break;
		case cRasterButton:	return mRasterOn;	break;
		default:
		return NSOffState;
	}
}

#define EncodedMapArray @"POVMapArray"
#define EncodedSlopeOn @"POVSlopeOn"
#define EncodedPointOn @"POVPointOn"
#define EncodedRasterOn @"POVRasterOn"
#define EncodedCurveOn @"POVCurveOn"

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	if ([encoder allowsKeyedCoding]) {
		[encoder encodeObject:mMapArray forKey:EncodedMapArray];
		[encoder encodeInteger:mSlopeOn forKey:EncodedSlopeOn];
		[encoder encodeInteger:mPointOn forKey:EncodedPointOn];
		[encoder encodeInteger:mRasterOn forKey:EncodedRasterOn];
		[encoder encodeInteger:mCurveOn forKey:EncodedCurveOn];
	} else {
	int tmpInt;
	[encoder encodeObject:mMapArray];
	[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
	mSlopeOn = tmpInt;
	[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
	mPointOn = tmpInt;
	[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
	mRasterOn = tmpInt;
	[encoder encodeValueOfObjCType:@encode(int) at:&tmpInt];
	mCurveOn = tmpInt;
	}
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	if (self = [super init]) {
		if ([decoder allowsKeyedCoding] && [decoder containsValueForKey:EncodedMapArray]) {
			[self setArray:[decoder decodeObjectForKey:EncodedMapArray]];
			mSlopeOn = [decoder decodeIntegerForKey:EncodedSlopeOn];
			mPointOn = [decoder decodeIntegerForKey:EncodedPointOn];
			mRasterOn = [decoder decodeIntegerForKey:EncodedRasterOn];
			mCurveOn = [decoder decodeIntegerForKey:EncodedCurveOn];
		} else {
			int tmpInt;
			[self setArray:[decoder decodeObject]];
			tmpInt = (int)mSlopeOn;
			[decoder decodeValueOfObjCType:@encode(int) at:&tmpInt];
			tmpInt = (int)mPointOn;
			[decoder decodeValueOfObjCType:@encode(int) at:&tmpInt];
			tmpInt = (int)mRasterOn;
			[decoder decodeValueOfObjCType:@encode(int) at:&tmpInt];
			tmpInt = (int)mCurveOn;
			[decoder decodeValueOfObjCType:@encode(int) at:&tmpInt];
			[self setSelectedRow:dNoRowSelected];
		}
	}
	return self;
}


@end
