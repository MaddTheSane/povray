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
/* BaseTemplate */

#import <Cocoa/Cocoa.h>
#import "standardMethods.h"
#import "sceneDocument+templates.h"
#import "mutableTabString.h"
#import "customColorwell.h"
#import "toolTipAutomator.h"

void WritePatternPanel(MutableTabString *ds,NSDictionary *dict, NSString *FileTypePop, 
								NSString * PatternImageWidth, NSString *PatternImageHeightt,
								NSString *FunctionEdit, NSString *PatternPigment,
								NSString *PigmentPigment, NSString *FileEdit);
void WriteColormap(MutableTabString *ds,NSDictionary *dict, NSString *colomapTab);
void AddWavesTypeFromPopup(MutableTabString *ds,NSDictionary *dict, NSString *popUp, NSString *polyEdit);
void WritePigment(int forceDontWrap, MutableTabString *ds,NSDictionary *dict, BOOL writePattern);
void WriteNormal(int keyword, MutableTabString *ds,NSDictionary *dict, BOOL writePattern);
void WriteIsoBounding(MutableTabString *ds,NSDictionary *dict, NSString *clipPopUp, 
								NSString *corner1X, NSString *corner1Y, NSString *corner1Z,
								NSString *corner2X, NSString *corner2Y, NSString *corner2Z,
								NSString *centerX, NSString *centerY, NSString *centerZ,
								NSString *radius);
void WriteShowContainingObject(MutableTabString *ds,NSDictionary *dict, NSString *clipPopUp, 
								NSString *corner1X, NSString *corner1Y, NSString *corner1Z,
								NSString *corner2X, NSString *corner2Y, NSString *corner2Z,
								NSString *centerX, NSString *centerY, NSString *centerZ,
								NSString *radius);


enum eForceWrite {
	cForceNothing		=0,
	cForceWrite			=1,
	cForceDontWrite	=2
};

enum eObjectIsoBound {
	cBoxContainer			=0,
	cSphereContainer	=1
	};	
	
enum {
	menuTagTemplateReserved					=0,
	menuTagTemplateCamera						=1,	//*
	menuTagTemplateLight						=2,	//*
	menuTagTemplateObject						=3,
	menuTagTemplateTransformations	=4,	
	menuTagTemplateFunctions				=5,	//*
	menuTagTemplatePigment					=6,
	menuTagTemplateFinish						=7,
	menuTagTemplateNormal						=8,
	menuTagTemplateInterior					=9,
	menuTagTemplateMedia						=10,
	menuTagTemplatePhotons					=11,
	menuTagTemplateBackground				=12,
	menuTagTemplateColormap					=14,
	menuTagTemplateDensitymap				=15,
	menuTagTemplateMaterialmap			=16,
	menuTagTemplateNormalmap				=17,
	menuTagTemplatePigmentmap				=18,
	menuTagTemplateSlopemap					=19,
	menuTagTemplateTexturemap				=20,
	menuTagTemplateHeaderInclude		=22,
	menuTagTemplateGlobals					=23,
	menuTagTemplateMaterial					=25,

	menuTagTemplateAllBodymaps    	=100,	//used inside bodymapTemplate to create all defaults
	menuTagTemplateAllObjectmaps		=101,
	menuTagTemplateLathe						=102,
	menuTagTemplatePolygon					=103,
	menuTagTemplatePrism						=104,
	menuTagTemplateSor							=105
};

enum {
	cXYZVectorPopupXisYisZ		=0,
	cXYZVectorPopupX					=1,
	cXYZVectorPopupY					=2,
	cXYZVectorPopupZ					=3,
	cXYZVectorPopupXandYandZ	=4,
	
	cX		=0,
	cY		=1,
	cZ		=2,
	
	cFirstCell		=0,
	cSecondCell	=1,
	cthird			=2
	};
enum eWaveTypes {
	cDefault=0,		cCubicWave=2,		cPolyWave=3,
	cRampWave=4,	cScallopWave=5,	cSineWave=6,		cTriangleWave=7
};
	
enum {
	cGif=0,		cHdr=1,	cJpeg=2,	cPgm=3,	cPng=4,		cPot=5,		
	cPpm=6,	cSys=7,		cTga=8,	cTiff=9,		cLine8=10,	cFunctionImage=11,	
	cPatternImage=12,	cPigmentImage=13 };
	
enum ecolorMap {
	cBlackAndWhite =0,
	cRainBow=1,
	cCustomized=2,
	cBodyMap=3
};

enum ePatternCrackleType {
	cForm=0,	cMetric=1,	cOffset=2,	cSolid=3};

enum ePatternFactalType{
	cJulia=0,					cMagnet1Julia=1,		cMagnet2Julia=2,
	cMagnet1Mandel=3,	cMagnet2Mandel=4,	cMandel=5,
	//interior & exterior type
	cType0=0, 	cType1=1, 	cType2=2, 	cType3=3,
	cType4=4, 	cType5=5,	cType6=6
};
enum eProjection {
	cPoint=0,	cParallel=1, cNormal=2 
};

enum ePatternImageMapUse {
	cUseDefault=0,
	cUseIndex=2,
	cUseColor=3,
	cUseAlpha=4
};

enum eImageMap {
	cProjectionPlanar=0,	cProjectionSpherical=1,	cProjectionCylindrical=2,	cProjection3=3,
	cProjection4=4, 		cProjectionTorus=5,		cProjection6=6,
	cProjectionOmnidirectional=7,		
	
	cInterpolationNone			=0,	
	cInterpolationBilinear		=2,		
	cInterpolationBicubic		=3,
	cInterpolationNormilizedDistance	=4
};


@interface BaseTemplate : NSObject <NSTabViewDelegate,NSTableViewDelegate>{
	IBOutlet NSPanel			*mWindow;
	IBOutlet NSButton		*templateOkButton;
	IBOutlet NSButton		*templateCancelButton;
	IBOutlet NSButton		*templateResetButton;
	IBOutlet NSButton		*templateOpenButton;
	IBOutlet NSButton		*templateSaveButton;

	NSMutableDictionary *mTemplatePrefs[25];
	NSArray							*mExcludedObjectsForReset;	//arry with keys for objects to exclude from reset
	id colorPickerController;		//used in BaseTemplate+callTemplates
	
	BaseTemplate *mFileOwner;	//fileOwner for nib file (is a subclass of basetempalte
													// like cameraTemplate or lightTemplate...
	id									mTemplateCaller; // could be scenedocument or another template
	NSString						*keyName; // hold the keyname for prefs
	NSMutableDictionary *mPreferences;
	unsigned int				mTemplateType;
	unsigned						mModified;
	NSDictionary 				*mOutlets;
}

-(id) initWithDocumentPointer:(id) caller andDictionary:(NSMutableDictionary*)preferences forType:(unsigned int) templateType;
-(void)setKeyName:(NSString*)name;
-(NSString *) keyName;
-(id) caller;
-(id) fileOwner;

-(void) setWindow:(id)window;
-(NSPanel*) getWindow;
-(IBAction) okButton:(id)sender;
-(IBAction) cancelButton: (id)sender;
-(IBAction) resetButton: (id)sender;
-(IBAction) openButton: (id)sender;
-(IBAction) saveButton: (id)sender;

-(void) setPreferences:(id) preferences;
+(id) addMissingObjectsInPreferences:(id)preferences forClass:(Class)_Class andTemplateType:(unsigned int)templateType;

-(NSMutableDictionary*) removeStandardSettingsFromPreference:(NSMutableDictionary*) inPreferences;

-(NSMutableDictionary*) preferences;
-(void) writeDefaultPreferences;

-(IBAction) setModified:(id) sender;
-(void)setNotModified;
-(unsigned) modified:(id) sender;

- (void) selectFile:(id)fileName withTypes:(NSArray*)fileTypes keepFullPath:(BOOL) keepFullPath;

-(void) templateSheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(NSString *) dictionaryTypeName;

// setting of controls
	//if the referenceObject is on, all other objects are enabled
	//if not, they are disabled
- (void) enableObjectsAccordingToObject:(id) referenceObject, ...;
- (void) enableObjectsAccordingToState:(int)state, ...;
- (void) setXYZVectorAccordingToPopup:(NSPopUpButton*) popup xyzMatrix: (NSMatrix*)xyzMatrix ;
-(void) setSubViewsOfNSBox:( NSBox *) group toNSButton:(NSButton*)button;
-(void) setSubViewsOfNSBoxReverse:( NSBox *) group toNSButton:(NSButton*)button;
-(void) setTabView: (NSTabView *) tabView toIndexOfPopup:(NSPopUpButton* ) popup;
-(void) enableDisableItemInSuperview:(NSControl*) controlItem forString:searchString andState:(int)newState;

// methods for sublclasses
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds;
//+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param;
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType;

-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key;

-(void) retrivePreferences;
-(void) setValuesInPanel:(NSMutableDictionary*)preferences;
-(NSString *) defaultPreferencesName;
-(void) updateControls;

@end

@interface  BaseTemplate (callTemplates)
- (void) callTemplate:(int)templateNumber withDictionary:(NSMutableDictionary*) dict andKeyName:(NSString*) key;
-(void) colorPickerSheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(IBAction) displayColorPicker:(id)sender;
-(void) setTemplatePrefs:(int)number withObject:(id)objc;
@end
