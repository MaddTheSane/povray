//******************************************************************************
///
/// @file /macintosh/config/syspovconfigbackend.h
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


#ifndef POVRAY_MACINTOSH_SYSPOVCONFIGBACKEND_H
#define POVRAY_MACINTOSH_SYSPOVCONFIGBACKEND_H

#include "syspovconfig.h"

#if defined(__i386__)
	#define POVRAY_PLATFORM_NAME "Macintosh 32Bit"
#elif defined(__x86_64__)
	#define POVRAY_PLATFORM_NAME "Macintosh 64Bit"
#endif

#define ALTMAIN

// NEW_LINE_STRING remains undefined, optimizing the code for "\n" as used internally
#define SYS_DEF_EXT     ""

// On Unix platforms, we don't do anything special at thread startup.
#define POV_USE_DEFAULT_TASK_INITIALIZE 1
#define POV_USE_DEFAULT_TASK_CLEANUP    1

#endif //POVRAY_MACINTOSH_SYSPOVCONFIGBACKEND_H
