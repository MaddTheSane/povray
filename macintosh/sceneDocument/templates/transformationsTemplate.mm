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
#import "transformationsTemplate.h"
#import "pigmentTemplate.h"
#import "standardMethods.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum eTransformationPanelNumbers {
	cTransformationScale					=0,
	cTransformationTranslate			=1,
	cTransformationRotate				=2,
	cTransformationPhase				=3,
	cTransformationFrequency			=4,
	cTransformationTurbulence			=5,
	cTransformationRepeatWarp		=6,
	cTransformationBlackHoleWarp	=7,
	cTransformationMatrix				=8,
	cTransformationDisplaceWarp		=9,
	cTransformationWarp3DMapping	=10
};



@implementation TransformationsTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[[TransformationsTemplate createDefaults:menuTagTemplateTransformations]autorelease];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[TransformationsTemplate class] andTemplateType:menuTagTemplateTransformations];

	if (ds == nil )
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
	if (ds == nil )
		return nil;


	NSString *pStr=nil;
	for ( int panel=0; panel < 3; panel ++)
	{
		if ( panel ==0)	//top
			pStr=@"top";
		else if (panel==1) //mid
			pStr=@"mid";
		else						//bottom
			pStr=@"bottom";
			
		if ( [[dict objectForKey:[pStr stringByAppendingString:@"On"] ]intValue ]==NSOnState)
		{		
			switch ( [[dict objectForKey:[pStr stringByAppendingString:@"TypePopUp"]] intValue ])
			{
				case cTransformationScale:
					[ds copyTabAndText:@"scale "];
					[ds addScaleVector:dict  popup:[pStr stringByAppendingString:@"ScalePopUp"] 
												xKey:[pStr stringByAppendingString:@"ScaleMatrixX"]
												yKey:[pStr stringByAppendingString:@"ScaleMatrixY"]
												zKey:[pStr stringByAppendingString:@"ScaleMatrixZ"]];
					[ds copyText:@"\n"];
					break;
				case cTransformationTranslate:
					[ds copyTabAndText:@"translate "];
					[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"TranslatePopUp"] 
												xKey:[pStr stringByAppendingString:@"TranslateMatrixX"]
												yKey:[pStr stringByAppendingString:@"TranslateMatrixY"]
												zKey:[pStr stringByAppendingString:@"TranslateMatrixZ"]];
					[ds copyTabAndText:@"\n"];
					break;
				case cTransformationRotate:
					[ds copyTabAndText:@"rotate "];
					[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"RotatePopUp"] 
												xKey:[pStr stringByAppendingString:@"RotateMatrixX"]
												yKey:[pStr stringByAppendingString:@"RotateMatrixY"]
												zKey:[pStr stringByAppendingString:@"RotateMatrixZ"]];
					[ds copyText:@"\n"];
					break;
				case cTransformationPhase:
					[ds appendTabAndFormat:@"phase %@\n",[dict objectForKey:[pStr stringByAppendingString:@"PhaseEdit"]]];
					break;
				case cTransformationFrequency:
					[ds appendTabAndFormat:@"frequency %@\n",[dict objectForKey:[pStr stringByAppendingString:@"FrequencyEdit"]]];
					break;
				case cTransformationTurbulence:
				//warp? ==> open
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceWarpOn"] ]intValue ]==NSOnState)
					{
						[ds copyTabAndText:@"warp {\n"];
						[ds addTab];
					}	
					[ds copyTabAndText:@"turbulence "];
					[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"TurbulencePopUp"] 
												xKey:[pStr stringByAppendingString:@"TurbulenceMatrixX"]
												yKey:[pStr stringByAppendingString:@"TurbulenceMatrixY"]
												zKey:[pStr stringByAppendingString:@"TurbulenceMatrixZ"]];
					[ds copyText:@"\n"];
					//octaves
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceOctavesOn"] ]intValue ]==NSOnState)
						[ds appendTabAndFormat:@"octaves %@\n",[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceOctavesEdit"]]];

					//omega
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceOmegaOn"] ]intValue ]==NSOnState)
						[ds appendTabAndFormat:@"omega %@\n",[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceOmegaEdit"]]];

					//lambda
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceLambdaOn"] ]intValue ]==NSOnState)
						[ds appendTabAndFormat:@"lambda %@\n",[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceLambdaEdit"]]];

				//warp? ==>close
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"TurbulenceWarpOn"] ]intValue ]==NSOnState)
					{	
						[ds removeTab];
						[ds copyTabAndText:@"}\n"];
					}	

					break;
				case cTransformationRepeatWarp:
					[ds copyTabAndText:@"warp {\n"];
					[ds addTab];
					[ds copyTabAndText:@"repeat "];

					switch( [[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpRepeatPopUp"] ]intValue ])
					{
						case 0: 
							[ds appendFormat:@"x * %@\n",[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpRepeatWidthEdit"]]];
							break;
						case 1: 	
							[ds appendFormat:@"y * %@\n",[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpRepeatWidthEdit"]]];
							break;
						case 2:
							[ds appendFormat:@"z * %@\n",[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpRepeatWidthEdit"]]];
							break;
					}
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpOffsetOn"] ]intValue ]==NSOnState)
					{
						[ds copyTabAndText:@"offset "];
						[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"RepeatWarpOffsetPopUp"] 
													xKey:[pStr stringByAppendingString:@"RepeatWarpOffsetMatrixX"]
													yKey:[pStr stringByAppendingString:@"RepeatWarpOffsetMatrixY"]
													zKey:[pStr stringByAppendingString:@"RepeatWarpOffsetMatrixZ"]];
						[ds copyText:@"\n"];
					}
					[ds copyTabAndText:@"flip < "];
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpFlipX"] ]intValue ]==NSOnState)
						[ds copyText:@"1, "];
					else
						[ds copyText:@"0, "];
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpFlipY"] ]intValue ]==NSOnState)
						[ds copyText:@"1, "];
					else
						[ds copyText:@"0, "];
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"RepeatWarpFlipZ"] ]intValue ]==NSOnState)
						[ds copyText:@"1>\n"];
					else
						[ds copyText:@"0>\n"];

					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
		
					break;
				case cTransformationBlackHoleWarp:
					[ds copyTabAndText:@"warp {\n"];
					[ds addTab];
					[ds copyTabAndText:@"black_hole "];
					[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"BlackHoleCenterPopUp"] 
													xKey:[pStr stringByAppendingString:@"BlackHoleCenterMatrixX"]
													yKey:[pStr stringByAppendingString:@"BlackHoleCenterMatrixY"]
													zKey:[pStr stringByAppendingString:@"BlackHoleCenterMatrixZ"]];
					[ds appendFormat:@", %@\n",[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleRadiusEdit"]]];

					//falloff
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleFalloffOn"] ]intValue ]==NSOnState)
						[ds appendTabAndFormat:@"falloff %@\n",[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleFalloffEdit"]]];

					//strength
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleStrengthOn"] ]intValue ]==NSOnState)
						[ds appendTabAndFormat:@"strength %@\n",[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleStrengthEdit"]]];

					//repeat
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleRepeatOn"] ]intValue ]==NSOnState)
					{
						[ds copyTabAndText:@"repeat "];
						[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"BlackHoleRepeatPopUp"] 
													xKey:[pStr stringByAppendingString:@"BlackHoleRepeatMatrixX"]
													yKey:[pStr stringByAppendingString:@"BlackHoleRepeatMatrixY"]
													zKey:[pStr stringByAppendingString:@"BlackHoleRepeatMatrixZ"]];
						[ds copyTabAndText:@"\n"];
					}
					
					//turbulence
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleTurbulenceOn"] ]intValue ]==NSOnState)
					{
						[ds copyTabAndText:@"turbulence "];
						[ds addXYZVector:dict popup:[pStr stringByAppendingString:@"BlackHoleTurbulencePopUp"] 
													xKey:[pStr stringByAppendingString:@"BlackHoleTurbulenceMatrixX"]
													yKey:[pStr stringByAppendingString:@"BlackHoleTurbulenceMatrixY"]
													zKey:[pStr stringByAppendingString:@"BlackHoleTurbulenceMatrixZ"]];
						[ds copyText:@"\n"];
					}

					//Inverse
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"BlackHoleInverseOn"] ]intValue ]==NSOnState)
						[ds copyTabAndText:@"inverse\n"];
					
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					break;				
				case cTransformationMatrix:
					[ds copyTabAndText:@"matrix <\n"];
					[ds addTab];
					[ds appendTabAndFormat:@"%@, %@, %@,\n",[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix00"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix01"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix02"]]];

					[ds appendTabAndFormat:@"%@, %@, %@,\n",[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix10"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix11"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix12"]]];
																											
					[ds appendTabAndFormat:@"%@, %@, %@,\n",[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix20"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix21"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix22"]]];

					[ds appendTabAndFormat:@"%@, %@, %@\n",[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix30"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix31"]],
																						[dict objectForKey:[pStr stringByAppendingString:@"MatrixMatrix32"]]];

					[ds removeTab];
					[ds copyTabAndText:@">\n"];
					break;					
				case cTransformationDisplaceWarp:
					[ds copyTabAndText:@"warp {\n"];
					[ds addTab];
					[ds copyTabAndText:@"displace {\n "];
					[ds addTab];
					WritePigment(cForceDontWrite, ds, [dict objectForKey:[pStr stringByAppendingString:@"TransformationsDisplayWarp"]], NO);
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					break;	

				case cTransformationWarp3DMapping:
					[ds copyTabAndText:@"warp {\n"];
					[ds addTab];
					switch( [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ])
					{
						case cWarp3DCylindrical:	[ds copyTabAndText:@"cylindrical\n"];		break;
						case cWarp3DPlanar:	[ds copyTabAndText:@"planar "];;			break;
						case cWarp3DSpherical:	[ds copyTabAndText:@"spherical\n"];		break;
						case cWarp3DTorodial:	[ds copyTabAndText:@"toroidal\n"];			break;
					}
				//orientation
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DOrientationOn"] ]intValue ]==NSOnState && 
							 [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ]!= cWarp3DPlanar)
					{
						[ds copyTabAndText:@"orientation "];
						[ds addXYZVector:dict popup:nil
														xKey:[pStr stringByAppendingString:@"Warp3DOrientationMatrixX"]
														yKey:[pStr stringByAppendingString:@"Warp3DOrientationMatrixY"]
														zKey:[pStr stringByAppendingString:@"Warp3DOrientationMatrixZ"]];
						[ds copyText:@"\n"];
					}
					else if (  [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ]== cWarp3DPlanar)
					{
						[ds addXYZVector:dict popup:nil
														xKey:[pStr stringByAppendingString:@"Warp3DNormalMatrixX"]
														yKey:[pStr stringByAppendingString:@"Warp3DNormalMatrixY"]
														zKey:[pStr stringByAppendingString:@"Warp3DNormalMatrixZ"]];
					}
				//dist_exp
					if ( [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DDistExpOn"] ]intValue ]==NSOnState && 
							 [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ]!= cWarp3DPlanar)
					{
						[ds appendTabAndFormat:@"dist_exp %@\n",[dict objectForKey:[pStr stringByAppendingString:@"Warp3DDistExpEdit"]]];
					}
					else if (  [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ]== cWarp3DPlanar)
					{
						[ds appendFormat:@", %@\n",[dict objectForKey:[pStr stringByAppendingString:@"Warp3DDistanceEdit"]]];
					}

					if ( [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DMajorRadiusOn"] ]intValue ]==NSOnState && 
							 [[dict objectForKey:[pStr stringByAppendingString:@"Warp3DTypePopUp"] ]intValue ]== 3)
						[ds appendTabAndFormat:@"major_radius %@\n",[dict objectForKey:[pStr stringByAppendingString:@"Warp3DMajorRadiusEdit"]]];

					[ds removeTab];
					[ds copyTabAndText:@"}\n"];

					break;
				
			}	//switch popupgroupbox
		}	//if box == on
	}//for panel

	return ds;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[mTopObjects release];
	[mMidObjects release];
	[mBottomObjects release];
	[super dealloc];
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[TransformationsTemplate createDefaults:menuTagTemplateTransformations];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"transformationsDefaultSettings",
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
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//Top
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		[NSNumber numberWithInt:NSOnState],									@"topOn",
		[NSNumber numberWithInt:cTransformationScale],					@"topTypePopUp",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"topScalePopUp",
		@"1.0",																					@"topScaleMatrixX",
		@"1.0",																					@"topScaleMatrixY",
		@"1.0",																					@"topScaleMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"topTranslatePopUp",
		@"0.0",																					@"topTranslateMatrixX",
		@"0.0",																					@"topTranslateMatrixY",
		@"0.0",																					@"topTranslateMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"topRotatePopUp",
		@"0.0",																					@"topRotateMatrixX",
		@"0.0",																					@"topRotateMatrixY",
		@"0.0",																					@"topRotateMatrixZ",

		@"0.0",																					@"topPhaseEdit",

		@"0.0",																					@"topFrequencyEdit",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"topTurbulencePopUp",
		@"0.0",																					@"topTurbulenceMatrixX",
		@"0.0",																					@"topTurbulenceMatrixY",
		@"0.0",																					@"topTurbulenceMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"topTurbulenceOctavesOn",
		@"0.0",																					@"topTurbulenceOctavesEdit",
		[NSNumber numberWithInt:NSOffState],									@"topTurbulenceOmegaOn",
		@"0.0",																					@"topTurbulenceOmegaEdit",
		[NSNumber numberWithInt:NSOffState],									@"topTurbulenceLambdaOn",
		@"0.0",																					@"topTurbulenceLambdaEdit",
		[NSNumber numberWithInt:NSOffState],									@"topTurbulenceWarpOn",

		[NSNumber numberWithInt:cX],												@"topRepeatWarpRepeatPopUp",
		@"0.0",																					@"topRepeatWarpRepeatWidthEdit",
		[NSNumber numberWithInt:NSOffState],									@"topRepeatWarpOffsetOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"topRepeatWarpOffsetPopUp",
		@"0.0",																					@"topRepeatWarpOffsetMatrixX",
		@"0.0",																					@"topRepeatWarpOffsetMatrixY",
		@"0.0",																					@"topRepeatWarpOffsetMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"topRepeatWarpFlipX",
		[NSNumber numberWithInt:NSOffState],									@"topRepeatWarpFlipY",
		[NSNumber numberWithInt:NSOffState],									@"topRepeatWarpFlipZ",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"topBlackHoleCenterPopUp",
		@"0.0",																					@"topBlackHoleCenterMatrixX",
		@"0.0",																					@"topBlackHoleCenterMatrixY",
		@"0.0",																					@"topBlackHoleCenterMatrixZ",
		[NSNumber numberWithInt:NSOffState],									@"topBlackHoleInverseOn",
		@"0.0",																					@"topBlackHoleRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"topBlackHoleFalloffOn",
		@"0.0",																					@"topBlackHoleFalloffEdit",
		[NSNumber numberWithInt:NSOffState],									@"topBlackHoleStrengthOn",
		@"0.0",																					@"topBlackHoleStrengthEdit",
		[NSNumber numberWithInt:NSOnState],									@"topBlackHoleRepeatOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"topBlackHoleRepeatPopUp",
		@"0.0",																					@"topBlackHoleRepeatMatrixX",
		@"0.0",																					@"topBlackHoleRepeatMatrixY",
		@"0.0",																					@"topBlackHoleRepeatMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"topBlackHoleTurbulenceOn",
		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"topBlackHoleTurbulencePopUp",
		@"0.0",																					@"topBlackHoleTurbulenceMatrixX",
		@"0.0",																					@"topBlackHoleTurbulenceMatrixY",
		@"0.0",																					@"topBlackHoleTurbulenceMatrixZ",

		@"0.0",																					@"topMatrixMatrix00",
		@"0.0",																					@"topMatrixMatrix01",
		@"0.0",																					@"topMatrixMatrix02",
		@"0.0",																					@"topMatrixMatrix10",
		@"0.0",																					@"topMatrixMatrix11",
		@"0.0",																					@"topMatrixMatrix12",
		@"0.0",																					@"topMatrixMatrix20",
		@"0.0",																					@"topMatrixMatrix21",
		@"0.0",																					@"topMatrixMatrix22",
		@"0.0",																					@"topMatrixMatrix30",
		@"0.0",																					@"topMatrixMatrix31",
		@"0.0",																					@"topMatrixMatrix32",

		[NSNumber numberWithInt:cSpherical],										@"topWarp3DTypePopUp",
		[NSNumber numberWithInt:NSOffState],									@"topWarp3DDistExpOn",
		@"0.0",																					@"topWarp3DDistExpEdit",
		@"0.0",																					@"topWarp3DDistanceEdit",
		[NSNumber numberWithInt:NSOffState],									@"topWarp3DMajorRadiusOn",
		@"0.33",																				@"topWarp3DMajorRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"topWarp3DOrientationOn",
		@"0.0",																					@"topWarp3DOrientationMatrixX",
		@"1.0",																					@"topWarp3DOrientationMatrixY",
		@"0.0",																					@"topWarp3DOrientationMatrixZ",

		@"0.0",																					@"topWarp3DNormalMatrixX",
		@"1.0",																					@"topWarp3DNormalMatrixY",
		@"0.0",																					@"topWarp3DNormalMatrixZ",

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//Mid
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		[NSNumber numberWithInt:NSOnState],									@"midOn",
		[NSNumber numberWithInt:cTransformationScale],					@"midTypePopUp",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"midScalePopUp",
		@"1.0",																					@"midScaleMatrixX",
		@"1.0",																					@"midScaleMatrixY",
		@"1.0",																					@"midScaleMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"midTranslatePopUp",
		@"0.0",																					@"midTranslateMatrixX",
		@"0.0",																					@"midTranslateMatrixY",
		@"0.0",																					@"midTranslateMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"midRotatePopUp",
		@"0.0",																					@"midRotateMatrixX",
		@"0.0",																					@"midRotateMatrixY",
		@"0.0",																					@"midRotateMatrixZ",

		@"0.0",																					@"midPhaseEdit",

		@"0.0",																					@"midFrequencyEdit",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"midTurbulencePopUp",
		@"0.0",																					@"midTurbulenceMatrixX",
		@"0.0",																					@"midTurbulenceMatrixY",
		@"0.0",																					@"midTurbulenceMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"midTurbulenceOctavesOn",
		@"0.0",																					@"midTurbulenceOctavesEdit",
		[NSNumber numberWithInt:NSOffState],									@"midTurbulenceOmegaOn",
		@"0.0",																					@"midTurbulenceOmegaEdit",
		[NSNumber numberWithInt:NSOffState],									@"midTurbulenceLambdaOn", 
		@"0.0",																					@"midTurbulenceLambdaEdit",
		[NSNumber numberWithInt:NSOffState],									@"midTurbulenceWarpOn",

		[NSNumber numberWithInt:cX],												@"midRepeatWarpRepeatPopUp",
		@"0.0",																					@"midRepeatWarpRepeatWidthEdit",
		[NSNumber numberWithInt:NSOffState],									@"midRepeatWarpOffsetOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"midRepeatWarpOffsetPopUp",
		@"0.0",																					@"midRepeatWarpOffsetMatrixX",
		@"0.0",																					@"midRepeatWarpOffsetMatrixY",
		@"0.0",																					@"midRepeatWarpOffsetMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"midRepeatWarpFlipX",
		[NSNumber numberWithInt:NSOffState],									@"midRepeatWarpFlipY",
		[NSNumber numberWithInt:NSOffState],									@"midRepeatWarpFlipZ",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"midBlackHoleCenterPopUp",
		@"0.0",																					@"midBlackHoleCenterMatrixX",
		@"0.0",																					@"midBlackHoleCenterMatrixY",
		@"0.0",																					@"midBlackHoleCenterMatrixZ",
		[NSNumber numberWithInt:NSOffState],									@"midBlackHoleInverseOn",
		@"0.0",																					@"midBlackHoleRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"midBlackHoleFalloffOn",
		@"0.0",																					@"midBlackHoleFalloffEdit",
		[NSNumber numberWithInt:NSOffState],									@"midBlackHoleStrengthOn",
		@"0.0",																					@"midBlackHoleStrengthEdit",
		[NSNumber numberWithInt:NSOnState],									@"midBlackHoleRepeatOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"midBlackHoleRepeatPopUp",
		@"0.0",																					@"midBlackHoleRepeatMatrixX",
		@"0.0",																					@"midBlackHoleRepeatMatrixY",
		@"0.0",																					@"midBlackHoleRepeatMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"midBlackHoleTurbulenceOn",
		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"midBlackHoleTurbulencePopUp",
		@"0.0",																					@"midBlackHoleTurbulenceMatrixX",
		@"0.0",																					@"midBlackHoleTurbulenceMatrixY",
		@"0.0",																					@"midBlackHoleTurbulenceMatrixZ",

		@"0.0",																					@"midMatrixMatrix00",
		@"0.0",																					@"midMatrixMatrix01",
		@"0.0",																					@"midMatrixMatrix02",
		@"0.0",																					@"midMatrixMatrix10",
		@"0.0",																					@"midMatrixMatrix11",
		@"0.0",																					@"midMatrixMatrix12",
		@"0.0",																					@"midMatrixMatrix20",
		@"0.0",																					@"midMatrixMatrix21",
		@"0.0",																					@"midMatrixMatrix22",
		@"0.0",																					@"midMatrixMatrix30",
		@"0.0",																					@"midMatrixMatrix31",
		@"0.0",																					@"midMatrixMatrix32",

		[NSNumber numberWithInt:cSpherical],										@"midWarp3DTypePopUp",
		[NSNumber numberWithInt:NSOffState],									@"midWarp3DDistExpOn",
		@"0.0",																					@"midWarp3DDistExpEdit",
		@"0.0",																					@"midWarp3DDistanceEdit",
		[NSNumber numberWithInt:NSOffState],									@"midWarp3DMajorRadiusOn",
		@"0.33",																				@"midWarp3DMajorRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"midWarp3DOrientationOn",
		@"0.0",																					@"midWarp3DOrientationMatrixX",
		@"1.0",																					@"midWarp3DOrientationMatrixY",
		@"0.0",																					@"midWarp3DOrientationMatrixZ",

		@"0.0",																					@"midWarp3DNormalMatrixX",
		@"1.0",																					@"midWarp3DNormalMatrixY",
		@"0.0",																					@"midWarp3DNormalMatrixZ",
		
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//Bottom
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
		[NSNumber numberWithInt:NSOnState],									@"bottomOn",
		[NSNumber numberWithInt:cTransformationScale],					@"bottomTypePopUp",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"bottomScalePopUp",
		@"1.0",																					@"bottomScaleMatrixX",
		@"1.0",																					@"bottomScaleMatrixY",
		@"1.0",																					@"bottomScaleMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"bottomTranslatePopUp",
		@"0.0",																					@"bottomTranslateMatrixX",
		@"0.0",																					@"bottomTranslateMatrixY",
		@"0.0",																					@"bottomTranslateMatrixZ",

		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"bottomRotatePopUp",
		@"0.0",																					@"bottomRotateMatrixX",
		@"0.0",																					@"bottomRotateMatrixY",
		@"0.0",																					@"bottomRotateMatrixZ",

		@"0.0",																					@"bottomPhaseEdit",

		@"0.0",																					@"bottomFrequencyEdit",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"bottomTurbulencePopUp",
		@"0.0",																					@"bottomTurbulenceMatrixX",
		@"0.0",																					@"bottomTurbulenceMatrixY",
		@"0.0",																					@"bottomTurbulenceMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"bottomTurbulenceOctavesOn",
		@"0.0",																					@"bottomTurbulenceOctavesEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomTurbulenceOmegaOn",
		@"0.0",																					@"bottomTurbulenceOmegaEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomTurbulenceLambdaOn",
		@"0.0",																					@"bottomTurbulenceLambdaEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomTurbulenceWarpOn",

		[NSNumber numberWithInt:cX],												@"bottomRepeatWarpRepeatPopUp",
		@"0.0",																					@"bottomRepeatWarpRepeatWidthEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomRepeatWarpOffsetOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"bottomRepeatWarpOffsetPopUp",
		@"0.0",																					@"bottomRepeatWarpOffsetMatrixX",
		@"0.0",																					@"bottomRepeatWarpOffsetMatrixY",
		@"0.0",																					@"bottomRepeatWarpOffsetMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"bottomRepeatWarpFlipX",
		[NSNumber numberWithInt:NSOffState],									@"bottomRepeatWarpFlipY",
		[NSNumber numberWithInt:NSOffState],									@"bottomRepeatWarpFlipZ",

		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"bottomBlackHoleCenterPopUp",
		@"0.0",																					@"bottomBlackHoleCenterMatrixX",
		@"0.0",																					@"bottomBlackHoleCenterMatrixY",
		@"0.0",																					@"bottomBlackHoleCenterMatrixZ",
		[NSNumber numberWithInt:NSOffState],									@"bottomBlackHoleInverseOn",
		@"0.0",																					@"bottomBlackHoleRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomBlackHoleFalloffOn",
		@"0.0",																					@"bottomBlackHoleFalloffEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomBlackHoleStrengthOn",
		@"0.0",																					@"bottomBlackHoleStrengthEdit",
		[NSNumber numberWithInt:NSOnState],									@"bottomBlackHoleRepeatOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],				@"bottomBlackHoleRepeatPopUp",
		@"0.0",																					@"bottomBlackHoleRepeatMatrixX",
		@"0.0",																					@"bottomBlackHoleRepeatMatrixY",
		@"0.0",																					@"bottomBlackHoleRepeatMatrixZ",

		[NSNumber numberWithInt:NSOffState],									@"bottomBlackHoleTurbulenceOn",
		[NSNumber numberWithInt:cXYZVectorPopupXandYandZ],			@"bottomBlackHoleTurbulencePopUp",
		@"0.0",																					@"bottomBlackHoleTurbulenceMatrixX",
		@"0.0",																					@"bottomBlackHoleTurbulenceMatrixY",
		@"0.0",																					@"bottomBlackHoleTurbulenceMatrixZ",

		@"0.0",																					@"bottomMatrixMatrix00",
		@"0.0",																					@"bottomMatrixMatrix01",
		@"0.0",																					@"bottomMatrixMatrix02",
		@"0.0",																					@"bottomMatrixMatrix10",
		@"0.0",																					@"bottomMatrixMatrix11",
		@"0.0",																					@"bottomMatrixMatrix12",
		@"0.0",																					@"bottomMatrixMatrix20",
		@"0.0",																					@"bottomMatrixMatrix21",
		@"0.0",																					@"bottomMatrixMatrix22",
		@"0.0",																					@"bottomMatrixMatrix30",
		@"0.0",																					@"bottomMatrixMatrix31",
		@"0.0",																					@"bottomMatrixMatrix32",

		[NSNumber numberWithInt:cSpherical],										@"bottomWarp3DTypePopUp",
		[NSNumber numberWithInt:NSOffState],									@"bottomWarp3DDistExpOn",
		@"0.0",																					@"bottomWarp3DDistExpEdit",
		@"0.0",																					@"bottomWarp3DDistanceEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomWarp3DMajorRadiusOn",
		@"0.33",																				@"bottomWarp3DMajorRadiusEdit",
		[NSNumber numberWithInt:NSOffState],									@"bottomWarp3DOrientationOn",
		@"0.0",																					@"bottomWarp3DOrientationMatrixX",
		@"1.0",																					@"bottomWarp3DOrientationMatrixY",
		@"0.0",																					@"bottomWarp3DOrientationMatrixZ",

		@"0.0",																					@"bottomWarp3DNormalMatrixX",
		@"1.0",																					@"bottomWarp3DNormalMatrixY",
		@"0.0",																					@"bottomWarp3DNormalMatrixZ",		
	nil];
	return initialDefaults;
}


//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self setTopTransformationsDisplayWarp:[preferences objectForKey:@"topTransformationsDisplayWarp"]];
	[self setMidTransformationsDisplayWarp:[preferences objectForKey:@"midTransformationsDisplayWarp"]];
	[self setBottomTransformationsDisplayWarp:[preferences objectForKey:@"bottomTransformationsDisplayWarp"]];
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

	if ( [[dict objectForKey:@"topOn"]intValue ]==NSOnState)
	{		
		if ( [[dict objectForKey:@"topTypePopUp"]intValue ]==cTransformationDisplaceWarp)
		{
			if( topTransformationsDisplayWarp != nil )
				[dict setObject:topTransformationsDisplayWarp forKey:@"topTransformationsDisplayWarp"];
		}
	}

	if ( [[dict objectForKey:@"midOn"]intValue ]==NSOnState)
	{		
		if ( [[dict objectForKey:@"midTypePopUp"]intValue ]==cTransformationDisplaceWarp)
		{
			if( midTransformationsDisplayWarp != nil )
				[dict setObject:midTransformationsDisplayWarp forKey:@"midTransformationsDisplayWarp"];
		}
	}
	
	if ( [[dict objectForKey:@"bottomOn"]intValue ]==NSOnState)
	{		
		if ( [[dict objectForKey:@"bottomTypePopUp"]intValue ]==cTransformationDisplaceWarp)
		{
			if( bottomTransformationsDisplayWarp != nil )
				[dict setObject:bottomTransformationsDisplayWarp forKey:@"bottomTransformationsDisplayWarp"];
		}
	}
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		topOn,															@"topOn",
		topTypePopUp,												@"topTypePopUp",
//		topGroup,														@"topGroup",
//		topTabView,													@"topTabView",
		topScalePopUp,												@"topScalePopUp",
		[topScaleMatrix cellWithTag:0],						@"topScaleMatrixX",
		[topScaleMatrix cellWithTag:1],						@"topScaleMatrixY",
		[topScaleMatrix cellWithTag:2],						@"topScaleMatrixZ",
		topTranslatePopUp,										@"topTranslatePopUp",
		[topTranslateMatrix cellWithTag:0],					@"topTranslateMatrixX",
		[topTranslateMatrix cellWithTag:1],					@"topTranslateMatrixY",
		[topTranslateMatrix cellWithTag:2],					@"topTranslateMatrixZ",
		topRotatePopUp,											@"topRotatePopUp",
		[topRotateMatrix cellWithTag:0],						@"topRotateMatrixX",
		[topRotateMatrix cellWithTag:1],						@"topRotateMatrixY",
		[topRotateMatrix cellWithTag:2],						@"topRotateMatrixZ",
		topPhaseEdit,													@"topPhaseEdit",
		topFrequencyEdit,											@"topFrequencyEdit",
		topTurbulencePopUp,										@"topTurbulencePopUp",
		[topTurbulenceMatrix cellWithTag:0],				@"topTurbulenceMatrixX",
		[topTurbulenceMatrix cellWithTag:1],				@"topTurbulenceMatrixY",
		[topTurbulenceMatrix cellWithTag:2],				@"topTurbulenceMatrixZ",
		topTurbulenceOctavesOn,								@"topTurbulenceOctavesOn",
		topTurbulenceOctavesEdit,								@"topTurbulenceOctavesEdit",
		topTurbulenceOmegaOn,								@"topTurbulenceOmegaOn",
		topTurbulenceOmegaEdit,								@"topTurbulenceOmegaEdit",
		topTurbulenceLambdaOn,								@"topTurbulenceLambdaOn",
		topTurbulenceLambdaEdit,								@"topTurbulenceLambdaEdit",
		topTurbulenceWarpOn,									@"topTurbulenceWarpOn",
		topRepeatWarpRepeatPopUp,							@"topRepeatWarpRepeatPopUp",
		topRepeatWarpRepeatWidthEdit,						@"topRepeatWarpRepeatWidthEdit",
		topRepeatWarpOffsetOn,								@"topRepeatWarpOffsetOn",
		topRepeatWarpOffsetPopUp,							@"topRepeatWarpOffsetPopUp",
		[topRepeatWarpOffsetMatrix cellWithTag:0],		@"topRepeatWarpOffsetMatrixX",
		[topRepeatWarpOffsetMatrix cellWithTag:1],		@"topRepeatWarpOffsetMatrixY",
		[topRepeatWarpOffsetMatrix cellWithTag:2],		@"topRepeatWarpOffsetMatrixZ",
		topRepeatWarpFlipX,										@"topRepeatWarpFlipX",
		topRepeatWarpFlipY,										@"topRepeatWarpFlipY",
		topRepeatWarpFlipZ,										@"topRepeatWarpFlipZ",
		topBlackHoleCenterPopUp,								@"topBlackHoleCenterPopUp",
		[topBlackHoleCenterMatrix cellWithTag:0]	,		@"topBlackHoleCenterMatrixX",
		[topBlackHoleCenterMatrix cellWithTag:1]	,		@"topBlackHoleCenterMatrixY",
		[topBlackHoleCenterMatrix cellWithTag:2],		@"topBlackHoleCenterMatrixZ",
		topBlackHoleInverseOn,									@"topBlackHoleInverseOn",
		topBlackHoleRadiusEdit,									@"topBlackHoleRadiusEdit",
		topBlackHoleFalloffOn,									@"topBlackHoleFalloffOn",
		topBlackHoleFalloffEdit,									@"topBlackHoleFalloffEdit",
		topBlackHoleStrengthOn,									@"topBlackHoleStrengthOn",
		topBlackHoleStrengthEdit,								@"topBlackHoleStrengthEdit",
		topBlackHoleRepeatOn,									@"topBlackHoleRepeatOn",
		topBlackHoleRepeatPopUp,								@"topBlackHoleRepeatPopUp",
		[topBlackHoleRepeatMatrix cellWithTag:0],		@"topBlackHoleRepeatMatrixX",
		[topBlackHoleRepeatMatrix cellWithTag:1],		@"topBlackHoleRepeatMatrixY",
		[topBlackHoleRepeatMatrix cellWithTag:2],		@"topBlackHoleRepeatMatrixZ",
		topBlackHoleTurbulenceOn,							@"topBlackHoleTurbulenceOn",
		topBlackHoleTurbulencePopUp,						@"topBlackHoleTurbulencePopUp",
		[topBlackHoleTurbulenceMatrix cellWithTag:0],	@"topBlackHoleTurbulenceMatrixX",
		[topBlackHoleTurbulenceMatrix cellWithTag:1],	@"topBlackHoleTurbulenceMatrixY",
		[topBlackHoleTurbulenceMatrix cellWithTag:2],	@"topBlackHoleTurbulenceMatrixZ",
		[topMatrixMatrix cellWithTag:0],						@"topMatrixMatrix00",
		[topMatrixMatrix cellWithTag:1],						@"topMatrixMatrix01",
		[topMatrixMatrix cellWithTag:2],						@"topMatrixMatrix02",
		[topMatrixMatrix cellWithTag:3],						@"topMatrixMatrix10",
		[topMatrixMatrix cellWithTag:4],						@"topMatrixMatrix11",
		[topMatrixMatrix cellWithTag:5],						@"topMatrixMatrix12",
		[topMatrixMatrix cellWithTag:6],						@"topMatrixMatrix20",
		[topMatrixMatrix cellWithTag:7],						@"topMatrixMatrix21",
		[topMatrixMatrix cellWithTag:8],						@"topMatrixMatrix22",
		[topMatrixMatrix cellWithTag:9],						@"topMatrixMatrix30",
		[topMatrixMatrix cellWithTag:10],					@"topMatrixMatrix31",
		[topMatrixMatrix cellWithTag:11],					@"topMatrixMatrix32",
		topWarp3DTypePopUp,									@"topWarp3DTypePopUp",
		topWarp3DDistExpOn,									@"topWarp3DDistExpOn",
		topWarp3DDistExpEdit,									@"topWarp3DDistExpEdit",
		topWarp3DDistanceEdit,									@"topWarp3DDistanceEdit",
		topWarp3DMajorRadiusOn,								@"topWarp3DMajorRadiusOn",
		topWarp3DMajorRadiusEdit,							@"topWarp3DMajorRadiusEdit",
		topWarp3DOrientationOn,								@"topWarp3DOrientationOn",
		[topWarp3DOrientationMatrix cellWithTag:0],	@"topWarp3DOrientationMatrixX",
		[topWarp3DOrientationMatrix cellWithTag:1],	@"topWarp3DOrientationMatrixY",
		[topWarp3DOrientationMatrix cellWithTag:2],	@"topWarp3DOrientationMatrixZ",
		[topWarp3DNormalMatrix cellWithTag:0],			@"topWarp3DNormalMatrixX",
		[topWarp3DNormalMatrix cellWithTag:1],			@"topWarp3DNormalMatrixY",
		[topWarp3DNormalMatrix cellWithTag:2],			@"topWarp3DNormalMatrixZ",

		midOn,																@"midOn",
		midTypePopUp,													@"midTypePopUp",
//		midGroup,															@"midGroup",
//		midTabView,														@"midTabView",
		midScalePopUp,													@"midScalePopUp",
		[midScaleMatrix cellWithTag:0],							@"midScaleMatrixX",
		[midScaleMatrix cellWithTag:1],							@"midScaleMatrixY",
		[midScaleMatrix cellWithTag:2],							@"midScaleMatrixZ",
		midTranslatePopUp,											@"midTranslatePopUp",
		[midTranslateMatrix cellWithTag:0],						@"midTranslateMatrixX",
		[midTranslateMatrix cellWithTag:1],						@"midTranslateMatrixY",
		[midTranslateMatrix cellWithTag:2],						@"midTranslateMatrixZ",
		midRotatePopUp,												@"midRotatePopUp",
		[midRotateMatrix cellWithTag:0],							@"midRotateMatrixX",
		[midRotateMatrix cellWithTag:1],							@"midRotateMatrixY",
		[midRotateMatrix cellWithTag:2],							@"midRotateMatrixZ",
		midPhaseEdit,													@"midPhaseEdit",
		midFrequencyEdit,												@"midFrequencyEdit",
		midTurbulencePopUp,										@"midTurbulencePopUp",
		[midTurbulenceMatrix cellWithTag:0],					@"midTurbulenceMatrixX",
		[midTurbulenceMatrix cellWithTag:1],					@"midTurbulenceMatrixY",
		[midTurbulenceMatrix cellWithTag:2],					@"midTurbulenceMatrixZ",
		midTurbulenceOctavesOn,									@"midTurbulenceOctavesOn",
		midTurbulenceOctavesEdit,									@"midTurbulenceOctavesEdit",
		midTurbulenceOmegaOn,									@"midTurbulenceOmegaOn",
		midTurbulenceOmegaEdit,									@"midTurbulenceOmegaEdit",
		midTurbulenceLambdaOn,									@"midTurbulenceLambdaOn",
		midTurbulenceLambdaEdit,								@"midTurbulenceLambdaEdit",
		midTurbulenceWarpOn,										@"midTurbulenceWarpOn",
		midRepeatWarpRepeatPopUp,							@"midRepeatWarpRepeatPopUp",
		midRepeatWarpRepeatWidthEdit,						@"midRepeatWarpRepeatWidthEdit",
		midRepeatWarpOffsetOn,									@"midRepeatWarpOffsetOn",
		midRepeatWarpOffsetPopUp,								@"midRepeatWarpOffsetPopUp",
		[midRepeatWarpOffsetMatrix cellWithTag:0],		@"midRepeatWarpOffsetMatrixX",
		[midRepeatWarpOffsetMatrix cellWithTag:1],		@"midRepeatWarpOffsetMatrixY",
		[midRepeatWarpOffsetMatrix cellWithTag:2],		@"midRepeatWarpOffsetMatrixZ",
		midRepeatWarpFlipX,											@"midRepeatWarpFlipX",
		midRepeatWarpFlipY,											@"midRepeatWarpFlipY",
		midRepeatWarpFlipZ,											@"midRepeatWarpFlipZ",
		midBlackHoleCenterPopUp,									@"midBlackHoleCenterPopUp",
		[midBlackHoleCenterMatrix cellWithTag:0],			@"midBlackHoleCenterMatrixX",
		[midBlackHoleCenterMatrix cellWithTag:1],			@"midBlackHoleCenterMatrixY",
		[midBlackHoleCenterMatrix cellWithTag:2],			@"midBlackHoleCenterMatrixZ",
		midBlackHoleInverseOn,										@"midBlackHoleInverseOn",
		midBlackHoleRadiusEdit,										@"midBlackHoleRadiusEdit",
		midBlackHoleFalloffOn,										@"midBlackHoleFalloffOn",
		midBlackHoleFalloffEdit,										@"midBlackHoleFalloffEdit",
		midBlackHoleStrengthOn,									@"midBlackHoleStrengthOn",
		midBlackHoleStrengthEdit,									@"midBlackHoleStrengthEdit",
		midBlackHoleRepeatOn,										@"midBlackHoleRepeatOn",
		midBlackHoleRepeatPopUp,								@"midBlackHoleRepeatPopUp",
		[midBlackHoleRepeatMatrix cellWithTag:0],			@"midBlackHoleRepeatMatrixX",
		[midBlackHoleRepeatMatrix cellWithTag:1],			@"midBlackHoleRepeatMatrixY",
		[midBlackHoleRepeatMatrix cellWithTag:2],			@"midBlackHoleRepeatMatrixZ",
		midBlackHoleTurbulenceOn,								@"midBlackHoleTurbulenceOn",
		midBlackHoleTurbulencePopUp,							@"midBlackHoleTurbulencePopUp",
		[midBlackHoleTurbulenceMatrix cellWithTag:0],	@"midBlackHoleTurbulenceMatrixX",
		[midBlackHoleTurbulenceMatrix cellWithTag:1],	@"midBlackHoleTurbulenceMatrixY",
		[midBlackHoleTurbulenceMatrix cellWithTag:2],	@"midBlackHoleTurbulenceMatrixZ",
		[midMatrixMatrix cellWithTag:0],							@"midMatrixMatrix00",
		[midMatrixMatrix cellWithTag:1],							@"midMatrixMatrix01",
		[midMatrixMatrix cellWithTag:2],							@"midMatrixMatrix02",
		[midMatrixMatrix cellWithTag:3],							@"midMatrixMatrix10",
		[midMatrixMatrix cellWithTag:4],							@"midMatrixMatrix11",
		[midMatrixMatrix cellWithTag:5],							@"midMatrixMatrix12",
		[midMatrixMatrix cellWithTag:6],							@"midMatrixMatrix20",
		[midMatrixMatrix cellWithTag:7],							@"midMatrixMatrix21",
		[midMatrixMatrix cellWithTag:8],							@"midMatrixMatrix22",
		[midMatrixMatrix cellWithTag:9],							@"midMatrixMatrix30",
		[midMatrixMatrix cellWithTag:10],						@"midMatrixMatrix31",
		[midMatrixMatrix cellWithTag:11]	,						@"midMatrixMatrix32",
		midWarp3DTypePopUp,										@"midWarp3DTypePopUp",
		midWarp3DDistExpOn,										@"midWarp3DDistExpOn",
		midWarp3DDistExpEdit,										@"midWarp3DDistExpEdit",
		midWarp3DDistanceEdit,									@"midWarp3DDistanceEdit",
		midWarp3DMajorRadiusOn,								@"midWarp3DMajorRadiusOn",
		midWarp3DMajorRadiusEdit,								@"midWarp3DMajorRadiusEdit",
		midWarp3DOrientationOn,									@"midWarp3DOrientationOn",
		[midWarp3DOrientationMatrix cellWithTag:0],		@"midWarp3DOrientationMatrixX",
		[midWarp3DOrientationMatrix cellWithTag:1],		@"midWarp3DOrientationMatrixY",
		[midWarp3DOrientationMatrix cellWithTag:2],		@"midWarp3DOrientationMatrixZ",
		[midWarp3DNormalMatrix cellWithTag:0],			@"midWarp3DNormalMatrixX",
		[midWarp3DNormalMatrix cellWithTag:1],			@"midWarp3DNormalMatrixY",
		[midWarp3DNormalMatrix cellWithTag:2],			@"midWarp3DNormalMatrixZ",
		
		bottomOn,															@"bottomOn",
		bottomTypePopUp,											@"bottomTypePopUp",
//		bottomGroup,													@"bottomGroup",
//		bottomTabView,													@"bottomTabView",
		bottomScalePopUp,											@"bottomScalePopUp",
		[bottomScaleMatrix cellWithTag:0],						@"bottomScaleMatrixX",
		[bottomScaleMatrix cellWithTag:1],						@"bottomScaleMatrixY",
		[bottomScaleMatrix cellWithTag:2],						@"bottomScaleMatrixZ",
		bottomTranslatePopUp,										@"bottomTranslatePopUp",
		[bottomTranslateMatrix cellWithTag:0],				@"bottomTranslateMatrixX",
		[bottomTranslateMatrix cellWithTag:1],				@"bottomTranslateMatrixY",
		[bottomTranslateMatrix cellWithTag:2],				@"bottomTranslateMatrixZ",
		bottomRotatePopUp,											@"bottomRotatePopUp",
		[bottomRotateMatrix cellWithTag:0],						@"bottomRotateMatrixX",
		[bottomRotateMatrix cellWithTag:1],						@"bottomRotateMatrixY",
		[bottomRotateMatrix cellWithTag:2],						@"bottomRotateMatrixZ",
		bottomPhaseEdit,												@"bottomPhaseEdit",
		bottomFrequencyEdit,											@"bottomFrequencyEdit",
		bottomTurbulencePopUp,									@"bottomTurbulencePopUp",
		[bottomTurbulenceMatrix cellWithTag:0],				@"bottomTurbulenceMatrixX",
		[bottomTurbulenceMatrix cellWithTag:1],				@"bottomTurbulenceMatrixY",
		[bottomTurbulenceMatrix cellWithTag:2],				@"bottomTurbulenceMatrixZ",
		bottomTurbulenceOctavesOn,								@"bottomTurbulenceOctavesOn",
		bottomTurbulenceOctavesEdit,							@"bottomTurbulenceOctavesEdit",
		bottomTurbulenceOmegaOn,								@"bottomTurbulenceOmegaOn",
		bottomTurbulenceOmegaEdit,								@"bottomTurbulenceOmegaEdit",
		bottomTurbulenceLambdaOn,								@"bottomTurbulenceLambdaOn",
		bottomTurbulenceLambdaEdit,							@"bottomTurbulenceLambdaEdit",
		bottomTurbulenceWarpOn,									@"bottomTurbulenceWarpOn",
		bottomRepeatWarpRepeatPopUp,						@"bottomRepeatWarpRepeatPopUp",
		bottomRepeatWarpRepeatWidthEdit,					@"bottomRepeatWarpRepeatWidthEdit",
		bottomRepeatWarpOffsetOn,								@"bottomRepeatWarpOffsetOn",
		bottomRepeatWarpOffsetPopUp,							@"bottomRepeatWarpOffsetPopUp",
		[bottomRepeatWarpOffsetMatrix cellWithTag:0],	@"bottomRepeatWarpOffsetMatrixX",
		[bottomRepeatWarpOffsetMatrix cellWithTag:1],	@"bottomRepeatWarpOffsetMatrixY",
		[bottomRepeatWarpOffsetMatrix cellWithTag:2]	,	@"bottomRepeatWarpOffsetMatrixZ",
		bottomRepeatWarpFlipX,									@"bottomRepeatWarpFlipX",
		bottomRepeatWarpFlipY,										@"bottomRepeatWarpFlipY",
		bottomRepeatWarpFlipZ,										@"bottomRepeatWarpFlipZ",
		bottomBlackHoleCenterPopUp,							@"bottomBlackHoleCenterPopUp",
		[bottomBlackHoleCenterMatrix cellWithTag:0],		@"bottomBlackHoleCenterMatrixX",
		[bottomBlackHoleCenterMatrix cellWithTag:1],		@"bottomBlackHoleCenterMatrixY",
		[bottomBlackHoleCenterMatrix cellWithTag:2],		@"bottomBlackHoleCenterMatrixZ",
		bottomBlackHoleInverseOn,									@"bottomBlackHoleInverseOn",
		bottomBlackHoleRadiusEdit,								@"bottomBlackHoleRadiusEdit",
		bottomBlackHoleFalloffOn,									@"bottomBlackHoleFalloffOn",
		bottomBlackHoleFalloffEdit,									@"bottomBlackHoleFalloffEdit",
		bottomBlackHoleStrengthOn,								@"bottomBlackHoleStrengthOn",
		bottomBlackHoleStrengthEdit,								@"bottomBlackHoleStrengthEdit",
		bottomBlackHoleRepeatOn,									@"bottomBlackHoleRepeatOn",
		bottomBlackHoleRepeatPopUp,							@"bottomBlackHoleRepeatPopUp",
		[bottomBlackHoleRepeatMatrix cellWithTag:0],		@"bottomBlackHoleRepeatMatrixX",
		[bottomBlackHoleRepeatMatrix cellWithTag:1],		@"bottomBlackHoleRepeatMatrixY",
		[bottomBlackHoleRepeatMatrix cellWithTag:2],		@"bottomBlackHoleRepeatMatrixZ",
		bottomBlackHoleTurbulenceOn,							@"bottomBlackHoleTurbulenceOn",
		bottomBlackHoleTurbulencePopUp,						@"bottomBlackHoleTurbulencePopUp",
		[bottomBlackHoleTurbulenceMatrix cellWithTag:0],@"bottomBlackHoleTurbulenceMatrixX",
		[bottomBlackHoleTurbulenceMatrix cellWithTag:1],	@"bottomBlackHoleTurbulenceMatrixY",
		[bottomBlackHoleTurbulenceMatrix cellWithTag:2],	@"bottomBlackHoleTurbulenceMatrixZ",
		[bottomMatrixMatrix cellWithTag:0],						@"bottomMatrixMatrix00",
		[bottomMatrixMatrix cellWithTag:1],						@"bottomMatrixMatrix01",
		[bottomMatrixMatrix cellWithTag:2],						@"bottomMatrixMatrix02",
		[bottomMatrixMatrix cellWithTag:3],						@"bottomMatrixMatrix10",
		[bottomMatrixMatrix cellWithTag:4],						@"bottomMatrixMatrix11",
		[bottomMatrixMatrix cellWithTag:5],						@"bottomMatrixMatrix12",
		[bottomMatrixMatrix cellWithTag:6],						@"bottomMatrixMatrix20",
		[bottomMatrixMatrix cellWithTag:7],						@"bottomMatrixMatrix21",
		[bottomMatrixMatrix cellWithTag:8],						@"bottomMatrixMatrix22",
		[bottomMatrixMatrix cellWithTag:9],						@"bottomMatrixMatrix30",
		[bottomMatrixMatrix cellWithTag:10],					@"bottomMatrixMatrix31",
		[bottomMatrixMatrix cellWithTag:11],					@"bottomMatrixMatrix32",
		bottomWarp3DTypePopUp,									@"bottomWarp3DTypePopUp",
		bottomWarp3DDistExpOn,									@"bottomWarp3DDistExpOn",
		bottomWarp3DDistExpEdit,									@"bottomWarp3DDistExpEdit",
		bottomWarp3DDistanceEdit,								@"bottomWarp3DDistanceEdit",
		bottomWarp3DMajorRadiusOn,							@"bottomWarp3DMajorRadiusOn",
		bottomWarp3DMajorRadiusEdit,							@"bottomWarp3DMajorRadiusEdit",
		bottomWarp3DOrientationOn,								@"bottomWarp3DOrientationOn",
		[bottomWarp3DOrientationMatrix cellWithTag:0],	@"bottomWarp3DOrientationMatrixX",
		[bottomWarp3DOrientationMatrix cellWithTag:1],	@"bottomWarp3DOrientationMatrixY",
		[bottomWarp3DOrientationMatrix cellWithTag:2],	@"bottomWarp3DOrientationMatrixZ",
		[bottomWarp3DNormalMatrix cellWithTag:0],		@"bottomWarp3DNormalMatrixX",
		[bottomWarp3DNormalMatrix cellWithTag:1],		@"bottomWarp3DNormalMatrixY",
		[bottomWarp3DNormalMatrix cellWithTag:2],		@"bottomWarp3DNormalMatrixZ",
		



	nil] ;
	[mOutlets retain];

	[ToolTipAutomator setTooltips:@"transformationsLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"transformationsLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			topDisplaceWarpEditPatternbutton,				@"topDisplaceWarpEditPatternbutton",
			midDisplaceWarpEditPatternbutton,				@"midDisplaceWarpEditPatternbutton",
			bottomDisplaceWarpEditPatternbutton,		@"bottomDisplaceWarpEditPatternbutton",
			
			topScaleMatrix,							@"topScaleMatrix",
			topTranslateMatrix,					@"topTranslateMatrix",
			topRotateMatrix,						@"topRotateMatrix",
			topTurbulenceMatrix,					@"topTurbulenceMatrix",
			topRepeatWarpOffsetMatrix,		@"topRepeatWarpOffsetMatrix",
			topBlackHoleCenterMatrix,			@"topBlackHoleCenterMatrix",
			topBlackHoleRepeatMatrix	,		@"topBlackHoleRepeatMatrix",		
			topBlackHoleTurbulenceMatrix,	@"topBlackHoleTurbulenceMatrix",
			topMatrixMatrix,							@"topMatrixMatrix",
			topWarp3DOrientationMatrix,		@"topWarp3DOrientationMatrix",
			topWarp3DNormalMatrix,			@"topWarp3DNormalMatrix",

			midScaleMatrix,							@"midScaleMatrix",
			midTranslateMatrix,					@"midTranslateMatrix",
			midRotateMatrix,						@"midRotateMatrix",
			midTurbulenceMatrix,					@"midTurbulenceMatrix",
			midRepeatWarpOffsetMatrix,		@"midRepeatWarpOffsetMatrix",
			midBlackHoleCenterMatrix,			@"midBlackHoleCenterMatrix",
			midBlackHoleRepeatMatrix	,		@"midBlackHoleRepeatMatrix",		
			midBlackHoleTurbulenceMatrix,	@"midBlackHoleTurbulenceMatrix",
			midMatrixMatrix,						@"midMatrixMatrix",
			midWarp3DOrientationMatrix,		@"midWarp3DOrientationMatrix",
			midWarp3DNormalMatrix,			@"midWarp3DNormalMatrix",

			bottomScaleMatrix,							@"bottomScaleMatrix",
			bottomTranslateMatrix,					@"bottomTranslateMatrix",
			bottomRotateMatrix,						@"bottomRotateMatrix",
			bottomTurbulenceMatrix,				@"bottomTurbulenceMatrix",
			bottomRepeatWarpOffsetMatrix,		@"bottomRepeatWarpOffsetMatrix",
			bottomBlackHoleCenterMatrix,			@"bottomBlackHoleCenterMatrix",
			bottomBlackHoleRepeatMatrix	,		@"bottomBlackHoleRepeatMatrix",		
			bottomBlackHoleTurbulenceMatrix,	@"bottomBlackHoleTurbulenceMatrix",
			bottomMatrixMatrix,						@"bottomMatrixMatrix",
			bottomWarp3DOrientationMatrix,		@"bottomWarp3DOrientationMatrix",
			bottomWarp3DNormalMatrix,			@"bottomWarp3DNormalMatrix",
		nil]
		];
	
//mTopObjects
	mTopObjects=[NSDictionary dictionaryWithObjectsAndKeys:
		topOn,									@"On",									topTypePopUp,							@"TypePopUp",							topGroup,									@"Group",
		topTabView,							@"TabView",							topScalePopUp,							@"ScalePopUp",							topScaleMatrix,							@"ScaleMatrix",
		topTranslatePopUp,				@"TranslatePopUp",				topTranslateMatrix,					@"TranslateMatrix",					topRotatePopUp,						@"RotatePopUp",
		topRotateMatrix,					@"RotateMatrix",						topTurbulencePopUp,					@"TurbulencePopUp",					topTurbulenceMatrix,					@"TurbulenceMatrix",
		topTurbulenceOctavesOn,		@"TurbulenceOctavesOn",		topTurbulenceOctavesEdit,			@"TurbulenceOctavesEdit",			topTurbulenceOmegaOn,			@"TurbulenceOmegaOn",
		topTurbulenceOmegaEdit,		@"TurbulenceOmegaEdit",		topTurbulenceLambdaOn,			@"TurbulenceLambdaOn",			topTurbulenceLambdaEdit,			@"TurbulenceLambdaEdit",
		topRepeatWarpRepeatPopUp,	@"RepeatWarpRepeatPopUp",	topRepeatWarpRepeatWidthEdit,	@"RepeatWarpRepeatWidthEdit",	topRepeatWarpOffsetOn,			@"RepeatWarpOffsetOn",
		topRepeatWarpOffsetPopUp,	@"RepeatWarpOffsetPopUp",	topRepeatWarpOffsetMatrix,		@"RepeatWarpOffsetMatrix",		topBlackHoleCenterPopUp,			@"BlackHoleCenterPopUp",
		topBlackHoleCenterMatrix,		@"BlackHoleCenterMatrix",		topBlackHoleInverseOn,				@"BlackHoleInverseOn",				topBlackHoleFalloffOn,				@"BlackHoleFalloffOn",
		topBlackHoleFalloffEdit,			@"BlackHoleFalloffEdit",			topBlackHoleStrengthOn,				@"BlackHoleStrengthOn",				topBlackHoleStrengthEdit,			@"BlackHoleStrengthEdit",
		topBlackHoleRepeatOn,			@"BlackHoleRepeatOn",			topBlackHoleRepeatPopUp,			@"BlackHoleRepeatPopUp",			topBlackHoleRepeatMatrix,			@"BlackHoleRepeatMatrix",
		topBlackHoleTurbulenceOn,	@"BlackHoleTurbulenceOn",		topBlackHoleTurbulencePopUp,	@"BlackHoleTurbulencePopUp",	topBlackHoleTurbulenceMatrix,	@"BlackHoleTurbulenceMatrix",
		topWarp3DTypePopUp,			@"Warp3DTypePopUp",			topWarp3DDistExpOn,				@"Warp3DDistExpOn",				topWarp3DDistExpEdit,				@"Warp3DDistExpEdit",
		topWarp3DDistanceEdit,			@"Warp3DDistanceEdit",			topWarp3DMajorRadiusOn,			@"Warp3DMajorRadiusOn",
		topWarp3DMajorRadiusEdit,	@"Warp3DMajorRadiusEdit",	topWarp3DOrientationOn,			@"Warp3DOrientationOn",			topWarp3DOrientationMatrix,		@"Warp3DOrientationMatrix",
		topWarp3DNormalMatrix,		@"Warp3DNormalMatrix",		
		topWarp3DDistExpView,			@"Warp3DDistExpView",			topWarp3DDistanceView,			@"Warp3DDistanceView",			topWarp3DNormalView,				@"Warp3DNormalView",
		topWarp3DOrientationView,	@"Warp3DOrientationView",

		nil];
		[mTopObjects retain];

//mMidObjects
	mMidObjects=[NSDictionary dictionaryWithObjectsAndKeys:
		midOn,									@"On",									midTypePopUp,							@"TypePopUp",							midGroup,									@"Group",
		midTabView,							@"TabView",							midScalePopUp,							@"ScalePopUp",							midScaleMatrix,							@"ScaleMatrix",
		midTranslatePopUp,				@"TranslatePopUp",				midTranslateMatrix,					@"TranslateMatrix",					midRotatePopUp,						@"RotatePopUp",
		midRotateMatrix,					@"RotateMatrix",						midTurbulencePopUp,				@"TurbulencePopUp",					midTurbulenceMatrix,					@"TurbulenceMatrix",
		midTurbulenceOctavesOn,		@"TurbulenceOctavesOn",		midTurbulenceOctavesEdit,			@"TurbulenceOctavesEdit",			midTurbulenceOmegaOn,			@"TurbulenceOmegaOn",
		midTurbulenceOmegaEdit,		@"TurbulenceOmegaEdit",		midTurbulenceLambdaOn,			@"TurbulenceLambdaOn",			midTurbulenceLambdaEdit,		@"TurbulenceLambdaEdit",
		midRepeatWarpRepeatPopUp,@"RepeatWarpRepeatPopUp",	midRepeatWarpRepeatWidthEdit,@"RepeatWarpRepeatWidthEdit",	midRepeatWarpOffsetOn,			@"RepeatWarpOffsetOn",
		midRepeatWarpOffsetPopUp,	@"RepeatWarpOffsetPopUp",	midRepeatWarpOffsetMatrix,		@"RepeatWarpOffsetMatrix",		midBlackHoleCenterPopUp,			@"BlackHoleCenterPopUp",
		midBlackHoleCenterMatrix,		@"BlackHoleCenterMatrix",		midBlackHoleInverseOn,				@"BlackHoleInverseOn",				midBlackHoleFalloffOn,				@"BlackHoleFalloffOn",
		midBlackHoleFalloffEdit,			@"BlackHoleFalloffEdit",			midBlackHoleStrengthOn,			@"BlackHoleStrengthOn",				midBlackHoleStrengthEdit,			@"BlackHoleStrengthEdit",
		midBlackHoleRepeatOn,			@"BlackHoleRepeatOn",			midBlackHoleRepeatPopUp,		@"BlackHoleRepeatPopUp",			midBlackHoleRepeatMatrix,			@"BlackHoleRepeatMatrix",
		midBlackHoleTurbulenceOn,	@"BlackHoleTurbulenceOn",		midBlackHoleTurbulencePopUp,	@"BlackHoleTurbulencePopUp",	midBlackHoleTurbulenceMatrix,	@"BlackHoleTurbulenceMatrix",
		midWarp3DTypePopUp,			@"Warp3DTypePopUp",			midWarp3DDistExpOn,				@"Warp3DDistExpOn",				midWarp3DDistExpEdit,				@"Warp3DDistExpEdit",
		midWarp3DDistanceEdit,		@"Warp3DDistanceEdit",			midWarp3DMajorRadiusOn,		@"Warp3DMajorRadiusOn",
		midWarp3DMajorRadiusEdit,	@"Warp3DMajorRadiusEdit",	midWarp3DOrientationOn,			@"Warp3DOrientationOn",			midWarp3DOrientationMatrix,		@"Warp3DOrientationMatrix",
		midWarp3DNormalMatrix,		@"Warp3DNormalMatrix",
		midWarp3DDistExpView,		@"Warp3DDistExpView",			midWarp3DDistanceView,			@"Warp3DDistanceView",			midWarp3DNormalView,				@"Warp3DNormalView",
		midWarp3DOrientationView,	@"Warp3DOrientationView",
		nil];
		[mMidObjects retain];

//mBottomObjects
	mBottomObjects=[NSDictionary dictionaryWithObjectsAndKeys:
		bottomOn,									@"On",									bottomTypePopUp,							@"TypePopUp",							bottomGroup,								@"Group",
		bottomTabView,							@"TabView",							bottomScalePopUp,							@"ScalePopUp",							bottomScaleMatrix,							@"ScaleMatrix",
		bottomTranslatePopUp,				@"TranslatePopUp",				bottomTranslateMatrix,						@"TranslateMatrix",					bottomRotatePopUp,						@"RotatePopUp",
		bottomRotateMatrix,					@"RotateMatrix",						bottomTurbulencePopUp,					@"TurbulencePopUp",					bottomTurbulenceMatrix,				@"TurbulenceMatrix",
		bottomTurbulenceOctavesOn,		@"TurbulenceOctavesOn",		bottomTurbulenceOctavesEdit,			@"TurbulenceOctavesEdit",			bottomTurbulenceOmegaOn,			@"TurbulenceOmegaOn",
		bottomTurbulenceOmegaEdit,		@"TurbulenceOmegaEdit",		bottomTurbulenceLambdaOn,				@"TurbulenceLambdaOn",			bottomTurbulenceLambdaEdit,		@"TurbulenceLambdaEdit",
		bottomRepeatWarpRepeatPopUp,@"RepeatWarpRepeatPopUp",	bottomRepeatWarpRepeatWidthEdit,	@"RepeatWarpRepeatWidthEdit",	bottomRepeatWarpOffsetOn,			@"RepeatWarpOffsetOn",
		bottomRepeatWarpOffsetPopUp,	@"RepeatWarpOffsetPopUp",	bottomRepeatWarpOffsetMatrix,			@"RepeatWarpOffsetMatrix",		bottomBlackHoleCenterPopUp,		@"BlackHoleCenterPopUp",
		bottomBlackHoleCenterMatrix,		@"BlackHoleCenterMatrix",		bottomBlackHoleInverseOn,					@"BlackHoleInverseOn",				bottomBlackHoleFalloffOn,				@"BlackHoleFalloffOn",
		bottomBlackHoleFalloffEdit,			@"BlackHoleFalloffEdit",			bottomBlackHoleStrengthOn,				@"BlackHoleStrengthOn",				bottomBlackHoleStrengthEdit,			@"BlackHoleStrengthEdit",
		bottomBlackHoleRepeatOn,			@"BlackHoleRepeatOn",			bottomBlackHoleRepeatPopUp,			@"BlackHoleRepeatPopUp",			bottomBlackHoleRepeatMatrix,		@"BlackHoleRepeatMatrix",
		bottomBlackHoleTurbulenceOn,	@"BlackHoleTurbulenceOn",		bottomBlackHoleTurbulencePopUp,		@"BlackHoleTurbulencePopUp",	bottomBlackHoleTurbulenceMatrix,	@"BlackHoleTurbulenceMatrix",
		bottomWarp3DTypePopUp,			@"Warp3DTypePopUp",			bottomWarp3DDistExpOn,					@"Warp3DDistExpOn",				bottomWarp3DDistExpEdit,				@"Warp3DDistExpEdit",
		bottomWarp3DDistanceEdit,		@"Warp3DDistanceEdit",			bottomWarp3DMajorRadiusOn,			@"Warp3DMajorRadiusOn",
		bottomWarp3DMajorRadiusEdit,	@"Warp3DMajorRadiusEdit",	bottomWarp3DOrientationOn,				@"Warp3DOrientationOn",			bottomWarp3DOrientationMatrix,		@"Warp3DOrientationMatrix",
		bottomWarp3DNormalMatrix,		@"Warp3DNormalMatrix",
		bottomWarp3DDistExpView,		@"Warp3DDistExpView",			bottomWarp3DDistanceView,				@"Warp3DDistanceView",			bottomWarp3DNormalView,				@"Warp3DNormalView",
		bottomWarp3DOrientationView,	@"Warp3DOrientationView",
		nil];
		[mBottomObjects retain];
	[self  setValuesInPanel:[self preferences]];
	[self updateControls];

}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self topTarget:self];	
	[self midTarget:self];	
	[self bottomTarget:self];	

	[self setNotModified];
}


//---------------------------------------------------------------------
// topTarget:sender
//---------------------------------------------------------------------
- (IBAction) topTarget:(id)sender
{
	[self performTarget:sender withObjects:mTopObjects];
}

//---------------------------------------------------------------------
// midTarget:sender
//---------------------------------------------------------------------
- (IBAction) midTarget:(id)sender
{
	[self performTarget:sender withObjects:mMidObjects];
}

//---------------------------------------------------------------------
// bottomTarget:sender
//---------------------------------------------------------------------
- (IBAction) bottomTarget:(id)sender
{
	[self performTarget:sender withObjects:mBottomObjects];
}


//---------------------------------------------------------------------
// performTarget:objects
//---------------------------------------------------------------------
-(void) performTarget:(id) sender withObjects:(NSDictionary*) objects
{
	int theTag;
	int idx;
	if ( sender==self)
		theTag=cTypePopUp;
	else
		theTag=[sender tag];
	switch( theTag)
	{
//type
		case 	cTypePopUp:
			[self setTabView:[objects objectForKey:@"TabView"] toIndexOfPopup:[objects objectForKey:@"TypePopUp"]];
			if ( sender !=self )	break;

//scale
		case 	cScalePopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"ScalePopUp"] xyzMatrix:[objects objectForKey:@"ScaleMatrix"]];
			if ( sender !=self )	break;

//translate
		case 	cTranslatePopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"TranslatePopUp"] xyzMatrix:[objects objectForKey:@"TranslateMatrix"]];
			if ( sender !=self )	break;

//rotate
		case 	cRotatePopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"RotatePopUp"] xyzMatrix:[objects objectForKey:@"RotateMatrix"]];
			if ( sender !=self )	break;

//turbulenceWarp
		case 	cTurbulencePopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"TurbulencePopUp"] xyzMatrix:[objects objectForKey:@"TurbulenceMatrix"]];
			if ( sender !=self )	break;
		case 	cTurbulenceOctavesOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"TurbulenceOctavesOn"] ,[objects objectForKey:@"TurbulenceOctavesEdit"],nil];
			if ( sender !=self )	break;
		case 	cTurbulenceOmegaOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"TurbulenceOmegaOn"] ,[objects objectForKey:@"TurbulenceOmegaEdit"],nil];
			if ( sender !=self )	break;
		case 	cTurbulenceLambdaOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"TurbulenceLambdaOn"] ,[objects objectForKey:@"TurbulenceLambdaEdit"],nil];
			if ( sender !=self )	break;

//repeatWarp
		case 	cRepeatWarpOffsetPopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"RepeatWarpOffsetPopUp"] xyzMatrix:[objects objectForKey:@"RepeatWarpOffsetMatrix"]];
			if ( sender !=self )	break;
		case 	cRepeatWarpOffsetOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"RepeatWarpOffsetPopUp"], [objects objectForKey:@"RepeatWarpOffsetMatrix"],nil];
			if ( sender !=self )	break;

//blackHole
		case 	cBlackHoleCenterPopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"BlackHoleCenterPopUp"] xyzMatrix:[objects objectForKey:@"BlackHoleCenterMatrix"]];
			if ( sender !=self )	break;
		case 	cBlackHoleFalloffOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"BlackHoleFalloffOn"] ,[objects objectForKey:@"BlackHoleFalloffEdit"],nil];
			if ( sender !=self )	break;
		case 	cBlackHoleStrengthOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"BlackHoleStrengthOn"] ,[objects objectForKey:@"BlackHoleStrengthEdit"],nil];
			if ( sender !=self )	break;
		case 	cBlackHoleRepeatPopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"BlackHoleRepeatPopUp"] xyzMatrix:[objects objectForKey:@"BlackHoleRepeatMatrix"]];
			if ( sender !=self )	break;
		case 	cBlackHoleRepeatOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"BlackHoleRepeatOn"] ,[objects objectForKey:@"BlackHoleRepeatPopUp"], [objects objectForKey:@"BlackHoleRepeatMatrix"],nil];
			if ( sender !=self )	break;
		case 	cBlackHoleTurbulencePopUp:
			[self setXYZVectorAccordingToPopup:[objects objectForKey:@"BlackHoleTurbulencePopUp"] xyzMatrix:[objects objectForKey:@"BlackHoleTurbulenceMatrix"]];
			if ( sender !=self )	break;
		case 	cBlackHoleTurbulenceOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"BlackHoleTurbulenceOn"] ,[objects objectForKey:@"BlackHoleTurbulencePopUp"], [objects objectForKey:@"BlackHoleTurbulenceMatrix"],nil];
			if ( sender !=self )	break;

//Warp3D
		case 	cWarp3DDistExpOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"Warp3DDistExpOn"] ,[objects objectForKey:@"Warp3DDistExpEdit"],nil];
			if ( sender !=self )	break;
		case 	cWarp3DMajorRadiusOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"Warp3DMajorRadiusOn"] ,[objects objectForKey:@"Warp3DMajorRadiusEdit"],nil];
			if ( sender !=self )	break;
		case 	cWarp3DOrientationOn:
			[self enableObjectsAccordingToObject:[objects objectForKey:@"Warp3DOrientationOn"] ,[objects objectForKey:@"Warp3DOrientationMatrix"],nil];
			if ( sender !=self )	break;
		case 	cWarp3DTypePopUp:
			idx=[[objects objectForKey:@"Warp3DTypePopUp"]indexOfSelectedItem];
			switch (idx)
			{
				case cCylindrical:
				case cSpherical:
				case cToroidal:
					[[objects objectForKey:@"Warp3DDistanceView"] setHidden:YES];
					[[objects objectForKey:@"Warp3DDistExpView"] setHidden:NO];

					[[objects objectForKey:@"Warp3DNormalView"] setHidden:YES];

					[[objects objectForKey:@"Warp3DOrientationView"] setHidden:NO];

					if ( idx == cToroidal)
					{
						[[objects objectForKey:@"Warp3DMajorRadiusOn"] setHidden:NO];
						[[objects objectForKey:@"Warp3DMajorRadiusEdit"] setHidden:NO];
					}
					else
					{
						[[objects objectForKey:@"Warp3DMajorRadiusOn"] setHidden:YES];
						[[objects objectForKey:@"Warp3DMajorRadiusEdit"] setHidden:YES];
					}
					break;
				case cPlanar:
					[[objects objectForKey:@"Warp3DDistanceView"] setHidden:NO];

					[[objects objectForKey:@"Warp3DDistExpView"] setHidden:YES];

					[[objects objectForKey:@"Warp3DNormalView"] setHidden:NO];

					[[objects objectForKey:@"Warp3DOrientationView"] setHidden:YES];

					[[objects objectForKey:@"Warp3DMajorRadiusOn"] setHidden:YES];
					[[objects objectForKey:@"Warp3DMajorRadiusEdit"] setHidden:YES];

					break;
			}
			if ( sender !=self )	break;

//last one
		case 	cOn:
			[self setSubViewsOfNSBox:[objects objectForKey:@"Group"] toNSButton:[objects objectForKey:@"On"]];
			[self enableObjectsAccordingToObject:[objects objectForKey:@"On"] ,[objects objectForKey:@"TypePopUp"],nil];
			if ( sender !=self )	break;
	}
}


//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	if( [key isEqualToString:@"topTransformationsDisplayWarp"])
		[self setTopTransformationsDisplayWarp:dict];
	else if( [key isEqualToString:@"midTransformationsDisplayWarp"])
		[self setMidTransformationsDisplayWarp:dict];
	else if( [key isEqualToString:@"bottomTransformationsDisplayWarp"])
		[self setBottomTransformationsDisplayWarp:dict];

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// topEditWarpButton:
//---------------------------------------------------------------------
-(IBAction) topEditWarpButton:(id)sender
{
	id 	prefs=nil;
	if (topTransformationsDisplayWarp!=nil)
		prefs=[NSMutableDictionary dictionaryWithDictionary:topTransformationsDisplayWarp];
	[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"topTransformationsDisplayWarp"];

}

//---------------------------------------------------------------------
// midEditWarpButton:
//---------------------------------------------------------------------
-(IBAction) midEditWarpButton:(id)sender
{
	id 	prefs=nil;
	if (midTransformationsDisplayWarp!=nil)
		prefs=[NSMutableDictionary dictionaryWithDictionary:midTransformationsDisplayWarp];
	[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"midTransformationsDisplayWarp"];

}

//---------------------------------------------------------------------
// bottomEditWarpButton:
//---------------------------------------------------------------------
-(IBAction) bottomEditWarpButton:(id)sender
{
	id 	prefs=nil;
	if (bottomTransformationsDisplayWarp!=nil)
		prefs=[NSMutableDictionary dictionaryWithDictionary:bottomTransformationsDisplayWarp];
	[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"bottomTransformationsDisplayWarp"];

}

@end
