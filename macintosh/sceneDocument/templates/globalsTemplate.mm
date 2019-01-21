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
#import "globalsTemplate.h"
#import "standardMethods.h"
#import "functionTemplate.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation GlobalsTemplate


//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[GlobalsTemplate createDefaults:menuTagTemplateGlobals];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[GlobalsTemplate class] andTemplateType:menuTagTemplateGlobals];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];


	
	if ( [[dict objectForKey:@"globalsPhotonsOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"#declare phd = 1.0;\t//used in photons\n"];
	

	if ( [[dict objectForKey:@"globalsDontWrapInGlobalSettings"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"global_settings {\n"];
		[ds addTab];
	}

//ambient light 
	if ( [[dict objectForKey:@"globalsGlobalsAmbientLightOn"]intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"globalsGlobalsAmbientLightColor" andTitle:@"ambient_light " comma:NO newLine:YES];
	}
//Irid wavelength
	if ( [[dict objectForKey:@"globalsGlobalsIridWavelengthOn"]intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"globalsGlobalsIridWavelengthColor" andTitle:@"irid_wavelength " comma:NO newLine:YES];
	}

	if ( [[dict objectForKey:@"globalsGlobalsCharsetOn"]intValue]==NSOnState)
	{
		switch([[dict objectForKey:@"globalsGlobalsCharsetPopUp"]intValue])
		{
			case cGlobalsCharSetASCII:	[ds copyTabAndText:@"charset ascii\n"];
				break;
			case cGlobalsCharSetUTF8:	[ds copyTabAndText:@"charset utf8\n"];
				break;
			case cGlobalsCharSetSys:	[ds copyTabAndText:@"charset sys\n"];
				break;
		}		
	}
	
	if ( [[dict objectForKey:@"globalsGlobalsNoiseGeneratorOn"]intValue]==NSOnState)
	{
		switch([[dict objectForKey:@"globalsGlobalsNoiseGeneratorPopUp"]intValue])
		{
			case cGlobalsNoiseGenerator1:	[ds copyTabAndText:@"noise_generator 1\t//(3.1)\n"];
					break;
			case cGlobalsNoiseGeneratorSqueesed:	[ds copyTabAndText:@"noise_generator 2\t//(3.1 squeesed)\n"];
					break;
			case cGlobalsNoiseGeneratorPernlin:	[ds copyTabAndText:@"noise_generator 3\t//(Perlin noise)\n"];
					break;
		}		
	}
	if ( [[dict objectForKey:@"globalsGlobalsmmPerUnitOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"mm_per_unit %@\n",[dict objectForKey:@"globalsGlobalsmmPerUnitEdit"]];


	if ( [[dict objectForKey:@"globalsGlobalsAssumedGammaOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"assumed_gamma %@\n",[dict objectForKey:@"globalsGlobalsAssumedGammaEdit"]];

	if ( [[dict objectForKey:@"globalsGlobalsAdcBailoutOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"adc_bailout %@\n",[dict objectForKey:@"globalsGlobalsAdcBailoutEdit"]];

	if ( [[dict objectForKey:@"globalsGlobalsMaxTraceLevelOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"max_trace_level %@\n",[dict objectForKey:@"globalsGlobalsMaxTraceLevelEdit"]];

	if ( [[dict objectForKey:@"globalsGlobalsNumberOfWavesOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"number_of_waves %@\n",[dict objectForKey:@"globalsGlobalsNumberOfWavesEdit"]];

	if ( [[dict objectForKey:@"globalsGlobalsMaxIntersectionsOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"max_intersections %@\n",[dict objectForKey:@"globalsGlobalsMaxIntersectionsEdit"]];

//subsurface
	if ( [[dict objectForKey:@"globalsSubsurfaceGroupOn"]intValue]==NSOnState)
	{
		[ds copyTabAndText:@"subsurface {\n"];
		[ds addTab];
		
		if ( [[dict objectForKey:@"globalsSubsurfaceSamplesOn"]intValue]==NSOnState)
		{
			[ds appendTabAndFormat:@"samples %@, %@\n",[dict objectForKey:@"globalsSubsurfaceSamplesEditA"],[dict objectForKey:@"globalsSubsurfaceSamplesEditA"]];
		}
		if ( [[dict objectForKey:@"globalsSubSurfaceRadiosityOn"]intValue]==NSOnState)
		{
			if ( [[dict objectForKey:@"globalsSubSurfaceRadiosityMatrix"] intValue]==cFirstCell)
				[ds copyTabAndText:@"radiosity on\n"];
			else
				[ds copyTabAndText:@"radiosity off\n"];
		}
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
		
	}

//radiosity
	if ( [[dict objectForKey:@"globalsRadiosityOn"]intValue]==NSOnState)
	{
		[ds copyTabAndText:@"radiosity {\n"];
		[ds addTab];

		if ( [[dict objectForKey:@"globalsRadiosityPretraceStartOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"pretrace_start %@\n",[dict objectForKey:@"globalsRadiosityPretraceStartEdit"]];



		if ( [[dict objectForKey:@"globalsRadiosityPretraceEndOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"pretrace_end %@\n",[dict objectForKey:@"globalsRadiosityPretraceEndEdit"]];
			


		if ( [[dict objectForKey:@"globalsRadiosityBrightnessOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"brightness %@\n",[dict objectForKey:@"globalsRadiosityBrightnessEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityCountOn"] intValue]==NSOnState)
		{
			[ds appendTabAndFormat:@"count %@",[dict objectForKey:@"globalsRadiosityCountEdit"]];
			if ( [[dict objectForKey:@"globalsRadiosityCountDirectionsOn"] intValue]==NSOnState)
				[ds appendTabAndFormat:@", %@\n",[dict objectForKey:@"globalsRadiosityCountDirectionsEdit"]];
			else
				[ds copyText:@"\n"];
		}
		
		if ( [[dict objectForKey:@"globalsRadiosityNearestCountOn"] intValue]==NSOnState)
		{
			[ds appendTabAndFormat:@"nearest_count %@",[dict objectForKey:@"globalsRadiosityNearestCountEdit"]];
			if ( [[dict objectForKey:@"globalsRadiosityNearestCountPretraceOn"] intValue]==NSOnState)
				[ds appendTabAndFormat:@", %@\n",[dict objectForKey:@"globalsRadiosityNearestCountPretraceEdit"]];
			else
				[ds copyText:@"\n"];
		}
		
		if ( [[dict objectForKey:@"globalsRadiosityMaxSampleOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"max_sample %@\n",[dict objectForKey:@"globalsRadiosityMaxSampleEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityAdcBailoutOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"adc_bailout %@\n",[dict objectForKey:@"globalsRadiosityAdcBailoutEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityErrorBoundOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"error_bound %@\n",[dict objectForKey:@"globalsRadiosityErrorBoundEdit"]];
		
		if ( [[dict objectForKey:@"globalsRadiosityGrayThresholdOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"gray_threshold %@\n",[dict objectForKey:@"globalsRadiosityGrayThresholdEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityLowErrorFactorOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"low_error_factor %@\n",[dict objectForKey:@"globalsRadiosityLowErrorFactorEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityMinimumReuseOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"minimum_reuse %@\n",[dict objectForKey:@"globalsRadiosityMinimumReuseEdit"]];


		if ( [[dict objectForKey:@"globalsRadiosityRecursionLimitOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"recursion_limit %@\n",[dict objectForKey:@"globalsRadiosityRecursionLimitEdit"]];

		if ( [[dict objectForKey:@"globalsRadiosityMediaOn"]intValue]==NSOnState)
			[ds copyTabAndText:@"media on\n"];

		if ( [[dict objectForKey:@"globalsRadiosityNormalOn"]intValue]==NSOnState)
			[ds copyTabAndText:@"normal on\n"];

		if ( [[dict objectForKey:@"globalsRadiositySubsurfaceOn"]intValue]==NSOnState)
			[ds copyTabAndText:@"subsurface on\n"];


		if ( [[dict objectForKey:@"globalsRadiosityAlwaysSampleOn"]intValue]==NSOnState)
				[ds copyTabAndText:@"always_sample on\n"];

		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}

//Photons
	if ( [[dict objectForKey:@"globalsPhotonsOn"]intValue]==NSOnState)
	{
		[ds copyTabAndText:@"photons {\n"];
		[ds addTab];

		if ( [[dict objectForKey:@"globalsPhotonsGatherMinOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"gather %@, %@\n",[dict objectForKey:@"globalsPhotonsGatherMinEdit"],[dict objectForKey:@"globalsPhotonsGatherMaxEdit"]];

		//media
		if ( [[dict objectForKey:@"globalsPhotonsMediaOn"] intValue]==NSOnState)
		{
			[ds appendTabAndFormat:@"media %@",[dict objectForKey:@"globalsPhotonsMediaEdit"]];
			if ( [[dict objectForKey:@"globalsPhotonsMediaFactorOn"] intValue]==NSOnState)
				[ds appendFormat:@", %@\n",[dict objectForKey:@"globalsPhotonsMediaFactorEdit"]];
			else
				[ds copyTabAndText:@"\n"];
		}

		//radius
		if ( [[dict objectForKey:@"globalsPhotonsRadiusOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"radius %@\n",[dict objectForKey:@"globalsPhotonsRadiusEdit"]];
			
		//count/spacing
		if ( [[dict objectForKey:@"globalsPhotonsSpacingMatrix"] intValue]==cFirstCell)
			[ds appendTabAndFormat:@"spacing %@\n",[dict objectForKey:@"globalsPhotonsSpacingEdit"]];
		else
			[ds appendTabAndFormat:@"count %@\n",[dict objectForKey:@"globalsPhotonsSpacingCountEdit"]];

		//autostop
		if ( [[dict objectForKey:@"globalsPhotonsAutoStopOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"autostop %@\n",[dict objectForKey:@"globalsPhotonsAutoStopEdit"]];
			
		//jitter
		if ( [[dict objectForKey:@"globalsPhotonsJitterOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"jitter %@\n",[dict objectForKey:@"globalsPhotonsJitterEdit"]];
			
		//expand_thresholds
		if ( [[dict objectForKey:@"globalsPhotonsExpandThresholdOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"expand_thresholds %@, %@\n",[dict objectForKey:@"globalsPhotonsExpandThresholdEdit"],[dict objectForKey:@"globalsPhotonsExpandThresholdMinEdit"]];

		//max_trace_level
		if ( [[dict objectForKey:@"globalsPhotonsMaxTraceLevelOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"max_trace_level %@\n",[dict objectForKey:@"globalsPhotonsMaxTraceLevelEdit"]];

		//adc_bailout
		if ( [[dict objectForKey:@"globalsPhotonsAdcBailoutOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"adc_bailout %@\n",[dict objectForKey:@"globalsPhotonsAdcBailoutEdit"]];


		if ( [[dict objectForKey:@"globalsPhotonsPhotonsFileOn"]intValue]==NSOnState)
		{
			if ( [[dict objectForKey:@"globalsPhotonsPhotonsFileMatrixLoad"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"load_file \"%@\"\n",[dict objectForKey:@"globalsPhotonsPhotonsFileEdit"]];
			else
				[ds appendTabAndFormat:@"save_file \"%@\"\n",[dict objectForKey:@"globalsPhotonsPhotonsFileEdit"]];
		}

		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}
	
	if ( [[dict objectForKey:@"globalsDontWrapInGlobalSettings"]intValue]==NSOffState)
	{
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}
	
	//[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[GlobalsTemplate createDefaults:menuTagTemplateGlobals];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"globalsDefaultSettings",
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
		[NSNumber numberWithInt:cGlobalsTab],					@"globalsTabView",
		[NSNumber numberWithInt:NSOffState],					@"globalsDontWrapInGlobalSettings",
//globals

		[NSArchiver archivedDataWithRootObject:[MPColorWell lightGrayColorAndFilter:NO]], 	@"globalsGlobalsAmbientLightColor",
		[NSArchiver archivedDataWithRootObject:[MPColorWell redColorAndFilter:NO]], 		@"globalsGlobalsIridWavelengthColor",
	
		[NSNumber numberWithInt:NSOnState],				@"globalsGlobalsAmbientLightOn",
		[NSNumber numberWithInt:NSOnState],				@"globalsGlobalsIridWavelengthOn",
	
		[NSNumber numberWithInt:NSOffState],			@"globalsGlobalsAssumedGammaOn",
		@"1.0",																		@"globalsGlobalsAssumedGammaEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsGlobalsAdcBailoutOn",
		@"1/255",																	@"globalsGlobalsAdcBailoutEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsGlobalsMaxTraceLevelOn",
		@"5",																			@"globalsGlobalsMaxTraceLevelEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsGlobalsNumberOfWavesOn",
		@"10",																		@"globalsGlobalsNumberOfWavesEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsGlobalsMaxIntersectionsOn",
		@"64",																		@"globalsGlobalsMaxIntersectionsEdit",

		[NSNumber numberWithInt:NSOffState],							@"globalsGlobalsCharsetOn",
		[NSNumber numberWithInt:cGlobalsCharSetSys],			@"globalsGlobalsCharsetPopUp",
		[NSNumber numberWithInt:NSOffState],							@"globalsGlobalsNoiseGeneratorOn",
		[NSNumber numberWithInt:cGlobalsNoiseGenerator1],	@"globalsGlobalsNoiseGeneratorPopUp",
		[NSNumber numberWithInt:NSOffState],							@"globalsGlobalsmmPerUnitOn",
		@"10",																						@"globalsGlobalsmmPerUnitEdit",
//subsurface
		[NSNumber numberWithInt:NSOffState],			@"globalsSubsurfaceGroupOn",
		[NSNumber numberWithInt:NSOffState],			@"globalsSubsurfaceSamplesOn",
		@"50",																		@"globalsSubsurfaceSamplesEditA",
		@"50",																		@"globalsSubsurfaceSamplesEditB",
		[NSNumber numberWithInt:NSOffState],			@"globalsSubSurfaceRadiosityOn",
		[NSNumber numberWithInt:cFirstCell], 			@"globalsSubSurfaceRadiosityMatrix",

//radiosity
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityOn",
	
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityPretraceStartOn",
		@"0.008",																	@"globalsRadiosityPretraceStartEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityPretraceEndOn",
		@"0.02",																	@"globalsRadiosityPretraceEndEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityBrightnessOn",
		@"1",																			@"globalsRadiosityBrightnessEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityCountOn",
		@"80",																		@"globalsRadiosityCountEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityCountDirectionsOn",
		@"1",																		@"globalsRadiosityCountDirectionsEdit",

		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityNearestCountOn",
		@"5",																			@"globalsRadiosityNearestCountEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityNearestCountPretraceOn",
		@"1",																			@"globalsRadiosityNearestCountPretraceEdit",

		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityRecursionLimitOn",
		@"2",																			@"globalsRadiosityRecursionLimitEdit",

		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityAlwaysSampleOn",

	
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityMaxSampleOn",
		@"2",																			@"globalsRadiosityMaxSampleEdit",

		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityErrorBoundOn",
		@"1",																			@"globalsRadiosityErrorBoundEdit",

		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityGrayThresholdOn",
		@"0.0",																		@"globalsRadiosityGrayThresholdEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityLowErrorFactorOn",
		@"0.5",																		@"globalsRadiosityLowErrorFactorEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsRadiosityMinimumReuseOn",
		@"0.015",																	@"globalsRadiosityMinimumReuseEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityAdcBailoutOn",
		@"0.01/2",																@"globalsRadiosityAdcBailoutEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityNormalOn",
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiositySubsurfaceOn",
		[NSNumber numberWithInt:NSOffState],			@"globalsRadiosityMediaOn",

//photons
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsOn",

		[NSNumber numberWithInt:cFirstCell], 			@"globalsPhotonsSpacingMatrix",
		@"0.005",																	@"globalsPhotonsSpacingEdit",
		@"5000",																	@"globalsPhotonsSpacingCountEdit",

		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsGatherMinOn",
		@"20",																		@"globalsPhotonsGatherMinEdit",
		@"100",																		@"globalsPhotonsGatherMaxEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsMediaOn",
		@"5",																			@"globalsPhotonsMediaEdit",
		[NSNumber numberWithInt:NSOnState],				@"globalsPhotonsMediaFactorOn",
		@"0.5",																		@"globalsPhotonsMediaFactorEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsExpandThresholdOn",
		@"0.2",																		@"globalsPhotonsExpandThresholdEdit",
		@"40",																		@"globalsPhotonsExpandThresholdMinEdit",

		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsJitterOn",
		@"0.4",																		@"globalsPhotonsJitterEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsMaxTraceLevelOn",
		@"6",																			@"globalsPhotonsMaxTraceLevelEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsRadiusOn",
		@"0.1",																		@"globalsPhotonsRadiusEdit",
																		
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsPhotonsFileOn",
		[NSNumber numberWithInt:NSOffState], 			@"globalsPhotonsPhotonsFileMatrixLoad",
		[NSNumber numberWithInt:NSOnState], 			@"globalsPhotonsPhotonsFileMatrixSave",
		@"Enter FileName",								  			@"globalsPhotonsPhotonsFileEdit",
																  		
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsAdcBailoutOn",
		@"1/255",																	@"globalsPhotonsAdcBailoutEdit",
		[NSNumber numberWithInt:NSOffState],			@"globalsPhotonsAutoStopOn",
		@"0.50",																	@"globalsPhotonsAutoStopEdit",

																			
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
		globalsTabView,												@"globalsTabView",
		globalsDontWrapInGlobalSettings,			@"globalsDontWrapInGlobalSettings",
//globals
		globalsGlobalsAmbientLightColor, 			@"globalsGlobalsAmbientLightColor",
		globalsGlobalsIridWavelengthColor, 		@"globalsGlobalsIridWavelengthColor",
	
		globalsGlobalsAmbientLightOn,					@"globalsGlobalsAmbientLightOn",
		globalsGlobalsIridWavelengthOn,				@"globalsGlobalsIridWavelengthOn",
	
		globalsGlobalsAssumedGammaOn,					@"globalsGlobalsAssumedGammaOn",
		globalsGlobalsAssumedGammaEdit,				@"globalsGlobalsAssumedGammaEdit",
		globalsGlobalsAdcBailoutOn,						@"globalsGlobalsAdcBailoutOn",
		globalsGlobalsAdcBailoutEdit,					@"globalsGlobalsAdcBailoutEdit",
		globalsGlobalsMaxTraceLevelOn,				@"globalsGlobalsMaxTraceLevelOn",
		globalsGlobalsMaxTraceLevelEdit,			@"globalsGlobalsMaxTraceLevelEdit",
		globalsGlobalsNumberOfWavesOn,				@"globalsGlobalsNumberOfWavesOn",
		globalsGlobalsNumberOfWavesEdit,			@"globalsGlobalsNumberOfWavesEdit",
		globalsGlobalsMaxIntersectionsOn,			@"globalsGlobalsMaxIntersectionsOn",
		globalsGlobalsMaxIntersectionsEdit,			@"globalsGlobalsMaxIntersectionsEdit",

		globalsGlobalsCharsetOn,							@"globalsGlobalsCharsetOn",
		globalsGlobalsCharsetPopUp,						@"globalsGlobalsCharsetPopUp",
		globalsGlobalsNoiseGeneratorOn,				@"globalsGlobalsNoiseGeneratorOn",
		globalsGlobalsNoiseGeneratorPopUp,		@"globalsGlobalsNoiseGeneratorPopUp",

		globalsGlobalsmmPerUnitOn,					@"globalsGlobalsmmPerUnitOn",
		globalsGlobalsmmPerUnitEdit,				@"globalsGlobalsmmPerUnitEdit",
//subsurface
		globalsSubsurfaceGroupOn,						@"globalsSubsurfaceGroupOn",
		globalsSubsurfaceSamplesOn,					@"globalsSubsurfaceSamplesOn",
		globalsSubsurfaceSamplesEditA,			@"globalsSubsurfaceSamplesEditA",
		globalsSubsurfaceSamplesEditB,			@"globalsSubsurfaceSamplesEditB",
		globalsSubSurfaceRadiosityOn,				@"globalsSubSurfaceRadiosityOn",
		globalsSubSurfaceRadiosityMatrix,		@"globalsSubSurfaceRadiosityMatrix",
	
//rad
		globalsRadiosityOn,										@"globalsRadiosityOn",
	
		globalsRadiosityPretraceStartOn,			@"globalsRadiosityPretraceStartOn",
		globalsRadiosityPretraceStartEdit,		@"globalsRadiosityPretraceStartEdit",
		globalsRadiosityPretraceEndOn,				@"globalsRadiosityPretraceEndOn",
		globalsRadiosityPretraceEndEdit,			@"globalsRadiosityPretraceEndEdit",
		globalsRadiosityBrightnessOn,					@"globalsRadiosityBrightnessOn",
		globalsRadiosityBrightnessEdit,				@"globalsRadiosityBrightnessEdit",
		globalsRadiosityCountOn,							@"globalsRadiosityCountOn",
		globalsRadiosityCountEdit,						@"globalsRadiosityCountEdit",
		globalsRadiosityCountDirectionsOn,							@"globalsRadiosityCountDirectionsOn",
		globalsRadiosityCountDirectionsEdit,						@"globalsRadiosityCountDirectionsEdit",

		globalsRadiosityNearestCountOn,				@"globalsRadiosityNearestCountOn",
		globalsRadiosityNearestCountEdit,			@"globalsRadiosityNearestCountEdit",
		globalsRadiosityNearestCountPretraceOn,				@"globalsRadiosityNearestCountPretraceOn",
		globalsRadiosityNearestCountPretraceEdit,			@"globalsRadiosityNearestCountPretraceEdit",

		globalsRadiosityRecursionLimitOn,			@"globalsRadiosityRecursionLimitOn",
		globalsRadiosityRecursionLimitEdit,		@"globalsRadiosityRecursionLimitEdit",

		globalsRadiosityAlwaysSampleOn,				@"globalsRadiosityAlwaysSampleOn",

		globalsRadiosityMaxSampleOn,					@"globalsRadiosityMaxSampleOn",
		globalsRadiosityMaxSampleEdit,				@"globalsRadiosityMaxSampleEdit",

		globalsRadiosityErrorBoundOn,								@"globalsRadiosityErrorBoundOn",
		globalsRadiosityErrorBoundEdit,							@"globalsRadiosityErrorBoundEdit",

		globalsRadiosityGrayThresholdOn,				@"globalsRadiosityGrayThresholdOn",
		globalsRadiosityGrayThresholdEdit,			@"globalsRadiosityGrayThresholdEdit",
		globalsRadiosityLowErrorFactorOn,				@"globalsRadiosityLowErrorFactorOn",
		globalsRadiosityLowErrorFactorEdit,			@"globalsRadiosityLowErrorFactorEdit",
		globalsRadiosityMinimumReuseOn,					@"globalsRadiosityMinimumReuseOn",
		globalsRadiosityMinimumReuseEdit,				@"globalsRadiosityMinimumReuseEdit",
		globalsRadiosityAdcBailoutOn,						@"globalsRadiosityAdcBailoutOn",
		globalsRadiosityAdcBailoutEdit,					@"globalsRadiosityAdcBailoutEdit",
		globalsRadiosityNormalOn,								@"globalsRadiosityNormalOn",
		globalsRadiositySubsurfaceOn,						@"globalsRadiositySubsurfaceOn",
		globalsRadiosityMediaOn,								@"globalsRadiosityMediaOn",

//ph
		globalsPhotonsOn,											@"globalsPhotonsOn",

		globalsPhotonsSpacingMatrix,					@"globalsPhotonsSpacingMatrix",
		globalsPhotonsSpacingEdit,						@"globalsPhotonsSpacingEdit",
		globalsPhotonsSpacingCountEdit,				@"globalsPhotonsSpacingCountEdit",

		globalsPhotonsGatherMinOn,						@"globalsPhotonsGatherMinOn",
		globalsPhotonsGatherMinEdit,					@"globalsPhotonsGatherMinEdit",
		globalsPhotonsGatherMaxEdit,					@"globalsPhotonsGatherMaxEdit",
		globalsPhotonsMediaOn,								@"globalsPhotonsMediaOn",
		globalsPhotonsMediaEdit,							@"globalsPhotonsMediaEdit",
		globalsPhotonsMediaFactorOn,					@"globalsPhotonsMediaFactorOn",
		globalsPhotonsMediaFactorEdit,				@"globalsPhotonsMediaFactorEdit",
		globalsPhotonsExpandThresholdOn,			@"globalsPhotonsExpandThresholdOn",
		globalsPhotonsExpandThresholdEdit,		@"globalsPhotonsExpandThresholdEdit",
		globalsPhotonsExpandThresholdMinEdit,	@"globalsPhotonsExpandThresholdMinEdit",

		globalsPhotonsJitterOn,								@"globalsPhotonsJitterOn",
		globalsPhotonsJitterEdit,							@"globalsPhotonsJitterEdit",
		globalsPhotonsMaxTraceLevelOn,				@"globalsPhotonsMaxTraceLevelOn",
		globalsPhotonsMaxTraceLevelEdit,			@"globalsPhotonsMaxTraceLevelEdit",
		globalsPhotonsRadiusOn,								@"globalsPhotonsRadiusOn",
		globalsPhotonsRadiusEdit,							@"globalsPhotonsRadiusEdit",
		
		globalsPhotonsPhotonsFileOn,					@"globalsPhotonsPhotonsFileOn",
		[globalsPhotonsPhotonsFileMatrix cellWithTag:cFirstCell],		@"globalsPhotonsPhotonsFileMatrixLoad",
		[globalsPhotonsPhotonsFileMatrix cellWithTag:cSecondCell],	@"globalsPhotonsPhotonsFileMatrixSave",
		globalsPhotonsPhotonsFileEdit,				@"globalsPhotonsPhotonsFileEdit",
		
		globalsPhotonsAdcBailoutOn,					@"globalsPhotonsAdcBailoutOn",
		globalsPhotonsAdcBailoutEdit,				@"globalsPhotonsAdcBailoutEdit",
		globalsPhotonsAutoStopOn,						@"globalsPhotonsAutoStopOn",
		globalsPhotonsAutoStopEdit,					@"globalsPhotonsAutoStopEdit",

		
	nil];	
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"globalsLocalized" andDictionary:mOutlets];

	//additional objects


	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"globalsTabView",
		nil];
	[mExcludedObjectsForReset retain];
	
	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// currentImportExportTitle
//---------------------------------------------------------------------
-(NSString*)currentImportExportTitle:(BOOL)import
{
	NSString *menuItemString=nil;
	NSString *titleString=nil;
	if( import==YES)
		menuItemString=[NSString stringWithString:NSLocalizedStringFromTable(@"importMenuItem", @"applicationLocalized", @"")];
	else
		menuItemString=[NSString stringWithString:NSLocalizedStringFromTable(@"exportMenuItem", @"applicationLocalized", @"")];
	
	switch ([globalsTabView indexOfTabViewItem:[globalsTabView selectedTabViewItem]])
	{
		case cGlobalsTab:			titleString=NSLocalizedStringFromTable(@"GlobalsTab", @"applicationLocalized", @""); 			break;
		case cSubsurfaceTab:	titleString=NSLocalizedStringFromTable(@"SubsurfaceTab", @"applicationLocalized", @""); break;
		case cRadiosityTab:		titleString=NSLocalizedStringFromTable(@"RadiosityTab", @"applicationLocalized", @""); 		break;
		case cPhotonsTab:			titleString=NSLocalizedStringFromTable(@"PhotonsTab", @"applicationLocalized", @""); 			break;
	}
	menuItemString=[menuItemString stringByAppendingString:@" "];
	
	return [menuItemString stringByAppendingString:titleString];
}

//---------------------------------------------------------------------
// importSettings
//---------------------------------------------------------------------
-(void) importSettings
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];
	[openPanel setDirectoryURL:nil];
	void (^importPreferencesOpenSavePanelHandler)(NSInteger) = ^( NSInteger resultCode )
	{
		@autoreleasepool
		{
			NSMutableDictionary *refDictLoadedFromFile=nil;
			if ( resultCode == NSOKButton )
				refDictLoadedFromFile=[NSMutableDictionary dictionaryWithContentsOfURL:[openPanel URL]];
			if ( refDictLoadedFromFile != nil)
			{
				id dictName=[refDictLoadedFromFile objectForKey:@"dictionaryTypeDefaults"];
				if ( dictName && [dictName isEqualToString:NSStringFromClass([self class])])
				{
					NSString *keepString=[self beginOfKeysForCurrentPanel];
					//first make a default settings array with
					NSMutableDictionary *refCompleteDefaultDict=[GlobalsTemplate createDefaults:mTemplateType];
					if ( refCompleteDefaultDict== nil)
						return;
					NSMutableDictionary *refDefaultDictForThisPanel=[[refCompleteDefaultDict mutableCopy]autorelease ];
					if ( refDefaultDictForThisPanel== nil)
						return;
					
					NSEnumerator *en=[refCompleteDefaultDict keyEnumerator];
					NSString *key;
					// now remove all the settings not for this panel
					while ( (key = [en nextObject]) != nil )
					{
						NSRange foundRange=[key rangeOfString:keepString options:NSLiteralSearch];
						if ( foundRange.location ==NSNotFound)
						{
							[refDefaultDictForThisPanel removeObjectForKey:key];
						}
					}
					
					NSMutableDictionary *dictToBeLoadedInpanel=[[refDictLoadedFromFile mutableCopy]autorelease];
					if( dictToBeLoadedInpanel == nil)
						return;
					//remove all settings that don't belong to the current panel
					en=[refDictLoadedFromFile keyEnumerator];
					
					while ( (key = [en nextObject]) != nil )
					{
						NSRange foundRange=[key rangeOfString:keepString options:NSLiteralSearch];
						if ( foundRange.location ==NSNotFound)
						{
							[dictToBeLoadedInpanel removeObjectForKey:key];
						}
					}
					
					//all settings which are not loaded for the current panel
					//need to be set to the defautl.
					// add alle missing settings
					en=[refDefaultDictForThisPanel keyEnumerator];
					
					while ( (key = [en nextObject]) != nil )
					{
						if ( [dictToBeLoadedInpanel objectForKey:key]==nil)
							[dictToBeLoadedInpanel setObject:[refDefaultDictForThisPanel objectForKey:key] forKey:key];
					}
					// finaly move the setttings in the panel
					[self  setValuesInPanel:dictToBeLoadedInpanel];
					
				}
				else
				{
					NSString *CurrentPanelString=@"global ";
				NSRunAlertPanel( NSLocalizedStringFromTable(@"WrongTemplateSettings", @"applicationLocalized", @"Wrong preferences file"),
													NSLocalizedStringFromTable(@"SelectCorrectFile", @"applicationLocalized", @"Only %@ settings files can be used!"),
													NSLocalizedStringFromTable(@"Ok", @"applicationLocalized", @"Cancel"),
													nil, 
													nil, CurrentPanelString);


				}
			}
			
		}
	};
	[openPanel beginSheetModalForWindow:[self getWindow] 
                              completionHandler:importPreferencesOpenSavePanelHandler];

}



//---------------------------------------------------------------------
// exportSettings
//---------------------------------------------------------------------
// saves only the settings of the active panel
//---------------------------------------------------------------------
-(void) exportSettings
{
	[self retrivePreferences];
	
	NSString *keepString=[self beginOfKeysForCurrentPanel];
	
	NSMutableDictionary *refDictCurrentPrefs=[self preferences];
	if ( refDictCurrentPrefs==nil)
		return;
	// make a copy, we will remove all unrelated prefs here
	// because you can not remove objects from a dict being enumerated
	NSMutableDictionary	*saveDict = [[refDictCurrentPrefs mutableCopy]autorelease];
	if ( saveDict==nil)
		return;
	
	//remove all setting which don't belong to the 
	//current panel
	
	NSEnumerator *en=[refDictCurrentPrefs keyEnumerator];
	NSString *key;
	while ( (key = [en nextObject]) != nil ) 
	{
		NSRange foundRange=[key rangeOfString:keepString options:NSLiteralSearch];
		if ( foundRange.location ==NSNotFound)
		{
			[saveDict removeObjectForKey:key];
		}
	}	

	// remove default settings
	id trimmedPrefs=[self removeStandardSettingsFromPreference:saveDict];
	NSSavePanel *savePanel=[NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];
	[savePanel setTitle:@"export template"];
	[savePanel setDirectoryURL:nil];
 [savePanel beginSheetModalForWindow:[self getWindow]
                              completionHandler: ^( NSInteger resultCode )
	{
		@autoreleasepool
	 	{
			if( resultCode ==NSOKButton )
				[trimmedPrefs writeToURL:[savePanel URL] atomically:YES];
    }
	}
  ];

}


//---------------------------------------------------------------------
// resetButton
//---------------------------------------------------------------------
// we only reset the currently visible tab and not the others
//---------------------------------------------------------------------
-(IBAction) resetButton: (id)sender
{
	NSString *keepString=[self beginOfKeysForCurrentPanel];

	if ( keepString != nil)
	{
		NSMutableDictionary *dict=[[[GlobalsTemplate createDefaults:mTemplateType]mutableCopy]autorelease];
		if ( dict != nil )
		{
			NSEnumerator *en=[dict keyEnumerator];
			NSString *key;
			while ( (key = [en nextObject]) != nil ) 
			{
				NSRange foundRange=[key rangeOfString:keepString options:NSLiteralSearch];
				if ( foundRange.location ==NSNotFound)
				{
					[dict removeObjectForKey:key];
				}
			}	
			[self  setValuesInPanel:dict];
		}
	}
}

//---------------------------------------------------------------------
// beginOfKeysForCurrentPanel
//---------------------------------------------------------------------
-(NSString *) beginOfKeysForCurrentPanel
{
	NSString *keepString=nil;

	switch ([globalsTabView indexOfTabViewItem:[globalsTabView selectedTabViewItem]])
	{
		case cGlobalsTab:			keepString=@"globalsGlobals"; 			break;
		case cSubsurfaceTab:	keepString=@"globalsSubsurface";		break;
		case cRadiosityTab:		keepString=@"globalsRadiosity"; 		break;
		case cPhotonsTab:			keepString=@"globalsPhotons"; 			break;
	}
	return keepString;
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	// if an older pref is loaded wiht more tabs than the current one,
	// use the last tab on the panel
	id tabview=[preferences objectForKey:@"globalsTabView"];
	if ( tabview && ([tabview intValue] > cPhotonsTab))
		[preferences setObject:[NSNumber numberWithInt:cGlobalsTab] forKey:@"globalsTabView"];
	[super setValuesInPanel:preferences];
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	//now we can add a few things
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self globalsGlobalsTarget:self];	
	[self globalsSubsurfaceOn:self];
	[self globalsSubsurfaceTarget:self];
	[self globalsRadiosityOn:self];
	[self globalsPhotonsOn:self];
	[self setNotModified];
}

//---------------------------------------------------------------------
// globalsGlobalsTarget:sender
//---------------------------------------------------------------------
-(IBAction) globalsGlobalsTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cGlobalsGlobalsAmbientLightOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cGlobalsGlobalsAmbientLightOn:
			[self setSubViewsOfNSBox:globalsGlobalsAmbientLightGroup toNSButton:globalsGlobalsAmbientLightOn];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsIridWavelengthOn:
			[self setSubViewsOfNSBox:globalsGlobalsIridWavelengthGroup toNSButton:globalsGlobalsIridWavelengthOn];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsAssumedGammaOn	:
			[self enableObjectsAccordingToObject:globalsGlobalsAssumedGammaOn ,globalsGlobalsAssumedGammaEdit ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsAdcBailoutOn:
			[self enableObjectsAccordingToObject:globalsGlobalsAdcBailoutOn ,globalsGlobalsAdcBailoutEdit ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsMaxTraceLevelOn:
			[self enableObjectsAccordingToObject:globalsGlobalsMaxTraceLevelOn ,globalsGlobalsMaxTraceLevelEdit ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsNumberOfWavesOn:
			[self enableObjectsAccordingToObject:globalsGlobalsNumberOfWavesOn ,globalsGlobalsNumberOfWavesEdit ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsMaxIntersectionsOn:
			[self enableObjectsAccordingToObject:globalsGlobalsMaxIntersectionsOn ,globalsGlobalsMaxIntersectionsEdit ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsCharsetOn:
			[self enableObjectsAccordingToObject:globalsGlobalsCharsetOn ,globalsGlobalsCharsetPopUp ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsNoiseGeneratorOn:
			[self enableObjectsAccordingToObject:globalsGlobalsNoiseGeneratorOn ,globalsGlobalsNoiseGeneratorPopUp ,nil];
			if ( sender !=self )	break;
		case 	cGlobalsGlobalsmmPerUnitOn:
			[self enableObjectsAccordingToObject:globalsGlobalsmmPerUnitOn ,globalsGlobalsmmPerUnitEdit ,nil];
			if ( sender !=self )	break;
	}
	[self setModified:nil];
}

//---------------------------------------------------------------------
// globalsToneMappingTarget:sender
//---------------------------------------------------------------------
-(IBAction) globalsSubsurfaceTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cGlobalsSubsurfaceSamplespOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{

		case 	cGlobalsSubsurfaceSamplespOn:
			[self enableObjectsAccordingToObject:globalsSubsurfaceSamplesOn,globalsSubsurfaceSamplesEditA,globalsSubsurfaceSamplesEditB,nil];
			if ( sender !=self )	break;
		case 	cGlobalsSubsurfaceRadiosityOn:
			[self enableObjectsAccordingToObject:globalsSubSurfaceRadiosityOn,globalsSubSurfaceRadiosityMatrix,nil];
			if ( sender !=self )	break;

		}
	[self setModified:nil];
}


//---------------------------------------------------------------------
// globalsRadiosityTarget:sender
//---------------------------------------------------------------------
-(IBAction) globalsRadiosityTarget:(id)sender
{
	NSInteger theTag;
	BOOL onState;
	if ( sender==self)
		theTag=cGlobalsRadiosityPretraceStartOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case cGlobalsRadiosityPretraceStartOn:
			[self enableObjectsAccordingToObject:globalsRadiosityPretraceStartOn, globalsRadiosityPretraceStartEdit,nil];
			if ( sender !=self )	break;

		case cGlobalsRadiosityPretraceEndOn:
			[self enableObjectsAccordingToObject:globalsRadiosityPretraceEndOn, globalsRadiosityPretraceEndEdit, nil];
			if ( sender !=self )	break;
		case cGlobalsRadiosityBrightnessOn:
			[self enableObjectsAccordingToObject:globalsRadiosityBrightnessOn, globalsRadiosityBrightnessEdit, nil];
			if ( sender !=self )	break;

		case cGlobalsRadiosityCountOn:
			[self enableObjectsAccordingToObject:globalsRadiosityCountOn, globalsRadiosityCountEdit,globalsRadiosityCountDirectionsOn,globalsRadiosityCountDirectionsEdit, nil];
		case cGlobalsRadiosityCountDirectionsOn:
			if ([globalsRadiosityCountOn state] == NSOnState)
			{
		//		if ([globalsRadiosityCountDirectionsOn state] == NSOnState)
					[self enableObjectsAccordingToObject:globalsRadiosityCountDirectionsOn,globalsRadiosityCountDirectionsEdit,nil];
			}
			if ( sender !=self )	break;
			
		case cGlobalsRadiosityNearestCountOn:
			[self enableObjectsAccordingToObject:globalsRadiosityNearestCountOn, globalsRadiosityNearestCountEdit,globalsRadiosityNearestCountPretraceOn, globalsRadiosityNearestCountPretraceEdit, nil];
		case cGlobalsRadiosityNearestCountPretraceOn:
			if ([globalsRadiosityNearestCountOn state] == NSOnState)
			{
	//			if ([globalsRadiosityNearestCountPretraceOn state] == NSOnState)
					[self enableObjectsAccordingToObject:globalsRadiosityNearestCountPretraceOn,globalsRadiosityNearestCountPretraceEdit,nil];
			}
			if ( sender !=self )	break;
		case cGlobalsRadiosityRecursionLimitOn:
			[self enableObjectsAccordingToObject:globalsRadiosityRecursionLimitOn, globalsRadiosityRecursionLimitEdit, nil];
			if ( sender !=self )	break;


		case cGlobalsRadiosityMaxSampleOn:
			[self enableObjectsAccordingToObject:globalsRadiosityMaxSampleOn, globalsRadiosityMaxSampleEdit, nil];
			if ( sender !=self )	break;

		case cGlobalsRadiosityErrorBoundOn:
			[self enableObjectsAccordingToObject:globalsRadiosityErrorBoundOn, globalsRadiosityErrorBoundEdit, nil];
			if ( sender !=self )	break;


		case cGlobalsRadiosityGrayThresholdOn:
			[self enableObjectsAccordingToObject:globalsRadiosityGrayThresholdOn, globalsRadiosityGrayThresholdEdit, nil];
			if ( sender !=self )	break;
		case cGlobalsRadiosityLowErrorFactorOn:
			[self enableObjectsAccordingToObject:globalsRadiosityLowErrorFactorOn, globalsRadiosityLowErrorFactorEdit, nil];
			if ( sender !=self )	break;
		case cGlobalsRadiosityMinimumReuseOn:
			[self enableObjectsAccordingToObject:globalsRadiosityMinimumReuseOn, globalsRadiosityMinimumReuseEdit, nil];
			if ( sender !=self )	break;
		case cGlobalsRadiosityAdcBailoutOn:
			[self enableObjectsAccordingToObject:globalsRadiosityAdcBailoutOn, globalsRadiosityAdcBailoutEdit, nil];
			if ( sender !=self )	break;
	}
}

//---------------------------------------------------------------------
// globalsPhotonsTarget:sender
//---------------------------------------------------------------------
-(IBAction) globalsPhotonsTarget:(id)sender
{
	NSInteger theTag;
	NSInteger nTag;
	if ( sender==self)
		theTag=cGlobalsPhotonsSpacingMatrix;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case cGlobalsPhotonsSpacingMatrix:
			nTag=[[globalsPhotonsSpacingMatrix selectedCell]tag];
			if ( nTag==cFirstCell)
			{
				[globalsPhotonsSpacingEdit setEnabled:YES];
				[globalsPhotonsSpacingCountEdit setEnabled:NO];
			}
			else
			{
				[globalsPhotonsSpacingEdit setEnabled:NO];
				[globalsPhotonsSpacingCountEdit setEnabled:YES];
			}
						
			if ( sender !=self )	break;

		case cGlobalsPhotonsGatherMinOn:
			[self enableObjectsAccordingToObject:globalsPhotonsGatherMinOn, globalsPhotonsGatherMinEdit,globalsPhotonsGatherMaxEdit,globalsPhotonsGatherMaxText, nil];
			if ( sender !=self )	break;

		case cGlobalsPhotonsMediaOn:
		case cGlobalsPhotonsMediaFactorOn:
			[self enableObjectsAccordingToObject:globalsPhotonsMediaOn, globalsPhotonsMediaEdit, globalsPhotonsMediaFactorOn,globalsPhotonsMediaFactorEdit,nil];
			if ( [globalsPhotonsMediaOn state]== NSOnState )
				[self enableObjectsAccordingToObject:globalsPhotonsMediaFactorOn, globalsPhotonsMediaFactorEdit, nil];
			if ( sender !=self )	break;


		case cGlobalsPhotonsExpandThresholdOn:
			[self enableObjectsAccordingToObject:globalsPhotonsExpandThresholdOn, globalsPhotonsExpandThresholdMinEdit,globalsPhotonsExpandThresholdMinText, nil];
			if ( sender !=self )	break;


		case cGlobalsPhotonsJitterOn:
			[self enableObjectsAccordingToObject:globalsPhotonsJitterOn, globalsPhotonsJitterEdit, nil];
			if ( sender !=self )	break;

		case cGlobalsPhotonsMaxTraceLevelOn:
			[self enableObjectsAccordingToObject:globalsPhotonsMaxTraceLevelOn, globalsPhotonsMaxTraceLevelEdit, nil];
			if ( sender !=self )	break;

		case cGlobalsPhotonsRadiusOn:
			[self enableObjectsAccordingToObject:globalsPhotonsRadiusOn, globalsPhotonsRadiusEdit, nil];
			if ( sender !=self )	break;


		case cGlobalsPhotonsPhotonsFileOn:
			[self enableObjectsAccordingToObject:globalsPhotonsPhotonsFileOn, globalsPhotonsPhotonsFileMatrix,globalsPhotonsPhotonsFileEdit,nil];
			if ( sender !=self )	break;

		case cGlobalsPhotonsAdcBailoutOn:
			[self enableObjectsAccordingToObject:globalsPhotonsAdcBailoutOn, globalsPhotonsAdcBailoutEdit, nil];
			if ( sender !=self )	break;

		case cGlobalsPhotonsAutoStopOn:
			[self enableObjectsAccordingToObject:globalsPhotonsAutoStopOn, globalsPhotonsAutoStopEdit, nil];
			if ( sender !=self )	break;

	}
}


//---------------------------------------------------------------------
// globalsRadiosityOn:sender
//---------------------------------------------------------------------
-(IBAction) globalsRadiosityOn:(id)sender
{
	[self setSubViewsOfNSBox:globalsRadiosityGroup toNSButton:globalsRadiosityOn];
	if ( [globalsRadiosityOn state]==NSOnState)
		[self globalsRadiosityTarget:self];
	if ( [globalsRadiosityOn state]==NSOnState)
		[globalsRadiosityLed setHidden:NO];
	else
		[globalsRadiosityLed setHidden:YES];

}
//---------------------------------------------------------------------
// globalsRadiosityOn:sender
//---------------------------------------------------------------------
-(IBAction) globalsSubsurfaceOn:(id)sender
{
	[self setSubViewsOfNSBox:globalsSubsurfaceGroup toNSButton:globalsSubsurfaceGroupOn];
	if ( [globalsSubsurfaceGroupOn state]==NSOnState)
		[self globalsSubsurfaceTarget:self];
	if ( [globalsSubsurfaceGroupOn state]==NSOnState)
		[globalsSubsurfaceLed setHidden:NO];
	else
		[globalsSubsurfaceLed setHidden:YES];

}
//---------------------------------------------------------------------
// globalsPhotonsOn:sender
//---------------------------------------------------------------------
-(IBAction) globalsPhotonsOn:(id)sender
{
	[self setSubViewsOfNSBox:globalsPhotonsGroup toNSButton:globalsPhotonsOn];
	if ( [globalsPhotonsOn state]==NSOnState)
		[self globalsPhotonsTarget:self];
	if ( [globalsPhotonsOn state]==NSOnState)
		[globalsPhotonsLed setHidden:NO];
	else
		[globalsPhotonsLed setHidden:YES];

}

@end
