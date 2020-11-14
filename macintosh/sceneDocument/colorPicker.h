//******************************************************************************
///
/// @file /macintosh/sceneDocument/colorPicker.h
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

NS_ENUM(NSInteger) {
	cRedEdit = 1,
	cGreenEdit=2,
	cBlueEdit=3,
	cFilterOn=4,
	cTransmitOn=5,
	cColorPicker=6,
	cGrayButton=7
};
#if 0
}
#endif

@interface ColorPicker : NSObject
{
	IBOutlet NSColorWell	*mColorWell;
	IBOutlet NSTextField	*mRedColorEdit;
	IBOutlet NSTextField	*mGreenColorEdit;
	IBOutlet NSTextField	*mBlueColorEdit;
	IBOutlet NSButton		*mFilterOn;
	IBOutlet NSTextField	*mFilterEdit;
	IBOutlet NSButton		*mFTransmitOn;
	IBOutlet NSTextField	*mTransmitEdit;
	IBOutlet NSView			*mFilterTransmitView;
	IBOutlet NSButton		*mGrayOn;
	
	id mDelegate;
	IBOutlet NSPanel *window;
	CGFloat mFilter,mTransmit;	
	NSControlStateValue mFilterOnState;
	NSControlStateValue mTransmitOnState;
	NSControlStateValue mGrayOnState;
}
-(id) initWithDelegate:(id) delegate ;
-(IBAction) cancelButton: (id)sender;
-(IBAction) okButton:(id)sender;
-(IBAction) colorPickerTraget:(id)sender;
-(NSPanel*) getWindow;
@end
