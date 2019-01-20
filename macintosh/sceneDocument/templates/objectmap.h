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
#import "mapBase.h"

enum eObjectmapIndex {
	cObjectmapXIndex		=0,
	cObjectmapYIndex		=1,
	
	cSplineTypePopUp=50,
	cDrawPointsButton	=100,
	
	cLinearSpline			=0,
	cQuadraticSpline	=1,
	cCubicSpline			=2,
	cBezierSpline			=3,

	cObjectEditorApplyScale 	=110,
	cObjectEditorApplyRotate	=120,
	cObjectEditorMoveUp			=130,
	cObjectEditorMoveRight		=140,
	cObjectEditorMoveDown		=150,
	cObjectEditorMoveLeft		=160,
	cObjectAllPoints	=0,
	cObjectSelectedPoints=1
};



@interface objectmap : MapBase <NSCoding> 
{
	NSControlStateValue mSlopeOn;
	NSControlStateValue mPointOn;
	NSControlStateValue mRasterOn;
	NSControlStateValue mCurveOn;
	NSControlStateValue mSplineTypePopUp;
	int mTemplateType;
}

+(instancetype) standardMap:(int) type withView:(id)view;
@property (nonatomic) int templateType;
-(void) setTemplateType:(int)type;
-(int) templateType;

-(void) makeMapWithPoints:(int)numberOfPoints;

-(void)	buildPolygonmap:(int)numberOfPoints;
-(void)	buildSormap:(int)numberOfPoints;
-(void)	buildLathemap:(int)numberOfPoints;
-(void)	buildPrismmap:(int)numberOfPoints;

-(void) addEntry;
-(void) insertEntryAtIndex:(NSInteger)index;

-(void) setButtonState:(NSControlStateValue) state forButton:(NSInteger)button;
-(NSControlStateValue) buttonState:(NSInteger)button;

@end


