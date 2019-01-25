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
#import "lightTemplate.h"
#import "standardMethods.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cDirectionalLightSpotLight = 0,
	cDirectionalLightCylindricalLight =1,
	
	cFadePowerLinear	= 0,
	cFadePowerQuadratic=1
};

@implementation LightTemplate


//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[LightTemplate createDefaults:menuTagTemplateLight];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[LightTemplate class] andTemplateType:menuTagTemplateLight];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	[ds copyTabAndText:@"light_source {\n"];
	[ds addTab];

//location
	[ds appendTabAndFormat:@"< %@, %@, %@>\n",[dict objectForKey:@"lightLocationMatrixX"],
																					[dict objectForKey:@"lightLocationMatrixY"],
																					[dict objectForKey:@"lightLocationMatrixZ"]];
//Color
	[ds copyTabText];
	[ds addRGBColor:dict forKey:@"lightColor" andTitle:@"" comma:NO newLine:NO];
	[ds appendTabAndFormat:@" * %@\n",[dict objectForKey:@"lightColorFactorEdit"]];
	
	if ( [[dict objectForKey:@"lightParallelLightOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"parallel\n"];
		[ds appendTabAndFormat:@"point_at < %@, %@, %@>\n",[dict objectForKey:@"lightParallelLightPointAtMatrixX"],
																					[dict objectForKey:@"lightParallelLightPointAtMatrixY"],
																					[dict objectForKey:@"lightParallelLightPointAtMatrixZ"]];
	}

//Directional light
	if ( [[dict objectForKey:@"lightDirectionalLightGroupOn"] intValue]==NSOnState)
	{
		//spot or cylinder
		if ( [[dict objectForKey:@"lightDirectionalLightTypePopup"] intValue]==cDirectionalLightSpotLight)
			[ds copyTabAndText:@"spotlight\n "];
		else
			[ds copyTabAndText:@"cylinder\n "];
		// point at
		[ds appendTabAndFormat:@"point_at < %@, %@, %@>\n",[dict objectForKey:@"lightDirectionalLightPointAtMatrixX"],
																					[dict objectForKey:@"lightDirectionalLightPointAtMatrixY"],
																					[dict objectForKey:@"lightDirectionalLightPointAtMatrixZ"]];

		[ds appendTabAndFormat:@"radius %@\n",[dict objectForKey:@"lightDirectionalLightRadiusAngleEdit"]];
		[ds appendTabAndFormat:@"falloff %@\n",[dict objectForKey:@"lightDirectionalLightFallOfAngleEdit"]];
		[ds appendTabAndFormat:@"tightness %@\n",[dict objectForKey:@"lightDirectionalLightTightnessEdit"]];
	}
//Area light
	if ( [[dict objectForKey:@"lightAreaLightGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"area_light "];
		[ds addXYZVector:dict popup:@"lightAreaLightAxis1Popup" xKey:@"lightAreaLightAxis1MatrixX" yKey:@"lightAreaLightAxis1MatrixY" zKey:@"lightAreaLightAxis1MatrixZ"];

		[ds copyText:@", "];
		[ds addXYZVector:dict popup:@"lightAreaLightAxis2Popup" xKey:@"lightAreaLightAxis2MatrixX" yKey:@"lightAreaLightAxis2MatrixY" zKey:@"lightAreaLightAxis2MatrixZ"];

		[ds appendTabAndFormat:@", %@",[dict objectForKey:@"lightAreaLightAxis1SizeEdit"]];
		[ds appendTabAndFormat:@", %@\n",[dict objectForKey:@"lightAreaLightAxis2SizeEdit"]];
		// adaptive 
		if ( [[dict objectForKey:@"lightAreaLightAdaptiveOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"adaptive %@\n",[dict objectForKey:@"lightAreaLightAdaptiveEdit"]];
		// jitter 
		if ( [[dict objectForKey:@"lightAreaLightJitterOn"] intValue]==NSOnState)
			[ds copyTabAndText:@"jitter\n "];
		if ( [[dict objectForKey:@"lightAreaLightAreaIllumination"] intValue]==NSOnState)
			[ds copyTabAndText:@"area_illumination\n"];

	}

	// photons 
	if ( [[dict objectForKey:@"lightPhotonsGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"photons {\n"];
		[ds addTab];
		if ( [[dict objectForKey:@"lightPhotonsReflectionOn"] intValue]==NSOnState)
		{
			if ( [[dict objectForKey:@"lightPhotonsReflectionMatrix"] intValue]==cFirstCell)
				[ds copyTabAndText:@"reflection on\n"];
			else
				[ds copyTabAndText:@"reflection off\n"];
		}
		if ( [[dict objectForKey:@"lightPhotonsRefractionOn"] intValue]==NSOnState)
		{
			if ( [[dict objectForKey:@"lightPhotonsRefractionMatrix"] intValue]==cFirstCell)
				[ds copyTabAndText:@"refraction on\n"];
			else
				[ds copyTabAndText:@"reflection off\n"];
		}
		if ( [[dict objectForKey:@"lightPhotonsAreaLightOn"] intValue]==NSOnState)
			[ds copyTabAndText:@"area_light\n"];
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}		

	// looks_like 
	if ( [[dict objectForKey:@"lightLooksLikeOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"looks_like { }\n"];

	// fade distance 
	if ( [[dict objectForKey:@"lightFadeDistanceOn"] intValue]==NSOnState)
	{
		[ds appendTabAndFormat:@"fade_distance %@\n",[dict objectForKey:@"lightFadeDistanceEdit"]];
		// fade power
		if ( [[dict objectForKey:@"lightFadePowerPopup"] intValue]==cFadePowerLinear)
			[ds copyTabAndText:@"fade_power 1\t//linear\n"];
		else
			[ds copyTabAndText:@"fade_power 2\t//quadratic\n"];
	}

	// shadowless
	if ( [[dict objectForKey:@"lightShadowlessOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"shadowless\n"];

	// atmosphere
	if ( [[dict objectForKey:@"lightMediaInteractionOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"media_interaction off\n"];

	// atmospheric attenuation
	if ( [[dict objectForKey:@"lightMediaAttenuationOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"media_attenuation\n"];

	if ( [[dict objectForKey:@"lightAreaLightGroupOn"] intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"lightAreaLightOrientOn"] intValue]==NSOnState)
			[ds copyTabAndText:@"orient\n"];

		if ( [[dict objectForKey:@"lightAreaLightCircularOn"] intValue]==NSOnState)
			[ds copyTabAndText:@"circular\n"];
	}	

	if ( [[dict objectForKey:@"lightProjectedTroughOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"projected_through { %@ }\n",[dict objectForKey:@"lightProjectedTroughObjectEdit"]];

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
	NSDictionary *initialDefaults=[LightTemplate createDefaults:menuTagTemplateLight];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"lightDefaultSettings",
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

		@"0.0",																					@"lightLocationMatrixX",	
		@"100",																					@"lightLocationMatrixY",
		@"100",																					@"lightLocationMatrixZ",	
		[NSArchiver archivedDataWithRootObject:[MPColorWell whiteColorAndFilter:NO]], 	@"lightColor",
		@"1.0",																					@"lightColorFactorEdit",

		@(NSOffState),									@"lightLooksLikeOn",
		@(NSOffState),									@"lightShadowlessOn",
		@(NSOffState),									@"lightFadeDistanceOn",
		@"1.0",																					@"lightFadeDistanceEdit",
		[NSNumber numberWithInt:cFadePowerLinear],							@"lightFadePowerPopup",

		@(NSOffState),									@"lightProjectedTroughOn",
		@"MyObject",																			@"lightProjectedTroughObjectEdit",
		
		@"0.0",																					@"lightDirectionalLightPointAtMatrixX",
		@"0.0",																					@"lightDirectionalLightPointAtMatrixY",
		@"0.0",																					@"lightDirectionalLightPointAtMatrixZ",
		[NSNumber numberWithInt:cDirectionalLightSpotLight],				@"lightDirectionalLightTypePopup",
		@"15",																					@"lightDirectionalLightRadiusAngleEdit",
		@"10",																					@"lightDirectionalLightTightnessEdit",
		@"30",																					@"lightDirectionalLightFallOfAngleEdit",

		@(NSOffState),									@"lightDirectionalLightGroupOn",

//area
		@(NSOffState),									@"lightAreaLightGroupOn",
		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"lightAreaLightAxis1Popup",
		@"0.0",																					@"lightAreaLightAxis1MatrixX",
		@"5.0",																					@"lightAreaLightAxis1MatrixY",
		@"5.0",																					@"lightAreaLightAxis1MatrixZ",
		@"5",																						@"lightAreaLightAxis1SizeEdit",

		[NSNumber numberWithInt:cXYZVectorPopupX],						@"lightAreaLightAxis2Popup",
		@"5.0",																					@"lightAreaLightAxis2MatrixX",
		@"0.0",																					@"lightAreaLightAxis2MatrixY",
		@"0.0",																					@"lightAreaLightAxis2MatrixZ",
		@"5",																						@"lightAreaLightAxis2SizeEdit",
		
		@(NSOffState),									@"lightAreaLightAdaptiveOn",
		@"1",																						@"lightAreaLightAdaptiveEdit",
		@(NSOffState),									@"lightAreaLightAreaIllumination",
//		@"1",																						@"lightAreaLightMaxTraceEdit",
		@(NSOffState),									@"lightAreaLightJitterOn",
		@(NSOffState),									@"lightAreaLightCircularOn",
		@(NSOffState),									@"lightAreaLightOrientOn",

		@(NSOffState),									@"lightMediaAttenuationOn",
		@(NSOffState),									@"lightMediaInteractionOn",

//photons
		@(NSOffState),									@"lightPhotonsGroupOn",
		@(NSOffState),									@"lightPhotonsReflectionOn",
		[NSNumber numberWithInt:cFirstCell],										@"lightPhotonsReflectionMatrix",
		@(NSOffState),									@"lightPhotonsRefractionOn",
		[NSNumber numberWithInt:cFirstCell],										@"lightPhotonsRefractionMatrix",
		@(NSOffState),									@"lightPhotonsAreaLightOn",

		@(NSOffState),									@"lightParallelLightOn",
		@"0.0",																					@"lightParallelLightPointAtMatrixX",
		@"0.0",																					@"lightParallelLightPointAtMatrixY",
		@"0.0",																					@"lightParallelLightPointAtMatrixZ",
		
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

		[lightLocationMatrix cellWithTag:0],	@"lightLocationMatrixX",	
		[lightLocationMatrix cellWithTag:1],	@"lightLocationMatrixY",
		[lightLocationMatrix cellWithTag:2],	@"lightLocationMatrixZ",	
		lightColor,														@"lightColor",
		lightColorFactorEdit,									@"lightColorFactorEdit",
		lightLooksLikeOn,											@"lightLooksLikeOn",
		lightShadowlessOn,										@"lightShadowlessOn",
		lightFadeDistanceOn,									@"lightFadeDistanceOn",
		lightFadeDistanceEdit,								@"lightFadeDistanceEdit",
		lightFadePowerPopup,									@"lightFadePowerPopup",

		lightProjectedTroughOn,								@"lightProjectedTroughOn",
		lightProjectedTroughObjectEdit,				@"lightProjectedTroughObjectEdit",
		
		[lightDirectionalLightPointAtMatrix cellWithTag:0],	@"lightDirectionalLightPointAtMatrixX",
		[lightDirectionalLightPointAtMatrix cellWithTag:1],	@"lightDirectionalLightPointAtMatrixY",
		[lightDirectionalLightPointAtMatrix cellWithTag:2],	@"lightDirectionalLightPointAtMatrixZ",
		lightDirectionalLightTypePopup,					@"lightDirectionalLightTypePopup",
		lightDirectionalLightRadiusAngleEdit,		@"lightDirectionalLightRadiusAngleEdit",
		lightDirectionalLightTightnessEdit,			@"lightDirectionalLightTightnessEdit",
		lightDirectionalLightFallOfAngleEdit,		@"lightDirectionalLightFallOfAngleEdit",

		lightDirectionalLightGroupOn,						@"lightDirectionalLightGroupOn",

//area
		lightAreaLightGroupOn,										@"lightAreaLightGroupOn",
		lightAreaLightAxis1Popup,									@"lightAreaLightAxis1Popup",
		[lightAreaLightAxis1Matrix cellWithTag:0],@"lightAreaLightAxis1MatrixX",
		[lightAreaLightAxis1Matrix cellWithTag:1],@"lightAreaLightAxis1MatrixY",
		[lightAreaLightAxis1Matrix cellWithTag:2],@"lightAreaLightAxis1MatrixZ",
		lightAreaLightAxis1SizeEdit,							@"lightAreaLightAxis1SizeEdit",

		lightAreaLightAxis2Popup,								@"lightAreaLightAxis2Popup",
		[lightAreaLightAxis2Matrix cellWithTag:0],			@"lightAreaLightAxis2MatrixX",
		[lightAreaLightAxis2Matrix cellWithTag:1],			@"lightAreaLightAxis2MatrixY",
		[lightAreaLightAxis2Matrix cellWithTag:2],			@"lightAreaLightAxis2MatrixZ",
		lightAreaLightAxis2SizeEdit,								@"lightAreaLightAxis2SizeEdit",
		
		lightAreaLightAdaptiveOn,								@"lightAreaLightAdaptiveOn",
		lightAreaLightAdaptiveEdit,								@"lightAreaLightAdaptiveEdit",
		lightAreaLightAreaIllumination,								@"lightAreaLightAreaIllumination",
		lightAreaLightJitterOn,										@"lightAreaLightJitterOn",
		lightAreaLightCircularOn,									@"lightAreaLightCircularOn",
		lightAreaLightOrientOn,									@"lightAreaLightOrientOn",

		lightMediaAttenuationOn,								@"lightMediaAttenuationOn",
		lightMediaInteractionOn,									@"lightMediaInteractionOn",

//photons
		lightPhotonsGroupOn,										@"lightPhotonsGroupOn",
		lightPhotonsReflectionOn,								@"lightPhotonsReflectionOn",
		lightPhotonsReflectionMatrix,							@"lightPhotonsReflectionMatrix",
		lightPhotonsRefractionOn,								@"lightPhotonsRefractionOn",
		lightPhotonsRefractionMatrix,							@"lightPhotonsRefractionMatrix",
		lightPhotonsAreaLightOn,									@"lightPhotonsAreaLightOn",

		lightParallelLightOn,										@"lightParallelLightOn",
		[lightParallelLightPointAtMatrix cellWithTag:0],	@"lightParallelLightPointAtMatrixX",
		[lightParallelLightPointAtMatrix cellWithTag:1],	@"lightParallelLightPointAtMatrixY",
		[lightParallelLightPointAtMatrix cellWithTag:2],	@"lightParallelLightPointAtMatrixZ",
		
	nil];
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"lightLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"lightLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			lightParallelLightPointAtMatrix,					@"lightParallelLightPointAtMatrix",
			lightAreaLightAxis2Matrix,		@"lightAreaLightAxis2Matrix",
			lightAreaLightAxis1Matrix,		@"lightAreaLightAxis1Matrix",
			lightDirectionalLightPointAtMatrix,		@"lightDirectionalLightPointAtMatrix",
			lightLocationMatrix,		@"lightLocationMatrix",
		nil]
		];
	
	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self lightFadeDistanceOn:nil];
	[self lightProjectedTroughOn:nil];
	[self lightAreaLightAdaptiveOn:nil];
	
	[self lightAreaLightGroupOn:nil];
	[self lightAreaLightAxis2Popup:nil];
	[self lightAreaLightAxis1Popup:nil];
	[self lightDirectionalLightGroupOn:nil];
	[self lightFadeDistanceOn:nil];

	[self lightPhotonsGroupChanged:nil];
	[self setNotModified];
}

//---------------------------------------------------------------------
// lightAreaLightAdaptiveOn
//---------------------------------------------------------------------
- (IBAction)lightAreaLightAdaptiveOn:(id)sender
{
	[self enableObjectsAccordingToObject:lightAreaLightAdaptiveOn, 
			lightAreaLightAdaptiveEdit, nil];
	[self setModified:nil];
}

//---------------------------------------------------------------------
// lightAreaLightAxis1Popup
//---------------------------------------------------------------------
- (IBAction)lightAreaLightAxis1Popup:(id)sender
{
	[ self setXYZVectorAccordingToPopup:lightAreaLightAxis1Popup xyzMatrix:lightAreaLightAxis1Matrix];
	[self setModified:nil];
}

//---------------------------------------------------------------------
// lightAreaLightAxis2PopuptGroupOn
//---------------------------------------------------------------------
- (IBAction)lightAreaLightAxis2Popup:(id)sender
{
	[ self setXYZVectorAccordingToPopup:lightAreaLightAxis2Popup xyzMatrix:lightAreaLightAxis2Matrix];
	[self setModified:nil];
}

//---------------------------------------------------------------------
// lightAreaLightGroupOn
//---------------------------------------------------------------------
- (IBAction)lightAreaLightGroupOn:(id)sender
{
	[self setSubViewsOfNSBox:lightAreaLightGroupBox toNSButton:lightAreaLightGroupOn];
	if ([lightAreaLightGroupOn state]==NSOnState)
	{
		[self lightAreaLightAdaptiveOn:nil];
	}

	[self setModified:nil];
}


//---------------------------------------------------------------------
// lightDirectionalLightGroupOn
//---------------------------------------------------------------------
- (IBAction)lightDirectionalLightGroupOn:(id)sender
{
	[self setSubViewsOfNSBox:lightDirectionalLightGroupBox toNSButton:lightDirectionalLightGroupOn];
	[self setModified:nil];
}


//---------------------------------------------------------------------
// lightFadeDistanceOn
//---------------------------------------------------------------------
- (IBAction)lightFadeDistanceOn:(id)sender
{
	[self enableObjectsAccordingToObject:lightFadeDistanceOn, 
			lightFadeDistanceEdit, lightFadePowerPopup, nil];
	[self setModified:nil];
}

//---------------------------------------------------------------------
// lightPhotonsGroupOn
//---------------------------------------------------------------------
- (IBAction)lightPhotonsGroupChanged:(id)sender
{
	[self setSubViewsOfNSBox:lightPhotonsGroupBox toNSButton:lightPhotonsGroupOn];
	if ( [lightPhotonsGroupOn state]==NSOnState)
	{
		[ self lightPhotonsReflectionOn];
		[self lightPhotonsRefractionOn];
	}
[self setModified:nil];

}

//---------------------------------------------------------------------
// lightPhotonsReflectionOn
//---------------------------------------------------------------------
- (void)lightPhotonsReflectionOn
{
	[self enableObjectsAccordingToObject:lightPhotonsReflectionOn, 
			lightPhotonsReflectionMatrix,nil];
	[self setModified:nil];
}

//---------------------------------------------------------------------
// lightPhotonsRefractionOn
//---------------------------------------------------------------------
- (void)lightPhotonsRefractionOn
{
	[self enableObjectsAccordingToObject:lightPhotonsRefractionOn, 
			lightPhotonsRefractionMatrix,nil];
}

//---------------------------------------------------------------------
// lightProjectedTroughOn
//---------------------------------------------------------------------
- (IBAction)lightProjectedTroughOn:(id)sender
{
	[self enableObjectsAccordingToObject:lightProjectedTroughOn, 
			lightProjectedTroughObjectEdit, nil];
	[self setModified:nil];

}


@end
