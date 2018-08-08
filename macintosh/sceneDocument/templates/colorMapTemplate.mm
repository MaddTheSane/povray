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
#import "colorMapTemplate.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cLocationColumn=1,
	cColorColumn=2,
	cRedColumn=3,
	cGreenColumn=4,
	cBlueColumn=5,
	cFilterColumn=6,
	cTransmitColumn=7
};

@implementation ColormapTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(NSInteger) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[ColormapTemplate createDefaults:menuTagTemplateColormap];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[ColormapTemplate class] andTemplateType:menuTagTemplateColormap];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	[ds copyTabAndText:@"color_map {\n"];
	[ds addTab];
	colormap *cmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"colormap"]];

	for ( int x=1; x<=[cmap count]; x++)
	{
		int index=x-1;
		[ds appendTabAndFormat:@"[ %.5f rgb",[cmap floatAtRow:index atColumn:cColormapLocationIndex]];

		if ( [cmap buttonState:cFilterButton])
			[ds copyText:@"f"];
		if ( [cmap buttonState:cTransmitButton])
			[ds copyText:@"t"];

		[ds copyText:@" "];

		if ( [cmap buttonState:cGrayColorButton])
		{
			float grayValue= [[cmap redAtIndex:index]floatValue]*0.297 +
									[[cmap greenAtIndex:index]floatValue]*0.589 +
									[[cmap blueAtIndex:index]floatValue]*0.114;

			[ds appendFormat:@"< %.5f, %.5f, %.5f", grayValue, grayValue, grayValue];
		}
		else
		{
			[ds appendFormat:@"< %.5f, %.5f, %.5f", [[cmap redAtIndex:index]floatValue], [[cmap greenAtIndex:index]floatValue], [[cmap blueAtIndex:index]floatValue]];
		}
		if ( [cmap buttonState:cFilterButton])
			[ds appendFormat:@", %.5f",[cmap floatAtRow:index atColumn:cColormapFilterIndex]];
		if ( [cmap buttonState:cTransmitButton])
			[ds appendFormat:@", %.5f",[cmap floatAtRow:index atColumn:cColormapTransmitIndex]];
		[ds copyText:@"> ]\n"];
	}
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];


	
	//[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[ColormapTemplate createDefaults:menuTagTemplateColormap];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"colormapDefaultSettings",
		nil];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:factoryDefaults];
	
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(NSUInteger) templateType
{
	NSMutableDictionary *initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
[NSArchiver archivedDataWithRootObject:		[colormap standardMapWithView:nil]],					@"colormap",
	nil];

	return initialDefaults;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[mMap setPreview:nil];

	// make sure the panel isn't connected anymore
	NSColorPanel* colorPanel;
	colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setTarget: nil];
	[colorPanel setAction: NULL];
	[colorPanel orderOut:nil]; // hide the panel

	[super dealloc];
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	[dict autorelease];
	if (dict == nil)
		return;
	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"colormap"];
	[self setPreferences:dict];
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	NSTableColumn * color=[mTableView tableColumnWithIdentifier:@"Color"];

	mColorCell = [[[ColorCell alloc] init] autorelease];	// create the special color well cell
    [mColorCell setEditable: YES];								// allow user to change the color
	[mColorCell setTarget: self];								// set colorClick as the method to call
	[mColorCell setAction: @selector (colorClick:)];		// when the color well is clicked on
	[color setDataCell: mColorCell];							// sets the columns cell to the color well cell

	[self  setValuesInPanel:[self preferences]];
	[ToolTipAutomator setTooltips:@"colormapLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"colormapLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			colormapUseGrayColor,		@"colormapUseGrayColor",

			colormapFilterOn,		@"colormapFilterOn",
			colormapTransmitOn,		@"colormapTransmitOn",
			mAddButton,			@"mAddButton",
			mInsertButton,		@"mInsertButton",
			mTrashButton,		@"mTrashButton",

		nil]
		];


}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
 	[self setMap:[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"colormap"]]];
 	[mMap setPreview:cMapPreview];
 	[ mTableView noteNumberOfRowsChanged];
	[colormapFilterOn setState:[mMap buttonState:cFilterButton]];
	[colormapTransmitOn setState:[mMap buttonState:cTransmitButton]];
	[colormapUseGrayColor setState:[mMap buttonState:cGrayColorButton]];
	[self updateControls];	
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self colormapFilterOn:colormapFilterOn];
	[self colormapUseGrayColor:colormapUseGrayColor];
	[self colormapTransmitOn:colormapTransmitOn];
	[self setNotModified];
	[self setButtons];
}

//---------------------------------------------------------------------
// colormapUseGrayColor
//---------------------------------------------------------------------
- (IBAction)colormapUseGrayColor:(id)sender
{
	[mMap setButtonState:[sender state] forButton:[sender tag]];
	[mColorCell setIsGrayScale:([sender state]==NSOnState)];
	[mTableView reloadData];		// redraw the table
}

//---------------------------------------------------------------------
// colormapFilterOn
//---------------------------------------------------------------------
- (IBAction)colormapFilterOn:(id)sender
{
	[mMap setButtonState:[sender state] forButton:[sender tag]];
	NSTableColumn *t=[mTableView tableColumnWithIdentifier:@"Filter"];
	[t setEditable:([mMap buttonState:cFilterButton]==NSOnState)];
	[mTableView reloadData];		// redraw the table
}

//---------------------------------------------------------------------
// colormapTransmitOn
//---------------------------------------------------------------------
- (IBAction)colormapTransmitOn:(id)sender
{
	[mMap setButtonState:[sender state] forButton:[sender tag]];
	NSTableColumn *t=[mTableView tableColumnWithIdentifier:@"Transmit"];
	[t setEditable:([mMap buttonState:cTransmitButton]==NSOnState)];
	[mTableView reloadData];		// redraw the table
}


//---------------------------------------------------------------------
// colorClick
//---------------------------------------------------------------------
- (void) colorClick: (id) sender // sender is the table view
{	
	NSColorPanel* colorPanel;	

	mColorClickInRow = [sender clickedRow];				// save for color changed messages
	colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setTarget: self];											// send the color changed messages to colorChanged
	[colorPanel setAction: @selector (colorChanged:)];
	[colorPanel setShowsAlpha: YES];									// per ber to show the opacity slider
	[colorPanel setColor: [mMap objectAtRow:mColorClickInRow atColumn:cColormapColorIndex]];	// set the starting color
	[colorPanel makeKeyAndOrderFront: self];						// show the panel
}

//---------------------------------------------------------------------
// colorChanged
//---------------------------------------------------------------------
- (void) colorChanged: (id) sender // sender is the NSColorPanel
{	
	[mMap replaceEntryAtIndex: mColorClickInRow withObject: [[sender color]colorUsingColorSpaceName:NSCalibratedRGBColorSpace]]; // use saved row index to change the correct in the color array (the model)
	[mTableView reloadData];		// redraw the table
}


//---------------------------------------------------------------------
// tableView:willDisplayCell:row
//---------------------------------------------------------------------
// if a tablecolumn is not editable
// draw it with a disabled color
// black color otherwize
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)tableView willDisplayCell:(id)cell forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	NSColor *textColor=nil;
    if ( [tableColumn isEditable]==YES)
 		textColor = [NSColor blackColor];
 	else
 		textColor=[NSColor  disabledControlTextColor];

    if ([cell respondsToSelector:@selector(setTextColor:)]) {
        [cell setTextColor:textColor];
    }
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cColormapLocationIndex];
	else if ( [identifier isEqualToString:@"Color"])
		return [mMap objectAtRow:rowIndex atColumn:cColormapColorIndex];
	else if ( [identifier isEqualToString:@"Red"])
		return [mMap redAtIndex:rowIndex];
	else if ( [identifier isEqualToString:@"Green"])
		return [mMap greenAtIndex:rowIndex];
	else if ( [identifier isEqualToString:@"Blue"])
		return [mMap blueAtIndex:rowIndex];
	else if ( [identifier isEqualToString:@"Filter"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cColormapFilterIndex];
	else if ( [identifier isEqualToString:@"Transmit"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cColormapTransmitIndex];
	return nil;

}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cColormapLocationIndex ];
	else if ( [identifier isEqualToString:@"Red"])
		[mMap setRed:anObject atIndex:rowIndex ];
	else if ( [identifier isEqualToString:@"Green"])
		[mMap setGreen:anObject atIndex:rowIndex ];
	else if ( [identifier isEqualToString:@"Blue"])
		[mMap setBlue:anObject atIndex:rowIndex];
	else if ( [identifier isEqualToString:@"Filter"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cColormapFilterIndex ];
	else if ( [identifier isEqualToString:@"Transmit"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cColormapTransmitIndex ];
	[mTableView reloadData];		// redraw the table
}

@end
