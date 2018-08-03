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
#import "interiorTemplate.h"
#import "mediaTemplate.h"
#import "tooltipAutomator.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"

// this must be the last file included
#import "syspovdebug.h"



@implementation InteriorTemplate


//---------------------------------------------------------------------
// interiorMainViewNIBView
//---------------------------------------------------------------------
-(NSView*) interiorMainViewNIBView
{
	return interiorMainViewNIBView;
}

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(NSInteger) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{

	if ( dict== nil)
		dict=[InteriorTemplate createDefaults:menuTagTemplateInterior];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[InteriorTemplate class] andTemplateType:menuTagTemplateInterior];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	[ds copyTabAndText:@"interior {\n"];
	[ds addTab];

//interior type 
	if ( [[dict objectForKey:@"interiorIorIndexEdit"] doubleValue] != 1.0 || [[dict objectForKey:@"interiorDispersionGroupOn"]intValue]==NSOnState)
		[ds appendTabAndFormat:@"ior %@\n",[dict objectForKey:@"interiorIorIndexEdit"]];

	if (  [[dict objectForKey:@"interiorCausticsOn"]intValue]==NSOnState)
		[ds appendTabAndFormat:@"caustics %@\n",[dict objectForKey:@"interiorCausticsEdit"]];

//fade power
	if (  [[dict objectForKey:@"interiorLightAttenuationGroupOn"]intValue]==NSOnState)
	{
		[ds appendTabAndFormat:@"fade_distance %@ fade_power %@\n",[dict objectForKey:@"interiorLightAttenuationFadeDistanceEdit"],
						[dict objectForKey:@"interiorLightAttenuationFadePowerEdit"]];
		if (  [[dict objectForKey:@"interiorLightAttenuationFadeColorGroupOn"]intValue]==NSOnState)
		{
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"interiorLightAttenuationFadeColorColorWell" andTitle:@"fade_color " comma:NO newLine:YES];
		}
	}
//dispersion
	if (  [[dict objectForKey:@"interiorDispersionGroupOn"]intValue]==NSOnState)
	{
		[ds appendTabAndFormat:@"dispersion %@\n",[dict objectForKey:@"interiorDispersionValueEdit"]];
		[ds appendTabAndFormat:@"dispersion_samples %@\n",[dict objectForKey:@"interiorDispersionSamplesEdit"]];
	}

	if (  [[dict objectForKey:@"interiorMediaGroupOn"]intValue]==NSOnState)
	{
			[MediaTemplate createDescriptionWithDictionary:[dict objectForKey:@"interiorEditMedia"] 
				andTabs:[ds currentTabs]extraParam:menuTagTemplateMedia mutableTabString:ds];
	}

	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
	[dict release];
	return ds;
}


//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[InteriorTemplate createDefaults:menuTagTemplateInterior];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"interiorDefaultSettings",
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
		[NSNumber numberWithInt:cIorIndexWater],			@"interiorIorIndexPopUp",
		@"1.3",																				@"interiorIorIndexEdit",
		[NSNumber numberWithInt:NSOffState],					@"interiorDispersionGroupOn",
		[NSNumber numberWithInt:NSOnState],						@"interiorDispersionSamplesOn",
		@"7",																					@"interiorDispersionSamplesEdit",
		@"1.0",																				@"interiorDispersionValueEdit",
		[NSNumber numberWithInt:NSOffState],					@"interiorCausticsOn",
		@"1.0",																				@"interiorCausticsEdit",
		[NSNumber numberWithInt:NSOffState],					@"interiorLightAttenuationGroupOn",
		@"1",																					@"interiorLightAttenuationFadeDistanceEdit",
		@"1",																					@"interiorLightAttenuationFadePowerEdit",
		[NSNumber numberWithInt:NSOffState],					@"interiorLightAttenuationFadeColorGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"interiorLightAttenuationFadeColorColorWell",
		[NSNumber numberWithInt:NSOffState],					@"interiorMediaGroupOn",
	nil];

	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{

	[super awakeFromNib];
	NSMenu *m=[interiorIorIndexPopUp menu];
	NSMenuItem *newItem;
	NSArray *itemArray=[NSArray arrayWithObjects:
			@"Acrylic (1.49)",
			@"Air (1.0003)",
			@"Alcohol (1.33)",
			@"Amber (1.546)",
			@"Diamond (2.417)",
			@"Emerald (1.576)",
			@"Glass, borosilicate (Pyrex) (1.474)",
			@"Glass, Crown (common) (1.52)",
			@"Glass, Flint 71% lead (1.81)",
			@"Glycerine (1.473)",
			@"Ice (1.309)",
			@"Opal (1.45)",
			@"Polycarbonate (1.59)",
			@"Quartz (1.544)",
			@"Sapphire, ruby (1.77)",
			@"Topaz (1.62)",
			@"Vacuum (1)",
			@"Water (1.33)",
			@"Zircon (1.92)",
			@"Zirconia, Cubic (2.17)",
		nil];
	for (int index=0; index <[itemArray count]; index++)
	{
		newItem=[[NSMenuItem alloc]init];	
		[newItem setTitle:[itemArray objectAtIndex:index]];
		[m	addItem:newItem];
		[newItem release];
	}
	
	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		interiorIorIndexPopUp,											@"interiorIorIndexPopUp",
		interiorIorIndexEdit,												@"interiorIorIndexEdit",
		interiorDispersionGroupOn,									@"interiorDispersionGroupOn",
		interiorDispersionSamplesOn,								@"interiorDispersionSamplesOn",
		interiorDispersionSamplesEdit,							@"interiorDispersionSamplesEdit",
		interiorDispersionValueEdit,								@"interiorDispersionValueEdit",
		interiorCausticsOn,													@"interiorCausticsOn",
		interiorCausticsEdit,												@"interiorCausticsEdit",
		interiorLightAttenuationGroupOn,						@"interiorLightAttenuationGroupOn",
		interiorLightAttenuationFadeDistanceEdit,		@"interiorLightAttenuationFadeDistanceEdit",
		interiorLightAttenuationFadePowerEdit,			@"interiorLightAttenuationFadePowerEdit",
		interiorLightAttenuationFadeColorGroupOn,		@"interiorLightAttenuationFadeColorGroupOn",
		interiorLightAttenuationFadeColorColorWell,	@"interiorLightAttenuationFadeColorColorWell",
		interiorMediaGroupOn,												@"interiorMediaGroupOn",

	nil] ;
	
	[mOutlets retain];

	[ToolTipAutomator setTooltips:@"interiorLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"interiorLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			interiorMediaEditButton,					@"interiorMediaEditButton",
		nil]
		];
	
	[interiorMainViewHolderView  addSubview:interiorMainViewNIBView];

	[self  setValuesInPanel:[self preferences]];
}



//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self interiorTarget:self];
	[self setNotModified];
}
//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self setInteriorEditMedia:[preferences objectForKey:@"interiorEditMedia"]];
	[super setValuesInPanel:preferences];
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];

	if ( [[dict objectForKey:@"interiorMediaGroupOn"]intValue]==NSOnState)
	{
		if( interiorEditMedia != nil )
			[dict setObject:interiorEditMedia forKey:@"interiorEditMedia"];
	}		
}

//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	if( [key isEqualToString:@"interiorEditMedia"])
		[self setInteriorEditMedia:dict];
	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// interiorButtons:sender
//---------------------------------------------------------------------
-(IBAction) interiorButtons:(id)sender
{
	id 	prefs=nil;

	NSInteger tag=[sender tag];
	switch( tag)
	{
		case cInteriorEditMedia:
			if (interiorEditMedia!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:interiorEditMedia];
			[self callTemplate:menuTagTemplateMedia withDictionary:prefs andKeyName:@"interiorEditMedia"];
			break;
	}
}


//---------------------------------------------------------------------
// interiorTarget:sender
//---------------------------------------------------------------------
-(IBAction) interiorTarget:(id)sender
{
	eInteriorTags theTag;
	if ( sender==self)
		theTag=cInteriorDispersionGroupOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cInteriorDispersionGroupOn:
			[self setSubViewsOfNSBox:interiorDispersionGroup toNSButton:interiorDispersionGroupOn];
			if ( sender !=self )	break;

		case 	cIteriorLightAttenuationFadeColorGroupOn:
			if ( [interiorLightAttenuationGroupOn state]==NSOnState)
				[self setSubViewsOfNSBox:interiorLightAttenuationFadeColorGroup toNSButton:interiorLightAttenuationFadeColorGroupOn];
			else
				[self setSubViewsOfNSBox:interiorLightAttenuationFadeColorGroup toNSButton:interiorLightAttenuationGroupOn];
			if ( sender !=self )	break;
			
		case 	cInteriorDispersionSamplesOn:
			[self enableObjectsAccordingToObject:interiorDispersionSamplesOn, interiorDispersionSamplesEdit,nil];
			if ( sender !=self )	break;

		case 	cInteriorCausticsOn:
			[self enableObjectsAccordingToObject:interiorCausticsOn, interiorCausticsEdit,nil];
			if ( sender !=self )	break;
			
		case 	cInteriorLightAttenuationGroupOn:
			[self setSubViewsOfNSBox:interiorLightAttenuationGroup toNSButton:interiorLightAttenuationGroupOn];
			if ( [interiorLightAttenuationGroupOn state]==NSOnState)
				[self setSubViewsOfNSBox:interiorLightAttenuationFadeColorGroup toNSButton:interiorLightAttenuationFadeColorGroupOn];
			else
				[self setSubViewsOfNSBox:interiorLightAttenuationFadeColorGroup toNSButton:interiorLightAttenuationGroupOn];
			if ( sender !=self )	break;

		case 	cInteriorMediaGroupOn:
			[self setSubViewsOfNSBox:interiorMediaGroup toNSButton:interiorMediaGroupOn];
			if ( sender !=self )	break;
			
		case 	cInteriorIorIndexPopUp:
			if ( sender != self)
			{
				switch ([interiorIorIndexPopUp indexOfSelectedItem])
				{
					case cIorIndexNone:					[interiorIorIndexEdit setStringValue:@"1.0"]; 			break;
					case cIorIndexAcrylic:					[interiorIorIndexEdit setStringValue:@"1.49"];		break;
					case cIorIndexAir:						[interiorIorIndexEdit setStringValue:@"1.0003"];	break;
					case cIorIndexAlcohol:				[interiorIorIndexEdit setStringValue:@"1.33"];		break;
					case cIorIndexAmber:					[interiorIorIndexEdit setStringValue:@"1.546"];		break;
					case cIorIndexDiamond:				[interiorIorIndexEdit setStringValue:@"2.417"];		break;
					case cIorIndexEmerald:				[interiorIorIndexEdit setStringValue:@"1.576"];		break;
					case cIorIndexGlassBorosilicate:	[interiorIorIndexEdit setStringValue:@"1.474"];		break;
					case cIorIndexGlassCrown:			[interiorIorIndexEdit setStringValue:@"1.52"];		break;
					case cIorIndexGlass71Lead:		[interiorIorIndexEdit setStringValue:@"1.81"];		break;
					case cIorIndexGlycerine:				[interiorIorIndexEdit setStringValue:@"1.473"];		break;
					case cIorIndexIce:						[interiorIorIndexEdit setStringValue:@"1.309"];		break;
					case cIorIndexOpal:					[interiorIorIndexEdit setStringValue:@"1.45"];		break;
					case cIorIndexPolycarbonate:		[interiorIorIndexEdit setStringValue:@"1.59"];		break;
					case cIorIndexQuartz:					[interiorIorIndexEdit setStringValue:@"1.544"];		break;
					case cIorIndexSapphire:				[interiorIorIndexEdit setStringValue:@"1.77"];		break;
					case cIorIndexTopaz:					[interiorIorIndexEdit setStringValue:@"1.62"];		break;
					case cIorIndexWater:					[interiorIorIndexEdit setStringValue:@"1.33"];		break;
					case cIorIndexZircon:					[interiorIorIndexEdit setStringValue:@"1.92"];		break;
					case cIorIndexZirconaCubic:		[interiorIorIndexEdit setStringValue:@"2.17"];		break;
				}
			}
			break;
	}
	[self setModified:nil];
}


@end
