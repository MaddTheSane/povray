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
#import "finishTemplate.h"
#import "tooltipAutomator.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation FinishTemplate

//---------------------------------------------------------------------
// finishMainViewNIBView
//---------------------------------------------------------------------
-(NSView*) finishMainViewNIBView
{
	return finishMainViewNIBView;
}

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{

	if ( dict== nil)
		dict=[FinishTemplate createDefaults:menuTagTemplateFinish];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[FinishTemplate class] andTemplateType:menuTagTemplateFinish];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	if ( [[dict objectForKey:@"finishDontWrapInFinish"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"finish {\n"];
		[ds addTab];
	}

//Ambient light
	if ( [[dict objectForKey:@"finishAmbientColorGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"finishAmbientColorColorWell" andTitle:@"ambient " comma:NO newLine:YES];
	}

//emission light
	if ( [[dict objectForKey:@"finishEmissionColorGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"finishEmissionColorColorWell" andTitle:@"emission " comma:NO newLine:YES];
	}
//SubsurfaceLightTransport
	if ( [[dict objectForKey:@"finishSubsurfaceLightTransportColorGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"subsurface { "];
		[ds addRGBColor:dict forKey:@"finishSubsurfaceLightTransportColorColorWell" andTitle:@"translucency " comma:NO newLine:NO];
		[ds copyText:@"}\n"];
	}


//Reflection light
	if ( [[dict objectForKey:@"finishReflectionLightGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"reflection {\n"];
		[ds addTab];
		if ( [[dict objectForKey:@"finishReflectionVariableGroupOn"] intValue]==NSOnState)
		{
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"finishReflectionVariableMinColorColorWell" andTitle:@"" comma:YES newLine:YES];
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"finishReflectionMaxColorColorWell" andTitle:@"" comma:NO newLine:YES];
			if ( [[dict objectForKey:@"finishReflectionVariableFresnelOn"] intValue]==NSOnState)
				[ds copyTabAndText:@"fresnel\n"];
			if ( [[dict objectForKey:@"finishReflectionVariableFalloffOn"] intValue]==NSOnState)
				[ds appendTabAndFormat:@"falloff %@\n",[dict objectForKey:@"finishReflectionVariableFalloffEdit"]];
		}
		else
		{
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"finishReflectionMaxColorColorWell" andTitle:@"" comma:NO newLine:YES];
		}
		if ( [[dict objectForKey:@"finishReflectionExponentOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"exponent %@\n",[dict objectForKey:@"finishReflectionExponentEdit"]];
		if ( [[dict objectForKey:@"finishReflectionMetallicOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"metallic %@\n",[dict objectForKey:@"finishReflectionMetallicEdit"]];
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}
	
//Iridescene
	if ( [[dict objectForKey:@"finishIridescenceGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"irid {\n"];
		[ds addTab];
		[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"finishIridescenceAmountEdit"]];
		[ds appendTabAndFormat:@"thickness %@\n",[dict objectForKey:@"finishIridescenceThicknessEdit"]];
		[ds copyTabAndText:@"turbulence "];
		[ds addXYZVector:dict  popup:@"finishIridescenceTurbulencePopUp" xKey:@"finishIridescenceTurbulenceMatrixX" yKey:@"finishIridescenceTurbulenceMatrixY" zKey:@"finishIridescenceTurbulenceMatrixZ"];
		[ds copyTabAndText:@"\n"];
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}	

	if ( [[dict objectForKey:@"finishDiffuseOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"diffuse %@",[dict objectForKey:@"finishDiffuseEdit"]];
	if ( [[dict objectForKey:@"finishBacksideOn"] intValue]==NSOnState)
		[ds appendFormat:@", %@\n",[dict objectForKey:@"finishBacksideEdit"]];
	else
		[ds copyText:@"\n"];
	if ( [[dict objectForKey:@"finishBrillianceOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"brilliance %@\n",[dict objectForKey:@"finishBrillianceEdit"]];
	if ( [[dict objectForKey:@"finishCrandOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"crand %@\n",[dict objectForKey:@"finishCrandEdit"]];

	if ( [[dict objectForKey:@"finishPhongOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"phong %@\n",[dict objectForKey:@"finishPhongEdit"]];
	if ( [[dict objectForKey:@"finishPhongSizeOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"phong_size %@\n",[dict objectForKey:@"finishPhongSizeEdit"]];
	if ( [[dict objectForKey:@"finishSpecularOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"specular %@\n",[dict objectForKey:@"finishSpecularEdit"]];
	if ( [[dict objectForKey:@"finishRoghnessOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"roughness %@\n",[dict objectForKey:@"finishRoghnessEdit"]];

	if ( [[dict objectForKey:@"finishMetallicOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"metallic %@\n",[dict objectForKey:@"finishMetallicEdit"]];

	if ( [[dict objectForKey:@"finishConserveEnergyOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"conserve_energy\n"];

	if ( [[dict objectForKey:@"finishDontWrapInFinish"]intValue]==NSOffState)
	{
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}

	
//	[ds autorelease];
	[dict release];
	return ds;
}


//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[FinishTemplate createDefaults:menuTagTemplateFinish];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"finishDefaultSettings",
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
		[NSNumber numberWithInt:NSOffState],						@"finishDontWrapInFinish",
		[NSNumber numberWithInt:NSOnState],							@"finishDiffuseOn",
		@"0.6",																					@"finishDiffuseEdit",
		[NSNumber numberWithInt:NSOnState],							@"finishBacksideOn",
		@"0.6",																					@"finishBacksideEdit",
		[NSNumber numberWithInt:NSOnState],							@"finishBrillianceOn",
		@"1.0",																					@"finishBrillianceEdit",
		[NSNumber numberWithInt:NSOffState],						@"finishCrandOn",
		@"0.0",																					@"finishCrandEdit",

		[NSNumber numberWithInt:NSOffState],						@"finishAmbientColorGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"finishAmbientColorColorWell",

		[NSNumber numberWithInt:NSOffState],						@"finishAmbientColorGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"finishAmbientColorColorWell",


		[NSNumber numberWithInt:NSOffState],						@"finishSubsurfaceLightTransportColorGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell grayColorAndFilter:NO]],	@"finishSubsurfaceLightTransportColorColorWell",

		[NSNumber numberWithInt:NSOffState],						@"finishPhongOn",
		@"1.0",																					@"finishPhongEdit",
		[NSNumber numberWithInt:NSOffState],						@"finishPhongSizeOn",
		@"350",																					@"finishPhongSizeEdit",
		[NSNumber numberWithInt:NSOffState],						@"finishSpecularOn",
		@"1.0",																					@"finishSpecularEdit",
		[NSNumber numberWithInt:NSOffState],						@"finishRoghnessOn",
		@"0.0005",																			@"finishRoghnessEdit",
		[NSNumber numberWithInt:NSOffState],						@"finishMetallicOn",
		@"1.0",																					@"finishMetallicEdit",

		[NSNumber numberWithInt:NSOffState],								@"finishIridescenceGroupOn",
		@"0.0",																							@"finishIridescenceAmountEdit",
		@"0.0",																							@"finishIridescenceThicknessEdit",
		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],	@"finishIridescenceTurbulencePopUp",
		@"0.0",																							@"finishIridescenceTurbulenceMatrixX",
		@"1.0",																							@"finishIridescenceTurbulenceMatrixY",
		@"0.0",																							@"finishIridescenceTurbulenceMatrixZ",
		
		[NSNumber numberWithInt:NSOffState],	 							@"finishReflectionLightGroupOn",
		[NSNumber numberWithInt:NSOffState],	 							@"finishReflectionVariableGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell blackColorAndFilter:NO]],	@"finishReflectionVariableMinColorColorWell",
		[NSNumber numberWithInt:NSOffState], 								@"finishReflectionVariableFresnelOn",
		[NSNumber numberWithInt:NSOffState], 								@"finishReflectionVariableFalloffOn",
		@"1.0",																							@"finishReflectionVariableFalloffEdit",
		[NSArchiver archivedDataWithRootObject:[MPColorWell blackColorAndFilter:NO]],	@"finishReflectionMaxColorColorWell",
		[NSNumber numberWithInt:NSOffState], 								@"finishReflectionExponentOn",
		@"1.0",																							@"finishReflectionExponentEdit",
		[NSNumber numberWithInt:NSOffState],	 							@"finishReflectionMetallicOn",
		@"1.0",																							@"finishReflectionMetallicEdit",
		[NSNumber numberWithInt:NSOffState],								@"finishConserveEnergyOn",
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
		finishDontWrapInFinish,															@"finishDontWrapInFinish",
		finishDiffuseOn,																		@"finishDiffuseOn",
		finishDiffuseEdit,																	@"finishDiffuseEdit",
		finishBacksideOn,																		@"finishBacksideOn",
		finishBacksideEdit,																	@"finishBacksideEdit",
		finishBrillianceOn,																	@"finishBrillianceOn",
		finishBrillianceEdit,																@"finishBrillianceEdit",
		finishCrandOn,																			@"finishCrandOn",
		finishCrandEdit,																		@"finishCrandEdit",
		finishAmbientColorGroupOn,													@"finishAmbientColorGroupOn",
		finishAmbientColorColorWell,												@"finishAmbientColorColorWell",
		finishEmissionColorGroupOn,													@"finishEmissionColorGroupOn",
		finishEmissionColorColorWell,												@"finishEmissionColorColorWell",
		finishSubsurfaceLightTransportColorGroupOn,					@"finishSubsurfaceLightTransportColorGroupOn",
		finishSubsurfaceLightTransportColorColorWell,				@"finishSubsurfaceLightTransporttColorColorWell",

		finishPhongOn,																			@"finishPhongOn",
		finishPhongEdit,																		@"finishPhongEdit",
		finishPhongSizeOn,																	@"finishPhongSizeOn",
		finishPhongSizeEdit,																@"finishPhongSizeEdit",
		finishSpecularOn,																		@"finishSpecularOn",
		finishSpecularEdit,																	@"finishSpecularEdit",
		finishRoghnessOn,																		@"finishRoghnessOn",
		finishRoghnessEdit,																	@"finishRoghnessEdit",
		finishMetallicOn,																		@"finishMetallicOn",
		finishMetallicEdit,																	@"finishMetallicEdit",
		finishIridescenceGroupOn,														@"finishIridescenceGroupOn",
		finishIridescenceAmountEdit,												@"finishIridescenceAmountEdit",
		finishIridescenceThicknessEdit,											@"finishIridescenceThicknessEdit",
		finishIridescenceTurbulencePopUp,										@"finishIridescenceTurbulencePopUp",
		[finishIridescenceTurbulenceMatrix cellWithTag:0],	@"finishIridescenceTurbulenceMatrixX",
		[finishIridescenceTurbulenceMatrix cellWithTag:1],	@"finishIridescenceTurbulenceMatrixY",
		[finishIridescenceTurbulenceMatrix cellWithTag:2],	@"finishIridescenceTurbulenceMatrixZ",
		finishReflectionLightGroupOn,												@"finishReflectionLightGroupOn",
		finishReflectionVariableGroupOn,										@"finishReflectionVariableGroupOn",
		finishReflectionVariableMinColorColorWell,					@"finishReflectionVariableMinColorColorWell",
		finishReflectionVariableFresnelOn,									@"finishReflectionVariableFresnelOn",
		finishReflectionVariableFalloffOn,									@"finishReflectionVariableFalloffOn",
		finishReflectionVariableFalloffEdit,								@"finishReflectionVariableFalloffEdit",
		finishReflectionMaxColorColorWell,									@"finishReflectionMaxColorColorWell",
		finishReflectionExponentOn,													@"finishReflectionExponentOn",
		finishReflectionExponentEdit,												@"finishReflectionExponentEdit",
		finishReflectionMetallicOn,													@"finishReflectionMetallicOn",
		finishReflectionMetallicEdit,												@"finishReflectionMetallicEdit",
		finishConserveEnergyOn,															@"finishConserveEnergyOn",
	nil] ;
	
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"finishLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"finishLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			finishIridescenceTurbulenceMatrix,					@"finishIridescenceTurbulenceMatrix",
		nil]
		];

	[finishMainViewHolderView  addSubview:finishMainViewNIBView];

	[self  setValuesInPanel:[self preferences]];
}



//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self finishTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// finishTarget:sender
//---------------------------------------------------------------------
-(IBAction) finishTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cFinishAmbientLightGroupOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cFinishAmbientLightGroupOn:
			[self setSubViewsOfNSBox:finishAmbientColorGroup toNSButton:finishAmbientColorGroupOn];
			if ( sender !=self )	break;
		case 	cFinishEmissionGroupOn:
			[self setSubViewsOfNSBox:finishEmissionColorGroup toNSButton:finishEmissionColorGroupOn];
			if ( sender !=self )	break;
		case 	cFinishSubsurfaceLightTransportGroupOn:
			[self setSubViewsOfNSBox:finishSubsurfaceLightTransportColorGroup toNSButton:finishSubsurfaceLightTransportColorGroupOn];
			if ( sender !=self )	break;

		case 	cFinishReflectionVariableGroupOn:
			if ( [finishReflectionLightGroupOn state]==NSOnState)
				[self setSubViewsOfNSBox:finishReflectionVariableGroup toNSButton:finishReflectionVariableGroupOn];
			else
				[self setSubViewsOfNSBox:finishReflectionVariableGroup toNSButton:finishReflectionLightGroupOn];
			if ( sender !=self )	break;
		case 	cFinishReflectionVariableFallOffOn:
			[self enableObjectsAccordingToObject:finishReflectionVariableFalloffOn, finishReflectionVariableFalloffEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishReflectionLightGroupOn:
			[self setSubViewsOfNSBox:finishReflectionLightGroup toNSButton:finishReflectionLightGroupOn];
			if ( [finishReflectionLightGroupOn state]==NSOnState)
				[self setSubViewsOfNSBox:finishReflectionVariableGroup toNSButton:finishReflectionVariableGroupOn];
			else
				[self setSubViewsOfNSBox:finishReflectionVariableGroup toNSButton:finishReflectionLightGroupOn];
			[self enableObjectsAccordingToObject:finishReflectionMetallicOn, finishReflectionMetallicEdit,nil];
			[self enableObjectsAccordingToObject:finishReflectionExponentOn, finishReflectionExponentEdit,nil];
			[self enableObjectsAccordingToObject:finishReflectionVariableFalloffOn, finishReflectionVariableFalloffEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishReflectionMetallicOn:
			[self enableObjectsAccordingToObject:finishReflectionMetallicOn, finishReflectionMetallicEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishReflectionExponentOn:
			[self enableObjectsAccordingToObject:finishReflectionExponentOn, finishReflectionExponentEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishDiffuseOn:
			[self enableObjectsAccordingToObject:finishDiffuseOn, finishDiffuseEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishBacksideOn:
			[self enableObjectsAccordingToObject:finishBacksideOn, finishBacksideEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishBrillianceOn:
			[self enableObjectsAccordingToObject:finishBrillianceOn, finishBrillianceEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishCrandOn:
			[self enableObjectsAccordingToObject:finishCrandOn, finishCrandEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishPhongOn:
			[self enableObjectsAccordingToObject:finishPhongOn, finishPhongEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishPhongSizeOn:
			[self enableObjectsAccordingToObject:finishPhongSizeOn, finishPhongSizeEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishSpecularOn:
			[self enableObjectsAccordingToObject:finishSpecularOn, finishSpecularEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishRoghnessOn:
			[self enableObjectsAccordingToObject:finishRoghnessOn, finishRoghnessEdit,nil];
			if ( sender !=self )	break;
		case 	cFinishMetallicOn:
			[self enableObjectsAccordingToObject:finishMetallicOn, finishMetallicEdit,nil];
			if ( sender !=self )	break;

		case 	cFinishIridescenceGroupOn:
			[self setSubViewsOfNSBox:finishIridescenceGroup toNSButton:finishIridescenceGroupOn];
			if ( sender !=self )	break;
		case cFinishIridescenceTurbulencePopup:
			[ self setXYZVectorAccordingToPopup:finishIridescenceTurbulencePopUp xyzMatrix:finishIridescenceTurbulenceMatrix];
			if ( sender !=self )	break;
	}
	[self setModified:nil];
}


@end
