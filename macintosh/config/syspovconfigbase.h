//******************************************************************************
///
/// @file /macintosh/config/syspovconfigbase.h
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


#ifndef POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H
#define POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H

#include "syspovconfig.h"

// added by C.H. - see source/base/timer.h:
// uncomment to use default time if no platform specific implementation is provided.
//#undef POV_TIMER
#undef POV_DELAY_IMPLEMENTED

#define FILENAME_SEPARATOR '/'
#define IFF_SWITCH_CAST (long)

#endif // POVRAY_MACINTOSH_SYSPOVCONFIGBASE_H