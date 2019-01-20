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
/* PreferencesPanelController */

#import <Cocoa/Cocoa.h>
 
 #define dFactorySettings @"Factory Settings"
 #define dLastValuesInPanel @"lastValuesInPanel"

@interface greenLed : NSView
@end

enum {
	cAppRenderBlockSizePopup    =50,
	
	cRenderBlockSize4           =0,
	CRenderBlockSize8           =1,
	cRenderBlockSize16          =2,
	cRenderBlockSize32          =3,
	cRenderBlockSize64          =4,
	cRenderBlockSize128         =5,
	
	cAutomatic                  =0,
	cCpusMinus1                 =2,
	cCpusPlus1                  =3,
	cCpu1                       =5,
	cCpu2                       =6,
	cCpu3                       =7,
	cCpu4                       =8,
	cCpu5                       =9,
	cCpu6                       =10,

	cRenderPattern0             =0,
	cRenderPattern1             =1,
	cRenderPattern2             =2,
	cRenderPattern3             =3,
	cRenderPattern4             =4,
	cRenderPattern5             =5,
	
	cLanguageVersion1X          =0,
	cLanguageVersion2X          =1,
	cLanguageVersion30X         =2,
	cLanguageVersion31X         =3,
	cLanguageVersion35X         =4,
	cLanguageVersion36X         =5,
	cLanguageVersion37X         =6,

	cBitDepth5                  =0,
	cBitDepth8                  =1,
	cBitDepth12                 =2,
	cBitDepth16                 =3,

	cImageTypeDontSave          =0,
	cImageTypeTarga 			=1,
	cImageTypeTargaCompressed   =2,
	cImageTypePNG               =3,
	cImageTypePPM               =4,
	cImageTypeHdr               =5,
	cImageTypeExr               =6,
	cImageTypeLastMenu          = cImageTypeExr,
	
	cDitheringB2				=0,
	cDitheringB3				=1,
	cDitheringB4				=2,
	cDitheringD1				=3,
	cDitheringD2				=4,
	cDitheringFloydSteinberg	=5,
	
	cRatio1_1                   =0,
	cRatio2_1                   =1,
	cRatio4_3                   =2,
	cRatio16_9                  =3,
	cRatio1_2                   =5,
	cRatio3_4                   =6,
	cRatio9_16                  =7,

	cRadiosityVainOnCell        =1,
	cRadiosityVainOffCell       =2,
	

	cWarningLevel0              =0,
	cWarningLevel5              =1,
	cWarningLevel10             =2,

	cBoudingObjects1            =0,
	cBoudingObjects3            =1,
	cBoudingObjects5            =2,
	cBoudingObjects10           =3,
	cBoudingObjects15           =4,
	cBoudingObjects20           =5,
	cBoudingObjects25           =6,
	cBoudingObjects30           =7,
	cBoudingObjects35           =8,
	cBoudingObjects40           =9,


	cFieldRenderingOff          =0,
	cFieldRenderingStartEven    =2,
	cFieldRenderingStartOdd     =3,

	cSave                       =0,
	cModify                     =1
};

//*******************************************************************************
//Tags for the controls on the preferences panels
//*******************************************************************************
typedef NS_ENUM(NSInteger, preferencesTag) {
//Buttons buttom of panel
	cEditSceneFile                  =1,
	cStartRender                    =2,
	cRenderingPreferencesPresets    =3,

//******* Files @ paths Panel *****************************************
    selectSceneFileTag					=100,
    selectImageFileTag					=101,
    selectInclude1Tag						=102,
    selectInclude2Tag						=103,
    clearInclude1Tag						=104,
    clearInclude2Tag						=105,
    useIniInputFileTag					=106,
    selectInputIniFileTag				=107,
    RadiosityLoadSaveGroupOnTag =108,
    RadiosityLoadOnTag					=109,
    RadiositySaveOnTag					=110,
    RadiosityFileNameEditTag		=111,

//******* image & quality Panel *****************************************
    //image size
    cPresetsImageSizes              =10,
		cImageXTag                      =12,
		cImageYTag                      =13,
		cImageRatioXTag                 =14,
		cImageRatioYTag                 =15,
    cRatioOnOff                     =16,
    cRatioPresets                   =17,
    // patrial image
		cXSubsetStart                   =18,
		cXSubsetEnd                     =19,
		cYSubsetStart                   =20,
		cYSubsetEnd                     =21,
    cSubsetToFullSize               =22,
    //output file options
    ImageTypePopupTag               =30,
		BithDepthPopupTag               =31,
    cFileGammaOn                    =32,
		cDontDisplay                    =33,
    //Dithering group
    cDitheringOn                    =40,
     //AntiAlias
		cSamplingOn                     =50,
    cSamplingMethodPopupTag         =51,


//******* bounding & threads Panel *****************************************
   //redirect text streams
    cRedirectTextStreamsOnOff       =60,
	//Auto Bounding System
    cAutoBoundingOnOff							=70,
    //BSP Bounding
		cBSPBoundingMethodOnOff   	    =80,
	//render pattern
    cRenderBlockStepOn							=90,
	
//******* clock settings Panel *****************************************
	cAnimationOnOff                 =95,
	cFrameStepOn                    =96,

//******* misc Panel *****************************************
	cRedirectAllOutputImagesOnOff	=120,
	cRedirectAllOutputImagesPath	=121
};


@interface PreferencesPanelController : NSObject
{
	IBOutlet id				mMiscGreenLed;
	IBOutlet id				mClockGreenLed;
	IBOutlet id				mUseIniGreenLed;
	IBOutlet id				mSaveOutputfileGreenLed;



	IBOutlet NSPanel			*settingsPanel;
	IBOutlet NSButton			*settingsPanelOk;
	IBOutlet NSButton			*settingsPanelCancel;
	IBOutlet NSButton			*settingsPanelDelete;
	IBOutlet NSButton			*settingsPanelRename;
	IBOutlet NSTextField	*settingsPanelTextField;
	IBOutlet NSTableView	*settingsPanelTableView;
	int 									mSettingsPanelMode;
	IBOutlet NSTextField	*settingsPanelX;
	IBOutlet NSTextField	*settingsPanelY;
	IBOutlet NSTextField	*settingsPanelAntiAliasing;
	IBOutlet NSTextField	*settingsPanelThreshold;
	IBOutlet NSTextField	*settingsPanelRecursion;
	IBOutlet NSTextField	*settingsPanelMethod;
	IBOutlet NSTextField	*settingsPanelJitter;
	IBOutlet NSMatrix			*settingsPanelSortMatrix;
			

	double startColumnRatio, endColumnRatio,startRowRatio, endRowRatio;
	NSMutableArray		*mSettingsArray;
	NSMutableArray		*mBackupSettingsArray;
	NSString					*selectedDictionary;
	NSNumber					*indexOfSelectedTabViewItem;

	IBOutlet NSTabView			*tabViewOutlet;
	IBOutlet NSPopUpButton	*renderingPreferencesPresets;
	IBOutlet NSButton				*startRenderButton;

 //-------------Files and paths
		IBOutlet NSPopUpButton	*languageVersion;
		IBOutlet NSTextField		*sceneFile;
		IBOutlet NSTextField		*imageFile;
		IBOutlet NSButton				*useIniInputFile;
		IBOutlet NSBox					*useIniFileGroup;
		IBOutlet NSButton				*mRadiosityLoadSaveGroupOn;
		IBOutlet NSBox					*mRadiosityLoadSaveGroupBox;
		IBOutlet NSButton				*mRadiosityLoadOn;
		IBOutlet NSButton				*mRadiositySaveOn;
		IBOutlet NSTextField		*mRadiosityFileNameEdit;
		IBOutlet NSTextField		*iniInputFile;
		IBOutlet NSTextField		*include1;
		IBOutlet NSTextField		*include2;
 
 //--------------Image & quality
		//image size
			IBOutlet NSTextField		*imageSizeX;
			IBOutlet NSTextField		*imageSizeY;
			IBOutlet NSTextField		*xSubsetEnd;
			IBOutlet NSTextField		*xSubsetStart;
			IBOutlet NSTextField		*ySubsetEnd;
			IBOutlet NSTextField		*ySubsetStart;
			IBOutlet NSButton				*ratioOnOff;
			IBOutlet NSPopUpButton	*ratioPresets;
			IBOutlet NSTextField		*ratioX;
			IBOutlet NSTextField		*ratioY;
			IBOutlet NSPopUpButton	*presetsImageSizes;
			
		//output file options
			IBOutlet NSPopUpButton	*imageType;
			IBOutlet NSPopUpButton	*bitDepth;
			IBOutlet NSButton				*addAlphaChannel;
			IBOutlet NSButton				*grayScaleOutputOn;
			IBOutlet NSButton				*writeIniFile;
			IBOutlet NSButton				*dontDisplay;
			IBOutlet NSButton				*dontErasePreview;
			IBOutlet NSButton				*onlyDisplayPart;
			IBOutlet NSButton				*continueRendering;
			
		//quality
			IBOutlet NSPopUpButton	*quality;
			IBOutlet NSButton				*highReproducibilityOn;
			IBOutlet NSTextField		*fileGammaEdit;
			IBOutlet NSButton				*fileGammaOn;
		//dithering
			IBOutlet NSButton				*ditheringOn;
			IBOutlet NSBox					*ditheringGroup;
			IBOutlet NSPopUpButton	*ditheringMethod;
		//anti-aliasing
			IBOutlet NSBox					*samplingGroup;
			IBOutlet NSButton				*samplingOn;
			IBOutlet NSTextField		*sampleJitter;
			IBOutlet NSPopUpButton	*sampleMethod;
			IBOutlet NSTextField		*sampleRecursion;
			IBOutlet NSTextField		*sampleThreshold;
			IBOutlet NSTextField *mOutletSamplingGamma;
	//Bounding & Threads
	//Radiosityvain
		IBOutlet NSMatrix			*mRadiosityVainMatrix;
	//warning
		IBOutlet NSPopUpButton      *mWarningLevelPopup;
		//text streams
		IBOutlet NSButton			*redirectTextStreamsOnOff;
		IBOutlet NSBox				*redirectTextStreamsGroup;
		IBOutlet NSButton			*debugToFile;
		IBOutlet NSButton			*debugToScreen;
		IBOutlet NSButton			*fatalToFile;
		IBOutlet NSButton			*fatalToScreen;
		IBOutlet NSButton			*renderToFile;
		IBOutlet NSButton			*renderToScreen;
		IBOutlet NSButton			*statisticsToFile;
		IBOutlet NSButton			*statisticsToScreen;
		IBOutlet NSButton			*warningToFile;
		IBOutlet NSButton			*warningToScreen;
		// auto bounding system
		IBOutlet NSBox					*autoBoundingSystemGroup;
		IBOutlet NSButton				*autoBoundingOnOff;
		IBOutlet NSPopUpButton  *boundingObjects;
		IBOutlet NSButton				*ignoreBoundedBy;
		IBOutlet NSButton				*splitUnions;
		
		IBOutlet NSButton			*BSPBoundingMethodOnOff;
		IBOutlet NSBox				*BSPBoundingGroup;
		IBOutlet NSTextField	*BSP_MaxDepth;
		IBOutlet NSTextField	*BSP_BaseAccessCost;
		IBOutlet NSTextField	*BSP_ChildAccessCost;
		IBOutlet NSTextField	*BSP_IsectCost;
		IBOutlet NSTextField	*BSP_MissChance;
		//Render pattern
		IBOutlet NSTextField		*renderBlockStep; 
		IBOutlet NSButton				*renderBlockStepOn;
		IBOutlet NSPopUpButton  *renderPattern;
		//Threads
		IBOutlet NSPopUpButton  *mNumberOfCpusPopupButton;
		IBOutlet NSTextField		*mNumberCoresFound;
		IBOutlet NSPopUpButton  *mRenderBlockSizePopupButton;

	//misc
	IBOutlet NSBox            *redirectAllOutputImagesGroup;
	IBOutlet NSButton         *redirectAllOutputImagesOnOff;
	IBOutlet NSTextField      *redirectAllOutputImagesPath;

	//animation (clock)
	IBOutlet NSBox					*animationSettingsGroup;
	IBOutlet NSButton				*animationOnOff;
	IBOutlet NSTextField		*clockEnd;
	IBOutlet NSTextField 		*clockInitial;
	IBOutlet NSPopUpButton	*fieldRendering;
	IBOutlet NSTextField		*finalFrame;
	IBOutlet NSTextField		*frameStep;
	IBOutlet NSButton				*frameStepOn;
	IBOutlet NSTextField		*initialFrame;
	IBOutlet NSTextField		*subsetEnd;
	IBOutlet NSTextField		*subsetStart;
	IBOutlet NSButton				*turnCyclicAnimationOn;
//extra for tooltips
	IBOutlet NSButton 	*sceneFileButton;
	IBOutlet NSButton 	*imageFileButton;
	IBOutlet NSButton		*iniInputFilebutton;
	IBOutlet NSButton 	*include1Button;
	IBOutlet NSButton		*include2Button;
	IBOutlet NSButton		*setFullSizeButton;
	IBOutlet NSButton		*clearInclude1Button;
	IBOutlet NSButton		*clearInclude2Button;
	IBOutlet NSButton		*editSceneFileButton;
	IBOutlet NSButton		*redirectOutputPathButton;
}

+ (void) initialize;
+ (PreferencesPanelController*)sharedInstance;
+ (NSMutableDictionary *) mutableDictionaryWithDefaultSettings;
//actions
- (IBAction) preferencesTarget:(id)sender;
- (IBAction) targetFilesAndPaths:(id)sender;
- (IBAction) settingsPanelOk: (id)sender;
- (IBAction) settingsPanelCancel: (id)sender;
- (IBAction) settingsPanelDelete: (id)sender;
- (IBAction) settingsPanelRename: (id)sender;
- (IBAction) settingsPanelSortMatrix: (id)sender;
- (void) settingsPanelDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo;
-(NSString *) makeSettingsDescription;
-(void) buildPreferencesPopup;
-(void) setButtonStateSettingsPanel: (NSMutableDictionary*) dictToUse;
-(void) selectionSettingsPanelTableViewChanged:(NSNotification *) notification;
-(void) saveCurrentSettingsInDefaultSettings: (NSNotification *)ntf;
-(void) processSettingsPanel:(int) saveEdit;

- (void) selectInclude: (id) sender forField:(NSTextField*)textfield;
- (NSMutableDictionary*) setttingsDictionaryWithName: (NSString*)dictionaryToSearchFor;
- (BOOL) putDictionaryInPanel: (NSMutableDictionary*)dictToUse allowFileChange:(BOOL)fileChange;
-(void) setPanelTitle;
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem;
-(NSMutableDictionary*) getDictWithCurrentSettings:(BOOL) writeToDefaults;
 - (NSInteger) putDictionaryInSettingsArray: (NSMutableDictionary*)dictionaryToAdd;
- (void) updateStartEndRatio;
- (void) updateStartEndValues;
-(void) newSelectionInPreviewwindowSet:(NSNotification *) notification;
-(void) sendNotificationSubsetDidChange;

-(void)setSceneFileNameInPanel: (NSString*) newFile;
-(void) renderState:(NSNotification *) notification;
-(void) acceptDocument:(NSNotification *) notification;

- (NSNumber*)setIndexOfSelectedTabViewItem:(NSNumber *)selectedTab;

@end
