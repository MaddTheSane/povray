//******************************************************************************
///
/// @file <File Name>
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
#import "MainController.h"

#import "messageViewController.h"
#import "rendererGUIBridge.h"
#include "configbase.h"
#import "povray.h"


// this must be the last file included
#import "syspovdebug.h"

@implementation MessageString

//---------------------------------------------------------------------
// initWithCString
//---------------------------------------------------------------------
-(MessageString*) initWithCString: (char*)theString andStream: (int) stream
{
	self=[super init];
	mString=[[NSString alloc] initWithCString:theString encoding:NSASCIIStringEncoding];
	mStreamType=stream;
	return self;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void)dealloc
{
	[mString release];
	[super dealloc];
}
@end

static MessageViewController* _messageViewController;

@implementation MessageViewController

//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (MessageViewController*)sharedInstance
{
	return _messageViewController;
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self=_messageViewController=[super init];
	return self;
}

//---------------------------------------------------------------------
// windowFront
// called from 	void Mac_Parse_Error( const char *fileName, long  lineNo)
// in renderGUIBridge
//---------------------------------------------------------------------
-(void) windowFront
{
	[mWindow makeKeyAndOrderFront:nil];
}

//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{

	NSNumber *number=[[notification userInfo] objectForKey: @"renderStarted"];
	if ( number)
	{
		if ( [number boolValue] == YES)
		{
			[mSceneStart addObject:@([mTextStorage length])];
			NSInteger count=[mSceneStart count];
			if ( count >10 && [mTextStorage length] >=51200)
			{
				NSInteger removedBytes=[[mSceneStart objectAtIndex:0]integerValue];
				[mSceneStart removeObjectAtIndex:0];
				for ( NSInteger x=0; x<[mSceneStart count]; x++)
				{
					int oldValue=[[mSceneStart objectAtIndex:x]intValue];
					[mSceneStart replaceObjectAtIndex:x withObject:[NSNumber numberWithInteger:oldValue-removedBytes]];
				}
				NSRange newRange=NSMakeRange(0, removedBytes);
				[mTextStorage replaceCharactersInRange:newRange withString:@""];
			}
		}
	}
}
-(void) setNeedsUpdate
{
	[mMessageView setNeedsDisplay:YES];
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
- (void) awakeFromNib
{
	mSceneStart=[[NSMutableArray alloc]init];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"renderState"
		object:nil];

	mTextSize=0;	// no text in the buffer
	if ([[self superclass] instancesRespondToSelector:@selector(awakeFromNib)])
	{
		[super awakeFromNib];
	}
	mTextStorage= [mMessageView textStorage];
	// now set the mFont to monaco size 11
	mFont=[[NSFont userFixedPitchFontOfSize:0.0] retain];
	[mMessageView setFont:mFont];

	// init all styles
	mBlackStyle =[ [NSDictionary dictionaryWithObjectsAndKeys:
									mFont, NSFontAttributeName,
									[NSColor blackColor], NSForegroundColorAttributeName,
									nil] retain];

	mBlueStyle =[ [NSDictionary dictionaryWithObjectsAndKeys:
								 mFont, NSFontAttributeName,
								 [NSColor colorWithCalibratedRed:0.0/255.0 		green:0.0/255.0 		blue:194.0/255.0	alpha:1.0], NSForegroundColorAttributeName,
								 nil] retain];

	mRedStyle =[ [NSDictionary dictionaryWithObjectsAndKeys:
								mFont, NSFontAttributeName,
								[NSColor colorWithCalibratedRed:196.0/255.0 	green:0.0/255.0 		blue:0.0/255.0		alpha:1.0], NSForegroundColorAttributeName,
								nil] retain];

	mMagentaStyle =[ [NSDictionary dictionaryWithObjectsAndKeys:
										mFont, NSFontAttributeName,
										[NSColor colorWithCalibratedRed:255.0/255.0 	green:0.0/255.0 		blue:128.0/255.0	alpha:1.0], NSForegroundColorAttributeName,
										nil] retain];

	mGreenStyle =[ [NSDictionary dictionaryWithObjectsAndKeys:
									mFont, NSFontAttributeName,
									[NSColor colorWithCalibratedRed:0.0/255.0 		green:163.0/255.0 	blue:0.0/255.0		alpha:1.0], NSForegroundColorAttributeName,
									nil] retain];


}

//---------------------------------------------------------------------
// initRenderTimeUpdateTimer
//---------------------------------------------------------------------
// start the update timer for the current time since render start
// bottom right of message window
// every second
//---------------------------------------------------------------------
- (void) initRenderTimeUpdateTimer;
{
	mRenderTimeUpdater = [[NSTimer timerWithTimeInterval:1.0
												target:self
												selector:@selector(updateRenderTime:)
												userInfo:nil
												repeats:YES] retain];

	mStartDate=[[NSDate dateWithTimeIntervalSinceNow:0]retain];
	[[NSRunLoop currentRunLoop] addTimer:mRenderTimeUpdater forMode:NSDefaultRunLoopMode];
}


//---------------------------------------------------------------------
// removeRenderTimeUpdateTimer
//---------------------------------------------------------------------
- (void) removeRenderTimeUpdateTimer
{
	if ( mRenderTimeUpdater != nil)
	{
		[mRenderTimeUpdater invalidate];
		[mRenderTimeUpdater release];
		mRenderTimeUpdater=nil;
	}
	if ( mStartDate != nil )
	{
		[mStartDate release];
		mStartDate=nil;
	}
}

//---------------------------------------------------------------------
// initRenderTimeUpdateTimer
//---------------------------------------------------------------------
// display the current time since render start
// bottom right of message window
// every second
//---------------------------------------------------------------------
- (void) updateRenderTime: (NSTimer *) aTimer
{
	clock_t seconds= (clock_t)fabs([mStartDate timeIntervalSinceNow]);
	NSString *str=[NSString stringWithFormat:@"%lud %02luh %02lum %02lus",
								 seconds / 86400,
								 seconds % 86400 / 3600,
								 seconds % 3600 / 60,
								 seconds % 60];
	[mRenderTime setStringValue:str];
}

//---------------------------------------------------------------------
// bannerMessage
//---------------------------------------------------------------------
- (void) bannerMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:BANNER_STREAM];
}

//---------------------------------------------------------------------
// satusMessage
//---------------------------------------------------------------------
- (void) satusMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:STATUS_STREAM];
}

//---------------------------------------------------------------------
// debugMessage
//---------------------------------------------------------------------
- (void) debugMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:DEBUG_STREAM];
}

//---------------------------------------------------------------------
// fatalMessage
//---------------------------------------------------------------------
- (void) fatalMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:FATAL_STREAM];
}

//---------------------------------------------------------------------
// renderMessage
//---------------------------------------------------------------------
- (void) renderMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:RENDER_STREAM];
}

//---------------------------------------------------------------------
// statisticMessage
//---------------------------------------------------------------------
- (void) statisticMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:STATISTIC_STREAM];
}

//---------------------------------------------------------------------
// warningMessage
//---------------------------------------------------------------------
- (void) warningMessage: (NSString*) inMessage
{
	[self printNSString: inMessage fromStream:WARNING_STREAM];
}

//---------------------------------------------------------------------
// printNSString
//---------------------------------------------------------------------
- ( void) printNSString: (NSString*) inMessage fromStream: (int) StreamType
{
	[mTextStorage beginEditing];

	NSAttributedString *newString=[NSAttributedString alloc];
	switch (StreamType)
	{
		case streams(BANNER_STREAM):
			//if (POV_NAMESPACE::Stage==STAGE_INIT)
			newString=[newString initWithString:inMessage attributes:mBlueStyle];
			//fixme
#if(0)
			newString=[newString initWithString:inMessage attributes:mBlueStyle];
			else
				newString=[newString initWithString:inMessage attributes:mBlackStyle];
#endif
			break;

		case streams(STATUS_STREAM):
			newString=[newString initWithString:inMessage attributes:mBlackStyle];
			break;
		case streams(DEBUG_STREAM):
			newString=[newString initWithString:inMessage attributes:mBlackStyle];
			break;
		case streams(FATAL_STREAM):
			newString=[newString initWithString:inMessage attributes:mRedStyle];
			break;
		case streams(RENDER_STREAM):
			newString=[newString initWithString:inMessage attributes:mBlueStyle];
			break;
		case streams(STATISTIC_STREAM):
			newString=[newString initWithString:inMessage attributes:mMagentaStyle];
			break;
		case streams(WARNING_STREAM):
			newString=[newString initWithString:inMessage attributes:mGreenStyle];
			break;
	}

	[mTextStorage appendAttributedString:newString];
	[newString release];
	[mTextStorage endEditing];
	[mMessageView scrollRangeToVisible: NSMakeRange([[mMessageView string] length], 0)];
}

//---------------------------------------------------------------------
// updateProgress
//---------------------------------------------------------------------
// display status ("Starting up", "Parsing...",...
// bottom left of message window
//---------------------------------------------------------------------
-(void) updateProgress: (NSString*) progress
{
	[mProgressIndicator setStringValue: progress];
	[mProgressWindowTextField setStringValue: progress];
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self removeRenderTimeUpdateTimer];
	[[NSNotificationCenter defaultCenter]removeObserver:self];

	[mBlackStyle release];
	[mBlueStyle release];
	[mRedStyle release];
	[mMagentaStyle release];
	[mGreenStyle release];
	[mFont release];
	[mSceneStart release];
	mSceneStart=nil;
	_messageViewController=nil;
	[super dealloc];
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

-(IBAction) saveDocument:(id)sender
{
}

@end
