//******************************************************************************
///
/// @file /macintosh/config/syspovconfigbase.h
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


#ifndef POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H
#define POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H

#include "syspovconfig.h"

#define POV_PATH_SEPARATOR '/'
#define IFF_SWITCH_CAST (long)

// OSX has nanosleep(), we user our own Delay() function
#define POV_USE_DEFAULT_DELAY 0

// OSX provides platform-specific mechanisms to measure both wall-clock and CPU time.
#define POV_USE_DEFAULT_TIMER 0

// The default Path::ParsePathString() suits our needs perfectly.
#define POV_USE_DEFAULT_PATH_PARSER 1

#endif // POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H
