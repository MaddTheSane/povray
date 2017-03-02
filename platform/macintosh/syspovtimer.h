//******************************************************************************
///
/// @file /platform/mamcintosh/syspovtimer.h
///
/// Declaration of the Macintosh-specific implementation of the @ref Timer class.
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

#ifndef POVRAY_MACINTOSH_SYSPOVTIMER_H
#define POVRAY_MACINTOSH_SYSPOVTIMER_H

#include "base/configbase.h"

namespace pov_base
{

#if !POV_USE_DEFAULT_DELAY

void Delay(unsigned int msec);

#endif // !POV_USE_DEFAULT_DELAY


#if !POV_USE_DEFAULT_TIMER

/// Millisecond-precision timer.
///
/// This is the Macintosh-specific implementation of the millisecond-precision timer required by POV-Ray.
///
/// @impl
///     As of osx 10.12 (macos Sierra) clock_gettime() is available.
///     Since we support osx 10.7.4 up to the most recent one
///     We use host_get_clock_service() and thread_info()

class Timer
{
    public:

        Timer();
        ~Timer();

       inline POV_LONG ElapsedRealTime() const { return GetWallTime () - mWallTimeStart; };
       inline POV_LONG ElapsedProcessCPUTime() const { return GetProcessTime () - mProcessTimeStart; };
        inline POV_LONG ElapsedThreadCPUTime()const  {return GetThreadTime () - mThreadTimeStart; };

        void Reset();

        inline bool HasValidProcessCPUTime() const {return true;} ;
        inline bool HasValidThreadCPUTime() const  {return true; };

    private:

        POV_ULONG mWallTimeStart;
        POV_ULONG mProcessTimeStart;
        POV_ULONG mThreadTimeStart;

        POV_ULONG GetWallTime() const;
        POV_ULONG GetThreadTime() const;
        POV_ULONG GetProcessTime() const;
};

#endif // !POV_USE_DEFAULT_TIMER

}

#endif // POVRAY_MACINTOSH_SYSPOVTIMER_H
