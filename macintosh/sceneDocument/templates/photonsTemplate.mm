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
#import "photonsTemplate.h"
#import "tooltipAutomator.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation PhotonsTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{

	if ( dict== nil)
		dict=[PhotonsTemplate createDefaults:menuTagTemplatePhotons];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[PhotonsTemplate class] andTemplateType:menuTagTemplatePhotons];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];


	[ds copyTabAndText:@"photons {\n"];
	[ds addTab];

	if ( [[dict objectForKey:@"photonsTargetOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"target %@\n",[dict objectForKey:@"photonsSpacingEdit"]];
		
	if ( [[dict objectForKey:@"photonsReflectionOn"] intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"photonsReflectionMaxtrix"] intValue]==cFirstCell)
			[ds copyTabAndText:@"reflection on\n"];
		else
			[ds copyTabAndText:@"reflection off\n"];
	}
	if ( [[dict objectForKey:@"photonsRefractionOn"] intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"photonsRefractionMaxtrix"] intValue]==cFirstCell)
			[ds copyTabAndText:@"refraction on\n"];
		else
			[ds copyTabAndText:@"reflection off\n"];
	}
	if ( [[dict objectForKey:@"photonsCollectOn"] intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"photonsCollectMaxtrix"] intValue]==cFirstCell)
			[ds copyTabAndText:@"collect on\n"];
		else
			[ds copyTabAndText:@"collect off\n"];
	}
	if ( [[dict objectForKey:@"photonsPassThroughOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"pass_through\n"];

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
	NSDictionary *initialDefaults=[PhotonsTemplate createDefaults:menuTagTemplatePhotons];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"photonsDefaultSettings",
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
		[NSNumber numberWithInt:NSOnState],			@"photonsTargetOn",
		@"1.0",															@"photonsSpacingEdit",
		[NSNumber numberWithInt:NSOnState],			@"photonsRefractionOn",
		[NSNumber numberWithInt:cFirstCell],				@"photonsRefractionMaxtrix",
		[NSNumber numberWithInt:NSOnState],			@"photonsReflectionOn",
		[NSNumber numberWithInt:cFirstCell],				@"photonsReflectionMaxtrix",
		[NSNumber numberWithInt:NSOnState],			@"photonsCollectOn",
		[NSNumber numberWithInt:cFirstCell],				@"photonsCollectMaxtrix",
		[NSNumber numberWithInt:NSOnState],			@"photonsPassThroughOn",
		nil
	];

	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
	photonsTargetOn,				@"photonsTargetOn",
	photonsSpacingEdit,			@"photonsSpacingEdit",
	photonsRefractionOn,			@"photonsRefractionOn",
	photonsRefractionMaxtrix,	@"photonsRefractionMaxtrix",
	photonsReflectionOn,			@"photonsReflectionOn",
	photonsReflectionMaxtrix,	@"photonsReflectionMaxtrix",
	photonsCollectOn,				@"photonsCollectOn",
	photonsCollectMaxtrix,		@"photonsCollectMaxtrix",
	photonsPassThroughOn,		@"photonsPassThroughOn",
	nil] ;
	
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"photonsLocalized" andDictionary:mOutlets];

	[self  setValuesInPanel:[self preferences]];
}



//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self photonsTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// photonsTarget:sender
//---------------------------------------------------------------------
-(IBAction) photonsTarget:(id)sender
{
	int theTag;
	if ( sender==self)
		theTag=cPhotonsTargetOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cPhotonsTargetOn:
			[self enableObjectsAccordingToObject:photonsTargetOn, photonsSpacingText,photonsSpacingEdit,nil];
			if ( sender !=self )	break;
		case 	cPhotonsRefractionOn:
			[self enableObjectsAccordingToObject:photonsRefractionOn, photonsRefractionMaxtrix,nil];
			if ( sender !=self )	break;
		case 	cPhotonsReflectionOn:
			[self enableObjectsAccordingToObject:photonsReflectionOn, photonsReflectionMaxtrix,nil];
			if ( sender !=self )	break;
		case 	cPhotonsCollectOn:
			[self enableObjectsAccordingToObject:photonsCollectOn, photonsCollectMaxtrix,nil];
			if ( sender !=self )	break;
	}
	[self setModified:nil];
}


@end
