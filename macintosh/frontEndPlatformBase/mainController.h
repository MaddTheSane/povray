//******************************************************************************
///
/// @file /macintosh/frontEndPlatformBase/mainController.h
///
/// more or less the application delegate...
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
/* MainController */

#import <Cocoa/Cocoa.h>
//#import <pthread.h>
#import "sceneDocument.h"
#import "configbase.h"
#import "renderDispatcher.h"
#import "MessageViewController.h"
#import "picturePreview.h"
#import "MaterialPreview.h"
#import "PreferencesPanelController.h"
#import "renderDispatcher.h"
#import "standardMethods.h"
#import "menuFromDirectory.h"

#define notWatching 0
#define watching 1
#define aborting 2

enum menuTags {
	eTag_renderMenu					=100,
	eTag_pauseMenu					=101,
	eTag_abortMenu					=102,
	eTag_gotoMenu						=103,
	eTag_aboutMenu					=104,
	eTAb_shutDownWhenDone		=115,
	eTag_convertTemplate		=114,
	//batch
	eTag_ShowMenu						=105,
	eTag_AddMenu						=106,
	eTag_InsertMenu					=107,
	eTag_RemoveMenu					=108,
	eTag_ResetSelectedMenu	=109,
	eTag_ResetAllMenu				=110,
	eTag_RunAllMenu					=111,
	eTag_RunSelectedMenu		=112,
	eTag_AbortMenu					=113,
	
	eTag_Import							=200,
	eTag_Export							=201
};

extern picturePreview		*gPicturePreview;
extern materialPreview	*gMaterialPreview;
extern NSInteger				numericBlockPoint;


extern BOOL				rememberOpenWindowsOn;

extern BOOL				globalAutoSyntaxColoring;	// Automatically refresh syntax coloring when text is changed?
extern BOOL				maintainIndentation;	// Keep new lines indented at same depth as their predecessor?
extern NSControlStateValue	autoIndentBraces;	// Keep new lines indented at same depth as their predecessor?
extern int				tabDistance;
// Attribute constants added along with styles to program text:
#define commentAndStringAttributeName				@"cn"  //@"MegaPOV_Styntax_Coloring_Attribute"
#define allExceptCommentAndStringAttribute	@"nn"
#define commentAttribute										@"cm"
#define noneCommentAttribute								@"nc"

extern id	activeRenderPreview;
extern bool gApplicationShouldTerminate;
extern volatile bool gUserWantsToAbortRender;
extern volatile bool gApplicationAlreadyReceivedStopResquest;
extern bool	gIsRendering;
extern bool	gIsPausing;
extern volatile bool	gUserWantsToPauseRenderer;


@interface MainController : NSObject
{
	IBOutlet NSMenu				*mMainMenu;
	IBOutlet NSMenuItem		*mTemplateMenuItem;
 	IBOutlet NSTextField	*copyRightMessage;
 	IBOutlet NSPanel			*copyRightPanel;
 	IBOutlet NSWindow			*mMessageWindow;
 	IBOutlet NSWindow			*mPreferencesWindow;
 	IBOutlet NSWindow			*mProgressWindow;
	IBOutlet NSWindow 		*mPreviewWindow;
	
	IBOutlet NSMenuItem 	*mPreviewWindowMenuItem;
	IBOutlet NSMenuItem		*mSleepWhenDoneMenuItem;
 	menuFromDirectory			*mMainTemplateInsertMenu;
	NSInteger							mNumberOfCpus;
	short       mCountDownForSleep;
	NSAlert     *mGoToSleepAlert;
	NSString		*mGoToSleepInformatieveText;
	NSTimer			*mGoToSleepTimer;
}

+ (MainController*) sharedInstance;
- (void) previewWindowChangedName: (NSString*) newName;

- (menuFromDirectory*) templateMainInsertMenu;
- (void) setMenuFromDirectory: (menuFromDirectory*) menu;
- (void) reloadTemplateInsertMenu;
- (void) stopWatchingInsertMenu;

- (void) buildTemplateInsertMenu;
- (void) putInMultiThreadedMode:(id) anobject;
- (IBAction) orderFrontStandardAboutPanel:(id) sender;

- (IBAction) povRayLegalHelp:(id) sender;
- (IBAction) povRayBetaHelp:(id) sender;
- (IBAction) povRayDocumentationHelp:(id) sender;
- (IBAction) megaPovHelp:(id) sender;

- (IBAction) abortRender:(id) sender;
- (IBAction) pauseRender:(id) sender;
- (IBAction) sleepWhenDone:(id) sender;
- (NSInteger) shouldGoToSleepWhenDone;
- (void) resetGoToSleepWhenDone;
- (void) goToSleepAfterOneMinute;
- (void) putToSleep: (NSTimer *) aTimer;

- (IBAction)showPreviewWindow:(id)sender;
- (IBAction) showMessageWindow:(id)sender;
- (IBAction) showPreferencesWindow:(id) sender;
- (IBAction) showProgressWindow:(id) sender;

- (IBAction) batchMenu:(id)sender;
- (void) applicationDidFinishLaunching:(NSNotification *)notification;
- (NSInteger)	getNumberOfCpus;


@end 
