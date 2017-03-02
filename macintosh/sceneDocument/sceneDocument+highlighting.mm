//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument+highlighting.mm
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
//******************************************************************************
#import "sceneDocument+highlighting.h"
#import "parse.h"
#import "reswords.h"

#import "appPreferencesController.h"


#define dNumberOfSpacesToReserveForMacros 50
#define dNumberOfSpacesToReserveForDeclares 250
countList sKeywordsCountList[256];
keyWords *sKeywordsList=nil;
long	sNumberOfKeyWords=0;



static NSCharacterSet *wordCharacterSet=nil;
static NSCharacterSet *commentStringBeginCharacterSet=nil;
static NSCharacterSet *toNextWordCharacterSet=nil;
static NSCharacterSet *toNextWordOrCommentOrStringCharacterSet=nil;
static NSCharacterSet *macroDeclareSet=nil;
static NSCharacterSet *newlineCharacterSet=nil;


#define updateEffectiveRecoloredRange(a, b) \
{\
	if ( mEffectiveRecoloredRange.location == NSNotFound)	\
	{ \
		mEffectiveRecoloredRange.location = a; \
		mEffectiveRecoloredRange.length = b; \
	} \
	else \
		mEffectiveRecoloredRange=NSUnionRange(mEffectiveRecoloredRange, NSMakeRange(a,b)); \
}


 static const char *sPreprocessorWords[]={
 "ifdef",
 "ifndef",
 "if",
 "while",
 "for",
 "else",
 "elseif",
 "switch",
 "case",
 "range",
 "break",
 "end",
 "while",
 "for",
 "declare",
 "local",
 "default",
 "include",
 "warning",
 "error",
 "render",
 "statistics",
 "debug",
 "fopen",
 "fclose",
 "read",
 "write",
 "undef",
 "macro",
 "version",
 nil};
 
/* "if","ifdef","ifndef","else","end","macro","while","debug","error","warning",
													"do","version","include","declare","local","default",
													"case", "break", "switch","local","set","undef","range","fopen","read","write","fclose",0l};*/

@implementation SceneDocument (highlighting)

+(void) initializeSyntaxHightlighting
{
	wordCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:
		@"#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_1234567890"]retain];
	toNextWordCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:
		@"#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"]retain];
	toNextWordOrCommentOrStringCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:
		@"\"/#ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"]retain];
	 macroDeclareSet=[[NSCharacterSet characterSetWithCharactersInString:
		@"#macrodelinu"]retain];
	 newlineCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:
		@"\n\r"]retain];
	 commentStringBeginCharacterSet=[[NSCharacterSet characterSetWithCharactersInString:@"/\""]retain];

	
	// how many keywords are there?
	// get some numbers to create buffers
	sNumberOfKeyWords=0;
	unsigned char character;
	BOOL wasPreprocessorWord=NO;
	for (NSInteger i = 0; i < pov::LAST_TOKEN; i++)
	{
		sNumberOfKeyWords++;
		const char *ptr=pov::Reserved_Words[i].Token_Name;
		for(NSInteger ppCount=0; ;ppCount++)
		{
			wasPreprocessorWord=NO;
			if ( sPreprocessorWords[ppCount]==nil)
				break;
			if (strcmp(ptr,sPreprocessorWords[ppCount])==0)
			{
				wasPreprocessorWord=YES;
				character='#';
				break;
			}
		}
		if ( wasPreprocessorWord==NO)
			character=*ptr;
		sKeywordsCountList[character].numberOfWords+=1;
	}	
	//now reserve memory
	sKeywordsList=(keyWords*)malloc(sizeof(keyWords)*sNumberOfKeyWords);
	for (NSInteger x=0; x<256; x++)
	{
		if ( sKeywordsCountList[x].numberOfWords)
		{
			sKeywordsCountList[x].pointers=(long*)malloc(sKeywordsCountList[x].numberOfWords*(long)sizeof(long*));
		}
	}
	long num=-1;
	for (NSInteger i = 0; i < sNumberOfKeyWords; i++)
	{
		const char *ptr=pov::Reserved_Words[i].Token_Name;
		for(NSInteger ppCount=0; ;ppCount++)
		{
			wasPreprocessorWord=NO;
			if ( sPreprocessorWords[ppCount]==nil)
				break;
			if (strcmp(ptr,sPreprocessorWords[ppCount])==0)
			{
				wasPreprocessorWord=YES;
				break;
			}
		}
		if ( wasPreprocessorWord==YES)
		{
			num++;
			sKeywordsList[num].wordAsNSString=[[[NSString stringWithUTF8String:"#"] stringByAppendingString:[NSString stringWithUTF8String:ptr]] retain];
			sKeywordsList[num].wordStyle=usePreprocessorStyle;
		}
		else
		{
			num++;
			sKeywordsList[num].wordAsNSString=[[NSString stringWithUTF8String:ptr] retain];
			sKeywordsList[num].wordStyle=useKeywordStyle;
		}
		char *tempPtr=(char*)[sKeywordsList[num].wordAsNSString UTF8String];
		sKeywordsList[num].wordLength=strlen(tempPtr);
		sKeywordsList[num].wordAsCString=(char*)malloc(sKeywordsList[num].wordLength);
		memcpy(sKeywordsList[num].wordAsCString,tempPtr,sKeywordsList[num].wordLength);
		unsigned char pos=*(unsigned char*)tempPtr;
		sKeywordsCountList[pos].pointers[sKeywordsCountList[pos].reserved++]=num;
	}
}

//---------------------------------------------------------------------
// releaseKeywords
//---------------------------------------------------------------------
+(void) releaseKeywords
{
	for (NSInteger x=0; x<sNumberOfKeyWords; x++)
	{
		free(sKeywordsList[x].wordAsCString);
		[sKeywordsList[x].wordAsNSString release];
	}
	free(sKeywordsList);
	sKeywordsList=NULL;
	
	for (NSInteger x=0; x<256; x++)
	{
		if ( sKeywordsCountList[x].reserved )
			free(sKeywordsCountList[x].pointers);
	}
	sNumberOfKeyWords=0;
}

//---------------------------------------------------------------------
// releaseCharacterSets
//---------------------------------------------------------------------
+(void) releaseCharacterSets
{
	[wordCharacterSet release];
	[toNextWordCharacterSet release];
	[toNextWordOrCommentOrStringCharacterSet release];
	[macroDeclareSet release];
	[newlineCharacterSet release];
	[commentStringBeginCharacterSet release];

}


//---------------------------------------------------------------------
// recolorCompleteFile
//---------------------------------------------------------------------
-(void)	recolorCompleteAttributedString:(NSMutableAttributedString*)ms sender:(id)sender
{
	colorMessage(@"Start recolor complete file in recolorCompleteAttributedString")
	if ( ms == nil)	// we need to get it from the texview
		ms=[mSceneTextView textStorage];

	NSRange tempRange=NSMakeRange(0,[ms length]);
	if (mSyntaxColoringOn == NO) // make it all black
	{
		[mIncludeList release];
		mIncludeList=nil;
		[self releaseDeclareList];
		[self releaseMacroList];
		[self rebuildMacroPopup];
		[self rebuildIncludePopup];
		[self rebuildDeclarePopup];
		if ( [ms length] != 0)
			[self recolorAttributedString:ms forRange:tempRange recoloringType:cNoColor blackSet:NO];
	}
	else if ( [ms length] != 0)

	{
	
		[self recolorAttributedString:ms forRange:tempRange recoloringType:cComment blackSet:NO	];
		
		colorTimeStart(@"start building macro")
		[self buildMacro:ms];
		colorInTime(@"*****Done building macro total time since start:%lf since previous:%f")

		colorTimeStart(@"start building declare")
		[self buildDeclare:ms];
		colorInTime(@"*****Done building declare total time since start:%lf since previous:%f")

		colorTimeStart(@"start building include")
		[self buildInclude:ms];
		colorInTime(@"*****Done building include total time since start:%lf since previous:%f")

		[self recolorAttributedString:ms forRange:tempRange recoloringType:cKeywords blackSet:YES	];
	}
}

//---------------------------------------------------------------------
// colorComments
//---------------------------------------------------------------------
-(void) recolorAttributedString:(NSMutableAttributedString*) attributedString forRange: (NSRange)range recoloringType:(int)typeToRecolor blackSet:(BOOL) blackIsSet
{
	
	if( mSyntaxColoringBusy )	// Prevent endless loop when recoloring's replacement of text causes textStorageDidProcessEditingNotification to fire again.
		return;
	//	NSMutableAttributedString *storageAttributedString=[mSceneTextView textStorage];
	if( attributedString == nil || range.length == 0 || [attributedString length]==0)	// Don't like doing useless stuff.
		return;
	[attributedString beginEditing];
	
	NS_DURING
		mSyntaxColoringBusy = YES;
		[mProgressIndicator startAnimation:nil];
	
		switch (typeToRecolor)
		{
			case cComment:
				colorTimeStartRange(@"start recoloring comment start: %ld, lengt:%ld",range)
				[self applySyntaxHighlightingOnlyComment:attributedString forRange:range blackSet:blackIsSet];
				colorInTime(@"*****Done recoloring comment total time since start:%lf since previous:%f")
				break;
			case cKeywords:
				colorTimeStartRange(@"start recoloring keywordes start: %ld, lengt:%ldl",range)
				[self applySyntaxHighlightingOnlyKeywords:attributedString forRange:range blackSet:blackIsSet];
				colorInTime(@"*****Done recoloring keywords total time since start:%lf since previous:%f")
				break;
			case cAll:
				colorTimeStartRange(@"start recoloring cAll start: %ld, lengt:%ld",range)
				[self applySyntaxHighlighting:attributedString forRange:range blackSet:blackIsSet];
				colorInTime(@"*****Done recoloring cAll total time since start:%lf since previous:%f")
				break;
			case cNoColor:
				colorTimeStartRange(@"start recoloring black start: %ld, lengt:%ld",range)
				[attributedString setAttributes: 	[[appPreferencesController sharedInstance] style: cBlackStyle ]	range:  range];
				colorInTime(@"*****Done recoloring all black total time since start:%lf since previous:%f")
				break;
		}
		mSyntaxColoringBusy = NO;
		[mProgressIndicator stopAnimation:nil];
	NS_HANDLER
		[attributedString endEditing];
		mSyntaxColoringBusy = NO;
		[mProgressIndicator stopAnimation:nil];
		[localException raise];
		return;
	NS_ENDHANDLER
	[attributedString endEditing];
}

//---------------------------------------------------------------------
// applySyntaxHighlighting
//---------------------------------------------------------------------
//	for a given range, apply syntaxhighligting.
//  make sure macro and declare popups didn't change
//  
//	All in one function. Do keywords, comments, strings, ...
//	We only do the range but going over the end if needed
//	Make sure range.length is > 0 and [ms length] > 0
//	No checking for this here
//  On exit, mRecoloredRange will contain the full range we recolored
//---------------------------------------------------------------------
-(void) applySyntaxHighlighting:(NSMutableAttributedString *) ms forRange:(NSRange) r blackSet:(BOOL) blackIsSet
{
	mEffectiveRecoloredRange.location=NSNotFound;

	long lastPosition=[ms length];	// last character in the string (not range)
	if ( lastPosition==0)	//no characters, don't do anything
		return;
	lastPosition--;	// for index
	
	NSUInteger closeLocation=0;
	NSString *s=[ms string];
	NSString *foundString;
	unichar c;
	NSScanner *scan=[NSScanner scannerWithString:s];
	[scan setCharactersToBeSkipped:nil];

	void (*IMPsetScanLocation)(id, SEL, NSUInteger);
	NSUInteger (*IMPscanLocation)(id, SEL);
	BOOL (*IMPscanUpToCharactersFromSet)(id, SEL, NSCharacterSet*, NSString**);
	unichar (*IMPcharacterAtIndex)(id, SEL, NSUInteger);
	BOOL (*IMPscanCharactersFromSet)(id, SEL, NSCharacterSet*, NSString**);

	IMPsetScanLocation = (void (*)(id, SEL, NSUInteger))[scan methodForSelector:mSELsetScanLocation];
	IMPcharacterAtIndex = (unichar (*)(id, SEL, NSUInteger))[s methodForSelector:mSELcharacterAtIndex];
	IMPscanUpToCharactersFromSet = (BOOL (*)(id, SEL, NSCharacterSet*, NSString**))[scan methodForSelector:mSELscanUpToCharactersFromSet];
	IMPscanCharactersFromSet = (BOOL (*)(id, SEL, NSCharacterSet*, NSString**))[scan methodForSelector:mSELscanCharactersFromSet];
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scan methodForSelector:mSELscanLocation];
 
	NSUInteger currentPosition=r.location;
	// if everything else but comment isn't restored to black, do it now
	if (blackIsSet == NO)
	{
		colorMessage(@"color was not set to black");
				[ms setAttributes: [[appPreferencesController sharedInstance] style: cBlackStyle ] range: r];
	}
	else
		colorMessage(@"color was set to black");
	// once passed here, only color for keywords must be applied,
	// comment and black are set
shakeMessage(@"recoloring");
	while ( currentPosition <r.location+r.length)
	{
		c=IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition);	//c=[s characterAtIndex:currentPosition];
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if (c== '/' )
		{
			if (currentPosition <lastPosition)
			{
				if (IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition+1)=='*')	//begin of multiline comment
				{
					IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition+2);
					[scan scanUpToString:@"*/" intoString:nil];
					if ( [scan scanString:@"*/" intoString:nil])	// closing found
						closeLocation=[scan scanLocation];
					else																					// not found so comment until end of text
						closeLocation=[ms length];
					[ms setAttributes: [[appPreferencesController sharedInstance] style: cMultilineCommentStyle ] range: NSMakeRange( currentPosition,closeLocation-currentPosition)];
					updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
					currentPosition=closeLocation;															// continue after this comment block
				}// if ( currentPosition <lastPosition && [s characterAtIndex:currentPosition+1]=='*")
				else if (  IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition+1)=='/')	//begin of oneline comment
				{
					IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition+1);
					IMPscanUpToCharactersFromSet(scan, mSELscanUpToCharactersFromSet, newlineCharacterSet, nil);
					closeLocation=[scan scanLocation];
					while ( closeLocation <=lastPosition && (IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation)=='\n' ||	IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation)=='\r'))
						closeLocation++;

					[ms setAttributes: [[appPreferencesController sharedInstance] style: cOnelineCommentStyle ] range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
					updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
					currentPosition=closeLocation;							// continue after this comment block
				}// else if ( currentPosition <lastPosition && [s characterAtIndex:currentPosition+1]=='/')
				else // black is set, so only update the updated range
				{
//					[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
					updateEffectiveRecoloredRange(currentPosition, 1);
					currentPosition++;							// only one character, so increase by one and continue
				}
			}
			else // black is set, so only update the updated range
			{
			//	[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
				updateEffectiveRecoloredRange(currentPosition, 1);
				currentPosition++;							// only one character, so increase by one and continue
			}
		}
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		else if ( c=='\"' ) // beginning of a string
		{
			if ( (currentPosition>0 && IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition-1)!='\\') || currentPosition==0)	// start of a string but no special character
			{
				closeLocation=currentPosition+1;
				while ( closeLocation <=lastPosition )
				{
					unichar c2=IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation);
					if (c2=='\r' || c2 == '\n')
						break;
					else if ( c2!='\"' )
						closeLocation++;
					else if (c2=='\"' && /*[s characterAtIndex:closeLocation-1] */IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation-1)=='\\' )
						closeLocation++;
					else
					{
						closeLocation++;
						break;
					}
				}
				[ms setAttributes: [[appPreferencesController sharedInstance] style: cStringStyle ] range: NSMakeRange( currentPosition,closeLocation-currentPosition)];
				updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
				currentPosition=closeLocation;							// continue after this string block
			}
			else // black is set, so only update the updated range
			{
			//	[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
				updateEffectiveRecoloredRange(currentPosition, 1);
				currentPosition++;							// only one character, so increase by one and continue
			}
			
		}
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		else if ( [wordCharacterSet characterIsMember:c]) //(c>='A' && c<='Z')  || (c>='a' && c<='z') || c=='_' || c=='#')	//start of a keyword
		{
			IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition);
			IMPscanCharactersFromSet(scan, mSELscanUpToCharactersFromSet, wordCharacterSet, &foundString);
			closeLocation=IMPscanLocation(scan, mSELscanLocation); //[scan scanLocation];
			NSDictionary *styleToApply;
			const char* utf8FoundString=[foundString UTF8String];
   		findStyleForWord(styleToApply,utf8FoundString);
		//	if ( styleToApply != blackStyle) // black is set, so only update the updated range
				[ms setAttributes:styleToApply range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
			updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
			currentPosition=closeLocation;							// continue after this keyword (if it isn't a keyword, it will be colored black anyway :-)
		}
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		else	// anything else is black is set, so only update the updated range
		{
			do_anything_else:
			IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition);
			
			IMPscanUpToCharactersFromSet(scan, mSELscanUpToCharactersFromSet, toNextWordOrCommentOrStringCharacterSet, nil);
			closeLocation=IMPscanLocation(scan, mSELscanLocation); //[scan scanLocation];
			//[ms setAttributes:blackStyle range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
			updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
			currentPosition=closeLocation;							// continue after this keyword (if it isn't a keyword, it will be colored black anyway :-)
		}
	//	currentPosition++;
	}	//while ( currentPosition <lastPosition)
}

//---------------------------------------------------------------------
// applySyntaxHighlightingNoKeywords
//---------------------------------------------------------------------
//	for a given range, apply syntaxhighligting except keywords.
//  to be complete, call -applySyntaxHighlightingOnlyKeywords
//  after this. Rebuild macro and declare popups before a call
//  to -applySyntaxHighlightingOnlyKeywords if needed.
//	We only do the range but going over the end if needed
//	Make sure range.length is > 0 and [ms length] > 0
//	No checking for this here
//  On exit, mRecoloredRange will contain the full range we recolored
//---------------------------------------------------------------------
-(void) applySyntaxHighlightingOnlyComment:(NSMutableAttributedString *) ms forRange:(NSRange) r blackSet:(BOOL) blackIsSet
{
	mEffectiveRecoloredRange.location=NSNotFound;
	unsigned lastPosition=[ms length];	// last character in the string (not range)
	if ( lastPosition==0)	//no characters, don't do anything
		return;
	lastPosition--;	// for index
	
	NSUInteger closeLocation=0;
	NSString *s=[ms string];
	unichar c;
	NSScanner *scan=[NSScanner scannerWithString:s];
	[scan setCharactersToBeSkipped:nil];

	void (*IMPsetScanLocation)(id, SEL, NSUInteger);
	NSUInteger (*IMPscanLocation)(id, SEL);
	BOOL (*IMPscanUpToCharactersFromSet)(id, SEL, NSCharacterSet*, NSString**);
	unichar (*IMPcharacterAtIndex)(id, SEL, NSUInteger);


	IMPsetScanLocation = (void (*)(id, SEL, NSUInteger))[scan methodForSelector:mSELsetScanLocation];
	IMPcharacterAtIndex = (unichar (*)(id, SEL, NSUInteger))[s methodForSelector:mSELcharacterAtIndex];
	IMPscanUpToCharactersFromSet = (BOOL (*)(id, SEL, NSCharacterSet*, NSString**))[scan methodForSelector:mSELscanUpToCharactersFromSet];
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scan methodForSelector:mSELscanLocation];

	NSUInteger currentPosition=r.location;
	// if everything else but comment isn't restored to black, do it now
	if (blackIsSet == NO)
	{
		colorMessage(@"color was not set to black");
		[ms setAttributes:[[appPreferencesController sharedInstance] style: cBlackStyle ]  range:r ];
	}
	else
		colorMessage(@"color was set to black");
	// once passed here, only color for keywords must be applied,
	// comment and black are set


	while ( currentPosition <r.location+r.length)
	{
		c=IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition);	//c=[s characterAtIndex:currentPosition];
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		if (c== '/' )
		{
			if (currentPosition <lastPosition)
			{
				//begin of multiline comment **************************************************************
				if (/*[s characterAtIndex:currentPosition+1]*/IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition+1)=='*')
				{
					IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition+2);
					//[scan setScanLocation:currentPosition+2];
					[scan scanUpToString:@"*/" intoString:nil];
					if ( [scan scanString:@"*/" intoString:nil])	// closing found
						closeLocation=[scan scanLocation];
					else																					// not found so comment until end of text
						closeLocation=[ms length];
					[ms setAttributes: [[appPreferencesController sharedInstance] style: cMultilineCommentStyle ] range: NSMakeRange( currentPosition,closeLocation-currentPosition)];
					updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
					currentPosition=closeLocation;															// continue after this comment block
				}// if ( currentPosition <lastPosition && [s characterAtIndex:currentPosition+1]=='*")

				//begin of oneline comment **************************************************************
				else if (  IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition+1)=='/')
				{
					IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition+1);
					IMPscanUpToCharactersFromSet(scan, mSELscanUpToCharactersFromSet, newlineCharacterSet, nil);
					closeLocation=[scan scanLocation];
					while ( closeLocation <=lastPosition && (IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation)=='\n' ||
											IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation)=='\r'))
						closeLocation++;

					[ms setAttributes: [[appPreferencesController sharedInstance] style: cOnelineCommentStyle ] range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
					updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
					currentPosition=closeLocation;							// continue after this comment block
				}// else if ( currentPosition <lastPosition && [s characterAtIndex:currentPosition+1]=='/')
				else // black is set, so only update the updated range
				{
				//	[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
					updateEffectiveRecoloredRange(currentPosition, 1);
					currentPosition++;							// only one character, so increase by one and continue
				}
			}
			else // black is set, so only update the updated range
			{
//				[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
				updateEffectiveRecoloredRange(currentPosition, 1);
				currentPosition++;							// only one character, so increase by one and continue
			}
		}
		//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		else if ( c=='\"' )// beginning of a string
		{
			if ( (currentPosition>0 && IMPcharacterAtIndex(s, mSELcharacterAtIndex, currentPosition-1)!='\\') || currentPosition==0)	// start of a string but no special character
			{
				closeLocation=currentPosition+1;
				while ( closeLocation <=lastPosition )
				{
					unichar c2=IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation);
					if (c2=='\r' || c2 == '\n')
						break;
					else if ( c2!='\"' )
						closeLocation++;
					else if (c2=='\"' && IMPcharacterAtIndex(s, mSELcharacterAtIndex, closeLocation-1)=='\\' )
						closeLocation++;
					else
					{
						closeLocation++;
						break;
					}
				}
				[ms setAttributes: [[appPreferencesController sharedInstance] style: cStringStyle ] range: NSMakeRange( currentPosition,closeLocation-currentPosition)];
				updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
				currentPosition=closeLocation;							// continue after this string block
			}
			else// black is set, so only update the updated range
			{
				//[ms setAttributes: 	blackStyle	range:  NSMakeRange( currentPosition,1)];
				updateEffectiveRecoloredRange(currentPosition, 1);
				currentPosition++;							// only one character, so increase by one and continue
			}
			
		}
				//+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		else	//anything else is black until a comment or string is found
		{
			do_anything_else:
			IMPsetScanLocation(scan, mSELsetScanLocation, currentPosition+1);
//			[scan setScanLocation:currentPosition];
			IMPscanUpToCharactersFromSet(scan, mSELscanUpToCharactersFromSet, commentStringBeginCharacterSet, nil);
//			[scan scanUpToCharactersFromSet:commentStringBeginCharacterSet intoString:nil];
			closeLocation=IMPscanLocation(scan, mSELscanLocation); //[scan scanLocation];
			// black is set, so only update the updated range
//			[ms setAttributes:blackStyle range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
			updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
			currentPosition=closeLocation;							// continue after this keyword (if it isn't a keyword, it will be colored black anyway :-)
		}
	}	//while ( currentPosition <lastPosition)
}

//---------------------------------------------------------------------
// replaceAllNonCommentAndStringAttributes
//---------------------------------------------------------------------
-(void) replaceAllNonCommentAndStringAttributes:(NSMutableAttributedString*)ms inRange:(NSRange)r withStyle:(NSDictionary*)newStyle
{
	NSRange scanRange=r;
	NSRange effectiveRange;
	id attributeValue;
	NSUInteger currentPosition=scanRange.location;
	colorMessage(@"Replacing all none commentsattributes....");
	while ( currentPosition < [ms length] && currentPosition < r.location+r.length)
	{
    attributeValue = [ms attribute:allExceptCommentAndStringAttribute atIndex:currentPosition longestEffectiveRange:&effectiveRange inRange:r];
		if ( attributeValue)
			
				[ms setAttributes: [[appPreferencesController sharedInstance] style: cBlackStyle ] range:  effectiveRange];
		currentPosition+=effectiveRange.length+1;
	}
}

//---------------------------------------------------------------------
// applySyntaxHighlighting
//---------------------------------------------------------------------
//	for a given range, apply syntaxhighligting for keywords.
//	only call this after a call to -applySyntaxHighlightingOnlyComment
//	because we skip all comments
//	We only do the range but going over the end if needed
//	Make sure range.length is > 0 and [ms length] > 0
//	No checking for this here
//  On exit, mRecoloredRange will contain the full range we recolored
//---------------------------------------------------------------------
-(void) applySyntaxHighlightingOnlyKeywords:(NSMutableAttributedString *) ms forRange:(NSRange) r blackSet:(BOOL) blackIsSet
{
	mEffectiveRecoloredRange.location=NSNotFound;
	NSRange attributeRange;
	id commentRange=nil;
	NSUInteger lengthOfCompleteString=[ms length]; 
	NSUInteger lastPosition=lengthOfCompleteString;	// last character in the string (not range)
	if ( lastPosition==0)	//no characters, don't do anything
		return;
	NSString *foundString=nil;

	lastPosition--;	// for index

	NSUInteger closeLocation=0;

	NSScanner *scan=[NSScanner scannerWithString:[ms string]];
	[scan setCharactersToBeSkipped:nil];

	NSUInteger currentPosition=r.location;

	BOOL (*IMPscanUpToCharactersFromSet)(id, SEL, NSCharacterSet*, NSString**);
	NSUInteger (*IMPscanLocation)(id, SEL);
	BOOL (*IMPscanCharactersFromSet)(id, SEL, NSCharacterSet*, NSString**);

	IMPscanUpToCharactersFromSet = (BOOL (*)(id, SEL, NSCharacterSet*, NSString**))[scan methodForSelector:mSELscanUpToCharactersFromSet];
	IMPscanCharactersFromSet = (BOOL (*)(id, SEL, NSCharacterSet*, NSString**))[scan methodForSelector:mSELscanCharactersFromSet];
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scan methodForSelector:mSELscanLocation];

	// if everything else but comment isn't restored to black, do it now
	if (blackIsSet == NO)
	{
		shakeMessage(@"color was not set to black");
		[self replaceAllNonCommentAndStringAttributes:ms inRange:r withStyle:[[appPreferencesController sharedInstance] style: cBlackStyle ]];
	}
	else
		shakeMessage(@"color was set to black");
	// once passed here, only color for keywords must be applied,
	// comment and black are set
	while ( currentPosition < r.location+r.length)
	{
		IMPscanUpToCharactersFromSet(scan, mSELscanUpToCharactersFromSet, toNextWordCharacterSet, nil);
		
		currentPosition = IMPscanLocation(scan, mSELscanLocation);//[scan scanLocation];
		if ( currentPosition >= lengthOfCompleteString)
			goto bail;
		
		// is the current position in a comment, skip until the end of comment and continue
		commentRange=[ms attribute: commentAndStringAttributeName atIndex: currentPosition longestEffectiveRange: &attributeRange inRange:NSMakeRange(currentPosition, lengthOfCompleteString - currentPosition)];
		if ( commentRange)
		{
			currentPosition=(attributeRange.location+attributeRange.length);
			[scan setScanLocation:currentPosition];
			continue;
		}
		
		
		IMPscanCharactersFromSet(scan, mSELscanUpToCharactersFromSet, wordCharacterSet, &foundString);
		closeLocation=IMPscanLocation(scan, mSELscanLocation); //[scan scanLocation];
		// a word is found
		if ( foundString != nil)
		{
			NSDictionary *styleToApply;
			const char* utf8FoundString=[foundString UTF8String];
			// find the correct style for it
			findStyleForWord(styleToApply,utf8FoundString);
			// if it isn't a black style, recolor the range
			if ( styleToApply != [[appPreferencesController sharedInstance] style: cBlackStyle ])
				[ms setAttributes: styleToApply range:  NSMakeRange( currentPosition,closeLocation-currentPosition)];
			updateEffectiveRecoloredRange(currentPosition, closeLocation-currentPosition);
		}
		else
			currentPosition=closeLocation;
	}	//while ( currentPosition <lastPosition)
	bail:
	;
}



//---------------------------------------------------------------------
// buildInclude
//---------------------------------------------------------------------
-(void) buildInclude:(NSMutableAttributedString*) ms
{
	//NSTextStorage *storage=[mSceneTextView textStorage];
	NSUInteger storageLength=[ms length];

	NSString *storageString=[ ms string];
	if (ms==nil)
		return;
	[mIncludeList release];
	mIncludeList=nil;
	NSString *rangeMode;
	NSRange rangeWithSameAttributes;
	NSUInteger scannerLocation;

	NSScanner *scanner = [NSScanner scannerWithString:[ms string]];
	NSUInteger (*IMPscanLocation)(id, SEL);
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scanner methodForSelector:mSELscanLocation];

	while( ![scanner isAtEnd] )
	{
		// read the first word
		[scanner scanUpToString:@"#include" intoString:nil];
		scannerLocation = IMPscanLocation(scanner, mSELscanLocation);
		if ( scannerLocation < storageLength)
		{
	 		rangeMode = [ms attribute: commentAndStringAttributeName	atIndex:scannerLocation	effectiveRange:&rangeWithSameAttributes];
			if ( rangeMode)
			{
				[scanner setScanLocation:NSMaxRange(rangeWithSameAttributes)];
				continue;
			}
			else
			{
				if ([scanner scanString:@"#include" intoString:nil])
				{
					scannerLocation = IMPscanLocation(scanner, mSELscanLocation);
					if ( scannerLocation + 1 >= storageLength)
						return;
					NSUInteger beginOfLine, endOfLine;
					int beginQuote=-1;
					int endQuote=-1;
//					int currentLocation=[scanner scanLocation];
					[storageString getLineStart:&beginOfLine end:NULL contentsEnd:&endOfLine forRange:NSMakeRange(scannerLocation,1)];

					while ( scannerLocation < endOfLine && [storageString characterAtIndex:scannerLocation]!='\"')
						scannerLocation++;
					if (scannerLocation < endOfLine && [storageString characterAtIndex:scannerLocation]=='\"')	//open quote
						beginQuote=scannerLocation;
						
					scannerLocation++;
					while ( scannerLocation < endOfLine && [storageString characterAtIndex:scannerLocation]!='\"')
						scannerLocation++;
					if ( scannerLocation < endOfLine && [storageString characterAtIndex:scannerLocation]=='\"')	//close quote
						endQuote=scannerLocation;
					if( endQuote != -1 && beginQuote != -1)
					{
						if ( (endQuote-beginQuote)-1 > 0)	// dont add things like #include ""
						{
							NSString *tempString=[storageString substringWithRange:NSMakeRange(beginQuote+1,(endQuote-beginQuote)-1)];
							[self addInclude:tempString atLocation:beginQuote];
						}
					}
					// move past this line with the include
					[scanner setScanLocation:endOfLine];
				}
			}
		}
	}

	// and now rebuild the popups
	[self rebuildIncludePopup];

}


//---------------------------------------------------------------------
// buildMacro
//---------------------------------------------------------------------
-(void) buildMacro:(NSMutableAttributedString*) ms
{
	[self releaseMacroList];
//	NSTextStorage *storage=[mSceneTextView textStorage];
	NSUInteger storageLength=[ms length];
	NSUInteger scannerLocation;
	NSString *foundString;
	NSString *rangeMode;
	NSRange rangeWithSameAttributes;
	NSScanner *scanner = [NSScanner scannerWithString: [ms string]];
	
	NSUInteger (*IMPscanLocation)(id, SEL);
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scanner methodForSelector:mSELscanLocation];

	while( ![scanner isAtEnd] )
	{
		// read the first word
		[scanner scanUpToString:@"#macro" intoString:nil];
		scannerLocation = IMPscanLocation(scanner, mSELscanLocation);
		if ( scannerLocation < storageLength)
		{
	 		rangeMode = [ms attribute: commentAndStringAttributeName	atIndex:scannerLocation	effectiveRange:&rangeWithSameAttributes];
			if ( rangeMode)
			{
				[scanner setScanLocation:NSMaxRange(rangeWithSameAttributes)];
				continue;
			}
			else
			{
				if ([scanner scanString:@"#macro" intoString:nil])
				{
					[scanner scanUpToCharactersFromSet:toNextWordCharacterSet intoString:nil];
					scannerLocation=IMPscanLocation(scanner, mSELscanLocation)+1;
					if ([scanner scanCharactersFromSet:wordCharacterSet intoString:&foundString])
					{
						[self addMacro:foundString atLocation:scannerLocation];
					}
				}
			}
		}
	}
	// and now rebuild the popups
	[self rebuildMacroPopup];
}

//---------------------------------------------------------------------
// buildDeclare
//---------------------------------------------------------------------
-(void) buildDeclare:(NSMutableAttributedString*) ms
{

	[self releaseDeclareList];
//	NSTextStorage *storage=[mSceneTextView textStorage];
	NSUInteger storageLength=[ms length];
	NSScanner *scanner = [NSScanner scannerWithString: [ms string]];
	NSUInteger scannerLocation;
	NSString *foundString;
	NSString *rangeMode;
	NSRange rangeWithSameAttributes;
	NSUInteger (*IMPscanLocation)(id, SEL);
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scanner methodForSelector:mSELscanLocation];

	while( ![scanner isAtEnd] )
	{
		// read the first word
		[scanner scanUpToString:@"#declare" intoString:nil];
		scannerLocation = IMPscanLocation(scanner, mSELscanLocation);

		if ( scannerLocation < storageLength)
		{
	 		rangeMode = [ms attribute: commentAndStringAttributeName	atIndex: scannerLocation	effectiveRange:&rangeWithSameAttributes];
			if ( rangeMode)
			{
				[scanner setScanLocation:NSMaxRange(rangeWithSameAttributes)];
				continue;
			}
			else
			{
				if ([scanner scanString:@"#declare" intoString:nil])
				{
					[scanner scanUpToCharactersFromSet:toNextWordCharacterSet intoString:nil];
					scannerLocation=IMPscanLocation(scanner, mSELscanLocation)+1;
					if ([scanner scanCharactersFromSet:wordCharacterSet intoString:&foundString])
					{
						[self addDeclare:foundString atLocation:scannerLocation isLocal:NO];
					}			
				}
			}
		}
	}
//local
	scanner = [NSScanner scannerWithString: [ms string]];
	IMPscanLocation = (NSUInteger (*)(id, SEL))[scanner methodForSelector:mSELscanLocation];
//	scannerLocation = 0;
	while( ![scanner isAtEnd] )
	{
		// read the first word
		[scanner scanUpToString:@"#local" intoString:nil];
		scannerLocation = IMPscanLocation(scanner, mSELscanLocation);
		if ( scannerLocation < storageLength)
		{
	 		rangeMode = [ms attribute: commentAndStringAttributeName	atIndex:scannerLocation	effectiveRange:&rangeWithSameAttributes];
			if ( rangeMode)
			{
				[scanner setScanLocation:NSMaxRange(rangeWithSameAttributes)];
				continue;
			}
			else
			{
				if ([scanner scanString:@"#local" intoString:nil])
				{
					[scanner scanUpToCharactersFromSet:toNextWordCharacterSet intoString:nil];
					scannerLocation=IMPscanLocation(scanner, mSELscanLocation)+1;
					if ([scanner scanCharactersFromSet:wordCharacterSet intoString:&foundString])
					{
						[self addDeclare:foundString atLocation:scannerLocation isLocal:YES];
					}			
				}
			}
		}
	}

	// and now rebuild the popups
	[self rebuildDeclarePopup];

}

//---------------------------------------------------------------------
// addMacro
//---------------------------------------------------------------------
-(void)addMacro:(NSString*) macroName atLocation:(unsigned) macroLocation
{
	const char* utf8=[macroName UTF8String];
	if ( utf8==nil)
		return;
	size_t length=strlen(utf8);
	if ( length == 0 )
		return;
		
	NSDictionary *result;
	signed long dummy=-1l;
	findStyleForDeclare(result, utf8, length, dummy);
	if ( result == [[appPreferencesController sharedInstance] style: cMacroStyle])	// macro already in the list
		return;
		
	if ( mAvailableFreeMacroPositions ==0)
	{
		if (mMacroList ==NULL)
		{
			mMacroList=(keyWords*)malloc(sizeof(keyWords)*dNumberOfSpacesToReserveForMacros);
			if ( mMacroList==NULL)
				return;
			mAvailableFreeMacroPositions=dNumberOfSpacesToReserveForMacros;
		}
		else
		{
			mMacroList=(keyWords*)realloc(mMacroList, sizeof(keyWords)*(dNumberOfSpacesToReserveForMacros+mNumberOfMacros));
			if ( mMacroList==NULL)
				return;
			mAvailableFreeMacroPositions=dNumberOfSpacesToReserveForMacros;
		}
	}
	mNumberOfMacros++;
	mAvailableFreeMacroPositions--;
	
	mMacroList[mNumberOfMacros-1].wordAsNSString=[macroName copy];
	mMacroList[mNumberOfMacros-1].wordStyle=useMacroStyle;
	mMacroList[mNumberOfMacros-1].location=macroLocation;
	char *tempPtr=(char*)[mMacroList[mNumberOfMacros-1].wordAsNSString UTF8String];
	mMacroList[mNumberOfMacros-1].wordLength=strlen(tempPtr);
	mMacroList[mNumberOfMacros-1].wordAsCString=(char*)malloc(mMacroList[mNumberOfMacros-1].wordLength);
	memcpy(mMacroList[mNumberOfMacros-1].wordAsCString,tempPtr,mMacroList[mNumberOfMacros-1].wordLength);
	unsigned char pos=*(unsigned char*)tempPtr;
	if ( mMacroCountlist[pos].reserved==0)	//nothing reserved yet
		mMacroCountlist[pos].pointers=(long*)malloc((long)sizeof(long*));
	else
		mMacroCountlist[pos].pointers=(long*)realloc(mMacroCountlist[pos].pointers,(long)sizeof(long*)*(mMacroCountlist[pos].reserved+1));
	
	mMacroCountlist[pos].pointers[mMacroCountlist[pos].reserved++]=mNumberOfMacros-1;
	
}


//---------------------------------------------------------------------
// addDeclare
//---------------------------------------------------------------------
-(void)addDeclare:(NSString*) declareName atLocation:(unsigned) declareLocation isLocal:(BOOL) isLocal
{
	const char* utf8=[declareName UTF8String];
	if ( utf8==nil)
		return;
	size_t length=strlen(utf8);
	if ( length == 0 )
		return;
	NSDictionary *result;
	signed long dummy=-1l;
	findStyleForDeclare(result, utf8, length, dummy);
	if ( result==[[appPreferencesController sharedInstance] style: cDeclareStyle ])	// declare already in the list
		return;
		
	if ( mAvailableFreeDeclarePositions ==0)
	{
		if (mDeclareList ==NULL)
		{
			mDeclareList=(keyWords*)malloc(sizeof(keyWords)*dNumberOfSpacesToReserveForDeclares);
			if ( mDeclareList==NULL)
				return;
			mAvailableFreeDeclarePositions=dNumberOfSpacesToReserveForDeclares;
		}
		else
		{
			mDeclareList=(keyWords*)realloc(mDeclareList, sizeof(keyWords)*(dNumberOfSpacesToReserveForDeclares+mNumberOfDeclares));
			if ( mDeclareList==NULL)
				return;
			mAvailableFreeDeclarePositions=dNumberOfSpacesToReserveForDeclares;
		}
	}
	mNumberOfDeclares++;
	mAvailableFreeDeclarePositions--;
	
	mDeclareList[mNumberOfDeclares-1].wordAsNSString=[declareName copy];
	mDeclareList[mNumberOfDeclares-1].wordStyle=useDeclareStyle;
	mDeclareList[mNumberOfDeclares-1].location=declareLocation;
	mDeclareList[mNumberOfDeclares-1].isLocal=isLocal;

	char *tempPtr=(char*)[mDeclareList[mNumberOfDeclares-1].wordAsNSString UTF8String];
	mDeclareList[mNumberOfDeclares-1].wordLength=strlen(tempPtr);
	mDeclareList[mNumberOfDeclares-1].wordAsCString=(char*)malloc(mDeclareList[mNumberOfDeclares-1].wordLength);
	memcpy(mDeclareList[mNumberOfDeclares-1].wordAsCString,tempPtr,mDeclareList[mNumberOfDeclares-1].wordLength);
	unsigned char pos=*(unsigned char*)tempPtr;
	if ( mDeclareCountList[pos].reserved==0)	//nothing reserved yet
		mDeclareCountList[pos].pointers=(long*)malloc((long)sizeof(long*));
	else
		mDeclareCountList[pos].pointers=(long*)realloc(mDeclareCountList[pos].pointers,(long)sizeof(long*)*(mDeclareCountList[pos].reserved+1));
	
	mDeclareCountList[pos].pointers[mDeclareCountList[pos].reserved++]=mNumberOfDeclares-1;
}


//---------------------------------------------------------------------
// addInclude
//---------------------------------------------------------------------
-(void)addInclude:(NSString*) includeName atLocation:(unsigned) includeLocation
{
	if ( mIncludeList==NULL)
	{
		mIncludeList=[[NSMutableArray alloc] init];
	}
	[mIncludeList addObject:includeName];
}
//---------------------------------------------------------------------
// releaseDeclare
//---------------------------------------------------------------------
-(void) releaseDeclareList
{
	for (int x=0; x<mNumberOfDeclares; x++)
	{
		free(mDeclareList[x].wordAsCString);
		[mDeclareList[x].wordAsNSString release];
	}
	free(mDeclareList);
	mDeclareList=NULL;
	
		
	for (int x=0; x<256; x++)
	{
		if ( mDeclareCountList[x].reserved )
			free(mDeclareCountList[x].pointers);
		mDeclareCountList[x].numberOfWords = mDeclareCountList[x].reserved=0;
	}
	mNumberOfDeclares=mAvailableFreeDeclarePositions=mRemovedDeclarePositions=0;
}

//---------------------------------------------------------------------
// releaseDeclare
//---------------------------------------------------------------------
-(void) releaseMacroList
{
	for (int x=0; x<mNumberOfMacros; x++)
	{
		free(mMacroList[x].wordAsCString);
		[mMacroList[x].wordAsNSString release];
	}
	free(mMacroList);
	mMacroList=NULL;
	
		
	for (int x=0; x<256; x++)
	{
		if ( mMacroCountlist[x].reserved )
			free(mMacroCountlist[x].pointers);
		mMacroCountlist[x].numberOfWords = mMacroCountlist[x].reserved=0;
	}
	mNumberOfMacros = mAvailableFreeMacroPositions=mRemovedMacroPositions=0;
}
@end