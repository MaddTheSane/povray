//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument.mm
///
/// @todo   What's in here?
///
/// @copyright
/// @parblock
///
/// Unofficial Macintosh GUI port of POV-Ray 3.7
/// Copyright 2002-2016 Yvo Smellenbergh
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
/// Tracer ('POV-Ray') version 3.7, Copyright 1991-2016 Persistence of Vision
/// Raytracer Pty. Ltd.
///
/// ----------------------------------------------------------------------------
///
/// POV-Ray is based on the popular DKB raytracer version 2.12.
/// DKBTrace was originally written by David K. Buck.
/// DKBTrace Ver 2.0-2.12 were written by David K. Buck & Aaron A. Collins.
///
/// @endparblock
///
//********************************************************************************

#import "sceneDocument+highlighting.h"
#import "sceneDocument+templates.h"
#import "appPreferencesController.h"
#import "maincontroller.h"
#import "BaseTemplate.h"

 

@implementation SceneDocument
//---------------------------------------------------------------------
// fileOwner
//---------------------------------------------------------------------
-(id) fileOwner
{
	return mFileOwner;
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
//	use this to initialize our keywords and colors
//---------------------------------------------------------------------
+(void) initialize
{
	[self initializeSyntaxHightlighting];
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
- (id)init
{
    self = [super init];
    if (self) 
    {
	mSELsetScanLocation	= @selector(setScanLocation:);
	mSELcharacterAtIndex= @selector(characterAtIndex:);
	mSELscanLocation = @selector(scanLocation);
	mSELscanUpToCharactersFromSet = @selector(scanUpToCharactersFromSet:intoString:);
	mSELscanCharactersFromSet = @selector(scanCharactersFromSet:intoString:);
			#ifdef debugColorSyntax
				mDate=[[NSDate date]retain];
				NSLog(@"setting local coloring to default in init");
			#endif
			mSyntaxColoringOn=globalAutoSyntaxColoring;
			mMutableAttributedStringFromFile = nil;
			mSyntaxColoringBusy = NO;
		}
    return self;
}

//---------------------------------------------------------------------
// getSceneTextView
//---------------------------------------------------------------------
- (sceneTextView*) getSceneTextView
{
    return mSceneTextView;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	

	//build template popup
	int idx=1;	// index of first menu entry (camera)
	[mTemplatePopup removeAllItems];
	NSMenu *templates=[mTemplatePopup menu];

	[templates addItemWithTitle:@"Templates" action:nil keyEquivalent:@""];		//title

	[templates addItemWithTitle:@"Camera" action:nil keyEquivalent:@""];
	NSMenuItem *item=[templates itemAtIndex: idx++];									[item setTag:menuTagTemplateCamera];
	
	[templates addItemWithTitle:@"Light Source" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];	
		[item setTag:menuTagTemplateLight];

	[templates addItemWithTitle:@"Object..." action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateObject];

	[templates addItemWithTitle:@"Transformations.." action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateTransformations];

	[templates addItemWithTitle:@"Functions" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateFunctions];

	[templates addItem:[NSMenuItem separatorItem]];
	idx++;
	
	[templates addItemWithTitle:@"Pigment" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplatePigment];

	[templates addItemWithTitle:@"Finish" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateFinish];

	[templates addItemWithTitle:@"Normal" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateNormal];

	[templates addItemWithTitle:@"Interior" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateInterior];

	[templates addItemWithTitle:@"Media" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateMedia];

	[templates addItemWithTitle:@"Photons" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplatePhotons];

	[templates addItemWithTitle:@"Background|Fog|Rainbow|Sky|Glow" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateBackground];

	[templates addItem:[NSMenuItem separatorItem]];
	idx++;
	
	[templates addItemWithTitle:@"Color-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateColormap];

	[templates addItemWithTitle:@"Density-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateDensitymap];

	[templates addItemWithTitle:@"Material-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateMaterialmap];

	[templates addItemWithTitle:@"Normal-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateNormalmap];

	[templates addItemWithTitle:@"Pigment-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplatePigmentmap];

	[templates addItemWithTitle:@"Slope-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateSlopemap];

	[templates addItemWithTitle:@"Texture-map" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateTexturemap];

	[templates addItem:[NSMenuItem separatorItem]];
	idx++;

	[templates addItemWithTitle:@"Header/Include" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateHeaderInclude];

	[templates addItemWithTitle:@"Globals" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateGlobals];

	[templates addItem:[NSMenuItem separatorItem]];
	idx++;

	[templates addItemWithTitle:@"Material Editor" action:nil keyEquivalent:@""];
		item=[templates itemAtIndex: idx++];									
		[item setTag:menuTagTemplateMaterial];

	NSDictionary *gotoLineTextAttributes= [NSDictionary dictionaryWithObjectsAndKeys:
						[NSFont userFontOfSize:4.0], NSFontAttributeName,
						[NSColor redColor], NSForegroundColorAttributeName,
					nil];
	
	NSAttributedString *st=[[[NSAttributedString alloc]initWithString:@"1" attributes:gotoLineTextAttributes]autorelease];
	[gotoEdit setAttributedStringValue:st];
  [[gotoEdit cell] setBordered:YES];
	
	// bug in Mavericks? Settings in interface builder not used? Turn it off
	[mSceneTextView setAutomaticQuoteSubstitutionEnabled:NO];
}



//---------------------------------------------------------------------
// templatePopup: sender
//---------------------------------------------------------------------
-(IBAction) templatePopup:(id)sender
{
	// called from menu
	if ( [sender isMemberOfClass:[NSMenuItem class]])
		[SceneDocument displayTemplateNumber:[sender tag] fileowner:mFileOwner caller:self dictionary:nil ];
	// or called from the popup in the toolbar
	else
	{
		id menu=[sender itemAtIndex:[sender indexOfSelectedItem]];
		if (menu != nil)
			[SceneDocument displayTemplateNumber:[menu tag] fileowner:mFileOwner caller:self dictionary:nil ];
	}
}

//---------------------------------------------------------------------
// insertMenu: sender
//---------------------------------------------------------------------
-(IBAction) insertMenu:(id)sender
{
	menuFromDirectory* mfd=[[MainController sharedInstance]templateMainInsertMenu];
	if ( mfd)
	{
		menuFromDirectoryItem *mfdi=[mfd directoryItemForNSMenuItem:(NSMenuItem*)sender];
		if ( mfdi)
		{
			#if MAC_OS_X_VERSION_MIN_REQUIRED == MAC_OS_X_VERSION_10_4
				NSString *as=[NSString stringWithContentsOfFile:[mfdi fullFileName]];
			#else
				NSStringEncoding enc;
				NSString *as=[NSString stringWithContentsOfFile:[mfdi fullFileName] usedEncoding:&enc error:NULL];
			#endif
			
			if ( as)
			{
				NSRange selection=[mSceneTextView selectedRange];
				if ( [mSceneTextView shouldChangeTextInRange:selection replacementString:as])
				{
					[mSceneTextView replaceCharactersInRange:selection withString:as];
					[mSceneTextView didChangeText];
				}
			}
		}
	}
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self setMutableAttributedStringFromFile:nil];
	[self releaseMacroList];
	[self releaseDeclareList];
	[mIncludeList release];
	mIncludeList=nil;
	#ifdef debugColorSyntax
		[mDate release];
	#endif
	[super dealloc];
}

//---------------------------------------------------------------------
// windowControllerDidLoadNib
//---------------------------------------------------------------------
- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
	[mSceneTextView setTypingAttributes:[[appPreferencesController sharedInstance] style: cBlackStyle ]];
//	[mSceneTextView setFont:sceneDocumentFont];
//	[mSceneTextView setDefaultParagraphStyle:gDefaultParagraphStyle];
	[super windowControllerDidLoadNib:aController];

	[mProgressIndicator setDisplayedWhenStopped:NO];
	[mProgressIndicator setUsesThreadedAnimation:YES];
//	if ( [[mSceneTextView layoutManager]respondsToSelector:@selector(setAllowsNonContiguousLayout:)])
			[[mSceneTextView layoutManager]setAllowsNonContiguousLayout:NO];

	if ( [self mutableAttibutedStringFromFile])
	{
		colorTimeStart(@"Setting string in texwie");
		[[mSceneTextView textStorage] setAttributedString: [self mutableAttibutedStringFromFile]];
		// we have to do it here because when the file was loaded,
		// the nib file wasn't loaded yet
		[self rebuildDeclarePopup];
		[self rebuildIncludePopup];
		[self rebuildMacroPopup];
		colorInTime(@"******done Setting string in textview at time:%lf in:%f")
		[self setMutableAttributedStringFromFile:nil];
	}
	[self initializeToolbar];
	
	// Register for "text changed" notifications of our text storage:
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(textStorageDidProcessEditingNotification:)
		name: NSTextStorageDidProcessEditingNotification
		object: [mSceneTextView textStorage]];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(textViewDidChangeSelectionNotification:)
		name: NSTextViewDidChangeSelectionNotification
		object: mSceneTextView];

	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(textViewWillChangeNotifyingTextViewNotification:)
		name: NSTextViewWillChangeNotifyingTextViewNotification
		object: mSceneTextView];


	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"renderState"
		object:nil];

	
	// Put selection at top like Project Builder has it, so user sees it:
	[mSceneTextView setSelectedRange: NSMakeRange(0,0)];

	// Make sure text isn't wrapped:
	NSTextContainer *textContainer = [mSceneTextView textContainer];
	NSRect frame;
	NSScrollView *scrollView = [mSceneTextView enclosingScrollView];
	
	// Make sure we can see right edge of line:
    [scrollView setHasHorizontalScroller:YES];
	
	// Make text container so wide it won't wrap:
	[textContainer setContainerSize: NSMakeSize(1.0e7, 1.0e7)];
	[textContainer setWidthTracksTextView:NO];
  [textContainer setHeightTracksTextView:NO];

	// Make sure text view is wide enough:
	frame.origin = NSMakePoint(0.0, 0.0);
  frame.size = [scrollView contentSize];
	
  [mSceneTextView setMaxSize:NSMakeSize(1.0e7, 1.0e7)];
  [mSceneTextView setHorizontallyResizable:YES];
  [mSceneTextView setVerticallyResizable:YES];
  [mSceneTextView setContinuousSpellCheckingEnabled:NO];
  [mSceneTextView setAutoresizingMask:NSViewNotSizable];
  
	//build the table for macros and declares
	if ( mStringFromFileIsColored == NO)
		[self recolorCompleteAttributedString:nil sender:self];
}

//---------------------------------------------------------------------
// window
//---------------------------------------------------------------------
-(NSWindow*) window
{
    NSArray *controllers = [self windowControllers];
    return [[controllers objectAtIndex:0] window];
}

//---------------------------------------------------------------------
// windowNibName
//---------------------------------------------------------------------
- (NSString *)windowNibName
{
    return @"SceneDocument";
}

//---------------------------------------------------------------------
// macroPopup
//---------------------------------------------------------------------
-(IBAction)	macroPopup: (id)sender
{
	NSMenuItem *selectedItem=[sender selectedItem];
	if ( selectedItem != nil)
	{
	//	NSRange currentRange=[mSceneTextView selectedRange];
		NSString *title=[selectedItem title];
		
		// make sure title isn't an empty string
		const char* utf8=[title UTF8String];
		if ( utf8==nil)
			return;
		size_t length=strlen(utf8);
		if ( length == 0 )
			return;

		NSDictionary *styleToApply;
		signed long index=-1l;
		findStyleForMacro(styleToApply,utf8, length, index);
		if ( index != -1)	//found
		{
			NSRange newRange=NSMakeRange(mMacroList[index].location, [title length]);
			[mSceneTextView setSelectedRange:newRange];
			[mSceneTextView scrollRangeToVisible:newRange];

		}
	}
}

//---------------------------------------------------------------------
// includePopup
//---------------------------------------------------------------------
//	When the user selects an entry in the include popupbutton
//	all paths are searched to find that file.
//	if the file is found, it will be displayed
//---------------------------------------------------------------------
-(IBAction)	includePopup: (id)sender
{
	BOOL fileFound=NO;
	NSString *tempString=nil;
//	NSString *extension=nil;
	NSString *titleString=nil;
	
	NSFileManager *defaultFileManager=[NSFileManager defaultManager];
	NSMenuItem *selectedItem=[sender selectedItem];
	if ( selectedItem != nil)
	{
	//	NSRange currentRange=[mSceneTextView selectedRange];
		titleString=[selectedItem title];
		// first search in the same directory as the current file
		// but only if it is a pov file (no include etc..)
	// removed this check, no need for it.
	// open all files, even if it is an inc file
			tempString=[[[self fileURL]path] stringByDeletingLastPathComponent];
	//	extension=[[self fileName] pathExtension];
//		if ( [extension compare:@"pov" options:NSCaseInsensitiveSearch range:NSMakeRange(0,3)] ==NSOrderedSame)
		{
			if ( ![tempString hasSuffix:@"/"])
				tempString=[tempString stringByAppendingString:@"/"];
			tempString=[tempString stringByAppendingString:titleString];

			fileFound=[defaultFileManager fileExistsAtPath:tempString];
			if ( fileFound==YES)	
				[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:tempString] display:YES error:nil];
		}
		
		// now we start searching the library paths, starting with the two in the preference panel
		if (fileFound==NO)	
		{
			NSMutableDictionary *dict=[[PreferencesPanelController sharedInstance] getDictWithCurrentSettings:NO];
			NSMutableArray *paths=[[[NSMutableArray alloc] init]autorelease];
			if ( dict != nil)
			{
				[paths addObject:[dict objectForKey:@"include1"]];
				[paths addObject:[dict objectForKey:@"include2"]];
			}
			NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
			NSArray *sysPaths=[defaults objectForKey:@"includePaths"];
			if (sysPaths !=nil)
			{
				NSEnumerator *en=[sysPaths objectEnumerator];
				NSString *object;
				while ( (object =[en nextObject] )!= nil)
				{
					[paths addObject:object];
				}
			}

			for(int x=0; x<[paths count]; x++)
			{
				 tempString=[paths objectAtIndex:x];
				 if ( tempString && [tempString length])
				 {
					if ( ![tempString hasSuffix:@"/"])
						tempString=[tempString stringByAppendingString:@"/"];
				 
					tempString=[tempString stringByAppendingString:titleString];
					fileFound=[defaultFileManager fileExistsAtPath:tempString];
					if ( fileFound==YES)
					{
						[[NSDocumentController sharedDocumentController] openDocumentWithContentsOfURL:[NSURL fileURLWithPath:tempString] display:YES error:nil];

						return;
					}
				}
			}
		}
	}
}

//---------------------------------------------------------------------
// declarePopup
//---------------------------------------------------------------------
-(IBAction)	declarePopup: (id)sender
{
	NSMenuItem *selectedItem=[sender selectedItem];
	if ( selectedItem != nil)
	{
	//	NSRange currentRange=[mSceneTextView selectedRange];
		NSString *title=[selectedItem title];
		NSRange localStringRange=[title rangeOfString:@" (local)" options:NSLiteralSearch];
		if ( localStringRange.location != NSNotFound )
			title=[title substringToIndex:localStringRange.location];

		signed long index=-1l;
		// make sure title isn't an empty string
		const char* utf8=[title UTF8String];
		if ( utf8==nil)
			return;
		size_t length=strlen(utf8);
		if ( length == 0 )
			return;
		NSDictionary *styleToApply;
		findStyleForDeclare(styleToApply,utf8, length, index);
		if ( index != -1)	//found
		{
			NSRange newRange=NSMakeRange(mDeclareList[index].location, [title length]);
			[mSceneTextView setSelectedRange:newRange];
			[mSceneTextView scrollRangeToVisible:newRange];

		}
	}
}

//---------------------------------------------------------------------
// setStringFromFile
//---------------------------------------------------------------------
-(void) setMutableAttributedStringFromFile: (NSMutableAttributedString *)str
{
	[mMutableAttributedStringFromFile release];
	mMutableAttributedStringFromFile=str;
	[mMutableAttributedStringFromFile retain];
}

//---------------------------------------------------------------------
// stringFromFile
//---------------------------------------------------------------------
-(NSMutableAttributedString*) mutableAttibutedStringFromFile
{
	return mMutableAttributedStringFromFile;
}

//---------------------------------------------------------------------
// rebuildDeclarePopup
//---------------------------------------------------------------------
-(void) rebuildDeclarePopup
{
	if ( mDeclarePopup == nil)
		return;
	[mDeclarePopup removeAllItems];
	[mDeclarePopup addItemWithTitle:@"#declare"];	// item 0 is title in a pulldown
	NSMenu *menu=[mDeclarePopup menu];
	NSString *menuTitle=nil;
	if ( mNumberOfDeclares ==0)
		[mDeclarePopup setEnabled:NO];
	else
	{
		for(int x=1; x<=255; x++)
		{
			for(int y=1; y<=mDeclareCountList[x].reserved; y++)
			{
				menuTitle=mDeclareList[mDeclareCountList[x].pointers[y-1]].wordAsNSString;
				if ( mDeclareList[mDeclareCountList[x].pointers[y-1]].isLocal ==YES)	// is a local
					menuTitle=[menuTitle stringByAppendingString:@" (local)"];
				[menu addItemWithTitle:menuTitle action:nil keyEquivalent:@""];
			}
		}
		[mDeclarePopup setEnabled:YES];
	}
}

//---------------------------------------------------------------------
// rebuildMacroPopup
//---------------------------------------------------------------------
-(void) rebuildMacroPopup
{
	if ( mMacroPopup == nil)
		return;
	[mMacroPopup removeAllItems];
	[mMacroPopup addItemWithTitle:@"#Macro"];	// item 0 is title in a pulldown

	if ( mNumberOfMacros ==0)
		[mMacroPopup setEnabled:NO];
	else
	{	
		for(int x=1; x<=mNumberOfMacros; x++)
		{
			[mMacroPopup addItemWithTitle:mMacroList[x-1].wordAsNSString];
		}
		[mMacroPopup setEnabled:YES];
	}
}

//---------------------------------------------------------------------
// rebuildIncludePopup
//---------------------------------------------------------------------
-(void) rebuildIncludePopup
{
	if ( mIncludePopup == nil)
		return;

	[mIncludePopup removeAllItems];
	[mIncludePopup addItemWithTitle:@"#include"];	// item 0 is title in a pulldown
	NSEnumerator *en=[mIncludeList objectEnumerator];
	NSString *menuTitle;
	if ( [mIncludeList count] ==0)
		[mIncludePopup setEnabled:NO];
	else
	{
		while ( (menuTitle =[en nextObject] )!= nil)
		{
			[mIncludePopup addItemWithTitle:menuTitle];
		}
		[mIncludePopup setEnabled:YES];
	}
}

//---------------------------------------------------------------------
// [self recolorCompleteFile:self];
//---------------------------------------------------------------------
//	RECOLOR THE COMPLETE DOCUMENT
//---------------------------------------------------------------------
- (IBAction) recolorDocument:(id)sender
{

	[self recolorCompleteAttributedString:nil sender:self];
}
//---------------------------------------------------------------------
// coloredSyntaxMenu
//---------------------------------------------------------------------
//	turn colored syntax on/off for this document
//---------------------------------------------------------------------
- (IBAction) coloredSyntaxMenu:(id) sender
{
	if (mSyntaxColoringOn == NO)
	{
		if ( [[mSceneTextView textStorage]length]/(1024*1024) > 25l)
		{
			int res=NSRunAlertPanel( NSLocalizedStringFromTable(@"DocumentIsHuge", @"applicationLocalized", @"This is a large file\n"),
														NSLocalizedStringFromTable(@"DocumentIsHuge2", @"applicationLocalized", @"Turning on syntax coloring will lock up the computer for a long time.\nDo you want to proceed anyway?"),
														NSLocalizedStringFromTable(@"ColorOff", @"applicationLocalized", @"Color off"),
														NSLocalizedStringFromTable(@"ColorOn", @"applicationLocalized", @"Color on"),
														nil,
														nil);
			if ( res == NSAlertDefaultReturn) //cancel
				mSyntaxColoringOn=NO;
			else	//color on
				mSyntaxColoringOn=YES;
		}
		else
			mSyntaxColoringOn=YES;
		
	}
	else
		mSyntaxColoringOn=NO;
	[self recolorCompleteAttributedString:nil sender:self];
}
//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render of finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{
	NSToolbar *toolbar=[ [self window] toolbar];
	[toolbar validateVisibleItems];
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
- (BOOL) validateMenuItem:(NSMenuItem *)anItem
{
	switch ([anItem tag])
	{
		case eTag_ColorSyntaxOn:
			if ( mSyntaxColoringOn == YES)
				[anItem setState:NSOnState];
			else
				[anItem setState:NSOffState];
			return YES;
			break;
		case eTag_recolorDocument:
			if ( mSyntaxColoringOn == YES)
				return YES;
			else
				return NO;
			break;
		case eTag_renderMenu:
			return [[renderDispatcher sharedInstance] canStartNewRender];
			break;
		case eTag_pauseMenu:
			return [[renderDispatcher sharedInstance] canPauseRender];
			break;
		case eTag_abortMenu:
			return [[renderDispatcher sharedInstance] canAbortRender];
			break;
		case eTag_gotoMenu:
			return YES;
			break;
		default:
		if ( [anItem tag] >=menuTagTemplateCamera && [anItem tag] <=menuTagTemplateMaterial)
			return YES;
		else
		  	return [super validateMenuItem:anItem];
		
	}
  	return [super validateMenuItem:anItem];
}



//---------------------------------------------------------------------
// startRender
//---------------------------------------------------------------------
- (IBAction) startRender: (id)sender
{	
		// just as if we pressed the 'R' icon
	[self renderDocument];
}

//---------------------------------------------------------------------
// renderDocument
//---------------------------------------------------------------------
-(void) renderDocument
{
	NSMutableDictionary *currentSettings=[[PreferencesPanelController sharedInstance] getDictWithCurrentSettings:YES];
	if ( currentSettings)	//make sure we have usable settings to render the file
	{
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES] ,	@"shouldStartRendering",
			[[self fileURL]path], 			@"fileName",
			currentSettings,				@"rendersettings",
			[NSDate date],					@"dateOfPosting",
			nil];

		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"renderDocument" 
			object:self 
			userInfo:dict];
	}
}


//---------------------------------------------------------------------
// moveDocumentToRenderingPreferences
//---------------------------------------------------------------------
-(void) moveDocumentToRenderingPreferences
{
	[[NSNotificationCenter defaultCenter]postNotificationName:@"acceptDocument" 
		object:self 
		userInfo:nil];
}

//---------------------------------------------------------------------
// - (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
//---------------------------------------------------------------------
- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
   NSData *data=[[mSceneTextView string] dataUsingEncoding:NSUTF8StringEncoding/* NSMacOSRomanStringEncoding*/
   					allowLossyConversion:YES];
    if ( data == nil && outError != NULL )
		{
		*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:NULL];
	}
	return data;
}

//---------------------------------------------------------------------
// - (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
//---------------------------------------------------------------------
- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
	mStringFromFileIsColored=NO;


//	@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}
	[self setMutableAttributedStringFromFile:[[[NSMutableAttributedString alloc] initWithData:data options:	@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]} documentAttributes:nil error:nil]autorelease]];
	[self recolorCompleteAttributedString:[self mutableAttibutedStringFromFile] sender:self];

	mStringFromFileIsColored=YES;
	if (mSceneTextView !=nil)	//nib not loaded yet
	{
		[[mSceneTextView textStorage] setAttributedString: [self mutableAttibutedStringFromFile ]];
		[self setMutableAttributedStringFromFile:nil];
	}
	return YES;

}

//---------------------------------------------------------------------
// - (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
//---------------------------------------------------------------------
- (BOOL)readFromURL:(NSURL *)absoluteURL ofType:(NSString *)typeName error:(NSError **)outError
{
	NSFileManager *fileManager=[NSFileManager defaultManager];
	BOOL isDirectory;
	NSString *filePath=[absoluteURL path];
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
	#ifdef debugFileLoading
		mDateSincePrevious=[NSDate date];
	#endif
	
	if ( [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory])
	{
		if ( isDirectory == YES)	// we do not open directories
		{
			if (outError != nil)
			{
				[userInfo setObject:NSLocalizedStringFromTable(@"DirectoryCanNotBeLoaded", @"applicationLocalized", @"") forKey:NSLocalizedFailureReasonErrorKey];
				*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:userInfo];
			}
		}
		else // it is a regular file
		{
			NSFileHandle *fHandle=[NSFileHandle fileHandleForReadingFromURL:absoluteURL error:nil];
			if( fHandle == nil)
			{
				[userInfo setObject:NSLocalizedStringFromTable(@"NoFileHandleForReading", @"applicationLocalized", @"") forKey:NSLocalizedFailureReasonErrorKey];
				if ( outError!=nil)
					*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:userInfo];
				return NO;
			}// file handle is nil
			unsigned long long fileSize=[fHandle seekToEndOfFile];
			[fHandle closeFile];

			if ( fileSize/(1024*1024) > 25l)
			{
				NSString *messageString=[NSString stringWithFormat:NSLocalizedStringFromTable(@"FileIsHuge", @"applicationLocalized", @" is larger than ")];
				NSString *hugeString=[NSString stringWithString:[absoluteURL lastPathComponent]];
				hugeString=[hugeString stringByAppendingString:messageString];
				hugeString =[hugeString stringByAppendingString:@"25Mb."];
				int res=NSRunAlertPanel( hugeString,
																NSLocalizedStringFromTable(@"StillLoad", @"applicationLocalized", @"Load with color off, color on or skip loading?"),
																	NSLocalizedStringFromTable(@"DontLoad", @"applicationLocalized", @"Skip"),
																NSLocalizedStringFromTable(@"ColorOn", @"applicationLocalized", @"Color on"),
																NSLocalizedStringFromTable(@"ColorOff", @"applicationLocalized", @"Color off"),
																nil);
				if ( res == NSAlertDefaultReturn) //cancel
				{
					if (outError != nil)
						*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSUserCancelledError userInfo:nil];
					return NO;
				}
				else if (res == NSAlertOtherReturn)	// color off
				{
					mSyntaxColoringOn=NO;
				}
				else	//color on
				{
					mSyntaxColoringOn=YES;
				}
			}

			NSMutableAttributedString *loadedString=nil;
				#ifdef debugFileLoading
				NSLog(@"Reading file from disk");
			#endif
			// try to load the file with NSUTF8-endocing (will work for 99%)
			loadedString=[[[NSMutableAttributedString alloc] initWithURL:absoluteURL options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSUTF8StringEncoding]}  documentAttributes:nil error:outError/*&theError*/]autorelease];

			if ( loadedString == nil) // probably not a UTF8-encoded file Try Mac roman encoding
				loadedString=[[[NSMutableAttributedString alloc] initWithURL:absoluteURL options:@{ NSDocumentTypeDocumentAttribute: NSPlainTextDocumentType, NSCharacterEncodingDocumentAttribute: [NSNumber numberWithInt:NSMacOSRomanStringEncoding]}  documentAttributes:nil error:outError/*&theError*/]autorelease];

			if (loadedString == nil) // no utf8 or Mac roman exit
				return NO;

			if (loadedString != nil )
			{
				fileInTime(@"Loading file done in time:%lf since previous:%f")
				// replace dos line endings and mac line endings with unix line endings
				NSMutableString *tString=[loadedString mutableString];
			  NSRange entireString = NSMakeRange (0, [loadedString length]);
				[tString replaceOccurrencesOfString:@"\r\n" withString:@"\n" options:NSLiteralSearch range:entireString];
			  entireString = NSMakeRange (0, [loadedString length]);
				[tString replaceOccurrencesOfString:@"\r" withString:@"\n" options:NSLiteralSearch range:entireString];

				fileInTime(@"replaced dos and mac line endings in time:%lf since previous:%f")
				mStringFromFileIsColored=NO;
				[self recolorCompleteAttributedString:loadedString sender:self];
				mStringFromFileIsColored=YES;
				[self setMutableAttributedStringFromFile:loadedString];
				fileInTime(@"Setting string done in time:%lf since previous:%f")
				return YES;
			}
		}
	} //( [fileManager fileExistsAtPath:filePath isDirectory:&isDirectory])
	else if (outError != nil)// file didn't exist give an unkonw error
	{
		[userInfo setObject:NSLocalizedStringFromTable(@"UnknowErrorLoadingFile", @"applicationLocalized", @"") 	 forKey:NSLocalizedFailureReasonErrorKey];
		*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadUnknownError userInfo:userInfo];
	}
	return NO;
}
//---------------------------------------------------------------------
// loadFileWrapperRepresentation
//---------------------------------------------------------------------
// loads a bundle, not implemented
//---------------------------------------------------------------------
/*- (BOOL)readFromFileWrapper:(NSFileWrapper *)fileWrapper ofType:(NSString *)typeName error:(NSError **)outError
{
	NSLog(@"from warpper typename: %@ filename:%@",typeName,[fileWrapper filename]);
	NSLog(@"attributes %@",fileWrapper.fileAttributes);
	if ([fileWrapper isRegularFile])
		NSLog(@"is regularfile");
	else
		NSLog(@"is not regular file");

	if (outError != nil)
		*outError = [NSError errorWithDomain:@"co.uk.animPaint.ErrrorDomain" code:20 userInfo:NULL];
	return NO;
}*/

//---------------------------------------------------------------------
// insertStringForEachLineInSelectedRange
//---------------------------------------------------------------------
-(void) insertStringForEachLineInSelectedRange:(NSString*)StringToInsert
{

//	[[mSceneTextView textStorage] beginEditing];
	NSRange originalSelectedRange=[mSceneTextView selectedRange];

NS_DURING
	NSUInteger lengte=[StringToInsert length];
	NSRange rangeToRemove;
	NSString *str = [[mSceneTextView textStorage] string];
	NSUInteger sizeAdded=0;
	NSRange lineRange=[str lineRangeForRange:[mSceneTextView selectedRange]];
	originalSelectedRange.location=lineRange.location;	// after inserting we always positon at the beginning of the line
	//We will start with the last line in the selection 
	//and move up to the first line
	NSRange lastLineRange;
	if ( lineRange.length > 0)
		lastLineRange=[str lineRangeForRange:NSMakeRange(lineRange.location+lineRange.length-1, 0)];
	else
		lastLineRange=[str lineRangeForRange:NSMakeRange(lineRange.location+lineRange.length, 0)];

	BOOL firstLine=NO;
	do
	{
		rangeToRemove=NSMakeRange(lastLineRange.location,0);
		[mSceneTextView setSelectedRange:rangeToRemove];
		if ( lastLineRange.location==lineRange.location)	
			firstLine=YES;
		[mSceneTextView insertText:StringToInsert];
		sizeAdded+=lengte;
		if ( lastLineRange.location==0)
			break;
		lastLineRange=[str lineRangeForRange:NSMakeRange(lastLineRange.location-1, 0)];
	}while(firstLine==NO);

	if ( originalSelectedRange.length>1)	// more than one line selected to begin with?
		originalSelectedRange.length+=sizeAdded;
NS_HANDLER
//	[[mSceneTextView textStorage] endEditing];
//	[mSceneTextView setSelectedRange:originalSelectedRange];
//	return;
NS_ENDHANDLER
//	[[mSceneTextView textStorage] endEditing];
	[mSceneTextView setSelectedRange:originalSelectedRange];
}

//---------------------------------------------------------------------
// removeStringForEachLineInSelectedRange
//---------------------------------------------------------------------
-(void) removeStringForEachLineInSelectedRange:(NSString*)StringToInsert
{
//	[[mSceneTextView textStorage] beginEditing];
	NSRange originalSelectedRange=[mSceneTextView selectedRange];
NS_DURING
	NSUInteger lengte=[StringToInsert length];
	NSRange rangeToRemove;
	NSString *str = [[mSceneTextView textStorage] string];
	NSUInteger sizeRemoved=0;
	NSRange lineRange=[str lineRangeForRange:[mSceneTextView selectedRange]];	

	//NSLog(@"rangestart: %d length: %d",lineRange.location, lineRange.length);
	//We will start with the last line in the selection 
	//and move up to the first line
	NSRange lastLineRange;
	if ( lineRange.length > 0)
		lastLineRange=[str lineRangeForRange:NSMakeRange(lineRange.location+lineRange.length-1, 0)];
	else
		lastLineRange=[str lineRangeForRange:NSMakeRange(lineRange.location+lineRange.length, 0)];

	do
	{
		rangeToRemove=NSMakeRange(lastLineRange.location,lengte);
		if ( [str length] < (rangeToRemove.location+rangeToRemove.length))
			break;
		if ( [str compare:StringToInsert options:NSLiteralSearch range:rangeToRemove] ==NSOrderedSame)
		{
			[mSceneTextView setSelectedRange:rangeToRemove];
			[mSceneTextView insertText:@""];
			sizeRemoved+=lengte;
			if ( rangeToRemove.location < originalSelectedRange.location)
				originalSelectedRange.location-=lengte;
		}
		if ( lastLineRange.location==0)
			break;
		lastLineRange=[str lineRangeForRange:NSMakeRange(lastLineRange.location-1, 0)];
	}while ( lastLineRange.location >=originalSelectedRange.location);
	

		if ( originalSelectedRange.length > 1)// more than one line selected to begin with?
		originalSelectedRange.length-=sizeRemoved;

NS_HANDLER
//	[[mSceneTextView textStorage] endEditing];
//	[mSceneTextView setSelectedRange:originalSelectedRange];
//	return;
NS_ENDHANDLER
//	[[mSceneTextView textStorage] endEditing];
	//if ( originalSelectedRange.location<0)
	//	originalSelectedRange.location=0;
	[mSceneTextView setSelectedRange:originalSelectedRange];
	
}

//---------------------------------------------------------------------
// shiftSelectionToTheLeft
//---------------------------------------------------------------------
-(IBAction)shiftSelectionToTheLeft:(id)sender
{
	[self removeStringForEachLineInSelectedRange:@"\t"];
}

//---------------------------------------------------------------------
// shiftSelectionToTheRight
//---------------------------------------------------------------------
-(IBAction)shiftSelectionToTheRight:(id)sender
{
	[self insertStringForEachLineInSelectedRange:@"\t" ];
}

//---------------------------------------------------------------------
// makeSelectionComment
//---------------------------------------------------------------------
-(IBAction)makeSelectionComment:(id)sender
{
	[self insertStringForEachLineInSelectedRange:@"//" ];
}

//---------------------------------------------------------------------
// uncommentSelection
//---------------------------------------------------------------------
-(IBAction)uncommentSelection:(id)sender
{
	[self removeStringForEachLineInSelectedRange:@"//"];
}

//---------------------------------------------------------------------
// selectLine
//---------------------------------------------------------------------
-(void) selectLine:(unsigned )lineNumber
{
	NSString *str = [[mSceneTextView textStorage] string];
	if ( str)
	{
		NSUInteger strLength=[str length];
		NSRange range={0,1};
		NSUInteger line=0;
		NSUInteger startIndex=0,pastTerminator=0,contentsEnd=0;
		while (line != lineNumber && range.location <strLength)
		{
			[str getLineStart:&startIndex
				end: &pastTerminator
				contentsEnd:&contentsEnd
				forRange: range];
			line++;
			range.location=pastTerminator;
			range.length=1;
		}
		range.location=startIndex;
		range.length=contentsEnd-startIndex;
		[mSceneTextView setSelectedRange:range];
		[mSceneTextView scrollRangeToVisible:range];
	}
}

//---------------------------------------------------------------------
// gotoLine
//---------------------------------------------------------------------
- (IBAction) gotoLine: (id)sender
{
	if ( sender == gotoEdit)
	{
		[self selectLine:[gotoEdit intValue]];
		[[self window] performSelector:@selector(makeFirstResponder:) withObject:mSceneTextView afterDelay:0];
	}
	else
	{
		//[goToPanel makeKeyAndOrderFront: self];
		[[NSApplication sharedApplication] beginSheet:mGotoPanel 
				modalForWindow:[self window] modalDelegate:self 
				didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
	}
}

//---------------------------------------------------------------------
// gotoLineCanel
//---------------------------------------------------------------------
-(IBAction) gotoLineCanel: (id)sender
{
	[[NSApplication sharedApplication] endSheet: mGotoPanel];
}

//---------------------------------------------------------------------
// sheetDidEnd
//---------------------------------------------------------------------
-(void) sheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	[sheet orderOut: nil];
}


//---------------------------------------------------------------------
// gotoLineOk
//---------------------------------------------------------------------
-(IBAction) gotoLineOk:(id)sender
{
	[self selectLine:[mGotoPanelLineNumber intValue]];
	[[NSApplication sharedApplication] endSheet: mGotoPanel];
}

#pragma mark ----- toolbar
//---------------------------------------------------------------------
// validateToolbarItem
//---------------------------------------------------------------------
- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{ 
	BOOL ret = YES;
	if ([[toolbarItem itemIdentifier] isEqual:removeCommentToolbarItemIdentifier]) 
	{
	}
	else if ([[toolbarItem itemIdentifier] isEqual:renderSceneDocumentToolBarItemIdintifier]) 
	{
		ret=[[renderDispatcher sharedInstance] canStartNewRender];
	}
	else if ([[toolbarItem itemIdentifier] isEqual:sceneDocumentInPrefsToolbarItemIdentifier]) 
	{
		if ( [[self fileURL]path] != nil && [[[self fileURL]path ]length])
			ret=YES;
		else
			ret=NO;
	}

	return ret;
}

//---------------------------------------------------------------------
// toolbar
//---------------------------------------------------------------------
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar   itemForItemIdentifier:(NSString *)itemIdent
										 willBeInsertedIntoToolbar:(BOOL)willBeInserted
{
    NSToolbarItem *toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdent];

    [toolbarItem autorelease];
    if ([itemIdent isEqual:renderSceneDocumentToolBarItemIdintifier]) 
    { 
        [toolbarItem setLabel:dToolbarRenderLabel ];
        [toolbarItem setPaletteLabel: dToolbarRenderPaletteLabel];
        [toolbarItem setToolTip:dToolbarRenderTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"render"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(renderDocument)];
    } 
    else if([itemIdent isEqual:sceneDocumentInPrefsToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarPrepareLabel];
        [toolbarItem setPaletteLabel: dToolbarPreparePaletteLabel];
        [toolbarItem setToolTip:dToolbarPrepareTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"prefs"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(moveDocumentToRenderingPreferences)];
    } 
    else if([itemIdent isEqual:moveRightToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarShiftRLabel];
        [toolbarItem setPaletteLabel: dToolbarShiftRPaletteLabel];
        [toolbarItem setToolTip:dToolbarShiftRTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"shift_r"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(shiftSelectionToTheRight:)];
    } 
    else if([itemIdent isEqual:moveLeftToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarShiftLLabel];
        [toolbarItem setPaletteLabel: dToolbarShiftLPaletteLabel];
        [toolbarItem setToolTip:dToolbarShiftLTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"shift_l"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(shiftSelectionToTheLeft:)];
    } 
    else if([itemIdent isEqual:commentToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarAddCommentLabel];
        [toolbarItem setPaletteLabel: dToolbarAddCommentPaletteLabel];
        [toolbarItem setToolTip:dToolbarAddCommentTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"comment"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(makeSelectionComment:)];
    } 
    else if([itemIdent isEqual:removeCommentToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarRemoveCommentLabel];
        [toolbarItem setPaletteLabel: dToolbarRemoveCommentPaletteLabel];
        [toolbarItem setToolTip:dToolbarRemoveCommentTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"no_comment"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(uncommentSelection:)];
    } 
    else if([itemIdent isEqual:bracesToolbarItemIdentifier]) 
     { // a basic button item
        [toolbarItem setLabel: dToolbarBalanceBracesLabel];
        [toolbarItem setPaletteLabel: dToolbarBalanceBracesPaletteLabel];
        [toolbarItem setToolTip:dToolbarBalanceBracesTooltipLabel];
        [toolbarItem setImage:[NSImage imageNamed: @"brace"]];
        [toolbarItem setTarget: self];
        [toolbarItem setAction: @selector(checkBracesSceneDocument:)];
    } 

    else
    	return nil;

    return toolbarItem;
}

//---------------------------------------------------------------------
// toolbarDefaultItemIdentifiers
//---------------------------------------------------------------------
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of the items found in the default toolbar
    return [NSArray arrayWithObjects:
        NSToolbarPrintItemIdentifier, 
        NSToolbarSeparatorItemIdentifier,
        commentToolbarItemIdentifier,
        removeCommentToolbarItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        moveLeftToolbarItemIdentifier,
        moveRightToolbarItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
        renderSceneDocumentToolBarItemIdintifier,
        sceneDocumentInPrefsToolbarItemIdentifier,
        NSToolbarSeparatorItemIdentifier,
		bracesToolbarItemIdentifier,
       NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier, 
        nil];
}

//---------------------------------------------------------------------
// toolbarAllowedItemIdentifiers
//---------------------------------------------------------------------
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{ // return an array of all the items that can be put in the toolbar
    return [NSArray arrayWithObjects:
        NSToolbarPrintItemIdentifier, 
        renderSceneDocumentToolBarItemIdintifier,
        sceneDocumentInPrefsToolbarItemIdentifier, 
        moveLeftToolbarItemIdentifier,
        moveRightToolbarItemIdentifier,
        commentToolbarItemIdentifier,
        removeCommentToolbarItemIdentifier,
		bracesToolbarItemIdentifier,
        NSToolbarCustomizeToolbarItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier, 
        NSToolbarSpaceItemIdentifier,
        NSToolbarSeparatorItemIdentifier, nil];
}

//---------------------------------------------------------------------
// toolbarWillAddItem
//---------------------------------------------------------------------
- (void)toolbarWillAddItem:(NSNotification *)notification
{ // lets us modify items (target, action, tool tip, etc.) as they are added to toolbar
    NSToolbarItem *addedItem = [[notification userInfo] objectForKey: @"item"];
    if ([[addedItem itemIdentifier] isEqual:NSToolbarPrintItemIdentifier]) {
        [addedItem setToolTip: @"Print Document"];
        [addedItem setTarget:self];
    }
}

//---------------------------------------------------------------------
// toolbarDidRemoveItem
//---------------------------------------------------------------------
- (void)toolbarDidRemoveItem:(NSNotification *)notification
{ // handle removal of items.  We have an item that could be a target, so that needs to be reset
 /*   NSToolbarItem *removedItem = [[notification userInfo] objectForKey: @"item"];
    if (removedItem == angleItem) {
        [angleField setTarget:nil];
    }*/
}


//---------------------------------------------------------------------
// initializeToolbar
//---------------------------------------------------------------------
- (void)initializeToolbar
{
    NSToolbar *toolbar = [[NSToolbar alloc] initWithIdentifier:sceneDocumentToolbarIdentifier];
    [toolbar setAllowsUserCustomization:YES];
    [toolbar setAutosavesConfiguration:YES];
    [toolbar setDisplayMode:NSToolbarDisplayModeIconOnly];
    [toolbar setDelegate:self];
    [[self window] setToolbar:toolbar];
    [toolbar release];
}

//---------------------------------------------------------------------
// textStorageDidProcessEditingNotification
//---------------------------------------------------------------------
//	Part of the text was changed. Recolor it.
//---------------------------------------------------------------------
-(void) NSTextStorageWillProcessEditingNotification: (NSNotification*)notification
{
/*
	NSTextStorage *textStorage = [notification object];
	NSString *fullString=[textStorage string];
	NSRange range = [textStorage editedRange];
	int changeInLength=[textStorage changeInLength];
	NSRange originalRange=range;
		NSRange effectiveRange;
	id rangeMode;*/
}


//---------------------------------------------------------------------
// checkStringRangeForMacroDeclareOrLocal
//---------------------------------------------------------------------
-(void) checkStringRangeForMacroDeclareOrLocal:(NSString*)fullString forRange:(NSRange)lastLineRange
{

	// the part of the text we will change
	NSString *affectedText=[fullString substringWithRange:lastLineRange];

	NSRange foundRange;

	//mNewMacro, mNewDeclare,.. can be set to yes in 
	//textView: shouldChangeTextInRange
	// but when we leave this method we reset all to NO
	if ( mNewMacro == NO )	
	{
		foundRange= [affectedText rangeOfString:@"#macro" options:NSLiteralSearch ];
		if ( foundRange.location != NSNotFound )
			mNewMacro = YES;
	}
	if ( mNewDeclare ==NO )	
	{
		 foundRange = [affectedText rangeOfString:@"#declare" options:NSLiteralSearch ];
		if ( foundRange.location != NSNotFound )
			mNewDeclare = YES;
		 foundRange= [affectedText rangeOfString:@"#local" options:NSLiteralSearch ];
		if ( foundRange.location != NSNotFound )
			mNewDeclare = YES;
	}

	if ( mNewInclude == NO )	
	{
		 foundRange= [affectedText rangeOfString:@"#include" options:NSLiteralSearch ];
		if ( foundRange.location != NSNotFound )
			mNewInclude = YES;
	}
}//---------------------------------------------------------------------
// textViewDidChangeSelectionNotification
//---------------------------------------------------------------------
// keeps track op line number in the bottom of the window
//---------------------------------------------------------------------
-(void) textViewDidChangeSelectionNotification: (NSNotification*)notification
{
	NSRange range=[mSceneTextView selectedRange];

	NSUInteger line = 1;
	NSString *str = [[mSceneTextView textStorage] string];
//	NSUInteger strLength=[str length];
	unichar (*IMPcharacterAtIndex)(id, SEL, NSUInteger);
	unichar t;
	IMPcharacterAtIndex = (unichar (*)(id, SEL, NSUInteger))[str methodForSelector:mSELcharacterAtIndex];

	if ( str != nil )
	{
		for (NSUInteger pos=0; pos < range.location; pos++)
		{
			t=IMPcharacterAtIndex(str, mSELcharacterAtIndex, pos);
			if ( t=='\n')
				line ++;
		}
	}
	[gotoEdit setIntValue:line];
	[mSceneTextView setTypingAttributes:[[appPreferencesController sharedInstance] style: cBlackStyle ]];

}


//---------------------------------------------------------------------
// textViewWillChangeNotifyingTextViewNotification
//---------------------------------------------------------------------
-(void) textViewWillChangeNotifyingTextViewNotification: (NSNotification*)notification
{
	NSDictionary *userinfo=[notification userInfo];
	
	[[NSNotificationCenter defaultCenter] 
		addObserver:self 
		selector:@selector(textViewDidChangeSelectionNotification:)
		name: NSTextViewDidChangeSelectionNotification
		object: [userinfo objectForKey:@"NSNewNotifyingTextView"]];

}

//---------------------------------------------------------------------
// textStorageDidProcessEditingNotification
//---------------------------------------------------------------------
//	Part of the text was changed. Recolor it.
//---------------------------------------------------------------------
-(void) textStorageDidProcessEditingNotification: (NSNotification*)notification
{
	if (mSyntaxColoringOn == NO) // no syntaxcoloring so go home ;-)
		return;
	
	NSTextStorage *textStorage = [notification object];
	
	//only recolor if we changed characters,
	// not if attributes are changed
	if ( [textStorage editedMask] == NSTextStorageEditedAttributes)
		return;
	
	NSRange tempRange;
 	NSUInteger beginOfNextLine, beginOfContentsEnd, beginOfPreviousLine;
	NSRange rangeWhereAttributeWasFound=NSMakeRange(0,0);
	NSRange editedRange = [textStorage editedRange];
	NSInteger changeInLength=[textStorage changeInLength];
	NSString *fullString=[textStorage string];
	NSUInteger fullStringLength=[fullString length];
	id range=nil;
	
	NSCharacterSet *whiteSpaceAndLineEnding=[NSCharacterSet whitespaceAndNewlineCharacterSet];
//	NSCharacterSet *whiteSpaceAndLineEnding=[NSCharacterSet characterSetWithCharactersInString:[NSString stringWithString:@"\n\t\r"] ];
	
	if ( fullStringLength == 0)
		[self recolorCompleteAttributedString:nil sender:self];
	else
	{
		// find the range of the first character and the last, inlcuding line ending
		// of the line(s) within the edited range
		NSRange rangeOfEditedRegion=[fullString lineRangeForRange:NSMakeRange(editedRange.location,editedRange.length)];
		// now extend that range to the top of the text until all blanc lines are included
		// and if the first non blanc line is a comment include that region
		NSRange previousLineRange=rangeOfEditedRegion;
		previousLineRange.length=1;
		NSUInteger newRegionLocation=previousLineRange.location;
		if ( rangeOfEditedRegion.location > 0)	// make sure we stay in the bounds of the string
		{
			BOOL stop=NO;
			while ( stop==NO && previousLineRange.location > 0)
			{
				// find the line just before the current editedregion
				previousLineRange.location--;
				[fullString getLineStart:&beginOfPreviousLine end:NULL contentsEnd:&beginOfContentsEnd  forRange:previousLineRange];
				NSString *trimString=[fullString substringWithRange:NSMakeRange(beginOfPreviousLine,beginOfContentsEnd-beginOfPreviousLine) ];
				trimString=[trimString stringByTrimmingCharactersInSet:whiteSpaceAndLineEnding];
				if ( [trimString length]==0) // we have a blanc line
				{
					previousLineRange.location=beginOfPreviousLine;
					newRegionLocation=beginOfPreviousLine;
				}
				else
				{
					// check if it is a line with comment
					range=[textStorage attribute: commentAndStringAttributeName atIndex: beginOfPreviousLine effectiveRange: &rangeWhereAttributeWasFound ];
					if (range != nil)// the first none blanc line is a comment so includ the whole range and skip
						newRegionLocation=rangeWhereAttributeWasFound.location;
					// is is not a blanc line, if it was a comment line the range is included
					// in any case we stop here because we hit a keyword or something else but not
					// a blanc line or comment range
					break;
				}
				
			}
			// add to the original length of the editedregion the number of positions
			// we moved back to the top to get the new location of the editedregion.
			// if we don't do this, we only shift the edited region tot the top
			// the end of the region must remain at the same positon
			rangeOfEditedRegion.length+=rangeOfEditedRegion.location-newRegionLocation;
			// and now set the new start location
			rangeOfEditedRegion.location = newRegionLocation;
		}
		
		// find the first character of the next line past the last line of last line in range
		[fullString getLineStart:NULL end:&beginOfNextLine contentsEnd:NULL  forRange:rangeOfEditedRegion];
		
		// calculate the part we will have to recolor
		NSRange rangeToRecolor = rangeOfEditedRegion;
		//if the start of the region to recolor is the same
		// as the length of the text, there is nothing to do
		if ( rangeToRecolor.location != fullStringLength)
		{
			range=[textStorage attribute: commentAndStringAttributeName atIndex: rangeToRecolor.location effectiveRange: &rangeWhereAttributeWasFound ];
			if ( range)
				rangeToRecolor = NSUnionRange( rangeToRecolor, rangeWhereAttributeWasFound );
			
			//include the next line
			if ( beginOfNextLine != fullStringLength)
			{
				range=[textStorage attribute: commentAndStringAttributeName atIndex: beginOfNextLine effectiveRange: &rangeWhereAttributeWasFound	];
				if ( range)
					rangeToRecolor = NSUnionRange( rangeToRecolor, rangeWhereAttributeWasFound );
			}
			[self checkStringRangeForMacroDeclareOrLocal:fullString forRange:rangeOfEditedRegion];
			
			if ( mNewDeclare==YES || mNewMacro==YES )
			{
				declareMessage(@"new Declare")
				shakeMessageForRange(@"2 recoloring attributed string for comment location:%lu length: %lu",rangeToRecolor)
				[self recolorAttributedString:[mSceneTextView textStorage] forRange:rangeToRecolor recoloringType:cComment blackSet:NO];
			}
		}
		
		
		// now, rebuild the popups if needed
		// #macros and defines in comment are ignored
		if ( mNewMacro==YES)
		{
			[self buildMacro:[mSceneTextView textStorage]];
		}
		
		if ( mNewDeclare==YES)
		{
			[self buildDeclare:[mSceneTextView textStorage]];
		}
		
		if ( mNewInclude==YES)
		{
				[self buildInclude:[mSceneTextView textStorage]];
		
		}

		if ( mNewDeclare==YES || mNewMacro==YES )
		{
			// in case only one popup was rebuild, update positin for other one
			if ( mNewMacro == NO)	// no new macro so we need to update those
			{
				for (int z=1; z<=mNumberOfMacros; z++)
				{
					if ( mMacroList[z-1].location > editedRange.location)
						mMacroList[z-1].location+=changeInLength;
				}
			}
			if ( mNewDeclare == NO)	// no new declares so we need to update those
			{
				for (int z=1; z<=mNumberOfDeclares; z++)
				{
					if ( mDeclareList[z-1].location > editedRange.location)
						mDeclareList[z-1].location+=changeInLength;
				}
			}
			mNewMacro=mNewDeclare=mNewInclude=NO;
			tempRange=NSMakeRange(0,[[mSceneTextView textStorage] length]);
			colorTimeStartRange(@"Recolor Range for keywords from storageDidprocess new macro start: %ld size:%ld",tempRange)
			shakeMessageForRange(@"3 recoloring attributed string for keywords location:%lu length: %lu",tempRange)
			[self recolorAttributedString:[mSceneTextView textStorage] forRange:tempRange recoloringType:cKeywords blackSet:NO];
			colorInTime(@"******done recoloring keywords from storageDidProcess new macro since start:%f in time:%f")
		}//if ( mNewDeclare==YES || mNewMacro==YES )
		else	//update position of macro's and declares
		{
			[self recolorAttributedString:[mSceneTextView textStorage] forRange:rangeToRecolor recoloringType:cAll blackSet:NO];
			if ( fullStringLength ==0)
				goto bail;
			if ( mEffectiveRecoloredRange.location >= fullStringLength)
			{
				mEffectiveRecoloredRange.location = fullStringLength;
				if (  fullStringLength > 0)
					mEffectiveRecoloredRange.location --;
			}
			if ( mEffectiveRecoloredRange.length + mEffectiveRecoloredRange.location > fullStringLength)
				mEffectiveRecoloredRange.length = 1;
			
			[self checkStringRangeForMacroDeclareOrLocal:fullString forRange:mEffectiveRecoloredRange];
			// now, rebuild the popups if needed
			// #macros and defines in comment are ignored
			if ( mNewMacro==YES)
				[self buildMacro:[mSceneTextView textStorage]];
			if ( mNewDeclare==YES)
				[self buildDeclare:[mSceneTextView textStorage]];
			if ( mNewInclude==YES)
				[self buildInclude:[mSceneTextView textStorage]];
			
			if ( mNewDeclare==YES || mNewMacro==YES )
			{
				declareMessage(@"new Declare below")
				mNewMacro=mNewDeclare=mNewInclude=NO;
				tempRange=NSMakeRange(0,[[mSceneTextView textStorage] length]);
				colorTimeStartRange(@"Recolor Range for keywords from storageDidprocess last start: %ld size:%ld",tempRange);
				shakeMessageForRange(@"4 recoloring attributed string for keywords location:%lu length: %lu",tempRange)
				[self recolorAttributedString:[mSceneTextView textStorage] forRange: tempRange recoloringType:cKeywords blackSet:NO];
				colorInTime(@"******done recoloring keywords from storageDidProcess last since start:%f in time:%f")
				goto bail;
				
			}
			for (int z=1; z<=mNumberOfMacros; z++)
			{
				if ( mMacroList[z-1].location > editedRange.location)
					mMacroList[z-1].location+=changeInLength;
			}
			for (int z=1; z<=mNumberOfDeclares; z++)
			{
				if ( mDeclareList[z-1].location > editedRange.location)
					mDeclareList[z-1].location+=changeInLength;
			}
		}
	}//if ( [fullString length]==0)
	
bail:
	mNewMacro=NO;
	mNewDeclare=NO;
	mNewInclude=NO;
	
}

//---------------------------------------------------------------------
// textView:shouldChangeTextinRange:replacementString:
//---------------------------------------------------------------------
-(BOOL) textView:(NSTextView *)tv shouldChangeTextInRange:(NSRange)affectedCharRange replacementString:(NSString *)replacementString
{
	#ifdef debugColorSyntax
		NSLog(@"shouldchangetextinrage begin:%@",replacementString);
	#endif
	if ( affectedCharRange.length > 0) // something was deleted or replaced
	{																					// check if there was a #macro or #declare
		NSUInteger startIndex,contentsEnd;
		NSRange foundRange;
		NSString *temp=[[mSceneTextView textStorage]string];
		[temp getLineStart:&startIndex end:NULL contentsEnd:&contentsEnd forRange:affectedCharRange];
		foundRange= [temp rangeOfString:@"#macro" options:NSLiteralSearch range:NSMakeRange(startIndex,contentsEnd-startIndex)];
		if ( foundRange.location != NSNotFound )
			mNewMacro=YES;
		 foundRange= [temp rangeOfString:@"#declare" options:NSLiteralSearch range:NSMakeRange(startIndex,contentsEnd-startIndex)];
		if ( foundRange.location != NSNotFound )
			mNewDeclare=YES;
		 foundRange= [temp rangeOfString:@"#local" options:NSLiteralSearch range:NSMakeRange(startIndex,contentsEnd-startIndex)];
		if ( foundRange.location != NSNotFound )
			mNewDeclare=YES;

		 foundRange= [temp rangeOfString:@"#include" options:NSLiteralSearch range:NSMakeRange(startIndex,contentsEnd-startIndex)];
		if ( foundRange.location != NSNotFound )
			mNewInclude=YES;
	}
	#ifdef debugColorSyntax
		NSLog(@"newmacro:%d newdeclare:%d newinclude:%d",mNewMacro, mNewDeclare,mNewInclude);
	#endif

	return YES;
}

//---------------------------------------------------------------------
// checkBracesSceneDocument
//---------------------------------------------------------------------
-(IBAction)checkBracesSceneDocument:(id)sender
{
	[mSceneTextView checkBracesTextView];
}

//---------------------------------------------------------------------
// saveDocument
//---------------------------------------------------------------------
// because of a bug (document is not marked dirty after a save when
// adding text to the end of the file) we overwrite this
// and call -breakUndoCoalescing so that the receiver should
// begin coalescing sucessive typing operations in a new undo grouping
//---------------------------------------------------------------------
// 12/04/2008 use saveDocumentWithDelegate instead, called when menu item "save"
// is selected and when called directly before a render
//---------------------------------------------------------------------
/*-(IBAction) saveDocument:(id)sender
{
	[super saveDocument:sender];
	// only available in version 10.4 and later
	if ( [mSceneTextView respondsToSelector:@selector(breakUndoCoalescing)])
	{
		[mSceneTextView breakUndoCoalescing];
	}
}
*/
//---------------------------------------------------------------------
// saveDocumentWithDelegate
//---------------------------------------------------------------------
// because of a bug (document is not marked dirty after a save when
// adding text to the end of the file) we overwrite this
// and call -breakUndoCoalescing so that the receiver should
// begin coalescing sucessive typing operations in a new undo grouping
//---------------------------------------------------------------------
- (void)saveDocumentWithDelegate:(id)delegate didSaveSelector:(SEL)didSaveSelector contextInfo:(void *)contextInfo
{
	[super saveDocumentWithDelegate:delegate didSaveSelector:didSaveSelector contextInfo:contextInfo];
	// only available in version 10.4 and later
	if ( [mSceneTextView respondsToSelector:@selector(breakUndoCoalescing)])
	{
		[mSceneTextView breakUndoCoalescing];
	}
}

@end


//**************************************************************************************
//**************************************************************************************
//@implementation NSScanner (SkipUpToCharset)

@implementation NSScanner (SkipUpToCharset)

//---------------------------------------------------------------------
// skipUpToCharactersFromSet
//---------------------------------------------------------------------
-(BOOL) skipUpToCharactersFromSet:(NSCharacterSet*)set
{
	NSString*		vString = [self string];
	NSUInteger				x = [self scanLocation];
	
	while( x < [vString length] )
	{
		if( ![set characterIsMember: [vString characterAtIndex: x]] )
			x++;
		else
			break;
	}
	
	if( x > [self scanLocation] )
	{
		[self setScanLocation: x];
		return YES;
	}
	else
		return NO;
}

@end

