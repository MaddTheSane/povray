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

#import <Cocoa/Cocoa.h>
#import "baseTemplate.h"

@interface HeaderIncludeTemplate : BaseTemplate
{
	IBOutlet NSTextField		*headerIncludeComment1;
	IBOutlet NSButton			*headerIncludeComment1On;
	IBOutlet NSTextField		*headerIncludeComment2;
	IBOutlet NSButton			*headerIncludeComment2On;
	IBOutlet NSTextField		*headerIncludeComment3;
	IBOutlet NSButton			*headerIncludeComment3On;
	IBOutlet NSTextField		*headerIncludeComment4;
	IBOutlet NSButton			*headerIncludeComment4On;
	IBOutlet NSTextField		*headerIncludeComment5;
	IBOutlet NSButton			*headerIncludeComment5On;
	IBOutlet NSTextField		*headerIncludeComment6;
	IBOutlet NSButton			*headerIncludeComment6On;
	IBOutlet NSTextField		*headerIncludeComment7;
	IBOutlet NSButton			*headerIncludeComment7On;

	IBOutlet NSTextField		*headerIncludeInclude1;
	IBOutlet NSButton			*headerIncludeInclude1On;
	IBOutlet NSTextField		*headerIncludeInclude2;
	IBOutlet NSButton			*headerIncludeInclude2On;
	IBOutlet NSTextField		*headerIncludeInclude3;
	IBOutlet NSButton			*headerIncludeInclude3On;
	IBOutlet NSTextField		*headerIncludeInclude4;
	IBOutlet NSButton			*headerIncludeInclude4On;
	IBOutlet NSTextField		*headerIncludeInclude5;
	IBOutlet NSButton			*headerIncludeInclude5On;
	IBOutlet NSTextField		*headerIncludeInclude6;
	IBOutlet NSButton			*headerIncludeInclude6On;
	IBOutlet NSTextField		*headerIncludeInclude7;
	IBOutlet NSButton			*headerIncludeInclude7On;
	IBOutlet NSTextField		*headerIncludeInclude8;
	IBOutlet NSButton			*headerIncludeInclude8On;
	IBOutlet NSTextField		*headerIncludeInclude9;
	IBOutlet NSButton			*headerIncludeInclude9On;
	IBOutlet NSTextField		*headerIncludeInclude10;
	IBOutlet NSButton			*headerIncludeInclude10On;
	IBOutlet NSTextField		*headerIncludeInclude11;
	IBOutlet NSButton			*headerIncludeInclude11On;
	IBOutlet NSTextField		*headerIncludeInclude12;
	IBOutlet NSButton			*headerIncludeInclude12On;

	IBOutlet NSTextField		*headerIncludeVersion1;
	IBOutlet NSButton			*headerIncludeVersion1On;
	IBOutlet NSTextField		*headerIncludeVersion2;
	IBOutlet NSButton			*headerIncludeVersion2On;

}


-(void) setCommentState;
-(void) setIncludeState;
-(void) setVersionState;

- (IBAction)switchedOn:(id)sender;
@end
