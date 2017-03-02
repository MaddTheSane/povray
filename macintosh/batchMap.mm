//******************************************************************************
///
/// @file /macintosh/batchMap.mm
///
/// batchmap can hold various scenefiles for rendering one after the other
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
#import "batchMap.h"
#import "mainController.h"

@implementation BatchMap

//---------------------------------------------------------------------
// insertEntryAtIndex
//---------------------------------------------------------------------
-(void) insertEntryAtIndex:(int)index file:(NSString*)file
{
	if ( [self entryExists:file]==YES)
		return;
	if ( index <0)
		index=0;

	NSMutableArray *newArray=[NSMutableArray arrayWithObjects:
		[NSNumber numberWithInt:NSOnState],
		[[PreferencesPanelController sharedInstance] getDictWithCurrentSettings:NO],
		[NSString stringWithString:file],
		[NSNumber numberWithInt:cQueue],
		@"",
	nil];
	
	[mMapArray insertObject:newArray atIndex:index];
	[[self tableView] noteNumberOfRowsChanged];
//	[[self tableView] reloadData];
}

//---------------------------------------------------------------------
// addEntry
//---------------------------------------------------------------------
-(void) addEntry:(NSString *)file
{
	[self insertEntryAtIndex:[self count] file:file];
}

//---------------------------------------------------------------------
// entryExists
//---------------------------------------------------------------------
// search the map to see if 'file' already exists
//---------------------------------------------------------------------
-(BOOL) entryExists:(NSString *)file
{
	int cn=[self count];
	if (cn)
	{
		for (int x=0; x<cn; x++)
			if ( [[self objectAtRow:x atColumn:cNameIndex] isEqualToString:file])
				return YES;
	}
	return NO;
}
			
@end


@implementation BatchTableView

//---------------------------------------------------------------------
// mouseDown
//---------------------------------------------------------------------
// double click on the scene name open in editor
//---------------------------------------------------------------------
- (void)mouseDown:(NSEvent *)theEvent
{

	if( [theEvent clickCount]==2)
	{
		NSPoint mouseLoc = [self convertPoint:[theEvent locationInWindow] fromView:nil];
		int column=[self columnAtPoint:mouseLoc];
		NSTableColumn *clm=[[self tableColumns]objectAtIndex:column];
		if ( clm && [[clm identifier] isEqualToString:@"name"])
		{
			int row=[self rowAtPoint:mouseLoc];
			if( row != -1)
			{
				NSString *file=[[[renderDispatcher sharedInstance]batchMap] objectAtRow:row atColumn:cNameIndex];
				if ( file != nil)
				{
					NSDocumentController *ctrl=[NSDocumentController sharedDocumentController];
					[ctrl openDocumentWithContentsOfURL:[NSURL fileURLWithPath:file] display:YES error:nil];
				}
			}
			else
				[super mouseDown:theEvent];

		}
		else
			[super mouseDown:theEvent];
	}
	else
		[super mouseDown:theEvent];
}
@end
