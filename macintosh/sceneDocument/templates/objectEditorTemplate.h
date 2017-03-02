//******************************************************************************
///
/// @file <File Name>
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


#import <Cocoa/Cocoa.h>
#import "mapBaseTemplate.h"
#import "objectMap.h"
	
@interface ObjectEditorTemplate : MapBaseTemplate
{

	IBOutlet NSButton 			*SlopeButton;
	IBOutlet NSButton 			*PointButton;
	IBOutlet NSButton 			*CurveButton;
	IBOutlet NSButton 			*RasterButton;
	IBOutlet NSPopUpButton 	*splineTypePopUp;
	IBOutlet NSTextField		*splineTypeText;
	IBOutlet NSTextField		*drawPointsEdit;
	IBOutlet NSTableColumn	*yColumn;
	IBOutlet id						previewView;
	
	IBOutlet NSMatrix			*objectEditorActionOnPoints;
	IBOutlet NSTextField		*objectEditorScaleEdit;
	IBOutlet NSTextField		*objectEditorRotateEdit;
	IBOutlet NSTextField		*objectEditorMoveEdit;
	//extra for tooptips
	IBOutlet NSTableView		*objectEditorTableView;
	
	IBOutlet NSButton 			*objectEditorDrawNowButton;
	IBOutlet NSButton 			*objectEditorAddButton;
	IBOutlet NSButton 			*objectEditorInsertButton;
	IBOutlet NSButton 			*objectEditorTrashButton;
	IBOutlet NSButton 			*objectEditorApplyScaleButton;
	IBOutlet NSButton 			*objectEditorApplyRotateButton;
	IBOutlet NSButton 			*objectEditorApplyMoveLeftButton;
	IBOutlet NSButton 			*objectEditorApplyMoveRightButton;
	IBOutlet NSButton 			*objectEditorApplyMoveUpButton;
	IBOutlet NSButton 			*objectEditorApplyMoveDownButton;
	
	
}
-(IBAction) objectmapmapButtons:(id)sender;
-(void) applyArrows:(int) tag;
-(void) applyScaleRotate:(int)tag;
-(void) setPointToMin:(float & ) theValue thePoint:(NSInteger&)thePoint;

@end


