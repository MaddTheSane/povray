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
#import "mapBase.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation MapBase

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self =[super init];
	if ( self)
	{
		mSelectedRow=dNoRowSelected;
		[self setArray:[[[NSMutableArray alloc]init]autorelease]];
	}
	return self;
}

//---------------------------------------------------------------------
// selectTableRow:index
//---------------------------------------------------------------------
-(void) selectTableRow:(int)index
{
	[mTemplate selectTableRow:index];
}

//---------------------------------------------------------------------
// tableView
//---------------------------------------------------------------------
-(NSTableView *) tableView
{
	return [mTemplate tableView];
}

//---------------------------------------------------------------------
// selectRow: byExtendingSelection
//---------------------------------------------------------------------
- (void)selectRow:(NSUInteger)rowIndex byExtendingSelection:(BOOL)flag
{
	[mTemplate selectRow:rowIndex byExtendingSelection:flag];
}

//---------------------------------------------------------------------
// firstSelectedRow: 
//---------------------------------------------------------------------
- (int)firstSelectedRow
{
	int ret=dNoRowSelected;
	for( int x=0; x<[self count]; x++)
	{
		if ([ [self tableView] isRowSelected:x])
		{
			return x;
		}
	}
	return ret;
}

//---------------------------------------------------------------------
// reloadData
//---------------------------------------------------------------------
-(void)  reloadData
{
	[[self tableView] reloadData];
}

//---------------------------------------------------------------------
// setTemplate:owner
//---------------------------------------------------------------------
-(void) mapBaseSetTemplate:(id) owner
{
	mTemplate=owner;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self mapBaseSetTemplate:nil];
	[self setArray:nil];
	[super dealloc];
}

//---------------------------------------------------------------------
// setViewDirty
//---------------------------------------------------------------------
-(void) setViewDirty
{
	id pv=[self preview];
	if ( pv)
		if( [pv respondsToSelector:@selector(setNeedsDisplay:)])
			[pv setNeedsDisplay:YES];
}
//---------------------------------------------------------------------
// preview
//---------------------------------------------------------------------
-(id) preview
{
	return mPreview;
}

//---------------------------------------------------------------------
// setPreview
//---------------------------------------------------------------------
-(void) setPreview:(id) view
{
	mPreview=view;
	[mPreview setMap:self];
}

//---------------------------------------------------------------------
// removeEntryAtIndex
//---------------------------------------------------------------------
-(void) removeEntryAtIndex:(int)index reload:(bool)forceReload
{
	if (index <0)
		return;
	if ( index+1 >[self count])
		return;
	[mMapArray removeObjectAtIndex:index];
	[self setViewDirty];
	if (forceReload == YES)
		[self reloadData];
}

//---------------------------------------------------------------------
// count
//---------------------------------------------------------------------
-(NSUInteger) count
{
	id map=[self array];
	if ( map==nil)
		return 0;
	return [map count];
}


//---------------------------------------------------------------------
// setArray
//---------------------------------------------------------------------
-(void) setArray:(NSMutableArray*) array
{
	[mMapArray release];
	mMapArray=array;
	[mMapArray retain];
}

//---------------------------------------------------------------------
// array
//---------------------------------------------------------------------
-(id) array
{
	return mMapArray;
}

//---------------------------------------------------------------------
// archivedObjectAtIndex
//---------------------------------------------------------------------
-(NSData *) archivedObjectAtIndex:(int)index
{
	if (index > [self count])
		return nil;
	NSMutableArray *entry=[mMapArray objectAtIndex:index];
	return [NSArchiver archivedDataWithRootObject:entry];
}

//---------------------------------------------------------------------
// insertArchivedObject
//---------------------------------------------------------------------
-(void ) insertArchivedObject:(NSData *)data atIndex:(int) index
{
	id object=[NSUnarchiver unarchiveObjectWithData:data];
	if ( object)
		[[self array] insertObject:object atIndex:index];
}

//---------------------------------------------------------------------
// setSelectedRow
//---------------------------------------------------------------------
-(void) setSelectedRow:(NSInteger) row
{
	if ( [self selectedRow] != row)
	{
		mSelectedRow=row;
		[self setViewDirty];
	}
}

//---------------------------------------------------------------------
// selectedRow
//---------------------------------------------------------------------
-(NSUInteger)selectedRow
{
	return mSelectedRow;
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



//---------------------------------------------------------------------
// objectAtRow: atColumn
//---------------------------------------------------------------------
-(id) objectAtRow:(NSUInteger)row atColumn:( NSUInteger) column
{
	NSMutableArray *a=[mMapArray objectAtIndex:row];
	return 	[a objectAtIndex:column];
}

//---------------------------------------------------------------------
// intAtRow: atColumn
//---------------------------------------------------------------------
-(int) intAtRow:(NSUInteger)row atColumn:( NSUInteger) column
{
	id obj=[self objectAtRow:row atColumn:column];
	return [obj intValue];
}

//---------------------------------------------------------------------
// floatAtRow: atColumn
//---------------------------------------------------------------------
-(float) floatAtRow:(NSUInteger)row atColumn:( NSUInteger) column
{
	id obj=[self objectAtRow:row atColumn:column];
	return [obj floatValue];
}

//---------------------------------------------------------------------
// stringFromFloatWithFormat: atRow: column
//---------------------------------------------------------------------
-(id) stringFromFloatWithFormat:(NSString*)format atRow:(NSUInteger)row atColumn:( NSUInteger) column
{
	float fl=[self floatAtRow:row atColumn:column];
	return 	[NSString stringWithFormat:format,fl];
}


//---------------------------------------------------------------------
// setObject: atRow: atColumn
//---------------------------------------------------------------------
-(void) setObject:(id) objc atRow:(NSUInteger) row atColumn:(NSUInteger) column
{
	NSMutableArray *a=[mMapArray objectAtIndex:row];
	[a replaceObjectAtIndex:column withObject:objc];
}

//---------------------------------------------------------------------
// setFloat: atRow: atColumn
//---------------------------------------------------------------------
-(void) setFloat:(float)val atRow:(NSUInteger) row atColumn:(NSUInteger) column
{
	NSMutableArray *a=[mMapArray objectAtIndex:row];
	[a replaceObjectAtIndex:column withObject:[NSNumber numberWithFloat:val]];
}
//---------------------------------------------------------------------
// setInt: atRow: atColumn
//---------------------------------------------------------------------
-(void) setInt:(int)val atRow:(NSUInteger)row atColumn:(NSUInteger) column
{
	NSMutableArray *a=[mMapArray objectAtIndex:row];
	[a replaceObjectAtIndex:column withObject:[NSNumber numberWithInt:val]];
}



@end
