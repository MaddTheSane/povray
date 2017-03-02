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
#import "mapPreview.h"

#define pigmentTransformations mTemplatePrefs[0]
#define pigmentCamera mTemplatePrefs[1]
#define pigmentFunctionFunction mTemplatePrefs[2]

#define pigmentImageMapFunction mTemplatePrefs[3]				// for pigmentColorPatternImagePattern and pigmentImageMap
#define pigmentImageMapPatternPigment mTemplatePrefs[4]	// for pigmentColorPatternImagePattern and pigmentImageMap
#define pigmentImageMapPigmentPigment mTemplatePrefs[5]	// for pigmentColorPatternImagePattern and pigmentImageMap
#define pigmentColorPatternPigmentPattern mTemplatePrefs[6]	
#define pigmentColorPatternObjectOutsidePigment mTemplatePrefs[7]	
#define pigmentColorPatternObjectInsidePigment mTemplatePrefs[8]	
#define pigmentColorPatternObject mTemplatePrefs[9]	
#define pigmentColorPatternAverageEditPigment mTemplatePrefs[10]	
#define pigmentColorMapEditPigmentMap mTemplatePrefs[11]	

#define setPigmentTransformations setTemplatePrefs:0 withObject
#define setPigmentCamera setTemplatePrefs:1 withObject
#define setPigmentFunctionFunction setTemplatePrefs:2 withObject

#define setPigmentImageMapFunction setTemplatePrefs:3 withObject			// for pigmentColorPatternImagePattern and pigmentImageMap
#define setPigmentImageMapPatternPigment setTemplatePrefs:4 withObject	// for pigmentColorPatternImagePattern and pigmentImageMap
#define setPigmentImageMapPigmentPigment setTemplatePrefs:5 withObject	// for pigmentColorPatternImagePattern and pigmentImageMap

#define setPigmentColorPatternPigmentPattern setTemplatePrefs:6 withObject	
#define setPigmentColorPatternObjectOutsidePigment setTemplatePrefs:7 withObject	
#define setPigmentColorPatternObjectInsidePigment setTemplatePrefs:8 withObject	
#define setPigmentColorPatternObject setTemplatePrefs:9 withObject	
#define setPigmentColorPatternAverageEditPigment setTemplatePrefs:10 withObject	
#define setPigmentColorMapEditPigmentMap setTemplatePrefs:11 withObject	

enum ePigmentMainTab {
	cPigmentFullColorTab 		=0,
	cPigmentColorPatternTab	=1,
	cPigmentImageMapTab			=2,
	cPigmentFunctionTab			=3
};
	
enum ePigmentPages{
	cPigmentPatternBrick				=0,
	cPigmentPatternChecker			=1,
	cPigmentPatternHexagon			=2,
	cPigmentPatternObject				=3,
	cPigmentPatternSquare				=4,
	cPigmentPatternTriangular		=5,
	line1												,
	cPigmentPatternAgate				,
	cPigmentPatternAoi					,
	cPigmentPatternBoxed				,
	cPigmentPatternBozo					,
	cPigmentPatternBumps				,
	cPigmentPatternCells				,
	cPigmentPatternCrackle			,
	cPigmentPatternCylindrical	,
	cPigmentPatternDensityFile	,
	cPigmentPatternDents				,
	cPigmentPatternFractals			,
	cPigmentPatternGradient			,
	cPigmentPatternGranite			,
	cPigmentPatternImagePattern	,
	cPigmentPatternLeopard				,
	cPigmentPatternMarble					,
	cPigmentPatternOnion					,
	cPigmentPavement							,
	cPigmentPatternPigmentPattern	,
	cPigmentPatternPlanar					,
	cPigmentPatternQuilted				,
	cPigmentPatternRadial					,
	cPigmentPatternRipples				,
	cPigmentPatternSlope					,
	cPigmentPatternSpherical			,
	cPigmentPatternSpiral					,
	cPigmentPatternTiling					,
	cPigmentPatternWaves					,
	cPigmentPatternWood						,
	cPigmentPatternWrinkles				,
	line2													,
	cPigmentPatternAverage
};


enum ePigmentNoise {
	cPlainColor=0,	cPlainMonochrome=1, cGaussianColor=2, cGaussianMonochrome=3
};


enum ePigmentTags {
	cPigmentColorMapEditCustomizedColorMap	=10,
	cPigmentColorMapEditPigmentMap					=11,
	cPigmentTransformationsOn								=13,
	cPigmentTransformationsEditButton				=14,
	cPigmentQuickColorOn										=15,
	
	//full Color
	cPigmentFullColorColorWell							=20,
	cPigmentFullColorAddCommentOn						=21,
	//color pattern
	cPigmentColorPatternWaveTypePopUpButton	=22,
	cPigmentColorPatternSelectPopUpButton 	=30,
		//brick
		//checker
		//hexagon
		//object
		cPigmentColorPatternObjectEditInsidePigment		=40,
		cPigmentColorPatternObjectEditOutsidePigment	=41,
		cPigmentColorPatternObjectEditObject					=42,
		//aoi
		//crackle
		cPigmentColorPatternCrackleType1On			=60,
		cPigmentColorPatternCrackleType1PopUp		=61,
		cPigmentColorPatternCrackleType2On			=62,
		cPigmentColorPatternCrackleType2PopUp		=63,
		cPigmentColorPatternCrackleType3On			=64,
		cPigmentColorPatternCrackleType3PopUp		=65,
		cPigmentColorPatternCrackleType4On			=66,
		cPigmentColorPatternCrackleType4PopUp		=67,
		//density file
		cPigmentColorPatternDisityFileSelectFileButton		=70,
		//factals
		cPpigmentColorPatternFractalsTypePopUp			=80,
	 	cPigmentColorPatternFractalsExponentOn			=81,
	 	cPigmentColorPatternFractalsInteriorTypeOn	=82,
	 	cPigmentColorPatternFractalsExteriorTypeOn	=83,
		//gradient
		cPigmentColorPatternGradientXYZPopUp				=90,
		//image pattern
		cPigmentColorPatternImagePatternFileTypePopUp					=100,
	 	cPigmentColorPatternImagePatternEditFunctionButton		=101,
	 	cPigmentColorPatternImagePatternEditPatternButton			=102,
	 	cPigmentColorPatternImagePatternSelectImageFileButton	=103,
	 	cPigmentColorPatternImagePatternEditPigmentButton			=104,
		cPigmentColorPatternImageMapProjectionPopUp						=105,
	 	
		//pavement
	 	cPigmentColorPatternPavementSidesPopUp		=120,
	 	cPigmentColorPatternPavementTilesPopUp		=121,
		cPavementSidesTriangle	=0,
		cPavementSidesSquare			=1,
		cPavementSidesHexagon	=2,

		//pigment pattern
		cPigmentColorPatternPigmentPatternEditPigment		=110,

		//slope
		cPigmentColorPatternSlopeDirectionXYZPopUp	=130,
		cPigmentColorPatternSlopeSlopeOn						=131,
		cPigmentColorPatternSlopeAltitudeOn					=132,
		cPigmentColorPatternSlopeAltitudeXYZPopUp		=133,
		cPigmentColorPatternSlopeOffsetOn						=134,
		//average
		cPigmentColorPatternAverageEditPigment	=140,
	//pigment image map
		cPigmentImageMapFileTypePopUp					=150,
	 	cPigmentImageMapEditFunctionButton		=151,
	 	cPigmentImageMapEditPatternButton			=152,
		cPigmentImageMapSelectImageFileButton	=153,
		cPigmentImageMapEditPigmentButton			=154,
		cPigmentImageMapProjectionPopUp				=155,
		cPigmentImageMapFilerAllOn						=156,
		cPigmentImageMapTransmitAllOn					=157,
	//pigment function
		cPigmentFunctionEditFunctionButton		=160,
		cPigmentFunctionWaveTypePopUpButton		=161
};



@interface PigmentTemplate : BaseTemplate
{

	NSArray								*mPigmentPatternColormapViewArray;
	IBOutlet NSView				*pigmentMainViewNIBView;						//view in NIB file, contains everything
	IBOutlet NSView				*pigmentColorPatternMapTypeNIBView;	//vie win NIB file, containts color map
	//main
	IBOutlet NSView				*pigmentMainViewHolderView;
	IBOutlet NSButton			*pigmentDontWrapInPigment;

	IBOutlet NSTabView		*pigmentMainTabView;
	IBOutlet NSButton			*pigmentTransformationsOn;
	IBOutlet NSButton			*pigmentTransformationsEditButton;
	IBOutlet NSColorWell	*pigmentQuickColorColorWell;
	IBOutlet NSButton 		*pigmentQuickColorOn;
	
	//full color
	IBOutlet NSColorWell	*pigmentFullColorColorWell;
	IBOutlet NSButton			*pigmentFullColorAddCommentOn;
	IBOutlet NSTextField	*pigmentFullColorCommentTextField;
	
	//color map for pattern and image map
	IBOutlet NSTabView				*pigmentColorMapTabView;
	IBOutlet colormapPreview	*pigmentColorMapBlackAndWhitePreview;
	IBOutlet colormapPreview	*pigmentColorMapRainbowPreview;
	IBOutlet colormapPreview	*pigmentColorMapCustomizedPreview;
	
	//color pattern;
	IBOutlet NSPopUpButton 	*pigmentColorPatternSelectPopUpButton;
	IBOutlet NSTabView			*pigmentColorPatternTabView;
	IBOutlet NSView					*pigmentColorPatternWaveTypeView;
	IBOutlet NSPopUpButton	*pigmentColorPatternWaveTypePopUpButton;
	IBOutlet NSTextField		*pigmentColorPatternWaveTypeEdit;
	
	 	//brick
	 	IBOutlet NSMatrix				*pigmentColorPatternBrickBrickSizeMatrix;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternBrickBrickColor;
	 	IBOutlet NSTextField		*pigmentColorPatternBrickMortarEdit;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternBrickMortarColor;
	 	//checker
	 	IBOutlet MPFTColorWell	*pigmentColorPatternCheckerColor1;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternCheckerColor2;
	 	//hexagon
	 	IBOutlet MPFTColorWell	*pigmentColorPatternHexagonColor1;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternHexagonColor2;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternHexagonColor3;
	 	//object
	 	//Square
	 	IBOutlet MPFTColorWell	*pigmentColorPatternSquareColor1;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternSquareColor2;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternSquareColor3;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternSquareColor4;

	 	//Triangular
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor1;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor2;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor3;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor4;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor5;
	 	IBOutlet MPFTColorWell	*pigmentColorPatternTriangularColor6;

	//-------
	 	//agate
	 	IBOutlet NSView				*pigmentColorPatternAgateColorMapView;
	 	IBOutlet NSTextField 	*pigmentColorPatternAgateTurbEdit;
	 	//aoi
	 	IBOutlet NSView					*pigmentColorPatternAoiColorMapView;
	 	
	 	//boxed
	 	IBOutlet NSView				*pigmentColorPatternBoxedColorMapView;
	 	//bozo
	 	IBOutlet NSView				*pigmentColorPatternBozoColorMapView;
	 	//bumps
	 	IBOutlet NSView				*pigmentColorPatternBumpsColorMapView;
	 	//cells
	 	IBOutlet NSView				*pigmentColorPatternCellsColorMapView;
	 	//crackle
	 	IBOutlet NSView					*pigmentColorPatternCrackleColorMapView;
		IBOutlet NSButton				*pigmentColorPatternCrackleType1On;
		IBOutlet NSPopUpButton	*pigmentColorPatternCrackleType1PopUp;
		IBOutlet NSView					*pigmentColorPatternCrackleType1MatrixView;
		IBOutlet NSMatrix				*pigmentColorPatternCrackleType1Matrix;
		IBOutlet NSTextField		*pigmentColorPatternCrackleType1Edit;
		IBOutlet NSButton				*pigmentColorPatternCrackleType2On;
		IBOutlet NSPopUpButton	*pigmentColorPatternCrackleType2PopUp;				
		IBOutlet NSView					*pigmentColorPatternCrackleType2MatrixView;
		IBOutlet NSMatrix				*pigmentColorPatternCrackleType2Matrix;
		IBOutlet NSTextField		*pigmentColorPatternCrackleType2Edit;
		IBOutlet NSButton				*pigmentColorPatternCrackleType3On;
		IBOutlet NSPopUpButton	*pigmentColorPatternCrackleType3PopUp;				
		IBOutlet NSView					*pigmentColorPatternCrackleType3MatrixView;
		IBOutlet NSMatrix				*pigmentColorPatternCrackleType3Matrix;
		IBOutlet NSTextField		*pigmentColorPatternCrackleType3Edit;
		IBOutlet NSButton				*pigmentColorPatternCrackleType4On;
		IBOutlet NSPopUpButton	*pigmentColorPatternCrackleType4PopUp;				
		IBOutlet NSView					*pigmentColorPatternCrackleType4MatrixView;
		IBOutlet NSMatrix				*pigmentColorPatternCrackleType4Matrix;
		IBOutlet NSTextField		*pigmentColorPatternCrackleType4Edit;
	//cylindrical
	 	IBOutlet NSView					*pigmentColorPatternCylindricalColorMapView;
	//density_file
	 	IBOutlet NSView					*pigmentColorPatternDensityFileColorMapView;
		IBOutlet NSTextField		*pigmentColorPatternDisityFileFileNameEdit;
		IBOutlet NSPopUpButton	*pigmentColorPatternDisityFileInterpolationPopUp;
	//dents
	 	IBOutlet NSView					*pigmentColorPatternDentsColorMapView;
	//fractals
	 	IBOutlet NSView					*pigmentColorPatternFractalsColorMapView;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternFractalsTypePopUp;
	 	IBOutlet NSView					*pigmentColorPatternFractalsTypeXYView;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsTypeXEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsTypeYEdit;
	 	IBOutlet NSView					*pigmentColorPatternFractalsExponentView;
	 	IBOutlet NSButton				*pigmentColorPatternFractalsExponentOn;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsExponentEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsMaxIterationsEdit;
	 	IBOutlet NSButton				*pigmentColorPatternFractalsInteriorTypeOn;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternFractalsInteriorTypePopUp;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsInteriorTypeFactorEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsInteriorTypeFactorText;
	 	IBOutlet NSButton				*pigmentColorPatternFractalsExteriorTypeOn;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternFractalsExteriorTypePopUp;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsExteriorTypeFactorEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternFractalsExteriorTypeFactorText;

	 	//gradient
	 	IBOutlet NSView					*pigmentColorPatternGradientColorMapView;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternGradientXYZPopUp;
	 	IBOutlet NSMatrix				*pigmentColorPatternGradientMatrix;
	 	//granite
	 	IBOutlet NSView					*pigmentColorPatternGraniteColorMapView;
	 	//image_pattern
	 	IBOutlet NSView					*pigmentColorPatternImagePatternColorMapView;
		IBOutlet NSPopUpButton	*pigmentColorPatternImagePatternFileTypePopUp;
	 	IBOutlet NSView 				*pigmentColorPatternImagePatternFileView;
 	 	IBOutlet NSView 				*pigmentColorPatternImagePatternWidthHeightView;
		IBOutlet NSTextField 		*pigmentColorPatternImagePatternFileNameEdit;
	 	IBOutlet NSView 				*pigmentColorPatternImagePatternFunctionView;
	 	IBOutlet NSTextView			*pigmentColorPatternImagePatternFunctionFunctionEdit;
	 	IBOutlet NSTextField 		*pigmentColorPatternImagePatternFunctionImageWidth;
	 	IBOutlet NSTextField 		*pigmentColorPatternImagePatternFunctionImageHeight;
	 	IBOutlet NSView 				*pigmentColorPatternImagePatternPatternView;
	 	IBOutlet NSView 				*pigmentColorPatternImagePatternPigmentView;
		IBOutlet NSPopUpButton 	*pigmentColorPatternImageMapProjectionPopUp;
		IBOutlet NSButton 			*pigmentColorPatternImageMapProjectionOnceOn;
		IBOutlet NSPopUpButton 	*pigmentColorPatternImageMapInterpolationPopUp;
		IBOutlet NSPopUpButton 	*pigmentColorPatternImageMapUsePopUp;
	 	
	 		 		 		 	
	 	//leopard
	 	IBOutlet NSView				*pigmentColorPatternLeopardColorMapView;
	 	//marble
	 	IBOutlet NSView				*pigmentColorPatternMarbleColorMapView;
	 	//onion
	 	IBOutlet NSView				*pigmentColorPatternOnionColorMapView;
	 	//pavement
	 	IBOutlet NSView					*pigmentColorPatternPavementColorMapView;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementSidesPopUp;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementTilesPopUp;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementPatternPopUp;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementFormPopUp;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementInteriorPopUp;
		IBOutlet NSBox					*pgimentColorPatternPavementExtriorGroupBox;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternPavementExteriorPopUp;


	 	//pigment_pattern
	 	IBOutlet NSView				*pigmentColorPatternPigmentPatternColorMapView;
	 	//planar
	 	IBOutlet NSView				*pigmentColorPatternPlanarColorMapView;
	 	//quilted
	 	IBOutlet NSView					*pigmentColorPatternQuiltedColorMapView;
	 	IBOutlet NSTextField		*pigmentColorPatternQuiltedControl0Edit;
	 	IBOutlet NSTextField		*pigmentColorPatternQuiltedControl1Edit;
	 	//radial
	 	IBOutlet NSView					*pigmentColorPatternRadialColorMapView;
	 	//ripples
	 	IBOutlet NSView					*pigmentColorPatternRipplesColorMapView;
	 	//slope
	 	IBOutlet NSView					*pigmentColorPatternSlopeColorMapView;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternSlopeDirectionXYZPopUp;
	 	IBOutlet NSMatrix				*pigmentColorPatternSlopeDirectionMatrix;
	 	IBOutlet NSButton				*pigmentColorPatternSlopeSlopeOn;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeSlopeLowText;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeSlopeLowEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeSlopeHighText;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeSlopeHighEdit;
	 	IBOutlet NSButton				*pigmentColorPatternSlopeAltitudeOn;
	 	IBOutlet NSPopUpButton	*pigmentColorPatternSlopeAltitudeXYZPopUp;
	 	IBOutlet NSMatrix				*pigmentColorPatternSlopeAltitudeMatrix;
	 	IBOutlet NSButton				*pigmentColorPatternSlopeOffsetOn;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeOffsetLowText;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeOffsetLowEdit;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeOffsetHighText;
	 	IBOutlet NSTextField		*pigmentColorPatternSlopeOffsetHighEdit;
	 	//spherical
	 	IBOutlet NSView					*pigmentColorPatternSphericalColorMapView;
	 	//spiral
	 	IBOutlet NSView					*pigmentColorPatternSpiralColorMapView;
	 	IBOutlet NSView					*pigmentColorPatternSpiralTypePopUp;
	 	IBOutlet NSTextField		*pigmentColorPatternSpiralNrOfArmsEdit;
	 	//tiling
	 	IBOutlet NSView					*pigmentColorPatternTilingColorMapView;
	 	IBOutlet NSView					*pigmentColorPatterTilingTypePopUp;

	 	//waves
	 	IBOutlet NSView					*pigmentColorPatternWavesColorMapView;
	 	//wood
	 	IBOutlet NSView					*pigmentColorPatternWoodColorMapView;
	 	//wrinkles
	 	IBOutlet NSView					*pigmentColorPatternWrinklesColorMapView;
 	//---------
		//average
// pigmentImageMap
		IBOutlet NSPopUpButton 		*pigmentImageMapFileTypePopUp;
	 	IBOutlet NSView 					*pigmentImageMapFileView;
	 	IBOutlet NSView 					*pigmentImageMapWidthHeightView;
 		IBOutlet NSTextField 			*pigmentImageMapFileName;
	 	IBOutlet NSView 					*pigmentImageMapFunctionView;
	 	IBOutlet NSTextView				*pigmentImageMapFunctionEdit;
	 	IBOutlet NSTextField 			*pigmentImageMapFunctionImageWidth;
	 	IBOutlet NSTextField 			*pigmentImageMapFunctionImageHeight;
	 	IBOutlet NSView 					*pigmentImageMapPatternView;
	 	IBOutlet NSView 					*pigmentImageMapPigmentView;
		IBOutlet NSPopUpButton 		*pigmentImageMapProjectionPopUp;
		IBOutlet NSButton 				*pigmentImageMapProjectionOnceOn;
		IBOutlet NSPopUpButton 		*pigmentImageMapInterpolationPopUp;
		IBOutlet NSButton 				*pigmentImageMapFilerAllOn;
		IBOutlet NSTextField 			*pigmentImageMapFilterAllEdit;
		IBOutlet NSButton 				*pigmentImageMapTransmitAllOn;
		IBOutlet NSTextField 			*pigmentImageMapTransmitAllEdit;
// pigmentFunction
	 	IBOutlet NSView						*pigmentFunctionColorMapView;
		IBOutlet NSTextView 			*pigmentFunctionEdit;
		IBOutlet NSPopUpButton		*pigmentFunctionWaveTypePopUpButton;
		IBOutlet NSTextField			*pigmentFunctionWaveTypeEdit;
//extra for tooltips
		IBOutlet NSButton 				*pigmentColorMapEditButton;
		IBOutlet NSButton 				*pigmentColorMapCustomizedButton;
		IBOutlet NSButton 				*pigmentColorPatternDisityFileFileNameEditButton;

		IBOutlet NSButton 				*pigmentColorPatternImagePatternFileNameButton;
		IBOutlet NSButton 				*pigmentColorPatternImagePatternFunctionFunctionButton;
		IBOutlet NSButton 				*pigmentColorPatternImagePatternPatternButton;
		IBOutlet NSButton 				*pigmentColorPatternImagePatternPigmentButton;

		IBOutlet NSButton 				*pigmentColorPatternProjectionEditObjectButton;

		IBOutlet NSButton 				*pigmentImageMapFileButton;
		IBOutlet NSButton 				*pigmentImageMapFunctionButton;
		IBOutlet NSButton 				*pigmentImageMapPatternButton;
		IBOutlet NSButton 				*pigmentImageMapPigmentButton;


		IBOutlet NSButton 				*pigmentFunctionEditButton;

		IBOutlet NSButton 				*pigmentcolorPatternObjectEditObjectButton;
		IBOutlet NSButton 				*pigmentcolorPatternObjectEditOutsideObjectButton;
		IBOutlet NSButton 				*pigmentcolorPatternObjectEditInsideObjectButton;

		IBOutlet NSButton 				*pigmentcolorPatternPigmentPatternEditButton;
		IBOutlet NSButton 				*pigmentcolorPatternAveragePigmentEditButton;


}
-(NSView*) pigmentMainViewNIBView;
-(IBAction) pigmentButtons:(id)sender;
-(IBAction) pigmentTarget:(id)sender;
-(IBAction) pigmentColorPatternSelectPopUpButton:(id)sender;

@end
