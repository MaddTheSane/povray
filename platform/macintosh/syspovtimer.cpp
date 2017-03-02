//******************************************************************************
///
/// @file /platform/mamcintosh/syspovtimer.cpp
///
/// Implementation of the Macintosh-specific implementation of the @ref Timer class.
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

#include "syspovtimer.h"

#include <time.h>
#include <sys/time.h>
#include <mach/mach.h>
#include <mach/clock.h>

// this must be the last file included
#include "base/povdebug.h"

// this must be the last file included
#include "base/povdebug.h"



namespace pov_base
{
    
    //******************************************************************************
    
#if !POV_USE_DEFAULT_DELAY
    
    void Delay(unsigned int msec)
    {
        timespec ts;
        ts.tv_sec = msec / 1000;
        ts.tv_nsec = (POV_ULONG) (1000000) * (msec % 1000);
        nanosleep(&ts, NULL);
    }
    
#endif // !POV_USE_DEFAULT_DELAY
    
    //******************************************************************************
#if !POV_USE_DEFAULT_TIMER
    // Mac OS X supports three clocks:
    
    // SYSTEM_CLOCK returns the time since boot time;
    // CALENDAR_CLOCK returns the UTC time since 1970-01-01;
    // REALTIME_CLOCK is deprecated and is the same as SYSTEM_CLOCK in its current implementation.
    // The documentation for clock_get_time says the clocks are monotonically incrementing unless
    // someone calls clock_set_time. Calls to clock_set_time are discouraged as it could break
    // the monotonic property of the clocks, and in fact, the current implementation returns KERN_FAILURE without doing anything.
    /// get milliseconds time using `host_get_clock_service()`.
    static inline bool ClockGettimeMillisec(POV_ULONG& result )
    {
        kern_return_t Kern_result;
        clock_serv_t cclock;
        mach_timespec_t mts;
        Kern_result = host_get_clock_service(mach_host_self(), CALENDAR_CLOCK, &cclock);
        if ( Kern_result != KERN_SUCCESS )
            return false;
        
        Kern_result = clock_get_time(cclock, &mts);
        mach_port_deallocate(mach_task_self(), cclock);
        if ( Kern_result != KERN_SUCCESS )
            return false;
        
        result = static_cast<POV_ULONG>(mts.tv_sec)  *1000+ static_cast<POV_ULONG>(mts.tv_nsec) /1000000;
        return true;
    }
    
    /// get milliseconds elapsed CPU-time using `getrusage()`.
    static inline bool GetrusageMillisec(POV_ULONG& result)
    {
        struct rusage ru;
        bool success = (getrusage(RUSAGE_SELF, &ru) == 0);
        if (success)
            result = (static_cast<POV_ULONG>(ru.ru_utime.tv_sec)  + static_cast<POV_ULONG>(ru.ru_stime.tv_sec))  *1000
            + (static_cast<POV_ULONG>(ru.ru_utime.tv_usec) + static_cast<POV_ULONG>(ru.ru_stime.tv_usec)) /1000;
        return success;
    }

    
    /// get milliseconds elapsed Per Thread-CPU-time using `thread_info()`.
   static inline bool GetPerThreadCPUTimeMilisec (POV_ULONG& result)
    {
        kern_return_t error;
        mach_msg_type_number_t count;
        thread_basic_info_data_t thread_info_data;
        
        count = THREAD_BASIC_INFO_COUNT;
        error = thread_info(mach_thread_self(), THREAD_BASIC_INFO, (thread_info_t)&thread_info_data, &count);
        if (error == KERN_SUCCESS  )
        {
            result = (static_cast<POV_ULONG>(thread_info_data.user_time.seconds)  + static_cast<POV_ULONG>(thread_info_data.system_time.seconds))  *1000
           + (static_cast<POV_ULONG>(thread_info_data.user_time.microseconds) + static_cast<POV_ULONG>(thread_info_data.system_time.microseconds)) /1000;
            return true;
        }
        return false;
   }


Timer::Timer ()
{
    // timer to use for wall clock time.
    if (!ClockGettimeMillisec(mWallTimeStart))
        mWallTimeStart = 0;
    
    
    // timer to use for per-process CPU time.
    if (!GetrusageMillisec(mProcessTimeStart))
        mProcessTimeStart = mWallTimeStart;
    
    
    // timer to use for per-thread CPU time.
    
    if (!GetPerThreadCPUTimeMilisec(mThreadTimeStart))
        mThreadTimeStart = mProcessTimeStart;
}

Timer::~Timer ()
{
    // nothing to do
}

POV_ULONG Timer::GetWallTime () const
{
    POV_ULONG result;
    return (ClockGettimeMillisec(result) ? result : 0);
}

POV_ULONG Timer::GetProcessTime () const
{
    POV_ULONG result;
    return (GetrusageMillisec(result) ? result : 0);
}

POV_ULONG Timer::GetThreadTime () const
{
    POV_ULONG result;
    return (GetPerThreadCPUTimeMilisec(result) ? result : 0);
}
void Timer::Reset ()
{
    mWallTimeStart    = GetWallTime ();
    mProcessTimeStart = GetProcessTime ();
    mThreadTimeStart  = GetThreadTime ();
}


#endif // !POV_USE_DEFAULT_TIMER

//******************************************************************************

}
