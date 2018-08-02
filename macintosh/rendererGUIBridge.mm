//******************************************************************************
///
/// @file /macintosh/renderGUIBridge.mm
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
#import "rendererGUIBridge.h"
#import "messageViewController.h"
#import "mainController.h"
// this must be the last file included
#import "syspovdebug.h"

using namespace pov_frontend;
namespace vfe
{

	//---------------------------------------------------------------------
	// Mac_Parse_Error
	//---------------------------------------------------------------------
	// remoteMac_Parse_Error is in picturePreviewBase.mm
	//---------------------------------------------------------------------
	void Mac_Parse_Error( const char *fileName, long  lineNo)
	{
		@autoreleasepool
		{
			[[MessageViewController sharedInstance] performSelectorOnMainThread:@selector(windowFront) withObject:nil waitUntilDone:YES];

			remoteObject *rm=[[remoteObject alloc]initWithObjectsAndKeys:
												[NSString stringWithUTF8String:fileName], @"fileName",
												[NSNumber numberWithInt:lineNo], @"lineNo",	nil];
			[activeRenderPreview performSelectorOnMainThread:@selector(remoteMac_Parse_Error:)withObject: rm waitUntilDone:YES];
			[rm release];
		}
	}



	//---------------------------------------------------------------------
	// BeginRender
	//---------------------------------------------------------------------
	ReturnValue BeginRender(int argc, char **argv, renderDispatcher* dispatcher)
	{
		vfeStatusFlags    flags;
		vfeRenderOptions  opts;
		ReturnValue       retval = RETURN_OK;
		int result=0;
		MessageViewController *messageView=[MessageViewController sharedInstance];
		if ( messageView == nil)
			return RETURN_ERROR;

		SEL SEL_updateProgress=@selector(updateProgress:);
		SEL SEL_fatalMessage=@selector(fatalMessage:);
		NSString *msgStr=nil;

		[messageView performSelectorOnMainThread: SEL_updateProgress withObject:@"Starting up" waitUntilDone:NO];

		gVfeSession->Clear();
		gVfeSession->ClearOptions();

		for (int i = 1; i < argc; i++)
			opts.AddCommand(argv[i]);

		[messageView performSelectorOnMainThread:@selector(initRenderTimeUpdateTimer) withObject:nil waitUntilDone:NO];

		try
		{
			result = gVfeSession->SetOptions(opts);

			if (result == vfeNoInputFile)
				throw POV_EXCEPTION_STRING("No source file specified, either directly or via an INI file.");
			else if (result != vfeNoError)
				throw POV_EXCEPTION_STRING (gVfeSession->GetErrorString());

			gVfeSession->SetEventMask(~stNone);  // immediatly notify this event

			int result=gVfeSession->StartRender();
			if (result < 0)
				throw POV_EXCEPTION_CODE (result);
			else if (result > 0)
				throw POV_EXCEPTION_STRING (gVfeSession->GetErrorString());
			// make sure any outstanding messages are processed

			while (((flags = gVfeSession->GetStatus(true, 1)) & stRenderShutdown) == 0)
			{
				if ( gUserWantsToAbortRender==YES && gApplicationAlreadyReceivedStopResquest == NO)
				{
					gApplicationAlreadyReceivedStopResquest = YES;
					gUserWantsToAbortRender = NO;
					gVfeSession->CancelRender();// request the backend to cancel
					ProcessSession(flags);
					while (gVfeSession->GetBackendState() != kReady)  // wait for the render to effectively shut down
						Delay(10);
					retval=RETURN_USER_ABORT;
				}
				else if (gUserWantsToPauseRenderer==YES)
				{
					//	NSLog(@"pause requested");
					gUserWantsToPauseRenderer=NO;
					BOOL olState=gIsPausing;
					bool lres=vfe::gVfeSession->Pause();
					//	NSLog(@"resutl :%d",lres);
					if ( lres== true)
						gIsPausing=YES;
					if ( olState != gIsPausing)
						[[NSNotificationCenter defaultCenter]	postNotificationName:@"pauseStatusChanged" object:nil userInfo:nil];

				}

				ProcessSession(flags);

			}
			if ( flags & stRenderShutdown)
				// make sure the update timer stops :-)
				[[renderDispatcher sharedInstance] performSelectorOnMainThread:@selector(notifyVfeSessionStoppedRendering)withObject:NULL waitUntilDone:YES];
			
		}
		catch (std::exception& e)
		{
			retval=RETURN_ERROR;
			msgStr=[NSString stringWithFormat:@"\nFailed to start render: %s", e.what()];
			[messageView performSelectorOnMainThread: SEL_fatalMessage withObject:msgStr waitUntilDone:NO];
			gVfeSession->CancelRender();
			// make sure there aren't any outstanding messages
			while ((flags = gVfeSession->GetStatus(true, 0)))
			{
				ProcessSession(flags);
			}
		}
		if ( gVfeSession->Succeeded() == false)
			retval=	RETURN_ERROR;

		[messageView performSelectorOnMainThread:@selector(removeRenderTimeUpdateTimer) withObject:nil waitUntilDone:YES];
		[messageView performSelectorOnMainThread: SEL_updateProgress withObject:[NSString stringWithUTF8String:"Ready"] waitUntilDone:YES];
		return retval;
	}

	//---------------------------------------------------------------------
	// ProcessSession
	//---------------------------------------------------------------------
	void ProcessSession(vfeStatusFlags flags)
	{
		int previousMessage=-1; // undefined
		MessageViewController *messageView=[MessageViewController sharedInstance];
		if ( messageView == nil)
			return ;

		SEL SEL_updateProgress=@selector(updateProgress:);
		SEL SEL_warningMessage=@selector(warningMessage:);
		SEL SEL_fatalMessage=@selector(fatalMessage:);
		SEL SEL_debugMessage=@selector(debugMessage:);
		SEL SEL_bannerMessage=@selector(bannerMessage:);
		NSString *msgStr=nil;
		//backend state changed
		
		if (flags & stBackendStateChanged)
		{
			switch (gVfeSession->GetBackendState())
			{
				case kParsing:
					[messageView performSelectorOnMainThread: SEL_updateProgress withObject:@"Parsing..." waitUntilDone:NO];
					break;
				case kRendering:
					[messageView performSelectorOnMainThread: SEL_updateProgress withObject:@"Rendering..." waitUntilDone:NO];
					break;
				case kPausedRendering:
					[messageView performSelectorOnMainThread: SEL_updateProgress withObject:@"Paused..." waitUntilDone:NO];
					break;
				case kStopped:
					[[renderDispatcher sharedInstance] performSelectorOnMainThread:@selector(notifyVfeSessionStoppedRendering)withObject:NULL waitUntilDone:YES];
					break;
				default:
					break;
			}
		}

		if ((flags & (stStatusMessage | stAnimationStatus)) != 0) 
		{
			vfeSession::StatusMessage msg(*gVfeSession) ;
			while (gVfeSession->GetNextStatusMessage (msg))
			{
				if (msg.m_Type == vfeSession::mGenericStatus)
					[messageView performSelectorOnMainThread: SEL_updateProgress withObject:[NSString stringWithUTF8String:msg.m_Message.c_str()] waitUntilDone:NO];
				else if (msg.m_Type == vfeSession::mAnimationStatus)
					[messageView performSelectorOnMainThread: SEL_updateProgress withObject:[NSString stringWithFormat: @"Rendering frame %d of %d ",  msg.m_Frame, msg.m_TotalFrames] waitUntilDone:NO];
				else
				{
					// huh?
					assert (false);
				}
			}
		}

		if ((flags & (stStreamMessage | stErrorMessage | stWarningMessage)) != 0)
		{
			int line;
			int col;
			char str[32];
			string errormsg;
			string message;
			string filename;
			vfeSession::MessageType type;
			string         ErrorMessage ;
			string         ErrorFilename ;
			unsigned       ErrorLine ;
			unsigned       ErrorCol ;

			while (gVfeSession->GetNextNonStatusMessage (type, message, filename, line, col))
			{
				switch (type)
				{
					case vfeSession::mDebug:
						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mDebug) ? @"\n" :@"" , message.c_str()];
						[messageView performSelectorOnMainThread: SEL_debugMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mDebug;
						break;

					case vfeSession::mInformation:
						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mInformation) ? @"\n" :@"" ,message.c_str()];
						[messageView performSelectorOnMainThread: SEL_bannerMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mInformation;
						break;

					case vfeSession::mWarning:

						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mWarning) ? @"\n" :@"" ,message.c_str()];
						[messageView performSelectorOnMainThread: SEL_warningMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mWarning;
						break;

					case vfeSession::mPossibleError:
						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mPossibleError) ? @"\n" :@"" ,message.c_str()];
						[messageView performSelectorOnMainThread: SEL_warningMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mPossibleError;
						break;

					case vfeSession::mError:
						if (ErrorMessage.empty())
						{
							ErrorMessage = message;
							//ErrorLine = line;
							//	ErrorCol = col;
							ErrorFilename = filename;
						}
						if (filename.empty() == false)
						{
							errormsg = "\"";
							errormsg += filename + "\"\n";
							if (line > 0)
							{
								sprintf(str, "%u", line);
								errormsg += " line ";
								errormsg += str;
								errormsg +="\n";
							}
							errormsg +=  message;
							msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mError) ? @"\n" :@"" ,errormsg.c_str()];
							[messageView performSelectorOnMainThread: SEL_fatalMessage withObject:msgStr waitUntilDone:NO];
							Mac_Parse_Error(filename.c_str(),line);
						}
						else
						{
							msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mError) ? @"\n" :@"" ,message.c_str()];
							[messageView performSelectorOnMainThread: SEL_fatalMessage withObject:msgStr waitUntilDone:NO];
						}
						previousMessage = vfeSession::mError;
						break;

					case vfeSession::mDivider:
						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mDivider) ? @"\n" :@"" ,message.c_str()];
						[messageView performSelectorOnMainThread: SEL_bannerMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mDivider;
						break;

					default:
						msgStr=[NSString stringWithFormat:@"%@%s\n", (previousMessage != vfeSession::mUnclassified) ? @"\n" :@"" ,message.c_str()];
						[messageView performSelectorOnMainThread: SEL_bannerMessage withObject:msgStr waitUntilDone:NO];
						previousMessage = vfeSession::mUnclassified;
						break;
				}
			}
		}
	}
	
} // end namespace


