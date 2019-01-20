//******************************************************************************
///
/// @file /macintosh/sceneDocument/templates/materialmapTemplate.mm
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
#import "materialmapTemplate.h"
#import "functionTemplate.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cPigmentmap=0,
	cNormalmap=1,
	cTexturemap=2,
	cDensitymap=3
};

@implementation MaterialmapTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[MaterialmapTemplate createDefaults:param];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[MaterialmapTemplate class] andTemplateType:param];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	bodymap *bmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"bodymap"]];

	[ds copyTabAndText:@"texture {\n"];
	[ds addTab];
	[ds copyTabAndText:@"image_map {\n"];
	WritePatternPanel(ds, dict, @"materialmapFileTypePopUp", 
											@"materialmapFunctionImageWidth", @"materialmapFunctionImageHeight",
											@"materialmapFunctionEdit", @"materialmapPatternPigment",
											@"materialmapPigmentPigment" ,@"materialmapFileName");
	switch( [[dict objectForKey:@"materialmapProjectionPopUp"]intValue])
	{
		case cProjectionPlanar:				[ds copyTabAndText:@"map_type 0\t//planar\n"];				break;
		case cProjectionSpherical:			[ds copyTabAndText:@"map_type 1\t//spherical\n"];			break;
		case cProjectionCylindrical:			[ds copyTabAndText:@"map_type 2\t//cylindrical\n"];			break;
		case cProjection3:						break;
		case cProjection4:						break;
		case cProjectionTorus:				[ds copyTabAndText:@"map_type 5\t//torus\n"];					break;
		case cProjectionOmnidirectional:	[ds copyTabAndText:@"map_type 7\t//omnidirectional\n"];	break;
	}
	if ( [[dict objectForKey:@"materialmapProjectionOnceOn"]intValue]==NSOnState)
		[ds copyTabAndText:@"once\n"];

	switch( [[dict objectForKey:@"materialmapInterpolationPopUp"]intValue])
	{
		case cInterpolationNone:							[ds copyTabAndText:@"interpolate 0\t//none\n"];							break;
		case cInterpolationBilinear:						[ds copyTabAndText:@"interpolate 2\t//bilinear\n"];						break;
		case cInterpolationBicubic:						[ds copyTabAndText:@"interpolate 3\t//bilinear\n"];						break;
		case cInterpolationNormilizedDistance:	[ds copyTabAndText:@"interpolate 4\t//normalized distance\n"];	break;
	}
	for ( int x=1; x<=[bmap count]; x++)
	{
		int index=x-1;
		[ds copyTabAndText:@"texture {\n"];
		[ds addTab];
		[ds appendTabAndFormat:@"%@\n",[bmap identifierAtIndex:index]];
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}


	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
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
	NSDictionary *initialDefaults=[MaterialmapTemplate createDefaults:menuTagTemplateMaterialmap];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"materialmapDefaultSettings",
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
		[NSArchiver archivedDataWithRootObject:[bodymap defaultMap]],	@"bodymap",
		[NSNumber numberWithInt:cGif],									@"materialmapFileTypePopUp",
		@"MyFile",																			@"materialmapFileName",
		@"x+y+z",																				@"materialmapFunctionEdit",
		@"300",																					@"materialmapFunctionImageWidth",
		@"300",																					@"materialmapFunctionImageHeight",
		[NSNumber numberWithInt:NSOffState],						@"materialmapProjectionOnceOn",
		[NSNumber numberWithInt:cProjectionPlanar],			@"materialmapProjectionPopUp",
		[NSNumber numberWithInt:cInterpolationNone],		@"materialmapInterpolationPopUp",
	nil];

	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
	  	materialmapFileTypePopUp,			@"materialmapFileTypePopUp",
		materialmapFileName,						@"materialmapFileName",
		materialmapFunctionEdit,				@"materialmapFunctionEdit",
		materialmapFunctionImageWidth,	@"materialmapFunctionImageWidth",
		materialmapFunctionImageHeight,	@"materialmapFunctionImageHeight",
		materialmapProjectionPopUp,			@"materialmapProjectionPopUp",
		materialmapInterpolationPopUp,	@"materialmapInterpolationPopUp",
		materialmapProjectionOnceOn,		@"materialmapProjectionOnceOn",
	nil] ;
	
	[mOutlets retain];

	[ToolTipAutomator setTooltips:@"materialmapLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"materialmapLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			mAddButton,			@"mAddButton",
			mInsertButton,		@"mInsertButton",
			mTrashButton,		@"mTrashButton",

			materialmapFileNameButton,				@"materialmapFileNameButton",
			materialmapFunctionFunctionButton,		@"materialmapFunctionFunctionButton",
			materialmapPatternButton,					@"materialmapPatternButton",
			materialmapPigmentButton,					@"materialmapPigmentButton",
		nil]
		];

	[self  setValuesInPanel:[self preferences]];

}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];
	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"bodymap"];

	if ( [[dict objectForKey:@"materialmapFileTypePopUp"]intValue]==cFunctionImage && materialmapFunction != nil)
		[dict setObject:materialmapFunction forKey:@"materialmapFunction"];
	else if ( [[dict objectForKey:@"materialmapFileTypePopUp"]intValue]==cPatternImage && materialmapPatternPigment != nil)
		[dict setObject:materialmapPatternPigment forKey:@"materialmapPatternPigment"];
	else if ( [[dict objectForKey:@"materialmapFileTypePopUp"]intValue]==cPigmentImage && materialmapPigmentPigment != nil)
		[dict setObject:materialmapPigmentPigment forKey:@"materialmapPigmentPigment"];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
 	mMap=[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"bodymap"]];
 	[mMap retain];
 	[super setValuesInPanel:preferences];
 	[mTableView noteNumberOfRowsChanged];
	[self setButtons];
	[self setMaterialmapFunction:[preferences objectForKey:@"materialmapFunction"]];
	[self setMaterialmapPatternPigment:[preferences objectForKey:@"materialmapPatternPigment"]];
	[self setMaterialmapPigmentPigment:[preferences objectForKey:@"materialmapPigmentPigment"]];

}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self materialmapTarget:self];	
	[self setNotModified];
}

//---------------------------------------------------------------------
// materialmapTarget:sender
//---------------------------------------------------------------------
-(IBAction) materialmapTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cMaterialmapProjectionPopUp;
	else
		theTag=[sender tag];
	switch( theTag)
	{

		
		case cMaterialmapProjectionPopUp:
			if ( [materialmapProjectionPopUp indexOfSelectedItem] == cProjectionSpherical)
				[materialmapProjectionOnceOn setEnabled:NO];
			else
				[materialmapProjectionOnceOn setEnabled:YES];
			if ( sender !=self )	break;
		case cMaterialmapFileTypePopUp:
			switch([materialmapFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[materialmapFileView setHidden:NO];
					[materialmapWidthHeightView setHidden:YES];
					[materialmapFunctionView setHidden:YES];
					[materialmapPatternView setHidden:YES];
					[materialmapPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[materialmapFileView setHidden:YES];
					[materialmapWidthHeightView setHidden:NO];
					[materialmapFunctionView setHidden:NO];
					[materialmapPatternView setHidden:YES];
					[materialmapPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[materialmapFileView setHidden:YES];
					[materialmapWidthHeightView setHidden:NO];
					[materialmapFunctionView setHidden:YES];
					[materialmapPatternView setHidden:NO];
					[materialmapPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[materialmapFileView setHidden:YES];
					[materialmapWidthHeightView setHidden:NO];
					[materialmapFunctionView setHidden:YES];
					[materialmapPatternView setHidden:YES];
					[materialmapPigmentView setHidden:NO];
					break;
			}
			if ( sender !=self )	break;
	}
	[self setModified:nil];
}

//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	NSString *str=nil;

	if( [key isEqualToString:@"materialmapFunction"])
	{
		[self setMaterialmapFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[materialmapFunctionEdit  insertText:str];
	}

	else if( [key isEqualToString:@"materialmapPatternPigment"])
	{
		[self setMaterialmapPatternPigment:dict];
	}
	else if( [key isEqualToString:@"materialmapPigmentPigment"])
	{
		[self setMaterialmapPigmentPigment:dict];
	}

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// materialmapButtons:sender
//---------------------------------------------------------------------
-(IBAction) materialmapButtons:(id)sender
{
	id 	prefs=nil;

	NSInteger tag=[sender tag];
	switch( tag)
	{

	 	case cMaterialmapEditFunctionButton:
			if (materialmapFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:materialmapFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"materialmapFunction"];
			break;
			
	 	case cMaterialmapEditPatternButton:
			if (materialmapPatternPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:materialmapPatternPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"materialmapPatternPigment"];
			break;
			
		case cMaterialmapEditPigmentButton:
			if (materialmapPigmentPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:materialmapPigmentPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"materialmapPigmentPigment"];
			break;

		case cMaterialmapSelectImageFileButton:
			[self selectFile:materialmapFileName withTypes:nil keepFullPath:NO];
			break;

	}
}



//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"Location"])
		return [NSNumber numberWithInteger:rowIndex];
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
	if ( [identifier isEqualToString:@"identifier"])
		[mMap setIdentifier:anObject atIndex:rowIndex ];
	[mTableView reloadData];		// redraw the table
}

	
@end


