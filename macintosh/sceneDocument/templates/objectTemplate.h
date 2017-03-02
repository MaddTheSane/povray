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

#define objectTransformations mTemplatePrefs[0]
#define objectPhotons mTemplatePrefs[1]
#define objectMaterial mTemplatePrefs[2]
#define objectHeightFieldFunction mTemplatePrefs[3]
#define objectHeightFieldPatternPigment mTemplatePrefs[4]
#define objectHeightFieldPigmentPigment mTemplatePrefs[5]
#define objectIsoFunction mTemplatePrefs[6]

#define objectLathe mTemplatePrefs[7]
#define objectPolygon mTemplatePrefs[8]
#define objectPrism mTemplatePrefs[9]
#define objectSor mTemplatePrefs[10]

#define setObjectTransformations setTemplatePrefs:0 withObject
#define setObjectPhotons setTemplatePrefs:1 withObject
#define setObjectMaterial setTemplatePrefs:2 withObject
#define setObjectHeightFieldFunction setTemplatePrefs:3 withObject		
#define setObjectHeightFieldPatternPigment setTemplatePrefs:4 withObject	
#define setObjectHeightFieldPigmentPigment setTemplatePrefs:5 withObject	
#define setObjectIsoFunction setTemplatePrefs:6 withObject	

#define setObjectLathe setTemplatePrefs:7 withObject	
#define setObjectPolygon setTemplatePrefs:8 withObject	
#define setObjectPrism setTemplatePrefs:9 withObject	
#define setObjectSor setTemplatePrefs:10 withObject	

enum eObjectPages{
	cObjectBicubicPatch		=0,
	cObjectBlob						=1,
	cObjectBox						=2,
	cObjectCone						=3,
	cObjectCylinder				=4,
	cObjectDisc						=5,
	cObjectHeightField		=6,
	cObjectIsosurface			=7,
	cObjectJuliaFractal		=8,
	cObjectLathe					=9,
	cObjectParametric			=10,
	cObjectPlane					=11,
	cObjectPoly						=12,
	cObjectPolygon				=13,
	cObjectPrism					=14,
	cObjectSor						=15,
	cObjectSphere					=16,
	cObjectSpheresweep		=17,
	cObjectSuperelipsoid	=18,
	cObjectText						=19,
	cObjectOvus						=20,
	cObjectTriangle				=21,
	cObjectTorus					=22
	};


enum eObjectButtonsTags {
	cObjectTypePopUp								=10,
	cObjectMaterialGroupOn					=20,
	cObjectMaterialEditButton				=30,
	cObjectTransformationGroupOn		=40,
	cObjectTransformationEditButton	=50,
	cObjectPhotonsGroupOn						=60,
	cObjectPhotonsEditButton				=70,
	cObjectRadiosityImportanceOn		=75,
	//blob
	cObjectBlobSphericalOn					=80,
	cObjectBlobCylindricalOn				=81,
	//box
	//cone
	//cylinder
	//disc
	cObjectDiscHoleRadiusOn									=90,
	//height field
	cObjectHeightFieldFileTypePopUp					=150,
 	cObjectHeightFieldEditFunctionButton		=151,
 	cObjectHeightFieldEditPatternButton			=152,
	cObjectHeightFieldSelectImageFileButton	=153,
	cObjectHeightFieldEditPigmentButton			=154,
	cObjectHeightFieldProjectionPopUp				=155,
	cObjectHeightFieldWaterLevelOn					=156,
	//iso
	cObjectIsoFunctionEditButton						=160,
	cObjectIsoMaxGradientMatrix							=161,
	cObjectIsoThresholdOn										=162,
	cObjectIsoAccuracyOn										=163,
	cObjectIsoMessageOn											=164,
	cObjectIsoMaxTraceOn										=165,
	cObjectIsoMaxTraceMatrix								=166,
	cObjectIsoContainerObjectPopUp					=167,
	cObjectIsoMaxGradientGroupOn						=168,
	//fractal
	cObjectFractalSliceOn										=170,
	cObjectFractal4DAlgebraPopUp						=171,
	//lathe
	cObjectLatheEditButton									=180,
	//Parametric
	cObjectParametricFunctionXEditButton		=190,
	cObjectParametricFunctionYEditButton		=191,
	cObjectParametricFunctionZEditButton		=192,
	cObjectParametricAccuracyOn							=193,
	cObjectParametricPrecomputeDepthsOn			=194,
	cObjectParametricMaxGradientOn					=195,
	cObjectParametricContainerObjectPopUp		=196,
	//plane
	cObjectPlaneNormalXYZPopUp					=200,
	//poly
	cObjectPolyPolyTypePopUp						=210,
	//polygon
	cObjectPolygonEditButton						=220,
	//Prism
	cObjectPrismEditButton							=230,
	cObjectPrismBevelPrismGroupOn				=231,
	cObjectPrismSweepTypePopUp					=232,
	cObjectPrismKeepDimensionsOn				=233,
	//Sor
	cObjectSorEditButton							=240,
	//spheresweep
	cObjectSpheresweepToleranceOn			=250,
	//text
	cObjectTextSelectTTFButton				=260,
	//triangle
	cObjectTriangleWriteMeshTriangleOn		=270,
	cObjectTriangleSmoothTriangleOn				=271,
	cObjectTriangleInsideVectorOn					=272,
	cObjectTriangleInsideXYZVectorPopUp		=273,

	
};

enum eObjectJuliafunction {
	cSqrt =0,	cCube,	cExp,	cReciprocal,	cSin,		cAsin,
	cSinh,		cAsinh,	cCos,		cAcos,			cCosh,	cAcosh,
	cTan,		cAtan,	cTanh,	cAtanh,			cLog,		cPwr,
	cQuaternation=0, cHypercomplex=1
};

enum eObjectPolyTypes {
	cQuadricPoly	=0,
	cCubicPoly		=1,
	cQuarticPoly	=2,
	cPoly5			=3,
	cPoly6			=4,
	cPoly7			=5
};	

enum eObjectPrismType {
	cPrismLinearSweep =0,
	cPrismConicSweep 	=1,
	
	cPrismBase 	=0,
	cPrismTop 	=1
};

enum eObjectSpheresweepSpline {
	cSpheresweepLinearSpline =0,
	cSpheresweepb_spline		=1,
	cSpheresweepCubicSpline	=2
};

enum eObjectTextAlignment {
	cDefaultAlignment 	=0,
	cLeftAlignment		=2,
	cCenterAlignment	=3,
	cRightAlignment		=4,
	
	cTopAlignment		=2,
	cBottomAlignment	=4
};

@interface ObjectTemplate : BaseTemplate
{
	NSMutableArray					*mPolyArray;
	IBOutlet NSTabView			*objectTabView;
	IBOutlet NSPopUpButton	*objectTypePopUp;

	IBOutlet NSButton				*objectMaterialGroupOn;
	IBOutlet NSBox					*objectMaterialGroupBox;

	IBOutlet NSButton				*objectTransformationGroupOn;
	IBOutlet NSBox					*objectTransformationGroupBox;
	IBOutlet NSButton				*objectIgnoreMaterialOn;

	IBOutlet NSButton				*objectPhotonsGroupOn;
	IBOutlet NSBox					*objectPhotonsGroupBox;

	IBOutlet NSButton				*objectUvMappingOn;
	IBOutlet NSButton				*objectDoubleIlluminateOn;
	IBOutlet NSButton				*objectHollowOn;
	IBOutlet NSButton				*objectNoImageOn;
	IBOutlet NSButton				*objectNoReflectionOn;
	IBOutlet NSButton				*objectNoShadowOn;
	IBOutlet NSButton				*objectNoRadiosityOn;
	IBOutlet NSButton				*objectRadiosityImportanceOn;
	IBOutlet NSTextField		*objectRadiosityImportanceEdit;
//cObjectBicubicPatch
	IBOutlet NSPopUpButton	*objectBicubicPatchTypePopUp;
	IBOutlet NSTextField		*objectBicubicPatchFlatnessEdit;   
	IBOutlet NSTextField		*objectBicubicPatchUStepsEdit;
	IBOutlet NSTextField		*objectBicubicPatchVStepsEdit;
	IBOutlet NSMatrix				*objectBicubicPatchCorner1Matrix;
	IBOutlet NSMatrix				*objectBicubicPatchCorner2Matrix;
//blob
	IBOutlet NSButton				*objectBlobSphericalOn;
	IBOutlet NSBox					*objectBlobSphericalGroup;
	IBOutlet NSTextField		*objectBlobSphericalNumberOfComponentsEdit;
	IBOutlet NSTextField		*objectBlobSphericalRadiusEdit;
	IBOutlet NSTextField		*objectBlobSphericalStrengthEdit;
	IBOutlet NSButton				*objectBlobSphericalTextureOn;

	IBOutlet NSButton				*objectBlobCylindricalOn;
	IBOutlet NSBox					*objectBlobCylindricalGroup;
	IBOutlet NSTextField		*objectBlobCylindricalNumberOfComponentsEdit;
	IBOutlet NSTextField		*objectBlobCylindricalRadiusEdit;
	IBOutlet NSTextField		*objectBlobCylindricalStrengthEdit;
	IBOutlet NSButton				*objectBlobCylindricalTextureOn;
	IBOutlet NSMatrix				*objectBlobCylindricalEnd1Matrix;
	IBOutlet NSMatrix				*objectBlobCylindricalEnd2Matrix;

	IBOutlet NSTextField		*objectBlobThresholdEdit;
	IBOutlet NSButton				*objectBlobSturm;
//box
	IBOutlet NSMatrix				*objectBoxCorner1Matrix;
	IBOutlet NSMatrix				*objectBoxCorner2Matrix;
//cone
	IBOutlet NSButton				*objectConeOpenOn;
	IBOutlet NSMatrix				*objectConeBaseMatrix;
	IBOutlet NSTextField		*objectConeBaseRadiusEdit;
	IBOutlet NSMatrix				*objectConeCapMatrix;
	IBOutlet NSTextField		*objectConeCapRadiusEdit;
//cylinder
	IBOutlet NSButton				*objectCylinderOpenOn;
	IBOutlet NSMatrix				*objectCylinderBaseMatrix;
	IBOutlet NSMatrix				*objectCylinderCapMatrix;
	IBOutlet NSTextField		*objectCylinderCapRadiusEdit;
//disc
	IBOutlet NSMatrix				*objectDiscCenterMatrix;
	IBOutlet NSMatrix				*objectDiscNormalMatrix;
	IBOutlet NSTextField		*objectDiscRadiusEdit;
	IBOutlet NSButton				*objectDiscHoleRadiusOn;
	IBOutlet NSTextField		*objectDiscHoleRadiusEdit;
//height field
	IBOutlet NSPopUpButton 	*objectHeightFieldFileTypePopUp;
 	IBOutlet NSView 				*objectHeightFieldFileView;
 	IBOutlet NSView 				*objectHeightFieldWidthHeightView;
	IBOutlet NSTextField 		*objectHeightFieldFileName;
 	IBOutlet NSView 				*objectHeightFieldFunctionView;
 	IBOutlet NSTextView			*objectHeightFieldFunctionEdit;
 	IBOutlet NSTextField 		*objectHeightFieldFunctionImageWidth;
 	IBOutlet NSTextField 		*objectHeightFieldFunctionImageHeight;
 	IBOutlet NSView 				*objectHeightFieldPatternView;
 	IBOutlet NSView 				*objectHeightFieldPigmentView;
	IBOutlet NSButton 			*objectHeightFieldWaterLevelOn;
	IBOutlet NSTextField 		*objectHeightFieldWaterLevelEdit;
	IBOutlet NSButton 			*objectHeightFieldSmoothOn;
	IBOutlet NSButton 			*objectHeightFieldHierarchyOn;
//isosurface
 	IBOutlet NSTextView			*objectIsoFunctionEdit;
	IBOutlet NSButton				*objectIsoMaxGradientGroupOn;
	IBOutlet NSBox					*objectIsoMaxGradientGroup;
	IBOutlet NSMatrix 			*objectIsoMaxGradientMatrix;
	IBOutlet NSTextField 		*objectIsoMaxGradientEdit;
	IBOutlet NSTextField 		*objectIsoEvaluateEditX;
	IBOutlet NSTextField 		*objectIsoEvaluateEditY;
	IBOutlet NSTextField 		*objectIsoEvaluateEditZ;
	IBOutlet NSButton				*objectIsoMessageOn;
	IBOutlet NSMatrix				*objectIsoMessageMatrix;
	IBOutlet NSButton 			*objectIsoThresholdOn;
	IBOutlet NSTextField 		*objectIsoThresholdEdit;
	IBOutlet NSButton 			*objectIsoAccuracyOn;
	IBOutlet NSTextField 		*objectIsoAccuracyEdit;
	IBOutlet NSButton 			*objectIsoMaxTraceOn;
	IBOutlet NSMatrix				*objectIsoMaxTraceMatrix;
	IBOutlet NSTextField 		*objectIsoMaxTraceEdit;
	IBOutlet NSPopUpButton	*objectIsoContainerObjectPopUp;
	IBOutlet NSButton				*objectIsoShowContainerObjectOn;
	IBOutlet NSView					*objectIsoContainerBoxView;
	IBOutlet NSMatrix				*objectIsoContainerBoxCorner1Matrix;
	IBOutlet NSMatrix				*objectIsoContainerBoxCorner2Matrix;
	IBOutlet NSView					*objectIsoContainerSphereView;
	IBOutlet NSMatrix				*objectIsoContainerSphereCenterMatrix;
	IBOutlet NSTextField 		*objectIsoContainerSphereRadiusEdit;
	IBOutlet NSButton 			*objectIsoOpenOn;
//fractal
	
	IBOutlet NSMatrix				*objectFractal4DjuliaParameterMatrix;
	IBOutlet NSPopUpButton	*objectFractal4DAlgebraPopUp;
	IBOutlet NSPopUpButton	*objectFractalFunctionPopUp;
	IBOutlet NSTextField 		*objectFractalMaxIterationEdit;
	IBOutlet NSTextField		*objectFractalPrecisionEdit;
	IBOutlet NSButton				*objectFractalSliceOn;
	IBOutlet NSBox					*objectFractalSliceGroup;
	IBOutlet NSMatrix				*objectFractal4DNormalMatrix;
	IBOutlet NSTextField		*objectFractalDistanceEdit;
//lathe
	IBOutlet NSButton				*objectLatheSturmOn;
//parametric
 	IBOutlet NSTextView			*objectParametricFunctionXEdit;
 	IBOutlet NSTextView			*objectParametricFunctionYEdit;
 	IBOutlet NSTextView			*objectParametricFunctionZEdit;
	IBOutlet NSButton 			*objectParametricMaxGradientOn;
	IBOutlet NSTextField 		*objectParametricMaxGradientEdit;

	IBOutlet NSButton 			*objectParametricAccuracyOn;
	IBOutlet NSTextField 		*objectParametricAccuracyEdit;
	IBOutlet NSButton 			*objectParametricPrecomputeDepthsOn;
	IBOutlet NSTextField 		*objectParametricPrecomputeDepthsEdit;
	IBOutlet NSTextField		*objectParametricOfVariablesText;
	
	IBOutlet NSButton 			*objectParametricOfVariablesXOn;
	IBOutlet NSButton 			*objectParametricOfVariablesYOn;
	IBOutlet NSButton 			*objectParametricOfVariablesZOn;
	IBOutlet NSMatrix				*objectParametricBounderiesUMatrix;
	IBOutlet NSMatrix				*objectParametricBounderiesVMatrix;

	IBOutlet NSPopUpButton	*objectParametricContainerObjectPopUp;
	IBOutlet NSButton				*objectParametricShowContainerObjectOn;
	IBOutlet NSView					*objectParametricContainerBoxView;
	IBOutlet NSMatrix				*objectParametricContainerBoxCorner1Matrix;
	IBOutlet NSMatrix				*objectParametricContainerBoxCorner2Matrix;
	IBOutlet NSView					*objectParametricContainerSphereView;
	IBOutlet NSMatrix				*objectParametricContainerSphereCenterMatrix;
	IBOutlet NSTextField 		*objectParametricContainerSphereRadiusEdit;
//plane
	IBOutlet NSPopUpButton	*objectPlaneNormalXYZPopUp;
	IBOutlet NSMatrix				*objectPlaneNormalMatrix;
	IBOutlet NSTextField		*objectPlaneDistanceEdit;
//poly
	IBOutlet NSTableView		*objectPolyTableView;
	IBOutlet NSPopUpButton	*objectPolyPolyTypePopUp;
	IBOutlet NSButton				*objectPolySturmOn;
//prism
	IBOutlet NSPopUpButton	*objectPrismSweepTypePopUp;
	IBOutlet NSView					*objectPrismKeepDimensionsView;
	IBOutlet NSButton				*objectPrismKeepDimensionsOn;
	IBOutlet NSPopUpButton	*objectPrismKeepDimensionsPopUp;
	IBOutlet NSTextField		*objectPrismTopHeightEdit;
	IBOutlet NSTextField		*objectPrismBaseHeightEdit;
	IBOutlet NSButton				*objectPrismBevelPrismGroupOn;
	IBOutlet NSBox					*objectPrismBevelPrismGroup;
	IBOutlet NSTextField		*objectPrismBevelPrismFractionHeightEdit;
	IBOutlet NSTextField		*objectPrismBevelPrismFractionAngleEdit;
	IBOutlet NSButton				*objectPrismOpenOn;
	IBOutlet NSButton 			*objectPrismSturmOn;
//sor
	IBOutlet NSButton				*objectSorOpenOn;
	IBOutlet NSButton 			*objectSorSturmOn;
//sphere
	IBOutlet NSMatrix				*objectSphereCenterMatrix;
	IBOutlet NSTextField		*objectSphereRadiusEdit;
//sphereSweep
	IBOutlet NSTextField 		*objectSpheresweepEntriesEdit;
	IBOutlet NSPopUpButton	*objectSpheresweepSplineTypePopUp;
	IBOutlet NSButton 			*objectSpheresweepToleranceOn;
	IBOutlet NSTextField 		*objectSpheresweepToleranceEdit;
//Superellipsoid
	IBOutlet NSTextField 		*objectSuperellipsoidEastWestEdit;
	IBOutlet NSTextField 		*objectSuperellipsoidNorthSouthEdit;
//text
	IBOutlet NSTextField		*objectTextTTFFileNameEdit;
	IBOutlet NSTextField		*objectTextTextEdit;
	IBOutlet NSTextField		*objectTextThicknessEdit;
	IBOutlet NSMatrix				*objectTextOffsetMatrix;
	IBOutlet NSPopUpButton	*objectTextHorizontalAlignmentTypePopUp;
	IBOutlet NSPopUpButton	*objectTextVerticalAlignmentTypePopUp;
//ovus
	IBOutlet NSTextField		*objectOvusBottomRadiusEdit;
	IBOutlet NSTextField		*objectOvusTopRadiusEdit;
//torus
	IBOutlet NSTextField			*objectTorusMajorRadiusEdit;
	IBOutlet NSTextField			*objectTorusMinorRadiusEdit;
	IBOutlet NSButton 				*objectTorusSturmOn;
///triangle
	IBOutlet NSMatrix				*objectTriangleCorner1Matrix;
	IBOutlet NSMatrix				*objectTriangleCorner2Matrix;
	IBOutlet NSMatrix				*objectTriangleCorner3Matrix;
	IBOutlet NSBox					*objectTriangleNormalGroup;
	IBOutlet NSMatrix				*objectTriangleNormal1Matrix;
	IBOutlet NSMatrix				*objectTriangleNormal2Matrix;
	IBOutlet NSMatrix				*objectTriangleNormal3Matrix;
	IBOutlet NSButton				*objectTriangleWriteMeshTriangleOn;
	IBOutlet NSTextField		*objectTriangleWriteMeshEntriesText;
	IBOutlet NSTextField		*objectTriangleWriteMeshEntriesEdit;
	IBOutlet NSButton				*objectTriangleSmoothTriangleOn;
	IBOutlet NSButton				*objectTriangleInsideVectorOn;
	IBOutlet NSPopUpButton	*objectTriangleInsideXYZVectorPopUp;
	IBOutlet NSMatrix				*objectTriangleInsideXYZVectorMatrix;
	IBOutlet NSBox					*objectTriangleInsideVectorBox;				
//extra for tooltips:

	IBOutlet NSButton				*objectMaterialGroupEditButton;	
	IBOutlet NSButton				*objectTransformationEditButton;
	IBOutlet NSButton				*objectPhotonsGroupEditButton;		
	IBOutlet NSButton				*objectHeightFieldPigmentButton;
	IBOutlet NSButton				*objectHeightFieldPatternButton;
	IBOutlet NSButton				*objectHeightFieldFileButton;
	IBOutlet NSButton				*objectHeightFieldFunctionButton;
	IBOutlet NSButton				*objectLatheEditButton;

	IBOutlet NSButton				*objectParametricFunctionXButton;
	IBOutlet NSButton				*objectParametricFunctionYButton;
	IBOutlet NSButton				*objectParametricFunctionZButton;
	IBOutlet NSButton				*objectPrismEditButton;
	IBOutlet NSButton				*objectPolygonEditButton;
	IBOutlet NSButton				*objectSorEditButton;
	IBOutlet NSButton				*objectTextTTFFileSelectButton;

	
}

-(IBAction) objectTarget:(id)sender;
-(IBAction) objectButtons:(id)sender;
-(IBAction) objectTypePopUp:(id)sender;

@end
