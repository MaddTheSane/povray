//******************************************************************************
///
/// @file /macintosh/sceneDocument/templates/backgroundTemplate.mm
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
//********************************************************************************
#import "BackgroundTemplate.h"
#import "PigmentTemplate.h"
#import "BodymapTemplate.h"
#import "TransformationsTemplate.h"
#import "standardMethods.h"
#import "TooltipAutomator.h"
#import "colormap.h"

@implementation BackgroundTemplate


//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{
	if ( dict== nil)
		dict=[BackgroundTemplate createDefaults:menuTagTemplateBackground];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[BackgroundTemplate class] andTemplateType:menuTagTemplateBackground];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];


	switch ( [[dict objectForKey:@"backgroundTabView"]intValue])
	{
		case cBackground:
			[ds copyTabAndText:@"background {\n"];
			[ds addTab];
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"backgroundColorWell" andTitle:@"" comma:NO newLine:YES];
			break;
		case cFog:
			[ds copyTabAndText:@"fog {\n"];
			[ds addTab];
		
			switch ( [[dict objectForKey:@"backgroundFogTypePopUp"]intValue])
			{
				case cConstantFog: 
					[ds copyTabAndText:@"fog_type 1 //constant_fog\n"];
					break;
				case cGroundFog: 
					[ds copyTabAndText:@"fog_type 2 //ground_fog\n"];
				//up
					if ( [[dict objectForKey:@"backgroundFogUpOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"up "];
						[ds addXYZVector:dict  popup:@"backgroundFogUpXYZPopUp" xKey:@"backgroundFogUpMatrixX" 
																yKey:@"backgroundFogUpMatrixY" zKey:@"backgroundFogUpMatrixZ"];
					[ds copyText:@"\n"];

					}
				//fog offset
				if ( [[dict objectForKey:@"backgroundFogOffsetOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"fog_offset %@\n",[dict objectForKey:@"backgroundFogOffsetEdit"]];

					//fog altitude
				if ( [[dict objectForKey:@"backgroundFogAltitudeOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"fog_alt %@\n",[dict objectForKey:@"backgroundFogAltitudeEdit"]];
						break;
			}
			[ds appendTabAndFormat:@"distance %@\n",[dict objectForKey:@"backgroundFogDistanceEdit"]];
			//color
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"backgroundFogColorColorWell" andTitle:@"" comma:NO newLine:YES];
			//turbulence
			if ( [[dict objectForKey:@"backgroundFogTurbulenceOn"]intValue]==NSOnState)
			{
				[ds copyTabAndText:@"turbulence "];
				[ds addXYZVector:dict  popup:@"backgroundFogTurbulenceXYZPopUp" xKey:@"backgroundFogTurbulenceMatrixX" 
																yKey:@"backgroundFogTurbulenceMatrixY" zKey:@"backgroundFogTurbulenceMatrixZ"];
					[ds copyText:@"\n"];
			}
			if ( [[dict objectForKey:@"backgroundFogOmegaOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"omega %@\n",[dict objectForKey:@"backgroundFogOmegaEdit"]];
			if ( [[dict objectForKey:@"backgroundFogLambdaOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"lambda %@\n",[dict objectForKey:@"backgroundFogLambdaEdit"]];
			if ( [[dict objectForKey:@"backgroundFogOctavesOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"octaves %@\n",[dict objectForKey:@"backgroundFogOctavesEdit"]];
			if ( [[dict objectForKey:@"backgroundFogTurbulenceDepthOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"turb_depth %@\n",[dict objectForKey:@"backgroundFogTurbulenceDepthEdit"]];
			break;
		case cRainbow:
			[ds copyTabAndText:@"rainbow {\n"];
			[ds addTab];
		//direction
				[ds copyTabAndText:@"direction "];
				[ds addXYZVector:dict  popup:@"backgroundRainbowDirectionXYZPopUp" xKey:@"backgroundRainbowDirectionMatrixX" 
																yKey:@"backgroundRainbowDirectionMatrixY" zKey:@"backgroundRainbowDirectionMatrixZ"];
					[ds copyText:@"\n"];

			[ds appendTabAndFormat:@"angle %@\n",[dict objectForKey:@"backgroundRainbowAngleEdit"]];
			[ds appendTabAndFormat:@"width %@\n",[dict objectForKey:@"backgroundRainbowWidthEdit"]];
			[ds appendTabAndFormat:@"distance %@\n",[dict objectForKey:@"backgroundRainbowDistanceEdit"]];
			if ( [[dict objectForKey:@"backgroundRainbowJitterOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"jitter %@\n",[dict objectForKey:@"backgroundRainbowJitterEdit"]];
			
		//up
			if ( [[dict objectForKey:@"backgroundRainbowUpOn"]intValue]==NSOnState)
			{
				[ds copyTabAndText:@"up "];
				[ds addXYZVector:dict  popup:@"backgroundRainbowUpXYZPopUp" xKey:@"backgroundRainbowUpMatrixX" 
																yKey:@"backgroundRainbowUpMatrixY" zKey:@"backgroundRainbowUpMatrixZ"];
					[ds copyText:@"\n"];

			}
			if ( [[dict objectForKey:@"backgroundRainbowArcAngleOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"arc_angle %@\n",[dict objectForKey:@"backgroundRainbowArcAngleEdit"]];
			if ( [[dict objectForKey:@"backgroundRainbowFalloffAngleOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"falloff_angle %@\n",[dict objectForKey:@"backgroundRainbowFalloffAngleEdit"]];
			WriteColormap(ds, dict, @"backgroundRainbowColorMapTabView");
			break;
		case cSkysphere:
			[ds copyTabAndText:@"sky_sphere {\n"];
			[ds addTab];
			WritePigment(cForceWrite, ds, [dict objectForKey:@"backgroundSkysphereEditPigment1"], NO);

			if ( [[dict objectForKey:@"backgroundSkyspherePigment2On"]intValue]==NSOnState)
				WritePigment(cForceWrite, ds, [dict objectForKey:@"backgroundSkysphereEditPigment2"], NO);

			if ( [[dict objectForKey:@"backgroundSkyspherePigment3On"]intValue]==NSOnState)
				WritePigment(cForceWrite, ds, [dict objectForKey:@"backgroundSkysphereEditPigment3"], NO);

			if ( [[dict objectForKey:@"backgroundSkyspherePigment4On"]intValue]==NSOnState)
				WritePigment(cForceWrite, ds, [dict objectForKey:@"backgroundSkysphereEditPigment4"], NO);

			if ( [[dict objectForKey:@"backgroundSkyspherePigment5On"]intValue]==NSOnState)
				WritePigment(cForceWrite, ds, [dict objectForKey:@"backgroundSkysphereEditPigment5"], NO);

			break;
			
		case cGlow:
			[ds copyTabAndText:@"glow {\n"];
			[ds addTab];
			switch ( [[dict objectForKey:@"backgroundGlowTypePopUp"]intValue])
			{
				case cGlowType0:	[ds copyTabAndText:@"type 0\n"];	break;
				case cGlowType1:	[ds copyTabAndText:@"type 1\n"];	break;
				case cGlowType2:	[ds copyTabAndText:@"type 2\n"];	break;
				case cGlowType3:	[ds copyTabAndText:@"type 3\n"];	break;
			}
			[ds copyTabAndText:@"location "];
			[ds addXYZVector:dict  popup:@"backgroundGlowLocationXYZPopUp" xKey:@"backgroundGlowLocationMatrixX" 
																yKey:@"backgroundGlowLocationMatrixY" zKey:@"backgroundGlowLocationMatrixZ"];
			[ds copyText:@"\n"];

			[ds appendTabAndFormat:@"size %@\n",[dict objectForKey:@"backgroundGlowSizeEdit"]];
			[ds appendTabAndFormat:@"radius %@\n",[dict objectForKey:@"backgroundGlowRadiusEdit"]];
			[ds appendTabAndFormat:@"fade_power %@\n",[dict objectForKey:@"backgroundGlowFadePowerEdit"]];
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"backgroundGlowColorWell" andTitle:@"color " comma:NO newLine:YES];
			if ( [[dict objectForKey:@"backgroundGlowTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"glowTransformations"]
					andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			break;
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
	NSDictionary *initialDefaults=[BackgroundTemplate createDefaults:menuTagTemplateBackground];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"backgroundDefaultSettings",
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
		[NSNumber numberWithInt:cBackground],							@"backgroundTabView",

		//background
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"backgroundColorWell",
		//fog
		@(cConstantFog),																	@"backgroundFogTypePopUp",
		@"0.0",																						@"backgroundFogDistanceEdit",
		@(NSOffState),																		@"backgroundFogUpOn",
		@(cXYZVectorPopupY),															@"backgroundFogUpXYZPopUp",
		@"0.0",																						@"backgroundFogUpMatrixX",
		@"0.0",																						@"backgroundFogUpMatrixY",
		@"0.0",																						@"backgroundFogUpMatrixZ",
		@(NSOffState),																		@"backgroundFogOffsetOn",
		@"0.0",																						@"backgroundFogOffsetEdit",
		@(NSOffState),																		@"backgroundFogAltitudeOn",
		@"0.0",																						@"backgroundFogAltitudeEdit",
		[NSArchiver archivedDataWithRootObject:[MPFTColorWell grayColorAndFilter:YES]],	@"backgroundFogColorColorWell",
		@(NSOffState),																		@"backgroundFogTurbulenceOn",
		@(cXYZVectorPopupXandYandZ),											@"backgroundFogTurbulenceXYZPopUp",
		@"0.0",																						@"backgroundFogTurbulenceMatrixX",
		@"0.0",																						@"backgroundFogTurbulenceMatrixY",
		@"0.0",																						@"backgroundFogTurbulenceMatrixZ",
		@(NSOffState),																		@"backgroundFogTurbulenceDepthOn",
		@"0.5",																						@"backgroundFogTurbulenceDepthEdit",
		@(NSOffState),																		@"backgroundFogOctavesOn",
		@"6",																							@"backgroundFogOctavesEdit",
		@(NSOffState),																		@"backgroundFogOmegaOn",
		@"0.5",																						@"backgroundFogOmegaEdit",
		@(NSOffState),																		@"backgroundFogLambdaOn",
		@"0.2",																						@"backgroundFogLambdaEdit",
		
		//rainbow
		@(cXYZVectorPopupZ),															@"backgroundRainbowDirectionXYZPopUp",
		@"0.0",																						@"backgroundRainbowDirectionMatrixX",
		@"0.1",																						@"backgroundRainbowDirectionMatrixY",
		@"0.0",																						@"backgroundRainbowDirectionMatrixZ",
		@"15",																						@"backgroundRainbowAngleEdit",
		@"4",																							@"backgroundRainbowWidthEdit",
		@"1000",																					@"backgroundRainbowDistanceEdit",
	//customized color map is in a dictionary because
	// we use it as preferences for the color map template
	// rainbow and b&w are not editable so they can be in colormap format directly
		[NSDictionary dictionaryWithObjectsAndKeys:
			[NSArchiver archivedDataWithRootObject:[colormap standardMapWithView:nil]],		@"colormap",nil
		],																															@"customizedColorMap",
		[NSArchiver archivedDataWithRootObject:	[colormap rainbowMapWithView:nil]],			@"rainbowColorMap",
		[NSArchiver archivedDataWithRootObject:	[colormap blackAndWhiteMapWithView:nil]],	@"blackAndWhiteColorMap",
		@(cRainBow),																			@"backgroundRainbowColorMapTabView",
		@(NSOffState),																		@"backgroundRainbowJitterOn",
		@"0.05",																					@"backgroundRainbowJitterEdit",
		@(NSOffState),																		@"backgroundRainbowUpOn",
		@(cXYZVectorPopupY),															@"backgroundRainbowUpXYZPopUp",
		@"0.0",																						@"backgroundRainbowUpMatrixX",
		@"0.0",																						@"backgroundRainbowUpMatrixY",
		@"0.0",																						@"backgroundRainbowUpMatrixZ",
		@(NSOnState),																			@"backgroundRainbowArcAngleOn",
		@"160",																						@"backgroundRainbowArcAngleEdit",
		@(NSOnState),																			@"backgroundRainbowFalloffAngleOn",
		@"60",																						@"backgroundRainbowFalloffAngleEdit",
		
	//skysphere
		@(NSOffState),																		@"backgroundSkyspherePigment2On",
		@(NSOffState),																		@"backgroundSkyspherePigment3On",
		@(NSOffState),																		@"backgroundSkyspherePigment4On",
		@(NSOffState),																		@"backgroundSkyspherePigment5On",
		
		//glow
		@(cGlowType0),																		@"backgroundGlowTypePopUp",
		@(cXYZVectorPopupXisYisZ),												@"backgroundGlowLocationXYZPopUp",
		@"0.0",																						@"backgroundGlowLocationMatrixX",
		@"0.0",																						@"backgroundGlowLocationMatrixY",
		@"0.0",																						@"backgroundGlowLocationMatrixZ",
		@"0.0",																						@"backgroundGlowSizeEdit",
		@"0.0",																						@"backgroundGlowRadiusEdit",
		@"0.0",																						@"backgroundGlowFadePowerEdit",
		@(NSOffState),																		@"backgroundGlowTransformationsOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"backgroundGlowColorWell",

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
		backgroundTabView,																@"backgroundTabView",
	//background
		backgroundColorWell,															@"backgroundColorWell",
	//fog
		backgroundFogTypePopUp,														@"backgroundFogTypePopUp",
		backgroundFogDistanceEdit,												@"backgroundFogDistanceEdit",
		backgroundFogUpOn,																@"backgroundFogUpOn",
		backgroundFogUpXYZPopUp,													@"backgroundFogUpXYZPopUp",
		[backgroundFogUpMatrix cellWithTag:0],						@"backgroundFogUpMatrixX",
		[backgroundFogUpMatrix cellWithTag:1],						@"backgroundFogUpMatrixY",
		[backgroundFogUpMatrix cellWithTag:2],						@"backgroundFogUpMatrixZ",
		backgroundFogOffsetOn,														@"backgroundFogOffsetOn",
		backgroundFogOffsetEdit,													@"backgroundFogOffsetEdit",
		backgroundFogAltitudeOn,													@"backgroundFogAltitudeOn",
		backgroundFogAltitudeEdit,												@"backgroundFogAltitudeEdit",
		backgroundFogColorColorWell,											@"backgroundFogColorColorWell",
		backgroundFogTurbulenceOn,												@"backgroundFogTurbulenceOn",
		backgroundFogTurbulenceXYZPopUp,									@"backgroundFogTurbulenceXYZPopUp",
		[backgroundFogTurbulenceMatrix cellWithTag:0],		@"backgroundFogTurbulenceMatrixX",
		[backgroundFogTurbulenceMatrix cellWithTag:1],		@"backgroundFogTurbulenceMatrixY",
		[backgroundFogTurbulenceMatrix cellWithTag:2],		@"backgroundFogTurbulenceMatrixZ",
		backgroundFogTurbulenceDepthOn,										@"backgroundFogTurbulenceDepthOn",
		backgroundFogTurbulenceDepthEdit,									@"backgroundFogTurbulenceDepthEdit",
		backgroundFogOctavesOn,														@"backgroundFogOctavesOn",
		backgroundFogOctavesEdit,													@"backgroundFogOctavesEdit",
		backgroundFogOmegaOn,															@"backgroundFogOmegaOn",
		backgroundFogOmegaEdit,														@"backgroundFogOmegaEdit",
		backgroundFogLambdaOn,														@"backgroundFogLambdaOn",
		backgroundFogLambdaEdit,													@"backgroundFogLambdaEdit",
	//rainbow
		backgroundRainbowDirectionXYZPopUp,								@"backgroundRainbowDirectionXYZPopUp",
		[backgroundRainbowDirectionMatrix cellWithTag:0],	@"backgroundRainbowDirectionMatrixX",
		[backgroundRainbowDirectionMatrix cellWithTag:1],	@"backgroundRainbowDirectionMatrixY",
		[backgroundRainbowDirectionMatrix cellWithTag:2],	@"backgroundRainbowDirectionMatrixZ",
		backgroundRainbowAngleEdit,												@"backgroundRainbowAngleEdit",
		backgroundRainbowWidthEdit,												@"backgroundRainbowWidthEdit",
		backgroundRainbowDistanceEdit,										@"backgroundRainbowDistanceEdit",
		backgroundRainbowColorMapTabView,									@"backgroundRainbowColorMapTabView",
		backgroundRainbowJitterOn,												@"backgroundRainbowJitterOn",
		backgroundRainbowJitterEdit,											@"backgroundRainbowJitterEdit",
		backgroundRainbowUpOn,														@"backgroundRainbowUpOn",
		backgroundRainbowUpXYZPopUp,											@"backgroundRainbowUpXYZPopUp",
		[backgroundRainbowUpMatrix cellWithTag:0],				@"backgroundRainbowUpMatrixX",
		[backgroundRainbowUpMatrix cellWithTag:1],				@"backgroundRainbowUpMatrixY",
		[backgroundRainbowUpMatrix cellWithTag:2],				@"backgroundRainbowUpMatrixZ",
		backgroundRainbowArcAngleOn,											@"backgroundRainbowArcAngleOn",
		backgroundRainbowArcAngleEdit,										@"backgroundRainbowArcAngleEdit",
		backgroundRainbowFalloffAngleOn,									@"backgroundRainbowFalloffAngleOn",
		backgroundRainbowFalloffAngleEdit,								@"backgroundRainbowFalloffAngleEdit",
	//skysphere
		backgroundSkyspherePigment2On,										@"backgroundSkyspherePigment2On",
		backgroundSkyspherePigment3On,										@"backgroundSkyspherePigment3On",
		backgroundSkyspherePigment4On,										@"backgroundSkyspherePigment4On",
		backgroundSkyspherePigment5On,										@"backgroundSkyspherePigment5On",
	//Glow
		backgroundGlowTypePopUp,													@"backgroundGlowTypePopUp",
		backgroundGlowLocationXYZPopUp,										@"backgroundGlowLocationXYZPopUp",
		[backgroundGlowLocationMatrix cellWithTag:0],			@"backgroundGlowLocationMatrixX",
		[backgroundGlowLocationMatrix cellWithTag:1],			@"backgroundGlowLocationMatrixY",
		[backgroundGlowLocationMatrix cellWithTag:2],			@"backgroundGlowLocationMatrixZ",
		backgroundGlowSizeEdit,														@"backgroundGlowSizeEdit",
		backgroundGlowRadiusEdit,													@"backgroundGlowRadiusEdit",
		backgroundGlowFadePowerEdit,											@"backgroundGlowFadePowerEdit",
		backgroundGlowTransformationsOn,									@"backgroundGlowTransformationsOn",
		backgroundGlowColorWell,													@"backgroundGlowColorWell",
	nil] ;
	
	[mOutlets retain];
	
	[ToolTipAutomator setTooltips:@"backgroundLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"backgroundLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			backgroundFogUpMatrix,								@"backgroundFogUpMatrix",
			backgroundFogTurbulenceMatrix,				@"backgroundFogTurbulenceMatrix",
			backgroundRainbowDirectionMatrix,			@"backgroundRainbowDirectionMatrix",
			backgroundRainbowUpMatrix,						@"backgroundRainbowUpMatrix",
			backgroundGlowLocationMatrix,					@"backgroundGlowLocationMatrix",

			backgroundColorMapEditButton,					@"backgroundColorMapEditButton",

			backgroundSkysphereEditPigment1Button,					@"backgroundSkysphereEditPigment1Button",
			backgroundSkysphereEditPigment2Button,					@"backgroundSkysphereEditPigment2Button",
			backgroundSkysphereEditPigment3Button,					@"backgroundSkysphereEditPigment3Button",
			backgroundSkysphereEditPigment4Button,					@"backgroundSkysphereEditPigment4Button",
			backgroundSkysphereEditPigment5Button,					@"backgroundSkysphereEditPigment5Button",



			backgroundGlowTransformationsButton, @"backgroundGlowTransformationsButton",
		nil]
		];
	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"backgroundTabView",
		nil];
	[mExcludedObjectsForReset retain];

	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	//customized color map is in a dictionary because
	// we use it as preferences for the color map template
	// rainbow and b&w are not editable so they can be in colormap format directly
	id cm=[preferences objectForKey:@"customizedColorMap"];
	if ( cm)
		cm=[cm objectForKey:@"colormap"];
	if( cm)
		[[NSUnarchiver unarchiveObjectWithData:cm] setPreview:backgroundRainbowColorMapCustomizedPreview];
 	[[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"rainbowColorMap"]]setPreview:backgroundRainbowColorMapRainbowPreview];
 	[[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"blackAndWhiteColorMap"]]setPreview:backgroundRainbowColorMapBlackAndWhitePreview];
	[self setGlowTransformations:[preferences objectForKey:@"glowTransformations"]];
	[self setBackgroundSkysphereEditPigment1:[preferences objectForKey:@"backgroundSkysphereEditPigment1"]];
	[self setBackgroundSkysphereEditPigment2:[preferences objectForKey:@"backgroundSkysphereEditPigment2"]];
	[self setBackgroundSkysphereEditPigment3:[preferences objectForKey:@"backgroundSkysphereEditPigment3"]];
	[self setBackgroundSkysphereEditPigment4:[preferences objectForKey:@"backgroundSkysphereEditPigment4"]];
	[self setBackgroundSkysphereEditPigment5:[preferences objectForKey:@"backgroundSkysphereEditPigment5"]];
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
	//customized color map is in a dictionary because
	// we use it as preferences for the color map template
	// rainbow and b&w are not editable so they can be in colormap format directly
	[dict setObject:[NSDictionary dictionaryWithObject:
								[NSArchiver archivedDataWithRootObject:[backgroundRainbowColorMapCustomizedPreview  map]] 
								forKey:@"colormap"]
								forKey:@"customizedColorMap"];
	[dict setObject:
								[NSArchiver archivedDataWithRootObject:[backgroundRainbowColorMapRainbowPreview  map]] 
								forKey:@"rainbowColorMap"];
	[dict setObject:
								[NSArchiver archivedDataWithRootObject:[backgroundRainbowColorMapBlackAndWhitePreview  map]] 
								forKey:@"blackAndWhiteColorMap"];

//store transformations if selected
	if ( glowTransformations != nil )
		if ( [[dict objectForKey:@"backgroundGlowTransformationsOn"]intValue]==NSOnState)
			[dict setObject:glowTransformations forKey:@"glowTransformations"];

//store skysphere pigment
	if ( backgroundSkysphereEditPigment1 != nil )
			[dict setObject:backgroundSkysphereEditPigment1 forKey:@"backgroundSkysphereEditPigment1"];

//store skysphere pigments if selected
	if ( backgroundSkysphereEditPigment2 != nil )
		if ( [[dict objectForKey:@"backgroundSkyspherePigment2On"]intValue]==NSOnState)
			[dict setObject:backgroundSkysphereEditPigment2 forKey:@"backgroundSkysphereEditPigment2"];
	if ( backgroundSkysphereEditPigment3 != nil )
		if ( [[dict objectForKey:@"backgroundSkyspherePigment3On"]intValue]==NSOnState)
			[dict setObject:backgroundSkysphereEditPigment3 forKey:@"backgroundSkysphereEditPigment3"];
	if ( backgroundSkysphereEditPigment4 != nil )
		if ( [[dict objectForKey:@"backgroundSkyspherePigment4On"]intValue]==NSOnState)
			[dict setObject:backgroundSkysphereEditPigment4 forKey:@"backgroundSkysphereEditPigment4"];
	if ( backgroundSkysphereEditPigment5 != nil )
		if ( [[dict objectForKey:@"backgroundSkyspherePigment5On"]intValue]==NSOnState)
			[dict setObject:backgroundSkysphereEditPigment5 forKey:@"backgroundSkysphereEditPigment5"];

}

//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	id obj;
	if( [key isEqualToString:@"customizedColorMap"])
	{
		obj=[dict objectForKey:@"colormap"];
		if ( obj != nil)// was default and removed from prefs, add a new default
			obj=[NSUnarchiver unarchiveObjectWithData:obj];
		else
			obj=[colormap standardMapWithView:nil];
		[obj setPreview:backgroundRainbowColorMapCustomizedPreview];
		[backgroundRainbowColorMapCustomizedPreview setNeedsDisplay:YES];
	}
	else	if( [key isEqualToString:@"glowTransformations"])
		[self setGlowTransformations:dict];
	else	if( [key isEqualToString:@"backgroundSkysphereEditPigment1"])
		[self setBackgroundSkysphereEditPigment1:dict];
	else	if( [key isEqualToString:@"backgroundSkysphereEditPigment2"])
		[self setBackgroundSkysphereEditPigment2:dict];
	else	if( [key isEqualToString:@"backgroundSkysphereEditPigment3"])
		[self setBackgroundSkysphereEditPigment3:dict];
	else	if( [key isEqualToString:@"backgroundSkysphereEditPigment4"])
		[self setBackgroundSkysphereEditPigment4:dict];
	else	if( [key isEqualToString:@"backgroundSkysphereEditPigment5"])
		[self setBackgroundSkysphereEditPigment5:dict];

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// backgroundButtons:sender
//---------------------------------------------------------------------
-(IBAction) backgroundButtons:(id)sender
{
	id 	prefs=nil;

	int tag=[sender tag];
	switch( tag)
	{
	//skysphere
		case cBackgroundSkysphereEditPigment1Button:
			if (backgroundSkysphereEditPigment1!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:backgroundSkysphereEditPigment1];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"backgroundSkysphereEditPigment1"];
			break;
		case cBackgroundSkysphereEditPigment2Button:
			if (backgroundSkysphereEditPigment2!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:backgroundSkysphereEditPigment2];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"backgroundSkysphereEditPigment2"];
			break;
		case cBackgroundSkysphereEditPigment3Button:
			if (backgroundSkysphereEditPigment1!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:backgroundSkysphereEditPigment3];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"backgroundSkysphereEditPigment3"];
			break;
		case cBackgroundSkysphereEditPigment4Button:
			if (backgroundSkysphereEditPigment1!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:backgroundSkysphereEditPigment4];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"backgroundSkysphereEditPigment4"];
			break;
		case cBackgroundSkysphereEditPigment5Button:
			if (backgroundSkysphereEditPigment1!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:backgroundSkysphereEditPigment5];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"backgroundSkysphereEditPigment5"];
			break;

	//Glow
		case cBackgroundGlowTransformationsButton:
			if (glowTransformations!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:glowTransformations];
			[self callTemplate:menuTagTemplateTransformations withDictionary:prefs andKeyName:@"glowTransformations"];
			break;
	//rainbow
		case cRainbowColorMapEditCustomizedColorMap:
			[self callTemplate:menuTagTemplateColormap 
					withDictionary:[NSMutableDictionary dictionaryWithObject:
											[NSArchiver archivedDataWithRootObject:
												[backgroundRainbowColorMapCustomizedPreview  map]
											] 
											forKey:@"colormap"
										]
					andKeyName:@"customizedColorMap"];
			break;
	}
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self backgroundTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// backgroundTarget:sender
//---------------------------------------------------------------------
-(IBAction) backgroundTarget:(id)sender
{
	int theTag;
	if ( sender==self)
		theTag=cBackgroundFogTypePopUp;
	else
		theTag=[sender tag];
	switch( theTag)
	{
//fog
		case 	cBackgroundFogTypePopUp:
			if ( [backgroundFogTypePopUp indexOfSelectedItem]==cGroundFog)
				[backgroundFogGroundfogView setHidden:NO];
			else
				[backgroundFogGroundfogView setHidden:YES];
			if ( sender !=self )	break;
		case 	cBackgroundFogUpOn:
			[self enableObjectsAccordingToObject:backgroundFogUpOn, backgroundFogUpXYZPopUp,backgroundFogUpMatrix,nil];
			if ( sender !=self )	break;
		case cBackgroundFogUpXYZPopUp:
			if ( [backgroundFogUpOn state]==NSOnState)
				[ self setXYZVectorAccordingToPopup:backgroundFogUpXYZPopUp xyzMatrix:backgroundFogUpMatrix];
			if ( sender !=self )	break;
		case 	cBackgroundFogOffsetOn:
			[self enableObjectsAccordingToObject:backgroundFogOffsetOn, backgroundFogOffsetEdit,nil];
			if ( sender !=self )	break;
		case 	cBackgroundFogAltitudeOn:
			[self enableObjectsAccordingToObject:backgroundFogAltitudeOn, backgroundFogAltitudeEdit,nil];
			if ( sender !=self )	break;
		
		

		case 	cBackgroundFogTurbulenceOn:
			[self enableObjectsAccordingToObject:backgroundFogTurbulenceOn, backgroundFogTurbulenceXYZPopUp,backgroundFogTurbulenceMatrix,nil];
			if ( sender !=self )	break;
		case cBackgroundFogTurbulenceXYZPopUp:
			if ( [backgroundFogTurbulenceOn state]==NSOnState)
				[ self setXYZVectorAccordingToPopup:backgroundFogTurbulenceXYZPopUp xyzMatrix:backgroundFogTurbulenceMatrix];
			if ( sender !=self )	break;
					
		case 	cBackgroundFogTurbulenceDepthOn:
			[self enableObjectsAccordingToObject:backgroundFogTurbulenceDepthOn, backgroundFogTurbulenceDepthEdit,nil];
			if ( sender !=self )	break;

		case 	cBackgroundFogOctavesOn:
			[self enableObjectsAccordingToObject:backgroundFogOctavesOn, backgroundFogOctavesEdit,nil];
			if ( sender !=self )	break;
		case 	cBackgroundFogOmegaOn:
			[self enableObjectsAccordingToObject:backgroundFogOmegaOn, backgroundFogOmegaEdit,nil];
			if ( sender !=self )	break;
		
		case 	cBackgroundFogLambdaOn:
			[self enableObjectsAccordingToObject:backgroundFogLambdaOn, backgroundFogLambdaEdit,nil];
			if ( sender !=self )	break;

//rainbow		
		
		case cBackgroundRainbowDirectionXYZPopUp:
			[ self setXYZVectorAccordingToPopup:backgroundRainbowDirectionXYZPopUp xyzMatrix:backgroundRainbowDirectionMatrix];
			if ( sender !=self )	break;
		case 	cBackgroundRainbowJitterOn:
			[self enableObjectsAccordingToObject:backgroundRainbowJitterOn, backgroundRainbowJitterEdit,nil];
			if ( sender !=self )	break;

		case 	cBackgroundRainbowUpOn:
			[self enableObjectsAccordingToObject:backgroundRainbowUpOn, backgroundRainbowUpXYZPopUp,backgroundRainbowUpMatrix,nil];
			if ( sender !=self )	break;
		case cBackgroundRainbowUpXYZPopUp:
			if ( [backgroundRainbowUpOn state]==NSOnState)
				[ self setXYZVectorAccordingToPopup:backgroundRainbowUpXYZPopUp xyzMatrix:backgroundRainbowUpMatrix];
			if ( sender !=self )	break;
		
		case 	cBackgroundRainbowArcAngleOn:
			[self enableObjectsAccordingToObject:backgroundRainbowArcAngleOn, backgroundRainbowArcAngleEdit,nil];
			if ( sender !=self )	break;
		case 	cBackgroundRainbowFalloffAngleOn:
			[self enableObjectsAccordingToObject:backgroundRainbowFalloffAngleOn, backgroundRainbowFalloffAngleEdit,nil];
			if ( sender !=self )	break;
//skysphere
		case 	cBackgroundSkyspherePigment2On:
			[self enableObjectsAccordingToObject:backgroundSkyspherePigment2On, backgroundSkysphereEditPigment2Button,nil];
			if ( sender !=self )	break;
		case 	cBackgroundSkyspherePigment3On:
			[self enableObjectsAccordingToObject:backgroundSkyspherePigment3On, backgroundSkysphereEditPigment3Button,nil];
			if ( sender !=self )	break;
		case 	cBackgroundSkyspherePigment4On:
			[self enableObjectsAccordingToObject:backgroundSkyspherePigment4On, backgroundSkysphereEditPigment4Button,nil];
			if ( sender !=self )	break;
		case 	cBackgroundSkyspherePigment5On:
			[self enableObjectsAccordingToObject:backgroundSkyspherePigment5On, backgroundSkysphereEditPigment5Button,nil];
			if ( sender !=self )	break;

//glow
		case cBackgroundGlowLocationXYZPopUp:
			[ self setXYZVectorAccordingToPopup:backgroundGlowLocationXYZPopUp xyzMatrix:backgroundGlowLocationMatrix];
			if ( sender !=self )	break;
		case 	cBackgroundGlowTransformationsOn:
			[self enableObjectsAccordingToObject:backgroundGlowTransformationsOn, backgroundGlowTransformationsButton,nil];
			if ( sender !=self )	break;

			

	}
	[self setModified:nil];
}


@end
