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
#import "bodymapTemplate.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cPigmentmap=0,
	cNormalmap=1,
	cTexturemap=2,
	cDensitymap=3
};

@implementation BodymapTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[BodymapTemplate createDefaults:param];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[BodymapTemplate class] andTemplateType:param];


	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	bodymap *bmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"bodymap"]];
	switch ( [[dict objectForKey:@"bodymapType"]intValue])
	{
		case cPigmentmap:	[ds copyTabAndText:@"pigment_map {\n"]; break;
		case cNormalmap:		[ds copyTabAndText:@"normal_map {\n"]; break;
		case cTexturemap:		[ds copyTabAndText:@"texture_map {\n"]; break;
		case cDensitymap:		[ds copyTabAndText:@"density_map {\n"]; break;
	}
	[ds addTab];
	for ( int x=1; x<=[bmap count]; x++)
	{
		int index=x-1;
		[ds appendTabAndFormat:@"[ %.5f %@]\n",[[bmap locationAtIndex:index]floatValue],[bmap identifierAtIndex:index]];
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
	[BodymapTemplate createDefaults:menuTagTemplateAllBodymaps];
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType
{
	//if templateType is menuTagTemplateAllBodymaps all default maps
	// will be created.
	// if templateType is of type density, normal, pigment or texture,
	// only that map will be created and returned. No defaults will
	// be written in that case.
	
	NSDictionary *factoryDefaults=nil;
	NSMutableDictionary *initialDefaults=nil;
	
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

	if (templateType == menuTagTemplateAllBodymaps || templateType== menuTagTemplateDensitymap)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[bodymap defaultMap]],	@"bodymap",
								[NSNumber numberWithInt:cDensitymap],										@"bodymapType", nil];
		if ( templateType==menuTagTemplateAllBodymaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:		
									initialDefaults,@"densitymapDefaultSettings",nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}

	if (templateType == menuTagTemplateAllBodymaps || templateType== menuTagTemplatePigmentmap)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[bodymap defaultMap]],	@"bodymap",
								[NSNumber numberWithInt:cPigmentmap],										@"bodymapType", nil];
		if ( templateType==menuTagTemplateAllBodymaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"pigmentmapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}
	
	if (templateType == menuTagTemplateAllBodymaps || templateType== menuTagTemplateNormalmap)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[bodymap defaultMap]],	@"bodymap",
								[NSNumber numberWithInt:cNormalmap],										@"bodymapType", nil];
		if ( templateType==menuTagTemplateAllBodymaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"normalmapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}
	
	if (templateType == menuTagTemplateAllBodymaps || templateType== menuTagTemplateTexturemap)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[bodymap textureMap]],	@"bodymap",
								[NSNumber numberWithInt:cTexturemap],									@"bodymapType", nil];
		if ( templateType==menuTagTemplateAllBodymaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"texturemapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}

	return initialDefaults;
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
	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"bodymap"];
	switch (mTemplateType)
	{
		case menuTagTemplateDensitymap:	[dict setObject:[NSNumber numberWithInt:cDensitymap] forKey:@"bodymapType"];	break;
		case menuTagTemplateNormalmap:	[dict setObject:[NSNumber numberWithInt:cNormalmap] forKey:@"bodymapType"];	break;
		case menuTagTemplateTexturemap:	[dict setObject:[NSNumber numberWithInt:cTexturemap] forKey:@"bodymapType"];	break;
		case menuTagTemplatePigmentmap:	[dict setObject:[NSNumber numberWithInt:cPigmentmap] forKey:@"bodymapType"];	break;
	}

	[self setPreferences:dict];
	[dict release];
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];
	switch (mTemplateType)
	{
		case menuTagTemplateDensitymap:
			[bodymapTypeText setStringValue:@"Density map"];
			[[bodymapLocationColumn headerCell]setStringValue:@"Location"];
			break;
		case menuTagTemplateNormalmap:
			[bodymapTypeText setStringValue:@"Normal map"];
			[[bodymapLocationColumn headerCell]setStringValue:@"Weight"];
			break;
		case menuTagTemplateTexturemap:
			[bodymapTypeText setStringValue:@"Texture map"];
			[[bodymapLocationColumn headerCell]setStringValue:@"Location"];
			break;
		case menuTagTemplatePigmentmap:
			[bodymapTypeText setStringValue:@"Pigment map"];
			[[bodymapLocationColumn headerCell]setStringValue:@"Weight"];
			break;
	}
	
	[self  setValuesInPanel:[self preferences]];
	//additional objects
	[ToolTipAutomator setTooltips:@"bodymapLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:

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
 	mMap=[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"bodymap"]];
 	[mMap retain];
 	[mTableView noteNumberOfRowsChanged];
	[self setButtons];

	[self updateControls];	
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		return [mMap locationAtIndex:rowIndex];
	else if ( [identifier isEqualToString:@"identifier"])
		return [mMap identifierAtIndex:rowIndex];
	return nil;

}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		[mMap setLocation:anObject atIndex:rowIndex ];
	else if ( [identifier isEqualToString:@"identifier"])
		[mMap setIdentifier:anObject atIndex:rowIndex ];
	[mTableView reloadData];		// redraw the table
}

	
@end


