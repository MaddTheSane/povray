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


#import <Cocoa/Cocoa.h>
#import "baseTemplate.h"

#define normalTransformations mTemplatePrefs[0]
#define normalFunctionFunction mTemplatePrefs[2]

#define normalImageMapFunction mTemplatePrefs[3]				// for normalPatternImagePattern and normalImageMap
#define normalImageMapPatternNormal mTemplatePrefs[4]	// for normalPatternImagePattern and normalImageMap
#define normalImageMapNormal mTemplatePrefs[5]	// for normalPatternImagePattern and normalImageMap
#define normalPatternPigment mTemplatePrefs[6]	
#define normalPatternObjectOutsideNormal mTemplatePrefs[7]	
#define normalPatternObjectInsideNormal mTemplatePrefs[8]	
#define normalPatternObject mTemplatePrefs[9]	
#define normalPatternAverageEditNormal mTemplatePrefs[10]	
#define normalSlopemap mTemplatePrefs[11]	
#define normalNormalmap mTemplatePrefs[12]	

#define setNormalTransformations setTemplatePrefs:0 withObject
#define setNormalCamera setTemplatePrefs:1 withObject
#define setNormalFunctionFunction setTemplatePrefs:2 withObject

#define setNormalImageMapFunction setTemplatePrefs:3 withObject			// for normalPatternImagePattern and normalImageMap
#define setNormalImageMapPatternNormal setTemplatePrefs:4 withObject	// for normalPatternImagePattern and normalImageMap
#define setNormalImageMapNormal setTemplatePrefs:5 withObject	// for normalPatternImagePattern and normalImageMap

#define setNormalPatternPigment setTemplatePrefs:6 withObject	
#define setNormalPatternObjectOutsideNormal setTemplatePrefs:7 withObject	
#define setNormalPatternObjectInsideNormal setTemplatePrefs:8 withObject	
#define setNormalPatternObject setTemplatePrefs:9 withObject	
#define setNormalPatternAverageEditNormal setTemplatePrefs:10 withObject	
#define setNormalSlopemap setTemplatePrefs:11 withObject	
#define setNormalNormalmap setTemplatePrefs:12 withObject	

enum eNormalMainTab {
	cNormalPatternTab		=0,
	cNormalImageMapTab	=1,
	cNormalFunctionTab		=2
};
enum ePatternNormalCrackleType {
	cNormalDefault=0, cNormalFacets=2,	cNormalFrom=3,	
	cNormalMetric=4, cNormalOffset=5, cNormalSolid=6,
	cNormalCoords=0, cNormalSize=1
};

enum eBumpMapBumpHeight {
	cColor=0,
	cIndex=1
};

enum eFullNormal {
	cFullNormalBrick			=0,
	cFullNormalChecker	=1,
	cFullNormalHexagon	=2,
	cFullNormalAgate		=4,
	cFullNormalBozo			=5,
	cFullNormalBumps		=6,
	cFullNormalCells			=7,
	cFullNormalCrackle		=8,
	cFullNormalDents		=9,
	cFullNormalGradient	=10,
	cFullNormalGranite		=11,
	cFullNormalLeopard	=12,
	cFullNormalMandel		=13,
	cFullNormalMarble		=14,
	cFullNormalOnion		=15,
	cFullNormalQuilted		=16,
	cFullNormalRadial		=17,
	cFullNormalRipples		=18,
	cFullNormalSpiral1		=19,
	cFullNormalSpiral2		=20,
	cFullNormalWaves		=21,
	cFullNormalWood		=22,
	cFullNormalWrinkles	=24
};
	
enum eNormalPages{
	cNormalPatternBrick				=0,
	cNormalPatternChecker			=1,
	cNormalPatternHexagon			=2,
	cNormalPatternObject				=3,
	line11									=4,
	cNormalPatternAgate				=5,
	cNormalPatternAoi					=6,
	cNormalPatternBoxed				=7,
	cNormalPatternBozo				=8,
	cNormalPatternBumps			=9,
	cNormalPatternCells				=10,
	cNormalPatternCrackle			=11,
	cNormalPatternCylindrical		=12,
	cNormalPatternDensityFile		=13,
	cNormalPatternDents				=14,
	cNormalPatternFacets				=15,
	cNormalPatternFractals			=16,
	cNormalPatternGradient			=17,
	cNormalPatternGranite			=18,
	cNormalPatternImagePattern	=19,
	cNormalPatternLeopard			=20,
	cNormalPatternMarble			=21,
	cNormalPatternOnion				=22,
	cNormalPatternPigmentPattern=23,
	cNormalPatternPlanar				=24,
	cNormalPatternProjection		=25,
	cNormalPatternQuilted			=26,
	cNormalPatternRadial				=27,
	cNormalPatternRipples			=28,
	cNormalPatternSlope				=29,
	cNormalPatternSpherical			=30,
	cNormalPatternSpiral				=31,
	cNormalPatternWaves				=32,
	cNormalPatternWood				=33,
	cNormalPatternWrinkles			=34,
	line12									=35,
	cNormalPatternAverage			=36
};

enum eNormalTags {
	cNormalTransformationsOn						=1,
	cNormalTransformationsEditButton			=2,
	cNormalAmountOn									=3,
	cNormalAccuracyOn								=4,
	cNormalBumpSizeOn								=5,
	
	cNormalNormalSlopeMapOn					=6,
	cNormalNormalSlopeMapEditButton			=7,
	cNormalNormalMapOn							=8,
	cNnormalNormalMapEditButton				=9,
	cNormalWaveTypePopUpButton				=10,

	//pattern;
	cNormalPatternSelectPopUpButton 			=11,

	 	//brick
	cNormalPatternBrickFullNormalMatrix					=20,
	cNormalPatternBrickAmountOn							=21,
	cNormalPatternBrickBrickSizeOn							=22,
	cNormalPatternBrickMortarOn								=23,
			//brick1	
	cNormalPatternBrickFullNormal1AmountOn			=24,
	cNormalPatternBrickFullNormal1ScaleOn				=25,
	cNormalPatternBrickFullNormal1ScalePopUp			=26,
	cNormalPatternBrickFullNormal1TypePopUp			=200,
			//brick2	
	cNormalPatternBrickFullNormal2AmountOn			=27,
	cNormalPatternBrickFullNormal2ScaleOn				=28,
	cNormalPatternBrickFullNormal2ScalePopUp			=29,
	cNormalPatternBrickFullNormal2TypePopUp			=205,
	 	//checker
	cNormalPatternCheckerFullNormalMatrix				=30,
	cNormalPatternCheckerAmountOn						=31,
			//checker1	
	cNormalPatternCheckerFullNormal1AmountOn		=33,
	cNormalPatternCheckerFullNormal1ScaleOn			=34,
	cNormalPatternCheckerFullNormal1ScalePopUp	=35,
	cNormalPatternCheckerFullNormal1TypePopUp	=210,
			//checker2	
	cNormalPatternCheckerFullNormal2AmountOn		=36,
	cNormalPatternCheckerFullNormal2ScaleOn			=37,
	cNormalPatternCheckerFullNormal2ScalePopUp	=38,
	cNormalPatternCheckerFullNormal2TypePopUp	=215,

	 	//hexagon
	cNormalPatternHexagonFullNormalMatrix				=39,
	cNormalPatternHexagonAmountOn						=40,
			//hexagon1	
	cNormalPatternHexagonFullNormal1AmountOn		=42,
	cNormalPatternHexagonFullNormal1ScaleOn			=43,
	cNormalPatternHexagonFullNormal1ScalePopUp	=44,
	cNormalPatternHexagonFullNormal1TypePopUp	=220,
			//hexagon2	
	cNormalPatternHexagonFullNormal2AmountOn		=45,
	cNormalPatternHexagonFullNormal2ScaleOn			=46,
	cNormalPatternHexagonFullNormal2ScalePopUp	=47,
	cNormalPatternHexagonFullNormal2TypePopUp	=225,
			//hexagon3	
	cNormalPatternHexagonFullNormal3AmountOn		=48,
	cNormalPatternHexagonFullNormal3ScaleOn			=49,
	cNormalPatternHexagonFullNormal3ScalePopUp	=50,
	cNormalPatternHexagonFullNormal3TypePopUp	=230,

		//object
		cNormalPatternObjectEditInsideNormal	=55,
		cNormalPatternObjectEditOutsideNormal	=56,
		cNormalPatternObjectEditObject				=57,
		//agate
		//aoi
		//crackle
		cNormalPatternCrackleType1On				=60,
		cNormalPatternCrackleType1PopUp			=61,	
		cNormalPatternCrackleType2On				=62,
		cNormalPatternCrackleType2PopUp			=63,	
		cNormalPatternCrackleType3On				=64,
		cNormalPatternCrackleType3PopUp			=65,	
		cNormalPatternCrackleType4On				=66,
		cNormalPatternCrackleType4PopUp			=67,	


		//density file
		cNormalPatternDisityFileSelectFileButton	=70,
		//facets
		cNormalPatternFacetsSizeOn					=75,
		cNormalPatternFacetsCoordsOn				=76,
		//factals
		cPnormalPatternFractalsTypePopUp			=80,
	 	cNormalPatternFractalsExponentOn			=81,
	 	cNormalPatternFractalsInteriorTypeOn		=82,
	 	cNormalPatternFractalsExteriorTypeOn		=83,
		//gradient
		cNormalPatternGradientXYZPopUp			=90,
		//image pattern
		cNormalPatternImagePatternFileTypePopUp				=100,
	 	cNormalPatternImagePatternEditFunctionButton			=101,
	 	cNormalPatternImagePatternEditPatternButton			=102,
	 	cNormalPatternImagePatternSelectImageFileButton	=103,
	 	cNormalPatternImagePatternEditNormalButton			=104,
		cNormalPatternImageMapProjectionPopUp				=105,

		//normal pattern
		cNormalPatternPigmentPatternEditNormal		=110,
		//projection
		cNormalPatternProjectionEditObjectButton	=120,
		cNormalPatternProjectionNormalPopUp		=121,
		cNormalPatternProjectionXYZPopUp				=122,
		cNormalPatternProjectionBlurOn					=123,
		//slope
		cNormalPatternSlopeDirectionXYZPopUp		=130,
		cNormalPatternSlopeSlopeOn						=131,
		cNormalPatternSlopeAltitudeOn					=132,
		cNormalPatternSlopeAltitudeXYZPopUp		=133,
		cNormalPatternSlopeOffsetOn						=134,
		//average
		cNormalPatternAverageEditNormal				=140,
	//normal image map
		cNormalImageMapFileTypePopUp				=150,
	 	cNormalImageMapEditFunctionButton			=151,
	 	cNormalImageMapEditPatternButton				=152,
		cNormalImageMapSelectImageFileButton		=153,
		cNormalImageMapEditNormalButton			=154,
		cNormalImageMapProjectionPopUp				=155,
	//normal function
		cNormalFunctionEditFunctionButton				=160,
};

@interface NormalTemplate : BaseTemplate
{

	//main
	IBOutlet NSView						*normalMainViewNIBView;						//view in NIB file, contains everything
	IBOutlet NSView						*normalMainViewHolderView;	
	IBOutlet NSButton 					*normalDontWrapInNormal;

	IBOutlet NSTabView 				*normalMainTabView;
	IBOutlet NSButton 					*normalTransformationsOn;
	IBOutlet NSButton					*normalTransformationsEditButton;
	IBOutlet NSButton 					*normalAmountOn;
	IBOutlet NSTextField				*normalAmountEdit;
	IBOutlet NSButton 					*normalAccuracyOn;
	IBOutlet NSTextField				*normalAccuracyEdit;
	IBOutlet NSButton 					*normalBumpSizeOn;
	IBOutlet NSTextField				*normalBumpSizeEdit;
	IBOutlet NSButton					*normalNoBumpScaleOn;
	
	IBOutlet NSButton 					*normalNormalSlopeMapOn;
	IBOutlet NSButton					*normalNormalSlopeMapEditButton;
	IBOutlet NSButton 					*normalNormalMapOn;
	IBOutlet NSButton					*normalNormalMapEditButton;
	IBOutlet NSPopUpButton			*normalWaveTypePopUpButton;
	IBOutlet NSTextField				*normalWaveTypeEdit;
	IBOutlet NSTextField				*normalWaveTypeText;

	//pattern;
	IBOutlet NSPopUpButton 			*normalPatternSelectPopUpButton;
	IBOutlet NSTabView				*normalPatternTabView;
	
	 	//brick
		IBOutlet NSMatrix			*normalPatternBrickFullNormalMatrix;
		IBOutlet NSBox				*normalPatternBrickFullNormalGroup;
		IBOutlet NSButton			*normalPatternBrickAmountOn;
		IBOutlet NSTextField		*normalPatternBrickAmountEdit;
	 	IBOutlet NSButton			*normalPatternBrickBrickSizeOn;
	 	IBOutlet NSMatrix			*normalPatternBrickBrickSizeMatrix;
		IBOutlet NSButton 			*normalPatternBrickMortarOn;
	 	IBOutlet NSTextField		*normalPatternBrickMortarEdit;
			//brick1	
		IBOutlet NSPopUpButton	*normalPatternBrickFullNormal1TypePopUp;
		IBOutlet NSButton 			*normalPatternBrickFullNormal1AmountOn;
	 	IBOutlet NSTextField		*normalPatternBrickFullNormal1AmountEdit;
	 	IBOutlet NSButton			*normalPatternBrickFullNormal1ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternBrickFullNormal1ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternBrickFullNormal1ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternBrickFullNormal1ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternBrickFullNormal1ArmsPopUp;
			//brick2	
		IBOutlet NSPopUpButton	*normalPatternBrickFullNormal2TypePopUp;
		IBOutlet NSButton 			*normalPatternBrickFullNormal2AmountOn;
	 	IBOutlet NSTextField		*normalPatternBrickFullNormal2AmountEdit;
	 	IBOutlet NSButton			*normalPatternBrickFullNormal2ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternBrickFullNormal2ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternBrickFullNormal2ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternBrickFullNormal2ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternBrickFullNormal2ArmsPopUp;


	 	//checker
		IBOutlet NSMatrix			*normalPatternCheckerFullNormalMatrix;
		IBOutlet NSBox				*normalPatternCheckerFullNormalGroup;
		IBOutlet NSButton			*normalPatternCheckerAmountOn;
		IBOutlet NSTextField		*normalPatternCheckerAmountEdit;
			//checker1	
		IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal1TypePopUp;
		IBOutlet NSButton 			*normalPatternCheckerFullNormal1AmountOn;
	 	IBOutlet NSTextField		*normalPatternCheckerFullNormal1AmountEdit;
	 	IBOutlet NSButton			*normalPatternCheckerFullNormal1ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal1ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternCheckerFullNormal1ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternCheckerFullNormal1ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal1ArmsPopUp;
			//checker2	
		IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal2TypePopUp;
		IBOutlet NSButton 			*normalPatternCheckerFullNormal2AmountOn;
	 	IBOutlet NSTextField		*normalPatternCheckerFullNormal2AmountEdit;
	 	IBOutlet NSButton			*normalPatternCheckerFullNormal2ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal2ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternCheckerFullNormal2ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternCheckerFullNormal2ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternCheckerFullNormal2ArmsPopUp;

	 	//hexagon
		IBOutlet NSMatrix			*normalPatternHexagonFullNormalMatrix;
		IBOutlet NSBox				*normalPatternHexagonFullNormalGroup;
		IBOutlet NSButton			*normalPatternHexagonAmountOn;
		IBOutlet NSTextField		*normalPatternHexagonAmountEdit;
			//hexagon1	
		IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal1TypePopUp;
		IBOutlet NSButton 			*normalPatternHexagonFullNormal1AmountOn;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal1AmountEdit;
	 	IBOutlet NSButton			*normalPatternHexagonFullNormal1ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal1ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternHexagonFullNormal1ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal1ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal1ArmsPopUp;
			//hexagon2	
		IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal2TypePopUp;
		IBOutlet NSButton 			*normalPatternHexagonFullNormal2AmountOn;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal2AmountEdit;
	 	IBOutlet NSButton			*normalPatternHexagonFullNormal2ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal2ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternHexagonFullNormal2ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal2ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal2ArmsPopUp;
			//hexagon3	
		IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal3TypePopUp;
		IBOutlet NSButton 			*normalPatternHexagonFullNormal3AmountOn;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal3AmountEdit;
	 	IBOutlet NSButton			*normalPatternHexagonFullNormal3ScaleOn;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal3ScalePopUp;
	 	IBOutlet NSMatrix			*normalPatternHexagonFullNormal3ScaleMatrix;
	 	IBOutlet NSTextField		*normalPatternHexagonFullNormal3ArmsText;
	 	IBOutlet NSPopUpButton	*normalPatternHexagonFullNormal3ArmsPopUp;

	 	//object
		IBOutlet NSButton 			*normalPatternObjectEditObjectButton;
		IBOutlet NSButton 			*normalPatternObjectEditOutsideObjectButton;
		IBOutlet NSButton 			*normalPatternObjectEditInsideObjectButton;

	//------- 	
	 	//agate
	 	//aoi
	 	//boxed
	 	//bozo
	 	//bumps
	 	//cells
	 	//crackle
		IBOutlet NSButton			*normalPatternCrackleType1On;
		IBOutlet NSPopUpButton	*normalPatternCrackleType1PopUp;
		IBOutlet NSView				*normalPatternCrackleType1MatrixView;
		IBOutlet NSMatrix			*normalPatternCrackleType1Matrix;
		IBOutlet NSTextField		*normalPatternCrackleType1Edit;
		IBOutlet NSButton			*normalPatternCrackleType2On;
		IBOutlet NSPopUpButton	*normalPatternCrackleType2PopUp;				
		IBOutlet NSView				*normalPatternCrackleType2MatrixView;
		IBOutlet NSMatrix			*normalPatternCrackleType2Matrix;
		IBOutlet NSTextField		*normalPatternCrackleType2Edit;
		IBOutlet NSButton			*normalPatternCrackleType3On;
		IBOutlet NSPopUpButton	*normalPatternCrackleType3PopUp;				
		IBOutlet NSView				*normalPatternCrackleType3MatrixView;
		IBOutlet NSMatrix			*normalPatternCrackleType3Matrix;
		IBOutlet NSTextField		*normalPatternCrackleType3Edit;
		IBOutlet NSButton			*normalPatternCrackleType4On;
		IBOutlet NSPopUpButton	*normalPatternCrackleType4PopUp;				
		IBOutlet NSView				*normalPatternCrackleType4MatrixView;
		IBOutlet NSMatrix			*normalPatternCrackleType4Matrix;
		IBOutlet NSTextField		*normalPatternCrackleType4Edit;


	//cylindrical
	//density_file
		IBOutlet NSTextField		*normalPatternDisityFileFileNameEdit;
		IBOutlet NSPopUpButton	*normalPatternDisityFileInterpolationPopUp;
	//dents
	//facets
		IBOutlet NSTextField		*normalPatternFacetsCoordsEdit;
		IBOutlet NSButton			*normalPatternFacetsCoordsOn;
		IBOutlet NSTextField		*normalPatternFacetsSizeEdit;
		IBOutlet NSButton			*normalPatternFacetsSizeOn;
		
	//fractals
	 	IBOutlet NSPopUpButton	*normalPatternFractalsTypePopUp;
	 	IBOutlet NSView				*normalPatternFractalsTypeXYView;
	 	IBOutlet NSTextField		*normalPatternFractalsTypeXEdit;
	 	IBOutlet NSTextField		*normalPatternFractalsTypeYEdit;
	 	IBOutlet NSView				*normalPatternFractalsExponentView;
	 	IBOutlet NSButton			*normalPatternFractalsExponentOn;
	 	IBOutlet NSTextField		*normalPatternFractalsExponentEdit;
	 	IBOutlet NSTextField		*normalPatternFractalsMaxIterationsEdit;
	 	IBOutlet NSButton			*normalPatternFractalsInteriorTypeOn;
	 	IBOutlet NSPopUpButton	*normalPatternFractalsInteriorTypePopUp;
	 	IBOutlet NSTextField		*normalPatternFractalsInteriorTypeFactorEdit;
	 	IBOutlet NSTextField		*normalPatternFractalsInteriorTypeFactorText;
	 	IBOutlet NSButton			*normalPatternFractalsExteriorTypeOn;
	 	IBOutlet NSPopUpButton	*normalPatternFractalsExteriorTypePopUp;
	 	IBOutlet NSTextField		*normalPatternFractalsExteriorTypeFactorEdit;
	 	IBOutlet NSTextField		*normalPatternFractalsExteriorTypeFactorText;

	 	//gradient
	 	IBOutlet NSPopUpButton	*normalPatternGradientXYZPopUp;
	 	IBOutlet NSMatrix			*normalPatternGradientMatrix;
	 	//granite
	 	//image_pattern
		IBOutlet NSPopUpButton	*normalPatternImagePatternFileTypePopUp;
	 	IBOutlet NSView 				*normalPatternImagePatternFileView;
 	 	IBOutlet NSView 				*normalPatternImagePatternWidthHeightView;
		IBOutlet NSTextField 		*normalPatternImagePatternFileNameEdit;
	 	IBOutlet NSView 				*normalPatternImagePatternFunctionView;
	 	IBOutlet NSTextView		*normalPatternImagePatternFunctionFunctionEdit;
	 	IBOutlet NSTextField 		*normalPatternImagePatternFunctionImageWidth;
	 	IBOutlet NSTextField 		*normalPatternImagePatternFunctionImageHeight;
	 	IBOutlet NSView 				*normalPatternImagePatternPatternView;
	 	IBOutlet NSView 				*normalPatternImagePatternPigmentView;
		IBOutlet NSPopUpButton 	*normalPatternImageMapProjectionPopUp;
		IBOutlet NSButton 			*normalPatternImageMapProjectionOnceOn;
		IBOutlet NSPopUpButton 	*normalPatternImageMapInterpolationPopUp;
		IBOutlet NSPopUpButton 	*normalPatternImageMapUsePopUp;
	 	
	 		 		 		 	
	 	//leopard
	 	//marble
	 	//onion
	 	//pigment_pattern
	 	//planar
	 	//projection
	 	IBOutlet NSPopUpButton	*normalPatternProjectionNormalPopUp;
		IBOutlet NSView				*normalPatternProjectionView;
	 	IBOutlet NSPopUpButton	*normalPatternProjectionXYZPopUp;
	 	IBOutlet NSMatrix			*normalPatternProjectionXYZMatrix	;
	 	IBOutlet NSButton			*normalPatternProjectionBlurOn;
		IBOutlet NSTextField		*normalPatternProjectionAmountEdit;
		IBOutlet NSTextField		*normalPatternProjectionAmountText;
		IBOutlet NSTextField		*normalPatternProjectionSamplesEdit;
		IBOutlet NSTextField		*normalPatternProjectionSamplesText;
	 	//quilted
	 	IBOutlet NSTextField		*normalPatternQuiltedControl0Edit;
	 	IBOutlet NSTextField		*normalPatternQuiltedControl1Edit;
	 	//radial
	 	//ripples
	 	//slope
	 	IBOutlet NSPopUpButton	*normalPatternSlopeDirectionXYZPopUp;
	 	IBOutlet NSMatrix			*normalPatternSlopeDirectionMatrix;
	 	IBOutlet NSButton			*normalPatternSlopeSlopeOn;
	 	IBOutlet NSTextField		*normalPatternSlopeSlopeLowText;
	 	IBOutlet NSTextField		*normalPatternSlopeSlopeLowEdit;
	 	IBOutlet NSTextField		*normalPatternSlopeSlopeHighText;
	 	IBOutlet NSTextField		*normalPatternSlopeSlopeHighEdit;
	 	IBOutlet NSButton			*normalPatternSlopeAltitudeOn;
	 	IBOutlet NSPopUpButton	*normalPatternSlopeAltitudeXYZPopUp;
	 	IBOutlet NSMatrix			*normalPatternSlopeAltitudeMatrix;
	 	IBOutlet NSButton			*normalPatternSlopeOffsetOn;
	 	IBOutlet NSTextField		*normalPatternSlopeOffsetLowText;
	 	IBOutlet NSTextField		*normalPatternSlopeOffsetLowEdit;
	 	IBOutlet NSTextField		*normalPatternSlopeOffsetHighText;
	 	IBOutlet NSTextField		*normalPatternSlopeOffsetHighEdit;
	 	//spherical
	 	//spiral
	 	IBOutlet NSView				*normalPatternSpiralTypePopUp;
	 	IBOutlet NSTextField		*normalPatternSpiralNrOfArmsEdit;
	 	//waves
	 	//wood
	 	//wrinkles
 	//---------
		//average
// normalImageMap
		IBOutlet NSPopUpButton 		*normalImageMapFileTypePopUp;
	 	IBOutlet NSView 					*normalImageMapFileView;
	 	IBOutlet NSView					*normalImageMapWidthHeightView;
 		IBOutlet NSTextField 			*normalImageMapFileName;
	 	IBOutlet NSView 					*normalImageMapFunctionView;
	 	IBOutlet NSTextView			*normalImageMapFunctionEdit;
	 	IBOutlet NSTextField 			*normalImageMapFunctionImageWidth;
	 	IBOutlet NSTextField 			*normalImageMapFunctionImageHeight;
	 	IBOutlet NSView 					*normalImageMapPatternView;
	 	IBOutlet NSView 					*normalImageMapPigmentView;
		IBOutlet NSPopUpButton 		*normalImageMapProjectionPopUp;
		IBOutlet NSButton 				*normalImageMapProjectionOnceOn;
		IBOutlet NSPopUpButton 		*normalImageMapInterpolationPopUp;
		IBOutlet NSPopUpButton 		*normalImageMapGetBumpHeightPopUp;

// normalFunction
		IBOutlet NSTextView 			*normalFunctionEdit;
	//extra for tooltips
	IBOutlet NSButtonCell 					*normalPatternBrickFullNormal;
	IBOutlet NSButtonCell 					*normalPatternCheckerFullNormal;
	IBOutlet NSButtonCell 					*normalPatternHexagonFullNormal;
	
	IBOutlet NSButton						*normalPatternDisityFileFileEditButton;

	IBOutlet NSButton						*normalPatternImagePatternFileNameButton;
	IBOutlet NSButton						*normalPatternImagePatternPatternButton;
	IBOutlet NSButton						*normalPatternImagePatternPigmentButton;
	IBOutlet NSButton						*normalPatternImagePatternFunctionFunctionButton;

	IBOutlet NSButton						*normalImageMapFileButton;
	IBOutlet NSButton						*normalImageMapPatternButton;
	IBOutlet NSButton						*normalImageMapPigmentButton;
	IBOutlet NSButton						*normalImageMapFunctionButton;

	IBOutlet NSButton						*normalPatternProjectionObjectButton;
	IBOutlet NSButton						*normalFunctionEditButton;
}
-(NSView*) normalMainViewNIBView;

-(IBAction) normalButtons:(id)sender;
-(IBAction) normalTarget:(id)sender;
-(IBAction) normalPatternSelectPopUpButton:(id)sender;

@end
