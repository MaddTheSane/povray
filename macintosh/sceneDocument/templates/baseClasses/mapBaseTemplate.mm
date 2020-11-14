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
#import "mapBaseTemplate.h"
#import "mapPreview.h"
#import "SlopeMap.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation MapBaseTemplate

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self setMap:nil];
	[super dealloc];
}

//---------------------------------------------------------------------
// setMap:map
//---------------------------------------------------------------------
-(void) setMap:(id)map
{
	[mMap release];
	mMap=map;
	[mMap retain];	
	[mMap mapBaseSetTemplate:self];
}

//---------------------------------------------------------------------
// selectTableRow:index
//---------------------------------------------------------------------
-(void) selectTableRow:(int)index
{
	[mTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] 
		byExtendingSelection:NO];
	[mTableView scrollRowToVisible:index];
}

//---------------------------------------------------------------------
// addButton
//---------------------------------------------------------------------
- (IBAction)addButton:(id)sender
{
	[mMap addEntry];
 	[mTableView noteNumberOfRowsChanged];
 	[self setButtons];
}

//---------------------------------------------------------------------
// insertButton
//---------------------------------------------------------------------
- (IBAction)insertButton:(id)sender
{
	[mMap insertEntryAtIndex:[mTableView selectedRow]];
 	[ mTableView noteNumberOfRowsChanged];
 	[self setButtons];
}


//---------------------------------------------------------------------
// trashButton
//---------------------------------------------------------------------
- (IBAction)trashButton:(id)sender
{
	NSIndexSet *idx=[mTableView selectedRowIndexes];
	NSUInteger current;
	current=[idx lastIndex];
	while (current != NSNotFound)
	{
		[mMap removeEntryAtIndex:current reload:YES];
		current=[idx indexLessThanIndex:current];
	};
 	[self setButtons];
}

//---------------------------------------------------------------------
// tableView
//---------------------------------------------------------------------
-(NSTableView *) tableView
{
	return mTableView;
}

//---------------------------------------------------------------------
// selectRow: byExtendingSelection
//---------------------------------------------------------------------
- (void)selectRow:(NSUInteger)rowIndex byExtendingSelection:(BOOL)flag
{
	[mTableView selectRowIndexes:[[[NSIndexSet alloc] initWithIndex:rowIndex]autorelease] byExtendingSelection:flag];
}

//---------------------------------------------------------------------
// datasource
//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [mMap count];
}

//---------------------------------------------------------------------
// selectionIncludePathTableViewChanged
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ( mMap && [mMap respondsToSelector:@selector(setSelectedRow:)])
		[mMap setSelectedRow:[mTableView selectedRow]];
	[self setButtons];
}


//---------------------------------------------------------------------
// setButtons
//---------------------------------------------------------------------
-(void) setButtons
{
	if ( [mMap selectedRow] == dNoRowSelected)	
	{
		[mInsertButton setEnabled:NO];
		[mAddButton setEnabled:YES];
		[mTrashButton setEnabled:NO];
	}
	else  
	{
		[mInsertButton setEnabled:YES];
		[mAddButton setEnabled:YES];
		[mTrashButton setEnabled:YES];
	}
	if ([mMap count] <=2)
		[mTrashButton setEnabled:NO];
}

	
@end


