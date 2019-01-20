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
#import "mediaTemplate.h"
#import "pigmentTemplate.h"
#import "bodymapTemplate.h"
#import "standardMethods.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation MediaTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{

	if ( dict== nil)
		dict=[MediaTemplate createDefaults:menuTagTemplateMedia];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[MediaTemplate class] andTemplateType:menuTagTemplateMedia];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	if ( [[dict objectForKey:@"mediaDontWrapInMedia"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"media {\n"];
		[ds addTab];
	}
	
	if ( [[dict objectForKey:@"mediaAbsorptionGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"mediaAbsorptionGroupColorWell" andTitle:@"absorption " comma:NO newLine:YES];
	}
	
	//Emission light
	if ( [[dict objectForKey:@"mediaEmissionGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"mediaEmissionGroupColorWell" andTitle:@"emission " comma:NO newLine:YES];
	}

	//scattering
	if ( [[dict objectForKey:@"mediaScatteringGroupOn"] intValue]==NSOnState)
	{
		[ds copyTabAndText:@"scattering {\n"];
		[ds addTab];
		switch ( [[dict objectForKey:@"mediaScatteringTypePopUp"] intValue] )
		{
			case cIsotropic: 					[ds copyTabAndText:@"1,	//isotropic_scattering\n"];					break;
			case cMieHazy: 					[ds copyTabAndText:@"2,	//mie_hazy_scattering\n"];					break;
			case cMieMurky: 				[ds copyTabAndText:@"3,	//mie_murky_scattering\n"];				break;
			case cRayleigh: 					[ds copyTabAndText:@"4,	//rayleigh_scattering\n"];						break;
			case cHenyeyGreenstein:	[ds copyTabAndText:@"5,	//henyey_greenstein_scattering \n"];		break;
		}
		[ds copyTabText];
		[ds addRGBColor:dict forKey:@"mediaScatteringColorWell" andTitle:@"" comma:NO newLine:YES];
		switch ( [[dict objectForKey:@"mediaScatteringTypePopUp"] intValue] )
		{
			case cHenyeyGreenstein: 	
				[ds appendTabAndFormat:@"eccentricity %@\n", [dict objectForKey:@"mediaScatteringEccentricityEdit"]];
				break;
		}
		//extinction
		if ( [[dict objectForKey:@"mediaScatteringExtinctionOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"extinction %@\n", [dict objectForKey:@"mediaScatteringExtinctionEdit"]];
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}	

		//density
	if ( [[dict objectForKey:@"mediaDensityGroupOn"] intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"mediaDensityMatrix"] intValue]==cFirstCell)
		{
			[ds copyTabAndText:@"density {\n"];
			[ds addTab];
			WritePigment(cForceDontWrite, ds, [dict objectForKey:@"mediaDensityEditPattern"], NO);
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
		}	
		else if ( [[dict objectForKey:@"mediaDensityMatrix"] intValue]==cSecondCell)
		{
			[BodymapTemplate createDescriptionWithDictionary:[dict objectForKey:@"mediaDensityEditMap"] andTabs:[ds currentTabs]extraParam:menuTagTemplateDensitymap mutableTabString:ds];
		}
	}

	switch ( [[dict objectForKey:@"mediaSamplingMethodPopUp"] intValue] )
	{
		case cMethod1:
			break;	//1 is default, by not writing it, it stays compatible with the official Povray
		case cMethod2:			[ds copyTabAndText:@"method 2\n"];				break;
		case cMethod3:			[ds copyTabAndText:@"method 3\n"];				break;
	}
		
	if ([[dict objectForKey:@"mediaSamplingMethodPopUp"] intValue] == cMethod2 || [[dict objectForKey:@"mediaSamplingMethodPopUp"] intValue] ==cMethod3)
	{
		if ( [[dict objectForKey:@"mediaSamplingJitterOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"jitter %@\n",[dict objectForKey:@"mediaSamplingJitterEdit"]];
	}	
	if ([[dict objectForKey:@"mediaSamplingMethodPopUp"] intValue] ==cMethod3)
	{
		if ( [[dict objectForKey:@"mediaSamplingAaDepthOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"aa_level %@\n",[dict objectForKey:@"mediaSamplingAaDepthEdit"]];
		if ( [[dict objectForKey:@"mediaSamplingAaThresholdOn"] intValue]==NSOnState)
			[ds appendTabAndFormat:@"aa_threshold %@\n",[dict objectForKey:@"mediaSamplingAaThresholdEdit"]];
	}	

	if ( [[dict objectForKey:@"mediaSamplingIntervalsOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"intervals %@\n",[dict objectForKey:@"mediaSamplingIntervalsEdit"]];


	if ( [[dict objectForKey:@"mediaSamplingSamplesOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"samples %@,%@\n",[dict objectForKey:@"mediaSamplingSamplesMinEdit"],[dict objectForKey:@"mediaSamplingSamplesMaxEdit"]];


	if ( [[dict objectForKey:@"mediaSamplingConfidenceOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"confidence %@\n",[dict objectForKey:@"mediaSamplingConfidenceEdit"]];

	if ( [[dict objectForKey:@"mediaSamplingVarianceOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"variance %@\n",[dict objectForKey:@"mediaSamplingVarianceEdit"]];

	if ( [[dict objectForKey:@"mediaSamplingRatioOn"] intValue]==NSOnState)
		[ds appendTabAndFormat:@"ratio %@\n",[dict objectForKey:@"mediaSamplingRatioEdit"]];

	if ( [[dict objectForKey:@"mediaIgnorePhotonsOn"] intValue]==NSOnState)
		[ds copyTabAndText:@"collect off\n"];

	if ( [[dict objectForKey:@"mediaDontWrapInMedia"]intValue]==NSOffState)
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
	NSDictionary *initialDefaults=[MediaTemplate createDefaults:menuTagTemplateMedia];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"mediaDefaultSettings",
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
		[NSNumber numberWithInt:NSOffState],									@"mediaDontWrapInMedia",
		[NSNumber numberWithInt:NSOffState],									@"mediaIgnorePhotonsOn",
		[NSNumber numberWithInt:NSOffState],									@"mediaAbsorptionGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell whiteColorAndFilter:NO]],	@"mediaAbsorptionGroupColorWell",
		[NSNumber numberWithInt:NSOffState],									@"mediaEmissionGroupOn",
		[NSArchiver archivedDataWithRootObject:[MPColorWell whiteColorAndFilter:NO]],	@"mediaEmissionGroupColorWell",
		[NSNumber numberWithInt:NSOffState],									@"mediaDensityGroupOn",
		[NSNumber numberWithInt:cFirstCell],										@"mediaDensityMatrix",
		[NSNumber numberWithInt:NSOnState],									@"mediaScatteringGroupOn",
		[NSNumber numberWithInt:cIsotropic],										@"mediaScatteringTypePopUp",
		[NSNumber numberWithInt:NSOffState],	 								@"mediaScatteringColorWell",
		@"0.0",																					@"mediaScatteringEccentricityEdit",
		[NSNumber numberWithInt:NSOffState],	 								@"mediaScatteringExtinctionOn",
		@"0.5",																					@"mediaScatteringExtinctionEdit",
		[NSArchiver archivedDataWithRootObject:[MPColorWell whiteColorAndFilter:NO]],	@"mediaScatteringColorWell",
		[NSNumber numberWithInt:cMethod1],										@"mediaSamplingMethodPopUp",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingIntervalsOn",
		@"1.0",																					@"mediaSamplingIntervalsEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingSamplesOn",
		@"1",																						@"mediaSamplingSamplesMinEdit",
		@"1",																						@"mediaSamplingSamplesMaxEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingJitterOn",
		@"0.0",																					@"mediaSamplingJitterEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingAaDepthOn",
		@"4.0",																					@"mediaSamplingAaDepthEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingAaThresholdOn",
		@"0.1",																					@"mediaSamplingAaThresholdEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingConfidenceOn",
		@"0.9",																					@"mediaSamplingConfidenceEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingVarianceOn",
		@"1/128",																				@"mediaSamplingVarianceEdit",
		[NSNumber numberWithInt:NSOffState],									@"mediaSamplingRatioOn",
		@"0.9",																					@"mediaSamplingRatioEdit",
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
		mediaDontWrapInMedia,				@"mediaDontWrapInMedia",
		mediaIgnorePhotonsOn,				@"mediaIgnorePhotonsOn",
		mediaAbsorptionGroupOn,			@"mediaAbsorptionGroupOn",
		mediaAbsorptionGroupColorWell,@"mediaAbsorptionGroupColorWell",
		mediaEmissionGroupOn,				@"mediaEmissionGroupOn",
		mediaEmissionGroupColorWell,	@"mediaEmissionGroupColorWell",
		mediaDensityGroupOn,				@"mediaDensityGroupOn",
		mediaDensityMatrix,					@"mediaDensityMatrix",
		mediaScatteringGroupOn,			@"mediaScatteringGroupOn",
		mediaScatteringTypePopUp,		@"mediaScatteringTypePopUp",
		mediaScatteringColorWell,			@"mediaScatteringColorWell",
		mediaScatteringEccentricityEdit,	@"mediaScatteringEccentricityEdit",
		mediaScatteringExtinctionOn,		@"mediaScatteringExtinctionOn",
		mediaScatteringExtinctionEdit,		@"mediaScatteringExtinctionEdit",
		mediaScatteringColorWell,			@"mediaScatteringColorWell",
		mediaSamplingMethodPopUp,		@"mediaSamplingMethodPopUp",
		mediaSamplingIntervalsOn,			@"mediaSamplingIntervalsOn",
		mediaSamplingIntervalsEdit,		@"mediaSamplingIntervalsEdit",
		mediaSamplingSamplesOn,			@"mediaSamplingSamplesOn",
		mediaSamplingSamplesMinEdit,	@"mediaSamplingSamplesMinEdit",
		mediaSamplingSamplesMaxEdit,	@"mediaSamplingSamplesMaxEdit",
		mediaSamplingJitterOn,				@"mediaSamplingJitterOn",
		mediaSamplingJitterEdit,				@"mediaSamplingJitterEdit",
		mediaSamplingAaDepthOn,			@"mediaSamplingAaDepthOn",
		mediaSamplingAaDepthEdit,		@"mediaSamplingAaDepthEdit",
		mediaSamplingAaThresholdOn,	@"mediaSamplingAaThresholdOn",
		mediaSamplingAaThresholdEdit,	@"mediaSamplingAaThresholdEdit",
		mediaSamplingConfidenceOn,		@"mediaSamplingConfidenceOn",
		mediaSamplingConfidenceEdit,	@"mediaSamplingConfidenceEdit",
		mediaSamplingVarianceOn,			@"mediaSamplingVarianceOn",
		mediaSamplingVarianceEdit,		@"mediaSamplingVarianceEdit",
		mediaSamplingRatioOn,				@"mediaSamplingRatioOn",
		mediaSamplingRatioEdit,				@"mediaSamplingRatioEdit",
	nil] ;
	
	[mOutlets retain];
	
	[ToolTipAutomator setTooltips:@"mediaLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"mediaLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			mediaDensityEditPatternButton,					@"mediaDensityEditPatternButton",
			mediaDensityEditMapButton,		@"mediaDensityEditMapButton",
		nil]
		];

	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self setMediaDensityEditPattern:[preferences objectForKey:@"mediaDensityEditPattern"]];
	[self setMediaDensityEditMap:[preferences objectForKey:@"mediaDensityEditMap"]];
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

	if ( [[dict objectForKey:@"mediaDensityGroupOn"]intValue]==NSOnState)
	{
		if ( [[dict objectForKey:@"mediaDensityMatrix"]intValue]==cFirstCell)
		{
			if( mediaDensityEditPattern != nil )
				[dict setObject:mediaDensityEditPattern forKey:@"mediaDensityEditPattern"];
		}
		else if ( [[dict objectForKey:@"mediaDensityMatrix"]intValue]==cSecondCell)
		{
			if( mediaDensityEditMap != nil )
				[dict setObject:mediaDensityEditMap forKey:@"mediaDensityEditMap"];
		}
	}		
}

//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	if( [key isEqualToString:@"mediaDensityEditPattern"])
		[self setMediaDensityEditPattern:dict];
	else if( [key isEqualToString:@"mediaDensityEditMap"])
		[self setMediaDensityEditMap:dict];

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// mediaButtons:sender
//---------------------------------------------------------------------
-(IBAction) mediaButtons:(id)sender
{
	id 	prefs=nil;

	NSInteger tag=[sender tag];
	switch( tag)
	{
		case cMediaDensityEditPatternButton:
			if (mediaDensityEditPattern!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:mediaDensityEditPattern];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"mediaDensityEditPattern"];
			break;

		case cMediaDensityEditMapButton:
			if (mediaDensityEditMap!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:mediaDensityEditMap];
			[self callTemplate:menuTagTemplateDensitymap withDictionary:prefs andKeyName:@"mediaDensityEditMap"];
			break;
	}
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self mediaTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// mediaTarget:sender
//---------------------------------------------------------------------
-(IBAction) mediaTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cMediaAbsorptionGroupOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cMediaAbsorptionGroupOn:
			[self setSubViewsOfNSBox:mediaAbsorptionGroup toNSButton:mediaAbsorptionGroupOn];
			if ( sender !=self )	break;

		case 	cMediaEmissionGroupOn:
			[self setSubViewsOfNSBox:mediaEmissionGroup toNSButton:mediaEmissionGroupOn];
			if ( sender !=self )	break;
		case cMediaDensityMatrix:
			if ( [[mediaDensityMatrix selectedCell] tag] ==cFirstCell)	//pattern
			{
				[mediaDensityEditPatternButton setEnabled:YES];
				[mediaDensityEditMapButton setEnabled:NO];
			}
			else
			{
				[mediaDensityEditPatternButton setEnabled:NO];
				[mediaDensityEditMapButton setEnabled:YES];
			}
			if ( sender !=self )	break;
					
		case 	cMediaDensityGroupOn:
			[self setSubViewsOfNSBox:mediaDensityGroup toNSButton:mediaDensityGroupOn];
			if ( [mediaDensityGroupOn state]==NSOnState)
			{
				if ( [[mediaDensityMatrix selectedCell] tag] ==cFirstCell)	//pattern
				{
					[mediaDensityEditPatternButton setEnabled:YES];
					[mediaDensityEditMapButton setEnabled:NO];
				}
				else
				{
					[mediaDensityEditPatternButton setEnabled:NO];
					[mediaDensityEditMapButton setEnabled:YES];
				}
			}
			if ( sender !=self )	break;

			
		case 	cMediaScatteringGroupOn:
			[self setSubViewsOfNSBox:mediaScatteringGroup toNSButton:mediaScatteringGroupOn];
			//continue
		case 	cMediaScatteringExtinctionOn:
			[self enableObjectsAccordingToObject:mediaScatteringExtinctionOn, mediaScatteringExtinctionEdit,nil];
			if ( sender !=self )	break;

		case 	cMediaScatteringTypePopUp:
			if ( [mediaScatteringTypePopUp indexOfSelectedItem]==cHenyeyGreenstein)
			{
				[mediaScatteringEccentricityText setHidden:NO];	[mediaScatteringEccentricityEdit setHidden:NO];
			}
			else
			{
				[mediaScatteringEccentricityText setHidden:YES];	[mediaScatteringEccentricityEdit setHidden:YES];
			}
			if ( sender !=self )	break;

		
		case cMediaSamplingMethodPopUp:
			switch ([mediaSamplingMethodPopUp indexOfSelectedItem])
			{
				case cMethod1:
					[mediaSamplingJitterOn setEnabled:NO]; [mediaSamplingJitterEdit setEnabled:NO];
					[mediaSamplingAaDepthOn setEnabled:NO]; [mediaSamplingAaDepthEdit setEnabled:NO];
					[mediaSamplingAaThresholdOn setEnabled:NO]; [mediaSamplingAaThresholdEdit setEnabled:NO];
					break;
				case cMethod2:
					[mediaSamplingJitterOn setEnabled:YES]; [mediaSamplingJitterEdit setEnabled:YES];
					[mediaSamplingAaDepthOn setEnabled:NO]; [mediaSamplingAaDepthEdit setEnabled:NO];
					[mediaSamplingAaThresholdOn setEnabled:NO]; [mediaSamplingAaThresholdEdit setEnabled:NO];
					break;
				case cMethod3:
					[mediaSamplingJitterOn setEnabled:YES]; [mediaSamplingJitterEdit setEnabled:YES];
					[mediaSamplingAaDepthOn setEnabled:YES]; [mediaSamplingAaDepthEdit setEnabled:YES];
					[mediaSamplingAaThresholdOn setEnabled:YES]; [mediaSamplingAaThresholdEdit setEnabled:YES];
					break;
			}
			//continue
		case 	cMediaSamplingJitterOn:
			[self enableObjectsAccordingToObject:mediaSamplingJitterOn, mediaSamplingJitterEdit,nil];
			//continue

		case 	cMediaSamplingAaDepthOn:
			[self enableObjectsAccordingToObject:mediaSamplingAaDepthOn, mediaSamplingAaDepthEdit,nil];
			//continue

		case 	cMediaSamplingAaThresholdOn:
			[self enableObjectsAccordingToObject:mediaSamplingAaThresholdOn, mediaSamplingAaThresholdEdit,nil];
			if ( sender !=self )	break;
			
		case 	cMediaSamplingIntervalsOn:
			[self enableObjectsAccordingToObject:mediaSamplingIntervalsOn, mediaSamplingIntervalsEdit,nil];
			if ( sender !=self )	break;


		case 	cMediaSamplingConfidenceOn:
			[self enableObjectsAccordingToObject:mediaSamplingConfidenceOn, mediaSamplingConfidenceEdit,nil];
			if ( sender !=self )	break;

		case 	cMediaSamplingVarianceOn:
			[self enableObjectsAccordingToObject:mediaSamplingVarianceOn, mediaSamplingVarianceEdit,nil];
			if ( sender !=self )	break;

		case 	cMediaSamplingRatioOn:
			[self enableObjectsAccordingToObject:mediaSamplingRatioOn, mediaSamplingRatioEdit,nil];
			if ( sender !=self )	break;

		case 	cMediaSamplingSamplesOn:
			[self enableObjectsAccordingToObject:mediaSamplingSamplesOn, mediaSamplingSamplesMinText,mediaSamplingSamplesMinEdit,
												mediaSamplingSamplesMaxText,mediaSamplingSamplesMaxEdit,nil];
			if ( sender !=self )	break;

	}
	[self setModified:nil];
}


@end
