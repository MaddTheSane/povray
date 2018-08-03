//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument.h
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
//********************************************************************************

//#define debugFileLoading
//#define debugColorSyntax
//#define debugShake
//#define debugDeclare
@class BaseTemplate;
@class sceneTextView;
#import <Cocoa/Cocoa.h>
#import "sceneTextview.h"
#define dToolbarRenderLabel NSLocalizedStringFromTable(@"toolBarRenderButtonLabel", @"applicationLocalized", @"")
#define dToolbarRenderPaletteLabel NSLocalizedStringFromTable(@"toolBarRenderButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarRenderTooltipLabel NSLocalizedStringFromTable(@"toolBarRenderButtonTooltip", @"applicationLocalized", @"")


#define dToolbarPrepareLabel NSLocalizedStringFromTable(@"toolBarPrepareButtonLabel", @"applicationLocalized", @"")
#define dToolbarPreparePaletteLabel NSLocalizedStringFromTable(@"toolBarPrepareButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarPrepareTooltipLabel NSLocalizedStringFromTable(@"toolBarPrepareButtonTooltip", @"applicationLocalized", @"")

#define dToolbarShiftLLabel NSLocalizedStringFromTable(@"toolBarShiftLButtonLabel", @"applicationLocalized", @"")
#define dToolbarShiftLPaletteLabel NSLocalizedStringFromTable(@"toolBarShiftLButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarShiftLTooltipLabel NSLocalizedStringFromTable(@"toolBarShiftLButtonTooltip", @"applicationLocalized", @"")

#define dToolbarShiftRLabel NSLocalizedStringFromTable(@"toolBarShiftRButtonLabel", @"applicationLocalized", @"")
#define dToolbarShiftRPaletteLabel NSLocalizedStringFromTable(@"toolBarShiftRButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarShiftRTooltipLabel NSLocalizedStringFromTable(@"toolBarShiftRButtonTooltip", @"applicationLocalized", @"")

#define dToolbarAddCommentLabel NSLocalizedStringFromTable(@"toolBarAddCommentButtonLabel", @"applicationLocalized", @"")
#define dToolbarAddCommentPaletteLabel NSLocalizedStringFromTable(@"toolBarAddCommentButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarAddCommentTooltipLabel NSLocalizedStringFromTable(@"toolBarAddCommentButtonTooltip", @"applicationLocalized", @"")

#define dToolbarRemoveCommentLabel NSLocalizedStringFromTable(@"toolBarRemoveCommentButtonLabel", @"applicationLocalized", @"")
#define dToolbarRemoveCommentPaletteLabel NSLocalizedStringFromTable(@"toolBarRemoveCommentButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarRemoveCommentTooltipLabel NSLocalizedStringFromTable(@"toolBarRemoveCommentButtonTooltip", @"applicationLocalized", @"")

#define dToolbarBalanceBracesLabel NSLocalizedStringFromTable(@"toolBarBalanceBracesButtonLabel", @"applicationLocalized", @"")
#define dToolbarBalanceBracesPaletteLabel NSLocalizedStringFromTable(@"toolBarBalanceBracesButtonPaletteLabel", @"applicationLocalized", @"")
#define dToolbarBalanceBracesTooltipLabel NSLocalizedStringFromTable(@"toolBarBalanceBracesButtonTooltip", @"applicationLocalized", @"")
#ifdef debugShake
	#define shakeMessage(q)  NSLog(q);
	#define shakeMessageForRange(mes,range) NSLog(mes,range.location, range.length);
#else
	#define shakeMessage(q)  
	#define shakeMessageForRange(mes,range) 
#endif

#ifdef debugDeclare
	#define declareMessage(q)  NSLog(q);
#else
	#define declareMessage(q)  
#endif


#ifdef debugColorSyntax
	// colorInTime
	#define colorInTime(q)  NSLog(q,[[NSDate date] timeIntervalSinceDate:mDate],[[NSDate date] timeIntervalSinceDate:mDateSincePrevious]);		mDateSincePrevious=[NSDate date];
	//colorTimeStart
	#define colorTimeStart(q)  NSLog(q);	mDateSincePrevious=[NSDate date];
	//colorTimeStartRange
		#define colorTimeStartRange(q,range)  NSLog(q,range.location, range.length); mDateSincePrevious=[NSDate date];
	//colorMessage
	#define colorMessage(q)  NSLog(q);
	#else
		#define colorInTime(q)
		#define colorTimeStart(q)
		#define colorTimeStartRange(q, range)
		#define colorMessage(q)
#endif



#ifdef debugFileLoading
	//fileInTime
	#define fileInTime(q)  NSLog(q,[[NSDate date] timeIntervalSinceDate:mDate],[[NSDate date] timeIntervalSinceDate:mDateSincePrevious]);	mDateSincePrevious=[NSDate date];
	#else
		#define fileInTime(q)
#endif

#define sceneDocumentToolbarIdentifier						@"sceneDocumentToolbarIdentifier"
#define renderSceneDocumentToolBarItemIdintifier 	@"renderSceneDocumentToolBarItemIdintifier"
#define sceneDocumentInPrefsToolbarItemIdentifier @"sceneDocumentInPrefsToolbarItemIdentifier"
#define commentToolbarItemIdentifier							@"commentToolbarItemIdentifier"
#define removeCommentToolbarItemIdentifier				@"removeCommentToolbarItemIdentifier"
#define moveLeftToolbarItemIdentifier							@"moveLeftToolbarItemIdentifier"
#define moveRightToolbarItemIdentifier						@"moveRightToolbarItemIdentifier"
#define bracesToolbarItemIdentifier								@"bracesToolbarItemIdentifier"

enum styleToBeUsed {
	useKeywordStyle=1,
	usePreprocessorStyle=2,
	useMacroStyle=3,
	useDeclareStyle=4
};

enum menuItems {
	eTag_ColorSyntaxOn=345,
	eTag_recolorDocument=346
	};

typedef struct {
	char *wordAsCString;
	NSString *wordAsNSString;
	long wordLength;
	unsigned short wordStyle;
	unsigned location;
	BOOL isLocal;
	} keyWords;
 
 typedef struct {
 	long numberOfWords;
 	long reserved;
 	long *pointers;
 }countList;

extern countList sKeywordsCountList[256];
extern keyWords *sKeywordsList;
extern long	sNumberOfKeyWords;

//---------------------------------------------------------------------
// findStyleForDeclare
//---------------------------------------------------------------------
//	returns declareStyle for a word if it exists as declare, else returns blackStyle
// utf8 should not be nil and lenght should not be 0
// check this before calling!
//---------------------------------------------------------------------
#define  findStyleForDeclare(result, utf8,  stringLength, index)																						\
{																																																						\
	result=[[appPreferencesController sharedInstance] style: cBlackStyle ];																		\
	if ( mNumberOfDeclares !=0)																																								\
	{																																																					\
		BOOL found=YES;																																													\
		for (int x=0; x<mDeclareCountList[*(unsigned char*)utf8].reserved; x++)																	\
		{																																																				\
			long number=mDeclareCountList[*(unsigned char*)utf8].pointers[x];																			\
			if ( mDeclareList[number].wordLength==stringLength && mDeclareList[number].wordAsCString[0]==utf8[0])	\
			{																																																			\
					found=YES;																																												\
				for (int y=1; y<stringLength; y++)																																	\
				{																																																		\
					if ( mDeclareList[number].wordAsCString[y] != utf8[y])																						\
					{																																																	\
						found=NO;																																												\
						break;																																													\
					}																																																	\
				}																																																		\
				if ( found==YES)																																										\
				{																																																		\
					result=[[appPreferencesController sharedInstance] style: cDeclareStyle ];													\
					index= number;																																										\
					break;																																														\
				}																																																		\
			}																																																			\
		}																																																				\
	}																																																					\
}

//---------------------------------------------------------------------
// findStyleForMacro
//---------------------------------------------------------------------
//	returns macroStyle for a word if it exists as macro, else returns blackStyle
// utf8 should not be nil and lenght should not be 0
// check this before calling!
//---------------------------------------------------------------------

#define findStyleForMacro(result, utf8,  stringLength, index)																							\
{																																																					\
	result=[[appPreferencesController sharedInstance] style: cBlackStyle ];																	\
	if ( mNumberOfMacros !=0)																																								\
	{																																																				\
	BOOL found=YES;																																													\
		for (int x=0; x<mMacroCountlist[*(unsigned char*)utf8].reserved; x++)																	\
		{																																																			\
			long number=mMacroCountlist[*(unsigned char*)utf8].pointers[x];																			\
			if ( mMacroList[number].wordLength==stringLength && mMacroList[number].wordAsCString[0]==utf8[0])		\
			{																																																		\
				found=YES;																																												\
				for (int y=1; y<stringLength; y++)																																\
				{																																																	\
					if ( mMacroList[number].wordAsCString[y] != utf8[y])																						\
					{																																																\
						found=NO;																																											\
						break;																																												\
					}																																																\
				}																																																	\
				if ( found==YES)																																									\
				{																																																	\
					result=[[appPreferencesController sharedInstance] style: cMacroStyle ];													\
					index= number;																																									\
					break;																																													\
				}																																																\
			}																																																		\
		}																																																			\
	}																																																				\
}																																																		





//---------------------------------------------------------------------
// findStyleForWord
//---------------------------------------------------------------------
//	return the style for a given word
//---------------------------------------------------------------------
#define  findStyleForWord(result, utf8)																																					\
{																																																								\
	result=[[appPreferencesController sharedInstance] style: cBlackStyle ];																				\
	long stringLength=strlen(utf8);																																								\
	if (stringLength !=0)																																													\
	{																																																							\
		BOOL found=YES;																																															\
		for (int x=0; x<sKeywordsCountList[*(unsigned char*)utf8].reserved; x++)																		\
		{																																																						\
			long number=sKeywordsCountList[*(unsigned char*)utf8].pointers[x];																				\
			if ( sKeywordsList[number].wordLength==stringLength && sKeywordsList[number].wordAsCString[0]==utf8[0])		\
			{																																																					\
				for (int y=1; y<stringLength; y++)																																			\
				{																																																				\
					found=YES;																																														\
					if ( sKeywordsList[number].wordAsCString[y] != utf8[y])																								\
					{																																																			\
						found=NO;																																														\
						break;																																															\
					}																																																			\
				}																																																				\
				if ( found==YES)																																												\
				{																																																				\
					if( sKeywordsList[number].wordStyle ==useKeywordStyle)																								\
						result=[[appPreferencesController sharedInstance] style: cKeywordStyle ];														\
					else if( sKeywordsList[number].wordStyle ==usePreprocessorStyle)																			\
						result=[[appPreferencesController sharedInstance] style: cPreprocessorStyle ];											\
					break;																																																\
				}																																																				\
			}																																																					\
		}																																																						\
		if (result == [[appPreferencesController sharedInstance] style: cBlackStyle ])	/*no, it wasn't a keyword*/	\
		{																																																						\
			signed long index=0;																																											\
			findStyleForDeclare(result,utf8,stringLength, index);																											\
			if ( result==[[appPreferencesController sharedInstance] style: cBlackStyle ])	/*no, it wasn't a declare*/	\
				findStyleForMacro(result, utf8,stringLength, index);																										\
		}																																																						\
	}																																																							\
}


extern	NSRange mEffectiveRecoloredRange;	// this contains the range recolored.
																	// set after a call to one of these methods:
																	// -applySyntaxHighlightingOnlyComment
																	// -applySyntaxHighlighting
																	// -applySyntaxHighlightingOnlyKeywords



@interface SceneDocument : NSDocument <NSToolbarDelegate>
{
	IBOutlet id gotoEdit;
	 BaseTemplate *mFileOwner;	//fileOwner for nib file (is a subclass of basetemplate
												// like cameraTemplate or lightTemplate...

	//goto
	IBOutlet	NSPanel					*mGotoPanel;
	IBOutlet	NSButton				*mGotoPanelOk;
	IBOutlet	NSButton				*mGotoPanelCancel;
	IBOutlet NSTextField			*mGotoPanelLineNumber;
	
	IBOutlet NSPopUpButton				*mMacroPopup;
	IBOutlet NSPopUpButton				*mIncludePopup;
	IBOutlet NSPopUpButton				*mDeclarePopup;
	IBOutlet NSPopUpButton				*mTemplatePopup;
	IBOutlet NSScrollView 				*mScrollView;
	IBOutlet sceneTextView				*mSceneTextView;
	IBOutlet NSProgressIndicator 	*mProgressIndicator;
	IBOutlet NSMenuItem						*mColoredSyntaxMenuItem;
	NSMutableAttributedString	*mMutableAttributedStringFromFile;
	BOOL mStringFromFileIsColored;
	BOOL	mSyntaxColoringOn;
	BOOL	mNewMacro;
	BOOL	mNewDeclare;
	BOOL	mNewInclude;
	BOOL	mSyntaxColoringBusy;	// Set while recolorRange is busy, so we don't recursively call recolorRange.
	NSMutableArray *mIncludeList;
	SEL mSELsetScanLocation;
	SEL mSELcharacterAtIndex;
	SEL mSELscanLocation;
	SEL mSELscanUpToCharactersFromSet;
	SEL mSELscanCharactersFromSet;
	NSRange mEffectiveRecoloredRange;	// this contains the range recolored.
																	// set after a call to one of these methods:
																	// -applySyntaxHighlightingOnlyComment
																	// -applySyntaxHighlighting
																	// -applySyntaxHighlightingOnlyKeywords
	keyWords	*mDeclareList;
	countList mDeclareCountList[256];

	long			mNumberOfDeclares;
	long			mAvailableFreeDeclarePositions;
	long			mRemovedDeclarePositions;
																	
	keyWords	*mMacroList;
	countList	mMacroCountlist[256];
	long			mNumberOfMacros;
	long			mAvailableFreeMacroPositions;
	long			mRemovedMacroPositions;
	#ifdef debugColorSyntax
		NSDate *mDate, *mDateSincePrevious;
	#endif
}
+(void) initialize;
-(id) fileOwner;
-(IBAction) coloredSyntaxMenu:(id) sender;
-(IBAction) recolorDocument:(id) sender;

-(IBAction) gotoLine: (id)sender;
-(IBAction) gotoLineCanel: (id)sender;
-(IBAction) gotoLineOk:(id)sender;

-(IBAction) startRender: (id)sender;
-(IBAction)	macroPopup: (id)sender;
-(IBAction)	templatePopup: (id)sender;
-(IBAction) insertMenu:(id)sender;

-(IBAction)	includePopup: (id)sender;
-(IBAction)	declarePopup: (id)sender;
-(void) rebuildIncludePopup;
-(void) rebuildDeclarePopup;
-(void) rebuildMacroPopup;
-(sceneTextView*) getSceneTextView;

-(NSWindow*) window;
-(void) selectLine:(NSUInteger)lineNumber;

-(NSMutableAttributedString*) mutableAttibutedStringFromFile;
-(void) setMutableAttributedStringFromFile: (NSMutableAttributedString *)str;

- (void)initializeToolbar;

-(IBAction)checkBracesSceneDocument:(id)sender;
-(void) renderDocument;
-(void) moveDocumentToRenderingPreferences;
-(IBAction)shiftSelectionToTheRight:(id)sender;
-(IBAction)shiftSelectionToTheLeft:(id)sender;
-(IBAction)makeSelectionComment:(id)sender;
-(IBAction)uncommentSelection:(id)sender;
-(void) renderState:(NSNotification *) notification;
-(void) insertStringForEachLineInSelectedRange:(NSString*)StringToInsert;
-(void) removeStringForEachLineInSelectedRange:(NSString*)StringToInsert;

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem;
-(void) textStorageDidProcessEditingNotification: (NSNotification*)notification;
-(void) checkStringRangeForMacroDeclareOrLocal:(NSString*)fullString forRange:(NSRange)lastLineRange;

@end

@interface NSScanner (SkipUpToCharset)

-(BOOL) skipUpToCharactersFromSet:(NSCharacterSet*)set;

@end
