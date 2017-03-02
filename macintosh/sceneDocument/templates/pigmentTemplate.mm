//******************************************************************************
///
/// @file <File Name>
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
//******************************************************************************
#import "pigmentTemplate.h"
#import "functionTemplate.h"
#import "transformationsTemplate.h"
#import "cameraTemplate.h"
#import "bodymapTemplate.h"
#import "objectTemplate.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"
#import "baseTemplate.h"
#import "tooltipAutomator.h"

#import "colormap.h"



@implementation PigmentTemplate

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[mPigmentPatternColormapViewArray release];
	mPigmentPatternColormapViewArray=nil;
	[super dealloc];
}

//---------------------------------------------------------------------
// pigmentMainViewNIBView
//---------------------------------------------------------------------
-(NSView*) pigmentMainViewNIBView
{
	return pigmentMainViewNIBView;
}

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{
	BOOL writeTransformationsBeforeClosing=YES;
	BOOL writeQuickColorBeforeClosing=YES;
	if ( dict== nil)
		dict=[PigmentTemplate createDefaults:menuTagTemplatePigment];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[PigmentTemplate class] andTemplateType:menuTagTemplatePigment];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}
	[dict retain];


	if ( [[dict objectForKey:@"pigmentDontWrapInPigment"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"pigment {\n"];
		[ds addTab];
	}

	switch( [[dict objectForKey:@"pigmentMainTabView"]intValue])	//pigment type
	{
		case cPigmentImageMapTab:
			[ds copyTabAndText:@"image_map {\n"];
			WritePatternPanel(ds, dict, @"pigmentImageMapFileTypePopUp", 
													@"pigmentImageMapFunctionImageWidth", @"pigmentImageMapFunctionImageHeight",
													@"pigmentImageMapFunctionEdit", @"pigmentImageMapPatternPigment",
													@"pigmentImageMapPigmentPigment" ,@"pigmentImageMapFileName");
			switch( [[dict objectForKey:@"pigmentImageMapProjectionPopUp"]intValue])
			{
				case cProjectionPlanar:					[ds copyTabAndText:@"map_type 0\t//planar\n"];				break;
				case cProjectionSpherical:			[ds copyTabAndText:@"map_type 1\t//spherical\n"];			break;
				case cProjectionCylindrical:		[ds copyTabAndText:@"map_type 2\t//cylindrical\n"];			break;
				case cProjection3:							break;
				case cProjection4:							break;
				case cProjectionTorus:					[ds copyTabAndText:@"map_type 5\t//torus\n"];					break;
				case cProjectionOmnidirectional:	[ds copyTabAndText:@"map_type 7\t//omnidirectional\n"];	break;
			}
			if ( [[dict objectForKey:@"pigmentImageMapProjectionOnceOn"]intValue]==NSOnState)
				[ds copyTabAndText:@"once\n"];

			switch( [[dict objectForKey:@"pigmentImageMapInterpolationPopUp"]intValue])
			{
				case cInterpolationNone:								[ds copyTabAndText:@"interpolate 0\t//none\n"];							break;
				case cInterpolationBilinear:						[ds copyTabAndText:@"interpolate 2\t//bilinear\n"];						break;
				case cInterpolationBicubic:							[ds copyTabAndText:@"interpolate 3\t//bicubic\n"];						break;
				case cInterpolationNormilizedDistance:	[ds copyTabAndText:@"interpolate 4\t//normalized distance\n"];	break;
			}
	
			if ( [[dict objectForKey:@"pigmentImageMapFilerAllOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"filter all %@\n",[dict objectForKey:@"pigmentImageMapFilterAllEdit"]];
			if ( [[dict objectForKey:@"pigmentImageMapTransmitAllOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"transmit all %@\n",[dict objectForKey:@"pigmentImageMapTransmitAllEdit"]];

			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			writeTransformationsBeforeClosing=YES;
			writeQuickColorBeforeClosing=YES;
			break;	
//cPigmentFunctionTab
		case cPigmentFunctionTab:
			[ds copyTabAndText:@"function {\n"];
			[ds addTab];
			[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"pigmentFunctionEdit"]];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];

			WriteColormap(ds, dict, @"pigmentColorMapTabView");
			AddWavesTypeFromPopup(ds, dict, @"pigmentFunctionWaveTypePopUpButton", @"pigmentFunctionWaveTypeEdit");
			writeTransformationsBeforeClosing=YES;
			writeQuickColorBeforeClosing=YES;
	
			break;
//cPigmentFullColorTab
		case cPigmentFullColorTab:
			//if ClosePigment than add tab
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"pigmentFullColorColorWell" andTitle:@"" comma:NO newLine:NO];
			if ( [[dict objectForKey:@"pigmentFullColorAddCommentOn"]intValue]==NSOnState)
				[ds appendTabAndFormat:@"\t//%@\n",[dict objectForKey:@"pigmentFullColorCommentTextField"]];
			else
				[ds copyText:@"\n"];
			writeTransformationsBeforeClosing=NO;
			writeQuickColorBeforeClosing=NO;
			break;
//cPigmentColorPatternTab
		case cPigmentColorPatternTab:
			switch( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue])
			{
	//cPigmentPatternBrick
				case cPigmentPatternBrick:
					[ds copyTabAndText:@"brick \n"];
					if (!WritingPattern)
					{
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternBrickMortarColor" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternBrickBrickColor" andTitle:@""  comma:NO newLine:YES];
					}	
					[ds appendTabAndFormat:@"brick_size <%@, %@, %@>\n",[dict objectForKey:@"pigmentColorPatternBrickBrickSizeMatrixX"],
																										[dict objectForKey:@"pigmentColorPatternBrickBrickSizeMatrixY"],
																										[dict objectForKey:@"pigmentColorPatternBrickBrickSizeMatrixZ"]];
					[ds appendTabAndFormat:@"mortar %@\n",[dict objectForKey:@"pigmentColorPatternBrickMortarEdit"]];
					
					break;
	//cPigmentPatternChecker
				case cPigmentPatternChecker:
					[ds copyTabAndText:@"checker \n"];
					if (!WritingPattern)
					{
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternCheckerColor1" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternCheckerColor2" andTitle:@""  comma:NO newLine:YES];
					}
					break;
	//cPigmentPatternHexagon
				case cPigmentPatternHexagon:
					[ds copyTabAndText:@"hexagon \n"];
					if (!WritingPattern)
					{
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternHexagonColor1" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternHexagonColor2" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternHexagonColor3" andTitle:@""  comma:NO newLine:YES];
					}
					break;
	//cPigmentPatternObject
				case cPigmentPatternObject:
					[ds copyTabAndText:@"object { \n"];
					[ds addTab];
					[ObjectTemplate createDescriptionWithDictionary:[dict objectForKey:@"pigmentColorPatternObject"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];

					if (!WritingPattern)
					{
						[ds copyTabAndText:@"//outside\n"];
						WritePigment(cForceNothing, ds, [dict objectForKey:@"pigmentColorPatternObjectOutsidePigment"], NO);
						[ds copyTabAndText:@",\n"];
						[ds copyTabAndText:@"//inside\n"];
						WritePigment(cForceNothing, ds, [dict objectForKey:@"pigmentColorPatternObjectInsidePigment"], NO);
					}
					break;
	//cPigmentPatternSquare
				case cPigmentPatternSquare:
					[ds copyTabAndText:@"square \n"];
					if (!WritingPattern)
					{
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternSquareColor1" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternSquareColor2" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternSquareColor3" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternSquareColor4" andTitle:@""  comma:NO newLine:YES];
					}
					break;	//cPigmentPatternTriangular
				case cPigmentPatternTriangular:
					[ds copyTabAndText:@"triangular \n"];
					if (!WritingPattern)
					{
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor1" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor2" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor3" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor4" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor5" andTitle:@""  comma:YES newLine:YES];
						[ds copyTabText];
						[ds addRGBColor:dict forKey:@"pigmentColorPatternTriangularColor6" andTitle:@""  comma:NO newLine:YES];
					}
					break;

	//cPigmentPatternAgate
				case cPigmentPatternAgate:
					[ds copyTabAndText:@"agate \n"];
					[ds appendTabAndFormat:@"agate_turb %@\n",[dict objectForKey:@"pigmentColorPatternAgateTurbEdit"]];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternAoi
				case cPigmentPatternAoi:
					[ds copyTabAndText:@"aoi"];
					[ds copyText:@"\n"];

					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;

	//cPigmentPatternDensityFile
				case cPigmentPatternDensityFile:
					[ds appendTabAndFormat:@"density_file df3 \"%@\"\n",[dict objectForKey:@"pigmentColorPatternDisityFileFileNameEdit"]];
					switch( [[dict objectForKey:@"pigmentColorPatternDisityFileInterpolationPopUp"]intValue])
					{
//						case 0:	[ds copyTabAndText:@"interpolate 0\t//none\n"];			break;
						case 2:	[ds copyTabAndText:@"interpolate 1\t//tri-linear\n"];	break;
						case 3:	[ds copyTabAndText:@"interpolate 2\t//tri_cubic\n"];	break;
					}
					
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");

					break;	
	//cPigmentPatternFractals
				case cPigmentPatternFractals:
					switch( [[dict objectForKey:@"pigmentColorPatternFractalsTypePopUp"]intValue])
					{			
						case cJulia: 					[ds copyTabAndText:@"julia "];						break;
						case cMagnet1Julia: 		[ds copyTabAndText:@"magnet 1 julia "]; 		break;
						case cMagnet2Julia: 		[ds copyTabAndText:@"magnet 2 julia "]; 		break;
						case cMagnet1Mandel:	[ds copyTabAndText:@"magnet 1 mandel "];	break;
						case cMagnet2Mandel:	[ds copyTabAndText:@"magnet 2 mandel "]; 	break;
						case cMandel:				[ds copyTabAndText:@"mandel "]; 					break;
					}
					switch( [[dict objectForKey:@"pigmentColorPatternFractalsTypePopUp"]intValue])
					{
						case cJulia: case cMagnet1Julia: case cMagnet2Julia: 
							[ds appendFormat:@"<%@, %@>, %@\n",[dict objectForKey:@"pigmentColorPatternFractalsTypeXEdit"],
																							[dict objectForKey:@"pigmentColorPatternFractalsTypeYEdit"],
																							[dict objectForKey:@"pigmentColorPatternFractalsMaxIterationsEdit"]];
							break;
						case cMagnet1Mandel: 
						case cMandel: 
						case cMagnet2Mandel: 
							[ds appendFormat:@"%@\n",[dict objectForKey:@"pigmentColorPatternFractalsMaxIterationsEdit"]];
							break;
					}
					switch( [[dict objectForKey:@"pigmentColorPatternFractalsTypePopUp"]intValue])
					{
						case cJulia: 
						case cMandel:
							if ( [[dict objectForKey:@"pigmentColorPatternFractalsExponentOn"]intValue]==NSOnState)
								[ds appendTabAndFormat:@"exponent %@\n",[dict objectForKey:@"pigmentColorPatternFractalsExponentEdit"]];
							break;
					}

					if ( [[dict objectForKey:@"pigmentColorPatternFractalsInteriorTypeOn"]intValue]==NSOnState)
					{
							[ds appendTabAndFormat:@"interior %d %@\n",[[dict objectForKey:@"pigmentColorPatternFractalsInteriorTypePopUp"]intValue],
							[dict objectForKey:@"pigmentColorPatternFractalsInteriorTypeFactorEdit"]];
					}
					if ( [[dict objectForKey:@"pigmentColorPatternFractalsExteriorTypeOn"]intValue]==NSOnState)
					{
							[ds appendTabAndFormat:@"exterior %d %@\n",[[dict objectForKey:@"pigmentColorPatternFractalsExteriorTypePopUp"]intValue],
							[dict objectForKey:@"pigmentColorPatternFractalsExteriorTypeFactorEdit"]];
					}
							

					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;

	//cPigmentPatternCrackle
				case cPigmentPatternCrackle:		//std
					[ds copyTabAndText:@"crackle\n"];
					for (int x=1; x<=4; x++)
					{
						if ( [[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dOn",x]]intValue]==NSOnState)
						{
							switch( [[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dPopUp",x]]intValue])
							{
								case cForm:		//form
									[ds appendTabAndFormat:@"form <%@, %@, %@>\n",
												[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dMatrixX",x]],
												[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dMatrixY",x]],
												[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dMatrixZ",x]]];
									break;
								case cMetric:	//metric
									[ds appendTabAndFormat:@"metric %@\n",[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dEdit",x]]];
									break;
								case cOffset:	//offset
									[ds appendTabAndFormat:@"offset %@\n",[dict objectForKey:[NSString stringWithFormat:@"pigmentColorPatternCrackleType%dEdit",x]]];
									break;
								case cSolid:
									[ds copyTabAndText:@"solid\n"];
									break;
							}
						}
					}		
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternImagePattern
				case cPigmentPatternImagePattern:
					[ds copyTabAndText:@"image_pattern {\n"];
					WritePatternPanel(ds, dict, @"pigmentColorPatternImagePatternFileTypePopUp", 
													@"pigmentColorPatternImagePatternFunctionImageWidth", @"pigmentColorPatternImagePatternFunctionImageHeight",
													@"pigmentColorPatternImagePatternFunctionFunctionEdit", @"pigmentImageMapPatternPigment",
													@"pigmentImageMapPigmentPigment" ,@"pigmentColorPatternImagePatternFileNameEdit");

					switch( [[dict objectForKey:@"pigmentColorPatternImageMapUsePopUp"]intValue])
					{
						case  cUseDefault: 	break;
						case cUseIndex:	[ds copyTabAndText:@"use_index\n"];	break;
						case cUseColor:	[ds copyTabAndText:@"use_color\n"];	break;
						case cUseAlpha:	[ds copyTabAndText:@"use_alpha\n"];	break;
					}
					
					switch( [[dict objectForKey:@"pigmentColorPatternImageMapProjectionPopUp"]intValue])
					{
						case cProjectionPlanar:						[ds copyTabAndText:@"map_type 0\t//planar\n"];				break;
						case cProjectionSpherical:				[ds copyTabAndText:@"map_type 1\t//spherical\n"];			break;
						case cProjectionCylindrical:			[ds copyTabAndText:@"map_type 2\t//cylindrical\n"];		break;
						case cProjection3:								break;
						case cProjection4:								break;
						case cProjectionTorus:						[ds copyTabAndText:@"map_type 5\t//torus\n"];						break;
						case cProjectionOmnidirectional:	[ds copyTabAndText:@"map_type 7\t//omnidirectional\n"];	break;
					}
					if ( [[dict objectForKey:@"pigmentColorPatternImageMapProjectionOnceOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"once\n"];

					switch( [[dict objectForKey:@"pigmentColorPatternImageMapInterpolationPopUp"]intValue])
					{
						case cInterpolationNone:								[ds copyTabAndText:@"interpolate 0\t//none\n"];									break;
						case cInterpolationBilinear:						[ds copyTabAndText:@"interpolate 2\t//bilinear\n"];							break;
						case cInterpolationBicubic:							[ds copyTabAndText:@"interpolate 3\t//bicubic\n"];							break;
						case cInterpolationNormilizedDistance:	[ds copyTabAndText:@"interpolate 4\t//normalized distance\n"];	break;
					}
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];

					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;

	//cPigmentPatternAverage
				case cPigmentPatternAverage:
					[ds copyTabAndText:@"average\n"];
					if (!WritingPattern)
						[BodymapTemplate createDescriptionWithDictionary:[dict objectForKey:@"pigmentColorPatternAverageEditPigment"] 
								andTabs:[ds currentTabs]extraParam:menuTagTemplatePigmentmap mutableTabString:ds];
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternPavementPattern
				case cPigmentPavement:
					[ds copyTabAndText:@"pavement {\n"];
					[ds addTab];
					switch ([[dict objectForKey:@"pigmentColorPatternPavementSidesPopUp"]intValue])
					{
						case 0:[ds copyTabAndText:@"number_of_sides 3\n"]; break;
						case 1:[ds copyTabAndText:@"number_of_sides 4\n"]; break;
						case 2:[ds copyTabAndText:@"number_of_sides 6\n"]; break;
					}
					[ds appendTabAndFormat:@"number_of_tiles %d\n",[[dict objectForKey:@"pigmentColorPatternPavementTilesPopUp"]intValue]+1];
					[ds appendTabAndFormat:@"pattern %d\n",[[dict objectForKey:@"pigmentColorPatternPavementPatternPopUp"]intValue]+1];
					if ([[dict objectForKey:@"pigmentColorPatternPavementSidesPopUp"]intValue ] != 2)
						[ds appendTabAndFormat:@"exterior %d\n",[[dict objectForKey:@"pigmentColorPatternPavementExteriorPopUp"]intValue]];
					
					[ds appendTabAndFormat:@"interior %d\n",[[dict objectForKey:@"pigmentColorPatternPavementInteriorPopUp"]intValue]];
					[ds appendTabAndFormat:@"form %d\n",[[dict objectForKey:@"pigmentColorPatternPavementFormPopUp"]intValue]];
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternPigmentPattern
				case cPigmentPatternPigmentPattern:
					[ds copyTabAndText:@"pigment_pattern {\n"];
					[ds addTab];
					WritePigment(cForceDontWrite, ds, [dict objectForKey:@"pigmentColorPatternPigmentPattern"], NO);
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
				case cPigmentPatternBoxed:				//std
				case cPigmentPatternBozo:					//std
				case cPigmentPatternBumps:				//std
				case cPigmentPatternCells:				//std
				case cPigmentPatternCylindrical:	//std
				case cPigmentPatternDents:				//std
				case cPigmentPatternGranite:			//std
				case cPigmentPatternLeopard:			//std
				case cPigmentPatternMarble:				//std
				case cPigmentPatternOnion:				//std
				case cPigmentPatternPlanar:				//std
				case cPigmentPatternRadial:				//std
				case cPigmentPatternRipples:			//std
				case cPigmentPatternSpherical:		//std
				case cPigmentPatternWaves:				//std
				case cPigmentPatternWood:					//std
				case cPigmentPatternWrinkles:			//std
					switch( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue])
					{
						case cPigmentPatternBoxed:				[ds copyTabAndText:@"boxed\n"];				break;
						case cPigmentPatternBozo:					[ds copyTabAndText:@"bozo\n"];				break;
						case cPigmentPatternBumps:				[ds copyTabAndText:@"bumps\n"];				break;
						case cPigmentPatternCells:				[ds copyTabAndText:@"cells\n"];				break;
						case cPigmentPatternCylindrical:	[ds copyTabAndText:@"cylindrical\n"];	break;
						case cPigmentPatternDents:				[ds copyTabAndText:@"dents\n"];				break;
						case cPigmentPatternGranite:			[ds copyTabAndText:@"granite\n"];			break;
						case cPigmentPatternLeopard:			[ds copyTabAndText:@"leopard\n"];			break;
						case cPigmentPatternMarble:				[ds copyTabAndText:@"marble\n"];			break;
						case cPigmentPatternOnion:				[ds copyTabAndText:@"onion\n"];				break;
						case cPigmentPatternPlanar:				[ds copyTabAndText:@"planar\n"];			break;
						case cPigmentPatternRadial:				[ds copyTabAndText:@"radial\n"];			break;
						case cPigmentPatternRipples:			[ds copyTabAndText:@"ripples\n"];			break;
						case cPigmentPatternSpherical:		[ds copyTabAndText:@"spherical\n"];		break;
						case cPigmentPatternWaves:				[ds copyTabAndText:@"waves\n"];				break;
						case cPigmentPatternWood:					[ds copyTabAndText:@"wood\n"];				break;
						case cPigmentPatternWrinkles:			[ds copyTabAndText:@"wrinkles\n"];		break;
					}
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;				
	//cPigmentPatternSlope
				case cPigmentPatternSlope:
					[ds copyTabAndText:@"slope {\n"];
					[ds addTab];
					[ds copyTabText];
					[ds addXYZVector:dict popup:@"pigmentColorPatternSlopeDirectionXYZPopUp" xKey:@"pigmentColorPatternSlopeDirectionMatrixX" 
													yKey:@"pigmentColorPatternSlopeDirectionMatrixY" zKey:@"pigmentColorPatternSlopeDirectionMatrixZ"];
					if ( [[dict objectForKey:@"pigmentColorPatternSlopeSlopeOn"]intValue]==NSOnState)
					{

						[ds appendTabAndFormat:@", %@, %@\n",[dict objectForKey:@"pigmentColorPatternSlopeSlopeLowEdit"],
																					[dict objectForKey:@"pigmentColorPatternSlopeSlopeHighEdit"]];
					}
					else
						[ds copyText:@"\n"];
													
					if ( [[dict objectForKey:@"pigmentColorPatternSlopeAltitudeOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"altitude "];
						[ds addXYZVector:dict popup:@"pigmentColorPatternSlopeAltitudeXYZPopUp" xKey:@"pigmentColorPatternSlopeAltitudeMatrixX" 
														yKey:@"pigmentColorPatternSlopeAltitudeMatrixY" zKey:@"pigmentColorPatternSlopeAltitudeMatrixZ"];
						if ( [[dict objectForKey:@"pigmentColorPatternSlopeOffsetOn"]intValue]==NSOnState)
						{
							[ds appendTabAndFormat:@", %@, %@\n",[dict objectForKey:@"pigmentColorPatternSlopeOffsetLowEdit"],
																						[dict objectForKey:@"pigmentColorPatternSlopeOffsetHighEdit"]];
						}
						else
							[ds copyText:@"\n"];
						
					}
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternGradient
				case cPigmentPatternGradient:
					[ds copyTabAndText:@"gradient "];
					[ds addXYZVector:dict popup:@"pigmentColorPatternGradientXYZPopUp" xKey:@"pigmentColorPatternGradientMatrixX" 
														yKey:@"pigmentColorPatternGradientMatrixY" zKey:@"pigmentColorPatternGradientMatrixZ"];
					[ds copyText:@"\n"];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternQuilted
				case cPigmentPatternQuilted:
					[ds copyTabAndText:@"quilted\n"];	
					[ds appendTabAndFormat:@"control0 %@\n",[dict objectForKey:@"pigmentColorPatternQuiltedControl0Edit"]];
					[ds appendTabAndFormat:@"control1 %@\n",[dict objectForKey:@"pigmentColorPatternQuiltedControl1Edit"]];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;				
	//cPigmentPatternSpiral
				case cPigmentPatternSpiral:
					switch( [[dict objectForKey:@"pigmentColorPatternSpiralTypePopUp"]intValue])
					{
						case 0:
							[ds appendTabAndFormat:@"spiral1 %@\n",[dict objectForKey:@"pigmentColorPatternSpiralNrOfArmsEdit"]];
							break;
						case 1:
							[ds appendTabAndFormat:@"spiral2 %@\n",[dict objectForKey:@"pigmentColorPatternSpiralNrOfArmsEdit"]];
							break;
					}
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
	//cPigmentPatternTiling
				case cPigmentPatternTiling:
					[ds appendTabAndFormat:@"tiling %d\n",[[dict objectForKey:@"pigmentColorPatterTilingTypePopUp"]intValue]+1];
					if (!WritingPattern)
						WriteColormap(ds, dict, @"pigmentColorMapTabView");
					AddWavesTypeFromPopup(ds, dict, @"pigmentColorPatternWaveTypePopUpButton", @"pigmentColorPatternWaveTypeEdit");
					break;
			}	//switch pattern panel
			writeTransformationsBeforeClosing=YES;
			writeQuickColorBeforeClosing=YES;



	}	//switch main panel

	//now write transformations and quickcolor i
	if ( writeTransformationsBeforeClosing ==YES)
	{
		if ( [[dict objectForKey:@"pigmentTransformationsOn"]intValue]==NSOnState)
		{
			[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"pigmentTransformations"]
					andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
		}
	}
	if (writeQuickColorBeforeClosing==YES)
	{
		if ( [[dict objectForKey:@"pigmentQuickColorOn"]intValue]==NSOnState)
		{
			[ds copyTabText];
			[ds addRGBColor:dict forKey:@"pigmentQuickColorColorWell" andTitle:@"quick_color " comma:NO newLine:YES];
		}
	}	

	if ( [[dict objectForKey:@"pigmentDontWrapInPigment"]intValue]==NSOffState)
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
	NSDictionary *initialDefaults=[PigmentTemplate createDefaults:menuTagTemplatePigment];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"pigmentDefaultSettings",
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
	//customized color map is in a dictionary because
	// we use it as preferences for the color map template
	// rainbow and b&w are not editable so they can be in colormap format directly
		[NSDictionary dictionaryWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:[colormap standardMapWithView:nil]],@"colormap",nil],	@"customizedColorMap",
		[NSArchiver archivedDataWithRootObject:[colormap rainbowMapWithView:nil]],										@"rainbowColorMap",
		[NSArchiver archivedDataWithRootObject:[colormap blackAndWhiteMapWithView:nil]],							@"blackAndWhiteColorMap",
		[NSNumber numberWithInt:0],															@"pigmentColorMapTabView",
		[NSNumber numberWithInt:NSOffState],										@"pigmentDontWrapInPigment",
		[NSNumber numberWithInt:cPigmentFullColorTab],					@"pigmentMainTabView",
		[NSNumber numberWithInt:NSOffState],										@"pigmentTransformationsOn",
		[NSNumber numberWithInt:NSOffState],										@"pigmentQuickColorOn",
		[NSArchiver archivedDataWithRootObject:[MPFTColorWell redColorAndFilter:YES]], 	@"pigmentQuickColorColorWell",
		//full color
		[NSArchiver archivedDataWithRootObject:[MPFTColorWell blueColorAndFilter:YES]], 	@"pigmentFullColorColorWell",
		[NSNumber numberWithInt:NSOffState],									@"pigmentFullColorAddCommentOn",
		@"",																									@"pigmentFullColorCommentTextField",
		//color pattern
		[NSNumber numberWithInt:cPigmentPatternBrick],				@"pigmentColorPatternSelectPopUpButton",
		[NSNumber numberWithInt:cDefault],										@"pigmentColorPatternWaveTypePopUpButton",
		@"0.0",																								@"pigmentColorPatternWaveTypeEdit",
			//brick*******************************************************************************************************
				@"8.0",																						@"pigmentColorPatternBrickBrickSizeMatrixX",
				@"3.0",																						@"pigmentColorPatternBrickBrickSizeMatrixY",
				@"4.5",																						@"pigmentColorPatternBrickBrickSizeMatrixZ",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell redColorAndFilter:YES]], 	@"pigmentColorPatternBrickBrickColor",
				@"0.5",																						@"pigmentColorPatternBrickMortarEdit",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell grayColorAndFilter:YES]], 	@"pigmentColorPatternBrickMortarColor",
				//checker****************************************************************************************************
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell blueColorAndFilter:YES]], 	@"pigmentColorPatternCheckerColor1",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell greenColorAndFilter:YES]],	@"pigmentColorPatternCheckerColor2",
				//hexagon***************************************************************************************************
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell redColorAndFilter:YES]], 	@"pigmentColorPatternHexagonColor1",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell greenColorAndFilter:YES]],	@"pigmentColorPatternHexagonColor2",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell blueColorAndFilter:YES]],	@"pigmentColorPatternHexagonColor3",
				//object******************************************************************************************************
				//square***************************************************************************************************
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell redColorAndFilter:YES]], 	@"pigmentColorPatternSquareColor1",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell blueColorAndFilter:YES]],	@"pigmentColorPatternSquareColor2",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell yellowColorAndFilter:YES]],	@"pigmentColorPatternSquareColor3",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell greenColorAndFilter:YES]],	@"pigmentColorPatternSquareColor4",
				//triangular***************************************************************************************************
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell redColorAndFilter:YES]], 	@"pigmentColorPatternTriangularColor1",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell blueColorAndFilter:YES]],	@"pigmentColorPatternTriangularColor2",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell cyanColorAndFilter:YES]],	@"pigmentColorPatternTriangularColor3",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell magentaColorAndFilter:YES]],	@"pigmentColorPatternTriangularColor4",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell yellowColorAndFilter:YES]],	@"pigmentColorPatternTriangularColor5",
				[NSArchiver archivedDataWithRootObject:[MPFTColorWell greenColorAndFilter:YES]],	@"pigmentColorPatternTriangularColor6",
				//agate*******************************************************************************************************
				@"1.0",																					@"pigmentColorPatternAgateTurbEdit",
				//aoi*******************************************************************************************************
				//crackle******************************************************************************************************
				[NSNumber numberWithInt:NSOnState],							@"pigmentColorPatternCrackleType1On",
				[NSNumber numberWithInt:cForm],									@"pigmentColorPatternCrackleType1PopUp",
				@"-1.0",																				@"pigmentColorPatternCrackleType1MatrixX",
				@"1.1",																					@"pigmentColorPatternCrackleType1MatrixY",
				@"0",																						@"pigmentColorPatternCrackleType1MatrixZ",
				@"2",																						@"pigmentColorPatternCrackleType1Edit",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternCrackleType2On",
				[NSNumber numberWithInt:cMetric],								@"pigmentColorPatternCrackleType2PopUp",
				@"-1.0",																				@"pigmentColorPatternCrackleType2MatrixX",
				@"1.1",																					@"pigmentColorPatternCrackleType2MatrixY",
				@"0",																						@"pigmentColorPatternCrackleType2MatrixZ",
				@"2",																						@"pigmentColorPatternCrackleType2Edit",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternCrackleType3On",
				[NSNumber numberWithInt:cOffset],								@"pigmentColorPatternCrackleType3PopUp",
				@"-1.0",																				@"pigmentColorPatternCrackleType3MatrixX",
				@"1.1",																					@"pigmentColorPatternCrackleType3MatrixY",
				@"0",																						@"pigmentColorPatternCrackleType3MatrixZ",
				@"2",																						@"pigmentColorPatternCrackleType3Edit",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternCrackleType4On",
				[NSNumber numberWithInt:cSolid],								@"pigmentColorPatternCrackleType4PopUp",
				@"-1.0",																				@"pigmentColorPatternCrackleType4MatrixX",
				@"1.1",																					@"pigmentColorPatternCrackleType4MatrixY",
				@"0",																						@"pigmentColorPatternCrackleType4MatrixZ",
				@"2",																						@"pigmentColorPatternCrackleType4Edit",
				//density file***************************************************************************************************
				[NSNumber numberWithInt:0],											@"pigmentColorPatternDisityFileInterpolationPopUp",
				@"MyFile",																			@"pigmentColorPatternDisityFileFileNameEdit",
				//fractals*******************************************************************************************************
				[NSNumber numberWithInt:cJulia],								@"pigmentColorPatternFractalsTypePopUp",
				@"0.35",																				@"pigmentColorPatternFractalsTypeXEdit",
				@"0.28",																				@"pigmentColorPatternFractalsTypeYEdit",
				[NSNumber numberWithInt:NSOnState],							@"pigmentColorPatternFractalsExponentOn",
				@"2",																						@"pigmentColorPatternFractalsExponentEdit",
				@"25",																					@"pigmentColorPatternFractalsMaxIterationsEdit",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternFractalsInteriorTypeOn",
				[NSNumber numberWithInt:cType0],								@"pigmentColorPatternFractalsInteriorTypePopUp",
				@"1",																						@"pigmentColorPatternFractalsInteriorTypeFactorEdit",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternFractalsExteriorTypeOn",
				[NSNumber numberWithInt:cType0],								@"pigmentColorPatternFractalsExteriorTypePopUp",
				@"1",																						@"pigmentColorPatternFractalsExteriorTypeFactorEdit",
				//gradient*******************************************************************************************************
				[NSNumber numberWithInt:cXYZVectorPopupY],			@"pigmentColorPatternGradientXYZPopUp",
				@"1.0",																					@"pigmentColorPatternGradientMatrixX",
				@"1.0",																					@"pigmentColorPatternGradientMatrixY",
				@"1.0",																					@"pigmentColorPatternGradientMatrixZ",
				//image pattern*************************************************************************************************
				[NSNumber numberWithInt:cGif],									@"pigmentColorPatternImagePatternFileTypePopUp",
				@"MyFile",																			@"pigmentColorPatternImagePatternFileNameEdit",
				@"x+y+z",																				@"pigmentColorPatternImagePatternFunctionFunctionEdit",
				@"300",																					@"pigmentColorPatternImagePatternFunctionImageWidth",
				@"300",																					@"pigmentColorPatternImagePatternFunctionImageHeight",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternImageMapProjectionOnceOn",
				[NSNumber numberWithInt:cProjectionPlanar],			@"pigmentColorPatternImageMapProjectionPopUp",
				[NSNumber numberWithInt:cInterpolationNone],		@"pigmentColorPatternImageMapInterpolationPopUp",
				[NSNumber numberWithInt:cUseDefault],						@"pigmentColorPatternImageMapUsePopUp",

				//pavement*******************************************************************************************************
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementSidesPopUp",
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementTilesPopUp",
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementPatternPopUp",
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementFormPopUp",
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementInteriorPopUp",
				[NSNumber numberWithInt:0],											@"pigmentColorPatternPavementExteriorPopUp",
				
				//quilted*******************************************************************************************************
				@"0.33",																				@"pigmentColorPatternQuiltedControl0Edit",
				@"1.33",																				@"pigmentColorPatternQuiltedControl1Edit",
				//slope*******************************************************************************************************
				[NSNumber numberWithInt:cXYZVectorPopupY],			@"pigmentColorPatternSlopeDirectionXYZPopUp",
				@"1.0",																					@"pigmentColorPatternSlopeDirectionMatrixX",
				@"1.0",																					@"pigmentColorPatternSlopeDirectionMatrixY",
				@"1.0",																					@"pigmentColorPatternSlopeDirectionMatrixZ",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternSlopeSlopeOn",
				@"0.0",																					@"pigmentColorPatternSlopeSlopeLowEdit",	
				@"1.0",																					@"pigmentColorPatternSlopeSlopeHighEdit",	
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternSlopeAltitudeOn",
				[NSNumber numberWithInt:cXYZVectorPopupY],			@"pigmentColorPatternSlopeAltitudeXYZPopUp",
				@"1.0",																					@"pigmentColorPatternSlopeAltitudeMatrixX",
				@"1.0",																					@"pigmentColorPatternSlopeAltitudeMatrixY",
				@"1.0",																					@"pigmentColorPatternSlopeAltitudeMatrixZ",
				[NSNumber numberWithInt:NSOffState],						@"pigmentColorPatternSlopeOffsetOn",
				@"0.0",																					@"pigmentColorPatternSlopeOffsetLowEdit",	
				@"1.0",																					@"pigmentColorPatternSlopeOffsetHighEdit",	
				//spiral*******************************************************************************************************
				[NSNumber numberWithInt:0],											@"pigmentColorPatternSpiralTypePopUp",
				@"2",																						@"pigmentColorPatternSpiralNrOfArmsEdit",
				//Tiling*******************************************************************************************************
				[NSNumber numberWithInt:4],											@"pigmentColorPatterTilingTypePopUp",
	  	//pigment image_map
		[NSNumber numberWithInt:cGif],												@"pigmentImageMapFileTypePopUp",
		@"MyFile",																						@"pigmentImageMapFileName",
		@"x+y+z",																							@"pigmentImageMapFunctionEdit",
		@"300",																								@"pigmentImageMapFunctionImageWidth",
		@"300",																								@"pigmentImageMapFunctionImageHeight",
		[NSNumber numberWithInt:NSOffState],									@"pigmentImageMapProjectionOnceOn",
		[NSNumber numberWithInt:cProjectionPlanar],						@"pigmentImageMapProjectionPopUp",
		[NSNumber numberWithInt:cInterpolationNone],					@"pigmentImageMapInterpolationPopUp",
		[NSNumber numberWithInt:NSOffState],									@"pigmentImageMapFilerAllOn",
		@"1.0",																								@"pigmentImageMapFilterAllEdit",
		[NSNumber numberWithInt:NSOffState],									@"pigmentImageMapTransmitAllOn",
		@"1.0",																								@"pigmentImageMapTransmitAllEdit",
	//pigment function
		@"x+y+z",																							@"pigmentFunctionEdit",
		[NSNumber numberWithInt:cDefault],										@"pigmentFunctionWaveTypePopUpButton",
		@"0.0",																								@"pigmentFunctionWaveTypeEdit",

	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	[pigmentImageMapProjectionPopUp setAutoenablesItems:NO];
	[pigmentColorPatternImageMapProjectionPopUp setAutoenablesItems:NO];
	NSView *dummyView=[[[NSView alloc]init]autorelease];	//not used, to fill empty spots in array
	// disable some items from the projection popup in image map
	[[pigmentImageMapProjectionPopUp itemAtIndex:cProjection3]setEnabled:NO];
	[[pigmentImageMapProjectionPopUp itemAtIndex:cProjection4]setEnabled:NO];
	[[pigmentImageMapProjectionPopUp itemAtIndex:cProjection6]setEnabled:NO];
	[[pigmentColorPatternImageMapProjectionPopUp itemAtIndex:cProjection3]setEnabled:NO];
	[[pigmentColorPatternImageMapProjectionPopUp itemAtIndex:cProjection4]setEnabled:NO];
	[[pigmentColorPatternImageMapProjectionPopUp itemAtIndex:cProjection6]setEnabled:NO];

	mPigmentPatternColormapViewArray=[NSArray arrayWithObjects:
		/*cPigmentPatternBrick					=0,*/		dummyView,	//brick
		/*cPigmentPatternChecker				=1,*/		dummyView, 	//checker
		/*cPigmentPatternHexagon				=2,*/		dummyView,	//hexagon
		/*cPigmentPatternObject					=3,*/		dummyView,	//object
		/*cPigmentPatternSquare					=4,*/		dummyView,	//square
		/*cPigmentPatternTriangular			=4,*/		dummyView,	//triangular
		/*line1													=4,*/		dummyView,	//line1
		/*cPigmentPatternAgate					=5,*/		pigmentColorPatternAgateColorMapView,
		/*cPigmentPatternAoi						=6,*/		pigmentColorPatternAoiColorMapView,
		/*cPigmentPatternBoxed					=7,*/		pigmentColorPatternBoxedColorMapView,
		/*cPigmentPatternBozo						=8,*/		pigmentColorPatternBozoColorMapView,
		/*cPigmentPatternBumps					=9,*/		pigmentColorPatternBumpsColorMapView,
		/*cPigmentPatternCells					=10,*/		pigmentColorPatternCellsColorMapView,
		/*cPigmentPatternCrackle				=11,*/		pigmentColorPatternCrackleColorMapView,
		/*cPigmentPatternCylindrical		=12,*/		pigmentColorPatternCylindricalColorMapView,
		/*cPigmentPatternDensityFile		=13,*/		pigmentColorPatternDensityFileColorMapView,
		/*cPigmentPatternDents					=14,*/		pigmentColorPatternDentsColorMapView,
		/*cPigmentPatternFractals				=15,*/		pigmentColorPatternFractalsColorMapView,
		/*cPigmentPatternGradient				=16,*/		pigmentColorPatternGradientColorMapView,
		/*cPigmentPatternGranite				=17,*/		pigmentColorPatternGraniteColorMapView,
		/*cPigmentPatternImagePattern		=18,*/		pigmentColorPatternImagePatternColorMapView,
		/*cPigmentPatternLeopard				=19,*/		pigmentColorPatternLeopardColorMapView,
		/*cPigmentPatternMarble					=20,*/		pigmentColorPatternMarbleColorMapView,
		/*cPigmentPatternOnion					=21,*/		pigmentColorPatternOnionColorMapView,
		/*cPigmentPatternPavement				=22,*/		pigmentColorPatternOnionColorMapView,
		/*cPigmentPatternPigmentPattern	=23,*/		pigmentColorPatternPigmentPatternColorMapView,
		/*cPigmentPatternPlanar					=24,*/		pigmentColorPatternPlanarColorMapView,
		/*cPigmentPatternQuilted				=25,*/		pigmentColorPatternQuiltedColorMapView,
		/*cPigmentPatternRadial					=26,*/		pigmentColorPatternRadialColorMapView,
		/*cPigmentPatternRipples				=27,*/		pigmentColorPatternRipplesColorMapView,
		/*cPigmentPatternSlope					=28,*/		pigmentColorPatternSlopeColorMapView,
		/*cPigmentPatternSpherical			=29,*/		pigmentColorPatternSphericalColorMapView,
		/*cPigmentPatternSpiral					=30,*/		pigmentColorPatternSpiralColorMapView,
		/*cPigmentPatternTiling					=31,*/		pigmentColorPatternTilingColorMapView,
		/*cPigmentPatternWaves					=32,*/		pigmentColorPatternWavesColorMapView,
		/*cPigmentPatternWood						=33,*/		pigmentColorPatternWoodColorMapView,
		/*cPigmentPatternWrinkles				=34,*/		pigmentColorPatternWrinklesColorMapView,
		/*line2													=35,*/		dummyView,	//line2
		/*cPigmentPatternAverage				=36,*/		dummyView,	//average
		// pigmentFunction also has a color map
		pigmentFunctionColorMapView,
	nil	];
	[mPigmentPatternColormapViewArray retain];

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		pigmentMainTabView,																				@"pigmentMainTabView",
		pigmentColorMapTabView,																		@"pigmentColorMapTabView",

		pigmentTransformationsOn,																	@"pigmentTransformationsOn",
		pigmentDontWrapInPigment,																	@"pigmentDontWrapInPigment",
		pigmentQuickColorOn,																			@"pigmentQuickColorOn",
		pigmentQuickColorColorWell,																@"pigmentQuickColorColorWell",
		pigmentFullColorColorWell,																@"pigmentFullColorColorWell",
		pigmentFullColorAddCommentOn,															@"pigmentFullColorAddCommentOn",
		pigmentFullColorCommentTextField,													@"pigmentFullColorCommentTextField",
		pigmentColorPatternSelectPopUpButton,											@"pigmentColorPatternSelectPopUpButton",
		pigmentColorPatternWaveTypePopUpButton,										@"pigmentColorPatternWaveTypePopUpButton",
		pigmentColorPatternWaveTypeEdit,													@"pigmentColorPatternWaveTypeEdit",

		[pigmentColorPatternBrickBrickSizeMatrix cellWithTag:0],	@"pigmentColorPatternBrickBrickSizeMatrixX",
		[pigmentColorPatternBrickBrickSizeMatrix cellWithTag:1],	@"pigmentColorPatternBrickBrickSizeMatrixY",
		[pigmentColorPatternBrickBrickSizeMatrix cellWithTag:2],	@"pigmentColorPatternBrickBrickSizeMatrixZ",
		pigmentColorPatternBrickBrickColor,												@"pigmentColorPatternBrickBrickColor",
		pigmentColorPatternBrickMortarEdit,												@"pigmentColorPatternBrickMortarEdit",
		pigmentColorPatternBrickMortarColor,											@"pigmentColorPatternBrickMortarColor",
		pigmentColorPatternCheckerColor1,													@"pigmentColorPatternCheckerColor1",
		pigmentColorPatternCheckerColor2,													@"pigmentColorPatternCheckerColor2",
		pigmentColorPatternHexagonColor1,													@"pigmentColorPatternHexagonColor1",
		pigmentColorPatternHexagonColor2,													@"pigmentColorPatternHexagonColor2",
		pigmentColorPatternHexagonColor3,													@"pigmentColorPatternHexagonColor3",

		pigmentColorPatternSquareColor1,													@"pigmentColorPatternSquareColor1",
		pigmentColorPatternSquareColor2,													@"pigmentColorPatternSquareColor2",
		pigmentColorPatternSquareColor3,													@"pigmentColorPatternSquareColor3",
		pigmentColorPatternSquareColor4,													@"pigmentColorPatternSquareColor4",

		pigmentColorPatternTriangularColor1,											@"pigmentColorPatternTriangularColor1",
		pigmentColorPatternTriangularColor2,											@"pigmentColorPatternTriangularColor2",
		pigmentColorPatternTriangularColor3,											@"pigmentColorPatternTriangularColor3",
		pigmentColorPatternTriangularColor4,											@"pigmentColorPatternTriangularColor4",
		pigmentColorPatternTriangularColor5,											@"pigmentColorPatternTriangularColor5",
		pigmentColorPatternTriangularColor6,											@"pigmentColorPatternTriangularColor6",


		pigmentColorPatternAgateTurbEdit,													@"pigmentColorPatternAgateTurbEdit",
		pigmentColorPatternCrackleType1On,												@"pigmentColorPatternCrackleType1On",
		pigmentColorPatternCrackleType1PopUp,											@"pigmentColorPatternCrackleType1PopUp",
		[pigmentColorPatternCrackleType1Matrix cellWithTag:0],		@"pigmentColorPatternCrackleType1MatrixX",
		[pigmentColorPatternCrackleType1Matrix cellWithTag:1],		@"pigmentColorPatternCrackleType1MatrixY",
		[pigmentColorPatternCrackleType1Matrix cellWithTag:2],		@"pigmentColorPatternCrackleType1MatrixZ",
		pigmentColorPatternCrackleType1Edit,											@"pigmentColorPatternCrackleType1Edit",
		pigmentColorPatternCrackleType2On,												@"pigmentColorPatternCrackleType2On",
		pigmentColorPatternCrackleType2PopUp,											@"pigmentColorPatternCrackleType2PopUp",
		[pigmentColorPatternCrackleType2Matrix cellWithTag:0],		@"pigmentColorPatternCrackleType2MatrixX",
		[pigmentColorPatternCrackleType2Matrix cellWithTag:1],		@"pigmentColorPatternCrackleType2MatrixY",
		[pigmentColorPatternCrackleType2Matrix cellWithTag:2],		@"pigmentColorPatternCrackleType2MatrixZ",
		pigmentColorPatternCrackleType2Edit,											@"pigmentColorPatternCrackleType2Edit",
		pigmentColorPatternCrackleType3On,												@"pigmentColorPatternCrackleType3On",
		pigmentColorPatternCrackleType3PopUp,											@"pigmentColorPatternCrackleType3PopUp",
		[pigmentColorPatternCrackleType3Matrix cellWithTag:0],		@"pigmentColorPatternCrackleType3MatrixX",
		[pigmentColorPatternCrackleType3Matrix cellWithTag:1],		@"pigmentColorPatternCrackleType3MatrixY",
		[pigmentColorPatternCrackleType3Matrix cellWithTag:2],		@"pigmentColorPatternCrackleType3MatrixZ",
		pigmentColorPatternCrackleType3Edit,											@"pigmentColorPatternCrackleType3Edit",
		pigmentColorPatternCrackleType4On,												@"pigmentColorPatternCrackleType4On",
		pigmentColorPatternCrackleType4PopUp,											@"pigmentColorPatternCrackleType4PopUp",
		[pigmentColorPatternCrackleType4Matrix cellWithTag:0],		@"pigmentColorPatternCrackleType4MatrixX",
		[pigmentColorPatternCrackleType4Matrix cellWithTag:1],		@"pigmentColorPatternCrackleType4MatrixY",
		[pigmentColorPatternCrackleType4Matrix cellWithTag:2],		@"pigmentColorPatternCrackleType4MatrixZ",
		pigmentColorPatternCrackleType4Edit,											@"pigmentColorPatternCrackleType4Edit",
		pigmentColorPatternDisityFileInterpolationPopUp,					@"pigmentColorPatternDisityFileInterpolationPopUp",
		pigmentColorPatternDisityFileFileNameEdit,								@"pigmentColorPatternDisityFileFileNameEdit",
		pigmentColorPatternFractalsTypePopUp,											@"pigmentColorPatternFractalsTypePopUp",
		pigmentColorPatternFractalsTypeXEdit,											@"pigmentColorPatternFractalsTypeXEdit",
		pigmentColorPatternFractalsTypeYEdit,											@"pigmentColorPatternFractalsTypeYEdit",
		pigmentColorPatternFractalsExponentOn,										@"pigmentColorPatternFractalsExponentOn",
		pigmentColorPatternFractalsExponentEdit,									@"pigmentColorPatternFractalsExponentEdit",
		pigmentColorPatternFractalsMaxIterationsEdit,							@"pigmentColorPatternFractalsMaxIterationsEdit",
		pigmentColorPatternFractalsInteriorTypeOn,								@"pigmentColorPatternFractalsInteriorTypeOn",
		pigmentColorPatternFractalsInteriorTypePopUp,							@"pigmentColorPatternFractalsInteriorTypePopUp",
		pigmentColorPatternFractalsInteriorTypeFactorEdit,				@"pigmentColorPatternFractalsInteriorTypeFactorEdit",
		pigmentColorPatternFractalsExteriorTypeOn,								@"pigmentColorPatternFractalsExteriorTypeOn",
		pigmentColorPatternFractalsExteriorTypePopUp,							@"pigmentColorPatternFractalsExteriorTypePopUp",
		pigmentColorPatternFractalsExteriorTypeFactorEdit,				@"pigmentColorPatternFractalsExteriorTypeFactorEdit",
		pigmentColorPatternGradientXYZPopUp,											@"pigmentColorPatternGradientXYZPopUp",
		[pigmentColorPatternGradientMatrix cellWithTag:0],				@"pigmentColorPatternGradientMatrixX",
		[pigmentColorPatternGradientMatrix cellWithTag:1],				@"pigmentColorPatternGradientMatrixY",
		[pigmentColorPatternGradientMatrix cellWithTag:2],				@"pigmentColorPatternGradientMatrixZ",
		pigmentColorPatternImagePatternFileTypePopUp,							@"pigmentColorPatternImagePatternFileTypePopUp",
		pigmentColorPatternImagePatternFileNameEdit,							@"pigmentColorPatternImagePatternFileNameEdit",
		pigmentColorPatternImagePatternFunctionFunctionEdit,			@"pigmentColorPatternImagePatternFunctionFunctionEdit",
		pigmentColorPatternImagePatternFunctionImageWidth,				@"pigmentColorPatternImagePatternFunctionImageWidth",
		pigmentColorPatternImagePatternFunctionImageHeight,				@"pigmentColorPatternImagePatternFunctionImageHeight",
		pigmentColorPatternImageMapProjectionOnceOn,							@"pigmentColorPatternImageMapProjectionOnceOn",
		pigmentColorPatternImageMapProjectionPopUp,								@"pigmentColorPatternImageMapProjectionPopUp",
		pigmentColorPatternImageMapInterpolationPopUp,						@"pigmentColorPatternImageMapInterpolationPopUp",
		pigmentColorPatternImageMapUsePopUp,											@"pigmentColorPatternImageMapUsePopUp",
		pigmentColorPatternQuiltedControl0Edit,										@"pigmentColorPatternQuiltedControl0Edit",
		pigmentColorPatternQuiltedControl1Edit,										@"pigmentColorPatternQuiltedControl1Edit",

		pigmentColorPatternPavementSidesPopUp,										@"pigmentColorPatternPavementSidesPopUp",
		pigmentColorPatternPavementTilesPopUp,										@"pigmentColorPatternPavementTilesPopUp",
		pigmentColorPatternPavementPatternPopUp,									@"pigmentColorPatternPavementPatternPopUp",
		pigmentColorPatternPavementFormPopUp,											@"pigmentColorPatternPavementFormPopUp",
		pigmentColorPatternPavementInteriorPopUp,									@"pigmentColorPatternPavementInteriorPopUp",
		pigmentColorPatternPavementExteriorPopUp,									@"pigmentColorPatternPavementExteriorPopUp",


		pigmentColorPatternSlopeDirectionXYZPopUp,								@"pigmentColorPatternSlopeDirectionXYZPopUp",
		[pigmentColorPatternSlopeDirectionMatrix cellWithTag:0],	@"pigmentColorPatternSlopeDirectionMatrixX",
		[pigmentColorPatternSlopeDirectionMatrix cellWithTag:1],	@"pigmentColorPatternSlopeDirectionMatrixY",
		[pigmentColorPatternSlopeDirectionMatrix cellWithTag:2],	@"pigmentColorPatternSlopeDirectionMatrixZ",
		pigmentColorPatternSlopeSlopeOn,													@"pigmentColorPatternSlopeSlopeOn",
		pigmentColorPatternSlopeSlopeLowEdit,											@"pigmentColorPatternSlopeSlopeLowEdit",
		pigmentColorPatternSlopeSlopeHighEdit,										@"pigmentColorPatternSlopeSlopeHighEdit",
		pigmentColorPatternSlopeAltitudeOn,												@"pigmentColorPatternSlopeAltitudeOn",
		pigmentColorPatternSlopeAltitudeXYZPopUp,									@"pigmentColorPatternSlopeAltitudeXYZPopUp",
		[pigmentColorPatternSlopeAltitudeMatrix cellWithTag:0],		@"pigmentColorPatternSlopeAltitudeMatrixX",
		[pigmentColorPatternSlopeAltitudeMatrix cellWithTag:1],		@"pigmentColorPatternSlopeAltitudeMatrixY",
		[pigmentColorPatternSlopeAltitudeMatrix cellWithTag:2],		@"pigmentColorPatternSlopeAltitudeMatrixZ",
		pigmentColorPatternSlopeOffsetOn,													@"pigmentColorPatternSlopeOffsetOn",
		pigmentColorPatternSlopeOffsetLowEdit,										@"pigmentColorPatternSlopeOffsetLowEdit",
		pigmentColorPatternSlopeOffsetHighEdit,										@"pigmentColorPatternSlopeOffsetHighEdit",
		pigmentColorPatternSpiralTypePopUp,												@"pigmentColorPatternSpiralTypePopUp",
		pigmentColorPatterTilingTypePopUp,												@"pigmentColorPatterTilingTypePopUp",
		pigmentColorPatternSpiralNrOfArmsEdit,										@"pigmentColorPatternSpiralNrOfArmsEdit",
  	pigmentImageMapFileTypePopUp,															@"pigmentImageMapFileTypePopUp",
		pigmentImageMapFileName,																	@"pigmentImageMapFileName",
		pigmentImageMapFunctionEdit,															@"pigmentImageMapFunctionEdit",
		pigmentImageMapFunctionImageWidth,												@"pigmentImageMapFunctionImageWidth",
		pigmentImageMapFunctionImageHeight,												@"pigmentImageMapFunctionImageHeight",
		pigmentImageMapProjectionPopUp,														@"pigmentImageMapProjectionPopUp",
		pigmentImageMapInterpolationPopUp,												@"pigmentImageMapInterpolationPopUp",
		pigmentImageMapFilerAllOn,																@"pigmentImageMapFilerAllOn",
		pigmentImageMapFilterAllEdit,															@"pigmentImageMapFilterAllEdit",
		pigmentImageMapTransmitAllOn,															@"pigmentImageMapTransmitAllOn",
		pigmentImageMapTransmitAllEdit,														@"pigmentImageMapTransmitAllEdit",
		pigmentImageMapProjectionOnceOn,													@"pigmentImageMapProjectionOnceOn",
		pigmentFunctionEdit,																			@"pigmentFunctionEdit",
		pigmentFunctionWaveTypePopUpButton,												@"pigmentFunctionWaveTypePopUpButton",
		pigmentFunctionWaveTypeEdit,															@"pigmentFunctionWaveTypeEdit",

	nil] ;
	
	[mOutlets retain];
	
	[ToolTipAutomator setTooltips:@"pigmentLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"pigmentLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			pigmentColorPatternBrickBrickSizeMatrix,	@"pigmentColorPatternBrickBrickSizeMatrix",
			pigmentTransformationsEditButton,					@"pigmentTransformationsEditButton",
			pigmentColorPatternCrackleType1Matrix,		@"pigmentColorPatternCrackleType1Matrix",
			pigmentColorPatternCrackleType2Matrix,		@"pigmentColorPatternCrackleType2Matrix",
			pigmentColorPatternCrackleType3Matrix,		@"pigmentColorPatternCrackleType3Matrix",
			pigmentColorPatternCrackleType4Matrix,		@"pigmentColorPatternCrackleType4Matrix",
			pigmentColorPatternGradientMatrix,				@"pigmentColorPatternGradientMatrix",
			pigmentColorPatternSlopeDirectionMatrix,	@"pigmentColorPatternSlopeDirectionMatrix",
			pigmentColorPatternSlopeAltitudeMatrix,		@"pigmentColorPatternSlopeAltitudeMatrix",

			pigmentColorMapEditButton,								@"pigmentColorMapEditButton",
			pigmentColorMapCustomizedButton,					@"pigmentColorMapCustomizedButton",

			pigmentColorPatternDisityFileFileNameEditButton,				@"pigmentColorPatternDisityFileFileNameEditButton",

			pigmentColorPatternImagePatternFileNameButton,					@"pigmentColorPatternImagePatternFileNameButton",
			pigmentColorPatternImagePatternFunctionFunctionButton,	@"pigmentColorPatternImagePatternFunctionFunctionButton",
			pigmentColorPatternImagePatternPatternButton,						@"pigmentColorPatternImagePatternPatternButton",
			pigmentColorPatternImagePatternPigmentButton,						@"pigmentColorPatternImagePatternPigmentButton",

			pigmentColorPatternProjectionEditObjectButton,					@"pigmentColorPatternProjectionEditObjectButton",

			pigmentImageMapFileButton,				@"pigmentImageMapFileButton",
			pigmentImageMapFunctionButton,		@"pigmentImageMapFunctionButton",
			pigmentImageMapPatternButton,			@"pigmentImageMapPatternButton",
			pigmentImageMapPigmentButton,			@"pigmentImageMapPigmentButton",

			pigmentFunctionEditButton,					@"pigmentFunctionEditButton",

			pigmentcolorPatternObjectEditObjectButton,					@"pigmentcolorPatternObjectEditObjectButton",
			pigmentcolorPatternObjectEditOutsideObjectButton,		@"pigmentcolorPatternObjectEditOutsideObjectButton",
			pigmentcolorPatternObjectEditInsideObjectButton,		@"pigmentcolorPatternObjectEditInsideObjectButton",

			pigmentcolorPatternPigmentPatternEditButton,				@"pigmentcolorPatternPigmentPatternEditButton",
			pigmentcolorPatternAveragePigmentEditButton,				@"pigmentcolorPatternAveragePigmentEditButton",
		nil]
		];	
	[pigmentMainViewHolderView  addSubview:pigmentMainViewNIBView];

	// this is a little hack to make the tabview the right size
	// it doesn't work in IB, it is always oversized. could be because
	// the large number of tabs
	NSSize nw;
	nw.width=473;
	nw.height=290;
	[pigmentColorPatternTabView setFrameSize:nw];
	// end of fix

	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"pigmentMainTabView",
		@"pigmentColorPatternSelectPopUpButton",
		nil];
	[mExcludedObjectsForReset retain];

	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	// if an older pref is loaded wiht more tabs than the current one,
	// use the last tab on the panel
	id tabview=[preferences objectForKey:@"pigmentMainTabView"];
	if ( tabview && ([tabview intValue] > cPigmentFunctionTab))
		[preferences setObject:[NSNumber numberWithInt:cPigmentFunctionTab] forKey:@"globalsTabView"];

	//customized color map is in a dictionary because
	// we use it as preferences for the color map template
	// rainbow and b&w are not editable so they can be in colormap format directly
	id cm=[preferences objectForKey:@"customizedColorMap"];
	if ( cm)
		cm=[cm objectForKey:@"colormap"];
	if( cm)
		[[NSUnarchiver unarchiveObjectWithData:cm] setPreview:pigmentColorMapCustomizedPreview];
 	[[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"rainbowColorMap"]]setPreview:pigmentColorMapRainbowPreview];
 	[[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"blackAndWhiteColorMap"]]setPreview:pigmentColorMapBlackAndWhitePreview];

	[self setPigmentTransformations:[preferences objectForKey:@"pigmentTransformations"]];
	[self setPigmentCamera:[preferences objectForKey:@"pigmentCamera"]];
	[self setPigmentFunctionFunction:[preferences objectForKey:@"pigmentFunctionFunction"]];
	[self setPigmentImageMapFunction:[preferences objectForKey:@"pigmentImageMapFunction"]];
	[self setPigmentImageMapPatternPigment:[preferences objectForKey:@"pigmentImageMapPatternPigment"]];
	[self setPigmentImageMapPigmentPigment:[preferences objectForKey:@"pigmentImageMapPigmentPigment"]];

	[self setPigmentColorPatternPigmentPattern:[preferences objectForKey:@"pigmentColorPatternPigmentPattern"]];
	[self setPigmentColorPatternObjectOutsidePigment:[preferences objectForKey:@"pigmentColorPatternObjectOutsidePigment"]];
	[self setPigmentColorPatternObjectInsidePigment:[preferences objectForKey:@"pigmentColorPatternObjectInsidePigment"]];
	[self setPigmentColorMapEditPigmentMap:[preferences objectForKey:@"pigmentColorMapEditPigmentMap"]];
	[self setPigmentColorPatternObject:[preferences objectForKey:@"pigmentColorPatternObject"]];
	[self setPigmentColorPatternAverageEditPigment:[preferences objectForKey:@"pigmentColorPatternAverageEditPigment"]];
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
								[NSArchiver archivedDataWithRootObject:[pigmentColorMapCustomizedPreview  map]] 
								forKey:@"colormap"]
								forKey:@"customizedColorMap"];
	[dict setObject:
								[NSArchiver archivedDataWithRootObject:[pigmentColorMapRainbowPreview  map]] 
								forKey:@"rainbowColorMap"];
	[dict setObject:
								[NSArchiver archivedDataWithRootObject:[pigmentColorMapBlackAndWhitePreview  map]] 
								forKey:@"blackAndWhiteColorMap"];
								
//store transformations if selected
	if ( pigmentTransformations != nil )
		if ( [[dict objectForKey:@"pigmentTransformationsOn"]intValue]==NSOnState)
			[dict setObject:pigmentTransformations forKey:@"pigmentTransformations"];

//store pigmentColorMapEditPigmentMap if selected
	if ( pigmentColorMapEditPigmentMap != nil )
		if ( [[dict objectForKey:@"pigmentColorMapTabView"]intValue]==cBodyMap)
			[dict setObject:pigmentColorMapEditPigmentMap forKey:@"pigmentColorMapEditPigmentMap"];

		
//store function, pigment or pattern if selected
//in either colorPatternImageMap or image map
	if ( [[dict objectForKey:@"pigmentMainTabView"]intValue]==cPigmentImageMapTab)
	{
		if ( [[dict objectForKey:@"pigmentImageMapFileTypePopUp"]intValue]==cFunctionImage && pigmentImageMapFunction != nil)
			[dict setObject:pigmentImageMapFunction forKey:@"pigmentImageMapFunction"];
		else if ( [[dict objectForKey:@"pigmentImageMapFileTypePopUp"]intValue]==cPatternImage && pigmentImageMapPatternPigment != nil)
			[dict setObject:pigmentImageMapPatternPigment forKey:@"pigmentImageMapPatternPigment"];
		else if ( [[dict objectForKey:@"pigmentImageMapFileTypePopUp"]intValue]==cPigmentImage && pigmentImageMapPigmentPigment != nil)
			[dict setObject:pigmentImageMapPigmentPigment forKey:@"pigmentImageMapPigmentPigment"];
	}
	else if ( [[dict objectForKey:@"pigmentMainTabView"]intValue]==cPigmentColorPatternTab)
	{
		//color pattern image map
		if ( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue]==cPigmentPatternImagePattern)
		{
			if ( [[dict objectForKey:@"pigmentColorPatternImagePatternFileTypePopUp"]intValue]==cFunctionImage && pigmentImageMapFunction != nil)
				[dict setObject:pigmentImageMapFunction forKey:@"pigmentImageMapFunction"];
			else if ( [[dict objectForKey:@"pigmentColorPatternImagePatternFileTypePopUp"]intValue]==cPatternImage && pigmentImageMapPatternPigment != nil)
				[dict setObject:pigmentImageMapPatternPigment forKey:@"pigmentImageMapPatternPigment"];
			else if ( [[dict objectForKey:@"pigmentColorPatternImagePatternFileTypePopUp"]intValue]==cPigmentImage && pigmentImageMapPigmentPigment != nil)
				[dict setObject:pigmentImageMapPigmentPigment forKey:@"pigmentImageMapPigmentPigment"];
		}
		//pattern object
		else if ( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue]==cPigmentPatternObject)
		{
			if (  pigmentColorPatternObjectOutsidePigment != nil)
				[dict setObject:pigmentColorPatternObjectOutsidePigment forKey:@"pigmentColorPatternObjectOutsidePigment"];
			if (  pigmentColorPatternObjectInsidePigment != nil)
				[dict setObject:pigmentColorPatternObjectInsidePigment forKey:@"pigmentColorPatternObjectInsidePigment"];
			if (  pigmentColorPatternObject != nil)
				[dict setObject:pigmentColorPatternObject forKey:@"pigmentColorPatternObject"];
		}
		//pigment pattern
		else if ( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue]==cPigmentPatternPigmentPattern)
		{
			if (  pigmentColorPatternPigmentPattern != nil)
				[dict setObject:pigmentColorPatternPigmentPattern forKey:@"pigmentColorPatternPigmentPattern"];
		}
		//average pigment
		else if ( [[dict objectForKey:@"pigmentColorPatternSelectPopUpButton"]intValue]==cPigmentPatternAverage)
		{
			if (  pigmentColorPatternAverageEditPigment != nil)
				[dict setObject:pigmentColorPatternAverageEditPigment forKey:@"pigmentColorPatternAverageEditPigment"];
		}
	}

	
//store function for main function
	if ( pigmentFunctionFunction != nil )
		if([[dict objectForKey:@"pigmentMainTabView"]intValue]== cPigmentFunctionTab)
			if ( [[dict objectForKey:@"pigmentImageMapFileTypePopUp"]intValue]==cFunctionImage)
				[dict setObject:pigmentFunctionFunction forKey:@"pigmentFunctionFunction"];
								
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self pigmentColorPatternSelectPopUpButton:pigmentColorPatternSelectPopUpButton];
	//make sure colormaps are set correctly at startup
	[self 	tabView:pigmentMainTabView didSelectTabViewItem:[pigmentMainTabView selectedTabViewItem]];

	[self pigmentTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// pigmentColorPatternSelectPopUpButton
//---------------------------------------------------------------------
-(IBAction) pigmentColorPatternSelectPopUpButton:(id)sender
{
	int selectedItem=[sender indexOfSelectedItem];
	[pigmentColorPatternTabView selectTabViewItemAtIndex:[sender indexOfSelectedItem]];

	if ( selectedItem >=cPigmentPatternAgate && selectedItem<=cPigmentPatternWrinkles)
	{
		[pigmentColorPatternMapTypeNIBView removeFromSuperview];
		[ [mPigmentPatternColormapViewArray objectAtIndex:selectedItem] addSubview:pigmentColorPatternMapTypeNIBView];
	}
	switch (selectedItem)
	{
		case cPigmentPatternBrick:
		case cPigmentPatternChecker:	
		case cPigmentPatternHexagon:
		case cPigmentPatternObject:
		case cPigmentPatternSquare:
		case cPigmentPatternTriangular:
			[pigmentColorPatternWaveTypeView setHidden:YES];
			break;
		default:
			[pigmentColorPatternWaveTypeView setHidden:NO];
			break;
	}

}



//---------------------------------------------------------------------
// pigmentTarget:sender
//---------------------------------------------------------------------
-(IBAction) pigmentTarget:(id)sender
{
	int theTag;
	if ( sender==self)
		theTag=cPigmentTransformationsOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case 	cPigmentTransformationsOn:
			[self enableObjectsAccordingToObject:pigmentTransformationsOn, pigmentTransformationsEditButton,nil];
			if ( sender !=self )	break;
			

		case 	cPigmentQuickColorOn:
			[self enableObjectsAccordingToObject:pigmentQuickColorOn, pigmentQuickColorColorWell,nil];
			if ( sender !=self )	break;
	//full color
		case 	cPigmentFullColorAddCommentOn:
			[self enableObjectsAccordingToObject:pigmentFullColorAddCommentOn, pigmentFullColorCommentTextField,nil];
			if ( sender !=self )	break;
	//color pattern
		case cPigmentColorPatternWaveTypePopUpButton:
			if ( [pigmentColorPatternWaveTypePopUpButton indexOfSelectedItem]==cPolyWave)
				[pigmentColorPatternWaveTypeEdit setHidden:NO];	
			else
				[pigmentColorPatternWaveTypeEdit setHidden:YES];	
			if ( sender !=self )	break;
					
		
		//crackle
		case cPigmentColorPatternCrackleType1PopUp:
			switch ([pigmentColorPatternCrackleType1PopUp indexOfSelectedItem])
			{
				case cForm:
					[pigmentColorPatternCrackleType1MatrixView setHidden:NO];	[pigmentColorPatternCrackleType1Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[pigmentColorPatternCrackleType1MatrixView setHidden:YES];	[pigmentColorPatternCrackleType1Edit setHidden:NO];
					break;
				case cSolid:
					[pigmentColorPatternCrackleType1MatrixView setHidden:YES];	[pigmentColorPatternCrackleType1Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cPigmentColorPatternCrackleType1On:
			[self enableObjectsAccordingToObject:pigmentColorPatternCrackleType1On, pigmentColorPatternCrackleType1PopUp,pigmentColorPatternCrackleType1MatrixView,pigmentColorPatternCrackleType1Edit,nil];
			if ( sender !=self )	break;
			//2
		case cPigmentColorPatternCrackleType2PopUp:
			switch ([pigmentColorPatternCrackleType2PopUp indexOfSelectedItem])
			{
				case cForm:
					[pigmentColorPatternCrackleType2MatrixView setHidden:NO];	[pigmentColorPatternCrackleType2Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[pigmentColorPatternCrackleType2MatrixView setHidden:YES];	[pigmentColorPatternCrackleType2Edit setHidden:NO];
					break;
				case cSolid:
					[pigmentColorPatternCrackleType2MatrixView setHidden:YES];	[pigmentColorPatternCrackleType2Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cPigmentColorPatternCrackleType2On:
			[self enableObjectsAccordingToObject:pigmentColorPatternCrackleType2On, pigmentColorPatternCrackleType2PopUp,pigmentColorPatternCrackleType2MatrixView,pigmentColorPatternCrackleType2Edit,nil];
			if ( sender !=self )	break;
		//3
		case cPigmentColorPatternCrackleType3PopUp:
			switch ([pigmentColorPatternCrackleType3PopUp indexOfSelectedItem])
			{
				case cForm:
					[pigmentColorPatternCrackleType3MatrixView setHidden:NO];	[pigmentColorPatternCrackleType3Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[pigmentColorPatternCrackleType3MatrixView setHidden:YES];	[pigmentColorPatternCrackleType3Edit setHidden:NO];
					break;
				case cSolid:
					[pigmentColorPatternCrackleType3MatrixView setHidden:YES];	[pigmentColorPatternCrackleType3Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cPigmentColorPatternCrackleType3On:
			[self enableObjectsAccordingToObject:pigmentColorPatternCrackleType3On, pigmentColorPatternCrackleType3PopUp,pigmentColorPatternCrackleType3MatrixView,pigmentColorPatternCrackleType3Edit,nil];
			if ( sender !=self )	break;
			//4
		case cPigmentColorPatternCrackleType4PopUp:
			switch ([pigmentColorPatternCrackleType4PopUp indexOfSelectedItem])
			{
				case cForm:
					[pigmentColorPatternCrackleType4MatrixView setHidden:NO];	[pigmentColorPatternCrackleType4Edit setHidden:YES];
					break;
				case cMetric:	case cOffset:
					[pigmentColorPatternCrackleType4MatrixView setHidden:YES];	[pigmentColorPatternCrackleType4Edit setHidden:NO];
					break;
				case cSolid:
					[pigmentColorPatternCrackleType4MatrixView setHidden:YES];	[pigmentColorPatternCrackleType4Edit setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
		case cPigmentColorPatternCrackleType4On:
			[self enableObjectsAccordingToObject:pigmentColorPatternCrackleType4On, pigmentColorPatternCrackleType4PopUp,pigmentColorPatternCrackleType4MatrixView,pigmentColorPatternCrackleType4Edit,nil];
			if ( sender !=self )	break;

		//factals
		case cPpigmentColorPatternFractalsTypePopUp:
			switch ([pigmentColorPatternFractalsTypePopUp indexOfSelectedItem])
			{
				case cJulia:
					[pigmentColorPatternFractalsExponentView setHidden:NO];	[pigmentColorPatternFractalsTypeXYView setHidden:NO];
					break;
				case cMagnet1Julia:
				case cMagnet2Julia:
					[pigmentColorPatternFractalsExponentView setHidden:YES];	[pigmentColorPatternFractalsTypeXYView setHidden:NO];
					break;
				case cMagnet1Mandel:
				case cMagnet2Mandel:
					[pigmentColorPatternFractalsExponentView setHidden:YES];	[pigmentColorPatternFractalsTypeXYView setHidden:YES];
					break;
				case cMandel:
					[pigmentColorPatternFractalsExponentView setHidden:NO];	[pigmentColorPatternFractalsTypeXYView setHidden:YES];
					break;
			}
			if ( sender !=self )	break;
	 	case cPigmentColorPatternFractalsExponentOn:
			[self enableObjectsAccordingToObject:pigmentColorPatternFractalsExponentOn, pigmentColorPatternFractalsExponentEdit,nil];
			if ( sender !=self )	break;
	 	case cPigmentColorPatternFractalsInteriorTypeOn:
			[self enableObjectsAccordingToObject:pigmentColorPatternFractalsInteriorTypeOn, pigmentColorPatternFractalsInteriorTypePopUp,
					pigmentColorPatternFractalsInteriorTypeFactorEdit, pigmentColorPatternFractalsInteriorTypeFactorText,nil];
			if ( sender !=self )	break;
	 	case cPigmentColorPatternFractalsExteriorTypeOn	:
			[self enableObjectsAccordingToObject:pigmentColorPatternFractalsExteriorTypeOn, pigmentColorPatternFractalsExteriorTypePopUp,
					pigmentColorPatternFractalsExteriorTypeFactorEdit,pigmentColorPatternFractalsExteriorTypeFactorText,nil];
			if ( sender !=self )	break;

		//gradient
		case cPigmentColorPatternGradientXYZPopUp:
			[ self setXYZVectorAccordingToPopup:pigmentColorPatternGradientXYZPopUp xyzMatrix:pigmentColorPatternGradientMatrix];
			if ( sender !=self )	break;
		//image pattern
		case cPigmentColorPatternImageMapProjectionPopUp:
			if ( [pigmentColorPatternImageMapProjectionPopUp indexOfSelectedItem] == cProjectionSpherical)
				[pigmentColorPatternImageMapProjectionOnceOn setEnabled:NO];
			else
				[pigmentColorPatternImageMapProjectionOnceOn setEnabled:YES];
			if ( sender !=self )	break;


		case cPigmentColorPatternImagePatternFileTypePopUp:
			switch([pigmentColorPatternImagePatternFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[pigmentColorPatternImagePatternFileView setHidden:NO];
					[pigmentColorPatternImagePatternWidthHeightView setHidden:YES];
					[pigmentColorPatternImagePatternFunctionView setHidden:YES];
					[pigmentColorPatternImagePatternPatternView setHidden:YES];
					[pigmentColorPatternImagePatternPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[pigmentColorPatternImagePatternFileView setHidden:YES];
					[pigmentColorPatternImagePatternWidthHeightView setHidden:NO];
					[pigmentColorPatternImagePatternFunctionView setHidden:NO];
					[pigmentColorPatternImagePatternPatternView setHidden:YES];
					[pigmentColorPatternImagePatternPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[pigmentColorPatternImagePatternFileView setHidden:YES];
					[pigmentColorPatternImagePatternWidthHeightView setHidden:NO];
					[pigmentColorPatternImagePatternFunctionView setHidden:YES];
					[pigmentColorPatternImagePatternPatternView setHidden:NO];
					[pigmentColorPatternImagePatternPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[pigmentColorPatternImagePatternFileView setHidden:YES];
					[pigmentColorPatternImagePatternWidthHeightView setHidden:NO];
					[pigmentColorPatternImagePatternFunctionView setHidden:YES];
					[pigmentColorPatternImagePatternPatternView setHidden:YES];
					[pigmentColorPatternImagePatternPigmentView setHidden:NO];
					break;
			}
			if ( sender !=self )	break;
		//pavement
		case cPigmentColorPatternPavementSidesPopUp:
			if ( [pigmentColorPatternPavementSidesPopUp indexOfSelectedItem] == cPavementSidesHexagon)
			{
//				NSInteger selectedItem=[pigmentColorPatternPavementTilesPopUp indexOfSelectedItem];
				[pgimentColorPatternPavementExtriorGroupBox setHidden:YES];
				disableItemsFromIndex( pigmentColorPatternPavementTilesPopUp, 5);
			}
			else
			{
				[pgimentColorPatternPavementExtriorGroupBox setHidden:NO];
				// over last index, enable them all
				disableItemsFromIndex( pigmentColorPatternPavementTilesPopUp, 6);
			}
			if ( [pigmentColorPatternPavementSidesPopUp indexOfSelectedItem] == cPavementSidesSquare)
				disableItemsFromIndex( pigmentColorPatternPavementFormPopUp, 4);
			else
				disableItemsFromIndex( pigmentColorPatternPavementFormPopUp, 3);
			
	//		if ( sender !=self )	break;
		case cPigmentColorPatternPavementTilesPopUp:
			{
				NSInteger sides=[pigmentColorPatternPavementSidesPopUp indexOfSelectedItem];
				NSInteger tiles=[pigmentColorPatternPavementTilesPopUp indexOfSelectedItem];
				switch (tiles)
				{
					case 0:
					case 1:
						disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 1);
						break;
					case 2:
						disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, sides+1);
						break;
					case 3:
						switch (sides)
						{
							case 0: disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 3);	 break;
							case 1:	disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 5); break;
							case 2:	disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 7); break;
						}
						break;
					case 4:
						switch (sides)
						{
							case 0: disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 4);	 break;
							case 1:	disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 12); break;
							case 2:	disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 22); break;
						}
						break;
					case 5:
						switch (sides)
						{
							case 0: disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 12);	 break;
							case 1:	disableItemsFromIndex( pigmentColorPatternPavementPatternPopUp, 35); break;
						}
						break;
				}
			}
			if ( sender !=self )	break;

		//slope
		case cPigmentColorPatternSlopeDirectionXYZPopUp:
			[ self setXYZVectorAccordingToPopup:pigmentColorPatternSlopeDirectionXYZPopUp xyzMatrix:pigmentColorPatternSlopeDirectionMatrix];
			if ( sender !=self )	break;
		case cPigmentColorPatternSlopeSlopeOn:
			[self enableObjectsAccordingToObject:pigmentColorPatternSlopeSlopeOn, pigmentColorPatternSlopeSlopeLowText,
					pigmentColorPatternSlopeSlopeLowEdit,pigmentColorPatternSlopeSlopeHighText,pigmentColorPatternSlopeSlopeHighEdit, nil];
			if ( sender !=self )	break;
		case cPigmentColorPatternSlopeAltitudeXYZPopUp:
			[ self setXYZVectorAccordingToPopup:pigmentColorPatternSlopeAltitudeXYZPopUp xyzMatrix:pigmentColorPatternSlopeAltitudeMatrix];
			if ( sender !=self )	break;
		case cPigmentColorPatternSlopeAltitudeOn:
			[self enableObjectsAccordingToObject:pigmentColorPatternSlopeAltitudeOn, pigmentColorPatternSlopeAltitudeXYZPopUp,
					pigmentColorPatternSlopeAltitudeMatrix, nil];
			if ( sender !=self )	break;
		case cPigmentColorPatternSlopeOffsetOn:
			[self enableObjectsAccordingToObject:pigmentColorPatternSlopeOffsetOn, pigmentColorPatternSlopeOffsetLowText,
					pigmentColorPatternSlopeOffsetLowEdit,pigmentColorPatternSlopeOffsetHighText,pigmentColorPatternSlopeOffsetHighEdit, nil];
			if ( sender !=self )	break;

		//pigment image pattern
		
		case cPigmentImageMapProjectionPopUp:
			if ( [pigmentImageMapProjectionPopUp indexOfSelectedItem] == cProjectionSpherical)
				[pigmentImageMapProjectionOnceOn setEnabled:NO];
			else
				[pigmentImageMapProjectionOnceOn setEnabled:YES];
			if ( sender !=self )	break;
		case cPigmentImageMapFilerAllOn:
			[self enableObjectsAccordingToObject:pigmentImageMapFilerAllOn, pigmentImageMapFilterAllEdit,nil];
			if ( sender !=self )	break;
		case cPigmentImageMapTransmitAllOn:
			[self enableObjectsAccordingToObject:pigmentImageMapTransmitAllOn, pigmentImageMapTransmitAllEdit,nil];
			if ( sender !=self )	break;
		case cPigmentImageMapFileTypePopUp:
			switch([pigmentImageMapFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[pigmentImageMapFileView setHidden:NO];
					[pigmentImageMapWidthHeightView setHidden:YES];
					[pigmentImageMapFunctionView setHidden:YES];
					[pigmentImageMapPatternView setHidden:YES];
					[pigmentImageMapPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[pigmentImageMapFileView setHidden:YES];
					[pigmentImageMapWidthHeightView setHidden:NO];
					[pigmentImageMapFunctionView setHidden:NO];
					[pigmentImageMapPatternView setHidden:YES];
					[pigmentImageMapPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[pigmentImageMapFileView setHidden:YES];
					[pigmentImageMapWidthHeightView setHidden:NO];
					[pigmentImageMapFunctionView setHidden:YES];
					[pigmentImageMapPatternView setHidden:NO];
					[pigmentImageMapPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[pigmentImageMapFileView setHidden:YES];
					[pigmentImageMapWidthHeightView setHidden:NO];
					[pigmentImageMapFunctionView setHidden:YES];
					[pigmentImageMapPatternView setHidden:YES];
					[pigmentImageMapPigmentView setHidden:NO];
					break;
			}
			if ( sender !=self )	break;
		case cPigmentFunctionWaveTypePopUpButton:
			if ( [pigmentFunctionWaveTypePopUpButton indexOfSelectedItem]==cPolyWave)
				[pigmentFunctionWaveTypeEdit setHidden:NO];	
			else
				[pigmentFunctionWaveTypeEdit setHidden:YES];	
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
	id obj=nil;
	if( [key isEqualToString:@"customizedColorMap"])
	{
		obj=[dict objectForKey:@"colormap"];
		if ( obj != nil)// was default and removed from prefs, add a new default
			obj=[NSUnarchiver unarchiveObjectWithData:obj];
		else
			obj=[colormap standardMapWithView:nil];
		[obj setPreview:pigmentColorMapCustomizedPreview];
		[pigmentColorMapCustomizedPreview setNeedsDisplay:YES];
	}
	else if( [key isEqualToString:@"pigmentImageMapFunction"])
	{
		[self setPigmentImageMapFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[pigmentImageMapFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"pigmentPatternImageMapFunction"])
	{
		[self setPigmentImageMapFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[pigmentColorPatternImagePatternFunctionFunctionEdit  insertText:str];
	}

	else if( [key isEqualToString:@"pigmentFunctionFunction"])
	{
		[self setPigmentFunctionFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[pigmentFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"pigmentTransformations"])
	{
		[self setPigmentTransformations:dict];
	}
	else if( [key isEqualToString:@"pigmentCamera"])
	{
		[self setPigmentCamera:dict];
	}
	else if( [key isEqualToString:@"pigmentColorPatternPigmentPattern"])
	{
		[self setPigmentColorPatternPigmentPattern:dict];
	}
	else if( [key isEqualToString:@"pigmentColorPatternObjectOutsidePigment"])
	{
		[self setPigmentColorPatternObjectOutsidePigment:dict];
	}
	else if( [key isEqualToString:@"pigmentColorPatternObjectInsidePigment"])
	{
		[self setPigmentColorPatternObjectInsidePigment:dict];
	}
	else if( [key isEqualToString:@"pigmentColorMapEditPigmentMap"])
	{
		[self setPigmentColorMapEditPigmentMap:dict];
	}
	else if( [key isEqualToString:@"pigmentColorPatternObject"])
	{
		[self setPigmentColorPatternObject:dict];
	}
	else if( [key isEqualToString:@"pigmentColorPatternAverageEditPigment"])
	{
		[self setPigmentColorPatternAverageEditPigment:dict];
	}

	else if( [key isEqualToString:@"pigmentImageMapPatternPigment"])
	{
		[self setPigmentImageMapPatternPigment:dict];
	}
	else if( [key isEqualToString:@"pigmentImageMapPigmentPigment"])
	{
		[self setPigmentImageMapPigmentPigment:dict];
	}

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// pigmentButtons:sender
//---------------------------------------------------------------------
-(IBAction) pigmentButtons:(id)sender
{
	id 	prefs=nil;

	int tag=[sender tag];
	switch( tag)
	{
	
		case cPigmentColorMapEditCustomizedColorMap:
			[self callTemplate:menuTagTemplateColormap 
					withDictionary:[NSMutableDictionary dictionaryWithObject:
											[NSArchiver archivedDataWithRootObject:
												[pigmentColorMapCustomizedPreview  map]
											] 
											forKey:@"colormap"
										]
					andKeyName:@"customizedColorMap"];
			break;
		case cPigmentColorMapEditPigmentMap:
			if (pigmentColorMapEditPigmentMap!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorMapEditPigmentMap];
			[self callTemplate:menuTagTemplatePigmentmap withDictionary:prefs andKeyName:@"pigmentColorMapEditPigmentMap"];
			break;
		
		case cPigmentTransformationsEditButton:
			if (pigmentTransformations!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentTransformations];
			[self callTemplate:menuTagTemplateTransformations withDictionary:prefs andKeyName:@"pigmentTransformations"];
			break;
		case cPigmentColorPatternObjectEditInsidePigment:
			if (pigmentColorPatternObjectInsidePigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorPatternObjectInsidePigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"pigmentColorPatternObjectInsidePigment"];
			break;
		case cPigmentColorPatternObjectEditOutsidePigment	:
			if (pigmentColorPatternObjectOutsidePigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorPatternObjectOutsidePigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"pigmentColorPatternObjectOutsidePigment"];
			break;

		case cPigmentColorPatternDisityFileSelectFileButton:
			[self selectFile:pigmentColorPatternDisityFileFileNameEdit withTypes:nil keepFullPath:NO];
			break;

		case cPigmentColorPatternPigmentPatternEditPigment:
			if (pigmentColorPatternPigmentPattern!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorPatternPigmentPattern];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"pigmentColorPatternPigmentPattern"];

			break;

		case cPigmentColorPatternObjectEditObject:
			if (pigmentColorPatternObject!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorPatternObject];
			[self callTemplate:menuTagTemplateObject withDictionary:prefs andKeyName:@"pigmentColorPatternObject"];

			break;
		case cPigmentColorPatternAverageEditPigment:
			if (pigmentColorPatternAverageEditPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentColorPatternAverageEditPigment];
			[self callTemplate:menuTagTemplatePigmentmap withDictionary:prefs andKeyName:@"pigmentColorPatternAverageEditPigment"];
			break;

//image map & pattern image map
	 	case cPigmentColorPatternImagePatternEditFunctionButton:
			if (pigmentImageMapFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentImageMapFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"pigmentPatternImageMapFunction"];
			break;
	 	case cPigmentImageMapEditFunctionButton:
			if (pigmentImageMapFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentImageMapFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"pigmentImageMapFunction"];
			break;
			
	 	case cPigmentColorPatternImagePatternEditPatternButton:
	 	case cPigmentImageMapEditPatternButton:
			if (pigmentImageMapPatternPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentImageMapPatternPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"pigmentImageMapPatternPigment"];
			break;
			
	 	case cPigmentColorPatternImagePatternEditPigmentButton:
		case cPigmentImageMapEditPigmentButton:
			if (pigmentImageMapPigmentPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentImageMapPigmentPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"pigmentImageMapPigmentPigment"];
			break;

		case cPigmentImageMapSelectImageFileButton:
			[self selectFile:pigmentImageMapFileName withTypes:nil keepFullPath:NO];
			break;

	 	case cPigmentColorPatternImagePatternSelectImageFileButton:
			[self selectFile:pigmentColorPatternImagePatternFileNameEdit withTypes:nil keepFullPath:NO];
			break;

		case cPigmentFunctionEditFunctionButton:
			if (pigmentFunctionFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:pigmentFunctionFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"pigmentFunctionFunction"];
			break;

	}
}


//---------------------------------------------------------------------
// tabView delegate
//---------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	if ( tabView == pigmentMainTabView)
	{
		if ( [[tabViewItem identifier]intValue]==cPigmentFunctionTab)	//function
		{
			[pigmentColorPatternMapTypeNIBView removeFromSuperview];
			[ pigmentFunctionColorMapView addSubview:pigmentColorPatternMapTypeNIBView];
		}
		else if ( [[tabViewItem identifier]intValue]==cPigmentColorPatternTab)//	color pattern
			[self pigmentColorPatternSelectPopUpButton:pigmentColorPatternSelectPopUpButton];
	}
	else if ( tabView == pigmentColorMapTabView)
	{
	}
}

@end
