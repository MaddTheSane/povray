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



#import <Cocoa/Cocoa.h>
#import "baseTemplate.h"
#define topTransformationsDisplayWarp mTemplatePrefs[0]
#define midTransformationsDisplayWarp mTemplatePrefs[1]
#define bottomTransformationsDisplayWarp mTemplatePrefs[2]

#define setTopTransformationsDisplayWarp setTemplatePrefs:0 withObject
#define setMidTransformationsDisplayWarp setTemplatePrefs:1 withObject
#define setBottomTransformationsDisplayWarp setTemplatePrefs:2 withObject

enum eTransformationWarp3D {
	cCylindrical=0,
	cPlanar=1,
	cSpherical=2,
	cToroidal=3
	};
	
enum eTransformationTags {
	cOn										=100,
	cTypePopUp							=101,
	//Scale
	cScalePopUp							=1,
	//Translate
	cTranslatePopUp					=2,
	//Rotate
	cRotatePopUp						=3,
	//Phase
	//Frequency
	//Turbulence
	cTurbulencePopUp					=4,
	cTurbulenceOctavesOn			=5,
	cTurbulenceOmegaOn			=6,
	cTurbulenceLambdaOn			=7,
	//RepeatWarp
	cRepeatWarpOffsetOn				=8,
	cRepeatWarpOffsetPopUp		=9,
	//BlackHole
	cBlackHoleCenterPopUp			=10,
	cBlackHoleFalloffOn				=11,
	cBlackHoleStrengthOn				=12,
	cBlackHoleRepeatOn				=13,
	cBlackHoleRepeatPopUp			=14,
	cBlackHoleTurbulenceOn			=15,
	cBlackHoleTurbulencePopUp	=16,
	//matrix
	//displaceWarp
	cDisplaceWarpEditPattern		=40,
	//Warp3D
	cWarp3DTypePopUp				=17,
	cWarp3DDistExpOn				=18,
	cWarp3DMajorRadiusOn			=19,
	cWarp3DOrientationOn			=20,
   };
  
  enum {
  	cWarp3DCylindrical 	=0,
  	cWarp3DPlanar			=1,
  	cWarp3DSpherical			=2,
  	cWarp3DTorodial			=3
  };
  	
@interface TransformationsTemplate : BaseTemplate
{
	NSDictionary *mTopObjects, *mMidObjects, *mBottomObjects;
	
//******************************************************************************************
//***********************************************************top panel******************
//******************************************************************************************
		IBOutlet NSButton			*topOn;
		IBOutlet NSPopUpButton 	*topTypePopUp;
		IBOutlet NSBox				*topGroup;
		IBOutlet NSTabView		*topTabView;
	//Scale
		IBOutlet NSPopUpButton	*topScalePopUp;
		IBOutlet NSMatrix			*topScaleMatrix;

	//Translate
		IBOutlet NSPopUpButton	*topTranslatePopUp;
		IBOutlet NSMatrix			*topTranslateMatrix;
	//Rotate
		IBOutlet NSPopUpButton	*topRotatePopUp;
		IBOutlet NSMatrix			*topRotateMatrix;
	//Phase
		IBOutlet NSTextField		*topPhaseEdit;
	//Frequency
		IBOutlet NSTextField		*topFrequencyEdit;
	//Turbulence
		IBOutlet NSPopUpButton	*topTurbulencePopUp;
		IBOutlet NSMatrix			*topTurbulenceMatrix;
		IBOutlet NSButton			*topTurbulenceOctavesOn;
		IBOutlet NSTextField		*topTurbulenceOctavesEdit;
		IBOutlet NSButton			*topTurbulenceOmegaOn;
		IBOutlet NSTextField		*topTurbulenceOmegaEdit;
		IBOutlet NSButton			*topTurbulenceLambdaOn;
		IBOutlet NSTextField 		*topTurbulenceLambdaEdit;
		IBOutlet NSButton			*topTurbulenceWarpOn;
	//RepeatWarp
		IBOutlet NSPopUpButton	*topRepeatWarpRepeatPopUp;
		IBOutlet NSTextField		*topRepeatWarpRepeatWidthEdit;
		IBOutlet NSButton			*topRepeatWarpOffsetOn;
		IBOutlet NSPopUpButton	*topRepeatWarpOffsetPopUp;
		IBOutlet NSMatrix			*topRepeatWarpOffsetMatrix;
		IBOutlet NSButton			*topRepeatWarpFlipX;
		IBOutlet NSButton			*topRepeatWarpFlipY;
		IBOutlet NSButton			*topRepeatWarpFlipZ;
	//BlackHole
		IBOutlet NSPopUpButton	*topBlackHoleCenterPopUp;
		IBOutlet NSMatrix			*topBlackHoleCenterMatrix;
		IBOutlet NSButton			*topBlackHoleInverseOn;
		IBOutlet NSTextField		*topBlackHoleRadiusEdit;
		IBOutlet NSButton			*topBlackHoleFalloffOn;
		IBOutlet NSTextField		*topBlackHoleFalloffEdit;
		IBOutlet NSButton			*topBlackHoleStrengthOn;
		IBOutlet NSTextField		*topBlackHoleStrengthEdit;
		IBOutlet NSButton			*topBlackHoleRepeatOn;
		IBOutlet NSPopUpButton	*topBlackHoleRepeatPopUp;
		IBOutlet NSMatrix			*topBlackHoleRepeatMatrix;
		IBOutlet NSButton			*topBlackHoleTurbulenceOn;
		IBOutlet NSPopUpButton	*topBlackHoleTurbulencePopUp;
		IBOutlet NSMatrix			*topBlackHoleTurbulenceMatrix;
	//matrix
		IBOutlet NSMatrix			*topMatrixMatrix;
	//displaceWarp
	//Warp3D
		IBOutlet NSPopUpButton	*topWarp3DTypePopUp;
		IBOutlet NSView				*topWarp3DDistExpView;
		IBOutlet NSView 				*topWarp3DDistanceView;
		IBOutlet NSView 				*topWarp3DNormalView;
		IBOutlet NSView				*topWarp3DOrientationView;
		IBOutlet NSButton			*topWarp3DDistExpOn;
		IBOutlet NSTextField		*topWarp3DDistExpEdit;
		IBOutlet NSTextField		*topWarp3DDistanceEdit;
		IBOutlet NSButton			*topWarp3DMajorRadiusOn;
		IBOutlet NSTextField		*topWarp3DMajorRadiusEdit;
		IBOutlet NSButton			*topWarp3DOrientationOn;
		IBOutlet NSMatrix			*topWarp3DOrientationMatrix;
		IBOutlet NSMatrix			*topWarp3DNormalMatrix;

//******************************************************************************************
//***********************************************************mid panel******************
//******************************************************************************************
		IBOutlet NSButton			*midOn;
		IBOutlet NSPopUpButton 	*midTypePopUp;
		IBOutlet NSBox				*midGroup;
		IBOutlet NSTabView		*midTabView;
	//Scale
		IBOutlet NSPopUpButton	*midScalePopUp;
		IBOutlet NSMatrix			*midScaleMatrix;

	//Translate
		IBOutlet NSPopUpButton	*midTranslatePopUp;
		IBOutlet NSMatrix			*midTranslateMatrix;
	//Rotate
		IBOutlet NSPopUpButton	*midRotatePopUp;
		IBOutlet NSMatrix			*midRotateMatrix;
	//Phase
		IBOutlet NSTextField		*midPhaseEdit;
	//Frequency
		IBOutlet NSTextField		*midFrequencyEdit;
	//Turbulence
		IBOutlet NSPopUpButton	*midTurbulencePopUp;
		IBOutlet NSMatrix			*midTurbulenceMatrix;
		IBOutlet NSButton			*midTurbulenceOctavesOn;
		IBOutlet NSTextField		*midTurbulenceOctavesEdit;
		IBOutlet NSButton			*midTurbulenceOmegaOn;
		IBOutlet NSTextField		*midTurbulenceOmegaEdit;
		IBOutlet NSButton			*midTurbulenceLambdaOn;
		IBOutlet NSTextField 		*midTurbulenceLambdaEdit;
		IBOutlet NSButton			*midTurbulenceWarpOn;
	//RepeatWarp
		IBOutlet NSPopUpButton	*midRepeatWarpRepeatPopUp;
		IBOutlet NSTextField		*midRepeatWarpRepeatWidthEdit;
		IBOutlet NSButton			*midRepeatWarpOffsetOn;
		IBOutlet NSPopUpButton	*midRepeatWarpOffsetPopUp;
		IBOutlet NSMatrix			*midRepeatWarpOffsetMatrix;
		IBOutlet NSButton			*midRepeatWarpFlipX;
		IBOutlet NSButton			*midRepeatWarpFlipY;
		IBOutlet NSButton			*midRepeatWarpFlipZ;
	//BlackHole
		IBOutlet NSPopUpButton	*midBlackHoleCenterPopUp;
		IBOutlet NSMatrix			*midBlackHoleCenterMatrix;
		IBOutlet NSButton			*midBlackHoleInverseOn;
		IBOutlet NSTextField		*midBlackHoleRadiusEdit;
		IBOutlet NSButton			*midBlackHoleFalloffOn;
		IBOutlet NSTextField		*midBlackHoleFalloffEdit;
		IBOutlet NSButton			*midBlackHoleStrengthOn;
		IBOutlet NSTextField		*midBlackHoleStrengthEdit;
		IBOutlet NSButton			*midBlackHoleRepeatOn;
		IBOutlet NSPopUpButton	*midBlackHoleRepeatPopUp;
		IBOutlet NSMatrix			*midBlackHoleRepeatMatrix;
		IBOutlet NSButton			*midBlackHoleTurbulenceOn;
		IBOutlet NSPopUpButton	*midBlackHoleTurbulencePopUp;
		IBOutlet NSMatrix			*midBlackHoleTurbulenceMatrix;
	//matrix
		IBOutlet NSMatrix			*midMatrixMatrix;
	//displaceWarp
	//Warp3D
		IBOutlet NSPopUpButton	*midWarp3DTypePopUp;
		IBOutlet NSView				*midWarp3DDistExpView;
		IBOutlet NSView 				*midWarp3DDistanceView;
		IBOutlet NSView 				*midWarp3DNormalView;
		IBOutlet NSView				*midWarp3DOrientationView;
		IBOutlet NSButton			*midWarp3DDistExpOn;
		IBOutlet NSTextField		*midWarp3DDistExpEdit;
		IBOutlet NSTextField		*midWarp3DDistanceEdit;
		IBOutlet NSButton			*midWarp3DMajorRadiusOn;
		IBOutlet NSTextField		*midWarp3DMajorRadiusEdit;
		IBOutlet NSButton			*midWarp3DOrientationOn;
		IBOutlet NSMatrix			*midWarp3DOrientationMatrix;
		IBOutlet NSMatrix			*midWarp3DNormalMatrix;

//******************************************************************************************
//***********************************************************bottom panel******************
//******************************************************************************************
		IBOutlet NSButton			*bottomOn;
		IBOutlet NSPopUpButton 	*bottomTypePopUp;
		IBOutlet NSBox				*bottomGroup;
		IBOutlet NSTabView		*bottomTabView;
	//Scale
		IBOutlet NSPopUpButton	*bottomScalePopUp;
		IBOutlet NSMatrix			*bottomScaleMatrix;

	//Translate
		IBOutlet NSPopUpButton	*bottomTranslatePopUp;
		IBOutlet NSMatrix			*bottomTranslateMatrix;
	//Rotate
		IBOutlet NSPopUpButton	*bottomRotatePopUp;
		IBOutlet NSMatrix			*bottomRotateMatrix;
	//Phase
		IBOutlet NSTextField		*bottomPhaseEdit;
	//Frequency
		IBOutlet NSTextField		*bottomFrequencyEdit;
	//Turbulence
		IBOutlet NSPopUpButton	*bottomTurbulencePopUp;
		IBOutlet NSMatrix			*bottomTurbulenceMatrix;
		IBOutlet NSButton			*bottomTurbulenceOctavesOn;
		IBOutlet NSTextField		*bottomTurbulenceOctavesEdit;
		IBOutlet NSButton			*bottomTurbulenceOmegaOn;
		IBOutlet NSTextField		*bottomTurbulenceOmegaEdit;
		IBOutlet NSButton			*bottomTurbulenceLambdaOn;
		IBOutlet NSTextField 		*bottomTurbulenceLambdaEdit;
		IBOutlet NSButton			*bottomTurbulenceWarpOn;
	//RepeatWarp
		IBOutlet NSPopUpButton	*bottomRepeatWarpRepeatPopUp;
		IBOutlet NSTextField		*bottomRepeatWarpRepeatWidthEdit;
		IBOutlet NSButton			*bottomRepeatWarpOffsetOn;
		IBOutlet NSPopUpButton	*bottomRepeatWarpOffsetPopUp;
		IBOutlet NSMatrix			*bottomRepeatWarpOffsetMatrix;
		IBOutlet NSButton			*bottomRepeatWarpFlipX;
		IBOutlet NSButton			*bottomRepeatWarpFlipY;
		IBOutlet NSButton			*bottomRepeatWarpFlipZ;
	//BlackHole
		IBOutlet NSPopUpButton	*bottomBlackHoleCenterPopUp;
		IBOutlet NSMatrix			*bottomBlackHoleCenterMatrix;
		IBOutlet NSButton			*bottomBlackHoleInverseOn;
		IBOutlet NSTextField		*bottomBlackHoleRadiusEdit;
		IBOutlet NSButton			*bottomBlackHoleFalloffOn;
		IBOutlet NSTextField		*bottomBlackHoleFalloffEdit;
		IBOutlet NSButton			*bottomBlackHoleStrengthOn;
		IBOutlet NSTextField		*bottomBlackHoleStrengthEdit;
		IBOutlet NSButton			*bottomBlackHoleRepeatOn;
		IBOutlet NSPopUpButton	*bottomBlackHoleRepeatPopUp;
		IBOutlet NSMatrix			*bottomBlackHoleRepeatMatrix;
		IBOutlet NSButton			*bottomBlackHoleTurbulenceOn;
		IBOutlet NSPopUpButton	*bottomBlackHoleTurbulencePopUp;
		IBOutlet NSMatrix			*bottomBlackHoleTurbulenceMatrix;
	//matrix
		IBOutlet NSMatrix			*bottomMatrixMatrix;
	//displaceWarp
	//Warp3D
		IBOutlet NSPopUpButton	*bottomWarp3DTypePopUp;
		IBOutlet NSView				*bottomWarp3DDistExpView;
		IBOutlet NSView 				*bottomWarp3DDistanceView;
		IBOutlet NSView 				*bottomWarp3DNormalView;
		IBOutlet NSView				*bottomWarp3DOrientationView;

		IBOutlet NSButton			*bottomWarp3DDistExpOn;
		IBOutlet NSTextField		*bottomWarp3DDistExpEdit;
		IBOutlet NSTextField		*bottomWarp3DDistanceEdit;
		IBOutlet NSButton			*bottomWarp3DMajorRadiusOn;
		IBOutlet NSTextField		*bottomWarp3DMajorRadiusEdit;
		IBOutlet NSButton			*bottomWarp3DOrientationOn;
		IBOutlet NSMatrix			*bottomWarp3DOrientationMatrix;
		IBOutlet NSMatrix			*bottomWarp3DNormalMatrix;
   //extra for tooltips
   	IBOutlet NSButton				*topDisplaceWarpEditPatternbutton;
   	IBOutlet NSButton				*midDisplaceWarpEditPatternbutton;
   	IBOutlet NSButton				*bottomDisplaceWarpEditPatternbutton;
}

-(void) performTarget:(id) sender withObjects:(NSDictionary*) objects;


- (IBAction) topTarget:(id)sender;
- (IBAction) midTarget:(id)sender;
- (IBAction) bottomTarget:(id)sender;
-(IBAction) topEditWarpButton:(id)sender;
-(IBAction) midEditWarpButton:(id)sender;
-(IBAction) bottomEditWarpButton:(id)sender;

@end

