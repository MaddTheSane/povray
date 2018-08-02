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


// must come first
#import <Cocoa/Cocoa.h>
#include <mach/mach.h>
#include <mach/clock.h>

#import "syspovconfig.h"

#import <pthread.h>
#import <stdlib.h>
#import <string.h>

#import <time.h>
#import <signal.h>
#import "vfe.h"

namespace vfePlatform
{
	using namespace vfe;
		/////////////////////////////////////////////////////////////////////////
		// return a number that uniquely identifies the calling thread amongst
		// all other running threads in the process (and preferably in the OS).
		POVMS_Sys_Thread_Type GetThreadId ()
		{
			return (POVMS_Sys_Thread_Type) pthread_self();
		}
		
		//////////////////////////////////////////////////////////////
		// User-interface functions
		//////////////////////////////////////////////////////////////

		vfeMacSession::vfeMacSession(int id) :
			m_LastTimestamp(0), m_TimestampOffset(0), vfeSession(id)
		{
//			m_OptionsProc = boost::shared_ptr<UnixOptionsProcessor>(new UnixOptionsProcessor(this));
		}

		/////////////////////////////////////////////////////////////////////////
		// this method will get called when a render completes and the image writing
		// code is unable to write the requested output file for some reason (e.g.
		// disk full, existing output file is read-only, or whatever). the return
		// value can determine any one of several possible actions the code will take.
		// it's up to you what you do here, but a typical example would be to display
		// an error dialog showing the reason (which will be a short string) and the old
		// path, and allow the user to browse for a new path (you may want to auto-
		// suggest one). it is allowable to perform tests yourself on the path to
		// obtain some OS-specific information as to why it failed in order to better
		// determine what to suggest as the new path (e.g. the the output path is
		// not writable due to insufficient privileges, you may want to default the
		// new path to the user's home directory).
		//
		// any new path that is to be returned should be placed in NewPath. the parameter
		// CallCount will initially be 0, and represents the number of times the
		// method has been called for a given rendering; this allows you for example
		// to auto-default on the first call and prompt the user on subsequent ones.
		// (note that if you do this and the auto-default succeeds, it's up to you to
		// notify the user that the output file is not what they originally asked for).
		//
		// you may want to place a timeout on this dialog if the session is running
		// an animation and return in the case of a timeout a default value.
		//
		// the return values can be any of the following:
		//
		//   0 : don't try again, leave the render without an output file but preserve
		//       the state file (so a render with +c will reload the image data).
		//   1 : reserved for later support
		//   2 : don't try again and delete the state file (rendered data can't be
		//       recovered).
		//   3 : try again with the same file (NewPath is ignored).
		//   4 : try again with the new path returned in NewPath.
		//
		// note that if you choose to specify any of the "don't try again" options,
		// and the session happens to be an animation, and it's likely the same
		// error will occur again (e.g. invalid output path or something), then
		// you may want to call the render cancel API so the user isn't bombarded
		// with an error message for each frame of the render.
		int vfeMacSession::RequestNewOutputPath(int CallCount, const string& Reason, const UCS2String& OldPath, UCS2String& NewPath)
		{
			// TODO: print warning and cancel?
			return 0;
		}

		//////////////////////////////////////////////////////////////
		// File-system related support functions
		//////////////////////////////////////////////////////////////

		/////////////////////////////////////////////////////////////////////////
		// return an absolute path including trailing path separator.
		// *nix platforms might want to just return "/tmp/" here.
		UCS2String vfeMacSession::GetTemporaryPath(void) const
		{
			NSString *tempPathName=NSTemporaryDirectory();
			tempPathName=[tempPathName stringByAppendingString:@"/"];

			return ASCIItoUCS2String ([tempPathName UTF8String]);
		}

		/////////////////////////////////////////////////////////////////////////
		// might be better called 'CreateTemporaryFileName()' since pov
		// doesn't actually want the file opened; just the full path and
		// name to one that it can use.
		UCS2String vfeMacSession::CreateTemporaryFile(void) const
		{
			NSString *tempFileName=NSTemporaryDirectory();
			tempFileName=[tempFileName stringByAppendingString:@"/povtempfile"];


			return ASCIItoUCS2String ([tempFileName UTF8String]);
		}

		/////////////////////////////////////////////////////////////////////////
		// you could check that the path given lies within the paths that
		// your platform gives out for temporary files if you want; this
		// example doesn't do that but it's not a bad idea to add.
		void vfeMacSession::DeleteTemporaryFile(const UCS2String& filename) const
		{
			DELETE_FILE (UCS2toASCIIString (filename).c_str());
		}

		//////////////////////////////////////////////////////////////
		// vfe or POVMS related support functions
		//////////////////////////////////////////////////////////////

		/////////////////////////////////////////////////////////////////////////
		// This method will get called on POVMS critical errors (e.g. cannot
		// allocate memory, amongst other things). Note that you should not
		// assume that you can e.g. allocate memory when processing this call.
		//
		// Before calling this function vfe sets a flag that prevents the worker
		// thread from processing any more messages; it will wait for you to
		// call Shutdown(). Your UI thread can find out if this method has been
		// called by checking for the presence of the stCriticalError status bit
		// returned from vfeSession::GetStatus() (note that this bit is not
		// necessarily already set at the time the method is called though).
		//
		// If you are running a genuine virtual frontend (e.g. stateless HTTP
		// interface), we may want to set a flag to display the message later
		// rather than pop up a messagebox on the local windowstation. Otherwise
		// you would probably display the message immediately.
		void vfeMacSession::NotifyCriticalError (const char *message, const char *filename, int line)
		{
			fprintf (stderr, "POV-Ray Critical Error: %s", message);
		}

		////////////////////////////////////////////////////////////////////////
		// Return a timestamp to be used internally for queue sorting etc. The
		// value returned must be 64-bit and in milliseconds; the origin of the
		// count is not important (e.g. milliseconds since 1/1/1970, or whatever
		// it doesn't matter), as long as it is consistent value (milliseconds
		// since system boot is NOT a valid value since it will change each boot).
		// Also please don't call time() and multiply by 1000 since vfe wants at
		// least 100ms precision (so it can do sub-one-second event timing).
		//
		// It's also important that the count not go backwards during the life
		// of a vfeSession instance; this means you should attempt to detect wall
		// clock changes by caching the last value your implementation returns
		// and adding an appropriate offset if you calculate a lower value later
		// in the session.
		POV_LONG vfeMacSession::GetTimestamp(void) const
		{
            
                POV_LONG timestamp = 0;  // in milliseconds
                kern_return_t Kern_result;
                clock_serv_t cclock;
                mach_timespec_t mts;
                Kern_result = host_get_clock_service(mach_host_self(), CALENDAR_CLOCK, &cclock);
                if ( Kern_result == KERN_SUCCESS )
                {
                    Kern_result = clock_get_time(cclock, &mts);
                    mach_port_deallocate(mach_task_self(), cclock);
                    if ( Kern_result == KERN_SUCCESS )
                        timestamp = static_cast<POV_ULONG>(mts.tv_sec)  *1000+ static_cast<POV_ULONG>(mts.tv_nsec) /1000;
                }
                timestamp += m_TimestampOffset;
                if (timestamp < m_LastTimestamp)
                {
                    // perhaps the system clock has been adjusted?
                    m_TimestampOffset += m_LastTimestamp - timestamp;
                    timestamp = m_LastTimestamp;
                }
                else
                    m_LastTimestamp = timestamp;
                return timestamp;
		}

		/////////////////////////////////////////////////////////////////////////
		// called when the worker thread starts - you could if you like set the
		// thread priority here.
		void vfeMacSession::WorkerThreadStartup()
		{
		}

		/////////////////////////////////////////////////////////////////////////
		// called just before the worker thread exits.
		void vfeMacSession::WorkerThreadShutdown()
		{
		}

		/////////////////////////////////////////////////////////////////////////
		// The following methods support the I/O permissions feature
		/////////////////////////////////////////////////////////////////////////

		/////////////////////////////////////////////////////////////////////////
		// case-sensitive string comparison
		bool vfeMacSession::StrCompare (const UCS2String& lhs, const UCS2String& rhs) const
		{
			return lhs.compare(rhs);
		}

		/////////////////////////////////////////////////////////////////////////
		// return true if the path component of file is equal to the path component
		// of path. will also return true if recursive is true and path is a parent
		// of file. does not support relative paths, and will perform case-sensitive
		// comparisons.
		bool vfeMacSession::TestPath (const Path& path, const Path& file, bool recursive) const
		{
			// we don't support relative paths
			if (path.HasVolume() == false || file.HasVolume() == false)
				return (false);
			if (StrCompare(path.GetVolume(), file.GetVolume()) == false)
				return (false);

			vector<UCS2String> pc = path.GetAllFolders();
			vector<UCS2String> fc = file.GetAllFolders();
			if (fc.size() < pc.size())
				return (false) ;
			for (int i = 0 ; i < pc.size(); i++)
				if (StrCompare(fc[i], pc[i]) == false)
					return (false) ;
			return (fc.size() == pc.size() ? true : recursive);
		}

		/////////////////////////////////////////////////////////////////////////
		// returns true if opening the given file in the specified mode is to
		// be permitted. it is allowed to ask the user, so this method could
		// take some time to return (especially if user is not at workstation ...)
		//
		// TODO: modify this to work fully with UCS2 strings (no conversion)
		bool vfeMacSession::TestAccessAllowed (const Path& file, bool isWrite) 
		{
			return true;
			/*
			if (!m_OptionsProc->isIORestrictionsEnabled(isWrite))
				return true;

			string FullFnm = m_OptionsProc->CanonicalizePath(UCS2toASCIIString(file()));
			if(FullFnm.length() == 0)
				return false;

			Path fullPath(FullFnm);

			if (isWrite)
			{
				// we do special-case hard-coded exclusion test(s) here
				for (IOPathVector::const_iterator it = GetExcludedPaths().begin(); it != GetExcludedPaths().end(); it++)
				{
					if (TestPath(it->GetPath(), fullPath, it->IsRecursive()))
					{
						m_OptionsProc->IORestrictionsError(UCS2toASCIIString(file()), isWrite, false);
						return (false) ;
					}
				}
			}
			else
			{
				// it's a read
				for (IOPathVector::const_iterator it = GetReadPaths().begin(); it != GetReadPaths().end(); it++)
					if (TestPath(it->GetPath(), fullPath, it->IsRecursive()))
						return (true) ;

				// access for write implies access for read (this is by design).
				// so we check the write specs below instead of giving an error here.
			}

			for (IOPathVector::const_iterator it = GetWritePaths().begin(); it != GetWritePaths().end(); it++)
				if (TestPath(it->GetPath(), fullPath, it->IsRecursive()))
					return (true) ;

			m_OptionsProc->IORestrictionsError(UCS2toASCIIString(file()), isWrite, true);
			return (false);
		*/
		}

	/////////////////////////////////////////////////////////////////////////////
	// Shellout support class (MacShelloutProcessing)
	/////////////////////////////////////////////////////////////////////////////
	// See the comments in source/frontend/shelloutprocessing.h for documentation
	// on the requirements for these methods.
	/////////////////////////////////////////////////////////////////////////////

	MacShelloutProcessing::MacShelloutProcessing(POVMS_Object& opts, const string& scene, uint width, uint height): ShelloutProcessing(opts, scene, width, height)
	{
		m_ProcessRunning = false;
		m_ProcessId = m_LastError = m_ExitCode = 0;
	}

	MacShelloutProcessing::~MacShelloutProcessing()
	{
		if (MacShelloutProcessing::CommandRunning())
			KillShellouts(1, true);
		CollectCommand();
	}

	bool MacShelloutProcessing::ExecuteCommand(const string& cmd, const string& params)
	{
		if (MacShelloutProcessing::CommandRunning())
			throw POV_EXCEPTION(kNotNowErr, "Cannot create new process as previous shellout has not terminated");

		CollectCommand();
		m_Command = cmd;
		m_Params = params;
		m_ProcessId = m_LastError = m_ExitCode = 0;

		// TODO: IMPLEMENT (see vfe/win/vfeplatform.cpp for example)

		return m_ProcessRunning;
	}

	bool MacShelloutProcessing::CommandRunning(void)
	{
		if (!m_ProcessRunning)
			return false;

		// TODO: IMPLEMENT (see vfe/win/vfeplatform.cpp for example)

		return false;
	}

	int MacShelloutProcessing::ProcessID(void)
	{
		if (!MacShelloutProcessing::CommandRunning())
			return 0;
		return m_ProcessId;
	}

	bool MacShelloutProcessing::KillCommand(int timeout, bool force)
	{
		if (!MacShelloutProcessing::CommandRunning())
			return true;
		// TODO: IMPLEMENT (see vfe/win/vfeplatform.cpp for example)

		return false;
	}

	int MacShelloutProcessing::CollectCommand(void)
	{
		if (m_ProcessRunning == false)
			return -2;
		if (MacShelloutProcessing::CommandRunning())
			return -1;

		// TODO: IMPLEMENT (see vfe/win/vfeplatform.cpp for example)

		return m_ExitCode;
	}

	int MacShelloutProcessing::CollectCommand(string& output)
	{
		// TODO: IMPLEMENT IF OUTPUT COLLECTION TO BE SUPPORTED

		return CollectCommand();
	}

	bool MacShelloutProcessing::CommandPermitted(const string& command, const string& parameters)
	{
		// TODO: IMPLEMENT (probably all that is needed is to check if the Unix options
		//                  permit shellouts. the default should be no.)

		return false;
	}


		
	}