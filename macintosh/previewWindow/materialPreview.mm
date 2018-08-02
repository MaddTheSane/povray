//******************************************************************************
///
/// @file /macintosh/previewWindow/materialPreview.mm
///
/// small subclass of picturePreviewBase used for the material template preveiw
/// to do: this class can be deleted after a few modifications in the base class
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
#import "MainController.h"
#import "MaterialPreview.h"
 
// this must be the last file included
#import "syspovdebug.h"

@implementation materialPreview


//---------------------------------------------------------------------
// hideAndReleaseContent
// Just before a render, release memory for the content
// there is no window as in the base class
//---------------------------------------------------------------------
- (void) hideAndReleaseContent
{
	[self _destroyCache];
}

//---------------------------------------------------------------------
// adjustWindow
// override, nothing to do for material preview
// called from displayInit: withWidth: andHeight
// we don't have a window in the material preview
//---------------------------------------------------------------------
-(void) adjustWindow
{
}




@end
