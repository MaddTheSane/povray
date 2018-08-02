//******************************************************************************
///
/// @file /macintosh/sceneDocument/templates/materialmapTemplate.h
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
//********************************************************************************

#import <Cocoa/Cocoa.h>
#import "mapBaseTemplate.h"
#import "bodyMap.h"

#define materialmapFunction mTemplatePrefs[3]
#define materialmapPatternPigment mTemplatePrefs[4]
#define materialmapPigmentPigment mTemplatePrefs[5]


#define setMaterialmapFunction setTemplatePrefs:3 withObject			
#define setMaterialmapPatternPigment setTemplatePrefs:4 withObject	
#define setMaterialmapPigmentPigment setTemplatePrefs:5 withObject	

enum eMaterialmapEnum {
		cMaterialmapFileTypePopUp			=150,
	 	cMaterialmapEditFunctionButton		=151,
	 	cMaterialmapEditPatternButton		=152,
		cMaterialmapSelectImageFileButton	=153,
		cMaterialmapEditPigmentButton		=154,
		cMaterialmapProjectionPopUp			=155,
		cMaterialmapFilerAllOn					=156,
		cMaterialmapTransmitAllOn				=157
};

@interface MaterialmapTemplate : MapBaseTemplate
{

	IBOutlet NSPopUpButton 		*materialmapFileTypePopUp;
 	IBOutlet NSView 					*materialmapFileView;
 	IBOutlet NSView 					*materialmapWidthHeightView;
	IBOutlet NSTextField 			*materialmapFileName;
 	IBOutlet NSView 					*materialmapFunctionView;
 	IBOutlet NSTextView			*materialmapFunctionEdit;
 	IBOutlet NSTextField 			*materialmapFunctionImageWidth;
 	IBOutlet NSTextField 			*materialmapFunctionImageHeight;
 	IBOutlet NSView 					*materialmapPatternView;
 	IBOutlet NSView 					*materialmapPigmentView;
	IBOutlet NSPopUpButton 		*materialmapProjectionPopUp;
	IBOutlet NSButton 				*materialmapProjectionOnceOn;
	IBOutlet NSPopUpButton 		*materialmapInterpolationPopUp;
//extra for tooltips
	IBOutlet NSButton 				*materialmapFileNameButton;
	IBOutlet NSButton 				*materialmapFunctionFunctionButton;
	IBOutlet NSButton 				*materialmapPatternButton;
	IBOutlet NSButton 				*materialmapPigmentButton;

}
-(IBAction) materialmapTarget:(id)sender;
-(IBAction) materialmapButtons:(id)sender;

@end


