//******************************************************************************
///
/// @file /macintosh/appPreferencesController.h
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

#import "mainController.h"

#import "standardMethods.h"

typedef NS_ENUM(NSInteger, appPrefsEnum) {
	cMaintainIndentaion	=1,
	cAutoIndentBraces		=2,
	};

typedef NS_ENUM(NSInteger, textStyles) {
	cBlackStyle		=1,
	cKeywordStyle,
	cPreprocessorStyle,
	cMultilineCommentStyle,
	cOnelineCommentStyle,
	cStringStyle,
	cMacroStyle,
	cDeclareStyle
};
typedef NS_ENUM(NSInteger, windowInFront) {
		AllwaysInFront = 1,
		OnlyfirstFrameInFront=2
};

@interface appPreferencesController : NSObject <NSTextFieldDelegate, NSWindowDelegate>
{
	IBOutlet NSWindow			*mApplicationPreferencesWindow;
	IBOutlet NSButton			*mSyntaxColorOn;
	IBOutlet NSBox				*mSyntaxColorGroupBox;
	IBOutlet NSColorWell	*mPreprocessorColorWell;
	IBOutlet NSColorWell	*mMultiLineCommentColorWell;
	IBOutlet NSColorWell	*mOneLineCommentColorWell;
	IBOutlet NSColorWell	*mStringColorWell;
	IBOutlet NSColorWell	*mIdentifierColorWell;
	IBOutlet NSColorWell	*mMacroColorWell;
	IBOutlet NSColorWell	*mDeclaresColorWell;
	IBOutlet NSTextField 	*mTabSize;
	IBOutlet NSMatrix			*mPointMatrix;
	IBOutlet NSTextField	*mInsertMenuMainDirectoryEdit;
	IBOutlet NSSlider			*mInsertMenuImageScaleSlider;
 	IBOutlet NSTabView		*mTabView;
 	IBOutlet NSTableView	*mIncludePathTableView;
 	IBOutlet NSButton			*mIncludePathDeleteButton;
 	IBOutlet NSButton			*mIncludePathChangeButton;
 	IBOutlet NSButton			*mIncludePathAddButton;
 	IBOutlet NSButton			*mCancelButton;
 	IBOutlet NSButton			*mApplyButton;
 	IBOutlet NSButton			*mOkButton;
 	IBOutlet NSButton			*mMaintainIndentationOn;
 	IBOutlet NSButton			*mAutoIndentBracesOn;
 	IBOutlet NSTextField	*mSelectedFont;

	//misc
 	IBOutlet NSTextField	*mOutletDisplayGammaEdit;
 	IBOutlet NSButton			*mDisplayGammaButton;
	IBOutlet NSButton			*mRememberOpenWindowsButton;
	IBOutlet NSButton			*mAlwaysPutPreviewwindowInFrontButton;
	IBOutlet NSButton			*mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationButton;

	NSNumber							*mModifiedFlag;
	NSMutableArray				*mIncludePathsArray;
  NSUInteger						mDraggedRow;	// keep track of which row got dragged
    //extra
	IBOutlet NSButton		*mSelectFontButton;
	IBOutlet NSButton		*mSelectInsertMenuMainDirectoryButton;
	NSString						*mDisplayGammaString;
	NSInteger						mDisplayGammaOn;		//
	NSInteger						mAlwaysPutPreviewwindowInFrontOn;
	NSInteger						mOnlyPutPreviewwindowInFrontForFirstFrameOfAnimationOn;
	NSInteger						mSelectedRowForChangePath;
	NSString						*mInsertDirectory;
	NSNumber						*mInsertMenuImageScaleFloat;
	
	//syntaxhighliting
	NSColor					*mPreprocessorColor;
	NSColor					*mMultiLineCommentColor;
	NSColor					*mOneLineCommentColor;
	NSColor					*mStringColor;
	NSColor					*mIdentifierColor;
	NSColor					*mMacroColor;
	NSColor					*mDeclareColor;
	NSDictionary		*mBlackStyleDict;
	NSDictionary		*mKeyWordStyleDict;
	NSDictionary		*mPreprocessorStyleDict;
	NSDictionary		*mMultiLineCommentStyleDict;
	NSDictionary		*mOneLineCommentStyleDict;
	NSDictionary		*mStringStyleDict;
	NSDictionary		*mMacroStyleDict;
	NSDictionary		*mDeclareStyleDict;
	NSFont					*mSceneDocumentFont;
	NSMutableParagraphStyle	*mDefaultParagraphStyle;

}
+ (appPreferencesController*) sharedInstance;
-(NSDictionary*) style:(textStyles)type;
-(float) scaleFactor;
-(void) setIncludePathArray:(id) pathsArray;
-(IBAction)selectInsertMenuMainDirectoryButton:(id)sender;
-(IBAction)applicationPreferences:(id)sender;
-(void) setAddChangeRemoveButtons;
-(void) selectionIncludePathTableViewChanged:(NSNotification *) notification;
-(void)controlTextDidChange:(NSNotification *)aNotification;
-(void) deactivateColorWells;
@property (getter=isModified) BOOL modified;
-(void) buildSyntaxStyles;
-(void) buildDefaultParagraphStyle;
-(IBAction)displayGammaButton:(id)sender;
-(void) storeNewAppPreferences;
-(IBAction) selectFont:(id) sender;
-(IBAction) colorChanged:(id) sender;
-(IBAction) rememberOpenWindowsButton:(id) sender;
- (IBAction)AlwaysPutPreviewwindowInFrontButton:(id)sender;
-(IBAction) insertMenuImageSizeSlider:(id) sender;

-(IBAction) pointMatrix:(id) sender;
-(IBAction) syntaxColorOn:(id) sender;
-(IBAction) tabSize:(id) sender;
-(IBAction) includePathDeleteButton:(id) sender;
-(IBAction) includePathChangeButton:(id) sender;
-(IBAction) includePathAddButton:(id) sender;
-(IBAction) cancelButton:(id) sender;
-(IBAction) applyButton:(id) sender;
-(IBAction) okButton:(id) sender;
-(IBAction) appPreferencesButton:(id) sender;
-(IBAction) appPreferencesTarget:(id) sender;

@end
