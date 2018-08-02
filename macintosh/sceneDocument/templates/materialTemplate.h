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
#import "mapBaseTemplate.h"

#import "pigmentTemplate.h"
#import "normalTemplate.h"
#import "finishTemplate.h"
#import "interiorTemplate.h"
#import "materialEditorMap.h"
#import "materialPreview.h"

typedef NS_ENUM(NSInteger, eMaterialButtons) {
	cMaterialPigmentTab		=0,
	cMaterialNormalTab		=1,
	cMaterialFinishTab		=2,
	cMaterialInteriorTab	=3,

	cMaterialTransformationsOn					=1,
	cMaterialTransformationsEditButton	=2,
	cPigmentOn									=12,
	cNormalOn										=13,
	cFinishOn										=14,
	cInteriorOn									=15,
	
	cMaterialDrawLayer 					=16,
	cMaterialDrawMaterial				=17,
	cMaterialObjectPopUp				=18,
	cMaterialBackgroundPopUp		=19,
	cMaterialReflectPopUp				=20,


	cMaterialHorizontalSlider		=22,
	cMaterialVerticalSlider			=23,
	cMaterialVEdit							=24,
	cMaterialHEdit							=25,
	cMaterialFillOn							=26,
	cMaterialFillEdit						=27
};

enum {
	cObjectBox_0505 		=0,
	cObjectUnion				=1,
	cObjectDifference		=2,
	cObjectSphere_0005	=3,
	cObjectBox_0010			=4,
	
	cBackgroundBlack			=0,
	cBackgroundWhite			=1,
	cBackgroundSkysphere	=2,
	cBackgroundGridBlack	=3,
	cBackgroundGridWhite	=4,
	cBackgroundChecker		=5,
	
	cReflectNothing					=0,
	cReflectSkysphereClouds	=1,
	cReflectSkysphereWhite	=2,
	cReflectGridWhite				=3,
	cRefelctGridBlack				=4
};

enum eMaterialPreview {
	cPreviewTab	=0,
	cLayersTab	=1
};

#define SITDADDragType @"Mpe"

#define materialTransformations mTemplatePrefs[0]

#define setMaterialTransformations setTemplatePrefs:0 withObject

@interface MaterialTemplate : MapBaseTemplate
{

	//main
	IBOutlet NSButton 				*materialTransformationsOn;
	IBOutlet NSButton					*materialTransformationsEditButton;
	IBOutlet NSButton					*materialDrawLayer;
	IBOutlet NSButton					*materialDrawMaterial;
	IBOutlet NSButton					*materialDontWrapInMaterial;
	id mPigmentGreenLed;
	id mNormalGreenLed;
	id mFinishGreenLed;
	id mInteriorGreenLed;
	//normal/pigment/finish/interior tab
	IBOutlet NSTabView				*materialMainTabView;
	IBOutlet NSView						*materialPigmentViewHolder;	
	IBOutlet NSView						*materialNormalViewHolder;	
	IBOutlet NSView						*materialFinishViewHolder;	
	IBOutlet NSView						*materialInteriorViewHolder;	

	//preview
	IBOutlet NSTabView			*materialPreviewTabView;
	IBOutlet NSSlider 			*materialHorizontalSlider;
	IBOutlet NSSlider 			*materialVerticalSlider;
	IBOutlet NSTextField		*materialVEdit;
	IBOutlet NSTextField		*materialHEdit;
	IBOutlet NSButton				*materialFillOn;
	IBOutlet NSTextField		*materialFillEdit;
    
	//layer
	IBOutlet NSButton 			*materialPigmentOn;
	IBOutlet NSButton 			*materialNormalOn;
	IBOutlet NSButton 			*materialFinishOn;
	IBOutlet NSButton 			*materialInteriorOn;
  IBOutlet NSPopUpButton	*materialObjectPopUp;
  IBOutlet NSPopUpButton	*materialBackgroundPopUp;
  IBOutlet NSPopUpButton	*materialReflectPopUp;


	IBOutlet materialPreview	*mateiralPreviewView;
	
    
  //internal 
  NSUInteger mDraggedRow;	// keep track of which row got dragged
	id mPigmentFileOwner;
	id mNormalFileOwner;
	id mFinishFileOwner;
	id mInteriorFileOwner;

}
-(void) renderState:(NSNotification *) notification;
+(void) addLayer:(MutableTabString*) ds atIndex:(int)index fromMap:(id)cmap;
+(void) addBackgroundToString:(MutableTabString *)ds withDict:(NSDictionary *)dict;
+(void) addSkySphereToString:(MutableTabString *)ds withDict:(NSDictionary *)dict;
+(void) addReflectionToString:(MutableTabString *)ds withDict:(NSDictionary *)dict;
+(void) addCameraToString:(MutableTabString *)ds withDict:(NSDictionary *)dict;
+(void) addLightToString:(MutableTabString *)ds withDict:(NSDictionary *)dict;

-(IBAction) materialTarget:(id)sender;
-(IBAction) materialButtons:(id)sender;
-(void) setButtons;
-(void) updateGreenLeds;
-(void) importSettings;
-(void) exportSettings;
//- (void) importPreferencesOpenSavePanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo;


@end
