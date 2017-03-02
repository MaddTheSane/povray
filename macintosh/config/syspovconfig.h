//******************************************************************************
///
/// @file /macintosh/config/syspovconfig.h
///
/// configuration file for macintosh platform
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


#ifndef POVRAY_MACINTOSH_SYSPOVCONFIG_H
	#define POVRAY_MACINTOSH_SYSPOVCONFIG_H

	#define fseek64(stream,offset,whence) fseeko(stream,offset,whence)
	#define lseek64(handle,offset,whence) lseek(handle,offset,whence)

	#include <cmath>
	#include <cstdarg>
	#include <cstdlib>

	#include <exception>
	#include <list>
	#include <stdexcept>
	#include <string>
	#include <vector>

// boost headers
	#include <boost/intrusive_ptr.hpp>
	#include <boost/tr1/memory.hpp>

	//#include <fcntl.h>

    using std::max;
	using std::min;


	// the following types are used extensively throughout the POV source and hence are
	// included and named here for reasons of clarity and convenience.

	// when we say 'string' we mean std::string
	using std::string;

	// and vector is a std::vector
	using std::vector;

	// yup, list too
	using std::list;

	// runtime_error is the base of our Exception class, plus is referred
	// to in a few other places.
	using std::runtime_error;

	// these may actually be the boost implementations, depending on what boost/tr1/memory.hpp has pulled in
	using std::tr1::shared_ptr;
	using std::tr1::weak_ptr;
	using std::tr1::dynamic_pointer_cast;
	using std::tr1::static_pointer_cast;
	using std::tr1::const_pointer_cast;

	using boost::intrusive_ptr;

	#define METADATA_PLATFORM_STRING POVRAY_PLATFORM_NAME
	#define METADATA_COMPILER_STRING __VERSION__

	#define POV_RAY_IS_OFFICIAL 0
	#if defined(__GNUC__)
		#define COMPILER_VER "\nCompiler: gcc " __VERSION__
	#else
		#define COMPILER_VER "\nCompiler: "__VERSION__
	#endif



	#define NEW_LINE_STRING "\n"  // default
	#define SYS_DEF_EXT     ""
	#define POV_FILE_SEPARATOR_2  '/'
	#define POV_FILE_SEPARATOR '/'
	#define DEFAULT_OUTPUT_FORMAT    kPOVList_FileType_PNG

#define HAVE_NAN
	#define IFF_SWITCH_CAST (long)

	#define NON_UNIX_OPENEXR_HEADERS
	

	#define MEM_STATS 1 

	// After Stroustrop in _The C++ Programming Language, 3rd Ed_ p. 88
	#ifndef NULL
		const int NULL=0;
	#endif
 

	#define POV_LONG long long

	#define POV_DELETE_FILE(name)  unlink(name)

	# define FILE_NAME_LENGTH   PATH_MAX
	#ifndef MAX_PATH
		#define MAX_PATH PATH_MAX
	#endif

	// use a larger buffer for more efficient parsing
	#define DEFAULT_ITEXTSTREAM_BUFFER_SIZE 65536

	#define DEFAULT_DISPLAY_GAMMA 1.8
	
	#define DEFAULT_DISPLAY_GAMMA_TYPE          kPOVList_GammaType_SRGB

#define POV_ISNAN(x) std::isnan(x)

#define POV_ISINF(x) std::isinf(x)

#define POV_ISFINITE(x) (!POV_ISNAN(x) && !POV_ISINF(x))

/// Specifies the person or organization responsible for this build.
/// @attention Please set this to your real name, and/or include a working email or website address to contact you.
#define BUILT_BY "Yvo Smellenbergh - yvo.s@gmx.net"
//#error Please fill in BUILT_BY, then remove this line


#endif // POVRAY_MACINTOSH_SYSPOVCONFIG_H
