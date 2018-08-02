//******************************************************************************
///
/// @file /macintosh/batchMap.h
///
/// batchmap can hold various scenefiles for rendering one after the other
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
#import "MapBase.h"


#define BatchItemDragType @"BatchRenderDragType"

enum {
	cOnOffIndex			=0,
	cSettingsIndex	=1,
	cNameIndex			=2,
	cStatusIndex		=3,
	cCommentIndex		=4
};

typedef NS_ENUM(NSInteger, eBatchStatus) {
	cBatchError		=1,
	cCancelled		=3,
	cDone					=5,
	cProcessing		=10,
	cQueue 				=15,
	cRenderError	=20,
	cRendering		=25,
	cUnknown			=30,
	cUserAbort		=35
};
	
typedef NS_ENUM(NSInteger, eBatchButtonsTags) {
	cRunButton			=1,
	cRunAllButton		=2,
	cAbortButton 		=3,
	cAddbutton			=4,
	cInsertButton		=5,
	cTrashButton		=6,
	cSettingsPopup	=7,
	cResetButton		=8,
	cResetAllButton	=9,
	cSkipButton			=10
};

@interface BatchMap : MapBase
-(void) addEntry:(NSString *)file;
-(void) insertEntryAtIndex:(NSInteger)index file:(NSString*)file;
-(BOOL) entryExists:(NSString *)file;

@end
@interface BatchTableView : NSTableView
@end
