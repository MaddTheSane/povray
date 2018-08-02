//******************************************************************************
///
/// @file /macintosh/sceneDocument/templates/backgroundTemplate.h
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
//********************************************************************************


#import <Cocoa/Cocoa.h>
#import "BaseTemplate.h"
#import "mapPreview.h"
#define glowTransformations mTemplatePrefs[0]
#define backgroundSkysphereEditPigment1 mTemplatePrefs[1]
#define backgroundSkysphereEditPigment2 mTemplatePrefs[2]
#define backgroundSkysphereEditPigment3 mTemplatePrefs[3]
#define backgroundSkysphereEditPigment4 mTemplatePrefs[4]
#define backgroundSkysphereEditPigment5 mTemplatePrefs[5]

#define setGlowTransformations setTemplatePrefs:0 withObject
#define setBackgroundSkysphereEditPigment1 setTemplatePrefs:1 withObject
#define setBackgroundSkysphereEditPigment2 setTemplatePrefs:2 withObject
#define setBackgroundSkysphereEditPigment3 setTemplatePrefs:3 withObject
#define setBackgroundSkysphereEditPigment4 setTemplatePrefs:4 withObject
#define setBackgroundSkysphereEditPigment5 setTemplatePrefs:5 withObject
	
enum eBackgroundTags{
//fog	
	cBackgroundFogTypePopUp									=10,
	cBackgroundFogUpOn											=20,
	cBackgroundFogUpXYZPopUp								=30,
	cBackgroundFogOffsetOn									=50,
	cBackgroundFogAltitudeOn								=60,
	cBackgroundFogTurbulenceOn							=70,
	cBackgroundFogTurbulenceXYZPopUp				=80,
	cBackgroundFogTurbulenceDepthOn					=90,
	cBackgroundFogOctavesOn									=100,
	cBackgroundFogOmegaOn										=110,
	cBackgroundFogLambdaOn									=120,
	
//rainbow
	cBackgroundRainbowDirectionXYZPopUp			=130,
	
	cBackgroundRainbowJitterOn							=140,
	cBackgroundRainbowUpOn									=150,
	cRainbowColorMapEditCustomizedColorMap	=160,
	cBackgroundRainbowUpXYZPopUp						=180,

	cBackgroundRainbowArcAngleOn						=190,
	cBackgroundRainbowFalloffAngleOn				=200,
//skysphere
	cBackgroundSkysphereEditPigment1Button	=250,
	cBackgroundSkyspherePigment2On					=255,
	cBackgroundSkysphereEditPigment2Button	=260,
	cBackgroundSkyspherePigment3On					=265,
	cBackgroundSkysphereEditPigment3Button	=270,
	cBackgroundSkyspherePigment4On					=275,
	cBackgroundSkysphereEditPigment4Button	=280,
	cBackgroundSkyspherePigment5On					=285,
	cBackgroundSkysphereEditPigment5Button	=290,
//glow
	cBackgroundGlowLocationXYZPopUp					=220,
	cBackgroundGlowTransformationsOn				=230,
	cBackgroundGlowTransformationsButton		=240
	
};

enum  {
	cBackground		=0,
	cFog					=1,
	cRainbow			=2,
	cSkysphere		=3,
	cGlow					=4,
	
	cConstantFog	=0,
	cGroundFog		=1,
	
	cGlowType0		=0,
	cGlowType1		=1,
	cGlowType2		=2,
	cGlowType3		=3
	};

@interface BackgroundTemplate : BaseTemplate
{

	//main
	IBOutlet NSTabView				*backgroundTabView;
	//background
	IBOutlet NSColorWell 			*backgroundColorWell;
	//fog
	IBOutlet NSView						*backgroundFogGroundfogView;
	IBOutlet NSPopUpButton 		*backgroundFogTypePopUp;

	IBOutlet NSButton					*backgroundFogUpOn;
	IBOutlet NSPopUpButton 		*backgroundFogUpXYZPopUp;
	IBOutlet NSMatrix					*backgroundFogUpMatrix;
	IBOutlet NSTextField			*backgroundFogDistanceEdit;
	IBOutlet NSButton					*backgroundFogOffsetOn;
	IBOutlet NSTextField			*backgroundFogOffsetEdit;
	IBOutlet NSButton					*backgroundFogAltitudeOn;
	IBOutlet NSTextField			*backgroundFogAltitudeEdit;
	IBOutlet NSColorWell 			*backgroundFogColorColorWell;
	IBOutlet NSButton 				*backgroundFogTurbulenceOn;
	IBOutlet NSPopUpButton 		*backgroundFogTurbulenceXYZPopUp;
	IBOutlet NSMatrix					*backgroundFogTurbulenceMatrix;
	IBOutlet NSButton					*backgroundFogTurbulenceDepthOn;
	IBOutlet NSTextField			*backgroundFogTurbulenceDepthEdit;
	IBOutlet NSButton					*backgroundFogOctavesOn;
	IBOutlet NSTextField			*backgroundFogOctavesEdit;
	IBOutlet NSButton					*backgroundFogOmegaOn;
	IBOutlet NSTextField			*backgroundFogOmegaEdit;
	IBOutlet NSButton					*backgroundFogLambdaOn;
	IBOutlet NSTextField			*backgroundFogLambdaEdit;
	//rainbow
	IBOutlet NSPopUpButton 		*backgroundRainbowDirectionXYZPopUp;
	IBOutlet NSMatrix					*backgroundRainbowDirectionMatrix;
	IBOutlet NSTextField			*backgroundRainbowAngleEdit;
	IBOutlet NSTextField			*backgroundRainbowWidthEdit;
	IBOutlet NSTextField			*backgroundRainbowDistanceEdit;
	//colormap
	IBOutlet NSTabView				*backgroundRainbowColorMapTabView;
	IBOutlet colormapPreview	*backgroundRainbowColorMapBlackAndWhitePreview;
	IBOutlet colormapPreview	*backgroundRainbowColorMapRainbowPreview;
	IBOutlet colormapPreview	*backgroundRainbowColorMapCustomizedPreview;

	IBOutlet NSButton					*backgroundRainbowJitterOn;
	IBOutlet NSTextField			*backgroundRainbowJitterEdit;
	IBOutlet NSButton	 				*backgroundRainbowUpOn;
	IBOutlet NSPopUpButton 		*backgroundRainbowUpXYZPopUp;
	IBOutlet NSMatrix					*backgroundRainbowUpMatrix;

	IBOutlet NSButton					*backgroundRainbowArcAngleOn;
	IBOutlet NSTextField			*backgroundRainbowArcAngleEdit;
	IBOutlet NSButton					*backgroundRainbowFalloffAngleOn;
	IBOutlet NSTextField			*backgroundRainbowFalloffAngleEdit;
	//skysphere
	IBOutlet NSButton					*backgroundSkysphereEditPigment1Button;
	IBOutlet NSButton					*backgroundSkyspherePigment2On;
	IBOutlet NSButton					*backgroundSkysphereEditPigment2Button;
	IBOutlet NSButton					*backgroundSkyspherePigment3On;
	IBOutlet NSButton					*backgroundSkysphereEditPigment3Button;
	IBOutlet NSButton					*backgroundSkyspherePigment4On;
	IBOutlet NSButton					*backgroundSkysphereEditPigment4Button;
	IBOutlet NSButton					*backgroundSkyspherePigment5On;
	IBOutlet NSButton					*backgroundSkysphereEditPigment5Button;

	//glow
	IBOutlet NSPopUpButton 		*backgroundGlowTypePopUp;
	IBOutlet NSPopUpButton 		*backgroundGlowLocationXYZPopUp;
	IBOutlet NSMatrix					*backgroundGlowLocationMatrix;
	IBOutlet NSTextField			*backgroundGlowSizeEdit;
	IBOutlet NSTextField			*backgroundGlowRadiusEdit;
	IBOutlet NSTextField			*backgroundGlowFadePowerEdit;
	IBOutlet NSButton					*backgroundGlowTransformationsOn;
	IBOutlet NSButton					*backgroundGlowTransformationsButton;
	IBOutlet NSColorWell 			*backgroundGlowColorWell;

//extra for tooltips
	IBOutlet NSButton					*backgroundColorMapEditButton;

		
}

-(IBAction) backgroundTarget:(id)sender;
-(IBAction) backgroundButtons:(id)sender;

@end
