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

#import "mapPreview.h"

enum {
	cBackgroundPictureLoad			=1,
	cBackgroundPictureReload		=2,
	cBackgroundPictureRemove		=3,
	cBackgroundPictureBrighten	=5,
	cBackgroundPictureDarken		=6,
	cBackgroundPictureGrayscale	=7,
	
	cShowBackgroundPictureButton	=280,
	cZoomSlider								=281,
	cSizeSlider									=282,
	cObjectEditorCenter					=283
};


@interface objectEditorPreview : mapPreview
{
	IBOutlet NSPopUpButton 	*mBackgroundPicturePopup;
	IBOutlet NSButton 			*mCenter;
	IBOutlet NSButton 			*mShiftLeft;
	IBOutlet NSButton 			*mShiftRight;
	IBOutlet NSButton 			*mShiftUp;
	IBOutlet NSButton 			*mShiftDown;
	IBOutlet NSButton 			*mShowPictureButton;
	IBOutlet NSSlider 			*mZoomSlider;
	IBOutlet NSSlider 			*mSizeSlider;
	IBOutlet NSBox				*mImageControlsView;
	NSRect mFrame;
	NSRect mRasterFrame;
	NSRect mDrawFrame;
	float mXToCenter;
	float mYToCenter;
	float mRasterStep;
	NSRect *mPointList;	
		
	int mSlopeOn;
	int	mPointOn;
	int	mCurveOn;
	int mRasterOn;
	
	//image
	NSImage *mImage;
	NSString *mImagePath;
	NSRect mImageFromRect;
	NSRect mImageToRect;
	float shiftLeft, shiftUp, zoomIn, sizeIn;
	BOOL mIsGray;
}
-(IBAction) backgroundPicturePopup:(id)sender;
-(void) calculateBackgroundRects;
-(NSString*) imagePath;
-(void) setImagePath:(NSString *)file;
-(NSImage*) image;
-(void) setImage:(NSImage *)img;
-(void) 	resetImagePosition;
-(void) setImageControls;
-(void) grayScale;
-(void) darken;
-(void) brighten;
-(NSBitmapImageRep *) makeRepBitmap;

-(void) loadNewBackgroundImage:(NSString*)file;
-(IBAction) objectPreviewButtons:(id)sender;

-(void)drawSelectedPoint;
-(void) getControlPoint:(NSInteger) SelectedPoint controlPoint:(NSInteger&)ControlPoint centerPoint:(NSInteger&)CenterPoint event:(NSEvent*)event;
-(void) setPointToMin:(float & ) theValue thePoint:(NSInteger&)thePoint;
-(void) drawPolygon;
-(void) drawPrism;
-(void) drawSor;
-(void) drawLathe;
-(void) drawQubicQuadratic;
-(void) drawBezier;
-(void) getLeftRightPoint:(NSInteger) SelectedPoint leftPoint:(NSInteger&)LeftPoint rightPoint:(NSInteger&)RightPoint event:(NSEvent*)event;
-(void) getLastPoint:(NSInteger&)SelectedPoint lastPoint:(NSInteger&)LastPoint;
-(void) calculateControlPoint:(NSInteger)SelectedPoint controlPoint:(NSInteger&)ControlPoint centerPoint:(NSInteger&)CenterPoint;

@end

