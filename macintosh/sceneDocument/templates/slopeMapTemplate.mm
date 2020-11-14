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
#import "slopeMapTemplate.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation SlopemapTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[SlopemapTemplate createDefaults:menuTagTemplateColormap];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[SlopemapTemplate class] andTemplateType:menuTagTemplateColormap];
	[dict retain];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
		{
			[dict release];
			return nil;
		}
	}


	[ds copyTabAndText:@"slope_map {\n"];
	[ds addTab];
	slopemap *cmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"slopemap"]];

	for ( int x=1; x<=[cmap count]; x++)
	{
		int index=x-1;
		[ds appendTabAndFormat:@"[ %@, <%@, %@>]\n",[cmap objectAtRow:index 	atColumn:cSlopemapLocationIndex],
																					[cmap objectAtRow:index atColumn:cSlopemapHeightIndex],
																					[cmap objectAtRow:index atColumn:cSlopemapSlopeIndex]
																					];

	}
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];

//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[SlopemapTemplate createDefaults:menuTagTemplateSlopemap];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"slopemapDefaultSettings",
		nil];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:factoryDefaults];
	
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType
{
	NSMutableDictionary *initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:		[slopemap standardMapWithView:nil]],		@"slopemap",
	nil];

	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	//additional objects
	[ToolTipAutomator setTooltips:@"slopemapLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:

			SlopeButton,					@"SlopeButton",
			PointButton,		@"PointButton",
			CurveButton,		@"CurveButton",
			RasterButton,		@"RasterButton",

			mTableView,			@"mTableView",
			mAddButton,	@"mAddButton",
			mInsertButton,		@"mInsertButton",
			mTrashButton,		@"mTrashButton",
		nil]
		];

	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	if (dict == nil)
		return;
	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"slopemap"];
	[self setPreferences:dict];
	[dict release];
}


//---------------------------------------------------------------------
// slopemapButtons
//---------------------------------------------------------------------
-(IBAction) slopemapButtons:(id)sender
{
	[mMap setButtonState:[sender state] forButton:[sender tag]];
}


//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
 	[self setMap:[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"slopemap"]]];
 	[mMap setPreview:previewView];
 	[ mTableView noteNumberOfRowsChanged];
	[SlopeButton setState:[mMap buttonState:cSlopeButton]];
	[PointButton setState:[mMap buttonState:cPointButton]];
	[CurveButton setState:[mMap buttonState:cCurveButton]];
	[RasterButton setState:[mMap buttonState:cRasterButton]];
	[self updateControls];	
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[[NSNotificationCenter defaultCenter] postNotificationName:NSTableViewSelectionDidChangeNotification object:mTableView];
//	[self tableViewSelectionDidChange:nil];
	[self setButtons];
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cSlopemapLocationIndex];
	else if ( [identifier isEqualToString:@"Height"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cSlopemapHeightIndex];
	else if ( [identifier isEqualToString:@"Slope"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cSlopemapSlopeIndex];
	return nil;

}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		[mMap setObject:anObject  atRow:rowIndex atColumn:cSlopemapLocationIndex];
	else if ( [identifier isEqualToString:@"Height"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cSlopemapHeightIndex];
	else if ( [identifier isEqualToString:@"Slope"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cSlopemapSlopeIndex];
	[mTableView reloadData];		// redraw the table
}

	
@end


