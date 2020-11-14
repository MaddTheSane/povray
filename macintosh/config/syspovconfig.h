//******************************************************************************
///
/// @file /macintosh/config/syspovconfig.h
///
/// configuration file for macintosh platform
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
	#include <fcntl.h>

	#include <boost/tr1/memory.hpp>
	#define POV_TR1_NAMESPACE std::tr1

	// from directory "vfe"
	#include "vfeconf.h"
	using std::max;
	using std::min;

		#ifndef STD_TYPES_DECLARED
		#define STD_TYPES_DECLARED

		// the following types are used extensively throughout the POV source and hence are
		// included and named here for reasons of clarity and convenience.

		#include <exception>
		#include <stdexcept>
		#include <string>
		#include <vector>
		#include <list>

		#include <boost/version.hpp>
		#if BOOST_VERSION < 106500
			// Pulling in smart pointers is easy with Boost versions prior to 1.65.0, with the
			// `boost/tr1/*.hpp` set of headers simply pulling in whatever is available (C++11, TR1 or
			// boost's own implementation) and making it available in the `std::tr1` namespace.
			#include <boost/tr1/memory.hpp>
			#define POV_TR1_NAMESPACE std::tr1
		#else
			// With `boost/tr1/*.hpp` unavailable, we're currently blindly relying on the compiler to
			// be compliant with C++11.
			#include <memory>
			#define POV_TR1_NAMESPACE std
		#endif

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
		// (NOTE: If you're running into a compile error here, you're probably trying to compile POV-Ray
		// with Boost 1.65.0 or later and a non-C++11-compliant compiler. We currently do not support such a
		// combination.)
		using POV_TR1_NAMESPACE::shared_ptr;
		using POV_TR1_NAMESPACE::weak_ptr;
	#endif // STD_POV_TYPES_DECLARED

	#define METADATA_PLATFORM_STRING POVRAY_PLATFORM_NAME
	#define METADATA_COMPILER_STRING __VERSION__

	#define POV_RAY_IS_OFFICIAL 0
	#if defined(__GNUC__)
		#define COMPILER_VER "\n Compiler: gcc " __VERSION__
	#else
		#define COMPILER_VER "\nCompiler: "__VERSION__
	#endif

	#if defined(__i386__)
		#define POVRAY_PLATFORM_NAME "Apple_Intel32"
	#elif defined(__x86_64__)
		#define POVRAY_PLATFORM_NAME "Apple_Intel64"
	#endif

	#define ALTMAIN
	#define NEW_LINE_STRING "\n"  // default
	#define SYS_DEF_EXT     ""
	#define POV_FILE_SEPARATOR_2  '/'
	#define POV_FILE_SEPARATOR '/'
	#define DEFAULT_OUTPUT_FORMAT    kPOVList_FileType_PNG

	
	#define IFF_SWITCH_CAST (long)
	#define NON_UNIX_OPENEXR_HEADERS
	#define MEM_STATS 1

// After Stroustrop in _The C++ Programming Language, 3rd Ed_ p. 88
	#ifndef NULL
		const int NULL=0;
	#endif

#define POV_LONG long long

	#define DELETE_FILE(name)  unlink(name)

	# define FILE_NAME_LENGTH   PATH_MAX
	#ifndef MAX_PATH
		#define MAX_PATH PATH_MAX
	#endif

	// use a larger buffer for more efficient parsing
	#define DEFAULT_ITEXTSTREAM_BUFFER_SIZE 65536

	#define DEFAULT_DISPLAY_GAMMA 1.8
	#define DEFAULT_DISPLAY_GAMMA_TYPE          kPOVList_GammaType_SRGB
	#define DEFAULT_FILE_GAMMA    2.2
	#define DEFAULT_FILE_GAMMA_TYPE             kPOVList_GammaType_SRGB

/// Specifies the person or organization responsible for this build.
/// @attention Please set this to your real name, and/or include a working email or website address to contact you.
#define DISTRIBUTION_MESSAGE_2 "C.W. Betts - computers57@hotmail.com"

#endif // POVRAY_MACINTOSH_SYSPOVCONFIG_H
