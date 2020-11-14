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
/* MessageViewController */

#import <Cocoa/Cocoa.h>


@interface MessageString: NSObject
{
	@public
	NSString *mString;
	int mStreamType;
}
	-(MessageString*) initWithCString: (char*)theString andStream: (int) stream;
@end
@interface MessageViewController : NSObject
{
	IBOutlet NSTextView *mMessageView;
  IBOutlet NSTextField *mProgressIndicator;
  NSFont					*mFont;
	NSDictionary		*mBlackStyle;
	NSDictionary		*mBlueStyle;
	NSDictionary		*mRedStyle;
	NSDictionary		*mMagentaStyle;
	NSDictionary		*mGreenStyle;
	NSMutableArray	*mSceneStart;
	NSWindow				*mWindow;
	
    long		mTextSize;
    NSTextStorage	*mTextStorage;

	IBOutlet NSWindow			*mProgressWindow;
	IBOutlet NSTextField		*mProgressWindowTextField;

	enum streams
		{
			BANNER_STREAM = 0,
			STATUS_STREAM,
			DEBUG_STREAM,
			FATAL_STREAM,
			RENDER_STREAM,
			STATISTIC_STREAM,
			WARNING_STREAM,
			ALL_STREAM,
			MAX_STREAMS
		};
	NSTimer *mRenderTimeUpdater;
	clock_t mRenderStartTime, mRenderEndTime;
	NSDate *mStartDate;
	IBOutlet NSTextField *mRenderTime;
}
+ (MessageViewController*)sharedInstance;
- (void) warningMessage: (NSString*) inMessage;
- (void) statisticMessage: (NSString*) inMessage;
- (void) renderMessage: (NSString*) inMessage;
- (void) fatalMessage: (NSString*) inMessage;
- (void) debugMessage: (NSString*) inMessage;
- (void) satusMessage: (NSString*) inMessage;
- (void) bannerMessage: (NSString*) inMessage;
- (void) printNSString: (NSString*) inMessage fromStream: (int) StreamType;
- (void) updateProgress: (NSString*)progress;
- (void) initRenderTimeUpdateTimer;
- (void) removeRenderTimeUpdateTimer;
-(void) windowFront;

-(void) renderState:(NSNotification *) notification;
-(void) setNeedsUpdate;
@end


