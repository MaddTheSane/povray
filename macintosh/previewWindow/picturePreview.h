//******************************************************************************
///
/// @file /macintosh/previewWindow/picturePreview.h
///
/// preview window control
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
#import "picturePreviewBase.h"

	#define PvtbIdentifier									@"PvtbIdentifier"
	#define PvtbStopItemIdentifier					@"PvtbStopItemIdentifier"
	#define PvtbPauseContinueItemIdentifier	@"PvtbPauseContinue"
	#define PvtbCutItemIdentifier						@"PvtbCutItemIdentifier"

	#define dPvtbStopLabel NSLocalizedStringFromTable(@"PvtbStopLabel", @"previewWindowLocalized", @"")
	#define dPvtbStopLabelPaletteLabel NSLocalizedStringFromTable(@"PvtbStopLabel", @"previewWindowLocalized", @"")
	#define dPvtbStopLabelTooltipLabel NSLocalizedStringFromTable(@"PvtbStopTooltip", @"previewWindowLocalized", @"")

	#define dPvtbPauseLabel NSLocalizedStringFromTable(@"PvtbPauseLabel", @"previewWindowLocalized", @"")
	#define dPvtbContinueLabel NSLocalizedStringFromTable(@"PvtbContinueLabel", @"previewWindowLocalized", @"")
	#define dPvtbPauseContinuePaletteLabel NSLocalizedStringFromTable(@"PvtbPauseContinuePaletteLabel", @"previewWindowLocalized", @"")
	#define dPvtbContinueTooltip NSLocalizedStringFromTable(@"PvtbContinueTooltip", @"previewWindowLocalized", @"")
	#define dPvtbPauseTooltip NSLocalizedStringFromTable(@"PvtbPauseTooltip", @"previewWindowLocalized", @"")

	#define dPvtbCutLabel NSLocalizedStringFromTable(@"PvtbCutLabel", @"previewWindowLocalized", @"")
	#define dPvtbCutPaletteLabel NSLocalizedStringFromTable(@"PvtbCutPaletteLabel", @"previewWindowLocalized", @"")
	#define dPvtbCutTooltip NSLocalizedStringFromTable(@"PvtbCutTooltip", @"previewWindowLocalized", @"")

@interface pictureScrollView : NSScrollView
{


	IBOutlet id subView;
}
@end

@interface picturePreview : picturePreviewBase 
{
	// variables needed for the image cache method
	IBOutlet pictureScrollView *scrollView;
	BOOL mHasSelectionRect;
	BOOL mCanCut;
	// scaledSelectionRect holds the format in image pixels as set in the prefs panel
	NSRect mSelectionRectInPixelFormat;
	// unscaled holds the format in view pixels scaled with the backingscalefactor
	NSRect mSelectionRectInViewFormat;
 	NSInteger mCutItemState;
	NSInteger mStopItemState;
	NSInteger mPauseItemState;

	NSToolbarItem *mCutToolbarItem;
	NSToolbarItem *mStopToolbarItem;
	NSToolbarItem *mPauseToolbarItem;
}
-(void) resetCutButton;
-(void) showWindow:(id) sender shouldBecomeFront: (bool) makeFront;

-(IBAction) stopButton:(id) sender;
-(IBAction) pauseButton:(id) sender;
-(IBAction) cutButton:(id) sender;
- (void)mouseDown:(NSEvent *)theEvent;
-(void) newSelectionInPreferencesPanelSet:(NSNotification *) notification;
-(void) renderState:(NSNotification *) notification;
-(void) pauseStatusChanged:(NSNotification *) notification;


@end
