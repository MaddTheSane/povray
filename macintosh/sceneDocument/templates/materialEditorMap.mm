//******************************************************************************
///
/// @file <File Name>
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
#import "materialEditorMap.h"



@implementation materialEditorMap		//from MapBase

//---------------------------------------------------------------------
// standardMap
//---------------------------------------------------------------------
+(id) standardMap
{
	materialEditorMap *c=[[materialEditorMap alloc] init];
	[c makeDefaultMap];
	[c autorelease];
	return c;
}

//---------------------------------------------------------------------
// makeDefaultMap
//---------------------------------------------------------------------
-(void) makeDefaultMap
{
	[self setArray:
		// crate a layer array
		[NSMutableArray arrayWithObject:
			[self makeDefaultEntry]
		]
	];
}

//---------------------------------------------------------------------
// makeDefaultEntry
//---------------------------------------------------------------------
-(NSMutableArray*) makeDefaultEntry
{
	return [NSMutableArray arrayWithObjects:
				@"default layer",																	//layer name
				[NSNumber numberWithInt:NSOnState],								//layer on?
				[NSNumber numberWithInt:NSOnState],								//pigmentOn,
				[NSNumber numberWithInt:NSOnState],								//normalOn,
				[NSNumber numberWithInt:NSOnState],								//finishOn,
				[NSNumber numberWithInt:NSOnState],								//interiorOn,
				[PigmentTemplate createDefaults:menuTagTemplatePigment],		//pigment
				[NormalTemplate createDefaults:menuTagTemplateNormal],		//normal
				[FinishTemplate createDefaults:menuTagTemplateFinish],				//finish
				[InteriorTemplate createDefaults:menuTagTemplateInterior],		//interior
				nil];
}



//---------------------------------------------------------------------
// insertEntryAtIndex
//---------------------------------------------------------------------
-(void) insertEntryAtIndex:(int)index
{
	[mMapArray insertObject:[self makeDefaultEntry] atIndex:index];
}

//---------------------------------------------------------------------
// addEntry
//---------------------------------------------------------------------
-(void) addEntry
{
	[mMapArray addObject:[self makeDefaultEntry]];
}

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[encoder encodeObject:mMapArray];
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	[self setArray:[decoder decodeObject]];
	return self;
}

@end
