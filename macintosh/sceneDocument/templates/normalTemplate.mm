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

#import "normalTemplate.h"
#import "functionTemplate.h"
#import "transformationsTemplate.h"
#import "cameraTemplate.h"
#import "bodymapTemplate.h"
#import "slopeMapTemplate.h"
#import "objectTemplate.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"
#import "tooltipAutomator.h"
#import "colormap.h"

// this must be the last file included
#import "syspovdebug.h"

static void WriteFullNormal(MutableTabString *ds,NSDictionary *dict, 
									NSString *ScalePoUp, NSString *NormalPopUp, NSString *ArmsPopUp,
									NSString *AmountOn, NSString *AmountEdit, NSString *ScaleOn,
									NSString *ScaleX, NSString *ScaleY, NSString *ScaleZ);

static NSString * GetNormalPatternPopup(NSDictionary *dict, NSString *NormalPopUp, NSString  *ArmsPopUp);
static void WriteSpecificNormal(NSDictionary *dict, MutableTabString *ds,NSString *nameString);
static void WriteStandardNormal(NSDictionary *dict, MutableTabString *ds,NSString *nameString);

#define kWriteSlopemap	if ( [[dict objectForKey:@"normalNormalSlopeMapOn"]intValue]==NSOnState)\
					{\
						[SlopemapTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalSlopemap"]\
							andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];\
					}
					
#define kWriteNormalmap if ( [[dict objectForKey:@"normalNormalMapOn"]intValue]==NSOnState)\
					{\
						[BodymapTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalNormalmap"]\
							andTabs:[ds currentTabs] extraParam:menuTagTemplateNormalmap mutableTabString:ds];\
					}

#define kWriteAmount if ( [[dict objectForKey:@"normalAmountOn"]intValue]==NSOnState)\
				[ds appendTabAndFormat:@"%@\t//amount\n",[dict objectForKey:@"normalAmountEdit"]];

#define kWriteBumpsize if ( [[dict objectForKey:@"normalBumpSizeOn"]intValue]==NSOnState)\
				[ds appendTabAndFormat:@"bump_size %@\n",[dict objectForKey:@"normalBumpSizeEdit"]];

@implementation NormalTemplate

//---------------------------------------------------------------------
// normalMainViewNIBView
//---------------------------------------------------------------------
-(NSView*) normalMainViewNIBView
{
	return normalMainViewNIBView;
}

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{
	if ( dict== nil)
		dict=[NormalTemplate createDefaults:menuTagTemplateNormal];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[NormalTemplate class] andTemplateType:menuTagTemplateNormal];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	if ( [[dict objectForKey:@"normalDontWrapInNormal"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"normal {\n"];
		[ds addTab];
	}

	switch( [[dict objectForKey:@"normalMainTabView"]intValue])	//normal type
	{
//cNormalImageMapTab**************************************************************************************************cNormalImageMapTab
		case cNormalImageMapTab:
			[ds copyTabAndText:@"bump_map {\n"];
			WritePatternPanel(ds, dict, @"normalImageMapFileTypePopUp", 
													@"normalImageMapFunctionImageWidth", @"normalImageMapFunctionImageHeight",
													@"normalImageMapFunctionEdit", @"normalImageMapPatternNormal",
													@"normalImageMapNormal" ,@"normalImageMapFileName");
			switch( [[dict objectForKey:@"normalImageMapProjectionPopUp"]intValue])
			{
				case cProjectionPlanar:				[ds copyTabAndText:@"map_type 0\t//planar\n"];				break;
				case cProjectionSpherical:			[ds copyTabAndText:@"map_type 1\t//spherical\n"];			break;
				case cProjectionCylindrical:			[ds copyTabAndText:@"map_type 2\t//cylindrical\n"];			break;
				case cProjection3:						break;
				case cProjection4:						break;
				case cProjectionTorus:				[ds copyTabAndText:@"map_type 5\t//torus\n"];					break;
				case cProjectionOmnidirectional:	[ds copyTabAndText:@"map_type 7\t//omnidirectional\n"];	break;
			}
			if ( [[dict objectForKey:@"normalImageMapProjectionOnceOn"]intValue]==NSOnState)
				[ds copyTabAndText:@"once\n"];

			switch( [[dict objectForKey:@"normalImageMapInterpolationPopUp"]intValue])
			{
				case cInterpolationNone:							[ds copyTabAndText:@"interpolate 0\t//none\n"];							break;
				case cInterpolationBilinear:						[ds copyTabAndText:@"interpolate 2\t//bilinear\n"];						break;
				case cInterpolationBicubic:						[ds copyTabAndText:@"interpolate 3\t//bicubic\n"];						break;
				case cInterpolationNormilizedDistance:	[ds copyTabAndText:@"interpolate 4\t//normalized distance\n"];	break;
			}
			switch( [[dict objectForKey:@"normalImageMapGetBumpHeightPopUp"]intValue])
			{
				case cColor:	[ds copyTabAndText:@"use_color\n"];		break;
				case cIndex:	[ds copyTabAndText:@"use_index\n"];		break;
			}
	
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];

			if ( [[dict objectForKey:@"normalAmountOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"%@\t//amount\n",[dict objectForKey:@"normalAmountEdit"]];
			if ( [[dict objectForKey:@"normalBumpSizeOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"bump_size %@\n",[dict objectForKey:@"normalBumpSizeEdit"]];

			break;	
//cNormalFunctionTab**************************************************************************************************cNormalFunctionTab
		case cNormalFunctionTab:
			[ds copyTabAndText:@"function {\n"];
			[ds addTab];
			[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"normalFunctionEdit"]];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];

			kWriteAmount
			kWriteBumpsize
			AddWavesTypeFromPopup(ds, dict, @"normalFunctionWaveTypePopUpButton", @"normalFunctionWaveTypeEdit");
			kWriteSlopemap
			kWriteNormalmap
			break;	
//cNormalPatternTab////////////////////////////////////////////////////////////////////////////////////////////////////cNormalPatternTab
		case cNormalPatternTab:
			switch( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue])
			{
	//cNormalPatternBrick**************************************************************************************************cNormalPatternBrick
				case cNormalPatternBrick:
					if ( [[dict objectForKey:@"normalPatternBrickFullNormalMatrix"] intValue]==cFirstCell)
					{
						if ( [[dict objectForKey:@"normalPatternBrickAmountOn"]intValue]==NSOnState)
							[ds appendTabAndFormat:@"brick %@ //amount\n",[dict objectForKey:@"normalPatternBrickAmountEdit"]];
						else
							[ds copyTabAndText:@"brick \n"];
					}
					else
					{
						[ds copyTabAndText:@"brick \n"];
						WriteFullNormal(ds,dict, 
									@"normalPatternBrickFullNormal1ScalePopUp", @"normalPatternBrickFullNormal1TypePopUp", @"normalPatternBrickFullNormal1ArmsPopUp",
									@"normalPatternBrickFullNormal1AmountOn", @"normalPatternBrickFullNormal1AmountEdit", @"normalPatternBrickFullNormal1ScaleOn",
									@"normalPatternBrickFullNormal1ScaleMatrixX", @"normalPatternBrickFullNormal1ScaleMatrixY", @"normalPatternBrickFullNormal1ScaleMatrixZ");						
						WriteFullNormal(ds,dict, 
									@"normalPatternBrickFullNormal2ScalePopUp", @"normalPatternBrickFullNormal2TypePopUp", @"normalPatternBrickFullNormal2ArmsPopUp",
									@"normalPatternBrickFullNormal2AmountOn", @"normalPatternBrickFullNormal2AmountEdit", @"normalPatternBrickFullNormal2ScaleOn",
									@"normalPatternBrickFullNormal2ScaleMatrixX", @"normalPatternBrickFullNormal2ScaleMatrixY", @"normalPatternBrickFullNormal2ScaleMatrixZ");						
					}

					if ( [[dict objectForKey:@"normalPatternBrickBrickSizeOn"]intValue]==NSOnState)
						[ds appendTabAndFormat:@"brick_size <%@, %@, %@>\n",[dict objectForKey:@"normalPatternBrickBrickSizeMatrixX"],
															[dict objectForKey:@"normalPatternBrickBrickSizeMatrixY"],
															[dict objectForKey:@"normalPatternBrickBrickSizeMatrixZ"]];
					if ( [[dict objectForKey:@"normalPatternBrickMortarOn"]intValue]==NSOnState)
						[ds appendTabAndFormat:@"mortar %@\n",[dict objectForKey:@"normalPatternBrickMortarEdit"]];
					
					break;
	//cNormalPatternChecker**************************************************************************************************cNormalPatternChecker
				case cNormalPatternChecker:
					if ( [[dict objectForKey:@"normalPatternCheckerFullNormalMatrix"] intValue]==cFirstCell)
					{
						if ( [[dict objectForKey:@"normalPatternCheckerAmountOn"]intValue]==NSOnState)
							[ds appendTabAndFormat:@"checker %@ //amount\n",[dict objectForKey:@"normalPatternCheckerAmountEdit"]];
						else
							[ds copyTabAndText:@"checker \n"];
					}
					else
					{
						[ds copyTabAndText:@"checker \n"];
						WriteFullNormal(ds,dict, 
									@"normalPatternCheckerFullNormal1ScalePopUp", @"normalPatternCheckerFullNormal1TypePopUp", @"normalPatternCheckerFullNormal1ArmsPopUp",
									@"normalPatternCheckerFullNormal1AmountOn", @"normalPatternCheckerFullNormal1AmountEdit", @"normalPatternCheckerFullNormal1ScaleOn",
									@"normalPatternCheckerFullNormal1ScaleMatrixX", @"normalPatternCheckerFullNormal1ScaleMatrixY", @"normalPatternCheckerFullNormal1ScaleMatrixZ");						
						WriteFullNormal(ds,dict, 
									@"normalPatternCheckerFullNormal2ScalePopUp", @"normalPatternCheckerFullNormal2TypePopUp", @"normalPatternCheckerFullNormal2ArmsPopUp",
									@"normalPatternCheckerFullNormal2AmountOn", @"normalPatternCheckerFullNormal2AmountEdit", @"normalPatternCheckerFullNormal2ScaleOn",
									@"normalPatternCheckerFullNormal2ScaleMatrixX", @"normalPatternCheckerFullNormal2ScaleMatrixY", @"normalPatternCheckerFullNormal2ScaleMatrixZ");						
					}

					break;
	//cNormalPatternHexagon**************************************************************************************************cNormalPatternHexagon
				case cNormalPatternHexagon:
					if ( [[dict objectForKey:@"normalPatternHexagonFullNormalMatrix"] intValue]==cFirstCell)
					{
						if ( [[dict objectForKey:@"normalPatternHexagonAmountOn"]intValue]==NSOnState)
							[ds appendTabAndFormat:@"hexagon %@ //amount\n",[dict objectForKey:@"normalPatternHexagonAmountEdit"]];
						else
							[ds copyTabAndText:@"hexagon \n"];
					}
					else
					{
						[ds copyTabAndText:@"hexagon \n"];
						WriteFullNormal(ds,dict, 
									@"normalPatternHexagonFullNormal1ScalePopUp", @"normalPatternHexagonFullNormal1TypePopUp", @"normalPatternHexagonFullNormal1ArmsPopUp",
									@"normalPatternHexagonFullNormal1AmountOn", @"normalPatternHexagonFullNormal1AmountEdit", @"normalPatternHexagonFullNormal1ScaleOn",
									@"normalPatternHexagonFullNormal1ScaleMatrixX", @"normalPatternHexagonFullNormal1ScaleMatrixY", @"normalPatternHexagonFullNormal1ScaleMatrixZ");						
						WriteFullNormal(ds,dict, 
									@"normalPatternHexagonFullNormal2ScalePopUp", @"normalPatternHexagonFullNormal2TypePopUp", @"normalPatternHexagonFullNormal2ArmsPopUp",
									@"normalPatternHexagonFullNormal2AmountOn", @"normalPatternHexagonFullNormal2AmountEdit", @"normalPatternHexagonFullNormal2ScaleOn",
									@"normalPatternHexagonFullNormal2ScaleMatrixX", @"normalPatternHexagonFullNormal2ScaleMatrixY", @"normalPatternHexagonFullNormal2ScaleMatrixZ");						
						WriteFullNormal(ds,dict, 
									@"normalPatternHexagonFullNormal3ScalePopUp", @"normalPatternHexagonFullNormal3TypePopUp", @"normalPatternHexagonFullNormal3ArmsPopUp",
									@"normalPatternHexagonFullNormal3AmountOn", @"normalPatternHexagonFullNormal3AmountEdit", @"normalPatternHexagonFullNormal3ScaleOn",
									@"normalPatternHexagonFullNormal3ScaleMatrixX", @"normalPatternHexagonFullNormal3ScaleMatrixY", @"normalPatternHexagonFullNormal3ScaleMatrixZ");						
					}

					break;
	//cNormalPatternObject**************************************************************************************************cNormalPatternObject
				case cNormalPatternObject:
					[ds copyTabAndText:@"object { \n"];
					[ds addTab];
					[ObjectTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalPatternObject"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
/*					[ds removeTab];
					[ds copyTabAndText:@"}\n"];*/
					if (!WritingPattern)
					{
						WriteNormal(cForceWrite, ds, [dict objectForKey:@"normalPatternObjectOutsideNormal"], NO);
						WriteNormal(cForceWrite, ds, [dict objectForKey:@"normalPatternObjectInsideNormal"], NO);
					}
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					break;
	//Standard************************************************************************************************** Standard					
				case cNormalPatternAgate:			WriteStandardNormal(dict, ds, @"agate"); 		goto writeRest;		//std
				case cNormalPatternBozo:			WriteStandardNormal(dict, ds, @"bozo"); 			goto writeRest;		//std
				case cNormalPatternCells:			WriteStandardNormal(dict, ds, @"cells"); 			goto writeRest;		//std
				case cNormalPatternBoxed:			WriteStandardNormal(dict, ds, @"boxed"); 		goto writeRest;		//std
				case cNormalPatternCylindrical:	WriteStandardNormal(dict, ds, @"cylindrical"); 	goto writeRest;		//std
				case cNormalPatternPlanar:			WriteStandardNormal(dict, ds, @"planar"); 		goto writeRest;		//std
				case cNormalPatternSpherical:		WriteStandardNormal(dict, ds, @"spherical"); 	goto writeRest;		//std
				case cNormalPatternGranite:		WriteStandardNormal(dict, ds, @"granite"); 		goto writeRest;		//std
				case cNormalPatternLeopard:		WriteStandardNormal(dict, ds, @"leopard"); 		goto writeRest;		//std
				case cNormalPatternMarble:		WriteStandardNormal(dict, ds, @"marble"); 		goto writeRest;		//std
				case cNormalPatternOnion:			WriteStandardNormal(dict, ds, @"onion"); 			goto writeRest;		//std
				case cNormalPatternRadial:			WriteStandardNormal(dict, ds, @"radial"); 		goto writeRest;		//std
				case cNormalPatternWood:			WriteStandardNormal(dict, ds, @"wood"); 			goto writeRest;		//std
					writeRest:
					kWriteSlopemap
					kWriteNormalmap
					break;
	//Special************************************************************************************************** Special					
						
				case cNormalPatternBumps:	WriteSpecificNormal(dict, ds, @"bumps"); 		break;
				case cNormalPatternDents:		WriteSpecificNormal(dict, ds, @"dents"); 		break;
				case cNormalPatternRipples:	WriteSpecificNormal(dict, ds, @"ripples"); 		break;
				case cNormalPatternWaves:		WriteSpecificNormal(dict, ds, @"waves"); 		break;
				case cNormalPatternWrinkles:	WriteSpecificNormal(dict, ds, @"wrinkles"); 	break;
							
	//cNormalPatternAoi************************************************************************************************** cNormalPatternAoi
				case cNormalPatternAoi:
					[ds copyTabAndText:@"aoi"];

					[ds copyText:@"\n"];

					kWriteAmount
					kWriteBumpsize
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternFacets**************************************************************************************************cNormalPatternFacets
				case cNormalPatternFacets:
					[ds copyTabAndText:@"facets\n"];	
					kWriteAmount
					if ( [[dict objectForKey:@"normalPatternFacetsCoordsOn"]intValue]==NSOnState)
						[ds appendTabAndFormat:@"coords %@\n",[dict objectForKey:@"normalPatternFacetsCoordsEdit"]];
					if ( [[dict objectForKey:@"normalPatternFacetsSizeOn"]intValue]==NSOnState)
						[ds appendTabAndFormat:@"size %@\n",[dict objectForKey:@"normalPatternFacetsSizeEdit"]];
					kWriteBumpsize
					break;				
	//cNormalPatternDensityFilei**************************************************************************************************cNormalPatternDensityFile
				case cNormalPatternDensityFile:
					[ds appendTabAndFormat:@"density_file df3 \"%@\"\n",[dict objectForKey:@"normalPatternDisityFileFileNameEdit"]];
					kWriteBumpsize
					switch( [[dict objectForKey:@"normalPatternDisityFileInterpolationPopUp"]intValue])
					{
//						case 0:	[ds copyTabAndText:@"interpolate 0\t//none\n"];			break;
						case 2:	[ds copyTabAndText:@"interpolate 1\t//tri-linear\n"];	break;
						case 3:	[ds copyTabAndText:@"interpolate 2\t//tri_cubic\n"];	break;
					}
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap

					break;	
	//cNormalPatternFractals**************************************************************************************************cNormalPatternFractals
				case cNormalPatternFractals:
					switch( [[dict objectForKey:@"normalPatternFractalsTypePopUp"]intValue])
					{			
						case cJulia: 					[ds copyTabAndText:@"julia "];						break;
						case cMagnet1Julia: 		[ds copyTabAndText:@"magnet 1 julia "]; 		break;
						case cMagnet2Julia: 		[ds copyTabAndText:@"magnet 2 julia "]; 		break;
						case cMagnet1Mandel:	[ds copyTabAndText:@"magnet 1 mandel "];	break;
						case cMagnet2Mandel:	[ds copyTabAndText:@"magnet 2 mandel "]; 	break;
						case cMandel:				[ds copyTabAndText:@"mandel "]; 					break;
					}
					switch( [[dict objectForKey:@"normalPatternFractalsTypePopUp"]intValue])
					{
						case cJulia: case cMagnet1Julia: case cMagnet2Julia: 
							[ds appendFormat:@"<%@, %@>, %@\n",[dict objectForKey:@"normalPatternFractalsTypeXEdit"],
																							[dict objectForKey:@"normalPatternFractalsTypeYEdit"],
																							[dict objectForKey:@"normalPatternFractalsMaxIterationsEdit"]];
							break;
						case cMagnet1Mandel: 
						case cMandel: 
						case cMagnet2Mandel: 
							[ds appendFormat:@"%@\n",[dict objectForKey:@"normalPatternFractalsMaxIterationsEdit"]];
							break;
					}
					kWriteAmount
					switch( [[dict objectForKey:@"normalPatternFractalsTypePopUp"]intValue])
					{
						case cJulia: 
						case cMandel:
							if ( [[dict objectForKey:@"normalPatternFractalsExponentOn"]intValue]==NSOnState)
							[ds appendTabAndFormat:@"exponent %@\n",[dict objectForKey:@"normalPatternFractalsExponentEdit"]];
							break;
					}

					if ( [[dict objectForKey:@"normalPatternFractalsInteriorTypeOn"]intValue]==NSOnState)
					{
							[ds appendTabAndFormat:@"interior %d %@\n",[[dict objectForKey:@"normalPatternFractalsInteriorTypePopUp"]intValue],
							[dict objectForKey:@"normalPatternFractalsInteriorTypeFactorEdit"]];
					}
					if ( [[dict objectForKey:@"normalPatternFractalsExteriorTypeOn"]intValue]==NSOnState)
					{
							[ds appendTabAndFormat:@"exterior %d %@\n",[[dict objectForKey:@"normalPatternFractalsExteriorTypePopUp"]intValue],
							[dict objectForKey:@"normalPatternFractalsExteriorTypeFactorEdit"]];
					}
					kWriteBumpsize		
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;

	//cNormalPatternCrackle**************************************************************************************************cNormalPatternCrackle
				case cNormalPatternCrackle:
					[ds copyTabAndText:@"crackle\n"];
					kWriteAmount
					for (int x=1; x<=4; x++)
					{
						if ( [[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dOn",x]]intValue]==NSOnState)
						{
							switch( [[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dPopUp",x]]intValue])
							{
								case cForm:		//form
									[ds appendTabAndFormat:@"form <%@, %@, %@>\n",
												[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dMatrixX",x]],
												[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dMatrixY",x]],
												[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dMatrixZ",x]]];
									break;
								case cMetric:	//metric
									[ds appendTabAndFormat:@"metric %@\n",[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dEdit",x]]];
									break;
								case cOffset:	//offset
									[ds appendTabAndFormat:@"offset %@\n",[dict objectForKey:[NSString stringWithFormat:@"normalPatternCrackleType%dEdit",x]]];
									break;
								case cSolid:
									[ds copyTabAndText:@"solid\n"];
									break;
							}
						}
					}		
					kWriteBumpsize		
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternImagePattern**************************************************************************************************cNormalPatternImagePattern
				case cNormalPatternImagePattern:
					[ds copyTabAndText:@"image_pattern {\n"];
					WritePatternPanel(ds, dict, @"normalPatternImagePatternFileTypePopUp", 
													@"normalPatternImagePatternFunctionImageWidth", @"normalPatternImagePatternFunctionImageHeight",
													@"normalPatternImagePatternFunctionFunctionEdit", @"normalImageMapPatternNormal",
													@"normalImageMapNormal" ,@"normalPatternImagePatternFileNameEdit");

					switch( [[dict objectForKey:@"normalPatternImageMapUsePopUp"]intValue])
					{
						case  cUseDefault: 	break;
						case cUseIndex:	[ds copyTabAndText:@"use_index\n"];	break;
						case cUseColor:	[ds copyTabAndText:@"use_color\n"];	break;
						case cUseAlpha:	[ds copyTabAndText:@"use_alpha\n"];	break;
					}
					
					switch( [[dict objectForKey:@"normalPatternImageMapProjectionPopUp"]intValue])
					{
						case cProjectionPlanar:				[ds copyTabAndText:@"map_type 0\t//planar\n"];				break;
						case cProjectionSpherical:			[ds copyTabAndText:@"map_type 1\t//spherical\n"];			break;
						case cProjectionCylindrical:			[ds copyTabAndText:@"map_type 2\t//cylindrical\n"];			break;
						case cProjection3:						break;
						case cProjection4:						break;
						case cProjectionTorus:				[ds copyTabAndText:@"map_type 5\t//torus\n"];					break;
						case cProjectionOmnidirectional:	[ds copyTabAndText:@"map_type 7\t//omnidirectional\n"];	break;
					}
					if ( [[dict objectForKey:@"normalPatternImageMapProjectionOnceOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"once\n"];

					switch( [[dict objectForKey:@"normalPatternImageMapInterpolationPopUp"]intValue])
					{
						case cInterpolationNone:							[ds copyTabAndText:@"interpolate 0\t//none\n"];							break;
						case cInterpolationBilinear:						[ds copyTabAndText:@"interpolate 2\t//bilinear\n"];						break;
						case cInterpolationBicubic:						[ds copyTabAndText:@"interpolate 3\t//bicubic\n"];						break;
						case cInterpolationNormilizedDistance:	[ds copyTabAndText:@"interpolate 4\t//normalized distance\n"];	break;
					}
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					kWriteAmount
					kWriteBumpsize		
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternAverage**************************************************************************************************cNormalPatternAverage
				case cNormalPatternAverage:
					[ds copyTabAndText:@"average\n"];
					[BodymapTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalPatternAverageEditNormal"] 
								andTabs:[ds currentTabs]extraParam:menuTagTemplateNormalmap mutableTabString:ds];
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					break;
	//cNormalPatternPigmentPattern**************************************************************************************************cNormalPatternPigmentPattern
				case cNormalPatternPigmentPattern:
					[ds copyTabAndText:@"pigment_pattern {\n"];
					[ds addTab];
					WritePigment(cForceDontWrite, ds, [dict objectForKey:@"normalPatternPigment"], NO);
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternSlope**************************************************************************************************cNormalPatternSlope
				case cNormalPatternSlope:
					[ds copyTabAndText:@"slope {\n"];
					[ds addTab];
					[ds copyTabText];
					[ds addXYZVector:dict popup:@"normalPatternSlopeDirectionXYZPopUp" xKey:@"normalPatternSlopeDirectionMatrixX" 
												yKey:@"normalPatternSlopeDirectionMatrixY" zKey:@"normalPatternSlopeDirectionMatrixZ"];
					if ( [[dict objectForKey:@"normalPatternSlopeSlopeOn"]intValue]==NSOnState)
					{

						[ds appendTabAndFormat:@", %@, %@\n",[dict objectForKey:@"normalPatternSlopeSlopeLowEdit"],
																					[dict objectForKey:@"normalPatternSlopeSlopeHighEdit"]];
					}
					else
						[ds copyText:@"\n"];
													
					if ( [[dict objectForKey:@"normalPatternSlopeAltitudeOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"altitude "];
						[ds addXYZVector:dict popup:@"normalPatternSlopeAltitudeXYZPopUp" xKey:@"normalPatternSlopeAltitudeMatrixX" 
														yKey:@"normalPatternSlopeAltitudeMatrixY" zKey:@"normalPatternSlopeAltitudeMatrixZ"];
						if ( [[dict objectForKey:@"normalPatternSlopeOffsetOn"]intValue]==NSOnState)
						{
							[ds appendTabAndFormat:@", %@, %@\n",[dict objectForKey:@"normalPatternSlopeOffsetLowEdit"],
																						[dict objectForKey:@"normalPatternSlopeOffsetHighEdit"]];
						}
						else
							[ds copyText:@"\n"];
						
					}
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
								
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;										
	//cNormalPatternProjection**************************************************************************************************cNormalPatternProjection
				case cNormalPatternProjection:
					[ds copyTabAndText:@"projection {\n"];
					[ds addTab];
					[ObjectTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalPatternObject"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
					switch( [[dict objectForKey:@"normalPatternProjectionNormalPopUp"]intValue])
					{
						case cPoint:	
							[ds copyTabAndText:@"point "];
							[ds addXYZVector:dict popup:@"normalPatternProjectionXYZPopUp" xKey:@"normalPatternProjectionXYZMatrixX" 
													yKey:@"normalPatternProjectionXYZMatrixY" zKey:@"normalPatternProjectionXYZMatrixZ"];
							[ds copyText:@"\n"];
							break;
						case cParallel:
							[ds copyTabAndText:@"parallel "];
							[ds addXYZVector:dict popup:@"normalPatternProjectionXYZPopUp" xKey:@"normalPatternProjectionXYZMatrixX" 
													yKey:@"normalPatternProjectionXYZMatrixY" zKey:@"normalPatternProjectionXYZMatrixZ"];
							[ds copyText:@"\n"];
							break;
						case cNormal:
							[ds copyTabAndText:@"normal\n"];
							break;
					}
					if ( [[dict objectForKey:@"normalPatternProjectionBlurOn"]intValue]==NSOnState)
						[ds appendTabAndFormat:@"blur %@, %@\n",[dict objectForKey:@"normalPatternProjectionAmountEdit"],
																						[dict objectForKey:@"normalPatternProjectionSamplesEdit"]];
					
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					kWriteAmount
					kWriteBumpsize
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternGradient**************************************************************************************************cNormalPatternGradient
				case cNormalPatternGradient:
					[ds copyTabAndText:@"gradient "];
					[ds addXYZVector:dict popup:@"normalPatternGradientXYZPopUp" xKey:@"normalPatternGradientMatrixX" 
														yKey:@"normalPatternGradientMatrixY" zKey:@"normalPatternGradientMatrixZ"];
					[ds copyText:@"\n"];
														
					kWriteAmount
					kWriteBumpsize
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
	//cNormalPatternQuilted**************************************************************************************************cNormalPatternQuilted
				case cNormalPatternQuilted:
					[ds copyTabAndText:@"quilted\n"];	
					kWriteAmount
					[ds appendTabAndFormat:@"control0 %@\n",[dict objectForKey:@"normalPatternQuiltedControl0Edit"]];
					[ds appendTabAndFormat:@"control1 %@\n",[dict objectForKey:@"normalPatternQuiltedControl1Edit"]];
					kWriteBumpsize
					break;				
	//cNormalPatternSpiral**************************************************************************************************cNormalPatternSpiral
				case cNormalPatternSpiral:
					switch( [[dict objectForKey:@"normalPatternSpiralTypePopUp"]intValue])
					{
						case 0:
							[ds appendTabAndFormat:@"spiral1 %@\n",[dict objectForKey:@"normalPatternSpiralNrOfArmsEdit"]];
							break;
						case 1:
							[ds appendTabAndFormat:@"spiral2 %@\n",[dict objectForKey:@"normalPatternSpiralNrOfArmsEdit"]];
							break;
					}
					kWriteAmount
					kWriteBumpsize
					AddWavesTypeFromPopup(ds, dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
					kWriteSlopemap
					kWriteNormalmap
					break;
				break;				
			}	//switch pattern panel
			break;// case pattern colorpage 
	}	//switch main panel

	if ( [[dict objectForKey:@"normalNoBumpScaleOn"]intValue]==NSOnState)
		[ds copyTabAndText:@"no_bump_scale\n"];
	if ( [[dict objectForKey:@"normalAccuracyOn"]intValue]==NSOnState)
		[ds appendTabAndFormat:@"accuracy %@\n",[dict objectForKey:@"normalAccuracyEdit"]];

	if ( [[dict objectForKey:@"normalTransformationsOn"]intValue]==NSOnState)
	{
		[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"normalTransformations"]
				andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
	}

	if ( [[dict objectForKey:@"normalDontWrapInNormal"]intValue]==NSOffState)
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
	NSDictionary *initialDefaults=[NormalTemplate createDefaults:menuTagTemplateNormal];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"normalDefaultSettings",
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
		[NSNumber numberWithInt:cNormalPatternTab],			@"normalMainTabView",
		@(NSOffState),						@"normalDontWrapInNormal",
		@(NSOffState),						@"normalTransformationsOn",

		@(NSOffState),						@"normalNoBumpScaleOn",
		@(NSOffState),						@"normalAccuracyOn",
		@"0.01",																	@"normalAccuracyEdit",
		@(NSOffState),						@"normalAmountOn",
		@"0.5",																		@"normalAmountEdit",
		@(NSOffState),						@"normalBumpSizeOn",
		@"0.5",																		@"normalBumpSizeEdit",
		@(NSOffState),						@"normalNormalSlopeMapOn",
		@(NSOffState),						@"normalNormalMapOn",
		[NSNumber numberWithInt:cDefault],							@"normalWaveTypePopUpButton",
		@"0.5",																		@"normalWaveTypeEdit",

		//pattern
		[NSNumber numberWithInt:cNormalPatternBrick],			@"normalPatternSelectPopUpButton",

		 	//brick
			[NSNumber numberWithInt:cFirstCell],			@"normalPatternBrickFullNormalMatrix",
			@(NSOnState),			@"normalPatternBrickAmountOn",
			@"0.5",															@"normalPatternBrickAmountEdit",
			@(NSOffState),			@"normalPatternBrickBrickSizeOn",
		 	@"8",																@"normalPatternBrickBrickSizeMatrixX",
		 	@"3",																@"normalPatternBrickBrickSizeMatrixY",
		 	@"4.5",															@"normalPatternBrickBrickSizeMatrixZ",
			@(NSOffState),			@"normalPatternBrickMortarOn",
		 	@"0.5",															@"normalPatternBrickMortarEdit",
					//brick1	
				[NSNumber numberWithInt:cFullNormalBozo],				@"normalPatternBrickFullNormal1TypePopUp",
				@(NSOnState), 						@"normalPatternBrickFullNormal1AmountOn",
			 	@"0.4",																		@"normalPatternBrickFullNormal1AmountEdit",
			 	@(NSOnState),						@"normalPatternBrickFullNormal1ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternBrickFullNormal1ScalePopUp",
			 	@"0.3",																		@"normalPatternBrickFullNormal1ScaleMatrixX",
			 	@"0.3",																		@"normalPatternBrickFullNormal1ScaleMatrixY",
			 	@"0.3",																		@"normalPatternBrickFullNormal1ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternBrickFullNormal1ArmsPopUp",
					//brick2	
				[NSNumber numberWithInt:cFullNormalCells],				@"normalPatternBrickFullNormal2TypePopUp",
				@(NSOnState), 						@"normalPatternBrickFullNormal2AmountOn",
			 	@"0.9",																		@"normalPatternBrickFullNormal2AmountEdit",
			 	@(NSOnState),						@"normalPatternBrickFullNormal2ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternBrickFullNormal2ScalePopUp",
			 	@"0.2",																		@"normalPatternBrickFullNormal2ScaleMatrixX",
			 	@"0.2",																		@"normalPatternBrickFullNormal2ScaleMatrixY",
			 	@"0.2",																		@"normalPatternBrickFullNormal2ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternBrickFullNormal2ArmsPopUp",

		 	//checker
			[NSNumber numberWithInt:cFirstCell],			@"normalPatternCheckerFullNormalMatrix",
			@(NSOnState),			@"normalPatternCheckerAmountOn",
			@"0.5",															@"normalPatternCheckerAmountEdit",
					//checker1	
				[NSNumber numberWithInt:cFullNormalGradient],			@"normalPatternCheckerFullNormal1TypePopUp",
				@(NSOnState), 						@"normalPatternCheckerFullNormal1AmountOn",
			 	@"0.4",																		@"normalPatternCheckerFullNormal1AmountEdit",
			 	@(NSOnState),						@"normalPatternCheckerFullNormal1ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternCheckerFullNormal1ScalePopUp",
			 	@"0.2",																		@"normalPatternCheckerFullNormal1ScaleMatrixX",
			 	@"0.2",																		@"normalPatternCheckerFullNormal1ScaleMatrixY",
			 	@"0.2",																		@"normalPatternCheckerFullNormal1ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternCheckerFullNormal1ArmsPopUp",
					//checker2	
				[NSNumber numberWithInt:cFullNormalCrackle],			@"normalPatternCheckerFullNormal2TypePopUp",
				@(NSOnState), 						@"normalPatternCheckerFullNormal2AmountOn",
			 	@"0.1",																		@"normalPatternCheckerFullNormal2AmountEdit",
			 	@(NSOnState),						@"normalPatternCheckerFullNormal2ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternCheckerFullNormal2ScalePopUp",
			 	@"0.1",																		@"normalPatternCheckerFullNormal2ScaleMatrixX",
			 	@"0.1",																		@"normalPatternCheckerFullNormal2ScaleMatrixY",
			 	@"0.1",																		@"normalPatternCheckerFullNormal2ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternCheckerFullNormal2ArmsPopUp",

		 	//hexagon
			[NSNumber numberWithInt:cFirstCell],								@"normalPatternHexagonFullNormalMatrix",
			@(NSOnState),							@"normalPatternHexagonAmountOn",
			@"0.5",																			@"normalPatternHexagonAmountEdit",
					//hexagon1	
				[NSNumber numberWithInt:cFullNormalBrick],				@"normalPatternHexagonFullNormal1TypePopUp",
				@(NSOnState), 						@"normalPatternHexagonFullNormal1AmountOn",
			 	@"0.8",																		@"normalPatternHexagonFullNormal1AmountEdit",
			 	@(NSOnState),						@"normalPatternHexagonFullNormal1ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternHexagonFullNormal1ScalePopUp",
			 	@"0.2",																		@"normalPatternHexagonFullNormal1ScaleMatrixX",
			 	@"0.2",																		@"normalPatternHexagonFullNormal1ScaleMatrixY",
			 	@"0.2",																		@"normalPatternHexagonFullNormal1ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternHexagonFullNormal1ArmsPopUp",
					//hexagon2	
				[NSNumber numberWithInt:cFullNormalGranite],			@"normalPatternHexagonFullNormal2TypePopUp",
				@(NSOnState), 						@"normalPatternHexagonFullNormal2AmountOn",
			 	@"0.8",																		@"normalPatternHexagonFullNormal2AmountEdit",
			 	@(NSOnState),						@"normalPatternHexagonFullNormal2ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternHexagonFullNormal2ScalePopUp",
			 	@"0.1",																		@"normalPatternHexagonFullNormal2ScaleMatrixX",
			 	@"0.1",																		@"normalPatternHexagonFullNormal2ScaleMatrixY",
			 	@"0.1",																		@"normalPatternHexagonFullNormal2ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternHexagonFullNormal2ArmsPopUp",
					//hexagon3	
				[NSNumber numberWithInt:cFullNormalGradient],			@"normalPatternHexagonFullNormal3TypePopUp",
				@(NSOnState), 						@"normalPatternHexagonFullNormal3AmountOn",
			 	@"0.6",																		@"normalPatternHexagonFullNormal3AmountEdit",
			 	@(NSOffState),						@"normalPatternHexagonFullNormal3ScaleOn",
			 	[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternHexagonFullNormal3ScalePopUp",
			 	@"1.0",																		@"normalPatternHexagonFullNormal3ScaleMatrixX",
			 	@"1.0",																		@"normalPatternHexagonFullNormal3ScaleMatrixY",
			 	@"1.0",																		@"normalPatternHexagonFullNormal3ScaleMatrixZ",
			 	[NSNumber numberWithInt:0],										@"normalPatternHexagonFullNormal3ArmsPopUp",
		//aoi
	 	//crackle
			@(NSOnState),						@"normalPatternCrackleType1On",
			[NSNumber numberWithInt:cForm],								@"normalPatternCrackleType1PopUp",
			@"-1.0",																	@"normalPatternCrackleType1MatrixX",
			@"1.1",																		@"normalPatternCrackleType1MatrixY",
			@"0",																			@"normalPatternCrackleType1MatrixZ",
			@"2",																			@"normalPatternCrackleType1Edit",
			@(NSOffState),						@"normalPatternCrackleType2On",
			[NSNumber numberWithInt:cMetric],								@"normalPatternCrackleType2PopUp",
			@"-1.0",																	@"normalPatternCrackleType2MatrixX",
			@"1.1",																		@"normalPatternCrackleType2MatrixY",
			@"0",																			@"normalPatternCrackleType2MatrixZ",
			@"2",																			@"normalPatternCrackleType2Edit",
			@(NSOffState),						@"normalPatternCrackleType3On",
			[NSNumber numberWithInt:cOffset],								@"normalPatternCrackleType3PopUp",
			@"-1.0",																	@"normalPatternCrackleType3MatrixX",
			@"1.1",																		@"normalPatternCrackleType3MatrixY",
			@"0",																			@"normalPatternCrackleType3MatrixZ",
			@"2",																			@"normalPatternCrackleType3Edit",
			@(NSOffState),						@"normalPatternCrackleType4On",
			[NSNumber numberWithInt:cSolid],								@"normalPatternCrackleType4PopUp",
			@"-1.0",																	@"normalPatternCrackleType4MatrixX",
			@"1.1",																		@"normalPatternCrackleType4MatrixY",
			@"0",																			@"normalPatternCrackleType4MatrixZ",
			@"2",																			@"normalPatternCrackleType4Edit",

		//density file
			[NSNumber numberWithInt:0],										@"normalPatternDisityFileInterpolationPopUp",
			@"MyFile",																	@"normalPatternDisityFileFileNameEdit",
		//facets
			@"0.1",																		@"normalPatternFacetsCoordsEdit",
			@(NSOffState),						@"normalPatternFacetsCoordsOn",
			@"0.1",																		@"normalPatternFacetsSizeEdit",
			@(NSOffState),						@"normalPatternFacetsSizeOn",
		//fractals
			[NSNumber numberWithInt:cJulia],								@"normalPatternFractalsTypePopUp",
			@"0.35",																	@"normalPatternFractalsTypeXEdit",
			@"0.28",																	@"normalPatternFractalsTypeYEdit",
			@(NSOnState),						@"normalPatternFractalsExponentOn",
			@"2",																			@"normalPatternFractalsExponentEdit",
			@"25",																		@"normalPatternFractalsMaxIterationsEdit",
			@(NSOffState),						@"normalPatternFractalsInteriorTypeOn",
			[NSNumber numberWithInt:cType0],							@"normalPatternFractalsInteriorTypePopUp",
			@"1",																			@"normalPatternFractalsInteriorTypeFactorEdit",
			@(NSOffState),						@"normalPatternFractalsExteriorTypeOn",
			[NSNumber numberWithInt:cType0],							@"normalPatternFractalsExteriorTypePopUp",
			@"1",																			@"normalPatternFractalsExteriorTypeFactorEdit",
		//gradient
			[NSNumber numberWithInt:cXYZVectorPopupY],			@"normalPatternGradientXYZPopUp",
			@"1.0",																		@"normalPatternGradientMatrixX",
			@"1.0",																		@"normalPatternGradientMatrixY",
			@"1.0",																		@"normalPatternGradientMatrixZ",

			//image pattern*************************************************************************************************
			[NSNumber numberWithInt:cGif],									@"normalPatternImagePatternFileTypePopUp",
			@"MyFile",																	@"normalPatternImagePatternFileNameEdit",
			@"x+y+z",																	@"normalPatternImagePatternFunctionFunctionEdit",
			@"300",																		@"normalPatternImagePatternFunctionImageWidth",
			@"300",																		@"normalPatternImagePatternFunctionImageHeight",
			@(NSOffState),						@"normalPatternImageMapProjectionOnceOn",
			[NSNumber numberWithInt:cProjectionPlanar],				@"normalPatternImageMapProjectionPopUp",
			[NSNumber numberWithInt:cInterpolationNone],			@"normalPatternImageMapInterpolationPopUp",

			[NSNumber numberWithInt:cUseDefault],						@"normalPatternImageMapUsePopUp",
			//projection****************************************************************************************************
			[NSNumber numberWithInt:cPoint],								@"normalPatternProjectionNormalPopUp",
			[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"normalPatternProjectionXYZPopUp",
			@"1.0",																		@"normalPatternProjectionXYZMatrixX",	
			@"1.0",																		@"normalPatternProjectionXYZMatrixY",	
			@"1.0",																		@"normalPatternProjectionXYZMatrixZ",	
			@(NSOffState),						@"normalPatternProjectionBlurOn",
			@"0.0",																		@"normalPatternProjectionAmountEdit",
			@"1.0",																		@"normalPatternProjectionSamplesEdit",

			//quilted*******************************************************************************************************
			@"0.33",																	@"normalPatternQuiltedControl0Edit",
			@"1.33",																	@"normalPatternQuiltedControl1Edit",
			//slope*******************************************************************************************************
			[NSNumber numberWithInt:cXYZVectorPopupY],			@"normalPatternSlopeDirectionXYZPopUp",
			@"1.0",																		@"normalPatternSlopeDirectionMatrixX",
			@"1.0",																		@"normalPatternSlopeDirectionMatrixY",
			@"1.0",																		@"normalPatternSlopeDirectionMatrixZ",
			@(NSOffState),						@"normalPatternSlopeSlopeOn",
			@"0.0",																		@"normalPatternSlopeSlopeLowEdit",	
			@"1.0",																		@"normalPatternSlopeSlopeHighEdit",	
			@(NSOffState),						@"normalPatternSlopeAltitudeOn",
			[NSNumber numberWithInt:cXYZVectorPopupY],			@"normalPatternSlopeAltitudeXYZPopUp",
			@"1.0",																		@"normalPatternSlopeAltitudeMatrixX",
			@"1.0",																		@"normalPatternSlopeAltitudeMatrixY",
			@"1.0",																		@"normalPatternSlopeAltitudeMatrixZ",
			@(NSOffState),						@"normalPatternSlopeOffsetOn",
			@"0.0",																		@"normalPatternSlopeOffsetLowEdit",	
			@"1.0",																		@"normalPatternSlopeOffsetHighEdit",	
			//spiral*******************************************************************************************************
			[NSNumber numberWithInt:0],													@"normalPatternSpiralTypePopUp",
			@"2",																						@"normalPatternSpiralNrOfArmsEdit",

	  	//normal image_map
		[NSNumber numberWithInt:cGif],												@"normalImageMapFileTypePopUp",
		@"MyFile",																				@"normalImageMapFileName",
		@"x+y+z",																				@"normalImageMapFunctionEdit",
		@"300",																					@"normalImageMapFunctionImageWidth",
		@"300",																					@"normalImageMapFunctionImageHeight",
		@(NSOffState),									@"normalImageMapProjectionOnceOn",
		[NSNumber numberWithInt:cProjectionPlanar],							@"normalImageMapProjectionPopUp",
		[NSNumber numberWithInt:cInterpolationNone],						@"normalImageMapInterpolationPopUp",
		[NSNumber numberWithInt:cColor],								@"normalImageMapGetBumpHeightPopUp",
	//normal function
		@"x+y+z",																				@"normalFunctionEdit",
	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	[normalImageMapProjectionPopUp setAutoenablesItems:NO];
	[normalPatternImageMapProjectionPopUp setAutoenablesItems:NO];
	// disable some items from the projection popup in image map
	[[normalImageMapProjectionPopUp itemAtIndex:cProjection3]setEnabled:NO];
	[[normalImageMapProjectionPopUp itemAtIndex:cProjection4]setEnabled:NO];
	[[normalImageMapProjectionPopUp itemAtIndex:cProjection6]setEnabled:NO];
	[[normalPatternImageMapProjectionPopUp itemAtIndex:cProjection3]setEnabled:NO];
	[[normalPatternImageMapProjectionPopUp itemAtIndex:cProjection4]setEnabled:NO];
	[[normalPatternImageMapProjectionPopUp itemAtIndex:cProjection6]setEnabled:NO];


	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
	normalMainTabView,															@"normalMainTabView",
	normalDontWrapInNormal,													@"normalDontWrapInNormal",
	normalTransformationsOn,													@"normalTransformationsOn",
	normalNoBumpScaleOn,														@"normalNoBumpScaleOn",
	normalAccuracyOn,																@"normalAccuracyOn",
	normalAccuracyEdit,															@"normalAccuracyEdit",
	normalAmountOn,																@"normalAmountOn",
	normalAmountEdit,																@"normalAmountEdit",
	normalBumpSizeOn,															@"normalBumpSizeOn",
	normalBumpSizeEdit,															@"normalBumpSizeEdit",
	normalNormalSlopeMapOn,													@"normalNormalSlopeMapOn",
	normalNormalMapOn,															@"normalNormalMapOn",
	normalWaveTypePopUpButton,											@"normalWaveTypePopUpButton",
	normalWaveTypeEdit,															@"normalWaveTypeEdit",
	
	//pattern
	normalPatternSelectPopUpButton,										@"normalPatternSelectPopUpButton",

	 	//brick
	normalPatternBrickFullNormalMatrix,									@"normalPatternBrickFullNormalMatrix",
	normalPatternBrickAmountOn,												@"normalPatternBrickAmountOn",
	normalPatternBrickAmountEdit,											@"normalPatternBrickAmountEdit",
	normalPatternBrickBrickSizeOn,											@"normalPatternBrickBrickSizeOn",
 	[normalPatternBrickBrickSizeMatrix cellWithTag:0],				@"normalPatternBrickBrickSizeMatrixX",
 	[normalPatternBrickBrickSizeMatrix cellWithTag:1],				@"normalPatternBrickBrickSizeMatrixY",
 	[normalPatternBrickBrickSizeMatrix cellWithTag:2],				@"normalPatternBrickBrickSizeMatrixZ",
	normalPatternBrickMortarOn,												@"normalPatternBrickMortarOn",
 	normalPatternBrickMortarEdit,												@"normalPatternBrickMortarEdit",
		//brick1	
	normalPatternBrickFullNormal1TypePopUp,							@"normalPatternBrickFullNormal1TypePopUp",
	normalPatternBrickFullNormal1AmountOn,							@"normalPatternBrickFullNormal1AmountOn",
 	normalPatternBrickFullNormal1AmountEdit,							@"normalPatternBrickFullNormal1AmountEdit",
 	normalPatternBrickFullNormal1ScaleOn,								@"normalPatternBrickFullNormal1ScaleOn",
 	normalPatternBrickFullNormal1ScalePopUp,							@"normalPatternBrickFullNormal1ScalePopUp",
 	[normalPatternBrickFullNormal1ScaleMatrix cellWithTag:0],	@"normalPatternBrickFullNormal1ScaleMatrixX",
 	[normalPatternBrickFullNormal1ScaleMatrix cellWithTag:1],	@"normalPatternBrickFullNormal1ScaleMatrixY",
 	[normalPatternBrickFullNormal1ScaleMatrix cellWithTag:2],	@"normalPatternBrickFullNormal1ScaleMatrixZ",
	normalPatternBrickFullNormal1ArmsPopUp,							@"normalPatternBrickFullNormal1ArmsPopUp",
				//brick2	
	normalPatternBrickFullNormal2TypePopUp,							@"normalPatternBrickFullNormal2TypePopUp",
	normalPatternBrickFullNormal2AmountOn,							@"normalPatternBrickFullNormal2AmountOn",
 	normalPatternBrickFullNormal2AmountEdit,							@"normalPatternBrickFullNormal2AmountEdit",
 	normalPatternBrickFullNormal2ScaleOn,								@"normalPatternBrickFullNormal2ScaleOn",
 	normalPatternBrickFullNormal2ScalePopUp,							@"normalPatternBrickFullNormal2ScalePopUp",
 	[normalPatternBrickFullNormal2ScaleMatrix cellWithTag:0],	@"normalPatternBrickFullNormal2ScaleMatrixX",
 	[normalPatternBrickFullNormal2ScaleMatrix cellWithTag:1],	@"normalPatternBrickFullNormal2ScaleMatrixY",
 	[normalPatternBrickFullNormal2ScaleMatrix cellWithTag:2],	@"normalPatternBrickFullNormal2ScaleMatrixZ",
	normalPatternBrickFullNormal2ArmsPopUp,							@"normalPatternBrickFullNormal2ArmsPopUp",

	 	//checker
	normalPatternCheckerFullNormalMatrix,									@"normalPatternCheckerFullNormalMatrix",
	normalPatternCheckerAmountOn,											@"normalPatternCheckerAmountOn",
	normalPatternCheckerAmountEdit,											@"normalPatternCheckerAmountEdit",
		//checker1	
	normalPatternCheckerFullNormal1TypePopUp,							@"normalPatternCheckerFullNormal1TypePopUp",
	normalPatternCheckerFullNormal1AmountOn,							@"normalPatternCheckerFullNormal1AmountOn",
 	normalPatternCheckerFullNormal1AmountEdit,							@"normalPatternCheckerFullNormal1AmountEdit",
 	normalPatternCheckerFullNormal1ScaleOn,								@"normalPatternCheckerFullNormal1ScaleOn",
 	normalPatternCheckerFullNormal1ScalePopUp,							@"normalPatternCheckerFullNormal1ScalePopUp",
 	[normalPatternCheckerFullNormal1ScaleMatrix cellWithTag:0],	@"normalPatternCheckerFullNormal1ScaleMatrixX",
 	[normalPatternCheckerFullNormal1ScaleMatrix cellWithTag:1],	@"normalPatternCheckerFullNormal1ScaleMatrixY",
 	[normalPatternCheckerFullNormal1ScaleMatrix cellWithTag:2],	@"normalPatternCheckerFullNormal1ScaleMatrixZ",
	normalPatternCheckerFullNormal1ArmsPopUp,							@"normalPatternCheckerFullNormal1ArmsPopUp",
				//checker2	
	normalPatternCheckerFullNormal2TypePopUp,							@"normalPatternCheckerFullNormal2TypePopUp",
	normalPatternCheckerFullNormal2AmountOn,							@"normalPatternCheckerFullNormal2AmountOn",
 	normalPatternCheckerFullNormal2AmountEdit,							@"normalPatternCheckerFullNormal2AmountEdit",
 	normalPatternCheckerFullNormal2ScaleOn,								@"normalPatternCheckerFullNormal2ScaleOn",
 	normalPatternCheckerFullNormal2ScalePopUp,							@"normalPatternCheckerFullNormal2ScalePopUp",
 	[normalPatternCheckerFullNormal2ScaleMatrix cellWithTag:0],	@"normalPatternCheckerFullNormal2ScaleMatrixX",
 	[normalPatternCheckerFullNormal2ScaleMatrix cellWithTag:1],	@"normalPatternCheckerFullNormal2ScaleMatrixY",
 	[normalPatternCheckerFullNormal2ScaleMatrix cellWithTag:2],	@"normalPatternCheckerFullNormal2ScaleMatrixZ",
	normalPatternCheckerFullNormal2ArmsPopUp,							@"normalPatternCheckerFullNormal2ArmsPopUp",

	 	//hexagon
	normalPatternHexagonFullNormalMatrix,									@"normalPatternHexagonFullNormalMatrix",
	normalPatternHexagonAmountOn,											@"normalPatternHexagonAmountOn",
	normalPatternHexagonAmountEdit,											@"normalPatternHexagonAmountEdit",
		//hexagon1	
	normalPatternHexagonFullNormal1TypePopUp,						@"normalPatternHexagonFullNormal1TypePopUp",
	normalPatternHexagonFullNormal1AmountOn,							@"normalPatternHexagonFullNormal1AmountOn",
 	normalPatternHexagonFullNormal1AmountEdit,							@"normalPatternHexagonFullNormal1AmountEdit",
 	normalPatternHexagonFullNormal1ScaleOn,								@"normalPatternHexagonFullNormal1ScaleOn",
 	normalPatternHexagonFullNormal1ScalePopUp,						@"normalPatternHexagonFullNormal1ScalePopUp",
 	[normalPatternHexagonFullNormal1ScaleMatrix cellWithTag:0],	@"normalPatternHexagonFullNormal1ScaleMatrixX",
 	[normalPatternHexagonFullNormal1ScaleMatrix cellWithTag:1],	@"normalPatternHexagonFullNormal1ScaleMatrixY",
 	[normalPatternHexagonFullNormal1ScaleMatrix cellWithTag:2],	@"normalPatternHexagonFullNormal1ScaleMatrixZ",
	normalPatternHexagonFullNormal1ArmsPopUp,						@"normalPatternHexagonFullNormal1ArmsPopUp",
				//hexagon2	
	normalPatternHexagonFullNormal2TypePopUp,						@"normalPatternHexagonFullNormal2TypePopUp",
	normalPatternHexagonFullNormal2AmountOn,							@"normalPatternHexagonFullNormal2AmountOn",
 	normalPatternHexagonFullNormal2AmountEdit,							@"normalPatternHexagonFullNormal2AmountEdit",
 	normalPatternHexagonFullNormal2ScaleOn,								@"normalPatternHexagonFullNormal2ScaleOn",
 	normalPatternHexagonFullNormal2ScalePopUp,						@"normalPatternHexagonFullNormal2ScalePopUp",
 	[normalPatternHexagonFullNormal2ScaleMatrix cellWithTag:0],	@"normalPatternHexagonFullNormal2ScaleMatrixX",
 	[normalPatternHexagonFullNormal2ScaleMatrix cellWithTag:1],	@"normalPatternHexagonFullNormal2ScaleMatrixY",
 	[normalPatternHexagonFullNormal2ScaleMatrix cellWithTag:2],	@"normalPatternHexagonFullNormal2ScaleMatrixZ",
	normalPatternHexagonFullNormal2ArmsPopUp,						@"normalPatternHexagonFullNormal2ArmsPopUp",
				//hexagon32	
	normalPatternHexagonFullNormal3TypePopUp,						@"normalPatternHexagonFullNormal3TypePopUp",
	normalPatternHexagonFullNormal3AmountOn,							@"normalPatternHexagonFullNormal3AmountOn",
 	normalPatternHexagonFullNormal3AmountEdit,							@"normalPatternHexagonFullNormal3AmountEdit",
 	normalPatternHexagonFullNormal3ScaleOn,								@"normalPatternHexagonFullNormal3ScaleOn",
 	normalPatternHexagonFullNormal3ScalePopUp,						@"normalPatternHexagonFullNormal3ScalePopUp",
 	[normalPatternHexagonFullNormal3ScaleMatrix cellWithTag:0],	@"normalPatternHexagonFullNormal3ScaleMatrixX",
 	[normalPatternHexagonFullNormal3ScaleMatrix cellWithTag:1],	@"normalPatternHexagonFullNormal3ScaleMatrixY",
 	[normalPatternHexagonFullNormal3ScaleMatrix cellWithTag:2],	@"normalPatternHexagonFullNormal3ScaleMatrixZ",
	normalPatternHexagonFullNormal3ArmsPopUp,						@"normalPatternHexagonFullNormal3ArmsPopUp",
	//aoi
 	//crackle
	normalPatternCrackleType1On,												@"normalPatternCrackleType1On",
	normalPatternCrackleType1PopUp,											@"normalPatternCrackleType1PopUp",
	[normalPatternCrackleType1Matrix cellWithTag:0],					@"normalPatternCrackleType1MatrixX",
	[normalPatternCrackleType1Matrix cellWithTag:1],					@"normalPatternCrackleType1MatrixY",
	[normalPatternCrackleType1Matrix cellWithTag:2],					@"normalPatternCrackleType1MatrixZ",
	normalPatternCrackleType1Edit,												@"normalPatternCrackleType1Edit",
	normalPatternCrackleType2On,												@"normalPatternCrackleType2On",
	normalPatternCrackleType2PopUp,											@"normalPatternCrackleType2PopUp",
	[normalPatternCrackleType2Matrix cellWithTag:0],					@"normalPatternCrackleType2MatrixX",
	[normalPatternCrackleType2Matrix cellWithTag:1],					@"normalPatternCrackleType2MatrixY",
	[normalPatternCrackleType2Matrix cellWithTag:2],					@"normalPatternCrackleType2MatrixZ",
	normalPatternCrackleType2Edit,												@"normalPatternCrackleType2Edit",
	normalPatternCrackleType3On,												@"normalPatternCrackleType3On",
	normalPatternCrackleType3PopUp,											@"normalPatternCrackleType3PopUp",
	[normalPatternCrackleType3Matrix cellWithTag:0],					@"normalPatternCrackleType3MatrixX",
	[normalPatternCrackleType3Matrix cellWithTag:1],					@"normalPatternCrackleType3MatrixY",
	[normalPatternCrackleType3Matrix cellWithTag:2],					@"normalPatternCrackleType3MatrixZ",
	normalPatternCrackleType3Edit,												@"normalPatternCrackleType3Edit",
	normalPatternCrackleType4On,												@"normalPatternCrackleType4On",
	normalPatternCrackleType4PopUp,											@"normalPatternCrackleType4PopUp",
	[normalPatternCrackleType4Matrix cellWithTag:0],					@"normalPatternCrackleType4MatrixX",
	[normalPatternCrackleType4Matrix cellWithTag:1],					@"normalPatternCrackleType4MatrixY",
	[normalPatternCrackleType4Matrix cellWithTag:2],					@"normalPatternCrackleType4MatrixZ",
	normalPatternCrackleType4Edit,												@"normalPatternCrackleType4Edit",

	//facets
 	normalPatternFacetsCoordsEdit,												@"normalPatternFacetsCoordsEdit",
	normalPatternFacetsCoordsOn,												@"normalPatternFacetsCoordsOn",
	normalPatternFacetsSizeEdit,													@"normalPatternFacetsSizeEdit",
	normalPatternFacetsSizeOn,													@"normalPatternFacetsSizeOn",
	//fractals
	normalPatternFractalsTypePopUp,											@"normalPatternFractalsTypePopUp",
	normalPatternFractalsTypeXEdit,												@"normalPatternFractalsTypeXEdit",
	normalPatternFractalsTypeYEdit,												@"normalPatternFractalsTypeYEdit",
	normalPatternFractalsExponentOn,											@"normalPatternFractalsExponentOn",
	normalPatternFractalsExponentEdit,											@"normalPatternFractalsExponentEdit",
	normalPatternFractalsMaxIterationsEdit,									@"normalPatternFractalsMaxIterationsEdit",
	normalPatternFractalsInteriorTypeOn,										@"normalPatternFractalsInteriorTypeOn",
	normalPatternFractalsInteriorTypePopUp,									@"normalPatternFractalsInteriorTypePopUp",
	normalPatternFractalsInteriorTypeFactorEdit,							@"normalPatternFractalsInteriorTypeFactorEdit",
	normalPatternFractalsExteriorTypeOn,										@"normalPatternFractalsExteriorTypeOn",
	normalPatternFractalsExteriorTypePopUp,								@"normalPatternFractalsExteriorTypePopUp",
	normalPatternFractalsExteriorTypeFactorEdit,							@"normalPatternFractalsExteriorTypeFactorEdit",
	//density file
	normalPatternDisityFileInterpolationPopUp,								@"normalPatternDisityFileInterpolationPopUp",
	normalPatternDisityFileFileNameEdit,										@"normalPatternDisityFileFileNameEdit",
	//gradient
	normalPatternGradientXYZPopUp,											@"normalPatternGradientXYZPopUp",
	[normalPatternGradientMatrix cellWithTag:0],							@"normalPatternGradientMatrixX",
	[normalPatternGradientMatrix cellWithTag:1],							@"normalPatternGradientMatrixY",
	[normalPatternGradientMatrix cellWithTag:2],							@"normalPatternGradientMatrixZ",
	//image pattern
	normalPatternImagePatternFileTypePopUp,								@"normalPatternImagePatternFileTypePopUp",
	normalPatternImagePatternFileNameEdit,									@"normalPatternImagePatternFileNameEdit",
	normalPatternImagePatternFunctionFunctionEdit,						@"normalPatternImagePatternFunctionFunctionEdit",
	normalPatternImagePatternFunctionImageWidth,						@"normalPatternImagePatternFunctionImageWidth",
	normalPatternImagePatternFunctionImageHeight,						@"normalPatternImagePatternFunctionImageHeight",
	normalPatternImageMapProjectionOnceOn,								@"normalPatternImageMapProjectionOnceOn",
	normalPatternImageMapProjectionPopUp,								@"normalPatternImageMapProjectionPopUp",
	normalPatternImageMapInterpolationPopUp,								@"normalPatternImageMapInterpolationPopUp",
	
	normalPatternImageMapUsePopUp,											@"normalPatternImageMapUsePopUp",
	//projection
	normalPatternProjectionNormalPopUp,										@"normalPatternProjectionNormalPopUp",
	normalPatternProjectionXYZPopUp,											@"normalPatternProjectionXYZPopUp",
	[normalPatternProjectionXYZMatrix cellWithTag:0],					@"normalPatternProjectionXYZMatrixX",	
	[normalPatternProjectionXYZMatrix cellWithTag:1],					@"normalPatternProjectionXYZMatrixY",	
	[normalPatternProjectionXYZMatrix cellWithTag:2],					@"normalPatternProjectionXYZMatrixZ",	
	normalPatternProjectionBlurOn,												@"normalPatternProjectionBlurOn",
	normalPatternProjectionAmountEdit,										@"normalPatternProjectionAmountEdit",
	normalPatternProjectionSamplesEdit,										@"normalPatternProjectionSamplesEdit",
	//quilted
	normalPatternQuiltedControl0Edit,											@"normalPatternQuiltedControl0Edit",
	normalPatternQuiltedControl1Edit,											@"normalPatternQuiltedControl1Edit",
	//slope
	normalPatternSlopeDirectionXYZPopUp,									@"normalPatternSlopeDirectionXYZPopUp",
	[normalPatternSlopeDirectionMatrix cellWithTag:0],					@"normalPatternSlopeDirectionMatrixX",
	[normalPatternSlopeDirectionMatrix cellWithTag:1],					@"normalPatternSlopeDirectionMatrixY",
	[normalPatternSlopeDirectionMatrix cellWithTag:2],					@"normalPatternSlopeDirectionMatrixZ",
	normalPatternSlopeSlopeOn,													@"normalPatternSlopeSlopeOn",
	normalPatternSlopeSlopeLowEdit,												@"normalPatternSlopeSlopeLowEdit",	
	normalPatternSlopeSlopeHighEdit,											@"normalPatternSlopeSlopeHighEdit",	
	normalPatternSlopeAltitudeOn,												@"normalPatternSlopeAltitudeOn",
	normalPatternSlopeAltitudeXYZPopUp,										@"normalPatternSlopeAltitudeXYZPopUp",
	[normalPatternSlopeAltitudeMatrix cellWithTag:0],						@"normalPatternSlopeAltitudeMatrixX",
	[normalPatternSlopeAltitudeMatrix cellWithTag:1],						@"normalPatternSlopeAltitudeMatrixY",
	[normalPatternSlopeAltitudeMatrix cellWithTag:2],						@"normalPatternSlopeAltitudeMatrixZ",
	normalPatternSlopeOffsetOn,													@"normalPatternSlopeOffsetOn",
	normalPatternSlopeOffsetLowEdit,											@"normalPatternSlopeOffsetLowEdit",	
	normalPatternSlopeOffsetHighEdit,											@"normalPatternSlopeOffsetHighEdit",	
	//spiral	
	normalPatternSpiralTypePopUp,												@"normalPatternSpiralTypePopUp",
	normalPatternSpiralNrOfArmsEdit,											@"normalPatternSpiralNrOfArmsEdit",
	//bump map
  	normalImageMapFileTypePopUp,												@"normalImageMapFileTypePopUp",
	normalImageMapFileName,														@"normalImageMapFileName",
	normalImageMapFunctionEdit,													@"normalImageMapFunctionEdit",
	normalImageMapFunctionImageWidth,										@"normalImageMapFunctionImageWidth",
	normalImageMapFunctionImageHeight,										@"normalImageMapFunctionImageHeight",
	normalImageMapProjectionPopUp,											@"normalImageMapProjectionPopUp",
	normalImageMapInterpolationPopUp,										@"normalImageMapInterpolationPopUp",
	normalImageMapProjectionOnceOn,											@"normalImageMapProjectionOnceOn",
	normalImageMapGetBumpHeightPopUp,									@"normalImageMapGetBumpHeightPopUp",
	//function
	normalFunctionEdit,																@"normalFunctionEdit",
	nil] ;
	
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"normalLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"normalLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			normalNormalSlopeMapEditButton,					@"normalNormalSlopeMapEditButton",
			normalNormalMapEditButton,							@"normalNormalMapEditButton",
			normalTransformationsEditButton,					@"normalTransformationsEditButton",
			//brick
			normalPatternBrickFullNormal,							@"normalPatternBrickFullNormal",
			normalPatternBrickBrickSizeMatrix,					@"normalPatternBrickBrickSizeMatrix",
			normalPatternBrickFullNormal1ScaleMatrix,		@"normalPatternBrickFullNormal1ScaleMatrix",
			normalPatternBrickFullNormal2ScaleMatrix,		@"normalPatternBrickFullNormal2ScaleMatrix",
			//checker
			normalPatternCheckerFullNormal,					@"normalPatternCheckerFullNormal",
			normalPatternCheckerFullNormal1ScaleMatrix,	@"normalPatternCheckerFullNormal1ScaleMatrix",
			normalPatternCheckerFullNormal2ScaleMatrix,	@"normalPatternCheckerFullNormal2ScaleMatrix",
			//hexagon
			normalPatternHexagonFullNormal,						@"normalPatternHexagonFullNormal",
			normalPatternHexagonFullNormal1ScaleMatrix,		@"normalPatternHexagonFullNormal1ScaleMatrix",
			normalPatternHexagonFullNormal2ScaleMatrix,		@"normalPatternHexagonFullNormal2ScaleMatrix",
			normalPatternHexagonFullNormal3ScaleMatrix,		@"normalPatternHexagonFullNormal3ScaleMatrix",
	 	//object
			normalPatternObjectEditObjectButton,						@"normalPatternObjectEditObjectButton",
			normalPatternObjectEditOutsideObjectButton,			@"normalPatternObjectEditOutsideObjectButton",
			normalPatternObjectEditInsideObjectButton,				@"normalPatternObjectEditInsideObjectButton",


			//crackle
			normalPatternCrackleType1Matrix,		@"normalPatternCrackleType1Matrix",
			normalPatternCrackleType2Matrix,		@"normalPatternCrackleType2Matrix",
			normalPatternCrackleType3Matrix,		@"normalPatternCrackleType3Matrix",
			normalPatternCrackleType4Matrix,		@"normalPatternCrackleType4Matrix",
			//Density file
			normalPatternDisityFileFileEditButton,				@"normalPatternDisityFileFileEditButton",
			//gradient
			normalPatternGradientMatrix,							@"normalPatternGradientMatrix",
			//projection
			normalPatternProjectionXYZMatrix,					@"normalPatternProjectionXYZMatrix",
			normalPatternProjectionObjectButton,				@"normalPatternProjectionObjectButton",
			//slope
			normalPatternSlopeDirectionMatrix,					@"normalPatternSlopeDirectionMatrix",
			normalPatternSlopeAltitudeMatrix,					@"normalPatternSlopeAltitudeMatrix",
			//Pattern ImagePatern
			normalPatternImagePatternFileNameButton,				@"normalPatternImagePatternFileNameButton",
			normalPatternImagePatternPatternButton,					@"normalPatternImagePatternPatternButton",
			normalPatternImagePatternPigmentButton,				@"normalPatternImagePatternPigmentButton",
			normalPatternImagePatternFunctionFunctionButton,	@"normalPatternImagePatternFunctionFunctionButton",
			// normalImageMap
			normalImageMapFileButton,						@"normalImageMapFileButton",
			normalImageMapPatternButton,				@"normalImageMapPatternButton",
			normalImageMapPigmentButton,				@"normalImageMapPigmentButton",
			normalImageMapFunctionButton,				@"normalImageMapFunctionButton",
			//function
			normalFunctionEditButton,						@"normalFunctionEditButton",
		nil]
		];
	[normalMainViewHolderView  addSubview:normalMainViewNIBView];

	// this is a little hack to make the tabview the right size
	// it doesn't work in IB, it is always oversized. could be because
	// the large number of tabs
	NSSize nw;
	nw.width=473;
	nw.height=240;
	[normalPatternTabView setFrameSize:nw];
	// end of fix
	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"normalMainTabView",
		@"normalPatternSelectPopUpButton",
		nil];
	[mExcludedObjectsForReset retain];
	
	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{

	[self setNormalTransformations:[preferences objectForKey:@"normalTransformations"]];
	[self setNormalFunctionFunction:[preferences objectForKey:@"normalFunctionFunction"]];
	[self setNormalImageMapFunction:[preferences objectForKey:@"normalImageMapFunction"]];
	[self setNormalImageMapPatternNormal:[preferences objectForKey:@"normalImageMapPatternNormal"]];
	[self setNormalImageMapNormal:[preferences objectForKey:@"normalImageMapNormal"]];

	[self setNormalPatternPigment:[preferences objectForKey:@"normalPatternPigment"]];
	[self setNormalPatternObjectOutsideNormal:[preferences objectForKey:@"normalPatternObjectOutsideNormal"]];
	[self setNormalPatternObjectInsideNormal:[preferences objectForKey:@"normalPatternObjectInsideNormal"]];
	[self setNormalPatternObject:[preferences objectForKey:@"normalPatternObject"]];
	[self setNormalPatternAverageEditNormal:[preferences objectForKey:@"normalPatternAverageEditNormal"]];
	[self setNormalSlopemap:[preferences objectForKey:@"normalSlopemap"]];
	[self setNormalNormalmap:[preferences objectForKey:@"normalNormalmap"]];
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
								
//store transformations if selected
	if ( normalTransformations != nil )
		if ( [[dict objectForKey:@"normalTransformationsOn"]intValue]==NSOnState)
			[dict setObject:normalTransformations forKey:@"normalTransformations"];

//store slopemap if selected
	if ( normalSlopemap != nil )
		if ( [[dict objectForKey:@"normalNormalSlopeMapOn"]intValue]==NSOnState)
			[dict setObject:normalSlopemap forKey:@"normalSlopemap"];

//store normal if selected
	if ( normalNormalmap != nil )
		if ( [[dict objectForKey:@"normalNormalMapOn"]intValue]==NSOnState)
			[dict setObject:normalNormalmap forKey:@"normalNormalmap"];

//store function, normal or pattern if selected
//in either colorPatternImageMap or image map
	if ( [[dict objectForKey:@"normalMainTabView"]intValue]==cNormalImageMapTab)
	{
		if ( [[dict objectForKey:@"normalImageMapFileTypePopUp"]intValue]==cFunctionImage && normalImageMapFunction != nil)
			[dict setObject:normalImageMapFunction forKey:@"normalImageMapFunction"];
		else if ( [[dict objectForKey:@"normalImageMapFileTypePopUp"]intValue]==cPatternImage && normalImageMapPatternNormal != nil)
			[dict setObject:normalImageMapPatternNormal forKey:@"normalImageMapPatternNormal"];
		else if ( [[dict objectForKey:@"normalImageMapFileTypePopUp"]intValue]==cPigmentImage && normalImageMapNormal != nil)
			[dict setObject:normalImageMapNormal forKey:@"normalImageMapNormal"];
	}
	else if ( [[dict objectForKey:@"normalMainTabView"]intValue]==cNormalPatternTab)
	{
		//color pattern image map
		if ( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue]==cNormalPatternImagePattern)
		{
			if ( [[dict objectForKey:@"normalPatternImagePatternFileTypePopUp"]intValue]==cFunctionImage && normalImageMapFunction != nil)
				[dict setObject:normalImageMapFunction forKey:@"normalImageMapFunction"];
			else if ( [[dict objectForKey:@"normalPatternImagePatternFileTypePopUp"]intValue]==cPatternImage && normalImageMapPatternNormal != nil)
				[dict setObject:normalImageMapPatternNormal forKey:@"normalImageMapPatternNormal"];
			else if ( [[dict objectForKey:@"normalPatternImagePatternFileTypePopUp"]intValue]==cPigmentImage && normalImageMapNormal != nil)
				[dict setObject:normalImageMapNormal forKey:@"normalImageMapNormal"];
		}
		//pattern object
		else if ( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue]==cNormalPatternObject)
		{
			if (  normalPatternObjectOutsideNormal != nil)
				[dict setObject:normalPatternObjectOutsideNormal forKey:@"normalPatternObjectOutsideNormal"];
			if (  normalPatternObjectInsideNormal != nil)
				[dict setObject:normalPatternObjectInsideNormal forKey:@"normalPatternObjectInsideNormal"];
			if (  normalPatternObject != nil)
				[dict setObject:normalPatternObject forKey:@"normalPatternObject"];
		}
		//projection
		else if ( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue]==cNormalPatternProjection)
		{
			if (  normalPatternObject != nil)
				[dict setObject:normalPatternObject forKey:@"normalPatternObject"];
		}
		//normal pattern
		else if ( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue]==cNormalPatternPigmentPattern)
		{
			if (  normalPatternPigment != nil)
				[dict setObject:normalPatternPigment forKey:@"normalPatternPigment"];
		}
		//average normal
		else if ( [[dict objectForKey:@"normalPatternSelectPopUpButton"]intValue]==cNormalPatternAverage)
		{
			if (  normalPatternAverageEditNormal != nil)
				[dict setObject:normalPatternAverageEditNormal forKey:@"normalPatternAverageEditNormal"];
		}
	}

	
//store function for main function
	if ( normalFunctionFunction != nil )
		if([[dict objectForKey:@"normalMainTabView"]intValue]== cNormalFunctionTab)
			if ( [[dict objectForKey:@"normalImageMapFileTypePopUp"]intValue]==cFunctionImage)
				[dict setObject:normalFunctionFunction forKey:@"normalFunctionFunction"];
								
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self normalPatternSelectPopUpButton:nil];
	//make sure colormaps are set correctly at startup
	[self 	tabView:normalMainTabView didSelectTabViewItem:[normalMainTabView selectedTabViewItem]];

	[self normalTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// normalPatternSelectPopUpButton
//---------------------------------------------------------------------
-(IBAction) normalPatternSelectPopUpButton:(id)sender
{
	NSInteger selectedItem=[normalPatternSelectPopUpButton indexOfSelectedItem];
	[normalPatternTabView selectTabViewItemAtIndex:selectedItem];
	BOOL hideAmount=NO;
	BOOL hideBumpSize=NO;
	BOOL hideSlopeMap=NO;
	BOOL hideNormalMap=NO;
	BOOL hideWaveType=NO;
	switch ([normalMainTabView indexOfTabViewItem: [normalMainTabView selectedTabViewItem]])
	{
		case cNormalImageMapTab:
			hideSlopeMap=YES; 
			hideNormalMap=YES; 
			hideWaveType=YES;
			break;
		case cNormalFunctionTab:
			break;
		case cNormalPatternTab:
			switch (selectedItem)
			{
				case cNormalPatternBrick:
				case cNormalPatternChecker:
				case cNormalPatternHexagon:
					hideAmount=YES; 
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				case cNormalPatternObject:
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				case cNormalPatternAgate:
				case cNormalPatternAoi:
				case cNormalPatternBoxed:
				case cNormalPatternBozo:
						break;
				case cNormalPatternBumps:
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;

				case cNormalPatternCells:
				case cNormalPatternCrackle:
				case cNormalPatternCylindrical:
					break;
				case cNormalPatternDensityFile:
					hideAmount=YES; 
					break;
				case cNormalPatternDents:
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				case cNormalPatternFractals:
				case cNormalPatternGradient:
				case cNormalPatternGranite:
				case cNormalPatternImagePattern:
				case cNormalPatternLeopard:	
				case cNormalPatternMarble:
				case cNormalPatternOnion:
				case cNormalPatternPigmentPattern:
				case cNormalPatternPlanar:
				case cNormalPatternProjection:
					break;
				case cNormalPatternQuilted:
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				
				case cNormalPatternRadial:
					break;
				case cNormalPatternRipples:
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
					
				case cNormalPatternSlope:
					hideAmount=YES; 
					hideBumpSize=YES; 
					break;
				case cNormalPatternSpherical:
				case cNormalPatternSpiral:
					break;
				case cNormalPatternWaves:
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				
				case cNormalPatternWood:
					break;
				case cNormalPatternWrinkles:
					hideBumpSize=YES; 
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					hideWaveType=YES;
					break;
				
				case cNormalPatternAverage:
					hideSlopeMap=YES; 
					hideNormalMap=YES; 
					break;
			}
	}
	[normalAmountOn setHidden:hideAmount]; [normalAmountEdit setHidden:hideAmount];
	[normalBumpSizeOn setHidden:hideBumpSize]; [normalBumpSizeEdit setHidden:hideBumpSize];
	[normalNormalSlopeMapOn setHidden:hideSlopeMap]; [normalNormalSlopeMapEditButton setHidden:hideSlopeMap];
	[normalNormalMapOn setHidden:hideNormalMap]; [normalNormalMapEditButton setHidden:hideNormalMap];
	[normalWaveTypePopUpButton setHidden:hideWaveType]; [normalWaveTypeEdit setHidden:hideWaveType];
	[normalWaveTypeText setHidden:hideWaveType];
}



//---------------------------------------------------------------------
// normalTarget:sender
//---------------------------------------------------------------------
-(IBAction) normalTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cNormalTransformationsOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cNormalTransformationsOn:
			[self enableObjectsAccordingToObject:normalTransformationsOn, normalTransformationsEditButton,nil];
			if ( sender !=self )	break;

		case cNormalAmountOn:
			[self enableObjectsAccordingToObject:normalAmountOn, normalAmountEdit,nil];
			if ( sender !=self )	break;

		case cNormalAccuracyOn:
			[self enableObjectsAccordingToObject:normalAccuracyOn, normalAccuracyEdit,nil];
			if ( sender !=self )	break;

		case cNormalBumpSizeOn:
			[self enableObjectsAccordingToObject:normalBumpSizeOn, normalBumpSizeEdit,nil];
			if ( sender !=self )	break;

		case cNormalNormalSlopeMapOn:
			[self enableObjectsAccordingToObject:normalNormalSlopeMapOn, normalNormalSlopeMapEditButton,nil];
			if ( [normalNormalSlopeMapOn state]==NSOnState)
				[self enableObjectsAccordingToState:NSOffState, normalWaveTypePopUpButton,normalWaveTypeEdit,normalWaveTypeText,nil];
			else
				[self enableObjectsAccordingToState:NSOnState, normalWaveTypePopUpButton,normalWaveTypeEdit,normalWaveTypeText,nil];
			if ( sender !=self )	break;

		case cNormalNormalMapOn:
			[self enableObjectsAccordingToObject:normalNormalMapOn, normalNormalMapEditButton,nil];
			if ( sender !=self )	break;

		case cNormalWaveTypePopUpButton:
			if ( [normalWaveTypePopUpButton indexOfSelectedItem]==cPolyWave)
				[normalWaveTypeEdit setHidden:NO];	
			else
				[normalWaveTypeEdit setHidden:YES];	
			if ( sender !=self )	break;

	//pattern
		//brick
		case cNormalPatternBrickAmountOn:
			[self enableObjectsAccordingToObject:normalPatternBrickAmountOn, normalPatternBrickAmountEdit,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickBrickSizeOn:
			[self enableObjectsAccordingToObject:normalPatternBrickBrickSizeOn, normalPatternBrickBrickSizeMatrix,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickMortarOn:
			[self enableObjectsAccordingToObject:normalPatternBrickMortarOn, normalPatternBrickMortarEdit,nil];
			if ( sender !=self )	break;

				//brick1
		case cNormalPatternBrickFullNormal1AmountOn:
			[self enableObjectsAccordingToObject:normalPatternBrickFullNormal1AmountOn, normalPatternBrickFullNormal1AmountEdit,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickFullNormal1TypePopUp:
			if ( [normalPatternBrickFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternBrickFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternBrickFullNormal1ArmsText,normalPatternBrickFullNormal1ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternBrickFullNormal1ArmsText,normalPatternBrickFullNormal1ArmsPopUp,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickFullNormal1ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternBrickFullNormal1ScaleOn, normalPatternBrickFullNormal1ScalePopUp,normalPatternBrickFullNormal1ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternBrickFullNormal1ScalePopUp:
			if ( [normalPatternBrickFullNormal2AmountOn state]==NSOnState && [normalPatternBrickFullNormal2AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternBrickFullNormal1ScalePopUp xyzMatrix:normalPatternBrickFullNormal1ScaleMatrix];
			if ( sender !=self )	break;
				//brick2

		case cNormalPatternBrickFullNormal2AmountOn:
			[self enableObjectsAccordingToObject:normalPatternBrickFullNormal2AmountOn, normalPatternBrickFullNormal2AmountEdit,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickFullNormal2TypePopUp:
			if ( [normalPatternBrickFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternBrickFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternBrickFullNormal2ArmsText,normalPatternBrickFullNormal2ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternBrickFullNormal2ArmsText,normalPatternBrickFullNormal2ArmsPopUp,nil];
			if ( sender !=self )	break;

		case cNormalPatternBrickFullNormal2ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternBrickFullNormal2ScaleOn, normalPatternBrickFullNormal2ScalePopUp,normalPatternBrickFullNormal2ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternBrickFullNormal2ScalePopUp:
			if ( [normalPatternBrickFullNormal2AmountOn state]==NSOnState && [normalPatternBrickFullNormal2AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternBrickFullNormal2ScalePopUp xyzMatrix:normalPatternBrickFullNormal2ScaleMatrix];
			if ( sender !=self )	break;
				
		case cNormalPatternBrickFullNormalMatrix:
			if ([[normalPatternBrickFullNormalMatrix selectedCell]tag]==cFirstCell)
			{
				SetSubViewsOfNSBoxToState(normalPatternBrickFullNormalGroup, NSOffState);
				[self enableObjectsAccordingToState:NSOnState,normalPatternBrickAmountOn, normalPatternBrickAmountEdit,nil];
			}
			else
			{
				[self enableObjectsAccordingToState:NSOffState,normalPatternBrickAmountOn, normalPatternBrickAmountEdit,nil];
	
				SetSubViewsOfNSBoxToState(normalPatternBrickFullNormalGroup, NSOnState);
				[self enableObjectsAccordingToObject:normalPatternBrickFullNormal1AmountOn, normalPatternBrickFullNormal1AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternBrickFullNormal1ScaleOn, normalPatternBrickFullNormal1ScalePopUp,normalPatternBrickFullNormal1ScaleMatrix,nil];
				if ( [normalPatternBrickFullNormal2AmountOn state]==NSOnState && [normalPatternBrickFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternBrickFullNormal1ScalePopUp xyzMatrix:normalPatternBrickFullNormal1ScaleMatrix];
				[self enableObjectsAccordingToObject:normalPatternBrickFullNormal2AmountOn, normalPatternBrickFullNormal2AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternBrickFullNormal2ScaleOn, normalPatternBrickFullNormal2ScalePopUp,normalPatternBrickFullNormal2ScaleMatrix,nil];
				if ( [normalPatternBrickFullNormal2AmountOn state]==NSOnState && [normalPatternBrickFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternBrickFullNormal2ScalePopUp xyzMatrix:normalPatternBrickFullNormal2ScaleMatrix];
				if ( [normalPatternBrickFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternBrickFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternBrickFullNormal1ArmsText,normalPatternBrickFullNormal1ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternBrickFullNormal1ArmsText,normalPatternBrickFullNormal1ArmsPopUp,nil];
				if ( [normalPatternBrickFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternBrickFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternBrickFullNormal2ArmsText,normalPatternBrickFullNormal2ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternBrickFullNormal2ArmsText,normalPatternBrickFullNormal2ArmsPopUp,nil];
			}
			if ( sender !=self )	break;

		//checker
		case cNormalPatternCheckerAmountOn:
			[self enableObjectsAccordingToObject:normalPatternCheckerAmountOn, normalPatternCheckerAmountEdit,nil];
			if ( sender !=self )	break;
				//checker1
		case cNormalPatternCheckerFullNormal1AmountOn:
			[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal1AmountOn, normalPatternCheckerFullNormal1AmountEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal1TypePopUp:
			if ( [normalPatternCheckerFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternCheckerFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternCheckerFullNormal1ArmsText,normalPatternCheckerFullNormal1ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternCheckerFullNormal1ArmsText,normalPatternCheckerFullNormal1ArmsPopUp,nil];
			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal1ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal1ScaleOn, normalPatternCheckerFullNormal1ScalePopUp,normalPatternCheckerFullNormal1ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal1ScalePopUp:
			if ( [normalPatternCheckerFullNormal2AmountOn state]==NSOnState && [normalPatternCheckerFullNormal2AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternCheckerFullNormal1ScalePopUp xyzMatrix:normalPatternCheckerFullNormal1ScaleMatrix];
			if ( sender !=self )	break;

				//checker2
		case cNormalPatternCheckerFullNormal2AmountOn:
			[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal2AmountOn, normalPatternCheckerFullNormal2AmountEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal2TypePopUp:
			if ( [normalPatternCheckerFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternCheckerFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternCheckerFullNormal2ArmsText,normalPatternCheckerFullNormal2ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternCheckerFullNormal2ArmsText,normalPatternCheckerFullNormal2ArmsPopUp,nil];
			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal2ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal2ScaleOn, normalPatternCheckerFullNormal2ScalePopUp,normalPatternCheckerFullNormal2ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternCheckerFullNormal2ScalePopUp:
			if ( [normalPatternCheckerFullNormal2AmountOn state]==NSOnState && [normalPatternCheckerFullNormal2AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternCheckerFullNormal2ScalePopUp xyzMatrix:normalPatternCheckerFullNormal2ScaleMatrix];
			if ( sender !=self )	break;
				
		case cNormalPatternCheckerFullNormalMatrix:
			if ([[normalPatternCheckerFullNormalMatrix selectedCell]tag]==cFirstCell)
			{
				SetSubViewsOfNSBoxToState(normalPatternCheckerFullNormalGroup, NSOffState);
				[self enableObjectsAccordingToState:NSOnState,normalPatternCheckerAmountOn, normalPatternCheckerAmountEdit,nil];
			}
			else
			{
				[self enableObjectsAccordingToState:NSOffState,normalPatternCheckerAmountOn, normalPatternCheckerAmountOn,nil];
			
				SetSubViewsOfNSBoxToState(normalPatternCheckerFullNormalGroup, NSOnState);
				[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal1AmountOn, normalPatternCheckerFullNormal1AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal1ScaleOn, normalPatternCheckerFullNormal1ScalePopUp,normalPatternCheckerFullNormal1ScaleMatrix,nil];
				if ( [normalPatternCheckerFullNormal2AmountOn state]==NSOnState && [normalPatternCheckerFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternCheckerFullNormal1ScalePopUp xyzMatrix:normalPatternCheckerFullNormal1ScaleMatrix];
				[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal2AmountOn, normalPatternCheckerFullNormal2AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternCheckerFullNormal2ScaleOn, normalPatternCheckerFullNormal2ScalePopUp,normalPatternCheckerFullNormal2ScaleMatrix,nil];
				if ( [normalPatternCheckerFullNormal2AmountOn state]==NSOnState && [normalPatternCheckerFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternCheckerFullNormal2ScalePopUp xyzMatrix:normalPatternCheckerFullNormal2ScaleMatrix];
				if ( [normalPatternCheckerFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternCheckerFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternCheckerFullNormal1ArmsText,normalPatternCheckerFullNormal1ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternCheckerFullNormal1ArmsText,normalPatternCheckerFullNormal1ArmsPopUp,nil];
				if ( [normalPatternCheckerFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternCheckerFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternCheckerFullNormal2ArmsText,normalPatternCheckerFullNormal2ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternCheckerFullNormal2ArmsText,normalPatternCheckerFullNormal2ArmsPopUp,nil];
			}
			if ( sender !=self )	break;

		//hexagon
		case cNormalPatternHexagonAmountOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonAmountOn, normalPatternHexagonAmountEdit,nil];
			if ( sender !=self )	break;
				//hexagon1
		case cNormalPatternHexagonFullNormal1AmountOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal1AmountOn, normalPatternHexagonFullNormal1AmountEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal1TypePopUp:
			if ( [normalPatternHexagonFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal1ArmsText,normalPatternHexagonFullNormal1ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal1ArmsText,normalPatternHexagonFullNormal1ArmsPopUp,nil];
			if ( sender !=self )	break;

		case cNormalPatternHexagonFullNormal1ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal1ScaleOn, normalPatternHexagonFullNormal1ScalePopUp,normalPatternHexagonFullNormal1ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal1ScalePopUp:
			if ( [normalPatternHexagonFullNormal1AmountOn state]==NSOnState && [normalPatternHexagonFullNormal1AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal1ScalePopUp xyzMatrix:normalPatternHexagonFullNormal1ScaleMatrix];
			if ( sender !=self )	break;

				//hexagon2
		case cNormalPatternHexagonFullNormal2AmountOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal2AmountOn, normalPatternHexagonFullNormal2AmountEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal2TypePopUp:
			if ( [normalPatternHexagonFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal2ArmsText,normalPatternHexagonFullNormal2ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal2ArmsText,normalPatternHexagonFullNormal2ArmsPopUp,nil];
			if ( sender !=self )	break;
			
		case cNormalPatternHexagonFullNormal2ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal2ScaleOn, normalPatternHexagonFullNormal2ScalePopUp,normalPatternHexagonFullNormal2ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal2ScalePopUp:
			if ( [normalPatternHexagonFullNormal2AmountOn state]==NSOnState && [normalPatternHexagonFullNormal2AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal2ScalePopUp xyzMatrix:normalPatternHexagonFullNormal2ScaleMatrix];
			if ( sender !=self )	break;

				//hexagon3
		case cNormalPatternHexagonFullNormal3AmountOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal3AmountOn, normalPatternHexagonFullNormal3AmountEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal3TypePopUp:
			if ( [normalPatternHexagonFullNormal3TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal3TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
				[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal3ArmsText,normalPatternHexagonFullNormal3ArmsPopUp,nil];
			else
				[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal3ArmsText,normalPatternHexagonFullNormal3ArmsPopUp,nil];
			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal3ScaleOn:
			[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal3ScaleOn, normalPatternHexagonFullNormal3ScalePopUp,normalPatternHexagonFullNormal3ScaleMatrix,nil];
//			if ( sender !=self )	break;
		case cNormalPatternHexagonFullNormal3ScalePopUp:
			if ( [normalPatternHexagonFullNormal3AmountOn state]==NSOnState && [normalPatternHexagonFullNormal3AmountOn isEnabled]==YES)
				[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal3ScalePopUp xyzMatrix:normalPatternHexagonFullNormal3ScaleMatrix];
			if ( sender !=self )	break;
				
		case cNormalPatternHexagonFullNormalMatrix:
			if ([[normalPatternHexagonFullNormalMatrix selectedCell]tag]==cFirstCell)
			{
				SetSubViewsOfNSBoxToState(normalPatternHexagonFullNormalGroup, NSOffState);
				[self enableObjectsAccordingToState:NSOnState,normalPatternHexagonAmountOn, normalPatternHexagonAmountEdit,nil];
			}
			else
			{
				[self enableObjectsAccordingToState:NSOffState,normalPatternHexagonAmountOn, normalPatternHexagonAmountEdit,nil];
				SetSubViewsOfNSBoxToState(normalPatternHexagonFullNormalGroup, NSOnState);
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal1AmountOn, normalPatternHexagonFullNormal1AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal1ScaleOn, normalPatternHexagonFullNormal1ScalePopUp,normalPatternHexagonFullNormal1ScaleMatrix,nil];
				if ( [normalPatternHexagonFullNormal2AmountOn state]==NSOnState && [normalPatternHexagonFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal1ScalePopUp xyzMatrix:normalPatternHexagonFullNormal1ScaleMatrix];
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal2AmountOn, normalPatternHexagonFullNormal2AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal2ScaleOn, normalPatternHexagonFullNormal2ScalePopUp,normalPatternHexagonFullNormal2ScaleMatrix,nil];
				if ( [normalPatternHexagonFullNormal2AmountOn state]==NSOnState && [normalPatternHexagonFullNormal2AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal2ScalePopUp xyzMatrix:normalPatternHexagonFullNormal2ScaleMatrix];
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal3AmountOn, normalPatternHexagonFullNormal3AmountEdit,nil];
				[self enableObjectsAccordingToObject:normalPatternHexagonFullNormal3ScaleOn, normalPatternHexagonFullNormal3ScalePopUp,normalPatternHexagonFullNormal3ScaleMatrix,nil];
				if ( [normalPatternHexagonFullNormal3AmountOn state]==NSOnState && [normalPatternHexagonFullNormal3AmountOn isEnabled]==YES)
					[ self setXYZVectorAccordingToPopup:normalPatternHexagonFullNormal3ScalePopUp xyzMatrix:normalPatternHexagonFullNormal3ScaleMatrix];
				if ( [normalPatternHexagonFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal1TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal1ArmsText,normalPatternHexagonFullNormal1ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal1ArmsText,normalPatternHexagonFullNormal1ArmsPopUp,nil];
				if ( [normalPatternHexagonFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal2TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal2ArmsText,normalPatternHexagonFullNormal2ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal2ArmsText,normalPatternHexagonFullNormal2ArmsPopUp,nil];
				if ( [normalPatternHexagonFullNormal3TypePopUp indexOfSelectedItem]==cFullNormalSpiral1 ||[normalPatternHexagonFullNormal3TypePopUp indexOfSelectedItem]==cFullNormalSpiral2)
					[self enableObjectsAccordingToState:NSOnState, normalPatternHexagonFullNormal3ArmsText,normalPatternHexagonFullNormal3ArmsPopUp,nil];
				else
					[self enableObjectsAccordingToState:NSOffState, normalPatternHexagonFullNormal3ArmsText,normalPatternHexagonFullNormal3ArmsPopUp,nil];
			}
			if ( sender !=self )	break;
				
	
		//crackle
		case cNormalPatternCrackleType1PopUp:
			switch ([normalPatternCrackleType1PopUp indexOfSelectedItem])
			{
				case cForm:
					[normalPatternCrackleType1MatrixView setHidden:NO];	[normalPatternCrackleType1Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[normalPatternCrackleType1MatrixView setHidden:YES];	[normalPatternCrackleType1Edit setHidden:NO];
					break;
				case cSolid:
					[normalPatternCrackleType1MatrixView setHidden:YES];	[normalPatternCrackleType1Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cNormalPatternCrackleType1On:
			[self enableObjectsAccordingToObject:normalPatternCrackleType1On, normalPatternCrackleType1PopUp,normalPatternCrackleType1MatrixView,normalPatternCrackleType1Edit,nil];
			if ( sender !=self )	break;
			//2
		case cNormalPatternCrackleType2PopUp:
			switch ([normalPatternCrackleType2PopUp indexOfSelectedItem])
			{
				case cForm:
					[normalPatternCrackleType2MatrixView setHidden:NO];	[normalPatternCrackleType2Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[normalPatternCrackleType2MatrixView setHidden:YES];	[normalPatternCrackleType2Edit setHidden:NO];
					break;
				case cSolid:
					[normalPatternCrackleType2MatrixView setHidden:YES];	[normalPatternCrackleType2Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cNormalPatternCrackleType2On:
			[self enableObjectsAccordingToObject:normalPatternCrackleType2On, normalPatternCrackleType2PopUp,normalPatternCrackleType2MatrixView,normalPatternCrackleType2Edit,nil];
			if ( sender !=self )	break;
		//3
		case cNormalPatternCrackleType3PopUp:
			switch ([normalPatternCrackleType3PopUp indexOfSelectedItem])
			{
				case cForm:
					[normalPatternCrackleType3MatrixView setHidden:NO];	[normalPatternCrackleType3Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[normalPatternCrackleType3MatrixView setHidden:YES];	[normalPatternCrackleType3Edit setHidden:NO];
					break;
				case cSolid:
					[normalPatternCrackleType3MatrixView setHidden:YES];	[normalPatternCrackleType3Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cNormalPatternCrackleType3On:
			[self enableObjectsAccordingToObject:normalPatternCrackleType3On, normalPatternCrackleType3PopUp,normalPatternCrackleType3MatrixView,normalPatternCrackleType3Edit,nil];
			if ( sender !=self )	break;
			//4
		case cNormalPatternCrackleType4PopUp:
			switch ([normalPatternCrackleType4PopUp indexOfSelectedItem])
			{
				case cForm:
					[normalPatternCrackleType4MatrixView setHidden:NO];	[normalPatternCrackleType4Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[normalPatternCrackleType4MatrixView setHidden:YES];	[normalPatternCrackleType4Edit setHidden:NO];
					break;
				case cSolid:
					[normalPatternCrackleType4MatrixView setHidden:YES];	[normalPatternCrackleType4Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cNormalPatternCrackleType4On:
			[self enableObjectsAccordingToObject:normalPatternCrackleType4On, normalPatternCrackleType4PopUp,normalPatternCrackleType4MatrixView,normalPatternCrackleType4Edit,nil];
			if ( sender !=self )	break;

		//facets
		case cNormalPatternFacetsSizeOn:
			[self enableObjectsAccordingToObject:normalPatternFacetsSizeOn, normalPatternFacetsSizeEdit,nil];
			if ( sender !=self )	break;
		case cNormalPatternFacetsCoordsOn:
			[self enableObjectsAccordingToObject:normalPatternFacetsCoordsOn, normalPatternFacetsCoordsEdit,nil];
			if ( sender !=self )	break;
		//factals
		case cPnormalPatternFractalsTypePopUp:
			switch ([normalPatternFractalsTypePopUp indexOfSelectedItem])
			{
				case cJulia:
					[normalPatternFractalsExponentView setHidden:NO];	[normalPatternFractalsTypeXYView setHidden:NO];
					break;
				case cMagnet1Julia:
				case cMagnet2Julia:
					[normalPatternFractalsExponentView setHidden:YES];	[normalPatternFractalsTypeXYView setHidden:NO];
					break;
				case cMagnet1Mandel:
				case cMagnet2Mandel:
					[normalPatternFractalsExponentView setHidden:YES];	[normalPatternFractalsTypeXYView setHidden:YES];
					break;
				case cMandel:
					[normalPatternFractalsExponentView setHidden:NO];	[normalPatternFractalsTypeXYView setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
	 	case cNormalPatternFractalsExponentOn:
			[self enableObjectsAccordingToObject:normalPatternFractalsExponentOn, normalPatternFractalsExponentEdit,nil];
			if ( sender !=self )	break;
	 	case cNormalPatternFractalsInteriorTypeOn:
			[self enableObjectsAccordingToObject:normalPatternFractalsInteriorTypeOn, normalPatternFractalsInteriorTypePopUp,
					normalPatternFractalsInteriorTypeFactorEdit, normalPatternFractalsInteriorTypeFactorText,nil];
			if ( sender !=self )	break;
	 	case cNormalPatternFractalsExteriorTypeOn	:
			[self enableObjectsAccordingToObject:normalPatternFractalsExteriorTypeOn, normalPatternFractalsExteriorTypePopUp,
					normalPatternFractalsExteriorTypeFactorEdit,normalPatternFractalsExteriorTypeFactorText,nil];
			if ( sender !=self )	break;

		//gradient
		case cNormalPatternGradientXYZPopUp:
			[ self setXYZVectorAccordingToPopup:normalPatternGradientXYZPopUp xyzMatrix:normalPatternGradientMatrix];
			if ( sender !=self )	break;

		//image pattern
		case cNormalPatternImageMapProjectionPopUp:
			if ( [normalPatternImageMapProjectionPopUp indexOfSelectedItem] == cProjectionSpherical)
				[normalPatternImageMapProjectionOnceOn setEnabled:NO];
			else
				[normalPatternImageMapProjectionOnceOn setEnabled:YES];
			if ( sender !=self )	break;


		case cNormalPatternImagePatternFileTypePopUp:
			switch([normalPatternImagePatternFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[normalPatternImagePatternFileView setHidden:NO];
					[normalPatternImagePatternWidthHeightView setHidden:YES];
					[normalPatternImagePatternFunctionView setHidden:YES];
					[normalPatternImagePatternPatternView setHidden:YES];
					[normalPatternImagePatternPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[normalPatternImagePatternFileView setHidden:YES];
					[normalPatternImagePatternWidthHeightView setHidden:NO];
					[normalPatternImagePatternFunctionView setHidden:NO];
					[normalPatternImagePatternPatternView setHidden:YES];
					[normalPatternImagePatternPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[normalPatternImagePatternFileView setHidden:YES];
					[normalPatternImagePatternWidthHeightView setHidden:NO];
					[normalPatternImagePatternFunctionView setHidden:YES];
					[normalPatternImagePatternPatternView setHidden:NO];
					[normalPatternImagePatternPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[normalPatternImagePatternFileView setHidden:YES];
					[normalPatternImagePatternWidthHeightView setHidden:NO];
					[normalPatternImagePatternFunctionView setHidden:YES];
					[normalPatternImagePatternPatternView setHidden:YES];
					[normalPatternImagePatternPigmentView setHidden:NO];
					break;
			}
			if ( sender !=self )	break;
		//Projection
		case cNormalPatternProjectionNormalPopUp:
			switch([normalPatternProjectionNormalPopUp indexOfSelectedItem])
			{
				case 	cPoint:	case cParallel:
					[normalPatternProjectionView setHidden:NO];
					break;
				default:
					[normalPatternProjectionView setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cNormalPatternProjectionXYZPopUp:
			[ self setXYZVectorAccordingToPopup:normalPatternProjectionXYZPopUp xyzMatrix:normalPatternProjectionXYZMatrix];
			if ( sender !=self )	break;
		case cNormalPatternProjectionBlurOn:
			[self enableObjectsAccordingToObject:normalPatternProjectionBlurOn, normalPatternProjectionAmountEdit,
					normalPatternProjectionAmountText,normalPatternProjectionSamplesEdit,normalPatternProjectionSamplesText,nil];
			if ( sender !=self )	break;
		//slope
		case cNormalPatternSlopeDirectionXYZPopUp:
			[ self setXYZVectorAccordingToPopup:normalPatternSlopeDirectionXYZPopUp xyzMatrix:normalPatternSlopeDirectionMatrix];
			if ( sender !=self )	break;
		case cNormalPatternSlopeSlopeOn:
			[self enableObjectsAccordingToObject:normalPatternSlopeSlopeOn, normalPatternSlopeSlopeLowText,
					normalPatternSlopeSlopeLowEdit,normalPatternSlopeSlopeHighText,normalPatternSlopeSlopeHighEdit, nil];
			if ( sender !=self )	break;
		case cNormalPatternSlopeAltitudeXYZPopUp:
			[ self setXYZVectorAccordingToPopup:normalPatternSlopeAltitudeXYZPopUp xyzMatrix:normalPatternSlopeAltitudeMatrix];
			if ( sender !=self )	break;
		case cNormalPatternSlopeAltitudeOn:
			[self enableObjectsAccordingToObject:normalPatternSlopeAltitudeOn, normalPatternSlopeAltitudeXYZPopUp,
					normalPatternSlopeAltitudeMatrix, nil];
			if ( sender !=self )	break;
		case cNormalPatternSlopeOffsetOn:
			[self enableObjectsAccordingToObject:normalPatternSlopeOffsetOn, normalPatternSlopeOffsetLowText,
					normalPatternSlopeOffsetLowEdit,normalPatternSlopeOffsetHighText,normalPatternSlopeOffsetHighEdit, nil];
			if ( sender !=self )	break;

		
		case cNormalImageMapProjectionPopUp:
			if ( [normalImageMapProjectionPopUp indexOfSelectedItem] == cProjectionSpherical)
				[normalImageMapProjectionOnceOn setEnabled:NO];
			else
				[normalImageMapProjectionOnceOn setEnabled:YES];
			if ( sender !=self )	break;
		//normal image pattern
		case cNormalImageMapFileTypePopUp:
			switch([normalImageMapFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[normalImageMapFileView setHidden:NO];
					[normalImageMapWidthHeightView setHidden:YES];
					[normalImageMapFunctionView setHidden:YES];
					[normalImageMapPatternView setHidden:YES];
					[normalImageMapPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[normalImageMapFileView setHidden:YES];
					[normalImageMapWidthHeightView setHidden:NO];
					[normalImageMapFunctionView setHidden:NO];
					[normalImageMapPatternView setHidden:YES];
					[normalImageMapPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[normalImageMapFileView setHidden:YES];
					[normalImageMapWidthHeightView setHidden:NO];
					[normalImageMapFunctionView setHidden:YES];
					[normalImageMapPatternView setHidden:NO];
					[normalImageMapPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[normalImageMapFileView setHidden:YES];
					[normalImageMapWidthHeightView setHidden:NO];
					[normalImageMapFunctionView setHidden:YES];
					[normalImageMapPatternView setHidden:YES];
					[normalImageMapPigmentView setHidden:NO];
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

	if( [key isEqualToString:@"normalImageMapFunction"])
	{
		[self setNormalImageMapFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[normalImageMapFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"normalPatternImageMapFunction"])
	{
		[self setNormalImageMapFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[normalPatternImagePatternFunctionFunctionEdit  insertText:str];
	}

	else if( [key isEqualToString:@"normalFunctionFunction"])
	{
		[self setNormalFunctionFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[normalFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"normalTransformations"])
	{
		[self setNormalTransformations:dict];
	}
	else if( [key isEqualToString:@"normalImageMapPatternNormal"])
	{
		[self setNormalImageMapPatternNormal:dict];
	}
	else if( [key isEqualToString:@"normalImageMapNormal"])
	{
		[self setNormalImageMapNormal:dict];
	}
	else if( [key isEqualToString:@"normalPatternPigment"])
	{
		[self setNormalPatternPigment:dict];
	}
	else if( [key isEqualToString:@"normalPatternObjectOutsideNormal"])
	{
		[self setNormalPatternObjectOutsideNormal:dict];
	}
	else if( [key isEqualToString:@"normalNormalmap"])
	{
		[self setNormalNormalmap:dict];
	}
	else if( [key isEqualToString:@"normalSlopemap"])
	{
		[self setNormalSlopemap:dict];
	}
	else if( [key isEqualToString:@"normalPatternObjectInsideNormal"])
	{
		[self setNormalPatternObjectInsideNormal:dict];
	}
	else if( [key isEqualToString:@"normalPatternObject"])
	{
		[self setNormalPatternObject:dict];
	}
	else if( [key isEqualToString:@"normalPatternAverageEditNormal"])
	{
		[self setNormalPatternAverageEditNormal:dict];
	}

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// normalButtons:sender
//---------------------------------------------------------------------
-(IBAction) normalButtons:(id)sender
{
	id 	prefs=nil;

	NSInteger tag=[sender tag];
	switch( tag)
	{
		case cNormalTransformationsEditButton:
			if (normalTransformations!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalTransformations];
			[self callTemplate:menuTagTemplateTransformations withDictionary:prefs andKeyName:@"normalTransformations"];
			break;

		case cNormalNormalSlopeMapEditButton:
			if (normalSlopemap!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalSlopemap];
			[self callTemplate:menuTagTemplateSlopemap withDictionary:prefs andKeyName:@"normalSlopemap"];
			break;

		case cNnormalNormalMapEditButton:
			if (normalNormalmap!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalNormalmap];
			[self callTemplate:menuTagTemplateNormalmap withDictionary:prefs andKeyName:@"normalNormalmap"];
			break;

		case cNormalPatternObjectEditOutsideNormal	:
			if (normalPatternObjectOutsideNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalPatternObjectOutsideNormal];
			[self callTemplate:menuTagTemplateNormal withDictionary:prefs andKeyName:@"normalPatternObjectOutsideNormal"];
			break;

		case cNormalPatternObjectEditInsideNormal:
			if (normalPatternObjectInsideNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalPatternObjectInsideNormal];
			[self callTemplate:menuTagTemplateNormal withDictionary:prefs andKeyName:@"normalPatternObjectInsideNormal"];
			break;

		case cNormalPatternDisityFileSelectFileButton:
			[self selectFile:normalPatternDisityFileFileNameEdit withTypes:nil  keepFullPath:NO];
			break;

		case cNormalPatternPigmentPatternEditNormal:
			if (normalPatternPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalPatternPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"normalPatternPigment"];

			break;

		case cNormalPatternObjectEditObject:
		case cNormalPatternProjectionEditObjectButton:
			if (normalPatternObject!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalPatternObject];
			[self callTemplate:menuTagTemplateObject withDictionary:prefs andKeyName:@"normalPatternObject"];

			break;
		case cNormalPatternAverageEditNormal:
			if (normalPatternAverageEditNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalPatternAverageEditNormal];
			[self callTemplate:menuTagTemplateNormalmap withDictionary:prefs andKeyName:@"normalPatternAverageEditNormal"];
			break;

//image map & pattern image map
	 	case cNormalPatternImagePatternEditFunctionButton:
			if (normalImageMapFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalImageMapFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"normalPatternImageMapFunction"];
			break;
	 	case cNormalImageMapEditFunctionButton:
			if (normalImageMapFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalImageMapFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"normalImageMapFunction"];
			break;
			
	 	case cNormalPatternImagePatternEditPatternButton:
	 	case cNormalImageMapEditPatternButton:
			if (normalImageMapPatternNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalImageMapPatternNormal];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"normalImageMapPatternNormal"];
			break;
			
	 	case cNormalPatternImagePatternEditNormalButton:
		case cNormalImageMapEditNormalButton:
			if (normalImageMapNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalImageMapNormal];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"normalImageMapNormal"];
			break;

		case cNormalImageMapSelectImageFileButton:
			[self selectFile:normalImageMapFileName withTypes:nil  keepFullPath:NO];
			break;

	 	case cNormalPatternImagePatternSelectImageFileButton:
			[self selectFile:normalPatternImagePatternFileNameEdit withTypes:nil keepFullPath:NO];
			break;

		case cNormalFunctionEditFunctionButton:
			if (normalFunctionFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:normalFunctionFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"normalFunctionFunction"];
			break;

	}
}


//---------------------------------------------------------------------
// tabView delegate
//---------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if ( tabView == normalMainTabView)
	{
		[self normalPatternSelectPopUpButton:nil];
	}
}

@end


//--------------------------------------------------------------------
// WriteFullNormal
//--------------------------------------------------------------------
static void WriteFullNormal(MutableTabString *ds,NSDictionary *dict, 
									NSString *ScalePoUp, NSString *NormalPopUp, NSString *ArmsPopUp,
									NSString *AmountOn, NSString *AmountEdit, NSString *ScaleOn, NSString *ScaleX, NSString *ScaleY, NSString *ScaleZ)

{
	[ds copyTabAndText:@"normal {\n"];
	[ds addTab];
	[ds copyTabAndText:GetNormalPatternPopup(dict, NormalPopUp,ArmsPopUp)];

	if ([[dict objectForKey:AmountOn]intValue]==NSOnState)
		[ds appendFormat:@"%@\t//amount\n",[dict objectForKey:AmountEdit]];

	if ([[dict objectForKey:ScaleOn]intValue]==NSOnState)
	{
		switch([[dict objectForKey:ScalePoUp]intValue])
		{
			case cXYZVectorPopupXisYisZ:
				[ds appendTabAndFormat:@"scale <%@, %@, %@>",[dict objectForKey:ScaleX],[dict objectForKey:ScaleX],[dict objectForKey:ScaleX]];
				break;
			case cXYZVectorPopupX:
				[ds appendTabAndFormat:@"scale <%@, 1.0, 1.0>",[dict objectForKey:ScaleX]];
				break;
			case cXYZVectorPopupY:
				[ds appendTabAndFormat:@"scale <1.0, %@, 1.0>",[dict objectForKey:ScaleY]];
				break;
			case cXYZVectorPopupZ:
				[ds appendTabAndFormat:@"scale <1.0, 1.0, %@>",[dict objectForKey:ScaleZ]];
				break;
			case cXYZVectorPopupXandYandZ:
				[ds appendTabAndFormat:@"scale <%@, %@, %@>",[dict objectForKey:ScaleX],[dict objectForKey:ScaleY],[dict objectForKey:ScaleZ]];
				break;
		}
	}
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
}

//--------------------------------------------------------------------
// GetNormalPatternPopup
//--------------------------------------------------------------------
static NSString * GetNormalPatternPopup(NSDictionary *dict,  NSString *NormalPopUp, NSString  *ArmsPopUp)
{
	NSString *ret=@"";
	switch([[dict objectForKey:NormalPopUp]intValue])
	{
		case cFullNormalBrick:		ret=@"brick ";							break;
		case cFullNormalChecker:	ret=@"checker ";						break;
		case cFullNormalHexagon:	ret=@"hexagon ";						break;
		case cFullNormalAgate:		ret=@"agate ";							break;
		case cFullNormalBozo:		ret=@"bozo ";							break;
		case cFullNormalBumps:		ret=@"bumps ";							break;
		case cFullNormalCells:		ret=@"cells ";								break;
		case cFullNormalCrackle:	ret=@"crackle ";							break;
		case cFullNormalDents:		ret=@"dents ";							break;
		case cFullNormalGradient:	ret=@"gradient y ";						break;
		case cFullNormalGranite:		ret=@"granite ";							break;
		case cFullNormalLeopard:	ret=@"leopard ";						break;
		case cFullNormalMandel:		ret=@"mandel 25 ";						break;
		case cFullNormalMarble:		ret=@"marble ";							break;
		case cFullNormalOnion:		ret=@"onion ";							break;
		case cFullNormalQuilted:		ret=@"quilted ";							break;
		case cFullNormalRadial:		ret=@"radial ";							break;
		case cFullNormalRipples:	ret=@"ripples ";							break;
		case cFullNormalSpiral1:		ret=[NSString stringWithFormat:@"spiral1 %d ",[[dict objectForKey:ArmsPopUp]intValue]+1];	break;
		case cFullNormalSpiral2:		ret=[NSString stringWithFormat:@"spiral2 %d ",[[dict objectForKey:ArmsPopUp]intValue]+1];	break;
		case cFullNormalWaves:		ret=@"waves ";							break;
		case cFullNormalWood:		ret=@"wood ";							break;
		case cFullNormalWrinkles:	ret=@"wrinkles ";						break;
	}
	return ret;
}		

//--------------------------------------------------------------------
// WriteStandardNormal
//--------------------------------------------------------------------
static void WriteStandardNormal(NSDictionary *dict, MutableTabString *ds,NSString *nameString)
{
	[ds copyTabAndText:nameString];

	if ( [[dict objectForKey:@"normalAmountOn"]intValue]==NSOnState)
		[ds appendFormat:@" %@\n",[dict objectForKey:@"normalAmountEdit"]];
	else
		[ds copyText:@"\n"];

	if ( [[dict objectForKey:@"normalBumpSizeOn"]intValue]==NSOnState)
		[ds appendTabAndFormat:@"bump_size %@\n",[dict objectForKey:@"normalBumpSizeEdit"]];
	AddWavesTypeFromPopup(ds,dict, @"normalWaveTypePopUpButton", @"normalWaveTypeEdit");
}

//--------------------------------------------------------------------
// WriteSpecificNormal
//--------------------------------------------------------------------
static void WriteSpecificNormal(NSDictionary *dict, MutableTabString *ds,NSString *nameString)
{
	[ds copyTabAndText:nameString];
	if ( [[dict objectForKey:@"normalAmountOn"]intValue]==NSOnState)
		[ds appendFormat:@" %@\n",[dict objectForKey:@"normalAmountEdit"]];
	else
		[ds copyText:@"\n"];
}
