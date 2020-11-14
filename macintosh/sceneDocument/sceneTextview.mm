//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneTextview.mm
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

#import "sceneTextview.h"
#import "appPreferencesController.h"

// this must be the last file included
#import "syspovdebug.h"

static BOOL BracesBackward(NSTextView *textView, unichar teken,  NSString *str, SInt32 TextSize,  SInt32 &pos);
static BOOL BracesForward(NSTextView *textView, unichar teken, NSString *str, SInt32 TextSize,  SInt32 &pos);
static BOOL CheckBraces(NSTextView *textView,SInt32 offset, NSString *str, SInt32 TextSize);

@implementation sceneTextView

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
- (id)init
{
    self = [super init];
    return self;
}

//---------------------------------------------------------------------
// insertNewline
//---------------------------------------------------------------------
- (void)insertNewline:(id)sender
{
	[super insertNewline:sender];

	//	If we should indent automatically, check the previous line and scan all the 
	//	whitespace at the beginning of the line into a string and insert that string into the new line
	NSString *lastLineString = [[self string] substringWithRange:[[self string] lineRangeForRange:NSMakeRange([self selectedRange].location - 1, 0)]];
	if (maintainIndentation == NSOnState) 
	{
		NSString *previousLineWhitespaceString;
		NSScanner *previousLineScanner = [[NSScanner alloc] initWithString:lastLineString];
		[previousLineScanner setCharactersToBeSkipped:nil];		
		if ([previousLineScanner scanCharactersFromSet:[NSCharacterSet whitespaceCharacterSet] intoString:&previousLineWhitespaceString]) 
		{
			[self insertText:previousLineWhitespaceString];
		}
		[previousLineScanner release];
		
		if (autoIndentBraces == NSOnState) 
		{
			NSCharacterSet *characterSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
			NSUInteger index = [lastLineString length];
			while (index--) {
				if ([characterSet characterIsMember:[lastLineString characterAtIndex:index]]) 
				{
					continue;
				}
				if ([lastLineString characterAtIndex:index] == '{') 
				{
					[self insertTab:nil];
				}
				break;
			}
		}
	}
}

//---------------------------------------------------------------------
// insertText
//---------------------------------------------------------------------
- (void)insertText:(NSString *)aString
{
	if ([aString isEqualToString:@"}"] && maintainIndentation == NSOnState 	&& autoIndentBraces == NSOnState)
	{
		unichar characterToCheck;
		NSUInteger location = [self selectedRange].location;
		NSString *completeString = [self string];
		NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
		NSRange currentLineRange = [completeString lineRangeForRange:NSMakeRange([self selectedRange].location, 0)];
		NSUInteger lineLocation = location;
		NSUInteger lineStart = currentLineRange.location;
		// If there are any characters before } on the line skip indenting
		while (--lineLocation >= lineStart) 
		{ 
			if ([whitespaceCharacterSet characterIsMember:[completeString characterAtIndex:lineLocation]]) 
			{
				continue;
			}
			[super insertText:aString];
			return;
		}
		
		BOOL hasInsertedBrace = NO;
		NSUInteger skipMatchingBrace = 0;
		while (location--) 
		{
			characterToCheck = [completeString characterAtIndex:location];
			if (characterToCheck == '{') 
			{
				// If we have found the opening brace check first how much space is in front 
				// of that line so the same amount can be inserted in front of the new line
				if (skipMatchingBrace == 0) 
				{ 
					NSString *openingBraceLineWhitespaceString;
					NSScanner *openingLineScanner = [[NSScanner alloc] initWithString:[completeString substringWithRange:[completeString lineRangeForRange:NSMakeRange(location, 0)]]];
					[openingLineScanner setCharactersToBeSkipped:nil];
					BOOL foundOpeningBraceWhitespace = [openingLineScanner scanCharactersFromSet:whitespaceCharacterSet intoString:&openingBraceLineWhitespaceString];
					
					if (foundOpeningBraceWhitespace == YES) 
					{
						NSMutableString *newLineString = [NSMutableString stringWithString:openingBraceLineWhitespaceString];
						[newLineString appendString:@"}"];
						[newLineString appendString:[completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)]];
						if ([self shouldChangeTextInRange:currentLineRange replacementString:newLineString]) 
						{
							[self replaceCharactersInRange:currentLineRange withString:newLineString];
							[self didChangeText];
						}
						hasInsertedBrace = YES;
						// +1 because we have inserted a character
						[self setSelectedRange:NSMakeRange(currentLineRange.location + [openingBraceLineWhitespaceString length] + 1, 0)]; 
					} 
					else 
					{
						NSString *restOfLineString = [completeString substringWithRange:NSMakeRange([self selectedRange].location, NSMaxRange(currentLineRange) - [self selectedRange].location)];
						// To fix a bug where text after the } can be deleted
						if ([restOfLineString length] != 0) 
						{ 
							NSMutableString *replaceString = [NSMutableString stringWithString:@"}"];
							[replaceString appendString:restOfLineString];
							hasInsertedBrace = YES;
							NSUInteger lengthOfWhiteSpace = 0;
							if (foundOpeningBraceWhitespace == YES) 
							{
								lengthOfWhiteSpace = [openingBraceLineWhitespaceString length];
							}
							if ([self shouldChangeTextInRange:currentLineRange replacementString:replaceString]) 
							{
								[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:replaceString];
								[self didChangeText];
							}
							// +1 because we have inserted a character
							[self setSelectedRange:NSMakeRange(currentLineRange.location + lengthOfWhiteSpace + 1, 0)]; 
						} 
						else 
						{
							[self replaceCharactersInRange:[completeString lineRangeForRange:currentLineRange] withString:@""]; // Remove whitespace before }
						}
				
					}
					[openingLineScanner release];
					break;
				} 
				else 
				{
					skipMatchingBrace--;
				}
			} 
			else if (characterToCheck == '}') 
			{
				skipMatchingBrace++;
			}
		}
		if (hasInsertedBrace == NO) {
			[super insertText:aString];
		}
	} 
	else 
	{
		[super insertText:aString];
	}
}

//---------------------------------------------------------------------
// checkBracesTextView
//---------------------------------------------------------------------
-(void)checkBracesTextView
{
	NSRange originalSelectedRange=[self selectedRange];
	NSString *str=[[self textStorage]string];
	CheckBraces(self,originalSelectedRange.location,  str, [str length]);
}

- (void)mouseDown:(NSEvent *)theEvent
{
	BOOL mustCheck=NO;
	if ( [theEvent clickCount]==2)	// double click?
	{
		NSRange originalSelectedRange=[self selectedRange];
		switch ([[[self textStorage]string] characterAtIndex: originalSelectedRange.location])
		{
			case '{':	case '(':	case '[':
			case '}':	case ')':	case ']':
				mustCheck=YES;
				break;
			default:
				mustCheck=NO;
				break;
		}
		if ( mustCheck==YES)
			[self checkBracesTextView];
		else
			if ( [super respondsToSelector:@selector(mouseDown:)])
				[super mouseDown:theEvent];
	}
	else
		if ( [super respondsToSelector:@selector(mouseDown:)])
			[super mouseDown:theEvent];
}

@end
BOOL CheckBraces(NSTextView *textView,SInt32 offset, NSString *str, SInt32 TextSize)
{
	BOOL returnvalue=NO;
	SInt32 pos=offset;
	if ( pos >=TextSize)
		return NO;
		
	switch ( [str characterAtIndex: pos])
	{
		case '{':
		case '(':
		case '[':
			returnvalue=BracesForward(textView, [str characterAtIndex: pos], str, TextSize, pos);
			if ( !returnvalue)
				NSBeep();
			break;
		case '}':
		case ')':
		case ']':
			returnvalue=BracesBackward( textView,[str characterAtIndex: pos], str, TextSize, pos);
			if ( !returnvalue)
				NSBeep();
			break;
		default:
			returnvalue=NO;
				NSBeep();
			break;
	}
	if ( returnvalue )
	{
		NSRange newRange;
		if ( offset > pos)	//backwards
		{
			newRange.location=pos;
			newRange.length=(offset-pos)+1;
		}
		else
		{
			newRange.location=offset;
			newRange.length=(pos-offset)+1;
		}
		[textView setSelectedRange:newRange];
	}
	return returnvalue;
}
BOOL BracesForward( NSTextView *textView,unichar teken, NSString *str, SInt32 TextSize,  SInt32 &pos)
{
	NSString *rangeMode;
	Boolean returnvalue=NO;
	if ( pos >= TextSize)
		return returnvalue;
	unichar End;
	
	switch ( teken)
	{
		case '{':		End='}';		break;
		case '(':		End=')';		break;
		case '[':		End=']';		break;
		default:
			return returnvalue;
			break;
	}
	while (pos < TextSize-1)
	{
		pos++;
		if ( [str characterAtIndex: pos] == End)
		{
		 	rangeMode = [[textView textStorage] attribute: commentAndStringAttributeName
								atIndex: pos
								effectiveRange:NULL];
			if ( rangeMode)
			{
				continue;
			}
			return YES;
		}
		switch ( [str characterAtIndex: pos])
		{
			case '{':
			case '(':
			case '[':
			 	rangeMode = [[textView textStorage] attribute: commentAndStringAttributeName
								atIndex: pos
								effectiveRange:NULL];
			if ( rangeMode)
			{
				continue;
			}
				returnvalue=BracesForward( textView,[str characterAtIndex: pos], str, TextSize, pos);
				if ( returnvalue ==NO)
					return returnvalue;
				else
					returnvalue=NO;
				break;
		}
	}
	return returnvalue;
}
BOOL BracesBackward( NSTextView *textView, unichar teken,  NSString *str, SInt32 TextSize,  SInt32 &pos)
{
	NSString *rangeMode;
	Boolean returnvalue=NO;
	if ( pos <= 0)
		return returnvalue;
	unichar End;
	
	switch ( teken)
	{
		case '}':		End='{';		break;
		case ')':		End='(';		break;
		case ']':		End='[';		break;
		default:
			return returnvalue;
			break;
	}
	while (pos > 0)
	{
		pos--;
		if ( [str characterAtIndex: pos] == End )
		{
			rangeMode = [[textView textStorage] attribute: commentAndStringAttributeName
								atIndex: pos
								effectiveRange:NULL];
			if ( rangeMode)
			{
				continue;
			}
			return YES;
		}	
		switch ( [str characterAtIndex: pos])
		{
			case '}':
			case ')':
			case ']':
				rangeMode = [[textView textStorage] attribute: commentAndStringAttributeName
								atIndex: pos
								effectiveRange:NULL];
			if ( rangeMode)
			{
				continue;
			}
				returnvalue=BracesBackward( textView,[str characterAtIndex: pos], str, TextSize, pos);
				if ( returnvalue ==NO)
					return returnvalue;
				else
					returnvalue=NO;
				break;
		}
	}
	return returnvalue;
}
