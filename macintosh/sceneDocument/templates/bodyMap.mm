//******************************************************************************
///
/// @file /macintosh/sceneDocument/templates/bodyMap.mm
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
//********************************************************************************
#import "bodyMap.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cLocationIndex=0,
	cIdentifierIndex=1
	};


@implementation bodymap

//---------------------------------------------------------------------
// defaultMap
//---------------------------------------------------------------------
+(id) defaultMap
{
	bodymap *c=[[bodymap alloc] init];
	[c makeDefaultMap];
	[c autorelease];
	return c;
}

//---------------------------------------------------------------------
// textureMap
//---------------------------------------------------------------------
+(id) textureMap
{
	bodymap *c=[[bodymap alloc] init];
	[c makeTextureMap];
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
				//location											//identifier
				[NSNumber numberWithFloat:0.0],  @"granite", nil ],
			[NSMutableArray arrayWithObjects:
				//location											//identifier
				[NSNumber numberWithFloat:1.0], 	@"boxed", nil ],
		nil]
	];

}

//---------------------------------------------------------------------
// makeTextureMap
//---------------------------------------------------------------------
-(void) makeTextureMap
{
	[self setArray:
		[NSMutableArray arrayWithObjects:
			[NSMutableArray arrayWithObjects:
				//location											//identifier
				[NSNumber numberWithFloat:0.0],  @"pigment { granite }", nil ],
			[NSMutableArray arrayWithObjects:
				//location											//identifier
				[NSNumber numberWithFloat:1.0], 	@"pigment { boxed }", nil ],
		nil]
	];

}


//---------------------------------------------------------------------
// locationAtIndex
//---------------------------------------------------------------------
-(NSString *) locationAtIndex:(NSUInteger) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	return 	[NSString stringWithFormat:FloatFormat,[[entry objectAtIndex:cLocationIndex]floatValue]];
}
//---------------------------------------------------------------------
// locationValueAtIndex
//---------------------------------------------------------------------
-(float ) locationValueAtIndex:(NSUInteger) index
{
	return [[self locationAtIndex:index]floatValue];
}

//---------------------------------------------------------------------
// identifierAtIndex
//---------------------------------------------------------------------
-(id) identifierAtIndex:(NSUInteger) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	return 	[entry objectAtIndex:cIdentifierIndex];
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
		locationTop=[[topArray objectAtIndex:cLocationIndex]floatValue];
	}
	
	NSMutableArray *endArray=[mMapArray objectAtIndex:index];
	locationEnd=[[endArray objectAtIndex:cLocationIndex]floatValue];
	
	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
		[NSString stringWithFormat:FloatFormat,locationTop+(locationEnd-locationTop)/2.0],
		@"",
		nil];
	[mMapArray insertObject:newArray atIndex:index];
}

//---------------------------------------------------------------------
// addEntry
//---------------------------------------------------------------------
-(void) addEntry
{
	NSMutableArray *old=[mMapArray objectAtIndex:[self count]-1];
	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
											[[[old objectAtIndex:cLocationIndex]copy]autorelease],
											[[[old objectAtIndex:cIdentifierIndex]copy]autorelease],
											nil];
	[mMapArray addObject:newArray];
}

//---------------------------------------------------------------------
// setLocation: atIndex
//---------------------------------------------------------------------
-(void) setLocation:(NSString *)location atIndex:(NSUInteger) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	[entry replaceObjectAtIndex:cLocationIndex withObject:location];
}

//---------------------------------------------------------------------
// setLocation: atIndex
//---------------------------------------------------------------------
-(void) setIdentifier:(NSString *)identifier atIndex:(NSUInteger) index
{
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	[entry replaceObjectAtIndex:cIdentifierIndex withObject:identifier];
}

#define EncodedBodyMap @"POVBodyMap"

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[super encodeWithCoder:encoder];
	if ([encoder allowsKeyedCoding]) {
		[encoder encodeObject:mMapArray forKey:EncodedBodyMap];
	} else {
	[encoder encodeObject:mMapArray];
	}
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	if (self = [super initWithCoder:decoder]) {
		if ([decoder allowsKeyedCoding] && [decoder containsValueForKey:EncodedBodyMap]) {
			[self setArray:[decoder decodeObjectForKey:EncodedBodyMap]];
		} else {
	[self setArray:[decoder decodeObject]];
		}
	}
	return self;
}


@end
