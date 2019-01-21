//******************************************************************************
///
/// @file /macintosh/frontEndPlatformBase/mainController.mm
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
#import	<sys/event.h>
#import	<sys/stat.h>
#import	<sys/fcntl.h>
#import	<unistd.h>
#import<pthread.h>
#import "mainController.h"
#import "appPreferencesController.h"
#import "rendererGUIBridge.h"
#import "sceneDocument+highlighting.h"
#import "CustomDocumentController.h"
#import <sys/sysctl.h>

// file systemEvents.h is generated with command:
// sdef /System/Library/CoreServices/System\ Events.app | sdp -fh --basename SystemEvents
// in terminal
#import "SystemEvents.h" // generated

// this must be the last file included
#import "syspovdebug.h"

picturePreview				*gPicturePreview=nil;
materialPreview				*gMaterialPreview=nil;
NSInteger							numericBlockPoint;
static volatile int		insertMenuIsBeingWatched=notWatching;
static MainController	*_mainController;


NSControlStateValue rememberOpenWindowsOn;
NSControlStateValue globalAutoSyntaxColoring;	// Automatically refresh syntax coloring when text is changed?
NSControlStateValue maintainIndentation;	// Keep new lines indented at same depth as their predecessor?
NSControlStateValue	autoIndentBraces;	// Keep new lines indented at same depth as their predecessor?
int	tabDistance;

// renderer control
id						activeRenderPreview=nil;
bool					gApplicationShouldTerminate = NO;
volatile bool	gUserWantsToAbortRender = NO;
volatile bool	gApplicationAlreadyReceivedStopResquest = NO;
bool					gIsRendering = NO;
bool					gIsPausing = NO;
volatile bool	gUserWantsToPauseRenderer = NO;

@implementation MainController

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	mNumberOfCpus=-1;
	self=_mainController=[super init];
	if ( self != nil)
	{
		OSErr err;
		int n, mib[2];
		size_t sz =sizeof(long);
		mib[0]=CTL_HW;
		mib[1]=HW_NCPU;
		err = sysctl (mib, 2, &n, &sz, NULL, 0);
		if ( err ==noErr)
			mNumberOfCpus=n;
	}

	return self;
}

//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (MainController*)sharedInstance
{
	return _mainController;
}

//---------------------------------------------------------------------
// POV-Ray legal
//---------------------------------------------------------------------
-(IBAction) povRayLegalHelp:(id) sender
{
 [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.povray.org/povlegal.html"]];
}

//---------------------------------------------------------------------
// POV-Ray beta
//---------------------------------------------------------------------
-(IBAction) povRayBetaHelp:(id) sender
{
 [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://wiki.povray.org/content/Main_Page"]];
}

//---------------------------------------------------------------------
// POV-Ray Docs
//---------------------------------------------------------------------
-(IBAction) povRayDocumentationHelp:(id) sender
{
 [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.povray.org/documentation/"]];
}


//---------------------------------------------------------------------
// megaPovHelp
//---------------------------------------------------------------------
-(IBAction) megaPovHelp:(id) sender
{

	NSString *path = [[NSBundle mainBundle]		pathForResource:@"macUnofficial" ofType:@"html" inDirectory:@"Documentation/Application"];
	if (path)
	{
		[[NSWorkspace sharedWorkspace] openFile:path withApplication:@"Safari"];
	}
}

//---------------------------------------------------------------------
// abortRender
//---------------------------------------------------------------------
-(IBAction) abortRender:(id) sender
{
	[[renderDispatcher sharedInstance] abortThread];
}

//---------------------------------------------------------------------
// abortRender
//---------------------------------------------------------------------
-(IBAction) pauseRender:(id) sender
{
	[[renderDispatcher sharedInstance] pauseThread];
}

//---------------------------------------------------------------------
// sleepWhenDone
//---------------------------------------------------------------------
-(IBAction) sleepWhenDone:(id) sender
{
	if ( [sender state ] == NSOnState)
		[sender setState: NSOffState];
	else
		[sender setState: NSOnState];

}

//---------------------------------------------------------------------
// goToSleepAfterOneMinute
//---------------------------------------------------------------------
- (void) goToSleepAfterOneMinute
{
	mGoToSleepAlert= [[[NSAlert alloc] init] autorelease];
	mGoToSleepInformatieveText=[mGoToSleepAlert informativeText];
	[mGoToSleepAlert addButtonWithTitle: @"Sleep"];
	[mGoToSleepAlert addButtonWithTitle: @"Cancel"];
	[mGoToSleepAlert setMessageText: @"Computer will go to sleep in 60 seconds."];
	[mGoToSleepAlert setAlertStyle: NSInformationalAlertStyle];
	mCountDownForSleep=60;
	mGoToSleepTimer = [NSTimer timerWithTimeInterval: 1 target:self
																					selector: @selector(putToSleep:)	userInfo:nil repeats:YES];

	[[NSRunLoop currentRunLoop] addTimer:mGoToSleepTimer forMode:NSModalPanelRunLoopMode];

	NSInteger choice = 0;
	choice = [mGoToSleepAlert runModal];
	[mGoToSleepTimer invalidate];
	if ( choice == NSAlertFirstButtonReturn ) // sleep
	{
		SystemEventsApplication *systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
		[systemEvents sleep];
		//		SendAppleEventToSystemProcess(kAESleep);
	}
	else
	{
		//	user pressed cancel button, do nothing
	}


}

//---------------------------------------------------------------------
// putToSleep
//---------------------------------------------------------------------
-(void) putToSleep: (NSTimer *) aTimer
{
	mCountDownForSleep--;
	[mGoToSleepAlert setMessageText: [NSString stringWithFormat:@"Computer will go to sleep in %d seconds.", mCountDownForSleep]];


	if ( mCountDownForSleep <= 0)  // time out, put computer to sleep
	{
		[mGoToSleepTimer invalidate];

		[[NSApplication sharedApplication]abortModal];
		[[mGoToSleepAlert window] close ];
		SystemEventsApplication *systemEvents = [SBApplication applicationWithBundleIdentifier:@"com.apple.systemevents"];
		[systemEvents sleep];
		//			SendAppleEventToSystemProcess(kAESleep);

	}
}


//---------------------------------------------------------------------
// shouldGoToSleepWhenDone
//---------------------------------------------------------------------
- (NSInteger) shouldGoToSleepWhenDone
{
	return [mSleepWhenDoneMenuItem state];
}

//---------------------------------------------------------------------
// resetGoToSleepWhenDone
//---------------------------------------------------------------------
- (void) resetGoToSleepWhenDone
{
	return [mSleepWhenDoneMenuItem setState:NSOffState];
}

//---------------------------------------------------------------------
// batchMenu
//---------------------------------------------------------------------
-(IBAction) batchMenu:(id)sender
{
	[[renderDispatcher sharedInstance] showBatch];
}

//---------------------------------------------------------------------
// orderFrontStandardAboutPanel
//---------------------------------------------------------------------
-(IBAction) orderFrontStandardAboutPanel:(id) sender
{
	[copyRightPanel orderFront:nil];
}

//---------------------------------------------------------------------
// showMessageWindow
//---------------------------------------------------------------------
-(IBAction) showMessageWindow:(id) sender
{
	[mMessageWindow makeKeyAndOrderFront:sender];
}

//---------------------------------------------------------------------
// showMessageWindow
//---------------------------------------------------------------------
- (IBAction)showPreviewWindow:(id)sender
{
	[mPreviewWindow makeKeyAndOrderFront:sender];
}

//---------------------------------------------------------------------
// showPreferencesWindow
//---------------------------------------------------------------------
-(IBAction) showPreferencesWindow:(id) sender
{
	[mPreferencesWindow makeKeyAndOrderFront:sender];
}

//---------------------------------------------------------------------
// showProgressWindow
//---------------------------------------------------------------------
-(IBAction) showProgressWindow:(id) sender
{
	[mProgressWindow makeKeyAndOrderFront:sender];
}

//---------------------------------------------------------------------
// previewWindowChangedName
// only called from previewwindow.mm when a new render starts
// updating of the menu entry
//---------------------------------------------------------------------
- (void) previewWindowChangedName: (NSString*) newName
{
	[mPreviewWindowMenuItem setTitle:newName];
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	SEL action = [aMenuItem action];

	//help
	if (action == @selector(megaPovHelp:))
		return YES;
	else if (action == @selector(povRayLegalHelp:))
		return YES;
	else if (action == @selector(povRayBetaHelp:))
		return YES;
	else if (action == @selector(povRayDocumentationHelp:))
		return YES;
	//preferences window

	else if ( action == @selector(showPreferencesWindow:))
	{
		if ( [mPreferencesWindow isKeyWindow]==YES)
			[aMenuItem setState:NSOnState];
		else
			[aMenuItem setState:NSOffState];
		return YES;

	}
	//progresswindow
	else if ( action == @selector(showProgressWindow:))
	{
		if ( [mProgressWindow isKeyWindow]==YES)
			[aMenuItem setState:NSOnState];
		else
			[aMenuItem setState:NSOffState];
		return YES;
	}
	//message window
	else if ( action == @selector(showMessageWindow:))
	{
		if ( [mMessageWindow isKeyWindow]==YES)
			[aMenuItem setState:NSOnState];
		else
			[aMenuItem setState:NSOffState];
		return YES;
	}
	else if ( action == @selector(showPreviewWindow:))
	{
		if ( [mPreviewWindow isKeyWindow]==YES)
			[aMenuItem setState:NSOnState];
		else
			[aMenuItem setState:NSOffState];
		return YES;
	}

	NSInteger theTag=[aMenuItem tag];
	switch (theTag)
	{
		case eTag_ShowMenu:
			return YES;
			break;
		case eTag_convertTemplate:
			return YES;
			break;

		case eTag_aboutMenu:
			return YES;
			break;
		case eTag_renderMenu:
			if ( gIsRendering==YES)
				return NO;
			else
				return YES;
			break;
		case eTag_abortMenu:
			if ( gIsRendering==YES)
				return YES;
			else
				return NO;
			break;
		case eTag_pauseMenu:
			if ( gIsRendering==YES)
			{
				if (gIsPausing)
					[aMenuItem setTitle:NSLocalizedStringFromTable(@"Continue", @"applicationLocalized", @"Continue for menu")];
				else
					[aMenuItem setTitle:NSLocalizedStringFromTable(@"Pause", @"applicationLocalized", @"Pause for menu")];
				return YES;
			}
			else
			{
				[aMenuItem setTitle:NSLocalizedStringFromTable(@"Pause", @"applicationLocalized", @"Pause for menu")];
				return NO;
			}
			break;
		case eTAb_shutDownWhenDone:
			return YES;
			break;
	}/*
		SEL action = [aMenuItem action];
		if (action == @selector(megaPovHelp:))
		return YES;
		else    	if (action == @selector(megaPovPatchesHelp:))
		return YES;
		else if ( action == @selector(showPreferencesWindow:))
		{
		NSLog(@"pppp");
		if ( [mPreferencesWindow isKeyWindow]==YES)
		[aMenuItem setState:NSOnState];
		else
		[aMenuItem setState:NSOffState];
		}
		*/
	return NO;
}

//---------------------------------------------------------------------
// applicationWillFinishLaunching
//---------------------------------------------------------------------
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
	// will create one if not already created
	[CustomDocumentController sharedInstance];
	[[NSUserDefaults standardUserDefaults]synchronize];

}

//---------------------------------------------------------------------
// applicationDidFinishLaunching
//---------------------------------------------------------------------
- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	// will create one if not already created
	renderDispatcher* dispatcher=	[renderDispatcher sharedInstance];

	// create message for about box dialog
	NSString	*messageToCopyInAboutDialog=nil;

#if __LP64__
	messageToCopyInAboutDialog=[NSString stringWithFormat:@"POV-Ray v%s (Intel 64 bit)\n",POV_RAY_VERSION];
#else
	messageToCopyInAboutDialog=[NSString stringWithFormat:@"POV-Ray v%s (Intel 32 bit)\n",POV_RAY_VERSION];
#endif 

	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",POV_RAY_COPYRIGHT];
	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",DISTRIBUTION_MESSAGE_1];
	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",DISTRIBUTION_MESSAGE_2];
	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",DISTRIBUTION_MESSAGE_3];

	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"Unofficial Version: %s | %s \n",__DATE__, __TIME__];
	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",DISCLAIMER_MESSAGE_1];
	messageToCopyInAboutDialog=[messageToCopyInAboutDialog stringByAppendingFormat:@"%s\n",DISCLAIMER_MESSAGE_2];

	[copyRightMessage setStringValue:messageToCopyInAboutDialog];

//message window
	[[MessageViewController sharedInstance] printNSString: @"---------------------------------------------------------------------------------------\n"	fromStream: WARNING_STREAM];
#if __LP64__
	[[MessageViewController sharedInstance] printNSString:@"POV-Ray Unofficial (Intel 64 bit)\n"	fromStream: WARNING_STREAM];
#else
	[[MessageViewController sharedInstance] printNSString:@"POV-Ray Unofficial (Intel 32 bit)\n"	fromStream: WARNING_STREAM];
#endif
	[[MessageViewController sharedInstance] printNSString: @"---------------------------------------------------------------------------------------\n"	fromStream: WARNING_STREAM];
	NSString *ms=[NSString stringWithFormat:@"%s\n%s\n%s\n",		POV_RAY_COPYRIGHT, DISCLAIMER_MESSAGE_1, DISCLAIMER_MESSAGE_2];
	[[MessageViewController sharedInstance] printNSString: ms fromStream:STATISTIC_STREAM];
	[[MessageViewController sharedInstance] printNSString: @"---------------------------------------------------------------------------------------\n"	fromStream: WARNING_STREAM];


	try
	{
		[dispatcher CreateFrontend:YES];
	}
	catch (pov_base::Exception& e)
	{
		messageToCopyInAboutDialog=[NSString stringWithFormat:@"Failed to initialize frontend: %s\nPOV-Ray Critical Error\n",e.what()];
		[[MessageViewController sharedInstance] printNSString: messageToCopyInAboutDialog fromStream:FATAL_STREAM];
		vfe::gVfeSession=NULL;
	}
	[[MessageViewController sharedInstance] setNeedsUpdate];


	//put application in multithreaded mode
	[NSThread detachNewThreadSelector:  @selector(putInMultiThreadedMode:)  toTarget: self withObject:self];


	//remove message window from the window menu
	//it has a separate entry in the menu
	[mMessageWindow setExcludedFromWindowsMenu:YES];
	[[NSApplication sharedApplication]removeWindowsItem:mMessageWindow];

	[mPreviewWindow setExcludedFromWindowsMenu:YES];
	[[NSApplication sharedApplication]removeWindowsItem:mPreviewWindow];

	[mPreferencesWindow setExcludedFromWindowsMenu:YES];
	[[NSApplication sharedApplication]removeWindowsItem:mPreferencesWindow];

	[mProgressWindow setExcludedFromWindowsMenu:YES];
	[[NSApplication sharedApplication]removeWindowsItem:mProgressWindow];

	//build the template menu
	[self buildTemplateInsertMenu];

	// reopen files open when application was quit
	id obj=[userDefaults objectForKey:@"rememberOpenWindowsOn"];
	if ( obj != nil)
	{
		if ( [obj intValue] == NSOnState)
		{
			NSMutableArray *openDocuments=[userDefaults objectForKey:@"OpenDocuments"];
			if ( openDocuments != nil && [ openDocuments count])
			{
				for (int x= 1; x<=[openDocuments count]; x++)
				{
					NSArray *documentArray=[openDocuments objectAtIndex:x-1];
					SceneDocument *document=[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:[documentArray objectAtIndex:1]] display:YES error:nil];
					[[document window] setFrameFromString:[documentArray objectAtIndex:0]];
					NSRange range=NSRangeFromString([documentArray objectAtIndex:2]);
					if(range.location > [[[document getSceneTextView]textStorage]length])
						range.location=0;
					[[document getSceneTextView] setSelectedRange:range];
					[[document getSceneTextView] scrollRangeToVisible:range];
					[document showWindows];
				}
			}
		}
	}
}

//---------------------------------------------------------------------
// applicationWillBecomeActive
//---------------------------------------------------------------------
- (void)applicationWillBecomeActive:(NSNotification *)aNotification
{

}

//---------------------------------------------------------------------
// putInMultiThreadedMode
//	just to put the application in mulithreaded mode
//---------------------------------------------------------------------
-(void) putInMultiThreadedMode:(id) anobject
{
	return;
}

//---------------------------------------------------------------------
// applicationWillTerminate
//	lets save some settings before the application quits
//---------------------------------------------------------------------

- (void)applicationWillTerminate:(NSNotification *)notification
{

	[[renderDispatcher sharedInstance] batchSaveDefaults]; // save the contents of the batch

	[SceneDocument releaseCharacterSets];	//clean up the scenedocument class
	[SceneDocument releaseKeywords];

	NSFileManager *fm=[NSFileManager defaultManager];
	NSURL *materialFileURL =[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"material.pov"]];
	[fm removeItemAtURL:materialFileURL error:nil];

	[self stopWatchingInsertMenu];

	if ( vfe::gVfeSession != NULL)
	{
		vfe::gVfeSession->Shutdown();
		delete vfe::gVfeSession;
		vfe::gVfeSession=NULL;
	}
}

//---------------------------------------------------------------------
// applicationWillTerminate
//	lets save some settings before the application quits
//---------------------------------------------------------------------
- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
	NSBundle *main=[NSBundle mainBundle];
	if ( main == nil)
		return NSTerminateNow;

	if ( gIsRendering ==YES)
	{
		NSInteger res=NSRunAlertPanel( NSLocalizedStringFromTable(@"RenderInProgress", @"applicationLocalized", @"Rendering in progress..."),
														NSLocalizedStringFromTable(@"ReallyQuit", @"applicationLocalized", @"A file is being rendered. Do you really want to quit?"),
														NSLocalizedStringFromTable(@"Cancel", @"applicationLocalized", @"Cancel"),
														NSLocalizedStringFromTable(@"Quit", @"applicationLocalized", @"Quit"),
														nil);
		if ( res == NSAlertDefaultReturn) //cancel
			return NSTerminateCancel;
		else
		{
			// quitting will be done in renderDispatcher in setRendering
			if([[renderDispatcher sharedInstance]batchIsRunning]==YES)
				[[renderDispatcher sharedInstance]setBatchIsRunning:ABORT];
			gApplicationShouldTerminate = YES;
			gUserWantsToAbortRender = YES;
			return NSTerminateCancel;
		}
	}

	return NSTerminateNow;
}

//---------------------------------------------------------------------
// templateMainInsertMenu
//---------------------------------------------------------------------
-(menuFromDirectory*)templateMainInsertMenu;
{
	return mMainTemplateInsertMenu;
}

//---------------------------------------------------------------------
// setMenuFromDirectory
//---------------------------------------------------------------------
- (void) setMenuFromDirectory: (menuFromDirectory*) menu;
{
	[mMainTemplateInsertMenu release];
	mMainTemplateInsertMenu=menu;
	[mMainTemplateInsertMenu retain];
}


//---------------------------------------------------------------------
// buildTemplateInsertMenu
//---------------------------------------------------------------------
-(void)buildTemplateInsertMenu
{

	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSString *mainInsertPath=[defaults objectForKey:@"mInsertMenuMainDirectoryEdit"];
	if ( mainInsertPath==nil || [mainInsertPath length]==0)
		return;

	float scaleFactor=[[appPreferencesController sharedInstance]scaleFactor];

	// create a new item to add the new insert menu on
	// will be added to the manubar later
	NSMenuItem		*tempItem=[[[NSMenuItem alloc]initWithTitle:@"Insert" action:@selector(insertMenu:) keyEquivalent:@""]autorelease];
	if ( tempItem == nil)
		return;

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSMenu *m=[[[NSMenu alloc]initWithTitle:@"Insert"]autorelease];
	[tempItem setSubmenu:m];
	// build the new insert menu
	[self setMenuFromDirectory:[menuFromDirectory fromDirectory:mainInsertPath
																							 withExtensions:[NSArray arrayWithObjects: @"txt",nil]
																							forMainMenuItem:tempItem
																									scaleFactor:scaleFactor action:@selector(insertMenu:)]];


	NSInteger indexForInsertMenuItem=[mMainMenu indexOfItem:mTemplateMenuItem];
	[mMainMenu insertItem:tempItem atIndex:indexForInsertMenuItem ];
	[pool release] ;

	//return;

	//fixme************************************************fixme
	// create an array with only directories
	// to watch for changes
	NSMutableArray *dirAr=[[[NSMutableArray alloc]init]autorelease];
	[dirAr addObject:[[[[self templateMainInsertMenu] path]copy]autorelease]];

	[[ self templateMainInsertMenu] directories:dirAr];
	[NSThread detachNewThreadSelector:  @selector(watchInsertDirectories:)  toTarget: self
												 withObject:dirAr];
}

//---------------------------------------------------------------------
// watchInsertDirectories
//	If any of the folders of our insert menu changes,
// rebuild it
// launched from a trhead, lives until one of the directories changes
// then the menu is rebuild and the thread is aborted
// and a new one is created to watch again,....
//---------------------------------------------------------------------

-(void) watchInsertDirectories:(id) anobject
{
	insertMenuIsBeingWatched=watching;
	NSMutableArray *dirAr=(NSMutableArray*)anobject;
	NSAutoreleasePool *pool;
	int				i;
	int				kq;
	//int				ev_count;
	struct kevent	ev_change[[dirAr count]];
	int				fd[[dirAr count]];
	int				foldersToWatch					= 0;
	struct kevent	*ev_receive;
	ev_receive=new struct kevent[[dirAr count]]; //	= { { 0 } };
	u_int			vnode_events					= NOTE_DELETE |  NOTE_WRITE | NOTE_EXTEND |			//  Events we are interested in watching
	NOTE_ATTRIB | NOTE_LINK | NOTE_RENAME | NOTE_REVOKE;
	if ( (kq = kqueue()) < 0 )
		goto Bail;
	pool = [[NSAutoreleasePool alloc] init];
	for (  foldersToWatch = 0 ; foldersToWatch < [dirAr count] ; foldersToWatch++ )
	{
		//  Currently the O_EVTONLY is designed so that to keep a dir file descriptor open without stopping users from unmounting the disk.  HFS+ only on 10.3
		//  Open a descriptor for each directory we are watching
		fd[foldersToWatch]	= open( [[dirAr objectAtIndex:foldersToWatch]UTF8String], O_EVTONLY );
		if ( fd[foldersToWatch] <= 0 )
			break;	//  If we get any errors, just break and continue with what we have
		EV_SET( &ev_change[foldersToWatch], fd[foldersToWatch], EVFILT_VNODE, EV_ADD | EV_CLEAR|EV_ENABLE | EV_ONESHOT, vnode_events, 0,0); // &(mpTaskInfo->mpControlInfo[foldersToWatch]) );
	}
	[pool release];

	/*ev_count	=*/kevent( kq, ev_change, foldersToWatch, ev_receive, [dirAr count], NULL );

Bail:
	//NSLog(@"bailing");
	//  Clean up and close any open file descriptors
	for ( i = 0 ; i < foldersToWatch ; i++ )
		(void) close( fd[i] );
	if ( insertMenuIsBeingWatched != aborting) // we are aborting and should not watch again
	{
		insertMenuIsBeingWatched=notWatching;
		[self performSelectorOnMainThread:@selector(reloadTemplateInsertMenu)withObject: nil waitUntilDone:NO];
	}
	delete []ev_receive;
	return;
}

//---------------------------------------------------------------------
// reloadTemplateInsertMenu
//---------------------------------------------------------------------
-(void) reloadTemplateInsertMenu
{

	if ( insertMenuIsBeingWatched == watching)
		[self stopWatchingInsertMenu];

	// if the insert menu exists, remove it
	// and recursively remove all submenu's and menuitems

	NSInteger indexForInsertMenuItem=[mMainMenu indexOfItemWithTitle:@"Insert"];
	if ( indexForInsertMenuItem != -1)
	{
		[mMainMenu removeItemAtIndex:indexForInsertMenuItem];
	}
	[self setMenuFromDirectory:nil];
	[self buildTemplateInsertMenu];
}

//---------------------------------------------------------------------
// stopWatchingInsertMenu
//---------------------------------------------------------------------
-(void) stopWatchingInsertMenu
{

	if ( insertMenuIsBeingWatched == notWatching)
		return;

	if ( [self templateMainInsertMenu] ==nil)
		return;
	NSURL *tempUrl=[NSURL fileURLWithPath:[[[self templateMainInsertMenu]path]stringByAppendingString:@"x_mp_temp012"] isDirectory:NO];
	if ( tempUrl != nil)
	{
		insertMenuIsBeingWatched=aborting;
		NSFileManager *fm=[NSFileManager defaultManager];
		if ([fm createFileAtPath:[tempUrl path] contents:nil  attributes:nil] ==YES)
			[fm removeItemAtURL:tempUrl error:nil];
	}
	//insertMenuIsBeingWatched=notWatching;
}

//---------------------------------------------------------------------
// getNumberOfCpus
//---------------------------------------------------------------------
@synthesize getNumberOfCpus=mNumberOfCpus;


@end
