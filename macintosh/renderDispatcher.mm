//******************************************************************************
///
/// @file /macintosh/renderDispatcher.mm
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


#import "MainController.h"
#import "macintoshDisplay.h"
#import "PreferencesPanelController.h"
#import "appPreferencesController.h"
#import "baseTemplate.h"
#import "MaterialTemplate.h"
#import "rendererGUIBridge.h"
#import "renderDispatcher.h"
#import "vfesession.h"

// this must be the last file included
#import "syspovdebug.h"

BOOL gOnlyDisplayPart=NO;
BOOL gDontErasePreveiw=NO;
static NSInteger compareBatchEntryUsingSelector(id p1, id p2, void *context);

struct sortStruct {
	int type;
	int sort;
};
static sortStruct sortstruct;
using namespace vfe;



static renderDispatcher* _renderDispatcher;

@implementation renderDispatcher

//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (renderDispatcher*)sharedInstance
{
	if ( _renderDispatcher ==nil)
		[[self alloc]init];
	return _renderDispatcher;
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self=_renderDispatcher=[super init];
	if ( self)
	{
		[self setBatchIsRunning:NO];
		[self setPostedDictionary:nil];
		[self setMap:[[[BatchMap alloc]init]autorelease]];
		[mBatchMap mapBaseSetTemplate:self];
		availableArgc=120;
		Argc=0;
		Argv=nil;
		if ([NSBundle loadNibNamed:@"batch.nib" owner:self] == YES)
		{
		}
		else
		{
		}

	}

	return self;
}

//---------------------------------------------------------------------
// CreateFrontend
//---------------------------------------------------------------------
-(void) CreateFrontend: (BOOL)printMessages
{
 vfe::vfeStatusFlags    flags;
 if (gVfeSession != NULL)
	 throw POV_EXCEPTION_STRING ("Session already open");
	try
	{
		gVfeSession = new vfeMacSession();
	}
	catch(vfeException& e)
	{
		throw POV_EXCEPTION_STRING (e.what());
	}
	if (gVfeSession == NULL)
		throw POV_EXCEPTION_STRING ("Failed to create session");
	gVfeSession->OptimizeForConsoleOutput(false);
	if (gVfeSession->Initialize(NULL, NULL) != vfeNoError)
	{
		gVfeSession->Shutdown();
		string str = gVfeSession->GetErrorString();
		delete gVfeSession;
		gVfeSession = NULL;
		throw POV_EXCEPTION_STRING (str.c_str());
	}
	gVfeSession->SetDisplayCreator(macintoshDisplayCreator);
	if ( printMessages==YES)
	{
		while ((flags = (gVfeSession->GetStatus(true, 0))))
		{
			ProcessSession(flags);
		}
	}
	else
		gVfeSession->Reset();
}

//---------------------------------------------------------------------
// batchMap
//---------------------------------------------------------------------
-(id) batchMap
{
	return mBatchMap;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
- (void) dealloc
{
	//[self batchSaveDefaults]; // moved to applicationWillTerminate()

	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[self releaseArgv];
	[self setPostedDictionary:nil];
	[inputFileNoPathNoExtension release];
	[outputFileNameNoPathNoExtension release];
	[inputFilePathWithSlash release];
	[outputFilePathWithSlash release];
	[inputFileNameNoPathWithExtension release];
	[extensionToAddIfNoneWasProvided release];
	[outputFileWithPathAndDot release];
	[mBatchMap release];
	_renderDispatcher=nil;
	[super dealloc];
}

//---------------------------------------------------------------------
// setMap:map
//---------------------------------------------------------------------
-(void) setMap:(id)map
{
	[mBatchMap release];
	mBatchMap=map;
	[mBatchMap retain];
	[mBatchMap mapBaseSetTemplate:self];
	[mTableView reloadData];
}
//---------------------------------------------------------------------
// tableView
//---------------------------------------------------------------------
-(NSTableView*) tableView
{
	return mTableView;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	// we need to know when a document needs rendering
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderDocument:)
		name:@"renderDocument"
		object:nil];

	// we need to know when a rendering settings are added or removed
	// for the batch
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(buildSettingsPopup)
		name:@"renderingSettingsChaged"
		object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"renderState"
		object:nil];

	[mSettingsPopupButton setAutoenablesItems:NO];


	// setup the NSButtonCell to place inside the table view
	id checkboxCell;
	checkboxCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
	[checkboxCell setEditable: YES];
	[checkboxCell setButtonType: NSSwitchButton];
	[checkboxCell setImagePosition: NSImageOnly];
	[checkboxCell setControlSize: NSSmallControlSize];

	// actually place the button cell on the table view
	[mOnOffColumn setDataCell: checkboxCell];

	[self buildSettingsPopup];
	// register for drag action, using the drag type we defined
	[mTableView registerForDraggedTypes: [NSArray arrayWithObjects: NSFilenamesPboardType,BatchItemDragType, nil]];

	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

	id anObject=[defaults objectForKey:@"defaultBatch"];
	if (anObject != nil)
	{
		id map=[NSUnarchiver unarchiveObjectWithData: [anObject objectForKey:@"batchMap"]];
		if ( map)
		{
			[self setMap:map];
		}
	}
	[mTableView setAutosaveTableColumns:YES];
	anObject=[defaults objectForKey:@"selectedColumn"];
	if ( anObject != nil)
	{
		mSorteerOplopend=	[[defaults objectForKey:@"sortMethod"]intValue];

		mLastTableColumn=[mTableView tableColumnWithIdentifier:anObject];
		if ( mLastTableColumn != nil)
		{
			[mLastTableColumn retain];
			[mTableView setHighlightedTableColumn:mLastTableColumn];
			[self batchSort];
			[mTableView setIndicatorImage: (mSorteerOplopend ?
																			[NSImage imageNamed:@"NSDescendingSortIndicator"] :
																			[NSImage imageNamed:@"NSAscendingSortIndicator"])
											inTableColumn: mLastTableColumn];
		}
	}
	// if batchwindow was visibl, show it at launch
	anObject=[defaults objectForKey:@"batchwindowIsVisible"];
	if ( anObject != nil && [anObject boolValue]== YES)
		[self showBatch];



	[self setButtons];
	[ToolTipAutomator setTooltips:@"batchLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			mRunButton,						@"mRunButton",
			mRunAllButton,				@"mRunAllButton",
			mAbortButton,					@"mAbortButton",
			mInsertButton,				@"mInsertButton",
			mAddButton,						@"mAddButton",
			mResetButton,					@"mResetButton",
			mResetAllButton,			@"mResetAllButton",
			mTrashButton,					@"mTrashButton",
			mSkipButton,					@"mSkipButton",
			mSettingsPopupButton,	@"mSettingsPopupButton",
			mTableView,						@"mTableView",

		 nil]
		];

}
//---------------------------------------------------------------------
// buildSettingsPopup
//---------------------------------------------------------------------
-(void) buildSettingsPopup
{
	[mSettingsPopupButton removeAllItems];

	NSMenu *theMenu=[mSettingsPopupButton menu];

	[theMenu addItemWithTitle:@"Current Default" action:nil keyEquivalent:@""];		//title


	[theMenu addItem:[NSMenuItem separatorItem]];

	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	NSArray *appArray=[defaults arrayForKey:@"mainPrefsArray"];


	for (int index=0; index <[appArray count]; index++)
	{
		NSMutableDictionary *dict=[appArray objectAtIndex:index];
		NSString *dictName=[dict objectForKey:@"dictionaryName"];
		[mSettingsPopupButton addItemWithTitle: dictName];
	}

}

//---------------------------------------------------------------------
// batchSort
//---------------------------------------------------------------------
-(void) batchSort
{
	if ( mLastTableColumn!= nil)
	{
		if ( [[mLastTableColumn identifier] isEqualToString:@"onoff"])
			sortstruct.type=cOnOffIndex;
		else if ( [[mLastTableColumn identifier] isEqualToString:@"name"])
			sortstruct.type=cNameIndex;
		else if ( [[mLastTableColumn identifier] isEqualToString:@"status"])
			sortstruct.type=cStatusIndex;
		else if ( [[mLastTableColumn identifier] isEqualToString:@"comment"])
			sortstruct.type=cCommentIndex;
		sortstruct.sort=mSorteerOplopend;
		[ [mBatchMap array] sortUsingFunction:compareBatchEntryUsingSelector context:&sortstruct];
	}
}

//---------------------------------------------------------------------
// batchRun
//---------------------------------------------------------------------
-(void) batchRun:(BOOL) onlySelected
{
	if ( [self batchIsRunning]==NO)
	{
		[self batchSetAllEntriesTo:cProcessing onlySelected:onlySelected onlyIfOn:YES refresh:YES];
		[self batchRunNextEntry];
	}
	else
		[self batchSetAllEntriesTo:cProcessing onlySelected:onlySelected onlyIfOn:YES refresh:YES];

}

//---------------------------------------------------------------------
// canEntryBeRemoved
//---------------------------------------------------------------------
-(BOOL) canEntryBeRemoved:(NSInteger)entry
{
	BOOL ret=YES;
	if ( [mBatchMap intAtRow:entry atColumn:cStatusIndex]==cRendering)
	{
		ret=NO;	// file is being rendered
		if ([self rendering]==NO )	//should not happen but is possible
			ret=YES;							//in this case we allow to make changes
	}
	return ret;
}
//---------------------------------------------------------------------
// batchRemove:refresh
//---------------------------------------------------------------------
-(void) batchRemove:(BOOL)all refresh:(BOOL)refresh
{
	if ( all ==YES)
	{
		for (int x=1; x<=[mBatchMap count]; x++)
		{
			if ( [self  canEntryBeRemoved:x-1]==YES)
				[mBatchMap removeEntryAtIndex:x-1 reload:YES];
		}
	}
	else
	{
		NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
		NSUInteger current;
		current=[selectedRows lastIndex];
		while (current != NSNotFound)
		{
			if ( [self  canEntryBeRemoved:current]==YES)
				[mBatchMap removeEntryAtIndex:current reload:YES];
			current=[selectedRows indexLessThanIndex:current];
		};
	}
	if ( refresh==YES)
	{
		[mTableView deselectAll:nil];
	}
}

//---------------------------------------------------------------------
// batchSetDefaultSettingsForState:atEntry
//---------------------------------------------------------------------
-(void) batchSetDefaultSettingsForState:(int) newState atEntry:(NSInteger)entry
{
	id obj=nil;
	// if setting from panel is choosen,
	// grab the current settings to be used when the entry is rendered
	if ( newState==cProcessing )
	{
		obj= [[mBatchMap objectAtRow:entry atColumn:cSettingsIndex] objectForKey:@"dictionaryName"];
		if ( [obj isEqualToString:dLastValuesInPanel])
			[mBatchMap setObject:[[PreferencesPanelController sharedInstance] getDictWithCurrentSettings:NO] atRow:entry atColumn:cSettingsIndex];
	}

}

//---------------------------------------------------------------------
// setAllSelectedBatchEntriesTo:onlyIfOn
//---------------------------------------------------------------------
-(void) batchSetAllEntriesTo:(int)newState onlySelected:(BOOL)onlySelected onlyIfOn:(BOOL)onlyIfOn refresh:(BOOL) refresh
{
	if ( onlySelected == NO)
	{
		for (int x=1; x<=[mBatchMap count]; x++)
		{
			if ( onlyIfOn)
			{
				if ( [mBatchMap intAtRow:x-1 atColumn:cOnOffIndex]==NSOnState)
				{
					// don't change if rendering is going on
					if ( [self  canEntryBeRemoved:x-1]==YES)
					{
						[mBatchMap setInt:newState atRow:x-1 atColumn:cStatusIndex];
						[self batchSetDefaultSettingsForState:newState atEntry:x-1];
					}
				}
			}
			// don't change if rendering is going on
			else if ( [self  canEntryBeRemoved:x-1]==YES)
			{
				[mBatchMap setInt:newState atRow:x-1 atColumn:cStatusIndex];
				[self batchSetDefaultSettingsForState:newState atEntry:x-1];
			}
		}
	}
	else
	{
		NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
		NSUInteger current=[selectedRows firstIndex];

		while (current != NSNotFound)
		{
			if ( onlyIfOn)
			{
				if ( [mBatchMap intAtRow:current atColumn:cOnOffIndex]==NSOnState)
				{
					// don't change if rendering is going on
					if ( [self  canEntryBeRemoved:current]==YES)
					{
						[mBatchMap setInt:newState atRow:current atColumn:cStatusIndex];
						[self batchSetDefaultSettingsForState:newState atEntry:current];
					}
				}
			}
			else if ( [self  canEntryBeRemoved:current]==YES)
			{
				[mBatchMap setInt:newState atRow:current atColumn:cStatusIndex];
				[self batchSetDefaultSettingsForState:newState atEntry:current];
			}
			current=[selectedRows indexGreaterThanIndex:current];
		}
	}
	if ( refresh==YES)
		[mTableView reloadData];
}

//---------------------------------------------------------------------
// batchSetAllProcessingToCancelled
//---------------------------------------------------------------------
// in case of abort, mark all entries ready to render as cancelled
//---------------------------------------------------------------------
-(void)batchSetAllProcessingToCancelled
{
	for (int x=1; x<=[mBatchMap count]; x++)
	{
		if ( [mBatchMap intAtRow:x-1 atColumn:cOnOffIndex]==NSOnState)
		{
			if ( [mBatchMap intAtRow:x-1 atColumn:cStatusIndex]==cProcessing)
			{
				[mBatchMap setInt:cCancelled atRow:x-1 atColumn:cStatusIndex];
			}
		}
	}
	[mTableView reloadData];

}

//---------------------------------------------------------------------
// showBatch
//---------------------------------------------------------------------
-(void) showBatch
{
	[mBatchWindow makeKeyAndOrderFront:nil];
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
// called from maincontroller
// should only handle menus specific to
// the batch
//---------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
	NSIndexSet *selectedRowsSet=[mTableView selectedRowIndexes];
	NSInteger numberOfSelectedRows=[selectedRowsSet count];
	switch ([aMenuItem tag])
	{
		case eTag_ShowMenu:		return YES; break;
		case eTag_AddMenu:			return YES;	break;

		case eTag_InsertMenu:
			if (numberOfSelectedRows==1)
				return YES;
			return NO;
			break;

		case eTag_RemoveMenu:
		case eTag_ResetSelectedMenu:
			if (numberOfSelectedRows)
				return YES;
			return NO;
			break;

		case eTag_ResetAllMenu:	return YES; break;

		case eTag_RunAllMenu:		return YES; break;

		case eTag_RunSelectedMenu:
			if (numberOfSelectedRows)
				return YES;
			return NO;
			break;

		case eTag_AbortMenu:
			if ( [self batchIsRunning] ==YES)
				return YES;
			return NO;
			break;
	}
	return NO;
}

//---------------------------------------------------------------------
// batchMenu:sender
//---------------------------------------------------------------------
-(IBAction)batchMenu:(id)sender
{
	//	NSIndexSet *selectedRowsSet=[mTableView selectedRowIndexes];
	//	int numberOfSelectedRows=[selectedRowsSet count];
	switch ([sender tag])
	{
		case eTag_ResetAllMenu:
			[self batchSetAllEntriesTo:cQueue onlySelected:NO onlyIfOn:YES refresh:YES];
			break;
		case eTag_ResetSelectedMenu:
			[self batchSetAllEntriesTo:cQueue onlySelected:YES onlyIfOn:YES refresh:YES];
			break;
		case eTag_RunAllMenu:
			[self batchRun:NO];
			break;
		case eTag_RunSelectedMenu:
			[self batchRun:YES];
			break;
		case eTag_RemoveMenu:
			[self batchRemove:NO refresh:YES];
			break;
		case eTag_AbortMenu:
			if ( gIsPausing==YES)	// go out of pause before aborting
				[self pauseThread];
			gUserWantsToAbortRender = YES;	// this will cause the renderer to stop
			[self setBatchIsRunning:ABORT];
			break;
		case eTag_AddMenu:
			[self batchAddFiles:NO];
			break;
		case eTag_InsertMenu:
			[self batchAddFiles:YES];
			break;
	}

}

//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{

	if ( [self batchIsRunning]==NO)
		return;

	NSNumber *number=[[notification userInfo] objectForKey: @"renderStarted"];
	if ( number)
	{
		if ( [number boolValue] == YES)
		{
		}
		else
		{
			id dict=[self postedDictionary];
			if ( dict != nil)
			{
				NSString *fileRendered=[dict objectForKey:@"fileName"];
				int result=[[dict objectForKey:@"renderResult"]intValue];
				for (int x=1; x<=[mBatchMap count]; x++)
				{
					NSString *batchFile=[mBatchMap objectAtRow:x-1 atColumn:cNameIndex];
					if ( [batchFile isEqualToString:fileRendered])
					{
						switch(result)
						{
							case 2:
								if ( [self batchIsRunning] != ABORT && [self batchIsRunning] != SKIPPING)
									[self setBatchIsRunning:ABORT];	// abort from menu or preview means abort all

								[mBatchMap setInt:cUserAbort atRow:x-1 atColumn:cStatusIndex];
								dict=[mBatchMap objectAtRow:x-1 atColumn:cSettingsIndex];
								if ( dict != nil)
								{
									NSMutableDictionary *dictCont=[[dict mutableCopy]autorelease];
									if ( dictCont != nil)
									{
										[dictCont setObject:[NSNumber numberWithInt:NSOnState] forKey:@"continueRendering"];
										[mBatchMap setObject:dictCont atRow:x-1 atColumn:cSettingsIndex];
									}
								}
								[self batchSetState:cProcessing toState:cCancelled onlyIfOn:YES refresh:YES];
								break;
							case 1:
								[mBatchMap setInt:cRenderError atRow:x-1 atColumn:cStatusIndex];
								break;
							case 0:
								[mBatchMap setInt:cDone atRow:x-1 atColumn:cStatusIndex];
								[mBatchMap setInt:NSOffState atRow:x-1 atColumn:cOnOffIndex];
								break;
						}
						[mTableView reloadData];
						break;
					}
				}
			}
			if ( [self batchIsRunning]==ABORT)
			{
				[self batchSetAllProcessingToCancelled];
				[self setBatchIsRunning:NO];
				[self setButtons];
				return;
			}
			[self batchRunNextEntry];
		}

	}
}

//---------------------------------------------------------------------
// batchSetState; toState: onlyIfOn: refresh
//---------------------------------------------------------------------
-(void) batchSetState:(int) oldState toState:(int)newState onlyIfOn:(BOOL)onlyIfOn refresh:(BOOL)refresh
{
	NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
	NSUInteger current=[selectedRows firstIndex];

	while (current != NSNotFound)
	{
		if ( onlyIfOn)
		{
			if ( [mBatchMap intAtRow:current atColumn:cOnOffIndex]==NSOnState)
			{
				if ( [mBatchMap intAtRow:current atColumn:cStatusIndex]==oldState)
					[mBatchMap setInt:newState atRow:current atColumn:cStatusIndex];
			}
		}
		else
		{
			if ( [mBatchMap intAtRow:current atColumn:cStatusIndex]==oldState)
			{
				[mBatchMap setInt:newState atRow:current atColumn:cStatusIndex];
			}
		}
		current=[selectedRows indexGreaterThanIndex:current];
	}

	if ( refresh==YES)
		[mTableView reloadData];

}

//---------------------------------------------------------------------
// batchRunNextEntry
//---------------------------------------------------------------------
-(void) batchRunNextEntry
{
	for (int x=1; x<=[mBatchMap count]; x++)
	{
		if ( [mBatchMap intAtRow:x-1 atColumn:cOnOffIndex]==NSOnState)
		{
			if ( [mBatchMap intAtRow:x-1 atColumn:cStatusIndex]==cProcessing)
			{
				[mBatchMap setInt:cRendering atRow:x-1 atColumn:cStatusIndex];
				[mTableView reloadData];

				NSMutableDictionary *currentSettings=[[[mBatchMap objectAtRow:x-1 atColumn:cSettingsIndex]mutableCopy]autorelease];
				if ( currentSettings)	//make sure we have usable settings to render the file
				{
					NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
															[NSNumber numberWithBool:YES] ,	@"shouldStartRendering",
															[mBatchMap objectAtRow:x-1 atColumn:cNameIndex], 				@"fileName",
															currentSettings,								@"rendersettings",
															[NSDate date],								@"dateOfPosting",
															[NSNumber numberWithBool:YES],	@"isBatchRender",
															nil];
					[self setBatchIsRunning:YES];
					[self setButtons];
					[[NSNotificationCenter defaultCenter]
						postNotificationName:@"renderDocument"
						object:self
						userInfo:dict];
					return;
				}
				else
				{
					[mBatchMap setInt:cBatchError atRow:x-1 atColumn:cStatusIndex];
					[mTableView reloadData];
				}
			}
		}
	}
	[self setBatchIsRunning:NO];
	[self setButtons];
}

//---------------------------------------------------------------------
// batchTarget
//---------------------------------------------------------------------
- (IBAction)batchTarget:(id)sender
{

	switch ([sender tag])
	{
		case cResetAllButton:
			[self batchSetAllEntriesTo:cQueue onlySelected:NO onlyIfOn:YES refresh:YES];
			break;
		case 	cResetButton:
			[self batchSetAllEntriesTo:cQueue onlySelected:YES onlyIfOn:YES refresh:YES];
			break;
		case cRunButton:
			[self batchRun:YES];
			break;
		case cRunAllButton:
			[self batchRun:NO];
			break;
		case cAbortButton:
			if ( gIsPausing==YES)	// go out of pause before aborting
				[self pauseThread];
			gUserWantsToAbortRender=YES;	// this will cause the renderer to stop
			[self setBatchIsRunning:ABORT];
			break;
		case cSkipButton:
			if ( gIsPausing==YES)	// go out of pause before aborting
				[self pauseThread];
			gUserWantsToAbortRender=YES;	// this will cause the renderer to stop
			[self setBatchIsRunning:SKIPPING];
			break;

		case cAddbutton:
			[self batchAddFiles:NO];
			break;
		case cInsertButton:
			[self batchAddFiles:YES];
			break;
		case cTrashButton:
			[self batchRemove:NO refresh:YES];
			break;
		case cSettingsPopup:
			[self batchApplySettingsPopup:sender];
			break;
	}
}

//---------------------------------------------------------------------
// batchAddFiles
//---------------------------------------------------------------------
-(void) batchAddFiles:(BOOL)insert
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:YES];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"pov"]];
	void (^batchOpenFilesPanelFinishedHandler)(NSInteger) = ^( NSInteger resultCode)
	{
		@autoreleasepool
		{
			if( resultCode == NSOKButton )
			{
				NSInteger current;
				if ( insert == YES)
				{
					NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
					current=[selectedRows firstIndex];
				}

				NSArray *arr=[openPanel URLs];
				for (int x=0; x<[arr count]; x++)
				{
					NSString *file=[[arr objectAtIndex:x] path];
					BOOL isDir;
					NSFileManager *manager = [NSFileManager defaultManager];
					if ([manager fileExistsAtPath:file isDirectory:&isDir] &&  isDir==NO)
					{
						if ( insert==YES)
						{
							[mBatchMap insertEntryAtIndex:current file:file];
							current++;
						}
						else
							[mBatchMap addEntry:file];
					}
				}
			}
		}
	};

	[openPanel beginSheetModalForWindow:[mTableView window]
										completionHandler:batchOpenFilesPanelFinishedHandler];
}

//---------------------------------------------------------------------
// isRendering
//---------------------------------------------------------------------
-(void) batchApplySettingsPopup:(id)sender
{
	NSInteger index=[mSettingsPopupButton indexOfSelectedItem];
	NSString *itemString=[mSettingsPopupButton itemTitleAtIndex:index];
	NSMutableDictionary *dict=nil;

	if ( index==0)	//default
	{
		dict=[[PreferencesPanelController sharedInstance]	getDictWithCurrentSettings:NO];
	}
	else
	{
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		NSArray *appArray=[defaults arrayForKey:@"mainPrefsArray"];
		for (int index=0; index <[appArray count]; index++)
		{
			dict=[appArray objectAtIndex:index];
			NSString *dictName=[dict objectForKey:@"dictionaryName"];
			if ( [dictName isEqualToString:itemString])
				break;
		}
	}
	if ( dict != nil)
	{
		NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
		NSUInteger current;
		current=[selectedRows firstIndex];
		while (current != NSNotFound)
		{
			[mBatchMap setObject:dict atRow:current atColumn: cSettingsIndex];
			current=[selectedRows indexGreaterThanIndex:current];
		};
	}
	[mTableView reloadData];
}

//---------------------------------------------------------------------
// isRendering
//---------------------------------------------------------------------
-(BOOL) rendering
{
	return mRendering;
}

-(void)notifyVfeSessionStoppedRendering
{
	[[NSNotificationCenter defaultCenter]	postNotificationName:@"vfeSessionStoppedRendering" object:nil userInfo:nil];
}
//---------------------------------------------------------------------
// setIsRendering
//---------------------------------------------------------------------
-(void) setNotRendering
{
	[self setRendering:NO];

}

//---------------------------------------------------------------------
// setIsRendering
//---------------------------------------------------------------------
-(void) setIsRendering
{
	[self setRendering:YES];
}

//---------------------------------------------------------------------
// setIsRendering
//---------------------------------------------------------------------
-(void) setRendering: (BOOL) flag
{
	mRendering=flag;
	NSDictionary *dict=[NSDictionary dictionaryWithObject:
											[NSNumber numberWithBool:mRendering] forKey:@"renderStarted"];
	if (mRendering==NO)
	{
		[self setPreparingToRender:NO];
		mThreadID=0l;
	}

	[[NSNotificationCenter defaultCenter]	postNotificationName:@"renderState" object:self userInfo:dict];
	if ( gApplicationShouldTerminate == YES)
		[[NSApplication sharedApplication]terminate:nil];

}

//---------------------------------------------------------------------
// isPreparintToRender
//---------------------------------------------------------------------
-(BOOL) preparingToRender
{
	return mPreparingToRender;
}

//---------------------------------------------------------------------
// setPreparintToRender
//---------------------------------------------------------------------
-(void) setPreparingToRender: (BOOL) flag
{
	mPreparingToRender=flag;
	NSDictionary *dict=[NSDictionary dictionaryWithObject:
											[NSNumber numberWithBool:flag] forKey:@"preparingStarted"];

	[[NSNotificationCenter defaultCenter]
		postNotificationName:@"preparingState"
		object:self userInfo:dict];
}


//---------------------------------------------------------------------
// acceptDocument
//---------------------------------------------------------------------
// notification
//	object is a NSDocument which wants to place itself in the preferences dialog
//	usersInfo contains one object indicating if we should start rendering
//---------------------------------------------------------------------
-(void) renderDocument:(NSNotification *) notification
{
	//can we start a new render
	if( [self canStartNewRender] ==NO)
		return;
	mPostingObject=nil;

	//reserve ourself
	[self setPreparingToRender:YES];

	// save all the info for rendering
	NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary: [notification userInfo]];
	[dict autorelease];
	if ( dict != nil)
	{
		[self setPostedDictionary:dict];
		// if the poster was a document, we will start by saving
		// that document. Makes it more clear for the user
		mPostingObject=[notification object];
		if ( [mPostingObject isKindOfClass:[SceneDocument class]] && [mPostingObject isDocumentEdited] )
		{
			[mPostingObject saveDocumentWithDelegate:self
															 didSaveSelector:@selector(keepSavingUntillAllFilesAreSaved:didSave:contextInfo:)
																	 contextInfo:(void*)mPostingObject];
			return;	// keepSavingUntillAllFilesAreSaved will do the rest and start the render
		}
		// if it is a materialeditor, we don't save anything
		else if ( [mPostingObject isKindOfClass:[MaterialTemplate class]])
		{
			if ( [[self postedDictionary] objectForKey:@"renderMaterial"] && [[[self postedDictionary] objectForKey:@"renderMaterial"]intValue]==YES)
			{
				[self runMaterial];
				return;
			}
		}
		// poster was something else
		// start saving all the documents if there are any unsaved
		[self keepSavingUntillAllFilesAreSaved:nil didSave:YES contextInfo:nil];
	}
	else
		[self setPreparingToRender:NO];
}

//---------------------------------------------------------------------
// keepSavingUntillAllFilesAreSaved
//---------------------------------------------------------------------
//	doc and contextInfo can be nil if called from renderDocument
//	in that case, didSave will be YES
//	this is used to start saving all documents
//---------------------------------------------------------------------
- (void) keepSavingUntillAllFilesAreSaved:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void*)contextInfo
{
	BOOL moreUnsaved=NO;

	if ( didSave==YES)
	{
		NSDocumentController *ctrl=[NSDocumentController sharedDocumentController];
		if ( ctrl)
		{
			NSArray *documentsArray=[ctrl documents];
			NSEnumerator *en=[documentsArray objectEnumerator];
			SceneDocument *object;
			while ( (object =[en nextObject] )!= nil)
			{
				if ( [object isDocumentEdited])
				{
					moreUnsaved=YES;
					[object saveDocumentWithDelegate:self didSaveSelector:@selector(keepSavingUntillAllFilesAreSaved:didSave:contextInfo:) contextInfo:nil];
					break;
				}
			}
			if ( moreUnsaved==NO)
			{

				// if the object that requested a render was a document
				//	move that name of the now saved document in
				//	the preferences window.
				NSString *fileName=[[self postedDictionary] objectForKey:@"fileName"];
				if ( fileName != nil)
				{
					if ( mPostingObject )
					{
						if ( [mPostingObject isKindOfClass:[SceneDocument class]]   )
						{
							NSDictionary *infoDict=[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"orderFront"];

							[[NSNotificationCenter defaultCenter]postNotificationName:@"acceptDocument"
																																 object:mPostingObject
																															 userInfo:infoDict];
							//make sure that we have the new file settings
							[ mPostedDictionary setObject:[[PreferencesPanelController sharedInstance] getDictWithCurrentSettings:NO] forKey:@"rendersettings"];
						}
						else if ( [mPostingObject isKindOfClass:[renderDispatcher class]]   )
						{
							NSMutableDictionary *dict=[mPostedDictionary objectForKey:@"rendersettings"];
							[dict setObject:[NSString stringWithString:fileName] forKey:@"sceneFile"];
							NSString *temp=[fileName stringByDeletingPathExtension];
							temp=[temp stringByAppendingString:@"."];
							[dict setObject:temp forKey:@"imageFile"];
							[ mPostedDictionary setObject:dict forKey:@"rendersettings"];
						}
					}
				}
				if ( [[self postedDictionary] objectForKey:@"renderMaterial"] && [[[self postedDictionary] objectForKey:@"renderMaterial"]intValue]==YES)
					[self runMaterial];
				else
					[self run];

			}
		}
	}
	else	// saving aborted
	{
		[self setPreparingToRender:NO];
	}
}

//---------------------------------------------------------------------
// setPostedDictionary
//---------------------------------------------------------------------
-(void) setPostedDictionary: (NSMutableDictionary*) dict
{
	[mPostedDictionary release];
	mPostedDictionary=dict;
	[mPostedDictionary retain];
}

//---------------------------------------------------------------------
// postedDictionary
//---------------------------------------------------------------------
-(NSMutableDictionary*) postedDictionary
{
	return mPostedDictionary;
}


//---------------------------------------------------------------------
// canStartNewRender
//---------------------------------------------------------------------
-(BOOL) canStartNewRender
{
	if ([self preparingToRender]==YES)
		return NO;
	if ( [self rendering]==YES)
		return NO;

	return YES;
}

//---------------------------------------------------------------------
// canPauseRender
//---------------------------------------------------------------------
-(BOOL) canPauseRender
{
	if ([self preparingToRender]==YES)
		return NO;
	if ( [self rendering]==YES)
		return YES;

	return YES;
}

//---------------------------------------------------------------------
// canAbortRender
//---------------------------------------------------------------------
-(BOOL) canAbortRender
{
	if ([self preparingToRender]==YES)
		return NO;
	if ( [self rendering]==YES)
		return YES;

	return YES;
}



//---------------------------------------------------------------------
// releaseArgv
//---------------------------------------------------------------------
//	release memory for Argv and elements
//---------------------------------------------------------------------
- (void) releaseArgv
{
	if ( Argv)
	{
		for (int x=0; x<=availableArgc; x++)
		{
			if ( Argv[x])
			{
				free(Argv[x]);
				Argv[x]=0;
			}
		}
		free (Argv);
		Argv=NULL;
		availableArgc=0;
		Argc=0;
	}
}


//---------------------------------------------------------------------
// Argc
//---------------------------------------------------------------------
-(int) Argc
{
	return Argc;
}

//---------------------------------------------------------------------
// Argv
//---------------------------------------------------------------------
-(char**) Argv
{
	return Argv;
}

-(void) runMaterial
{
	[self releaseArgv];
	NSMutableDictionary *settingsDict=[ mPostedDictionary objectForKey:@"rendersettings"];
	if ( settingsDict == nil)
	{
		[self setPostedDictionary:nil];
		[self setPreparingToRender:NO];
		return;
	}

	availableArgc=120;
	Argv=(char**)malloc((availableArgc+1)*sizeof(char*));
	if ( Argv)
	{
		for (int x=0; x<=availableArgc; x++)
			Argv[x]=0;
	}
	[gMaterialPreview hideAndReleaseContent];

	[self addCommand :"Input_File_Name" withString:[settingsDict objectForKey:@"fileName"]];
	[self addCommand:"Width" withString:[[settingsDict objectForKey:@"frameWidth"]stringValue]];
	[self addCommand:"Height" withString:[[settingsDict objectForKey:@"frameHeight"]stringValue]];
	[self addCommand:"Start_Column" withString:@"0"];
	[self addCommand:"Start_Row" withString:@"0"];
	[self addCommand:"End_Column" withString:[[settingsDict objectForKey:@"frameWidth"]stringValue]];
	[self addCommand:"End_Row" withString:[[settingsDict objectForKey:@"frameHeight"]stringValue]];

	[self addCommand:"Antialias" withString:@"false"];
	[self addCommand:"Output_To_File" withString:@"false"];
	[self addCommand:"Verbose" withString:@"Off"];
	[self addCommand:"Display" withString:@"true"];
	[self addCommand:"All_Console" withString:@"false"];
	[self addCommand:"Fatal_Console" withString:@"true"];
	[self addCommand:"Bounding_Threshold" withString:@"5"];
	activeRenderPreview=gMaterialPreview;
	[self createAndStartThread];


}
//---------------------------------------------------------------------
// run
//---------------------------------------------------------------------
//	make a command line
//	invoke the renderer
//---------------------------------------------------------------------
-(void) run
{
	gOnlyDisplayPart=NO;
	gDontErasePreveiw=NO;
	activeRenderPreview=gPicturePreview;

	[self releaseArgv];
	NSMutableDictionary *settingsDict=[ mPostedDictionary objectForKey:@"rendersettings"];
	if ( settingsDict == nil)
	{
		[self setPostedDictionary:nil];
		[self setPreparingToRender:NO];
		return;
	}

	id poster=[ mPostedDictionary objectForKey:@"poster"];
	if ( [poster isKindOfClass:[SceneDocument class]])
	{
		NSString *temp=[[poster fileName] stringByDeletingPathExtension];
		[settingsDict setObject:temp forKey:@"sceneFile"];
	}

	availableArgc=120;
	Argv=(char**)malloc((availableArgc+1)*sizeof(char*));
	if ( Argv)
	{
		for (int x=0; x<=availableArgc; x++)
			Argv[x]=0;
	}
	//release the content of the preview window and hide that window
	//	[gPicturePreview hideAndReleaseContent];

	// make paths and names to use for all
	//	options related to files
	//	we try to add a path for every possible file
	NSRange extensionDot=NSRange();
	[self setOutputFileNameNoPathNoExtension:nil];
	[self setOutputFilePathWithSlash:nil];
	/*	if (0)
	 {*/
	[self setInputFilePathWithSlash:[[settingsDict objectForKey:@"sceneFile"]stringByDeletingLastPathComponent]];
	if ( ![[self inputFilePathWithSlash] hasSuffix:@"/"])
		[self setInputFilePathWithSlash:[[self inputFilePathWithSlash] stringByAppendingString:@"/"]];

	[self setInputFileNameNoPathWithExtension:[ [settingsDict objectForKey:@"sceneFile"]lastPathComponent]];
	extensionDot=[[self inputFileNameNoPathWithExtension] rangeOfString:@"." options:NSBackwardsSearch+NSLiteralSearch];
	if ( extensionDot.length)	//there is an extension
	{
		[self setInputFileNoPathNoExtension:[inputFileNameNoPathWithExtension substringToIndex:extensionDot.location]];
	}
	else
	{
		[self setInputFileNoPathNoExtension:[self inputFileNameNoPathWithExtension]];
	}

	// now, the name of the output file
	//	we remove all extensions
	if ([settingsDict objectForKey:@"imageFile"])
	{
		//NSLog(@"output: %@",[settingsDict objectForKey:@"imageFile"]);

		[self setOutputFileNameNoPathNoExtension:[[settingsDict objectForKey:@"imageFile"]lastPathComponent]];
		[self setOutputFilePathWithSlash:[[settingsDict objectForKey:@"imageFile"]stringByDeletingLastPathComponent]];
		//NSLog(@"setOutputFileNameNoPathNoExtension: %@",[self outputFileNameNoPathNoExtension]);
		//NSLog(@"setOutputFilePathWithSlash: %@",[self outputFilePathWithSlash]);
	}


	if ( [[self outputFileNameNoPathNoExtension] length ] )
	{
		extensionDot=[[self outputFileNameNoPathNoExtension] rangeOfString:@"." options:NSBackwardsSearch+NSLiteralSearch];
		if ( extensionDot.length)	//there is an extension
		{
			[self setOutputFileNameNoPathNoExtension:[[self outputFileNameNoPathNoExtension] substringToIndex:extensionDot.location]];
		}
	}
	else
		[self setOutputFileNameNoPathNoExtension:[self inputFileNoPathNoExtension]];

	//and finaly, the path for the output.
	if ([[settingsDict objectForKey:@"redirectAllOutputImagesOnOff"] intValue] && [(NSString*)[settingsDict objectForKey:@"redirectAllOutputImagesPath"] length])
	{
		[self setOutputFilePathWithSlash:[settingsDict objectForKey:@"redirectAllOutputImagesPath"]];
	}


	if ( ![[self outputFilePathWithSlash] hasSuffix:@"/"])
		[self setOutputFilePathWithSlash:[outputFilePathWithSlash stringByAppendingString:@"/"]];
	[self buildOutputFileWithPathAndDot];	//having this ready is easy :-)

	//and now start building the options

	//input scene version
	id tempId=[settingsDict objectForKey:@"languageVersion_xx"];
	if ( tempId != nil)
	{
		switch ([tempId intValue])
		{
			case 10: [self addCommand:"Version" withString:@"1.0"]; break;
			case 20: [self addCommand:"Version" withString:@"2.0"]; break;
			case 30: [self addCommand:"Version" withString:@"3.0"]; break;
			case 31: [self addCommand:"Version" withString:@"3.1"]; break;
			case 35: [self addCommand:"Version" withString:@"3.5"]; break;
			case 36: [self addCommand:"Version" withString:@"3.6"]; break;
			case 37: [self addCommand:"Version" withString:@"3.7"]; break;
			default: [self addCommand:"Version" withString:@"3.7"]; break;
		}
	}
	else
	{
		switch ([[settingsDict objectForKey:@"languageVersion"]intValue])
		{
			case cLanguageVersion1X: [self addCommand:"Version" withString:@"1.0"]; break;
			case cLanguageVersion2X	: [self addCommand:"Version" withString:@"2.0"]; break;
			case cLanguageVersion30X: [self addCommand:"Version" withString:@"3.0"]; break;
			case cLanguageVersion31X: [self addCommand:"Version" withString:@"3.1"]; break;
			case cLanguageVersion35X: [self addCommand:"Version" withString:@"3.5"]; break;
			case cLanguageVersion36X: [self addCommand:"Version" withString:@"3.6"]; break;
			default: [self addCommand:"Version" withString:@"3.6"];
		}
	}

	//files and paths

	BOOL		doingOutput=NO;

	switch ( [[settingsDict objectForKey:@"imageType"]intValue] )
	{
		case cImageTypeDontSave: //don't save
			[self addCommand:"Output_To_File" withString:@"false"];
			[self setExtensionToAddIfNoneWasProvided:@""];
			break;
		case cImageTypeTarga:		//Targa
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"T"];
			[self setExtensionToAddIfNoneWasProvided:@"tga"];
			doingOutput=YES;
			break;
		case cImageTypeTargaCompressed:
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"C"];
			[self setExtensionToAddIfNoneWasProvided:@"tga"];
			doingOutput=YES;
			break;
		case cImageTypePNG:	//png
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"N"];
			[self setExtensionToAddIfNoneWasProvided:@"png"];
			if ( [[settingsDict objectForKey:@"grayScaleOutputOn"]intValue]==NSOnState )
			{
				[self addCommand:"Grayscale_Output" withString:@"true"];
			}
			doingOutput=YES;
			break;
		case cImageTypePPM: //ppm
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"P"];
			[self setExtensionToAddIfNoneWasProvided:@"ppm"];
			if ( [[settingsDict objectForKey:@"grayScaleOutputOn"]intValue]==NSOnState && [[settingsDict objectForKey:@"bitDepth"]intValue]==cBitDepth16)
			{
				[self addCommand:"Grayscale_Output" withString:@"true"];
			}
			doingOutput=YES;
			break;
		case cImageTypeHdr:		//df3
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"H"];
			[self setExtensionToAddIfNoneWasProvided:@"hdr"];
			doingOutput=YES;
			break;
		case cImageTypeExr:		//openExr
			[self addCommand:"Output_To_File" withString:@"true"];
			[self addCommand:"Output_File_Type" withString:@"E"];
			[self setExtensionToAddIfNoneWasProvided:@"exr"];
			doingOutput=YES;
			break;
		default:
			[self addCommand:"Output_To_File" withString:@"false"];
			break;
	}
	if ( doingOutput==YES)	//we will produce an image file, set up the file name
	{
		[self addCommand:"Output_File_Name" withString:	[self stringByAddingQuotationmarks: [[self outputFileWithPathAndDot] stringByAppendingString:[self extensionToAddIfNoneWasProvided]]]];
		if ( [[settingsDict objectForKey:@"fileGammaOn"]intValue]==NSOnState )
		{
			[self addCommand:"File_Gamma" withString:[settingsDict objectForKey:@"fileGammaEdit"]];
		}
		//	NSLog([NSString stringWithFormat:@"Output_File_Name=%@",[self stringByAddingQuotationmarks: [[self outputFileWithPathAndDot] stringByAppendingString:[self extensionToAddIfNoneWasProvided]]]]);
	}
	//bithDepth
	switch ([[settingsDict objectForKey:@"bitDepth"]intValue])
	{
		case cBitDepth5:
			[self addCommand:"Bits_Per_Colour" withString:@"5"]; break;
		case cBitDepth8:
			[self addCommand:"Bits_Per_Colour" withString:@"8"]; break;
		case cBitDepth12:
			[self addCommand:"Bits_Per_Colour" withString:@"12"]; break;
		case cBitDepth16:
			[self addCommand:"Bits_Per_Colour" withString:@"16"]; break;
		default:
			[self addCommand:"Bits_Per_Colour" withString:@"5"]; break;
	}

	//text streams
	// main switch
	if ( [[settingsDict objectForKey:@"redirectTextStreamsOnOff"]intValue] )
	{
		//debug
		if ( [[settingsDict objectForKey:@"debugToScreen"]intValue]==NSOffState )
			[self addCommand:"Debug_Console" withString:@"Off"];
		if ( [[settingsDict objectForKey:@"debugToFile"]intValue] )
			[self addCommand:"Debug_File" withString:[self stringByAddingQuotationmarks:[[self outputFileNameNoPathNoExtension] stringByAppendingString:@".deb"]]];

		//fatal
		if ( [[settingsDict objectForKey:@"fatalToScreen"]intValue]==NSOffState )
			[self addCommand:"Fatal_Console" withString:@"Off"];
		if ( [[settingsDict objectForKey:@"fatalToFile"]intValue] )
			[self addCommand:"Fatal_File" withString:[self stringByAddingQuotationmarks:[[self outputFileNameNoPathNoExtension] stringByAppendingString:@".fat"]]];

		//render
		if ( [[settingsDict objectForKey:@"renderToScreen"]intValue]==NSOffState )
			[self addCommand:"Render_Console" withString:@"Off"];
		if ( [[settingsDict objectForKey:@"renderToFile"]intValue] )
			[self addCommand:"Render_File" withString:[self stringByAddingQuotationmarks:[[self outputFileNameNoPathNoExtension] stringByAppendingString:@".ren"]]];

		//statistic
		if ( [[settingsDict objectForKey:@"statisticsToScreen"]intValue]==NSOffState )
			[self addCommand:"Statistic_Console" withString:@"Off"];
		if ( [[settingsDict objectForKey:@"statisticsToFile"]intValue] )
			[self addCommand:"Statistic_File" withString:[self stringByAddingQuotationmarks:[[self outputFileNameNoPathNoExtension] stringByAppendingString:@".sta"]]];

		//warning
		if ( [[settingsDict objectForKey:@"warningToScreen"]intValue]==NSOffState )
			[self addCommand:"Warning_Console" withString:@"Off"];
		if ( [[settingsDict objectForKey:@"warningToFile"]intValue] )
			[self addCommand:"Warning_File" withString:[self stringByAddingQuotationmarks:[[self outputFileNameNoPathNoExtension] stringByAppendingString:@".war"]]];
	}
	else	// no output to console, no output ot file
		[self addCommand:"All_Console" withString:@"false"];



	[self addCommand :"Library_Path" withString:[self stringByAddingQuotationmarks:[self inputFilePathWithSlash]]];
	[self addCommand :"Input_File_Name" withString:
		[self stringByAddingQuotationmarks:[[self inputFilePathWithSlash] stringByAppendingString:[self inputFileNameNoPathWithExtension]]]
	 ];

	if( [(NSString*)[settingsDict objectForKey:@"include1"]length])
		[self addCommand :"Library_Path" withString:[self stringByAddingQuotationmarks: [settingsDict objectForKey:@"include1"]]];

	if( [(NSString*)[settingsDict objectForKey:@"include2"]length])
		[self addCommand :"Library_Path" withString:[self stringByAddingQuotationmarks: [settingsDict objectForKey:@"include2"]]];



	//and here the system include paths.
	// after those from the preferences panel
	{	// keep these grouped, they use NSUserDefaults * defaults
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		NSArray *sysPaths=[[defaults objectForKey:@"includePaths"]retain];
		if (sysPaths !=nil)
		{
			NSEnumerator *en=[sysPaths objectEnumerator];
			NSString *object;
			while ( (object =[en nextObject] )!= nil)
				[self addCommand :"Library_Path" withString:[self stringByAddingQuotationmarks: [object  stringByAppendingString:@"/"]]];
			[sysPaths release];
		}

		//display gamma/*
		if ( defaults !=nil)
		{
			if ([defaults objectForKey:@"displayGammaOn"] && [[defaults objectForKey:@"displayGammaOn"]intValue]==NSOnState)
			{
				if ( [defaults objectForKey:@"mOutletDisplayGammaEdit"] )
					[self addCommand:"Display_Gamma" withString:[defaults objectForKey:@"mOutletDisplayGammaEdit"]];
			}
		}
	}	// keep these grouped, they use NSUserDefaults * defaults
	
	//image & quality
	[self addCommand:"Width" withString:[settingsDict objectForKey:@"imageSizeX"]];
	[self addCommand:"Height" withString:[settingsDict objectForKey:@"imageSizeY"]];
	[self addCommand:"Start_Column" withString:[settingsDict objectForKey:@"xSubsetStart"]];
	[self addCommand:"Start_Row" withString:[settingsDict objectForKey:@"ySubsetStart"]];
	[self addCommand:"End_Column" withString:[settingsDict objectForKey:@"xSubsetEnd"]];
	[self addCommand:"End_Row" withString:[settingsDict objectForKey:@"ySubsetEnd"]];


	//alphachannel

	if ( [[settingsDict objectForKey:@"addAlphaChannel"]intValue]==NSOnState)
		[self addCommand:"Output_Alpha" withString:@"true"];
	else
		[self addCommand:"Output_Alpha" withString:@"false"];

	//display on/off (If we don't save the file, we always turn diplaying on)
	if ( [[settingsDict objectForKey:@"dontDisplay"]intValue]==NSOffState || doingOutput==NO)
		[self addCommand:"Display" withString:@"true"];
	else
		[self addCommand:"Display" withString:@"false"];

	//continue trace
	if ( [[settingsDict objectForKey:@"continueRendering"]intValue])
		[self addCommand:"Continue_Trace" withString:@"true"];
	else
		[self addCommand:"Continue_Trace" withString:@"false"];

	//write ini
	if ( [[settingsDict objectForKey:@"writeIniFile"]intValue])
	{
		[self addCommand:"Create_Ini" withString:[self stringByAddingQuotationmarks:[[self outputFileWithPathAndDot] stringByAppendingString:@"ini"]]];
	}

	//quality
	switch ([[settingsDict objectForKey:@"quality"]intValue])
	{
		case 0: case 1:case 2:case 3:case 4:case 5:case 6:case 7:case 8:case 9:
			[self addCommand:"quality" withString:[NSString stringWithFormat:@"%d",[[settingsDict objectForKey:@"quality"]intValue]]];
			break;
		default:
			[self addCommand:"quality" withString:@"9"];
			break;
	}

	//highReproducibilityOn

	if ( [[settingsDict objectForKey:@"highReproducibilityOn"]intValue]==NSOnState)
		[self addCommand:"High_Reproducibility" withString:@"true"];
	else
		[self addCommand:"High_Reproducibility" withString:@"false"];

	//dithering
	if ( [[settingsDict objectForKey:@"ditheringOn"]intValue] )
	{
		[self addCommand:"Dither" withString:@"true"];

		switch ( [[settingsDict objectForKey:@"ditheringMethod"]intValue])
		{
			case cDitheringB2: [self addCommand:"Dither_Method" withString:@"B2"];	break;
			case cDitheringB3: [self addCommand:"Dither_Method" withString:@"B3"];	break;
			case cDitheringB4: [self addCommand:"Dither_Method" withString:@"B4"];	break;
			case cDitheringD1: [self addCommand:"Dither_Method" withString:@"D1"];	break;
			case cDitheringD2: [self addCommand:"Dither_Method" withString:@"D2"];	break;
			case cDitheringFloydSteinberg: [self addCommand:"Dither_Method" withString:@"FS"];	break;
			default:	[self addCommand:"Dither_Method" withString:@"FS"];		break;
		}
	}

	//anti-aliasing
	if ( [[settingsDict objectForKey:@"samplingOn"]intValue] )
	{
		[self addCommand:"Antialias" withString:@"true"];
		[self addCommand:"Jitter" withString:@"true"];

		switch ( [[settingsDict objectForKey:@"sampleMethod"]intValue])
		{
			case 1:
				[self addCommand:"Sampling_Method" withString:@"2"];
				break;
			default:	//which is also type 1 for now
				[self addCommand:"Sampling_Method" withString:@"1"];
				break;
		}
		[self addCommand:"Jitter_Amount" withString:[settingsDict objectForKey:@"sampleJitter"]];
		[self addCommand:"Antialias_Threshold" withString:[settingsDict objectForKey:@"sampleThreshold"]];
		[self addCommand:"Antialias_Depth" withString:[settingsDict objectForKey:@"sampleRecursion"]];
		[self addCommand:"Antialias_Gamma" withString:[settingsDict objectForKey:@"mOutletSamplingGamma"]];
	}
	else
	{
		[self addCommand:"Antialias" withString:@"false"];
		[self addCommand:"Jitter" withString:@"false"];

	}


	//bounding & preview

	//bounding system
	if ( [[settingsDict objectForKey:@"autoBoundingOnOff"]intValue] )
	{
		[self addCommand:"Bounding" withString:@"true"];
		switch ( [[settingsDict objectForKey:@"boundingObjects"]intValue])
		{
			case cBoudingObjects1:		[self addCommand:"Bounding_Threshold" withString:@"1"];	break;
			case cBoudingObjects3:		[self addCommand:"Bounding_Threshold" withString:@"3"];	break;
			case cBoudingObjects5:		[self addCommand:"Bounding_Threshold" withString:@"5"];	break;
			case cBoudingObjects10:	[self addCommand:"Bounding_Threshold" withString:@"10"];	break;
			case cBoudingObjects15:	[self addCommand:"Bounding_Threshold" withString:@"15"];	break;
			case cBoudingObjects20:	[self addCommand:"Bounding_Threshold" withString:@"20"];	break;
			case cBoudingObjects25:	[self addCommand:"Bounding_Threshold" withString:@"25"];	break;
			case cBoudingObjects30:	[self addCommand:"Bounding_Threshold" withString:@"30"];	break;
			case cBoudingObjects35:	[self addCommand:"Bounding_Threshold" withString:@"35"];	break;
			case cBoudingObjects40:	[self addCommand:"Bounding_Threshold" withString:@"40"];	break;
		}
		if ( [[settingsDict objectForKey:@"ignoreBoundedBy"]intValue] )
			[self addCommand:"Remove_Bounds" withString:@"true"];
		else
			[self addCommand:"Remove_Bounds" withString:@"false"];

		if ( [[settingsDict objectForKey:@"splitUnions"]intValue] )
			[self addCommand:"Split_Unions" withString:@"true"];
		else
			[self addCommand:"Split_Unions" withString:@"false"];

		if ( [[settingsDict objectForKey:@"BSPBoundingMethodOnOff"]intValue] )
		{
			[self addCommand:"Bounding_Method=2" withString:@"2"];
			[self addCommand:"BSP_MaxDepth" withString:[settingsDict objectForKey:@"BSP_MaxDepth"]];
			[self addCommand:"BSP_BaseAccessCost" withString:[settingsDict objectForKey:@"BSP_BaseAccessCost"]];
			[self addCommand:"BSP_ChildAccessCost" withString:[settingsDict objectForKey:@"BSP_ChildAccessCost"]];
			[self addCommand:"BSP_IsectCost" withString:[settingsDict objectForKey:@"BSP_IsectCost"]];
			[self addCommand:"BSP_MissChance" withString:[settingsDict objectForKey:@"BSP_MissChance"]];
		}
	}
	else
	{
		[self addCommand:"Bounding" withString:@"false"];
		[self addCommand:"Remove_Bounds" withString:@"false"];
		[self addCommand:"Split_Unions" withString:@"false"];
	}

	// worker threads:
	if ( [settingsDict objectForKey:@"Work_Threads"] != nil)
	{
		NSInteger cpus=[[MainController sharedInstance]getNumberOfCpus];
		if ( cpus != -1)	// we know how many cores there are
		{
			switch ([[settingsDict objectForKey:@"Work_Threads"]intValue])
			{
				case cAutomatic:
					[self addCommand:"Work_Threads" withString:[NSString stringWithFormat:@"%ld",(long)cpus]]; break;
				case cCpusMinus1:
					if (cpus > 1)
						[self addCommand:"Work_Threads" withString:[NSString stringWithFormat:@"%ld",(long)(cpus-1)]];
					else
						[self addCommand:"Work_Threads" withString:[NSString stringWithFormat:@"%ld",(long)cpus]];
					break;
				case cCpusPlus1: [self addCommand:"Work_Threads" withString:[NSString stringWithFormat:@"%ld",(long)(cpus+1)]]; break;
				case cCpu1:[self addCommand:"Work_Threads" withString:@"1"]; break;
				case cCpu2:[self addCommand:"Work_Threads" withString:@"2"]; break;
				case cCpu3:[self addCommand:"Work_Threads" withString:@"3"]; break;
				case cCpu4:[self addCommand:"Work_Threads" withString:@"4"]; break;
				case cCpu5:[self addCommand:"Work_Threads" withString:@"5"]; break;
				case cCpu6:[self addCommand:"Work_Threads" withString:@"6"]; break;
				default: [self addCommand:"Work_Threads" withString:@"1"]; break;
			}//switch ([objc intValue])
		}//if ( cpus != -1)
		else
			[self addCommand:"Work_Threads" withString:@"1"];
	}

	//radiosity pretrace vain
	if ( [settingsDict objectForKey:@"mRadiosityVainMatrix"]!= nil)
	{
		switch ([[settingsDict objectForKey:@"mRadiosityVainMatrix"]intValue])
		{
			case cRadiosityVainOnCell:
				[self addCommand:"Radiosity_Vain_Pretrace" withString:@"on"];
				break;
			case cRadiosityVainOffCell:
				[self addCommand:"Radiosity_Vain_Pretrace" withString:@"off"];
				break;
		}
	}

	// Warning level:
	if ( [settingsDict objectForKey:@"mWarningLevelPopup"]!= nil)
	{
		switch ([[settingsDict objectForKey:@"mWarningLevelPopup"]intValue])
		{
			case cWarningLevel0:
				[self addCommand:"Warning_Level" withString:@"0"]; break;
			case cWarningLevel5:
				[self addCommand:"Warning_Level" withString:@"5"]; break;
			case cWarningLevel10:
				[self addCommand:"Warning_Level" withString:@"10"]; break;
		}//switch ([objc intValue])
	}// if ( objc != nil)


	// render block size:
	if ( [settingsDict objectForKey:@"RenderBlockSize"]!= nil)
	{
		switch ([[settingsDict objectForKey:@"RenderBlockSize"]intValue])
		{
			case cRenderBlockSize4:
				[self addCommand:"Render_Block_Size" withString:@"4"]; break;
			case CRenderBlockSize8:
				[self addCommand:"Render_Block_Size" withString:@"8"]; break;
			case cRenderBlockSize16:
				[self addCommand:"Render_Block_Size" withString:@"16"]; break;
			case cRenderBlockSize32:
				[self addCommand:"Render_Block_Size" withString:@"32"]; break;
			case cRenderBlockSize64:
				[self addCommand:"Render_Block_Size" withString:@"64"]; break;
			case cRenderBlockSize128:
				[self addCommand:"Render_Block_Size" withString:@"128"]; break;
		}//switch ([objc intValue])
	}// if ( objc != nil)

	// render pattern:
	if ( [settingsDict objectForKey:@"renderPattern"]!= nil)
	{
		switch ([[settingsDict objectForKey:@"renderPattern"]intValue])
		{
			case cRenderPattern0:
				[self addCommand:"Render_Pattern" withString:@"0"]; break;
			case cRenderPattern1:
				[self addCommand:"Render_Pattern" withString:@"1"]; break;
			case cRenderPattern2:
				[self addCommand:"Render_Pattern" withString:@"2"]; break;
			case cRenderPattern3:
				[self addCommand:"Render_Pattern" withString:@"3"]; break;
			case cRenderPattern4:
				[self addCommand:"Render_Pattern" withString:@"4"]; break;
			case cRenderPattern5:
				[self addCommand:"Render_Pattern" withString:@"5"]; break;
		}//switch ([objc intValue])
	}// if ( objc != nil)

	//Render Block Step (render pattern):
	if ( [settingsDict objectForKey:@"renderBlockStepOn"]!= nil && [[settingsDict objectForKey:@"renderBlockStepOn"]intValue]==NSOnState)
		[self addCommand:"Render_Block_Step" withString:[settingsDict objectForKey:@"renderBlockStep"]];



	//animation (clock)
	if ( [[settingsDict objectForKey:@"animationOnOff"]intValue] )
	{
		if ( [[settingsDict objectForKey:@"turnCyclicAnimationOn"]intValue] )
			[self addCommand:"Cyclic_Animation" withString:@"true"];
		else
			[self addCommand:"Cyclic_Animation" withString:@"false"];

		[self addCommand:"Initial_Clock" withString:[settingsDict objectForKey:@"clockInitial"]];
		[self addCommand:"Final_Clock" withString:[settingsDict objectForKey:@"clockEnd"]];
		[self addCommand:"Initial_Frame" withString:[settingsDict objectForKey:@"initialFrame"]];
		[self addCommand:"Final_Frame" withString:[settingsDict objectForKey:@"finalFrame"]];
		[self addCommand:"Subset_Start_Frame" withString:[settingsDict objectForKey:@"subsetStart"]];
		[self addCommand:"Subset_End_Frame" withString:[settingsDict objectForKey:@"subsetEnd"]];
		if ( [[settingsDict objectForKey:@"frameStepOn"]intValue] )
			[self addCommand:"Frame_Step" withString:[settingsDict objectForKey:@"frameStep"]];
		switch ( [[settingsDict objectForKey:@"fieldRendering"]intValue])
		{
			case cFieldRenderingOff:
				[self addCommand:"Field_Render" withString:@"false"];
				break;
			case cFieldRenderingStartEven:
				[self addCommand:"Field_Render" withString:@"true"];
				[self addCommand:"Odd_Field" withString:@"false"];
				break;
			case cFieldRenderingStartOdd:
				[self addCommand:"Field_Render" withString:@"true"];
				[self addCommand:"Odd_Field" withString:@"true"];

				break;
		}
	}


	//use the radiosisyt file if set
	if ( [[settingsDict objectForKey:@"mRadiosityLoadSaveGroupOn"]intValue]==NSOnState )
	{
		if ( [[settingsDict objectForKey:@"mRadiosityLoadOn"]intValue]==NSOnState || [[settingsDict objectForKey:@"mRadiositySaveOn"]intValue]==NSOnState)
		{
			if(	[[settingsDict objectForKey:@"mRadiosityLoadOn"]intValue]==NSOnState)
				[self addCommand:"Radiosity_From_File" withString:@"on"];
			else
				[self addCommand:"Radiosity_From_File" withString:@"off"];
			if(	[[settingsDict objectForKey:@"mRadiositySaveOn"]intValue]==NSOnState)
				[self addCommand:"Radiosity_To_File" withString:@"on"];
			else
				[self addCommand:"Radiosity_To_File" withString:@"off"];
			[self addCommand:"Radiosity_File_Name" withString:[self stringByAddingQuotationmarks:[settingsDict objectForKey:@"mRadiosityFileNameEdit"]]];
		}
	}

	//use the ini file if set
	if ( [[settingsDict objectForKey:@"useIniInputFile"]intValue]==NSOnState )
	{
		/*	NSString *inipath=[[settingsDict objectForKey:@"sceneFile"]stringByDeletingLastPathComponent];
		 if ( ![inipath hasSuffix:@"/"])
		 inipath=[inipath stringByAppendingString:@"/"];

		 [self addCommand :"Library_Path" withString:[self stringByAddingQuotationmarks:inipath]];
		 */
		[self addCommand:"Include_Ini" withString:[self stringByAddingQuotationmarks:[settingsDict objectForKey:@"iniInputFile"]]];

	}

	//display only part?
	if ( [[settingsDict objectForKey:@"onlyDisplayPart"]intValue] ==NSOnState)
		gOnlyDisplayPart=YES;
	//display only part?
	if ( [[settingsDict objectForKey:@"dontErasePreview"]intValue] ==NSOnState)
		gDontErasePreveiw=YES;

	// set default path to the path where
	// output is done.
	// prevents files like .rca to be written all over the place :-)
	NSFileManager *fm=[NSFileManager defaultManager];
	[fm changeCurrentDirectoryPath:[self outputFilePathWithSlash]];


	[self createAndStartThread];
}

//---------------------------------------------------------------------
// stringByAddingQuotationmarks
//---------------------------------------------------------------------
-(NSString*) stringByAddingQuotationmarks: (NSString *) str
{
	return [NSString stringWithFormat:@"\"%@\"", str];
}

//---------------------------------------------------------------------
// createAndStartThread
//---------------------------------------------------------------------
-(void) createAndStartThread
{
	//and run
	//use pthread instead of NSTread
	// we need more control
	// create attribute
	int res=pthread_attr_init(&mThreadAttr);
	if ( res !=0)
	{
		[self setRendering:NO];
		return;
	}
	//set detachstate
	res=pthread_attr_setdetachstate(&mThreadAttr, PTHREAD_CREATE_DETACHED);
	if ( res !=0)
	{
		pthread_attr_destroy(&mThreadAttr);
		[self setRendering:NO];
		return;
	}

	//set schedpolicy
	res=pthread_attr_setschedpolicy(&mThreadAttr, SCHED_OTHER);
	if ( res !=0)
	{
		pthread_attr_destroy(&mThreadAttr);
		[self setRendering:NO];
		return;
	}


	// set stacksize
	res=pthread_attr_setstacksize(&mThreadAttr, 1024000l);
	if ( res !=0)
	{
		pthread_attr_destroy(&mThreadAttr);
		[self setRendering:NO];
		return;
	}

	if ( res !=0)
	{
		pthread_attr_destroy(&mThreadAttr);
		[self setRendering:NO];
		return;
	}
	// and go
	res=pthread_create(&mThreadID,&mThreadAttr,doRender, (void*)self);
	if (res != 0)
	{
		[self setRendering:NO];
		return;
	}
	pthread_attr_destroy(&mThreadAttr);
}


//---------------------------------------------------------------------
// doRender
//---------------------------------------------------------------------
void *doRender(void* theObject)
{
	@autoreleasepool
	{
		[[renderDispatcher sharedInstance] performSelectorOnMainThread:@selector(setIsRendering)withObject:NULL waitUntilDone:YES];

		gIsRendering=YES;
		gApplicationShouldTerminate = NO;
		gApplicationAlreadyReceivedStopResquest = NO;
		gUserWantsToAbortRender = NO;
		gIsPausing=NO;
		gUserWantsToPauseRenderer=NO;

		// start rendering
		ReturnValue retval=BeginRender([(__bridge renderDispatcher*)theObject Argc]+1, [(__bridge renderDispatcher*)theObject Argv], (__bridge renderDispatcher*)theObject);
		//for long renders, user can put the machine to sleep after the rendering is done
		// but only after a success, not when an error occurred or a user abort
		if ( retval == RETURN_OK)
		{
			if ( [[MainController sharedInstance]shouldGoToSleepWhenDone] == NSOnState)
				[[MainController sharedInstance] performSelectorOnMainThread: @selector(goToSleepAfterOneMinute) withObject:nil waitUntilDone:NO];
		}

		//always turn this option of after a render
		//the user must set it again for each render to avoid
		// that the machine goes to sleep after a test render
		[[MainController sharedInstance]resetGoToSleepWhenDone];

		gIsRendering=NO;
		gIsPausing=NO;
		gUserWantsToPauseRenderer=NO;
		[[renderDispatcher sharedInstance] performSelectorOnMainThread:@selector(setNotRendering)withObject:NULL waitUntilDone:YES];
	}
	pthread_exit(0l);
	return nil;
}

//---------------------------------------------------------------------
// abortThread
//---------------------------------------------------------------------
-(void) abortThread
{
	if ( gIsPausing==YES)	// go out of pause before aborting
		[self pauseThread];
	gUserWantsToAbortRender = YES;	// this will cause the renderer to stop
}


//---------------------------------------------------------------------
// pauseThread
//---------------------------------------------------------------------
-(void) pauseThread
{
	//NSLog(@"pause request in renderdispatcher");
	if ( gIsPausing==YES)	// go out of pause
	{
		//NSLog(@"we are pausing in renderdispatcher");

		if ( vfe::gVfeSession)
		{
			//		NSLog(@"resuming");

			mSessionResult=vfe::gVfeSession->Resume();
			//	NSLog(@"retult: %d",mSessionResult);
			if ( mSessionResult== true)
				gIsPausing=NO;
		}
		[[NSNotificationCenter defaultCenter]	postNotificationName:@"pauseStatusChanged" object:self userInfo:nil];
	}
	else
	{
		//	NSLog(@"we are not pausing in renderdispatcher");

		gUserWantsToPauseRenderer=YES;
	}
}

//---------------------------------------------------------------------
// addCommand
//---------------------------------------------------------------------
-(void) addCommand: (const char*)command withString: (NSString*)string
{
	static char formatString[]="%s=%s";
	if ( [string UTF8String])
	{
		Argv[++Argc]=(char*)malloc( strlen(command) + strlen([string UTF8String]) + strlen(formatString) + 1);
		sprintf((char*)Argv[Argc],formatString,command, [string UTF8String]);
	}
}

//************************** setters and getters

//---------------------------------------------------------------------
// setInputFileNoPathNoExtension
//---------------------------------------------------------------------
-(NSString *) setInputFileNoPathNoExtension: (NSString*)fileName
{
	[inputFileNoPathNoExtension release];
	inputFileNoPathNoExtension=[fileName copy];
	return inputFileNoPathNoExtension;
}

//---------------------------------------------------------------------
// inputFileNoPathNoExtension
//---------------------------------------------------------------------
-(NSString *) inputFileNoPathNoExtension
{
	return inputFileNoPathNoExtension;
}

//---------------------------------------------------------------------
// setInputFileNoPathNoExtension
//---------------------------------------------------------------------
-(NSString *) setInputFileNameNoPathWithExtension: (NSString*)fileName
{
	[inputFileNameNoPathWithExtension release];
	inputFileNameNoPathWithExtension=[fileName copy];
	return inputFileNameNoPathWithExtension;
}

//---------------------------------------------------------------------
// inputFileNameNoPathWithExtension
//---------------------------------------------------------------------
-(NSString *) inputFileNameNoPathWithExtension
{
	return inputFileNameNoPathWithExtension;
}

//---------------------------------------------------------------------
// setInputFilePathWithSlash
//---------------------------------------------------------------------
-(NSString *) setInputFilePathWithSlash: (NSString*)path
{
	[inputFilePathWithSlash release];
	inputFilePathWithSlash=[path copy];
	return inputFilePathWithSlash;
}

//---------------------------------------------------------------------
// inputFilePathWithSlash
//---------------------------------------------------------------------
-(NSString *) inputFilePathWithSlash
{
	return inputFilePathWithSlash;
}

//---------------------------------------------------------------------
// setOutputFilePathWithSlash
//---------------------------------------------------------------------
-(NSString *) setOutputFilePathWithSlash: (NSString*)path
{
	[outputFilePathWithSlash release];
	outputFilePathWithSlash=[path copy];
	return outputFilePathWithSlash;
}

//---------------------------------------------------------------------
// outputFilePathWithSlash
//---------------------------------------------------------------------
-(NSString *) outputFilePathWithSlash
{
	return outputFilePathWithSlash;
}

//---------------------------------------------------------------------
// setOutputFileNameNoPathNoExtension
//---------------------------------------------------------------------
-(NSString *) setOutputFileNameNoPathNoExtension: (NSString*)fileName
{
	[outputFileNameNoPathNoExtension release];
	outputFileNameNoPathNoExtension=[fileName copy];
	return outputFileNameNoPathNoExtension;
}

//---------------------------------------------------------------------
// outputFileNameNoPathNoExtension
//---------------------------------------------------------------------
-(NSString *) outputFileNameNoPathNoExtension
{
	return outputFileNameNoPathNoExtension;
}

//---------------------------------------------------------------------
// buildOutputFileWithPathAndDot
//---------------------------------------------------------------------
-(NSString *) buildOutputFileWithPathAndDot
{
	[outputFileWithPathAndDot release];
	outputFileWithPathAndDot=[[self outputFilePathWithSlash] stringByAppendingString:[self outputFileNameNoPathNoExtension]];
	//NSLog(@"outputFileWithPathAndDot: %@",[self outputFileWithPathAndDot]);
	outputFileWithPathAndDot=[[[self outputFileWithPathAndDot] stringByAppendingString:@"."] copy];
	//NSLog(@"outputFileWithPathAndDot: %@",[self outputFileWithPathAndDot]);

	return outputFileWithPathAndDot;
}

//---------------------------------------------------------------------
// outputFileWithPathAndDot
//---------------------------------------------------------------------
-(NSString *) outputFileWithPathAndDot
{
	return outputFileWithPathAndDot;
}

//---------------------------------------------------------------------
// setExtensionToAddIfNoneWasProvided
//---------------------------------------------------------------------
-(NSString *) setExtensionToAddIfNoneWasProvided: (NSString*)extension
{
	[extensionToAddIfNoneWasProvided release];
	extensionToAddIfNoneWasProvided=[extension copy];
	return extensionToAddIfNoneWasProvided;
}

//---------------------------------------------------------------------
// extensionToAddIfNoneWasProvided
//---------------------------------------------------------------------
-(NSString *) extensionToAddIfNoneWasProvided
{
	return extensionToAddIfNoneWasProvided;
}

//---------------------------------------------------------------------
// batchIsRunning
//---------------------------------------------------------------------
-(BOOL) batchIsRunning
{
	return mBatchIsRunning;
}

//---------------------------------------------------------------------
// setBatchIsRunning
//---------------------------------------------------------------------
-(void) setBatchIsRunning:(int)newState
{
	mBatchIsRunning=newState;
}

//---------------------------------------------------------------------
// batchSaveDefaults
//---------------------------------------------------------------------
-(void) batchSaveDefaults
{
	id batchMap=[NSArchiver archivedDataWithRootObject:mBatchMap];
	NSDictionary *dict=[NSDictionary dictionaryWithObject:batchMap forKey:@"batchMap"];

	if ( dict)
	{
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		[defaults setObject:dict forKey:@"defaultBatch"];
		id column=[mTableView highlightedTableColumn];
		if ( column != nil)
		{
			[defaults setObject:[column identifier] forKey:@"selectedColumn"];
			[defaults setObject:[NSNumber numberWithInt:mSorteerOplopend] forKey:@"sortMethod"];
		}
		if ( [mBatchWindow isVisible] )
			[defaults setObject:[NSNumber numberWithBool:YES] forKey:@"batchwindowIsVisible"];
		else
			[defaults setObject:[NSNumber numberWithBool:NO] forKey:@"batchwindowIsVisible"];

	}
}


//---------------------------------------------------------------------
// setButtons
//---------------------------------------------------------------------
-(void) setButtons
{
	NSIndexSet *selectedRows=[mTableView selectedRowIndexes];
	NSInteger number=[selectedRows count];
	if ( [self batchIsRunning]==NO)
	{
		[mAbortButton setEnabled:NO];
		[mSkipButton setEnabled:NO];
		[mResetAllButton setEnabled:YES];
		[mRunAllButton setEnabled:YES];
	}
	else
	{
		[mAbortButton setEnabled:YES];
		[mSkipButton setEnabled:YES];
		[mResetAllButton setEnabled:NO];
		[mRunAllButton setEnabled:NO];
	}

	if ( number ==0)
	{
		[mRunButton setEnabled:NO];
		[mResetButton setEnabled:NO];
		[mInsertButton setEnabled:NO];
		[mTrashButton setEnabled:NO];
		[mSettingsPopupButton setEnabled:NO];
	}
	else if ( number ==1)
	{
		if ( [self batchIsRunning]==NO)
		{
			[mRunButton setEnabled:YES];
			[mResetButton setEnabled:YES];
			[mRunButton setEnabled:YES];
		}
		[mSettingsPopupButton setEnabled:YES];
		[mInsertButton setEnabled:YES];
		[mTrashButton setEnabled:YES];
	}
	else if ( number >1)
	{
		[mTrashButton setEnabled:YES];
		[mInsertButton setEnabled:NO];
		[mRunButton setEnabled:YES];
		[mResetButton setEnabled:YES];

	}

	[mAddButton setEnabled:YES];

}

//---------------------------------------------------------------------
// datasource
//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [mBatchMap count];
}

//---------------------------------------------------------------------
// selectionIncludePathTableViewChanged
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self setButtons];
}

//---------------------------------------------------------------------
// tableView: toolTipForCell: row
//---------------------------------------------------------------------
- (NSString *)tableView:(NSTableView *)aTableView toolTipForCell:(NSCell *)aCell rect:(NSRectPointer)rect tableColumn:(NSTableColumn *)aTableColumn
										row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation
{
	id obj;
	NSString *identifier=[aTableColumn identifier];
	if ( [ identifier isEqualToString:@"name"])
	{
		return [mBatchMap objectAtRow:row atColumn:cNameIndex];
	}
	else if ( [ identifier isEqualToString:@"comment"])
	{
		return [mBatchMap objectAtRow:row atColumn:cCommentIndex];
	}
	else if ( [ identifier isEqualToString:@"setting"])
	{
		obj= [mBatchMap objectAtRow:row atColumn:cSettingsIndex] ;
		NSString *tip=nil;
		tip=[NSString stringWithFormat:@"x: %@, y: %@\n", [obj objectForKey:@"imageSizeX"], [obj objectForKey:@"imageSizeY"]];

		if ( [[obj objectForKey:@"samplingOn"]intValue]==NSOnState)
		{
			tip=[tip  stringByAppendingFormat:@"alias on\nthreshold:%@ recursion:%@ jitter:%@\n",
					 [obj objectForKey:@"sampleThreshold"],
					 [obj objectForKey:@"sampleRecursion"],
					 [obj objectForKey:@"sampleJitter"]];
		}
		else
			tip=[tip stringByAppendingString:@"alias off\n"];

		switch ( [[obj objectForKey:@"imageType"]intValue])
		{
			case cImageTypeDontSave: tip=[tip stringByAppendingString:@"Don't save image\n"];				break;
			case cImageTypeTarga:
			case cImageTypeTargaCompressed:  tip=[tip stringByAppendingString:@"Save as Targa\n"];	break;
			case cImageTypePNG: tip=[tip stringByAppendingString:@"Save as PNG\n"];							break;
			case cImageTypePPM: tip=[tip stringByAppendingString:@"Save as PPM\n"];							break;
			case cImageTypeHdr: tip=[tip stringByAppendingString:@"Save as HDR\n"];							break;
			case cImageTypeExr: tip=[tip stringByAppendingString:@"Save as EXR\n"];							break;
			default: tip=[tip stringByAppendingString:@"Saving image...\n"];										break;
		}
		return tip;
	}

	return nil;
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	id obj=nil;
	if ( [identifier isEqualToString:@"onoff"])
		return [mBatchMap objectAtRow:rowIndex atColumn:cOnOffIndex];
	else if ( [identifier isEqualToString:@"name"])
	{
		obj=[mBatchMap objectAtRow:rowIndex atColumn:cNameIndex];
		return [obj lastPathComponent];
	}
	else if ( [identifier isEqualToString:@"setting"])
	{
		obj= [[mBatchMap objectAtRow:rowIndex atColumn:cSettingsIndex] objectForKey:@"dictionaryName"];
		if ( [obj isEqualToString:dLastValuesInPanel])
			return NSLocalizedStringFromTable(@"PanelSettings", 			@"batchLocalized", @"settings in panel");
		else
			return obj;
	}
	else if ( [identifier isEqualToString:@"status"])
	{
		switch ([mBatchMap intAtRow:rowIndex atColumn:cStatusIndex])
		{
			case cQueue: 			return NSLocalizedStringFromTable(@"Queue", 			@"batchLocalized", @"Batch queue"); 			break;
			case cRenderError: 	return NSLocalizedStringFromTable(@"RenderError", 	@"batchLocalized", @"Batch render error");	break;
			case cBatchError: 		return NSLocalizedStringFromTable(@"BatchError", 	@"batchLocalized", @"Batch error"); 				break;
			case cCancelled:		return NSLocalizedStringFromTable(@"Cancelled", 	@"batchLocalized", @"Batch cancelled");		break;
			case cDone: 				return NSLocalizedStringFromTable(@"Done", 			@"batchLocalized", @"Catch done"); 				break;
			case cUserAbort: 		return NSLocalizedStringFromTable(@"UserAbort", 	@"batchLocalized", @"Batch user abort"); 		break;
			case cUnknown: 		return NSLocalizedStringFromTable(@"Unknown", 		@"batchLocalized", @"Batch unknown"); 		break;
			case cRendering: 		return NSLocalizedStringFromTable(@"Rendering", 	@"batchLocalized", @"Batch rendering"); 		break;
			case cProcessing: 		return NSLocalizedStringFromTable(@"Processing", 	@"batchLocalized", @"Batch processing"); 		break;
		}
	}
	else if ( [identifier isEqualToString:@"comment"])
		return [mBatchMap objectAtRow:rowIndex atColumn:cCommentIndex];
	return nil;

}

//---------------------------------------------------------------------
// tableView:willDisplayCell:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView willDisplayCell:(id)aCell forTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
	id identifier=[aTableColumn identifier];
	if ( [identifier isEqualToString:@"status"])
	{
		if ( [mBatchMap intAtRow:rowIndex atColumn:cOnOffIndex] == NSOffState)
		{
			[aCell setTextColor:[NSColor disabledControlTextColor]];
			return;
		}
		switch ([mBatchMap intAtRow:rowIndex atColumn:cStatusIndex])
		{
			case cQueue: 			[aCell setTextColor:[NSColor blackColor]] ;		break;
			case cRenderError: 	[aCell setTextColor:[NSColor redColor]];			break;
			case cCancelled: 		[aCell setTextColor:[NSColor brownColor]];	break;
			case cBatchError: 		[aCell setTextColor:[NSColor redColor]]; 			break;
			case cDone: 				[aCell setTextColor:[NSColor blueColor]]; 			break;
			case cUserAbort: 		[aCell setTextColor:[NSColor greenColor]]; 		break;
			case cUnknown: 		[aCell setTextColor:[NSColor blackColor]]; 		break;
			case cRendering: 		[aCell setTextColor:[NSColor orangeColor]]; 		break;
			case cProcessing: 		[aCell setTextColor:[NSColor purpleColor]]; 		break;
		}
	}
	else if ( [identifier isEqualToString:@"onoff"]==NO)
	{
		if ( [mBatchMap intAtRow:rowIndex atColumn:cOnOffIndex] == NSOffState)
			[aCell setTextColor:[NSColor disabledControlTextColor]];
		else
			[aCell setTextColor:[NSColor blackColor]];

	}
}

//---------------------------------------------------------------------
// tableView:didClickTableColumn:row
//---------------------------------------------------------------------
- (void)      tableView: (NSTableView *) tableView    didClickTableColumn: (NSTableColumn *) tableColumn
{
	if (mLastTableColumn == tableColumn)
	{
		// User clicked same column, change sort order
		mSorteerOplopend = !mSorteerOplopend;
	}
	else
	{
		// User clicked new column, change old/new column headers,
		// save new sorting selector, and re-sort the array.
		mSorteerOplopend = NO;
		if (mLastTableColumn)
		{
			[mTableView setIndicatorImage: nil    inTableColumn: mLastTableColumn];
			[mLastTableColumn release];
		}

		mLastTableColumn = [tableColumn retain];

		[mTableView setHighlightedTableColumn: tableColumn];
	}
	[self batchSort];

	// Set the graphic for the new column header
	[mTableView setIndicatorImage: (mSorteerOplopend ?
																	[NSImage imageNamed:@"NSDescendingSortIndicator"] :
																	[NSImage imageNamed:@"NSAscendingSortIndicator"])
									inTableColumn: tableColumn];

	[mTableView reloadData];
}


//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"onoff"])
		[mBatchMap setObject:anObject atRow:rowIndex atColumn:cOnOffIndex];
	else if ( [identifier isEqualToString:@"comment"])
		[mBatchMap setObject:anObject atRow:rowIndex atColumn:cCommentIndex];
	[mTableView reloadData];		// redraw the table
}


/*********************************************/
/*  table view dragging data source methods  */
/*********************************************/
//---------------------------------------------------------------------
// tableView:writeRows:toPasteboard
//---------------------------------------------------------------------
//---------------------------------------------------------------------
- (BOOL)tableView: (NSTableView *)aTableView writeRowsWithIndexes: (NSIndexSet *)rowIndexes toPasteboard: (NSPasteboard *)pboard
{
	if ([rowIndexes count] > 1)	// don't allow dragging with more than one row
		return NO;
	mDraggedRow = [rowIndexes firstIndex];


	// the NSArray "rows" is actually an array of the indecies dragged

	// declare our dragged type in the paste board
	[pboard declareTypes: [NSArray arrayWithObjects: BatchItemDragType, nil] owner: self];
	[pboard setData: [mBatchMap archivedObjectAtIndex:mDraggedRow] forType: BatchItemDragType];

	return YES;
}

//---------------------------------------------------------------------
// tableView:validateDrop:proposedRow:proposedDropOperation
//---------------------------------------------------------------------
- (NSDragOperation)tableView: (NSTableView *)aTableView validateDrop: (id <NSDraggingInfo>)item
								 proposedRow: (NSInteger)row  proposedDropOperation: (NSTableViewDropOperation)op
{
	// means the drag operation can be desided by the destination
	return NSDragOperationGeneric;
}

//---------------------------------------------------------------------
// tableView:acceptDrop:row:dropOperation
//---------------------------------------------------------------------
// This method is called when the mouse is released over an outline view that previously decided to
//	allow a drop via the validateDrop method.  The data source should incorporate the data from the
//	dragging pasteboard at this time.
//---------------------------------------------------------------------
- (BOOL)tableView:(NSTableView*)aTableView acceptDrop: (id <NSDraggingInfo>)item
							row: (NSInteger)row dropOperation:(NSTableViewDropOperation)op
{
	NSPasteboard *pboard = [item draggingPasteboard];	// get the paste board
	NSData *data;
	if (row >= [mBatchMap count])
	{
		row = [mBatchMap count] - 1;
	}
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject: BatchItemDragType]])
		// test to see if the string for the type we defined in the paste board.
		// if doesn't, do nothing.
	{
		data = [pboard dataForType: BatchItemDragType];	// get the data from paste board

		[mBatchMap removeEntryAtIndex: mDraggedRow reload:NO];
		// remove the index that got dragged, now that we are accepting the dragging
		[mBatchMap insertArchivedObject: data atIndex: row];
		// insert the new data (same one that got dragger) into the array

		[mTableView reloadData];

	}
	else if ([pboard availableTypeFromArray:[NSArray arrayWithObject: NSFilenamesPboardType]])
	{
		NSArray *str = [pboard propertyListForType: NSFilenamesPboardType];	// get the data from paste board
		for (int x=0; x<[str count]; x++)
		{
			NSString *file=[str objectAtIndex:x];
			BOOL isDir;
			NSFileManager *manager = [NSFileManager defaultManager];
			if ([manager fileExistsAtPath:file isDirectory:&isDir] &&  isDir==NO)
				[mBatchMap insertEntryAtIndex:row file:file];
		}
	}
	[mTableView selectRowIndexes:[[[NSIndexSet alloc] initWithIndex:row]autorelease] byExtendingSelection: NO];	// select the row
	return YES;
}

static NSInteger compareBatchEntryUsingSelector(id p1, id p2, void *context)
{
	sortStruct *str=(sortStruct*)context;
	switch (str->type)
	{
		case cOnOffIndex:
			if ( str->sort )	//oplopend
			{
				if ([[p1 objectAtIndex:cOnOffIndex]intValue] < [[p2 objectAtIndex:cOnOffIndex]intValue])
					return NSOrderedAscending;
				else if( [[p1 objectAtIndex:cOnOffIndex]intValue] > [[p2 objectAtIndex:cOnOffIndex]intValue])
					return NSOrderedDescending;
				else
					return NSOrderedSame;
			}
			else
			{
				if ([[p2 objectAtIndex:cOnOffIndex]intValue] < [[p1 objectAtIndex:cOnOffIndex]intValue])
					return NSOrderedAscending;
				else if ( [[p2 objectAtIndex:cOnOffIndex]intValue] > [[p1 objectAtIndex:cOnOffIndex]intValue])
					return NSOrderedDescending;
				else
					return NSOrderedSame;
			}
			break;
		case cNameIndex:
			if ( str->sort )	//oplopend
				return [[[p2 objectAtIndex:cNameIndex]lastPathComponent] compare:[[p1 objectAtIndex:cNameIndex] lastPathComponent] options: NSCaseInsensitiveSearch];
			else
				return [[[p1 objectAtIndex:cNameIndex]lastPathComponent] compare: [[p2 objectAtIndex:cNameIndex] lastPathComponent] options: NSCaseInsensitiveSearch];
			break;
		case cStatusIndex:
			if ( str->sort )	//oplopend
			{
				if ([[p1 objectAtIndex:cStatusIndex]intValue] < [[p2 objectAtIndex:cStatusIndex]intValue])
					return NSOrderedAscending;
				else if( [[p1 objectAtIndex:cStatusIndex]intValue] > [[p2 objectAtIndex:cStatusIndex]intValue])
					return NSOrderedDescending;
				else
					return NSOrderedSame;
			}
			else
			{
				if ([[p2 objectAtIndex:cStatusIndex]intValue] < [[p1 objectAtIndex:cStatusIndex]intValue])
					return NSOrderedAscending;
				else if ( [[p2 objectAtIndex:cStatusIndex]intValue] > [[p1 objectAtIndex:cStatusIndex]intValue])
					return NSOrderedDescending;
				else
					return NSOrderedSame;
			}
			break;
		case cCommentIndex:
			if ( str->sort )	//oplopend
				return [[[p2 objectAtIndex:cCommentIndex]lastPathComponent] compare:[[p1 objectAtIndex:cCommentIndex] lastPathComponent] options: NSCaseInsensitiveSearch];
			else
				return [[[p1 objectAtIndex:cCommentIndex]lastPathComponent] compare: [[p2 objectAtIndex:cCommentIndex] lastPathComponent] options: NSCaseInsensitiveSearch];
			break;

	}
	return NSOrderedSame;

}

@end
