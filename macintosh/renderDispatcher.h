//******************************************************************************
///
/// @file /macintosh/renderDispatcher.h
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
#import <pthread.h>
#import "sceneDocument.h"
#import "batchMap.h"
#define ABORT 2
#define SKIPPING		3

void *doRender (void * theObject);

@interface renderDispatcher : NSObject
{
	// batch
	BatchMap								*mBatchMap;
  IBOutlet NSTableView 		*mTableView;
  IBOutlet NSButton 			*mRunButton;
  IBOutlet NSButton 			*mRunAllButton;
  IBOutlet NSButton 			*mAbortButton;
  IBOutlet NSButton 			*mInsertButton;
  IBOutlet NSButton 			*mAddButton;
  IBOutlet NSButton 			*mTrashButton;
  IBOutlet NSButton 			*mResetButton;
  IBOutlet NSButton 			*mResetAllButton;
  IBOutlet NSButton 			*mSkipButton;
    
  IBOutlet NSPopUpButton 	*mSettingsPopupButton;
  IBOutlet NSTableColumn	*mOnOffColumn;
  IBOutlet NSTableColumn	*mNameColumn;
  IBOutlet NSTableColumn	*mSettingsColumn;
  IBOutlet NSTableColumn	*mStatusColumn;
  IBOutlet NSWindow				*mBatchWindow;
    
  NSUInteger 			mDraggedRow;
	NSTableColumn		*mLastTableColumn;
	BOOL 						mSorteerOplopend;
	//render dispatcher
	
	NSString 	*inputFileNoPathNoExtension;
	NSString 	*inputFileNameNoPathWithExtension;
	NSString 	*inputFilePathWithSlash;
	NSString 	*outputFilePathWithSlash;
	NSString 	*outputFileNameNoPathNoExtension;
	NSString	*outputFileWithPathAndDot;
	NSString 	*extensionToAddIfNoneWasProvided;
	NSMutableDictionary *mPostedDictionary;
	volatile BOOL mRendering;
	volatile BOOL mPreparingToRender;
	char 	**Argv;
	int 	Argc;
	int 	availableArgc;
	id 		mPostingObject;
	pthread_t mThreadID;
	pthread_attr_t mThreadAttr;
	int 			mBatchIsRunning;
	bool 			mSessionResult;
	NSThread 	*mSessionThread;
	NSTimer 	*mRunloopTimer;
}

+ (renderDispatcher*)sharedInstance;
-(void) CreateFrontend:(BOOL) printMessages;

//batch
-(id) batchMap;
-(void) showBatch;
- (IBAction) batchTarget:(id)sender;
-(void) batchRun:(BOOL) onlySelected;
-(void)batchSetAllProcessingToCancelled;
-(void) batchSetDefaultSettingsForState:(int) newState atEntry:(NSInteger)entry;
-(void) batchRunNextEntry;
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem;
-(IBAction)batchMenu:(id)sender;
-(void) batchRemove:(BOOL)all refresh:(BOOL)refresh;
-(void) batchApplySettingsPopup:(id)sender;
-(void) batchAddFiles:(BOOL)insert;
-(void) batchSort;

-(void) batchSetAllEntriesTo:(int)newState onlySelected:(BOOL)onlySelected onlyIfOn:(BOOL)onlyIfOn refresh:(BOOL) refresh;
-(void) batchSetState:(int) oldState toState:(int)newState onlyIfOn:(BOOL)onlyIfOn refresh:(BOOL)refresh;

-(void) setButtons;
-(NSTableView*) tableView;
-(BOOL) batchIsRunning;
-(void) setBatchIsRunning:(int)newState;
-(void) batchSaveDefaults;
-(void) setMap:(id)map;
//render dispatcher

-(id) init;

 -(void) buildSettingsPopup;

//notifications
-(void) renderDocument:(NSNotification *) notification;
-(NSMutableDictionary*) postedDictionary;
-(void) setPostedDictionary: (NSMutableDictionary*) dict;

// state
-(BOOL) preparingToRender;
-(void) setPreparingToRender: (BOOL) flag;
-(BOOL) rendering;
-(void) notifyVfeSessionStoppedRendering;
-(void) setRendering: (BOOL) flag;
-(void) setNotRendering;
-(void) setIsRendering;
-(BOOL) canStartNewRender;
-(BOOL) canPauseRender;
-(BOOL) canAbortRender;
-(void) pauseThread;
-(void) abortThread;
- (void) keepSavingUntillAllFilesAreSaved:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void*)contextInfo;

-(void) addCommand: (const char*)command withString: (NSString*)string;
-(void) run;
-(void) runMaterial;
-(void) createAndStartThread;
-(NSString*) stringByAddingQuotationmarks:(NSString *) str;

-(void) releaseArgv;

//setters
-(NSString *) setInputFileNoPathNoExtension: (NSString*)fileName;
-(NSString *) setInputFileNameNoPathWithExtension: (NSString*)fileName;
-(NSString *) setInputFilePathWithSlash: (NSString*)path;
-(NSString *) setOutputFilePathWithSlash: (NSString*)path;
-(NSString *) setOutputFileNameNoPathNoExtension: (NSString*)fileName;
-(NSString *) buildOutputFileWithPathAndDot;
-(NSString *) setExtensionToAddIfNoneWasProvided: (NSString*)extension;

//getters
-(NSString *) inputFileNoPathNoExtension;
-(NSString *) inputFileNameNoPathWithExtension;
-(NSString *) inputFilePathWithSlash;
-(NSString *) outputFilePathWithSlash;
-(NSString *) outputFileNameNoPathNoExtension;
-(NSString *) outputFileWithPathAndDot;
-(NSString *) extensionToAddIfNoneWasProvided;
-(int) Argc;
-(char**)Argv;
@end
