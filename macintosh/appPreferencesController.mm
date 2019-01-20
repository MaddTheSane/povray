//******************************************************************************
///
/// @file /macintosh/appPreferencesController.mm
///
/// appPreferencesController is the application preferences dialog
/// the place to set the path for include files, editor settings,...
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
#import "maincontroller.h"

#import "appPreferencesController.h"
#import "sceneDocument+highlighting.h"
#import "toolTipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

#define IncludePathDragType @"icdrt"
static appPreferencesController	*_appPreferencesController;

@implementation appPreferencesController
//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
- (IBAction)applicationPreferences:(id)sender
{
	[mApplicationPreferencesWindow makeKeyAndOrderFront: nil];
}
//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{

	NSMutableDictionary *initialDefaults=
	[NSMutableDictionary dictionaryWithObjectsAndKeys:
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0/255.0 		green:0.0/255.0 		blue:194.0/255.0	alpha:1.0]], @"identifierColor",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:196.0/255.0 	green:0.0/255.0 		blue:0.0/255.0		alpha:1.0]], @"multiLineCommentColor",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:255.0/255.0 	green:0.0/255.0 		blue:128.0/255.0	alpha:1.0]], @"oneLineCommentColor",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:190.0/255.0 	green:132.0/255.0 	blue:74.0/255.0	alpha:1.0]], @"preprocessorColor",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:0.0/255.0 		green:163.0/255.0 	blue:0.0/255.0		alpha:1.0]], @"stringColor",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:143.0/255.0 	green:41.0/255.0 		blue:158.0/255.0	alpha:1.0]], @"macroKleur",
	 [NSArchiver archivedDataWithRootObject:[NSColor colorWithCalibratedRed:255.0/255.0 	green:94.0/255.0 		blue:10.0/255.0	alpha:1.0]], @"declareColor",
	 [NSArchiver archivedDataWithRootObject:[NSFont userFontOfSize:11.0]], @"sceneDocumentFont",
	 @"1.8",															@"mOutletDisplayGammaEdit",
	 @YES,	@"globalAutoSyntaxColoring",
	 [NSNumber numberWithInt:NSOnState],	@"maintainIndentation",
	 [NSNumber numberWithInt:NSOnState],	@"autoIndentBraces",
	 [NSNumber numberWithInt:NSOffState],	@"rememberOpenWindowsOn",
	 [NSNumber numberWithInt:0],					@"numericBlockPoint",
	 [NSNumber numberWithInt:2],					@"tabDistance",
	 [NSNumber numberWithInt:1],					@"indexOfAppPrefsSelectedTabViewItem",
	 @"",																	@"mInsertMenuMainDirectoryEdit",
	 [NSNumber numberWithFloat:100.0],		@"mInsertMenuImageScaleSlider",
	 @10,					@"NSRecentDocumentsLimit",
	 @NO,	@"AlwaysPutPreviewwindowInFrontButton",
	 @NO,	@"OnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton",
	 nil];
	[[NSUserDefaults standardUserDefaults] registerDefaults:initialDefaults];
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self=_appPreferencesController=[super init];
	return self;
}

//---------------------------------------------------------------------
// scaleFactor
//---------------------------------------------------------------------
-(float) scaleFactor
{
	return [mInsertMenuImageScaleFloat floatValue];
}

//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (appPreferencesController*)sharedInstance
{
	return _appPreferencesController;
}

//--------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self  setIncludePathArray:nil];

	[mPreprocessorColor release];					mPreprocessorColor=nil;
	[mMultiLineCommentColor release];			mMultiLineCommentColor=nil;
	[mOneLineCommentColor release];				mOneLineCommentColor=nil;
	[mStringColor release];								mStringColor=nil;
	[mInsertDirectory release];						mInsertDirectory=nil;
	[mInsertMenuImageScaleFloat release]; mInsertMenuImageScaleFloat=nil;
	[mIdentifierColor release];						mIdentifierColor=nil;
	[mMacroColor release];								mMacroColor=nil;
	[mDeclareColor release];							mDeclareColor=nil;
	[mBlackStyleDict release];						mBlackStyleDict=nil;
	[mKeyWordStyleDict release];					mKeyWordStyleDict=nil;
	[mPreprocessorStyleDict release];			mPreprocessorStyleDict=nil;
	[mMultiLineCommentStyleDict release];	mMultiLineCommentStyleDict=nil;
	[mOneLineCommentStyleDict release];		mOneLineCommentStyleDict=nil;
	[mStringStyleDict release];						mStringStyleDict=nil;
	[mMacroStyleDict release];						mMacroStyleDict=nil;
	[mDeclareStyleDict release];					mDeclareStyleDict=nil;
	[mModifiedFlag release];
	[super dealloc];
}

//--------------------------------------------------------------------
// setIncludePathArray
//---------------------------------------------------------------------
-(void) setIncludePathArray:(id) pathsArray
{
	[mIncludePathsArray release];
	mIncludePathsArray=pathsArray;
	[mIncludePathsArray retain];
}

//--------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
//	Read the array with settings and move the settings from the
//	last run in the panel
//---------------------------------------------------------------------
- (void) awakeFromNib
{
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[ToolTipAutomator setTooltips:		@"apppreferencesLocalized" andDictionary:
	 [NSDictionary dictionaryWithObjectsAndKeys:
			mSyntaxColorOn,												@"syntaxColorOn",
			mPreprocessorColorWell,								@"preprocessorColorWell",
			mMultiLineCommentColorWell,						@"multiLineCommentColorWell",
			mOneLineCommentColorWell,							@"oneLineCommentColorWell",
			mStringColorWell,											@"stringColorWell",
			mIdentifierColorWell,									@"identifierColorWell",
			mMacroColorWell,											@"macroColorWell",
			mDeclaresColorWell,										@"declaresColorWell",
			mTabSize,															@"tabSize",
			mPointMatrix,													@"pointMatrix",
			mInsertMenuMainDirectoryEdit,					@"mInsertMenuMainDirectoryEdit",
			mInsertMenuImageScaleSlider,					@"mInsertMenuImageScaleSlider",
			mIncludePathTableView,								@"includePathTableView",
			mIncludePathDeleteButton,							@"includePathDeleteButton",
			mIncludePathChangeButton,							@"includePathChangeButton",
			mIncludePathAddButton,								@"includePathAddButton",
			mCancelButton,												@"cancel",
			mApplyButton,													@"apply",
			mOkButton,														@"ok",
			mMaintainIndentationOn,								@"maintainIndentationOn",
			mAutoIndentBracesOn,									@"autoIndentBracesOn",
			mSelectedFont,												@"selectedFont",
			mOutletDisplayGammaEdit,							@"mOutletDisplayGammaEdit",
			mDisplayGammaButton,									@"displayGammaButton",
			mAlwaysPutPreviewwindowInFrontButton,		@"AlwaysPutPreviewwindowInFrontButton",
			mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton,	@"OnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton",
		//extra:
			mSelectFontButton,										@"mSelectFontButton",
			mSelectInsertMenuMainDirectoryButton,	@"mSelectInsertMenuMainDirectoryButton",
			nil]
	 ];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(selectionIncludePathTableViewChanged:)
		name:NSTableViewSelectionDidChangeNotification
		object:mIncludePathTableView];

	[mTabSize setDelegate:self];	// we need to know when changed

	mInsertDirectory=[defaults objectForKey:@"mInsertMenuMainDirectoryEdit"];
	[mInsertDirectory retain];
	[mInsertMenuMainDirectoryEdit setStringValue:mInsertDirectory];
	[mInsertMenuMainDirectoryEdit setToolTip:mInsertDirectory];
	mInsertMenuImageScaleFloat=[defaults objectForKey:@"mInsertMenuImageScaleSlider"];
	[mInsertMenuImageScaleFloat retain];
	[mInsertMenuImageScaleSlider setFloatValue:[mInsertMenuImageScaleFloat floatValue]];

	[self setIncludePathArray:[[[defaults objectForKey:@"includePaths"]mutableCopy]autorelease]];
	if (mIncludePathsArray==nil)
		[self setIncludePathArray:[[[NSMutableArray alloc]init]autorelease]];
	[mApplicationPreferencesWindow setDelegate:self];

	[mIncludePathTableView reloadData];
	[mTabView selectTabViewItemAtIndex:[[defaults objectForKey:@"indexOfAppPrefsSelectedTabViewItem"]intValue]];

	mPreprocessorColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"preprocessorColor"]];
	[mPreprocessorColor retain];
	mMultiLineCommentColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"multiLineCommentColor"]];
	[mMultiLineCommentColor retain];
	mOneLineCommentColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"oneLineCommentColor"]];
	[mOneLineCommentColor retain];
	mStringColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"stringColor"]];
	[mStringColor retain];
	mIdentifierColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"identifierColor"]];
	[mIdentifierColor retain];

	mDeclareColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"declareColor"]];
	[mDeclareColor retain];
	mMacroColor=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"macroKleur"]];
	[mMacroColor retain];

	// auto syntax coloring
	globalAutoSyntaxColoring=[[defaults objectForKey:@"globalAutoSyntaxColoring"]boolValue];

	// display gamma
	mDisplayGammaString=[defaults objectForKey:@"mOutletDisplayGammaEdit"];
	[mDisplayGammaString retain];
	[mOutletDisplayGammaEdit setStringValue:mInsertDirectory];

	mDisplayGammaOn=[[defaults objectForKey:@"displayGammaOn"]intValue];
	[mDisplayGammaButton setState:mDisplayGammaOn];
	enableObjectsAccordingToObject( mDisplayGammaButton, mOutletDisplayGammaEdit,nil);

	// preview window to front
	mAlwaysPutPreviewwindowInFrontOn=[[defaults objectForKey:@"mAlwaysPutPreviewwindowInFrontButton"]intValue];
	mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn=[[defaults objectForKey:@"OnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton"]intValue];
	[mAlwaysPutPreviewwindowInFrontButton setIntegerValue:mAlwaysPutPreviewwindowInFrontOn];
	[mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton setState:mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn];
	enableObjectsAccordingToObject( mAlwaysPutPreviewwindowInFrontButton, mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton,nil);


	//	SetSubViewsOfNSBoxToState(mSyntaxColorGroupBox, globalAutoSyntaxColoring);

	rememberOpenWindowsOn=[[defaults objectForKey:@"rememberOpenWindowsOn"] intValue];
	[mRememberOpenWindowsButton setState:rememberOpenWindowsOn];


	maintainIndentation=[[defaults objectForKey:@"maintainIndentation"]intValue];
	[mMaintainIndentationOn setState:maintainIndentation];
	autoIndentBraces=[[defaults objectForKey:@"autoIndentBraces"]intValue];
	[mAutoIndentBracesOn setState:autoIndentBraces];
	enableObjectsAccordingToObject(mMaintainIndentationOn,mAutoIndentBracesOn,nil);

	tabDistance=[[defaults objectForKey:@"tabDistance"]intValue];
	[mTabSize setIntValue:tabDistance];
	numericBlockPoint=[[defaults objectForKey:@"numericBlockPoint"]intValue];
	[mPointMatrix selectCellWithTag:numericBlockPoint];

	mSceneDocumentFont=[NSUnarchiver unarchiveObjectWithData:[defaults objectForKey:@"sceneDocumentFont"]];
	[mSceneDocumentFont retain];


	[self buildSyntaxStyles];
	[mSelectedFont setFont:mSceneDocumentFont];
	[mSelectedFont setStringValue:[NSString stringWithFormat:@"%@ Size:%d",[mSceneDocumentFont displayName], (int)[mSceneDocumentFont pointSize]]];
	[self setModified:NO];
	[self cancelButton:nil];	//move our settings in the panel
	[self setAddChangeRemoveButtons];

	// register for drag action, using the drag type we defined
	[mIncludePathTableView registerForDraggedTypes: [NSArray arrayWithObjects: IncludePathDragType, NSFilenamesPboardType,nil]];

}

//---------------------------------------------------------------------
// buildTabStops
//---------------------------------------------------------------------
-(void) buildDefaultParagraphStyle
{
	NSDictionary *tempStyle=[NSDictionary dictionaryWithObject:mSceneDocumentFont forKey:NSFontAttributeName];
	NSAttributedString *title = [[[NSAttributedString alloc]       initWithString:@"m" attributes:tempStyle]autorelease];

	float fontWidth=[title size].width;
	fontWidth*=(float)tabDistance;
	[mDefaultParagraphStyle release];
	mDefaultParagraphStyle	= [[NSParagraphStyle defaultParagraphStyle]mutableCopy];

	NSMutableArray *newArray=[[[NSMutableArray alloc]init]autorelease];
	for (int x=1; x<20; x++)
		[newArray addObject:[[[NSTextTab alloc] initWithType:NSLeftTabStopType location:x*fontWidth]autorelease]];
	[mDefaultParagraphStyle setTabStops:newArray];
}

//--------------------------------------------------------------------
// buildSyntaxStyles
//---------------------------------------------------------------------
//	build all the styles we need for syntax coloring
//---------------------------------------------------------------------
-(void) buildSyntaxStyles
{
	[mBlackStyleDict release];
	[mKeyWordStyleDict release];
	[mPreprocessorStyleDict release];
	[mMultiLineCommentStyleDict release];
	[mOneLineCommentStyleDict release];
	[mStringStyleDict release];
	[mMacroStyleDict release];
	[mDeclareStyleDict release];
	[self buildDefaultParagraphStyle];

	mBlackStyleDict = [[NSDictionary dictionaryWithObjectsAndKeys:
											mSceneDocumentFont, NSFontAttributeName,
											mDefaultParagraphStyle, NSParagraphStyleAttributeName,
											[NSColor blackColor], NSForegroundColorAttributeName,
											noneCommentAttribute,allExceptCommentAndStringAttribute,
											nil]retain];

	mKeyWordStyleDict = [[NSDictionary dictionaryWithObjectsAndKeys:
												mSceneDocumentFont, NSFontAttributeName,
												mDefaultParagraphStyle, NSParagraphStyleAttributeName,
												mIdentifierColor, NSForegroundColorAttributeName,
												noneCommentAttribute,allExceptCommentAndStringAttribute,
												nil] retain];

	mPreprocessorStyleDict =[ [NSDictionary dictionaryWithObjectsAndKeys:
														 mSceneDocumentFont, NSFontAttributeName,
														 mDefaultParagraphStyle, NSParagraphStyleAttributeName,
														 mPreprocessorColor, NSForegroundColorAttributeName,
														 noneCommentAttribute,allExceptCommentAndStringAttribute,
														 nil] retain];

	mMultiLineCommentStyleDict=[[NSDictionary dictionaryWithObjectsAndKeys:
															 mSceneDocumentFont, NSFontAttributeName,
															 mDefaultParagraphStyle, NSParagraphStyleAttributeName,
															 mMultiLineCommentColor, NSForegroundColorAttributeName,
															 commentAttribute, commentAndStringAttributeName,
															 nil]retain];

	mOneLineCommentStyleDict=[[NSDictionary dictionaryWithObjectsAndKeys:
														 mSceneDocumentFont, NSFontAttributeName,
														 mDefaultParagraphStyle, NSParagraphStyleAttributeName,
														 mOneLineCommentColor, NSForegroundColorAttributeName,
														 commentAttribute, commentAndStringAttributeName,
														 nil]retain];

	mStringStyleDict=[[NSDictionary dictionaryWithObjectsAndKeys:
										 mSceneDocumentFont, NSFontAttributeName,
										 mDefaultParagraphStyle, NSParagraphStyleAttributeName,
										 mStringColor, NSForegroundColorAttributeName,
										 commentAttribute, commentAndStringAttributeName,
										 nil]retain];

	mMacroStyleDict=[[NSDictionary dictionaryWithObjectsAndKeys:
										mSceneDocumentFont, NSFontAttributeName,
										mDefaultParagraphStyle, NSParagraphStyleAttributeName,
										mMacroColor, NSForegroundColorAttributeName,
										noneCommentAttribute,allExceptCommentAndStringAttribute,
										nil]retain];

	mDeclareStyleDict=[[NSDictionary dictionaryWithObjectsAndKeys:
											mSceneDocumentFont, NSFontAttributeName,
											mDefaultParagraphStyle, NSParagraphStyleAttributeName,
											mDeclareColor, NSForegroundColorAttributeName,
											noneCommentAttribute,allExceptCommentAndStringAttribute,
											nil]retain];
}

//---------------------------------------------------------------------
// tabView
//---------------------------------------------------------------------
// delegate for tabView to keep track of the selected tab
//---------------------------------------------------------------------
- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	NSNumber *IndexOfSelectedTabViewItem=[NSNumber numberWithInt:[tabView indexOfTabViewItem:tabViewItem]];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults setObject:IndexOfSelectedTabViewItem forKey:@"indexOfAppPrefsSelectedTabViewItem"];
}

//---------------------------------------------------------------------
// changeFont
//---------------------------------------------------------------------
-(IBAction) selectFont:(id) sender
{
	NSFontPanel *fp=[NSFontPanel sharedFontPanel];
	if ( fp)
	{
		[fp makeKeyAndOrderFront: nil];
		[fp setDelegate:self];
	}
}

//---------------------------------------------------------------------
// selectInsertMenuMainDirectoryButton
//---------------------------------------------------------------------
- (IBAction)selectInsertMenuMainDirectoryButton:(id)sender
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setDirectoryURL:nil];
 [openPanel beginSheetModalForWindow:mApplicationPreferencesWindow
									 completionHandler: ^( NSInteger resultCode )
	{
		@autoreleasepool
		{
			if( resultCode ==NSOKButton )
			{
				NSURL *url = [openPanel URL];
				if( url )
				{
					// Get the directory from the open panel
					[mInsertMenuMainDirectoryEdit setStringValue: [url path]];
					[mInsertMenuMainDirectoryEdit setToolTip:[url path]];
					[self setModified:YES];
				} // if
			} // if
		}
	}
	];
}

//---------------------------------------------------------------------
// changeFont
//---------------------------------------------------------------------
-(void)changeFont:(id)sender
{
	NSFont *oldFont = [mSelectedFont font];
	NSFont *newFont = [sender convertFont:oldFont];
	[mSelectedFont setFont:newFont];
	[mSelectedFont setStringValue:[NSString stringWithFormat:@"%@ Size:%d",[newFont displayName], (int)[newFont pointSize]]];
	[self setModified:YES];
}


//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
-(IBAction) applyButton:(id) sender
{
	[self storeNewAppPreferences];
	[[MainController sharedInstance]reloadTemplateInsertMenu];
	//apply the new style to all documents

	NSDocumentController *ctrl=[NSDocumentController sharedDocumentController];
	if ( ctrl)
	{
		NSArray *documentsArray=[ctrl documents];
		NSEnumerator *en=[documentsArray objectEnumerator];
		SceneDocument *object;
		while ( (object =[en nextObject] )!= nil)
		{
			[object recolorCompleteAttributedString:nil sender:nil];
		}
	}
	if ( sender != mOkButton)
		[self deactivateColorWells];
	[self setModified:NO];

}

//---------------------------------------------------------------------
// deactivateColorWells
//---------------------------------------------------------------------
-(void) deactivateColorWells
{
	[mPreprocessorColorWell deactivate];
	[mMultiLineCommentColorWell deactivate];
	[mOneLineCommentColorWell deactivate];
	[mStringColorWell  deactivate];
	[mIdentifierColorWell deactivate];
	[mDeclaresColorWell deactivate];
	[mMacroColorWell deactivate];
	[[NSColorPanel sharedColorPanel] close];
}

//---------------------------------------------------------------------
// maintainIndentation
//---------------------------------------------------------------------
-(IBAction) appPreferencesButton:(id) sender
{
	if ( [sender tag]==cMaintainIndentaion)
		enableObjectsAccordingToObject(mMaintainIndentationOn,mAutoIndentBracesOn,nil);

	[self setModified:YES];

}

//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
-(IBAction) cancelButton:(id) sender
{
	[mPreprocessorColorWell setColor:mPreprocessorColor];
	[mMultiLineCommentColorWell setColor:mMultiLineCommentColor];
	[mOneLineCommentColorWell setColor:mOneLineCommentColor];
	[mInsertMenuMainDirectoryEdit setStringValue:mInsertDirectory];
	[mInsertMenuMainDirectoryEdit setToolTip:mInsertDirectory];
	[mInsertMenuImageScaleSlider setFloatValue:[mInsertMenuImageScaleFloat floatValue]];
	[mStringColorWell setColor:mStringColor];
	[mIdentifierColorWell setColor:mIdentifierColor];
	[mDeclaresColorWell setColor:mDeclareColor];
	[mMacroColorWell setColor:mMacroColor];
	[mSelectedFont setFont:mSceneDocumentFont];
	[mSyntaxColorOn setState:globalAutoSyntaxColoring ? NSOnState : NSOffState];
	[mOutletDisplayGammaEdit setStringValue:mDisplayGammaString];
	[mDisplayGammaButton setState:mDisplayGammaOn];
	[mAlwaysPutPreviewwindowInFrontButton setState:mAlwaysPutPreviewwindowInFrontOn];
	[mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton setState:mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn];
	[mMaintainIndentationOn setState:maintainIndentation];
	[mAutoIndentBracesOn setState:autoIndentBraces];
 enableObjectsAccordingToObject( mDisplayGammaButton, mOutletDisplayGammaEdit,nil);
	[mTabSize setIntValue:tabDistance];

	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[self setIncludePathArray:[[[defaults objectForKey:@"includePaths"]mutableCopy]autorelease]];
	if (mIncludePathsArray==nil)
		[self setIncludePathArray:[[[NSMutableArray alloc]init]autorelease]];
	[mIncludePathTableView noteNumberOfRowsChanged];

	[self deactivateColorWells];
	[self setModified:NO];
	[mApplicationPreferencesWindow close];
}

//---------------------------------------------------------------------
// style:(NSUInteger)type
//---------------------------------------------------------------------
-(NSDictionary*) style:(textStyles)type
{
	switch(type)
	{
		case cBlackStyle:							return mBlackStyleDict;							break;
		case cKeywordStyle:						return mKeyWordStyleDict;						break;
		case cPreprocessorStyle:			return mPreprocessorStyleDict;			break;
		case cMultilineCommentStyle:	return mMultiLineCommentStyleDict;	break;
		case cOnelineCommentStyle:		return mOneLineCommentStyleDict;		break;
		case cStringStyle:						return mStringStyleDict;						break;
		case cMacroStyle:							return mMacroStyleDict;							break;
		case cDeclareStyle:						return mDeclareStyleDict;						break;
		default:											return mBlackStyleDict;
	}
}

//---------------------------------------------------------------------
// closeWindowAlertSheetDidEnd
//---------------------------------------------------------------------
- (void) closeWindowAlertSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:nil];
	if ( returnCode ==NSAlertDefaultReturn)	//ok
	{
		[self applyButton:nil];
		[mApplicationPreferencesWindow close];
	}

	else if ( returnCode==NSAlertOtherReturn)	//cancel (dont save and don't close window
		[self cancelButton:self];
}
//---------------------------------------------------------------------
// windowShouldClose (delegate)
//---------------------------------------------------------------------
- (BOOL)windowShouldClose:(id)sender
{
	if ( [self isModified])
	{
		NSBeginAlertSheet( @"Really close", @"Save", @"Cancel", @"Don't Save",
											mApplicationPreferencesWindow, self,
											@selector(closeWindowAlertSheetDidEnd:returnCode:contextInfo:),
											nil,
											nil,
											@"There are unsaved changes.\nDo you wich to save them?",
											nil);

	}
	else
		return YES;
	return NO;

}

//---------------------------------------------------------------------
// setModified
//---------------------------------------------------------------------
-(void) setModified:(BOOL)flag
{
	[mModifiedFlag release];
	mModifiedFlag=[[NSNumber numberWithBool:flag]retain];
	if ( flag==YES)

		[mApplyButton setEnabled:YES];
	else
		[mApplyButton setEnabled:NO];
	[mApplicationPreferencesWindow setDocumentEdited:flag];
}


//---------------------------------------------------------------------
// isModified
//---------------------------------------------------------------------
-(BOOL) isModified;
{
	return [mModifiedFlag boolValue];
}

//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
-(IBAction) okButton:(id) sender
{
	if ( [self isModified])
		[self applyButton:nil];
	[self deactivateColorWells];

	[mApplicationPreferencesWindow close];
}

//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
-(IBAction) colorChanged:(id) sender
{
	[self setModified:YES];
}

//---------------------------------------------------------------------
// RememberOpenWindowsButton
//---------------------------------------------------------------------
- (IBAction)rememberOpenWindowsButton:(id)sender
{

	[self setModified:YES];
}

//---------------------------------------------------------------------
// AlwaysPutPreviewwindowInFrontButton
//---------------------------------------------------------------------
- (IBAction)AlwaysPutPreviewwindowInFrontButton:(id)sender
{
	switch ([sender tag])
	{
		case 		AllwaysInFront:
			enableObjectsAccordingToObject( mAlwaysPutPreviewwindowInFrontButton, mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton,nil);
			break;
	}
	[self setModified:YES];
}

//---------------------------------------------------------------------
// storeNewAppPreferences
//---------------------------------------------------------------------
-(void) storeNewAppPreferences
{
	[mSceneDocumentFont release];
	mSceneDocumentFont=[[mSelectedFont font]retain];
	[mPreprocessorColor release];
	mPreprocessorColor=[[mPreprocessorColorWell color]retain];

	[mMultiLineCommentColor release];
	mMultiLineCommentColor=[[mMultiLineCommentColorWell color]copy];

	[mOneLineCommentColor release];
	mOneLineCommentColor=[[mOneLineCommentColorWell color]copy];

	[mStringColor release];
	mStringColor=[[mStringColorWell color]copy];

	[mInsertDirectory release];
	mInsertDirectory=[[mInsertMenuMainDirectoryEdit stringValue]copy];

	[mInsertMenuImageScaleFloat release];
	mInsertMenuImageScaleFloat=[[NSNumber numberWithFloat:[mInsertMenuImageScaleSlider floatValue]]retain];

	[mIdentifierColor release];
	mIdentifierColor=[[mIdentifierColorWell color]copy];

	[mDeclareColor release];
	mDeclareColor=[[mDeclaresColorWell color]copy];

	[mMacroColor release];
	mMacroColor=[[mMacroColorWell color]copy];

	globalAutoSyntaxColoring=[mSyntaxColorOn state] == NSOnState;
	[mDisplayGammaString release];
	mDisplayGammaString=[[mOutletDisplayGammaEdit stringValue]copy];
	mDisplayGammaOn=[mDisplayGammaButton state];
	mAlwaysPutPreviewwindowInFrontOn=[mAlwaysPutPreviewwindowInFrontButton state];
	mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn=[mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton state];

	rememberOpenWindowsOn=[mRememberOpenWindowsButton state];
	maintainIndentation=[mMaintainIndentationOn state];
	autoIndentBraces=[mAutoIndentBracesOn state];
	tabDistance=[mTabSize intValue];
	numericBlockPoint=[[mPointMatrix selectedCell] tag];

	[self buildSyntaxStyles];
	//	[self buildDefaultParagraphStyle];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mPreprocessorColor]forKey: @"preprocessorColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mMultiLineCommentColor]forKey: @"multiLineCommentColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mOneLineCommentColor]forKey: @"oneLineCommentColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mStringColor]forKey: @"stringColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mIdentifierColor]forKey: @"identifierColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mMacroColor]forKey: @"macroKleur"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mDeclareColor]forKey: @"declareColor"];
	[defaults setObject:[NSArchiver archivedDataWithRootObject:mSceneDocumentFont]forKey: @"sceneDocumentFont"];
	[defaults setInteger:globalAutoSyntaxColoring forKey: @"globalAutoSyntaxColoring"];
	[defaults setObject:mDisplayGammaString forKey: @"mOutletDisplayGammaEdit"];
	[defaults setInteger:mDisplayGammaOn forKey: @"displayGammaOn"];
	[defaults setInteger:mAlwaysPutPreviewwindowInFrontOn forKey: @"AlwaysPutPreviewwindowInFrontButton"];
	[defaults setInteger:mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn forKey: @"OnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton"];


	[defaults setInteger:rememberOpenWindowsOn forKey: @"rememberOpenWindowsOn"];
	[defaults setInteger:maintainIndentation forKey: @"maintainIndentation"];
	[defaults setInteger:autoIndentBraces forKey: @"autoIndentBraces"];
	[defaults setInteger:tabDistance forKey: @"tabDistance"];
	[defaults setInteger:numericBlockPoint forKey: @"numericBlockPoint"];
	[defaults setObject:mIncludePathsArray forKey: @"includePaths"];
	[defaults setObject:mInsertDirectory forKey: @"mInsertMenuMainDirectoryEdit"];
	[defaults setObject:mInsertMenuImageScaleFloat forKey: @"mInsertMenuImageScaleSlider"];

	[self setModified:NO];
}

//---------------------------------------------------------------------
// appPreferencesTarget
//---------------------------------------------------------------------
-(IBAction) appPreferencesTarget: (id) sender
{
	NSInteger tag=[sender tag];
	switch( tag)
	{
		case cAppRenderBlockSizePopup:
			[self setModified:YES];
			break;
	}
}


//---------------------------------------------------------------------
// syntaxColorOn
//---------------------------------------------------------------------
-(IBAction) syntaxColorOn:(id) sender
{
	//	SetSubViewsOfNSBoxToState(mSyntaxColorGroupBox, [sender state]);
	[self setModified:YES];
}


//---------------------------------------------------------------------
// tabSize
//---------------------------------------------------------------------
-(IBAction) tabSize:(id) sender
{
	[self setModified:YES];
}

//---------------------------------------------------------------------
// tabSize
//---------------------------------------------------------------------
-(IBAction) insertMenuImageSizeSlider:(id) sender
{
	//	NSLog(@"slider: %f", [sender floatValue]);
	[self setModified:YES];
}
//---------------------------------------------------------------------
// displayGammaButton
//---------------------------------------------------------------------
-(IBAction)displayGammaButton:(id)sender
{
	enableObjectsAccordingToObject( mDisplayGammaButton, mOutletDisplayGammaEdit,nil);
	[self setModified:YES];
}

//---------------------------------------------------------------------
// controlTextDidChange
//---------------------------------------------------------------------
- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[self setModified:YES];
}


//---------------------------------------------------------------------
// pointMatrix
//---------------------------------------------------------------------
-(IBAction) pointMatrix:(id) sender
{
	[self setModified:YES];

}

//---------------------------------------------------------------------
// applicationPreferences
//---------------------------------------------------------------------
-(IBAction) includePathDeleteButton:(id) sender
{
	[mIncludePathsArray removeObjectAtIndex:[mIncludePathTableView selectedRow]];
	[self setModified:YES];
	[mIncludePathTableView noteNumberOfRowsChanged];

}


//---------------------------------------------------------------------
// includePathChangeButton
//---------------------------------------------------------------------
-(IBAction) includePathChangeButton:(id) sender
{
	mSelectedRowForChangePath = [mIncludePathTableView selectedRow];
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setDirectoryURL:nil];
	[openPanel beginSheetModalForWindow:mApplicationPreferencesWindow
										completionHandler: ^( NSInteger resultCode )
	 {
			@autoreleasepool
			{
				if( resultCode ==NSOKButton )
				{
					NSURL *url = [openPanel URL];
					if( url )
					{
						[mIncludePathsArray replaceObjectAtIndex:mSelectedRowForChangePath withObject:[url path]];
						[mIncludePathTableView reloadData];
						[self setModified:YES];
					} // if
				} // if
			}
	 }
  ];
}


//---------------------------------------------------------------------
// includePathAddButton
//---------------------------------------------------------------------
-(IBAction) includePathAddButton:(id) sender
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:YES];
	[openPanel setCanChooseFiles:NO];
	[openPanel setDirectoryURL:nil];
	[openPanel beginSheetModalForWindow:mApplicationPreferencesWindow
										completionHandler: ^( NSInteger resultCode )
	 {
			@autoreleasepool
			{
				if( resultCode ==NSOKButton )
				{
					NSURL *url = [openPanel URL];
					if( url )
					{
						[mIncludePathsArray addObject:[url path]];
						[mIncludePathTableView noteNumberOfRowsChanged];
						[self setModified:YES];
					} // if
				} // if
			}
	 }
  ];
}

//---------------------------------------------------------------------
// setAddChangeRemoveButtons
//---------------------------------------------------------------------
-(void) setAddChangeRemoveButtons
{
	int enabledState=NO;
	if(	[mIncludePathTableView numberOfSelectedRows] >0)
	{
		enabledState=YES;
	}
	[mIncludePathDeleteButton setEnabled:enabledState];
	[mIncludePathChangeButton setEnabled:enabledState];
	[mIncludePathDeleteButton setEnabled:enabledState];
}

//---------------------------------------------------------------------
// selectionIncludePathTableViewChanged
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
-(void) selectionIncludePathTableViewChanged:(NSNotification *) notification
{
	[self setAddChangeRemoveButtons];
}

// datasource
//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return [mIncludePathsArray count];
}
//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	return [mIncludePathsArray objectAtIndex:row];
}

/*********************************************/
/*  table view dragging data source methods  */
/*********************************************/
//---------------------------------------------------------------------
// tableView:writeRows:toPasteboard
//---------------------------------------------------------------------
// This method is called after it has been determined that a drag should begin, but before the drag has 0
//	been started.
//	To refuse the drag, return NO.
//	To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).
//	The drag image and other drag related information will be set up and provided by the table view once
//	this call returns with YES.  The rows array is the list of row numbers that will be participating in the drag.
//---------------------------------------------------------------------
- (BOOL)tableView: (NSTableView *)aTableView writeRowsWithIndexes: (NSIndexSet *)rowIndexes toPasteboard: (NSPasteboard *)pboard
{
	if ([rowIndexes count] > 1)	// don't allow dragging with more than one row
		return NO;
	mDraggedRow = [rowIndexes firstIndex];
	// the NSArray "rows" is actually an array of the indecies dragged

	// declare our dragged type in the paste board
	[pboard declareTypes: [NSArray arrayWithObjects: IncludePathDragType, nil] owner: self];
	[pboard setData: [NSArchiver archivedDataWithRootObject:[mIncludePathsArray objectAtIndex:mDraggedRow]] forType: IncludePathDragType];

	return YES;
}

//---------------------------------------------------------------------
// tableView:validateDrop:proposedRow:proposedDropOperation
//---------------------------------------------------------------------
// This method is used by NSTableView to determine a valid drop target.  Based on the mouse position,
//	the table view will suggest a proposed drop location.
//	This method must return a value that indicates which dragging operation the data source will perform.
//	The data source may "re-target" a drop if desired by calling setDropRow:dropOperation: and returning
//	something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for
//	better visual feedback when inserting into a sorted position).
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
	//    NSLog(@"droprow: %d",row);
	if ([pboard availableTypeFromArray:[NSArray arrayWithObject: IncludePathDragType]])
		// test to see if the string for the type we defined in the paste board.
		// if doesn't, do nothing.
	{
		data = [pboard dataForType: IncludePathDragType];	// get the data from paste board
  //      NSLog(@"removing dragged row: %ld",mDraggedRow);
		[mIncludePathsArray removeObjectAtIndex: mDraggedRow];
		// remove the index that got dragged, now that we are accepting the dragging
		if ([mIncludePathsArray count] > 1 && [mIncludePathsArray count]-1 >=row)
			[mIncludePathsArray insertObject: [NSUnarchiver unarchiveObjectWithData:data] atIndex: row];
		else
			[mIncludePathsArray addObject:[NSUnarchiver unarchiveObjectWithData:data]];

		// insert the new data (same one that got dragger) into the array

		[mIncludePathTableView reloadData];

	}
	else if ([pboard availableTypeFromArray:[NSArray arrayWithObject: NSFilenamesPboardType]])
	{
		NSArray *str = [pboard propertyListForType: NSFilenamesPboardType];	// get the data from paste board
		for (int x=0; x<[str count]; x++)
		{
			NSString *file=[str objectAtIndex:x];
			BOOL isDir;
			NSFileManager *manager = [NSFileManager defaultManager];
			if ([manager fileExistsAtPath:file isDirectory:&isDir] &&  isDir==YES)
			{
				BOOL pathExists= NO;		// path not alreay in table
				NSInteger cn=[mIncludePathsArray count]; // if it already exists don't add it again
				if (cn)
				{
					for (int x=0; x<cn; x++)
					{
						if ( [[mIncludePathsArray objectAtIndex:x ] isEqualToString:file])
						{
							pathExists =YES;
							break;
						}
					}
				}
				if (pathExists==NO)
				{
					if ( row == [mIncludePathsArray count])
						[mIncludePathsArray addObject: file];
					else
						[mIncludePathsArray insertObject: file atIndex: row];
				}
			}
			[mIncludePathTableView reloadData];
		}
	}
	
	
	[mIncludePathTableView selectRowIndexes:[[[NSIndexSet alloc] initWithIndex:row]autorelease] byExtendingSelection: NO];	// select the row
	[self setModified:YES];
	
	return YES;
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
- (BOOL)validateMenuItem:(NSMenuItem *)aMenuItem
{
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
