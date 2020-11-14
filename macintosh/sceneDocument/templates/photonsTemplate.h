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

	
enum ePhotonsTags{
	cPhotonsTargetOn			=10,
	cPhotonsRefractionOn		=20,
	cPhotonsReflectionOn		=30,
	cPhotonsCollectOn 			=40
};


@interface PhotonsTemplate : BaseTemplate
{

	//main

	IBOutlet NSButton		*photonsTargetOn;
	IBOutlet NSTextField	*photonsSpacingText;
	IBOutlet NSTextField	*photonsSpacingEdit;

	IBOutlet NSButton		*photonsReflectionOn;
	IBOutlet NSMatrix		*photonsReflectionMaxtrix;

	IBOutlet NSButton		*photonsRefractionOn;
	IBOutlet NSMatrix		*photonsRefractionMaxtrix;

	IBOutlet NSButton		*photonsCollectOn;
	IBOutlet NSMatrix		*photonsCollectMaxtrix;

	IBOutlet NSButton 		*photonsPassThroughOn;

}

-(IBAction) photonsTarget:(id)sender;

@end
