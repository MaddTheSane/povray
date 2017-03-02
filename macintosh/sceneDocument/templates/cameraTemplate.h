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

#define cameraUserDefinedDirectionPigment mTemplatePrefs[0]
#define cameraUserDefinedDirectionFunctionInsertX mTemplatePrefs[1]
#define cameraUserDefinedDirectionFunctionInsertY mTemplatePrefs[2]
#define cameraUserDefinedDirectionFunctionInsertZ mTemplatePrefs[3]
#define cameraUserDefinedLocationPigment mTemplatePrefs[4]
#define cameraUserDefinedLocationFunctionInsertX mTemplatePrefs[5]
#define cameraUserDefinedLocationFunctionInsertY mTemplatePrefs[6]
#define cameraUserDefinedLocationFunctionInsertZ mTemplatePrefs[7]
#define cameraNormal mTemplatePrefs[8]

#define setCameraUserDefinedDirectionPigment setTemplatePrefs:0 withObject
#define setCameraUserDefinedDirectionFunctionInsertX setTemplatePrefs:1 withObject
#define setCameraUserDefinedDirectionFunctionInsertY setTemplatePrefs:2 withObject
#define setCameraUserDefinedDirectionFunctionInsertZ setTemplatePrefs:3 withObject
#define setCameraUserDefinedLocationPigment setTemplatePrefs:4 withObject
#define setCameraUserDefinedLocationFunctionInsertX setTemplatePrefs:5 withObject
#define setCameraUserDefinedLocationFunctionInsertY setTemplatePrefs:6 withObject
#define setCameraUserDefinedLocationFunctionInsertZ setTemplatePrefs:7 withObject
#define setCameraNormal setTemplatePrefs:8 withObject

enum {
	cCameraPredefinedTab			=0,
	cCameraUserDefinedTab			=1,
	
	cCameraLocationFunction		=0,
	cCameraLocationPigment		=1,
	cCameraDirectionFunction	=0,
	cCameraDirectionPigment		=1,
	
	 cCameraTypePerspective			=0,
	 cCameraTypeOrthoGraphic		=1,
	 cCameraTypeFisheye					=2,
	 cCameraTypeOmnimax					=3,
	 cCameraTypeUltraWideAngle	=4,
	 cCameraTypePanoramic				=5,
	 cCameraTypeSpherical				=6,
	 cCameraTypeCylinderVerticalFixed			=8,
	 cCameraTypeCylinderHorizontalFixed		=9,
	 cCameraTypeCylinderVerticalMoving		=10,
	 cCameraTypeCylinderHorizontalMoving	=11,
	 
	 cCameraUpRightX		=0,
	 cCameraUpRightY		=1,
	 cCameraUpRightZ		=2,
	 
	 cCameraAngleDirectionPopupAngle			=1,
	 cCameraAngleDirectionPopupDirection	=0,
	 cCameraAngleTabViewNonSperical				=0,
	 cCameraAngleTabViewSperical					=1,
	cCameraUserDefinedFunction						=0,
	 cCameraUserDefinedPigment						=1
	};

enum eCameraButtons {
	cCameraNormalEditButton														=90,
	cCameraUserDefinedDirectionEditPigmentButton			=10,
	cCameraUserDefinedDirectionFunctionInsertButtonX	=20,
	cCameraUserDefinedDirectionFunctionInsertButtonY	=30,
	cCameraUserDefinedDirectionFunctionInsertButtonZ	=40,

	cCameraUserDefinedLocationEditPigmentButton			=50,
	cCameraUserDefinedLocationFunctionInsertButtonX	=60,
	cCameraUserDefinedLocationFunctionInsertButtonY	=70,
	cCameraUserDefinedLocationFunctionInsertButtonZ	=80
};

enum {
	cCameraAngleDirectionOn						=1,
	cCameraVerticalAngleOn						=2,
	cCameraAngleDirectionPopup				=3,
	cCameraSkyOn											=4,
	cCameraSkyVectorPopup							=5,
	cCameraAspectRatioGroupOn					=6,
	cCameraAspectRatioUpPopup					=7,
	cCameraAspectRatioRightPopup			=8,
	cCameraFocalBlurGroupOn						=9,
	cCameraFocalBlurVarianceOn				=10,
	cCameraFocalBlurConfidenceOn			=11,
	cCameraNormalGroupOn							=12,
	cCameraTypePopup									=13,
	cCameraUserDefinedDirectionPopup	=14,
	cCameraUserDefinedLocationPopup		=15,
	cCameraAspectRatioAutoOn					=16
	};

@interface CameraTemplate : BaseTemplate
{
	IBOutlet NSTextField		*cameraHorizontalAngleEdit;
	IBOutlet NSTextField		*cameraVerticalAngleEdit;
	IBOutlet NSButton				*cameraVerticalAngleOn;
	IBOutlet NSTabView			*cameraAngleTabView;
	
    IBOutlet NSTextField 		*cameraAngleAngleEdit;
    IBOutlet NSBox					*cameraAngleDirectionGroup;
    IBOutlet NSMatrix 			*cameraAngleDirectionMatrix;
    IBOutlet NSButton 			*cameraAngleDirectionOn;
    IBOutlet NSPopUpButton 	*cameraAngleDirectionPopup;
    IBOutlet NSBox					*cameraAspectRatioGroup;
    IBOutlet NSButton 			*cameraAspectRatioGroupOn;
    IBOutlet NSButton 			*cameraAspectRatioAutoOn;
    IBOutlet NSBox					*cameraAspectRatioAutoView;
    IBOutlet NSTextField 		*cameraAspectRatioRightEdit;
    IBOutlet NSPopUpButton 	*cameraAspectRatioRightPopup;
    IBOutlet NSTextField 		*cameraAspectRatioUpEdit;
    IBOutlet NSPopUpButton	*cameraAspectRatioUpPopup;
    IBOutlet NSTextField 		*cameraFocalBlurApertureEdit;
    IBOutlet NSTextField 		*cameraFocalBlurBlurSamplesEdit;
    IBOutlet NSTextField 		*cameraFocalBlurConfidenceEdit;
    IBOutlet NSButton 			*cameraFocalBlurConfidenceOn;
    IBOutlet NSMatrix 			*cameraFocalBlurFocalPointMatrix;
    IBOutlet NSBox					*cameraFocalBlurGroup;
    IBOutlet NSButton 			*cameraFocalBlurGroupOn;
    IBOutlet NSTextField 		*cameraFocalBlurVarianceEdit;
    IBOutlet NSButton 			*cameraFocalBlurVarianceOn;
    IBOutlet NSMatrix 			*cameraLocationMatrix;
    IBOutlet NSMatrix 			*cameraLookAtMatrix;
    IBOutlet NSTabView			*cameraMainTabView;
    IBOutlet NSBox					*cameraNormalGroup;
    IBOutlet NSButton 			*cameraNormalGroupOn;
    IBOutlet NSMatrix 			*cameraSkyMatrix;
    IBOutlet NSButton 			*cameraSkyOn;
    IBOutlet NSPopUpButton	*cameraSkyVectorPopup;
    IBOutlet NSTabView			*cameraTabView;
    IBOutlet NSPopUpButton	*cameraTypePopup;
    IBOutlet NSTextView			*cameraUserDefinedDirectionFunctionX;
    IBOutlet NSTextView			*cameraUserDefinedDirectionFunctionY;
    IBOutlet NSTextView			*cameraUserDefinedDirectionFunctionZ;
    IBOutlet NSBox					*cameraUserDefinedDirectionGroupBox;
    IBOutlet NSPopUpButton 	*cameraUserDefinedDirectionPopup;
    IBOutlet NSTabView			*cameraUserDefinedDirectionTabView;
    IBOutlet NSTextView			*cameraUserDefinedLocationFunctionX;
    IBOutlet NSTextView			*cameraUserDefinedLocationFunctionY;
    IBOutlet NSTextView			*cameraUserDefinedLocationFunctionZ;
    IBOutlet NSBox					*cameraUserDefinedLocationGroupBox;
    IBOutlet NSPopUpButton 	*cameraUserDefinedLocationPopup;
    IBOutlet NSTabView			*cameraUserDefinedLocationTabView;
    // for balloons only

    IBOutlet NSButton 			*cameraPredefinedEditNormalButton;

    IBOutlet NSButton 			*cameraUserDefinedLocationEditPigmentButton;	
    IBOutlet NSButton 			*cameraUserDefinedLocationFunctionUButton;	
    IBOutlet NSButton 			*cameraUserDefinedLocationFunctionVButton;	
    IBOutlet NSButton 			*cameraUserDefinedLocationFunctionZButton;		

    IBOutlet NSButton 			*cameraUserDefinedDirectionEditPigmentButton;
    IBOutlet NSButton 			*cameraUserDefinedDirectionFunctionUButton;
    IBOutlet NSButton 			*cameraUserDefinedDirectionFunctionVButton;	
    IBOutlet NSButton 			*cameraUserDefinedDirectionFunctionZButton;	
   
}
+(void) writeAspectRatioBlockFromDict:(NSDictionary *)dict toMutableTab:(MutableTabString*)ds;

-(IBAction) cameraTarget:(id)sender;
- (IBAction)cameraButtons:(id)sender;

@end
