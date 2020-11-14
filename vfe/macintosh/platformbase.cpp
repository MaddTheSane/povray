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
#include "syspovconfig.h"
#include <stdint.h>

#include <mach/mach.h>
#include <mach/clock.h>

#ifdef HAVE_TIME_H
# include <time.h>
#endif

#ifdef HAVE_SYS_TIME_H
# include <sys/time.h>
#endif

#ifdef HAVE_SYS_RESOURCE_H
# include <sys/resource.h>
#endif

#include "vfe.h"

// this must be the last file included
#include "base/povdebug.h"

namespace pov_base
{

	////////////////////////////////////////////////////////////////////////////////////////
	//
	// thread support
	//
	////////////////////////////////////////////////////////////////////////////////////////

	/////////////////////////////////////////////////////////////////////////
	// called by the base code each time a worker thread is created (the call
	// is made in the context of the new thread).
	void vfeSysThreadStartup(void)
	{
	}

	/////////////////////////////////////////////////////////////////////////
	// called by a worker thread just before it exits.
	void vfeSysThreadCleanup(void)
	{
	}

	////////////////////////////////////////////////////////////////////////////////////////
	//
	// class vfeTimer (OPTIONAL)
	//
	// if you don't want to supply this class, remove the definition for POV_TIMER from
	// config.h. see the base code for documentation on the implementation requirements.
	//
	////////////////////////////////////////////////////////////////////////////////////////

	vfeTimer::vfeTimer (bool CPUTimeIsThreadOnly)
	{
		m_ThreadTimeOnly = CPUTimeIsThreadOnly;
		Reset();
	}

	vfeTimer::~vfeTimer ()
	{
	}

	unsigned POV_LONG vfeTimer::GetWallTime (void) const
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
            {
                timestamp = static_cast<POV_ULONG>(mts.tv_sec)  *1000+ static_cast<POV_ULONG>(mts.tv_nsec) /1000000;
                return timestamp;
            }
        }
        return timestamp;   // zero on erro
	}

	unsigned POV_LONG vfeTimer::GetCPUTime (void) const
	{
        POV_LONG result= 0;
        kern_return_t error;
        mach_msg_type_number_t count;
        thread_basic_info_data_t thread_info_data;
        
        count = THREAD_BASIC_INFO_COUNT;
        error = thread_info(mach_thread_self(), THREAD_BASIC_INFO, (thread_info_t)&thread_info_data, &count);
        if (error == KERN_SUCCESS  )
        {
            result = (static_cast<POV_LONG>(thread_info_data.user_time.seconds)  + static_cast<POV_LONG>(thread_info_data.system_time.seconds))  *1000
            + (static_cast<POV_LONG>(thread_info_data.user_time.microseconds) + static_cast<POV_LONG>(thread_info_data.system_time.microseconds)) /1000;
        }
        return result;
        
        
        
        
 	}

	POV_LONG vfeTimer::ElapsedRealTime (void) const
	{
		return GetWallTime() - m_WallTimeStart;
	}

	POV_LONG vfeTimer::ElapsedCPUTime (void) const
	{
		return GetCPUTime() - m_CPUTimeStart;
	}

	void vfeTimer::Reset (void)
	{
		m_WallTimeStart = GetWallTime();
		m_CPUTimeStart = GetCPUTime();
	}

	bool vfeTimer::HasValidCPUTime() const
	{
		return true;
	}

	////////////////////////////////////////////////////////////////////////////////////////
	//
	// path parsing
	//
	////////////////////////////////////////////////////////////////////////////////////////

	////////////////////////////////////////////////////////////////////////////////////////
	// The first argument is the input, a UCS2 string.
	//
	// The second argument is the string you are supposed to return the "volume"
	// name with.  For DOS-style paths this implies i.e. "A:\" is the "volume".
	// Note that it is essential that the first "path" separator is also part of
	// the volume name.  If the path is relative, the "volume" name shall be empty.
	//
	// This trick is necessary so the code can account for the lack of volume names
	// in Unix-style paths: In Unix, the POV_PARSE_PATH_STRING function will have
	// to take a reading "/" or "~/" as "volume" name.  This makes it possible to
	// determine if a string is absolute or relative based on this 'virtual'
	// "volume" name rather than some flags.
	//
	// The third is a vector of strings you have to return, each has to contain the
	// folder name from left to right, without the path separator, of course.
	//
	// The fourth argument shall contain the filename, if any was given in the
	// source string. By definition if the source string does not contain a
	// trailing path separator, whatever comes after the last path separator
	// (or the start of the string if there is none) must be considered a filename,
	// even if it could be a directory (in other words, don't call a system function
	// to find out if it is a dir or not - see below).
	//
	// Please note that the function must not attempt to determine the validity of
	// a string by accessing the filesystem.  It has to parse anything that it is
	// given.  If the string provided cannot be parsed for some reason (that is if
	// you can determine that a given path cannot possibly be valid i.e. because it
	// contains invalid characters), the function has to return false.  It may not
	// throw exceptions.  The return value for success is true.
	////////////////////////////////////////////////////////////////////////////////////////

	bool vfeParsePathString (const UCS2String& path, UCS2String& volume, vector<UCS2String>& components, UCS2String& filename)
	{
		UCS2String q;

		if(path.empty() == true)
			return true;

		if(path[0] == '/')
			volume = '/';

		for(size_t i = 0; i < path.length(); ++i)
		{
			if(path[i] == '/')
			{
				if(q.empty() == false)
					components.push_back(q);
				q.clear();
			}
			else
				q += path[i];
		}

		filename = q;

		return true;
	}

}
