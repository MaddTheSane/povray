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
#include <algorithm>
#import "MainController.h"
#import "toolTipAutomator.h"
#import "rendererGUIBridge.h"

// this must be the last file included
#import "syspovdebug.h"

static NSInteger sortSettingsByName(id first, id last, void*context);
static NSInteger sortSettingsBySize(id first, id last, void*context);

static PreferencesPanelController* _preferencesPanelController;

@implementation greenLed
	//---------------------------------------------------------------------
	// drawRect
	//---------------------------------------------------------------------
	- (void)drawRect:(NSRect)aRect
	{
		NSRect r=[self bounds];
		[[NSColor greenColor]set];
		NSRectFill(r);
		[[NSColor darkGrayColor]set];
		NSFrameRect(r);
	}
@end


@implementation PreferencesPanelController

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self=_preferencesPanelController=[super init];
	return self;
}

//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (PreferencesPanelController*)sharedInstance
{
	return _preferencesPanelController;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
- (void) dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[super dealloc];
}

//---------------------------------------------------------------------
// mutableDictionaryWithDefaultSettings
//---------------------------------------------------------------------
+ (NSMutableDictionary *) mutableDictionaryWithDefaultSettings
{
	NSMutableDictionary *initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		
	//name of dict ***********************************************************************************
	dFactorySettings,													@"dictionaryName",
	[NSNumber numberWithInt:0],									@"indexOfSelectedTabViewItem",


	//files and paths ***********************************************************************************
	[NSNumber numberWithInt:cLanguageVersion36X],	@"languageVersion",
	[NSNumber numberWithInt:37],									@"languageVersion_xx",
	@"" ,																					@"sceneFile",
	@"" ,																					@"imageFile",
	[NSNumber numberWithInt:NSOffState],					@"useIniInputFile",
	@"" ,																					@"iniInputFile",
	@"" ,																					@"include1",
	@"" ,																					@"include2",
	[NSNumber numberWithInt:NSOffState],					@"mRadiosityLoadSaveGroupOn",
	[NSNumber numberWithInt:NSOffState],					@"mRadiosityLoadOn",
	[NSNumber numberWithInt:NSOffState],					@"mRadiositySaveOn",
	@"" ,																					@"mRadiosityFileNameEdit",

	//image & quality ***********************************************************************************
	@"320" ,										@"imageSizeX",
	@"240" ,										@"imageSizeY",
	@"1" ,											@"xSubsetStart",
	@"1" ,											@"ySubsetStart",
	@"320" ,										@"xSubsetEnd",
	@"240" ,										@"ySubsetEnd",
	[NSNumber numberWithInt:NSOnState] ,            @"ratioOnOff",
	[NSNumber numberWithInt:cRatio4_3] ,            @"ratioPresets",
	@"4" ,											@"ratioX",
	@"3" ,											@"ratioY",

	//output options ***********************************************************************************
	[NSNumber numberWithInt:cImageTypeDontSave],	@"imageType",
	[NSNumber numberWithInt:NSOffState],					@"addAlphaChannel",
	[NSNumber numberWithInt:cBitDepth16],					@"bitDepth",
	[NSNumber numberWithInt:NSOffState],					@"dontDisplay",
	[NSNumber numberWithInt:NSOffState],					@"dontErasePreview",
	[NSNumber numberWithInt:NSOffState],					@"onlyDisplayPart",
	[NSNumber numberWithInt:NSOffState],					@"continueRendering",
	[NSNumber numberWithInt:NSOffState],					@"writeIniFile",
	//file gamma
	[NSNumber numberWithInt:NSOffState],					@"fileGammaOn",
	@"sRGB" ,																			@"fileGammaEdit",
	[NSNumber numberWithInt:NSOffState],					@"grayScaleOutputOn",

	//Quality ***********************************************************************************
	[NSNumber numberWithInt:9] ,									@"quality",
	//dithering
	[NSNumber numberWithInt:NSOffState],					@"ditheringOn",
	[NSNumber numberWithInt:cDitheringFloydSteinberg],	@"ditheringMethod",

	//anti-aliasing
	[NSNumber numberWithInt:NSOnState],			@"samplingOn",
	[NSNumber numberWithInt:1] ,						@"sampleMethod",
	@"0.3",																	@"sampleThreshold",
	@"3",																		@"sampleRecursion",
	@"1.0",																	@"sampleJitter",
	@"2.5",																	@"mOutletSamplingGamma",

	//Bounding & Preview ***********************************************************************************
	//Render pattern ****************************************************************************************
	@"1" ,                                    @"renderBlockStep",
	[NSNumber numberWithInt:NSOffState],			@"renderBlockStepOn",
	[NSNumber numberWithInt:cRenderPattern0], @"renderPattern",
	//Threads ****************************************************************************************
	[NSNumber numberWithInt:cAutomatic],          @"Work_Threads",
	[NSNumber numberWithInt:cRenderBlockSize32],	@"RenderBlockSize",

	//radiosity ***********************************************************************************
	[NSNumber numberWithInt:cRadiosityVainOnCell],	@"mRadiosityVainMatrix",
	//warning level
	[NSNumber numberWithInt:cWarningLevel10],       @"mWarningLevelPopup",

	//text streams ***********************************************************************************
	[NSNumber numberWithInt:NSOnState],					@"redirectTextStreamsOnOff",
	[NSNumber numberWithInt:NSOffState],				@"debugToFile",
	[NSNumber numberWithInt:NSOnState],					@"debugToScreen",
	[NSNumber numberWithInt:NSOffState],				@"fatalToFile",
	[NSNumber numberWithInt:NSOnState],					@"fatalToScreen",
	[NSNumber numberWithInt:NSOffState],				@"renderToFile",
	[NSNumber numberWithInt:NSOnState],					@"renderToScreen",
	[NSNumber numberWithInt:NSOffState],				@"statisticsToFile",
	[NSNumber numberWithInt:NSOnState],					@"statisticsToScreen",
	[NSNumber numberWithInt:NSOffState],				@"warningToFile",
	[NSNumber numberWithInt:NSOnState],					@"warningToScreen",
	//auto bounding ***********************************************************************************
	[NSNumber numberWithInt:NSOnState],					@"autoBoundingOnOff",
	[NSNumber numberWithInt:cBoudingObjects3],	@"boundingObjects",
	[NSNumber numberWithInt:NSOnState],					@"ignoreBoundedBy",
	[NSNumber numberWithInt:NSOnState],					@"splitUnions",
	//new for 3.7 ***********************************************************************************
	[NSNumber numberWithInt:NSOffState],				@"BSPBoundingMethodOnOff",
	@"128",																			@"BSP_MaxDepth",
	@"1.0",																			@"BSP_BaseAccessCost",
	@"1.5",																			@"BSP_ChildAccessCost",
	@"150.0",																		@"BSP_IsectCost",
	@"0.2",																			@"BSP_MissChance",
	// end new for 3.7 ***********************************************************************************

	//animation (clock) ***********************************************************************************
	[NSNumber numberWithInt:NSOffState],					@"animationOnOff",
	[NSNumber numberWithInt:NSOffState],					@"turnCyclicAnimationOn",
	[NSNumber numberWithInt:NSOffState],					@"frameStepOn",
	[NSNumber numberWithInt:cFieldRenderingOff],		@"fieldRendering",
	@"0.0",																	@"clockInitial",
	@"1.0",																	@"clockEnd",
	@"1",																		@"initialFrame",
	@"10",																	@"finalFrame",
	@"1",																		@"subsetStart",
	@"10",																	@"subsetEnd",
	@"+1",																	@"frameStep",

	//misc ***********************************************************************************
	@"",																		@"redirectAllOutputImagesPath",
	[NSNumber numberWithInt:cBitDepth16],					@"boundingObjects",
	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
// building of factory settings.
//---------------------------------------------------------------------
+(void) initialize
{
	NSMutableDictionary *mutDict=[PreferencesPanelController mutableDictionaryWithDefaultSettings];
	// we save it as an object of another dictionary, makes it easier to retrieve
	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
																 mutDict,dFactorySettings,
																 [NSNumber numberWithInt:0], @"sortBySize",
																 nil];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:factoryDefaults];
	
}

//---------------------------------------------------------------------
// setIndexOfSelectedTabViewItem
//---------------------------------------------------------------------
- (NSNumber*)setIndexOfSelectedTabViewItem:(NSNumber *)selectedTab
{
	[indexOfSelectedTabViewItem release];
	indexOfSelectedTabViewItem=selectedTab;
	[indexOfSelectedTabViewItem retain];
	return indexOfSelectedTabViewItem;
}



//---------------------------------------------------------------------
// saveCurrentSettingsInDefaultSettingsoc
//	notification when application quits
// gives us the chance to save the current content
// in this panel
//---------------------------------------------------------------------
-(void) saveCurrentSettingsInDefaultSettings: (NSNotification *)ntf
{
	//find the current settings;
	NSMutableDictionary *dict=[self getDictWithCurrentSettings:NO];
	if ( dict)
	{
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		[defaults setObject:dict forKey:dLastValuesInPanel];
		[defaults synchronize];
	}
}


//---------------------------------------------------------------------
// updateDefaults
//---------------------------------------------------------------------
// updateDefaults writes the settings to the defaultsDatabase
//---------------------------------------------------------------------
- (void) updateDefaults
{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSArray *appArray=[NSArray arrayWithArray:mSettingsArray];
	[defaults setObject:appArray forKey:@"mainPrefsArray"];
	[self buildPreferencesPopup];
}

//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{

	NSNumber *number=[[notification userInfo] objectForKey: @"renderStarted"];
	if ( number)
	{
		if ( [number boolValue] == YES)
		{
			[startRenderButton setEnabled:NO];
			[startRenderButton setTitle:@"Busy..."];
		}
		else
		{
			[startRenderButton setEnabled:YES];
			[startRenderButton setTitle:@"Render"];
		}
		
	}
}


//---------------------------------------------------------------------
// acceptDocument
//---------------------------------------------------------------------
// notification
//	object is a NSDocument which wants to place itself in the preferences dialog
//---------------------------------------------------------------------
-(void) acceptDocument:(NSNotification *) notification
{
	SceneDocument *document=[notification object];
	
	if ( document && [[document fileURL]path]!= nil)
	{
		[self setSceneFileNameInPanel:[[document fileURL]path]];
		
		id dict=[notification userInfo];
		if ( dict != nil)
		{
			NSNumber *number=[dict objectForKey: @"orderFront"];
			if ( number)
			{
				if ( [number boolValue] == YES)
				{
					[[tabViewOutlet window] makeKeyAndOrderFront:self];
				}
			}
		}
		else
			[[tabViewOutlet window] makeKeyAndOrderFront:self];
	}
}


//--------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
//	Read the array with settings and move the settings from the
//	last run in the panel
//---------------------------------------------------------------------
- (void) awakeFromNib
{
	[ToolTipAutomator setTooltips:@"preferencespanel" andDictionary:
	 [NSDictionary dictionaryWithObjectsAndKeys:
		renderingPreferencesPresets,	@"renderingPreferencesPresets",
		startRenderButton,						@"startRenderButton",
		languageVersion,							@"languageVersion",
		sceneFile,										@"sceneFile",
		imageFile,										@"imageFile",
		useIniInputFile,							@"useIniInputFile",
		iniInputFile,									@"iniInputFile",

		mRadiosityLoadSaveGroupOn,		@"mRadiosityLoadSaveGroupOn",
		mRadiosityLoadOn,							@"mRadiosityLoadOn",
		mRadiositySaveOn,							@"mRadiositySaveOn",
		mRadiosityFileNameEdit,				@"mRadiosityFileNameEdit",
		
		
		include1,											@"include1",
		include2,											@"include2",
		imageSizeX,										@"imageSizeX",
		imageSizeY,										@"imageSizeY",
		xSubsetEnd,										@"xSubsetEnd",
		xSubsetStart,									@"xSubsetStart",
		ySubsetEnd,										@"ySubsetEnd",
		ySubsetStart,									@"ySubsetStart",
		ratioOnOff,										@"ratioOnOff",
		ratioPresets,									@"ratioPresets",
		ratioX,												@"ratioX",
		ratioY,												@"ratioY",
		presetsImageSizes,						@"presetsImageSizes",
		addAlphaChannel,							@"addAlphaChannel",
		bitDepth,											@"bitDepth",
		imageType,										@"imageType",
		dontDisplay,									@"dontDisplay",
		dontErasePreview,							@"dontErasePreview",
		onlyDisplayPart,							@"onlyDisplayPart",
		grayScaleOutputOn,						@"grayScaleOutputOn",
		fileGammaOn,									@"fileGammaOn",
		fileGammaEdit,								@"fileGammaEdit",
		continueRendering,						@"continueRendering",
		writeIniFile,									@"writeIniFile",
		samplingOn,										@"samplingOn" ,
		ditheringOn,									@"ditheringOn" ,
		ditheringMethod,							@"ditheringMethod" ,
		highReproducibilityOn,				@"highReproducibilityOn",
		quality,											@"quality",
		sampleJitter,									@"sampleJitter",
		sampleMethod,									@"sampleMethod",
		sampleRecursion,							@"sampleRecursion",
		sampleThreshold,							@"sampleThreshold",
		mOutletSamplingGamma,					@"mOutletSamplingGamma",
		redirectTextStreamsOnOff,			@"redirectTextStreamsOnOff",
		debugToFile,									@"debugToFile",
		debugToScreen,								@"debugToScreen",
		fatalToFile,									@"fatalToFile",
		fatalToScreen,								@"fatalToScreen",
		renderToFile,									@"renderToFile",
		renderToScreen,								@"renderToScreen",
		statisticsToFile,							@"statisticsToFile",
		statisticsToScreen,						@"statisticsToScreen",
		warningToFile,								@"warningToFile",
		warningToScreen,							@"warningToScreen",
		autoBoundingOnOff,						@"autoBoundingOnOff",
		boundingObjects,							@"boundingObjects",
		ignoreBoundedBy,							@"ignoreBoundedBy",
		splitUnions,									@"splitUnions",
		
		BSPBoundingMethodOnOff,				@"BSPBoundingMethodOnOff",
		BSP_MaxDepth,									@"BSP_MaxDepth",
		BSP_BaseAccessCost,						@"BSP_BaseAccessCost",
		BSP_ChildAccessCost,					@"BSP_ChildAccessCost",
		BSP_IsectCost,								@"BSP_IsectCost",
		BSP_MissChance,								@"BSP_MissChance",
		
		//Render pattern ****************************************************************************************
		renderBlockStep,							@"renderBlockStep",
		renderBlockStepOn,						@"renderBlockStepOn",
		renderPattern,								@"renderPattern",
		//Work threads
		mNumberOfCpusPopupButton,			@"Work_Threads",
		mRenderBlockSizePopupButton,	@"RenderBlockSize",
		mRadiosityVainMatrix,					@"mRadiosityVainMatrix",
		mWarningLevelPopup,						@"mWarningLevelPopup",
		
		redirectAllOutputImagesOnOff,	@"redirectAllOutputImagesOnOff",
		redirectAllOutputImagesPath,	@"redirectAllOutputImagesPath",
		animationOnOff,								@"animationOnOff",
		clockEnd,											@"clockEnd",
		clockInitial,									@"clockInitial",
		fieldRendering,								@"fieldRendering",
		finalFrame,										@"finalFrame",
		frameStep,										@"frameStep",
		frameStepOn,									@"frameStepOn",
		initialFrame,									@"initialFrame",
		subsetEnd,										@"subsetEnd",
		subsetStart,									@"subsetStart",
		turnCyclicAnimationOn,				@"turnCyclicAnimationOn",
		
		//extra:
		sceneFileButton,							@"sceneFileButton",
		imageFileButton,							@"imageFileButton",
		iniInputFilebutton,						@"iniInputFilebutton",
		include1Button,								@"include1Button",
		include2Button,								@"include2Button",
		setFullSizeButton,						@"setFullSizeButton",
		clearInclude1Button,					@"clearInclude1Button",
		clearInclude2Button,					@"clearInclude2Button",
		editSceneFileButton,					@"editSceneFileButton",
		redirectOutputPathButton,			@"redirectOutputPathButton",
		
		nil
		]
	 ];
	
	// we need to save our settings when the application quits.
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(saveCurrentSettingsInDefaultSettings:)
	 name:NSApplicationWillTerminateNotification
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(renderState:)
	 name:@"renderState"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(renderState:)
	 name:@"preparingState"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(acceptDocument:)
	 name:@"acceptDocument"
	 object:nil];
	
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(newSelectionInPreviewwindowSet:)
	 name:@"newSelectionInPreviewwindowSet"
	 object:nil];
	
	//settingspanel
	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(selectionSettingsPanelTableViewChanged:)
	 name:NSTableViewSelectionDidChangeNotification
	 object:settingsPanelTableView];
	
	
	[imageType setAutoenablesItems:NO];
	[bitDepth setAutoenablesItems:NO];
	
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSArray *appArray=[defaults arrayForKey:@"mainPrefsArray"];
	mSettingsArray=[[NSMutableArray alloc] initWithArray:appArray];
	// work threads
	[mNumberCoresFound setIntValue:[[MainController sharedInstance]getNumberOfCpus]];
	
	
	[self buildPreferencesPopup];
	
	[renderingPreferencesPresets selectItemAtIndex:0];
	
	//now, search for the last settings used and restore those in the panel
	// if that is not possible, set the factory settings
	if ( [self putDictionaryInPanel:[self setttingsDictionaryWithName:dLastValuesInPanel] allowFileChange:YES]==NO)
		[self putDictionaryInPanel:[[NSUserDefaults standardUserDefaults] objectForKey:dFactorySettings]allowFileChange:YES];
	
	//get the last selected tabView and restore
	[self setIndexOfSelectedTabViewItem:[defaults objectForKey:@"indexOfSelectedTabViewItem"]];
	[tabViewOutlet selectTabViewItemAtIndex:[indexOfSelectedTabViewItem intValue]];
	
}

//---------------------------------------------------------------------
// buildPreferencesPopup
//---------------------------------------------------------------------
-(void) buildPreferencesPopup
{
	NSMenu *settingsPresetsMenu=[renderingPreferencesPresets menu];
	NSMenuItem *newItem;
	[renderingPreferencesPresets removeAllItems];
	
	newItem=[[[NSMenuItem alloc]init] autorelease];	[newItem setTitle:@"Save current settings..."];
	[settingsPresetsMenu	addItem:newItem];
	newItem=[[[NSMenuItem alloc]init] autorelease];	[newItem setTitle:@"Edit list of settings..."];
	[settingsPresetsMenu	addItem:newItem];
	[settingsPresetsMenu	addItem:[NSMenuItem separatorItem]];
	//factory settings
	newItem=[	[[NSMenuItem alloc]init] autorelease];
	[newItem setTitle:dFactorySettings];
	[settingsPresetsMenu	addItem:newItem];
	[settingsPresetsMenu	addItem:[NSMenuItem separatorItem]];
	
	//from here on user settings
	
	for (int index=0; index <[mSettingsArray count]; index++)
	{
		NSMutableDictionary *dict=[mSettingsArray objectAtIndex:index];
		NSString *dictName=[dict objectForKey:@"dictionaryName"];
		newItem=[[NSMenuItem alloc]init];
		[newItem setTitle:dictName];
		[settingsPresetsMenu	addItem:newItem];
		[newItem release];
	}
	//end of presets menu
}

//---------------------------------------------------------------------
// tabView
//---------------------------------------------------------------------
// delegate for tabView to keep track of the selected tab
//---------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	[self setIndexOfSelectedTabViewItem:[NSNumber numberWithInt:[tabView indexOfTabViewItem:tabViewItem]]];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults setObject:indexOfSelectedTabViewItem forKey:@"indexOfSelectedTabViewItem"];
}


//---------------------------------------------------------------------
// putDictionaryInPanel
//	move all settings from dictToUse in the render preferences dialog
// make sure all required settings are in the dict by comparing with default
// setttings and adding them if there are not present to avoid errors
//---------------------------------------------------------------------
- (BOOL) putDictionaryInPanel: (NSMutableDictionary*)dictToUse allowFileChange:(BOOL)fileChange
{
	if ( dictToUse==nil)	//in this case leave everything as is
		return NO;
	// first add all missing settings (might happen if we add a setting)
	NSMutableDictionary *defaultSettings=[PreferencesPanelController mutableDictionaryWithDefaultSettings];
	if ( defaultSettings != nil)
	{
		NSEnumerator *enumerator = [defaultSettings keyEnumerator];
		id key;
 		while ((key = [enumerator nextObject]))
		{
			if ( [dictToUse objectForKey:key] ==nil)
			{
				//				NSLog(@"%@",key);
				[dictToUse setObject:[defaultSettings objectForKey:key] forKey:key];
			}
		}
	}
	
	//Files and paths
	// if a version 3.7 languageVersion_xx key exists use it, otherwise
	// use the old version.
	id obj=[dictToUse objectForKey:@"languageVersion_xx"];
	if ( obj != NULL)
	{
		switch ([obj intValue])
		{
			case 10: [languageVersion selectItemAtIndex:cLanguageVersion1X]; break;
			case 20: [languageVersion selectItemAtIndex:cLanguageVersion2X]; break;
			case 30: [languageVersion selectItemAtIndex:cLanguageVersion30X]; break;
			case 31: [languageVersion selectItemAtIndex:cLanguageVersion31X]; break;
			case 35: [languageVersion selectItemAtIndex:cLanguageVersion35X]; break;
			case 36: [languageVersion selectItemAtIndex:cLanguageVersion36X]; break;
			case 37: [languageVersion selectItemAtIndex:cLanguageVersion37X]; break;
			default:	[languageVersion selectItemAtIndex:cLanguageVersion37X];
		}
	}
	else
		[languageVersion selectItemAtIndex:[[dictToUse objectForKey:@"languageVersion"]intValue]];
	
	if ( fileChange == YES)
	{
		[sceneFile setStringValue:[dictToUse objectForKey:@"sceneFile"]];
		[imageFile setStringValue:[dictToUse objectForKey:@"imageFile"]];
		[include1 setStringValue:[dictToUse objectForKey:@"include1"]];
		[include2 setStringValue:[dictToUse objectForKey:@"include2"]];
		[useIniInputFile setState:[[dictToUse objectForKey:@"useIniInputFile"]intValue]];
		[iniInputFile setStringValue:[dictToUse objectForKey:@"iniInputFile"]];
	}
	[self targetFilesAndPaths:useIniInputFile];

	[mRadiosityFileNameEdit setStringValue:[dictToUse objectForKey:@"mRadiosityFileNameEdit"]];
	[mRadiosityLoadSaveGroupOn setState:[[dictToUse objectForKey:@"mRadiosityLoadSaveGroupOn"]intValue]];
	[mRadiosityLoadOn setState:[[dictToUse objectForKey:@"mRadiosityLoadOn"]intValue]];
	[mRadiositySaveOn setState:[[dictToUse objectForKey:@"mRadiositySaveOn"]intValue]];
	[self targetFilesAndPaths:mRadiosityLoadSaveGroupOn];


	[imageSizeX setStringValue:[dictToUse objectForKey:@"imageSizeX"]];
	[imageSizeY setStringValue:[dictToUse objectForKey:@"imageSizeY"]];
	[xSubsetStart setStringValue:[dictToUse objectForKey:@"xSubsetStart"]];
	[ySubsetStart setStringValue:[dictToUse objectForKey:@"ySubsetStart"]];
	[xSubsetEnd setStringValue:[dictToUse objectForKey:@"xSubsetEnd"]];
	[ySubsetEnd setStringValue:[dictToUse objectForKey:@"ySubsetEnd"]];
	[self updateStartEndRatio];
	
	[ratioPresets selectItemAtIndex:[[dictToUse objectForKey:@"ratioPresets"] intValue]];
	[ratioOnOff setState:[[dictToUse objectForKey:@"ratioOnOff"]intValue]];
	[ratioX setStringValue:[dictToUse objectForKey:@"ratioX"]];
	[ratioY setStringValue:[dictToUse objectForKey:@"ratioY"]];
	[self preferencesTarget:ratioOnOff];
//	[self ratioOnOff: ratioOnOff];
	//output options
	[imageType selectItemAtIndex:[[dictToUse objectForKey:@"imageType"] intValue]];
	
	[addAlphaChannel setState:[[dictToUse objectForKey:@"addAlphaChannel"]intValue]];
	[bitDepth selectItemAtIndex:[[dictToUse objectForKey:@"bitDepth"] intValue]];
	[dontDisplay setState:[[dictToUse objectForKey:@"dontDisplay"]intValue]];
	[dontErasePreview setState:[[dictToUse objectForKey:@"dontErasePreview"]intValue]];
	[self preferencesTarget:dontDisplay];
	[onlyDisplayPart setState:[[dictToUse objectForKey:@"onlyDisplayPart"]intValue]];
	[continueRendering setState:[[dictToUse objectForKey:@"continueRendering"]intValue]];
	[writeIniFile setState:[[dictToUse objectForKey:@"writeIniFile"]intValue]];
	
	[grayScaleOutputOn setState:[[dictToUse objectForKey:@"grayScaleOutputOn"]intValue]];
	[fileGammaOn setState:[[dictToUse objectForKey:@"fileGammaOn"]intValue]];
	[fileGammaEdit setStringValue:[dictToUse objectForKey:@"fileGammaEdit"]];
	[self preferencesTarget:fileGammaOn];
//	enableObjectsAccordingToObject(fileGammaOn,fileGammaEdit,nil);

	//quality
	[quality selectItemAtIndex:[[dictToUse objectForKey:@"quality"] intValue]];
	
	//dithering
	[ditheringOn setState:[[dictToUse objectForKey:@"ditheringOn"]intValue]];
	[highReproducibilityOn setState:[[dictToUse objectForKey:@"highReproducibilityOn"]intValue]];
	[ditheringMethod selectItemAtIndex:[[dictToUse objectForKey:@"ditheringMethod"] intValue]];
	[self preferencesTarget:ditheringOn];
//	SetSubViewsOfNSBoxToState(ditheringGroup, [ditheringOn state]);
	
	//anti-aliasing
	[samplingOn setState:[[dictToUse objectForKey:@"samplingOn"]intValue]];
	[self preferencesTarget:samplingOn];
//	SetSubViewsOfNSBoxToState(samplingGroup, [samplingOn state]);
	[sampleMethod selectItemAtIndex:[[dictToUse objectForKey:@"sampleMethod"] intValue]];
	[sampleThreshold setStringValue:[dictToUse objectForKey:@"sampleThreshold"]];
	[sampleRecursion setStringValue:[dictToUse objectForKey:@"sampleRecursion"]];
	[sampleJitter setStringValue:[dictToUse objectForKey:@"sampleJitter"]];
	[mOutletSamplingGamma setStringValue:[dictToUse objectForKey:@"mOutletSamplingGamma"]];
	
	//Bounding & Preview
	
	//text streams
	[redirectTextStreamsOnOff setState:[[dictToUse objectForKey:@"redirectTextStreamsOnOff"]intValue]];
	[self preferencesTarget:redirectTextStreamsOnOff];
//	SetSubViewsOfNSBoxToState(redirectTextStreamsGroup, [redirectTextStreamsOnOff state]);
	[debugToFile setState:[[dictToUse objectForKey:@"debugToFile"]intValue]];
	[debugToScreen setState:[[dictToUse objectForKey:@"debugToScreen"]intValue]];
	[fatalToFile setState:[[dictToUse objectForKey:@"fatalToFile"]intValue]];
	[fatalToScreen setState:[[dictToUse objectForKey:@"fatalToScreen"]intValue]];
	[renderToFile setState:[[dictToUse objectForKey:@"renderToFile"]intValue]];
	[renderToScreen setState:[[dictToUse objectForKey:@"renderToScreen"]intValue]];
	[statisticsToFile setState:[[dictToUse objectForKey:@"statisticsToFile"]intValue]];
	[statisticsToScreen setState:[[dictToUse objectForKey:@"statisticsToScreen"]intValue]];
	[warningToFile setState:[[dictToUse objectForKey:@"warningToFile"]intValue]];
	[warningToScreen setState:[[dictToUse objectForKey:@"warningToScreen"]intValue]];
	//----------------------------------------------------------------------------------------------
	//auto bounding----------------
	//----------------------------------------------------------------------------------------------
	[autoBoundingOnOff setState:[[dictToUse objectForKey:@"autoBoundingOnOff"]intValue]];
	[BSPBoundingMethodOnOff setState:[[dictToUse objectForKey:@"BSPBoundingMethodOnOff"]intValue]];
	[self preferencesTarget:autoBoundingOnOff];
/*	SetSubViewsOfNSBoxToState(autoBoundingSystemGroup, [autoBoundingOnOff state]);
	SetSubViewsOfNSBoxToState(BSPBoundingGroup, [autoBoundingOnOff state]);
	if ([autoBoundingOnOff state] == NSOnState)
	{
		SetSubViewsOfNSBoxToState(BSPBoundingGroup, [BSPBoundingMethodOnOff state]);
	}
	*/
	[BSP_MaxDepth setStringValue:[dictToUse objectForKey:@"BSP_MaxDepth"]];
	[BSP_BaseAccessCost setStringValue:[dictToUse objectForKey:@"BSP_BaseAccessCost"]];
	[BSP_ChildAccessCost setStringValue:[dictToUse objectForKey:@"BSP_ChildAccessCost"]];
	[BSP_IsectCost setStringValue:[dictToUse objectForKey:@"BSP_IsectCost"]];
	[BSP_MissChance setStringValue:[dictToUse objectForKey:@"BSP_MissChance"]];
	
	//render block size
	[mRenderBlockSizePopupButton selectItemAtIndex:[[dictToUse objectForKey:@"RenderBlockSize"]intValue]];
	//radiosity vain
	[mRadiosityVainMatrix selectCellWithTag:[[dictToUse objectForKey:@"mRadiosityVainMatrix"]intValue]];
	//warning level
	[mWarningLevelPopup selectItemAtIndex:[[dictToUse objectForKey:@"mWarningLevelPopup"]intValue]];
	//work threads
	[mNumberOfCpusPopupButton selectItemAtIndex:[[dictToUse objectForKey:@"Work_Threads"]intValue]];
	
	
	//Render pattern ****************************************************************************************
	[renderPattern selectItemAtIndex:[[dictToUse objectForKey:@"renderPattern"]intValue]];
	[renderBlockStep setStringValue:[dictToUse objectForKey:@"renderBlockStep"]];
	[renderBlockStepOn setState:[[dictToUse objectForKey:@"renderBlockStepOn"]intValue]];
	[self preferencesTarget:renderBlockStepOn];
//	[self renderBlockStepOn:renderBlockStepOn];
	
	
	[boundingObjects selectItemAtIndex:[[dictToUse objectForKey:@"boundingObjects"]intValue]];
	[ignoreBoundedBy setState:[[dictToUse objectForKey:@"ignoreBoundedBy"]intValue]];
	[splitUnions setState:[[dictToUse objectForKey:@"splitUnions"]intValue]];
	
	
	//animation (clock)
	[animationOnOff setState:[[dictToUse objectForKey:@"animationOnOff"]intValue]];
	[self preferencesTarget:animationOnOff];
//	[self animationOnOff:nil];
	[turnCyclicAnimationOn setState:[[dictToUse objectForKey:@"turnCyclicAnimationOn"]intValue]];
	[frameStepOn setState:[[dictToUse objectForKey:@"frameStepOn"]intValue]];
	[self preferencesTarget:frameStepOn];
//	[self frameStepOn:frameStepOn];
	[fieldRendering selectItemAtIndex:[[dictToUse objectForKey:@"fieldRendering"]intValue]];
	[clockInitial setStringValue:[dictToUse objectForKey:@"clockInitial"]];
	[clockEnd setStringValue:[dictToUse objectForKey:@"clockEnd"]];
	[initialFrame setStringValue:[dictToUse objectForKey:@"initialFrame"]];
	[finalFrame setStringValue:[dictToUse objectForKey:@"finalFrame"]];
	[subsetStart setStringValue:[dictToUse objectForKey:@"subsetStart"]];
	[subsetEnd setStringValue:[dictToUse objectForKey:@"subsetEnd"]];
	[frameStep setStringValue:[dictToUse objectForKey:@"frameStep"]];
	
	//misc
	[redirectAllOutputImagesPath setStringValue:[dictToUse objectForKey:@"redirectAllOutputImagesPath"]];
	[redirectAllOutputImagesOnOff setState:[[dictToUse objectForKey:@"redirectAllOutputImagesOnOff"]intValue]];
	[self preferencesTarget:redirectAllOutputImagesOnOff];
//	[self redirectAllOutputImagesOnOff:nil];
	[self setPanelTitle];
	
	
	return YES;
}

//---------------------------------------------------------------------
// setPanelTitle
//---------------------------------------------------------------------
-(void) setPanelTitle
{
	NSString *str=[NSString  stringWithFormat:@"Preferences for: %@", [[sceneFile stringValue] lastPathComponent]];
	[[tabViewOutlet window] setTitle:str];
}

//---------------------------------------------------------------------
// currentSettingsDictionary
//	search for the dict witht the last used settings
//---------------------------------------------------------------------
- (NSMutableDictionary*) setttingsDictionaryWithName: (NSString*)dictionaryToSearchFor
{
	int index=[mSettingsArray count];
	NSMutableDictionary *dict;
	// first see if it is in the defaults (could be factory settings)
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	dict=[defaults objectForKey:dictionaryToSearchFor];
	if ( dict)
	{
		//return a copy because for some reson on tiger it returns a NSDictionary instead of a mutable copy ??!xyz
		NSMutableDictionary *mdCopy=[NSMutableDictionary dictionaryWithDictionary:dict];
		return mdCopy;
		//		return dict;
	}
	while (index >0)
	{
		NSMutableDictionary *dict=[mSettingsArray objectAtIndex:--index];
		if ([[dict objectForKey:@"dictionaryName"]isEqualToString: dictionaryToSearchFor])
			return dict;
	}
	return nil;
}

//---------------------------------------------------------------------
// putDictionaryInSettingsArray
//
//---------------------------------------------------------------------
- (int) putDictionaryInSettingsArray: (NSMutableDictionary*)dictionaryToAdd
{
	if  (dictionaryToAdd==nil)
		return 0;
	
	NSString *dictName=[dictionaryToAdd objectForKey:@"dictionaryName"];
	if  (dictName == nil)	//no name, so we don't add it
		return 0;
	
	int index=[mSettingsArray count];
	
	while (index >0)
	{
		NSMutableDictionary *dict=[mSettingsArray objectAtIndex:--index];
		if ([[dict objectForKey:@"dictionaryName"]isEqualToString: dictName])
		{
			[mSettingsArray replaceObjectAtIndex:index withObject:dictionaryToAdd];
			[self updateDefaults];
			return index+1;
		}
	}
	//name not found, so we add it
	[mSettingsArray addObject:dictionaryToAdd];
	[self updateDefaults];
	return [mSettingsArray count];
}


#pragma mark ----Files and paths----

//---------------------------------------------------------------------
// targetFilesAndPaths
//---------------------------------------------------------------------
-(IBAction) targetFilesAndPaths:(id)sender
{
	NSSavePanel *savePanel=nil;
	NSOpenPanel *openPanel=nil;
	
	switch([sender tag])
	{
		case selectSceneFileTag:
		{
			openPanel=[NSOpenPanel openPanel];
			//	fileTypes=[[NSArray arrayWithObjects: @"pov", @"inc", @"txt", NSFileTypeForHFSTypeCode('TEXT'),nil]retain];
			[openPanel setAllowsMultipleSelection:NO];
			[openPanel setCanChooseDirectories:NO];
			[openPanel setCanChooseFiles:YES];
			[openPanel setDirectoryURL:nil];
			[openPanel setAllowedFileTypes:[NSArray arrayWithObjects: @"pov", @"inc", @"txt", NSFileTypeForHFSTypeCode('TEXT'),nil]];
			[openPanel beginSheetModalForWindow:[sceneFile window]
												completionHandler: ^( NSInteger resultCode )
			 {
			@autoreleasepool
			{
			 if ( resultCode == NSOKButton)
				 {
					 [sceneFile setStringValue:[[openPanel URL]path]];
					 [self setPanelTitle];
					 // make a full path with scene file but without the extension as an output file.
					 // example: /volumes/disk1/scene.pov becomes /volumes/disk1/scene.
					 NSString *temp=[[ sceneFile stringValue] stringByDeletingPathExtension];
					 [imageFile setStringValue:[temp stringByAppendingString:@"."]];
				 }
			}
		 }
		 ];
			}
			break;
		
		case selectImageFileTag:
		{
				savePanel=[NSSavePanel savePanel];
			[savePanel setCanCreateDirectories:YES];
			[savePanel setDirectoryURL:nil];
			[savePanel beginSheetModalForWindow:[imageFile window]
												completionHandler: ^( NSInteger resultCode )
			 {
			@autoreleasepool
			{
					 if( (resultCode == NSOKButton) && [imageFile respondsToSelector:@selector(setStringValue:)])
						 [imageFile setStringValue:[[savePanel URL]path]];
			}
			 }
			 ];
		}
			break;
			
		case selectInclude1Tag:
		{
				[self selectInclude:sender forField:include1];
		}
				break;
			
		case selectInclude2Tag:
			[self selectInclude:sender forField:include2];
			break;
			
		case clearInclude1Tag:
			[include1 setStringValue:@""];
			break;
			
		case clearInclude2Tag:
			[include2 setStringValue:@""];
			break;
			
		case useIniInputFileTag:
			SetSubViewsOfNSBoxToState(useIniFileGroup, [useIniInputFile state]);
			if ( [mRadiosityLoadSaveGroupOn state]==NSOnState ||[useIniInputFile state]==NSOnState)
				[mUseIniGreenLed setHidden:NO];
			else
				[mUseIniGreenLed setHidden:YES];
			
			break;
		case RadiosityLoadSaveGroupOnTag:
			SetSubViewsOfNSBoxToState(mRadiosityLoadSaveGroupBox, [mRadiosityLoadSaveGroupOn state]);
			if ( [mRadiosityLoadSaveGroupOn state]==NSOnState ||[useIniInputFile state]==NSOnState)
				[mUseIniGreenLed setHidden:NO];
			else
				[mUseIniGreenLed setHidden:YES];
			
			break;
		case selectInputIniFileTag:
			openPanel=[NSOpenPanel openPanel];
			[openPanel setAllowsMultipleSelection:NO];
			[openPanel setCanChooseDirectories:NO];
			[openPanel setCanChooseFiles:YES];
			[openPanel setAllowedFileTypes:[NSArray arrayWithObjects: @"ini", NSFileTypeForHFSTypeCode('Tini'),nil]];
			[openPanel setDirectoryURL:nil];
			[openPanel beginSheetModalForWindow:[iniInputFile window]
												completionHandler: ^( NSInteger resultCode )
			 {
			@autoreleasepool
			{
					 if( (resultCode == NSOKButton) && [iniInputFile respondsToSelector:@selector(setStringValue:)])
						 [iniInputFile setStringValue:[[openPanel URL]path]];
			}
			 }
			 ];
			break;
	}
}

//---------------------------------------------------------------------
// setSceneFileNameInPanel
//---------------------------------------------------------------------
-(void)setSceneFileNameInPanel: (NSString*) newFile
{
	[sceneFile setStringValue:newFile];
	[self setPanelTitle];
	// make a full path with scene file but without the extension as an output file.
	// example: /volumes/disk1/scene.pov becomes /volumes/disk1/scene.
	NSString *temp=[[ sceneFile stringValue] stringByDeletingPathExtension];
	[imageFile setStringValue:[temp stringByAppendingString:@"."]];
}

//---------------------------------------------------------------------
// selectInclude:forField: forKey
//---------------------------------------------------------------------
- (void) selectInclude: (id) sender forField:(NSTextField*)textfield
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setAllowedFileTypes:nil];
	[openPanel setDirectoryURL:nil];
	[openPanel beginSheetModalForWindow:[include1 window]
										completionHandler: ^( NSInteger resultCode )
	 {
			@autoreleasepool
			{
			 if( (resultCode == NSOKButton) && [textfield respondsToSelector:@selector(setStringValue:)])
				 [textfield setStringValue:[[openPanel URL]path]];
			}
	 }
	 ];
}


#pragma mark ----Image and quality -----

//---------------------------------------------------------------------
// controlTextDidChange
//	delegate for all objects in this window
//	Maintains ratio if the switch is turned on etc.
//---------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	static bool inside=false;
	if ( inside==false)
	{
		preferencesTag tag=[[aNotification object]tag];
		switch (tag)
		{
			case cImageXTag:	//image with
				inside = true;
				if ( [ratioOnOff state] == NSOnState)
					[imageSizeY setIntValue:(int)([imageSizeX floatValue]/([ratioX floatValue]/[ratioY floatValue]))];
				[self updateStartEndValues];
				inside= false;
				break;
			case cImageYTag:	//image height
				inside = true;
				if ( [ratioOnOff state] == NSOnState)
					[imageSizeX setIntValue:(int)([imageSizeY floatValue]*([ratioX floatValue]/[ratioY floatValue]))];
				[self updateStartEndValues];
				inside= false;
				break;
			case cImageRatioXTag:	//ratio x and y
			case 	cImageRatioYTag:
				inside = true;
				if ( [ratioOnOff state] == NSOnState)
					[imageSizeY setIntValue:(int)([imageSizeX floatValue]/([ratioX floatValue]/[ratioY floatValue]))];
				[self updateStartEndValues];
				inside= false;
				break;
			case cXSubsetStart:
			case cXSubsetEnd:
			case cYSubsetStart:
			case cYSubsetEnd:
				inside = true;
				if ( [xSubsetEnd integerValue] >[imageSizeX floatValue] ||[xSubsetEnd integerValue]<0)
					[xSubsetEnd setIntValue:[imageSizeX integerValue]];
				if ( [ySubsetEnd integerValue] >[imageSizeY floatValue]||[ySubsetEnd integerValue]<0)
					[ySubsetEnd setIntValue:[imageSizeY integerValue]];
				[self updateStartEndRatio];
				[self sendNotificationSubsetDidChange];
				inside= false;
				break;
		}
	}
}

//---------------------------------------------------------------------
// updateStartEndRatio
//	Keeps up with the ratio to be able to follow start-end with image size
//---------------------------------------------------------------------
- (void) updateStartEndValues
{
	// column
	[xSubsetStart setIntValue:MAX( (int)([imageSizeX floatValue] *startColumnRatio), (int)1)];
	[xSubsetEnd setIntValue:MIN( (int)([imageSizeX floatValue] *endColumnRatio), [imageSizeX intValue])];
	
	//row
	[ySubsetStart setIntValue:MAX( (int)([imageSizeY floatValue] *startRowRatio), (int)1)];
	[ySubsetEnd setIntValue:MIN( (int)([imageSizeY floatValue] *endRowRatio), [imageSizeY intValue])];
	[self sendNotificationSubsetDidChange];
}


//---------------------------------------------------------------------
// sendNotificationSubsetDidChange
//---------------------------------------------------------------------
// if value of x, y, endx or endy changes
// send a notification to the previewwindow
// so that the selection display can be updated
//---------------------------------------------------------------------
-(void) sendNotificationSubsetDidChange
{
	NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
											[NSNumber numberWithBool:YES], @"yStartsAtTop",
											[NSNumber numberWithInt: [xSubsetStart intValue]] ,	@"columnStart",
											[NSNumber numberWithInt: [xSubsetEnd intValue]] ,		@"columnEnd",
											[NSNumber numberWithInt: [ySubsetStart intValue]],	@"rowStart",
											[NSNumber numberWithInt: [ySubsetEnd intValue]] ,		@"rowEnd",
											[NSNumber numberWithInt: [imageSizeX intValue]] ,		@"imageSizeX",
											[NSNumber numberWithInt: [imageSizeY intValue]] ,		@"imageSizeY",
											nil];
	
	[[NSNotificationCenter defaultCenter]
	 postNotificationName:@"newSelectionInPreferencesPanelSet"
	 object:self
	 userInfo:dict];
}

//---------------------------------------------------------------------
// newSelectionInPreviewwindowSet
//---------------------------------------------------------------------
// notification
// when the user makes a selection in the preview window,
// the new start and end values are posted.
// New partial render values are set in the panel.
//---------------------------------------------------------------------
-(void) newSelectionInPreviewwindowSet:(NSNotification *) notification
{
	
	NSNumber *start=[[notification userInfo] objectForKey: @"columnStart"];
	NSNumber *end=[[notification userInfo] objectForKey: @"columnEnd"];
	[xSubsetStart setIntValue:[start intValue]];
	[xSubsetEnd setIntValue:[end intValue]];
	
	end=[[notification userInfo] objectForKey: @"rowEnd"];
	start=[[notification userInfo] objectForKey: @"rowStart"];
	[ySubsetStart setIntValue:[start intValue]];
	[ySubsetEnd setIntValue:[end intValue]];
	[self updateStartEndRatio];
	
	[[tabViewOutlet window] makeKeyAndOrderFront:self];
}

//---------------------------------------------------------------------
// updateStartEndValues
//	Set a new value in start/end field
//---------------------------------------------------------------------
- (void) updateStartEndRatio
{
	// column Start
	if ( [xSubsetStart intValue]==1)
		startColumnRatio=0.0;
	else
		startColumnRatio=[xSubsetStart floatValue] / [imageSizeX floatValue];
	//column end
	endColumnRatio=[xSubsetEnd floatValue] / [imageSizeX floatValue];
	
	// row Start
	if ( [ySubsetStart intValue]==1)
		startRowRatio=0.0;
	else
		startRowRatio=[ySubsetStart floatValue] / [imageSizeY floatValue];
	//column end
	endRowRatio=[ySubsetEnd floatValue] / [imageSizeY floatValue];
}



//---------------------------------------------------------------------
// preferencesTarget
//---------------------------------------------------------------------
-(IBAction) preferencesTarget:(id)sender
{
	NSURL *sceneUrl;
	NSOpenPanel *openPanel;
	NSMutableDictionary *currentSettings;
	int theTag;
	theTag=[sender tag];
	switch( theTag)
	{
		case cEditSceneFile:
			sceneUrl=[NSURL fileURLWithPath:[sceneFile stringValue]];
			if ( sceneUrl != nil)
			{
				NSDocumentController *ctrl=[NSDocumentController sharedDocumentController];
				//next line available from 10,7
			[ctrl openDocumentWithContentsOfURL:sceneUrl display:YES error:nil ];
			}
			break;
		case cStartRender:
			currentSettings=[self getDictWithCurrentSettings:YES	];
			if ( currentSettings)	//make sure we have usable settings to render the file
			{
				NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
												[NSNumber numberWithBool:YES] ,	@"shouldStartRendering",
												currentSettings,								@"rendersettings",
												[NSDate date],								@"dateOfPosting",
												nil];
		
				[[NSNotificationCenter defaultCenter] postNotificationName:@"renderDocument" object:self userInfo:dict];
			}
			break;
		case cRenderingPreferencesPresets:
			if ( [sender indexOfSelectedItem]==cSave  || [sender indexOfSelectedItem]==cModify)	// save or modify
				[self processSettingsPanel:[sender indexOfSelectedItem]];
			else if ( [sender indexOfSelectedItem]==3)
				[self putDictionaryInPanel:[self setttingsDictionaryWithName:dFactorySettings]allowFileChange:NO];
			else
				[self putDictionaryInPanel:[self setttingsDictionaryWithName:[sender titleOfSelectedItem]] allowFileChange:NO];
			break;
		case cDontDisplay:
			if ( [dontDisplay state]==NSOnState)
				[dontErasePreview setEnabled:NO];
			else
				[dontErasePreview setEnabled:YES];
			break;
		case cRatioPresets:
			switch([sender indexOfSelectedItem])
			{
				case cRatio1_1:
					[ratioX setStringValue:@"1"];
					[ratioY setStringValue:@"1"];
					break;
				case cRatio2_1:
					[ratioX setStringValue:@"2"];
					[ratioY setStringValue:@"1"];
					break;
				case cRatio4_3:
					[ratioX setStringValue:@"4"];
					[ratioY setStringValue:@"3"];
					break;
				case cRatio16_9:
					[ratioX setStringValue:@"16"];
					[ratioY setStringValue:@"9"];
					break;
				case cRatio1_2:
					[ratioX setStringValue:@"1"];
					[ratioY setStringValue:@"2"];
					break;
				case cRatio3_4:
					[ratioX setStringValue:@"3"];
					[ratioY setStringValue:@"4"];
					break;
				case cRatio9_16:
					[ratioX setStringValue:@"9"];
					[ratioY setStringValue:@"16"];
					break;
			}
			[ [NSNotificationCenter defaultCenter]
			 postNotificationName:NSControlTextDidChangeNotification
			 object:imageSizeX ];
			break;
		case cRatioOnOff:
			{
				BOOL enabledState=NO;
				if ( [sender state] == NSOnState)
					enabledState=YES;
				[ratioX setEnabled:enabledState];
				[ratioY setEnabled:enabledState];
				[ratioPresets setEnabled:enabledState];
			}
			break;
		case cPresetsImageSizes:
		{
			//get the title from the popup menuitem (example 200 * 200)
			NSString *menuItemText=[sender itemTitleAtIndex:[sender indexOfSelectedItem]];
			if ( [menuItemText length])	//anything usefull?
			{
				NSMutableArray *valuesArray=scanForValuesInString( menuItemText);
				if ([valuesArray count] == 2)
				{
					[imageSizeX setIntValue:[[valuesArray objectAtIndex:0]intValue]];
					[imageSizeY setIntValue:[[valuesArray objectAtIndex:1]intValue]];
					[self updateStartEndValues];
			//		[ [NSNotificationCenter defaultCenter]	 postNotificationName:NSControlTextDidChangeNotification object:imageSizeX ];
				}
			}
		}
			break;
		case cSubsetToFullSize:
			[xSubsetStart setStringValue:@"1"];
			[ySubsetStart setStringValue:@"1"];
			[xSubsetEnd setStringValue:[imageSizeX stringValue]];
			[ySubsetEnd setStringValue:[imageSizeY stringValue]];
			[self updateStartEndRatio];
			[self sendNotificationSubsetDidChange];
			break;
		case BithDepthPopupTag:
			switch( [imageType indexOfSelectedItem])
			{
				case cImageTypeDontSave:
				case cImageTypeTarga:
				case cImageTypeTargaCompressed:
				case cImageTypeHdr:
				case cImageTypeExr:
					[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypePNG:
					[grayScaleOutputOn setEnabled:YES];
					break;
				case cImageTypePPM:
					if ( [bitDepth indexOfSelectedItem]==cBitDepth16)
						[grayScaleOutputOn setEnabled:YES];
					else
						[grayScaleOutputOn setEnabled:NO];
					break;
			}//switch( [imageType indexOfSelectedItem])
			break;
			case cDitheringOn:
				SetSubViewsOfNSBoxToState(ditheringGroup, [sender state]);
			break;
			case cSamplingOn:
				SetSubViewsOfNSBoxToState(samplingGroup, [sender state]);
			break;
			case cFileGammaOn:
				enableObjectsAccordingToObject(fileGammaOn,fileGammaEdit,nil);
			break;
		case ImageTypePopupTag:	//image type
			switch( [sender indexOfSelectedItem])
			{
				case cImageTypeDontSave:																//----------------don't save
					[dontDisplay setEnabled:NO];
					[dontDisplay setState:NSOffState];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					//	[addAlphaChannel setEnabled:NO];
					[continueRendering setEnabled:NO];
					[bitDepth setEnabled:NO];
					[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypeTarga:																//----------------Targa + targa compressed
				case cImageTypeTargaCompressed:
					[dontDisplay setEnabled:YES];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					[addAlphaChannel setEnabled:YES];
					[continueRendering setEnabled:YES];
					[bitDepth setEnabled:YES];
					[bitDepth selectItemAtIndex:cBitDepth8];
					[[bitDepth itemAtIndex:cBitDepth5]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth8]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth12]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth16]setEnabled:NO];
					[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypePNG:																//----------------png
					[dontDisplay setEnabled:YES];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					[addAlphaChannel setEnabled:YES];
					[continueRendering setEnabled:YES];
					[bitDepth setEnabled:YES];
					[bitDepth selectItemAtIndex:cBitDepth8];
					[[bitDepth itemAtIndex:cBitDepth5]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth8]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth12]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth16]setEnabled:YES];
					if ( [bitDepth indexOfSelectedItem]==cBitDepth16)
						[grayScaleOutputOn setEnabled:YES];
					else
						[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypePPM:																//----------------ppm
					[dontDisplay setEnabled:YES];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					[addAlphaChannel setEnabled:NO];
					[continueRendering setEnabled:YES];
					[bitDepth setEnabled:YES];
					[bitDepth selectItemAtIndex:cBitDepth8];
					[[bitDepth itemAtIndex:cBitDepth5]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth8]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth12]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth16]setEnabled:YES];
					if ( [bitDepth indexOfSelectedItem]==cBitDepth16)
						[grayScaleOutputOn setEnabled:YES];
					else
						[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypeHdr:																//----------------hdr
					[dontDisplay setEnabled:YES];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					[addAlphaChannel setEnabled:YES];
					[continueRendering setEnabled:YES];
					[bitDepth setEnabled:YES];
					[bitDepth selectItemAtIndex:cBitDepth8];
					[[bitDepth itemAtIndex:cBitDepth5]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth8]setEnabled:YES];
					[[bitDepth itemAtIndex:cBitDepth12]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth16]setEnabled:NO];
					[grayScaleOutputOn setEnabled:NO];
					break;
				case cImageTypeExr:																//----------------openEXR
					[dontDisplay setEnabled:YES];
					if ( [dontDisplay state]==NSOnState)
						[dontErasePreview setEnabled:NO];
					else
						[dontErasePreview setEnabled:YES];
					[addAlphaChannel setEnabled:NO];
					[continueRendering setEnabled:YES];
					[bitDepth setEnabled:NO];
					[bitDepth selectItemAtIndex:cBitDepth8];
					[[bitDepth itemAtIndex:cBitDepth5]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth8]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth12]setEnabled:NO];
					[[bitDepth itemAtIndex:cBitDepth16]setEnabled:NO];
					[grayScaleOutputOn setEnabled:NO];
				break;
			}//switch( [sender indexOfSelectedItem]) of imagetype
			if ( [imageType indexOfSelectedItem]!=cImageTypeDontSave)
				[mSaveOutputfileGreenLed setHidden:NO];
			else
				[mSaveOutputfileGreenLed setHidden:YES];
			break;
		case cRedirectTextStreamsOnOff:
			SetSubViewsOfNSBoxToState(redirectTextStreamsGroup, [sender state]);
			break;
		case cAutoBoundingOnOff:
			SetSubViewsOfNSBoxToState(autoBoundingSystemGroup, [sender state]);
			SetSubViewsOfNSBoxToState(BSPBoundingGroup, [sender state]);
			if ([autoBoundingOnOff state] == NSOnState)
				SetSubViewsOfNSBoxToState(BSPBoundingGroup, [BSPBoundingMethodOnOff state]);
			break;
		case cBSPBoundingMethodOnOff:
			if ([autoBoundingOnOff state] == NSOnState)
				SetSubViewsOfNSBoxToState(BSPBoundingGroup, [BSPBoundingMethodOnOff state]);
			else
				SetSubViewsOfNSBoxToState(BSPBoundingGroup, NSOffState);
			break;
		case cRenderBlockStepOn:
			if ( [sender state])
				[renderBlockStep setEnabled:YES];
			else
				[renderBlockStep setEnabled:NO];
			break;
		//clock
		case cAnimationOnOff:
			SetSubViewsOfNSBoxToState(animationSettingsGroup, [animationOnOff state]);
			if( [animationOnOff state]==NSOnState)
				[self preferencesTarget:frameStepOn];
			if ( [animationOnOff state]==NSOnState)
				[mClockGreenLed setHidden:NO];
			else
				[mClockGreenLed setHidden:YES];
			break;
		case cFrameStepOn:
			if ( [sender state])
				[frameStep setEnabled:YES];
			else
				[frameStep setEnabled:NO];
			break;
		//misc
		case cRedirectAllOutputImagesOnOff:
			SetSubViewsOfNSBoxToState(redirectAllOutputImagesGroup, [redirectAllOutputImagesOnOff state]);
			if ( [redirectAllOutputImagesOnOff state]==NSOnState)
				[mMiscGreenLed setHidden:NO];
			else
				[mMiscGreenLed setHidden:YES];
			break;
		case cRedirectAllOutputImagesPath:
			openPanel=[NSOpenPanel openPanel];
			[openPanel setAllowsMultipleSelection:NO];
			[openPanel setCanChooseDirectories:YES];
			[openPanel setCanChooseFiles:NO];
			[openPanel setAllowedFileTypes:nil];
			[openPanel setDirectoryURL:nil];
			[openPanel beginSheetModalForWindow:[redirectAllOutputImagesPath window] completionHandler: ^( NSInteger resultCode )
				{
					@autoreleasepool
					{
						if( (resultCode == NSOKButton) && [redirectAllOutputImagesPath respondsToSelector:@selector(setStringValue:)])
							[redirectAllOutputImagesPath setStringValue:[[openPanel URL]path]];
					}
				}
			];
			break;
		
	}
}




//---------------------------------------------------------------------
// getDictWithCurrentSettings
//	returns a NSMutableDictionary with the current settings
//---------------------------------------------------------------------
-(NSMutableDictionary*) getDictWithCurrentSettings:(BOOL) writeToDefaults
{
	// make sure changes are set
	[[tabViewOutlet window] makeFirstResponder: [tabViewOutlet window] ];
	NSMutableDictionary *dict=[[NSMutableDictionary dictionary]autorelease];
	if ( dict)
	{
		[dict retain];
		//name of the dictionary
		[dict setObject:dLastValuesInPanel forKey:@"dictionaryName"];
		//files & paths
		
		// language version
		// as of version 3.7 we add a key: languageVersion_xx which contains an integer
		// for version. 10 or 1.0, 20 for 2.0,...
		// we keep the old system for compatibility reasons with 3.6
		NSInteger version=[languageVersion indexOfSelectedItem];
		switch (version)
		{
			case cLanguageVersion1X: version=10; break;
			case cLanguageVersion2X: version=20; break;
			case cLanguageVersion30X: version=30; break;
			case cLanguageVersion31X: version=31; break;
			case cLanguageVersion35X: version=35; break;
			case cLanguageVersion36X: version=36; break;
			case cLanguageVersion37X: version=37; break;
			default: version=37;
		}
		[dict setObject:@(version) forKey:@"languageVersion_xx"];
		if ( version <37)
			[dict setObject:@([languageVersion indexOfSelectedItem]) forKey:@"languageVersion"];
		else
			[dict setObject:[NSNumber numberWithInt:cLanguageVersion36X] forKey:@"languageVersion"];
		
		[dict setObject:[sceneFile stringValue] forKey:@"sceneFile"];
		[dict setObject:[imageFile stringValue] forKey:@"imageFile"];
		[dict setObject:@([useIniInputFile state]) forKey:@"useIniInputFile"];
		[dict setObject:[iniInputFile stringValue] forKey:@"iniInputFile"];


		[dict setObject:@([mRadiosityLoadSaveGroupOn state]) forKey:@"mRadiosityLoadSaveGroupOn"];
		[dict setObject:@([mRadiosityLoadOn state]) forKey:@"mRadiosityLoadOn"];
		[dict setObject:@([mRadiositySaveOn state]) forKey:@"mRadiositySaveOn"];
		[dict setObject:[mRadiosityFileNameEdit stringValue] forKey:@"mRadiosityFileNameEdit"];


		[dict setObject:[include1 stringValue] forKey:@"include1"];
		[dict setObject:[include2 stringValue] forKey:@"include2"];
		//image & quality
		[dict setObject:[imageSizeX stringValue] forKey:@"imageSizeX"];
		[dict setObject:[imageSizeY stringValue] forKey:@"imageSizeY"];
		[dict setObject:[xSubsetStart stringValue] forKey:@"xSubsetStart"];
		[dict setObject:[ySubsetStart stringValue] forKey:@"ySubsetStart"];
		[dict setObject:[xSubsetEnd stringValue] forKey:@"xSubsetEnd"];
		[dict setObject:[ySubsetEnd stringValue] forKey:@"ySubsetEnd"];
		[dict setObject:[NSNumber numberWithInt:[ratioOnOff state]] forKey:@"ratioOnOff"];
		[dict setObject:[NSNumber numberWithInt:[ratioPresets indexOfSelectedItem]] forKey:@"ratioPresets"];
		[dict setObject:[ratioX stringValue] forKey:@"ratioX"];
		[dict setObject:[ratioY stringValue] forKey:@"ratioY"];
		
		//output options
		[dict setObject:[NSNumber numberWithInt:[imageType indexOfSelectedItem]] forKey:@"imageType"];
		[dict setObject:[NSNumber numberWithInt:[addAlphaChannel state]] forKey:@"addAlphaChannel"];
		[dict setObject:[NSNumber numberWithInt:[bitDepth indexOfSelectedItem]] forKey:@"bitDepth"];
		[dict setObject:[NSNumber numberWithInt:[dontDisplay state]] forKey:@"dontDisplay"];
		[dict setObject:[NSNumber numberWithInt:[dontErasePreview state]] forKey:@"dontErasePreview"];
		[dict setObject:[NSNumber numberWithInt:[onlyDisplayPart state]] forKey:@"onlyDisplayPart"];
		[dict setObject:[NSNumber numberWithInt:[continueRendering state]] forKey:@"continueRendering"];
		[dict setObject:[NSNumber numberWithInt:[writeIniFile state]] forKey:@"writeIniFile"];
		
		[dict setObject:[NSNumber numberWithInt:[grayScaleOutputOn state]] forKey:@"grayScaleOutputOn"];
		[dict setObject:[NSNumber numberWithInt:[fileGammaOn state]] forKey:@"fileGammaOn"];
		[dict setObject:[fileGammaEdit stringValue] forKey:@"fileGammaEdit"];
		
		//quality
		[dict setObject:[NSNumber numberWithInt:[quality indexOfSelectedItem]] forKey:@"quality"];
		//dithering
		[dict setObject:[NSNumber numberWithInt:[ditheringOn state]] forKey:@"ditheringOn"];
		[dict setObject:[NSNumber numberWithInt:[highReproducibilityOn state]] forKey:@"highReproducibilityOn"];
		[dict setObject:[NSNumber numberWithInt:[ditheringMethod indexOfSelectedItem]] forKey:@"ditheringMethod"];
		
		//anti-aliasing
		[dict setObject:[NSNumber numberWithInt:[samplingOn state]] forKey:@"samplingOn"];
		[dict setObject:[NSNumber numberWithInt:[sampleMethod indexOfSelectedItem]] forKey:@"sampleMethod"];
		[dict setObject:[sampleThreshold stringValue] forKey:@"sampleThreshold"];
		[dict setObject:[mOutletSamplingGamma stringValue] forKey:@"mOutletSamplingGamma"];
		[dict setObject:[sampleRecursion stringValue] forKey:@"sampleRecursion"];
		[dict setObject:[sampleJitter stringValue] forKey:@"sampleJitter"];
		
		//bounding & Preview
		//threads
		[dict setObject:[NSNumber numberWithInt:[mNumberOfCpusPopupButton indexOfSelectedItem]] forKey:@"Work_Threads"];
		[dict setObject:[NSNumber numberWithInt:[mRenderBlockSizePopupButton indexOfSelectedItem]] forKey:@"RenderBlockSize"];
		//radiosity vain
		[dict setObject:[NSNumber numberWithInt:[[mRadiosityVainMatrix selectedCell]tag]] forKey:@"mRadiosityVainMatrix"];
		//Warning level
		[dict setObject:[NSNumber numberWithInt:[mWarningLevelPopup indexOfSelectedItem]] forKey:@"mWarningLevelPopup"];
		
		//Render pattern ****************************************************************************************
		[dict setObject:[NSNumber numberWithInt:[renderPattern indexOfSelectedItem]] forKey:@"renderPattern"];
		[dict setObject:[renderBlockStep stringValue] forKey:@"renderBlockStep"];
		[dict setObject:[NSNumber numberWithInt:[renderBlockStepOn state]] forKey:@"renderBlockStepOn"];
		
		//text streams
		[dict setObject:[NSNumber numberWithInt:[redirectTextStreamsOnOff state]]forKey:@"redirectTextStreamsOnOff"];
		[dict setObject:[NSNumber numberWithInt:[debugToFile state]] forKey:@"debugToFile"];
		[dict setObject:[NSNumber numberWithInt:[debugToScreen state]] forKey:@"debugToScreen"];
		[dict setObject:[NSNumber numberWithInt:[fatalToFile state]] forKey:@"fatalToFile"];
		[dict setObject:[NSNumber numberWithInt:[fatalToScreen state]] forKey:@"fatalToScreen"];
		[dict setObject:[NSNumber numberWithInt:[renderToFile state]] forKey:@"renderToFile"];
		[dict setObject:[NSNumber numberWithInt:[renderToScreen state]] forKey:@"renderToScreen"];
		[dict setObject:[NSNumber numberWithInt:[statisticsToFile state]] forKey:@"statisticsToFile"];
		[dict setObject:[NSNumber numberWithInt:[statisticsToScreen state]] forKey:@"statisticsToScreen"];
		[dict setObject:[NSNumber numberWithInt:[warningToFile state]] forKey:@"warningToFile"];
		[dict setObject:[NSNumber numberWithInt:[warningToScreen state]] forKey:@"warningToScreen"];
		
		//bounding
		[dict setObject:@([autoBoundingOnOff state])forKey:@"autoBoundingOnOff"];
		[dict setObject:@([boundingObjects indexOfSelectedItem]) forKey:@"boundingObjects"];
		[dict setObject:@([ignoreBoundedBy state]) forKey:@"ignoreBoundedBy"];
		[dict setObject:@([splitUnions state]) forKey:@"splitUnions"];
		[dict setObject:@([BSPBoundingMethodOnOff state])forKey:@"BSPBoundingMethodOnOff"];
		[dict setObject:[BSP_MaxDepth stringValue] forKey:@"BSP_MaxDepth"];
		[dict setObject:[BSP_BaseAccessCost stringValue] forKey:@"BSP_BaseAccessCost"];
		[dict setObject:[BSP_ChildAccessCost stringValue] forKey:@"BSP_ChildAccessCost"];
		[dict setObject:[BSP_IsectCost stringValue] forKey:@"BSP_IsectCost"];
		[dict setObject:[BSP_MissChance stringValue] forKey:@"BSP_MissChance"];
		
	
		//animation (clock)
		[dict setObject:@([animationOnOff state]) forKey:@"animationOnOff"];
		[dict setObject:@([turnCyclicAnimationOn state]) forKey:@"turnCyclicAnimationOn"];
		[dict setObject:@([frameStepOn state]) forKey:@"frameStepOn"];
		[dict setObject:@([fieldRendering indexOfSelectedItem]) forKey:@"fieldRendering"];
		[dict setObject:[clockInitial stringValue] forKey:@"clockInitial"];
		[dict setObject:[clockEnd stringValue] forKey:@"clockEnd"];
		[dict setObject:[initialFrame stringValue]forKey:@"initialFrame"];
		[dict setObject:[finalFrame stringValue] forKey:@"finalFrame"];
		[dict setObject:[subsetStart stringValue]forKey:@"subsetStart"];
		[dict setObject:[subsetEnd stringValue] forKey:@"subsetEnd"];
		[dict setObject:[frameStep stringValue] forKey:@"frameStep"];
		
		
		//misc
		[dict setObject:[redirectAllOutputImagesPath stringValue] forKey:@"redirectAllOutputImagesPath"];
		[dict setObject:@([redirectAllOutputImagesOnOff state]) forKey:@"redirectAllOutputImagesOnOff"];
		
		// before a render, force the current setting to be written to disc
		// if a crash occurs, the settings are stored for the next launch
		if ( writeToDefaults==YES && dict)
		{
			NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
			[defaults setObject:dict forKey:dLastValuesInPanel];
			[defaults synchronize];
		}

	//	[dict autorelease];
	}
	return dict;	//will return nil if no success
}

//---------------------------------------------------------------------
// makeSettingsDescription
//---------------------------------------------------------------------
-(NSString *) makeSettingsDescription
{
	NSString *settings=nil;
	settings=[NSString stringWithFormat:@"%@ * %@ |", [imageSizeX stringValue], [imageSizeY stringValue]];
	if ( [samplingOn  state]==NSOnState)
	{
		settings=[settings stringByAppendingString:[NSString stringWithFormat:@" +AA %@ %@ |",[sampleThreshold stringValue], [sampleRecursion stringValue]]];
	}
	else
		settings=[settings stringByAppendingString:@" No AA |"];
	
	
	return settings;
}

//---------------------------------------------------------------------
// processSettingsPanel
//---------------------------------------------------------------------
-(void) processSettingsPanel:(int) saveEdit
{
	// make a backup of the current settings in case we cancel
	mBackupSettingsArray=[mSettingsArray mutableCopy];
	
	mSettingsPanelMode=saveEdit;
	[settingsPanelTableView deselectAll:nil];
	switch (saveEdit)
	{
		case cSave:
			[settingsPanelOk setTitle:@"Save"];
			[settingsPanelRename setEnabled:NO];
			[settingsPanelRename setTransparent:YES];
			[settingsPanelDelete setEnabled:NO];
			[settingsPanelDelete setTransparent:YES];
			[self setButtonStateSettingsPanel: [self getDictWithCurrentSettings:NO] ];
			[settingsPanelTextField setStringValue:[self makeSettingsDescription]];
	break;
		case cModify:
			[settingsPanelOk setTitle:@"Ok"];
			[settingsPanelRename setEnabled:YES];
			[settingsPanelRename setTransparent:NO];
			[settingsPanelDelete setEnabled:YES];
			[settingsPanelDelete setTransparent:NO];
			[self setButtonStateSettingsPanel:nil];
			break;
	}
	[[NSApplication sharedApplication] beginSheet:settingsPanel
																 modalForWindow:[tabViewOutlet window] modalDelegate:self
																 didEndSelector:@selector(settingsPanelDidEnd:returnCode:contextInfo:) contextInfo:nil];
	
}

//---------------------------------------------------------------------
// settingsPanelOk
//---------------------------------------------------------------------
- (IBAction) settingsPanelOk:(id)sender
{
	[[NSApplication sharedApplication] endSheet: settingsPanel];
	if( mSettingsPanelMode==cSave)	// only if we save, not in case of modifying
	{
		NSMutableDictionary *dict=[self getDictWithCurrentSettings:NO];
		if ( dict)
		{
			[dict setObject:[settingsPanelTextField stringValue] forKey:@"dictionaryName"];
			[self putDictionaryInSettingsArray: dict];
			[settingsPanelTableView noteNumberOfRowsChanged];
		}
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		[defaults setObject:@([[settingsPanelSortMatrix selectedCell] tag]) forKey: @"sortBySize"];
	}
	[self updateDefaults];
	[mBackupSettingsArray release];	// no need for it anymore
	mBackupSettingsArray=nil;
	// post notification so that our batch window knows of the changed settings
	[[NSNotificationCenter defaultCenter] postNotificationName:@"renderingSettingsChaged" 	object:self 	userInfo:nil];
}

//---------------------------------------------------------------------
// settingsPanelRename
//---------------------------------------------------------------------
- (IBAction) settingsPanelRename: (id)sender
{
	NSInteger row=[settingsPanelTableView selectedRow];
	if ( row != -1)
	{
		NSInteger index=[mSettingsArray count];
		if (  row <=index)
		{
			NSMutableDictionary *dict=[mSettingsArray objectAtIndex:row];
			[dict setObject:[settingsPanelTextField stringValue] forKey:@"dictionaryName"];
		}
		[settingsPanelTableView noteNumberOfRowsChanged];
	}
	
}

//---------------------------------------------------------------------
// settingsPanelSortMatrix
//---------------------------------------------------------------------
- (IBAction) settingsPanelSortMatrix: (id)sender
{
	switch( [[sender selectedCell] tag])
	{
		case 0: 	//size
			[mSettingsArray sortUsingFunction:sortSettingsBySize context:nil];
			break;
		case 1: //name
			[mSettingsArray sortUsingFunction:sortSettingsByName context:nil];
			break;
	}
	[settingsPanelTableView reloadData];
	[self buildPreferencesPopup ];
	
}


//---------------------------------------------------------------------
// settingsPanelCancel
//---------------------------------------------------------------------
- (IBAction) settingsPanelCancel:(id)sender
{
	[[NSApplication sharedApplication] endSheet: settingsPanel];
	// restore to the way it was before we called the panel
	[mSettingsArray release];
	mSettingsArray=mBackupSettingsArray;
	mBackupSettingsArray=nil;
	[self buildPreferencesPopup];
	[settingsPanelTableView noteNumberOfRowsChanged];
	[self updateDefaults];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	if ( [[defaults objectForKey:@"sortBySize"]intValue]==0)
		[settingsPanelSortMatrix selectCellWithTag:0];
	else
		[settingsPanelSortMatrix selectCellWithTag:1];
}

//---------------------------------------------------------------------
// settingsPanelDelete
//---------------------------------------------------------------------
- (IBAction) settingsPanelDelete:(id)sender
{
	NSInteger row=[settingsPanelTableView selectedRow];
	if ( row != -1)
	{
		NSInteger index=[mSettingsArray count];
		if (  row <=index)
		{
			[mSettingsArray removeObjectAtIndex:row];
			[self updateDefaults];
		}
		[settingsPanelTableView noteNumberOfRowsChanged];
	}
}

//---------------------------------------------------------------------
// settingsPanelDidEnd
//---------------------------------------------------------------------
-(void) settingsPanelDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	[sheet orderOut: nil];
}

// datasource
//---------------------------------------------------------------------
// selectionIncludePathTableViewChanged
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
-(void) selectionSettingsPanelTableViewChanged:(NSNotification *) notification
{
	[self setButtonStateSettingsPanel:nil];
}

//---------------------------------------------------------------------
// setButtonStateSettingsPanel
//---------------------------------------------------------------------
-(void) setButtonStateSettingsPanel: (NSMutableDictionary*) dictToUse;
{
	int enabledState=NO;
	NSMutableDictionary *localDict=nil;
	
	// if a row is selected, use the settings from that row
	// this means it is calles to modify the list of settings
	if ( [settingsPanelTableView numberOfSelectedRows] ==0)
		localDict = dictToUse;
	else if (	[settingsPanelTableView numberOfSelectedRows] >0)
	{
		localDict=[mSettingsArray objectAtIndex:[settingsPanelTableView selectedRow]];
		enabledState=YES;
	}
	
	if ( localDict)
	{
		[settingsPanelTextField setStringValue:[localDict objectForKey:@"dictionaryName"]];
		[settingsPanelX setStringValue:[localDict objectForKey:@"imageSizeX"]];
		[settingsPanelY setStringValue:[localDict objectForKey:@"imageSizeY"]];
		if ( [[localDict objectForKey:@"samplingOn"] intValue] ==NSOnState)
			[settingsPanelAntiAliasing setStringValue:@"On"];
		else
			[settingsPanelAntiAliasing setStringValue:@"Off"];
			
		[settingsPanelThreshold setStringValue:[localDict objectForKey:@"sampleThreshold"]];
		[settingsPanelRecursion setStringValue:[localDict objectForKey:@"sampleRecursion"]];
		if ( [[localDict objectForKey:@"sampleMethod"] intValue] ==0)
			[settingsPanelMethod setStringValue:@"1"];
		else
			[settingsPanelMethod setStringValue:@"2"];
		[settingsPanelJitter setStringValue:[localDict objectForKey:@"sampleJitter"] ];
	}
	// no row selected, this means we are saving current settings
	// normaly dictToUse will point to a valid dictionary
	// if not, it is nil
	else
	{
		[settingsPanelTextField setStringValue:@""];
		[settingsPanelX setStringValue:@""];
		[settingsPanelY setStringValue:@""];
		[settingsPanelAntiAliasing setStringValue:@""];
		[settingsPanelThreshold setStringValue:@""];
		[settingsPanelRecursion setStringValue:@""];
		[settingsPanelMethod setStringValue:@""];
		[settingsPanelJitter setStringValue:@""];
	}
	if ( mSettingsPanelMode==cModify)
	{
		
		[settingsPanelRename setEnabled:enabledState];
		[settingsPanelDelete setEnabled:enabledState];
		if ( [[settingsPanelTextField stringValue]length]==0 )
			[settingsPanelRename setEnabled:NO];
		
	}
}


//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [mSettingsArray count];
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [[mSettingsArray objectAtIndex:row] objectForKey:@"dictionaryName"];
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	switch ([aMenuItem tag])
	{
		case eTag_renderMenu:
			if ( gIsRendering==YES)
				return NO;
			else
				return YES;
			break;
		case eTag_pauseMenu:
			break;
		case eTag_abortMenu:
			if ( gIsRendering==YES)
				return YES;
			else
				return NO;
			break;
	}
	if ( [aMenuItem action] == @selector(saveDocument:) )
		return NO;
	return YES;
	
}

//---------------------------------------------------------------------
// saveDocument:
//---------------------------------------------------------------------
-(IBAction) saveDocument:(id)sender
{
}

@end

//---------------------------------------------------------------------
// sortSettingsBySize
//---------------------------------------------------------------------
static NSInteger sortSettingsBySize(id first, id last, void*context)
{
	NSString *a, *b;
	a=[first objectForKey:@"imageSizeX"];
	b=[last objectForKey:@"imageSizeX"];
	if ( [a intValue] < [b intValue])
		return NSOrderedAscending;	//receiver smaler than argument
	else if ( [a intValue] > [b intValue])
		return NSOrderedDescending;	//larger
	
	return NSOrderedSame;				//same
}
//---------------------------------------------------------------------
// sortSettingsByName
//---------------------------------------------------------------------
static NSInteger sortSettingsByName(id first, id last, void*context)
{
	NSString *a, *b;
	NSRange range;
	a=[first objectForKey:@"dictionaryName"];
	b=[last objectForKey:@"dictionaryName"];
	if ( [a length] > [b length])
		range=NSMakeRange(0,[a length]);
	else
		range=NSMakeRange(0,[b length]);
	
	return  [a compare:b options:NSCaseInsensitiveSearch range:range];
}
