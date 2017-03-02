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
#import <Cocoa/Cocoa.h>
#import "mapPreview.h"
#import "standardMethods.h"

enum eSlopeButtonTags {
	cSlopeButton	=10,
	cPointButton	=20,
	cCurveButton	=30,
	cRasterButton	=40
};

@interface MapBase : NSObject <NSCoding> 
{
	NSMutableArray *mMapArray;
	id						mPreview;		//pointer
	id						mTemplate;	//slopemapTemplate, colormapTempalte,...
	int						mSelectedRow;
}
-(void)  reloadData;

-(void) mapBaseSetTemplate:(id) owner;
-(void) selectTableRow:(int)index;
-(id) init;
-(void) dealloc;
-(void) setViewDirty;
-(id) preview;
-(void) setPreview:(id) view;
-(void) removeEntryAtIndex:(int)index reload:(bool)forceReload;
-(NSUInteger) count;
-(void) setArray:(NSMutableArray*) array;
-(id) array;
-(void) setSelectedRow:(NSInteger) row;
-(NSUInteger) selectedRow;
-(int) firstSelectedRow;
- (void)selectRow:(NSUInteger)rowIndex byExtendingSelection:(BOOL)flag;

-(NSTableView *) tableView;
-(NSData *) archivedObjectAtIndex:(int)index;
-(void ) insertArchivedObject:(NSData *)data atIndex:(int) index;

//data
-(id) objectAtRow:(NSUInteger)row atColumn:( NSUInteger) column;
-(int) intAtRow:(NSUInteger)row atColumn:( NSUInteger) column;
-(float) floatAtRow:(NSUInteger)row atColumn:( NSUInteger) column;
-(id) stringFromFloatWithFormat:(NSString*)format atRow:(NSUInteger)row atColumn:( NSUInteger) column;

-(void) setObject:(id) objc atRow:(NSUInteger) row atColumn:(NSUInteger) column;
-(void) setInt:(int)val atRow:(NSUInteger)row atColumn:(NSUInteger) column;
-(void) setFloat:(float)val atRow:(NSUInteger) row atColumn:(NSUInteger) column;


@end

