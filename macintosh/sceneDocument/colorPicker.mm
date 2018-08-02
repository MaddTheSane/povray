//******************************************************************************
///
/// @file /macintosh/sceneDocument/colorPicker.mm
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

#import "colorPicker.h"
#import "customColorwell.h"
#import "standardMethods.h"

// this must be the last file included
#import "syspovdebug.h"
												
@implementation ColorPicker


//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[super dealloc];
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	if ( mDelegate)
	{
		[mColorWell setColor:[mDelegate color]];

		NSColor *cl=[[mDelegate color] colorUsingColorSpaceName:NSDeviceRGBColorSpace];

		[mRedColorEdit setFloatValue:[cl redComponent]];
		[mGreenColorEdit setFloatValue:[cl greenComponent]];
		[mBlueColorEdit setFloatValue:[cl blueComponent]];
		mGrayOnState=[mDelegate grayOn];
		[mGrayOn setState:mGrayOnState];
		if ([mDelegate hasFilterTransmit]==NO)
			[mFilterTransmitView setHidden:YES];
		else
		{
			[mFilterTransmitView setHidden:NO];

			mFilterOnState=[mDelegate filterOn];
			[mFilterOn setState:mFilterOnState];
			mFilter=[mDelegate filter];
			[mFilterEdit setFloatValue:mFilter];

			mTransmitOnState=[mDelegate transmitOn];
			mTransmit=[mDelegate transmit];
			[mFTransmitOn setState:mTransmitOnState];
			[mTransmitEdit setFloatValue:mTransmit];
		}
	}		
	[self colorPickerTraget:self];

}
	
//---------------------------------------------------------------------
// initWithDelegate
//---------------------------------------------------------------------

-(id) initWithDelegate:(id) delegate 
{

	self=[super init];
	if ( self)
	{
		mDelegate=delegate;
	}
	
	return self;
}

//---------------------------------------------------------------------
// okButton
//---------------------------------------------------------------------
-(IBAction) okButton:(id)sender
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	[mColorWell deactivate];
	mFilterOnState=[mFilterOn state];
	mTransmitOnState=[mFTransmitOn state];
	mFilter=[mFilterEdit floatValue];
	mTransmit=[mTransmitEdit floatValue];
	if ( mDelegate != nil)
	{
		[mDelegate setColor:[mColorWell color]];
		[mDelegate setGrayOn:mGrayOnState];
		if ([mDelegate hasFilterTransmit]==YES)
			[mDelegate setFilter:mFilter toState:mFilterOnState andTransmit:mTransmit toState:mTransmitOnState];
	}
	[[NSApplication sharedApplication] endSheet: window returnCode:NSOKButton];
}

//---------------------------------------------------------------------
// cancelButton
//---------------------------------------------------------------------
-(IBAction) cancelButton: (id)sender
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	[mColorWell deactivate];
	[[NSApplication sharedApplication] endSheet: window returnCode:NSCancelButton];
}

//---------------------------------------------------------------------
// getWindow
//---------------------------------------------------------------------
-(NSPanel*) getWindow
{
	return window;
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	return;
	// this doesn't work right now,
	// formatter keeps formatting
	// will look for a way to change color on the fly
	int tag=[[aNotification object]tag];
	switch (tag)
	{
		case cRedEdit:	//image with
		case cBlueEdit:
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mRedColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mBlueColorEdit floatValue]	
																		alpha:1.0]];
		break;
		case cGreenEdit:
			if( [mGrayOn state]==NSOnState)
			{
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mGreenColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mGreenColorEdit floatValue]	
																		alpha:1.0]];
			}
			else
			{
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mRedColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mBlueColorEdit floatValue]	
																		alpha:1.0]];
	}	
	}															

}
//---------------------------------------------------------------------
// getWindow
//---------------------------------------------------------------------
-(IBAction) colorPickerTraget:(id)sender
{
	int theTag;
	if ( sender==self)
		theTag=cFilterOn;
	else
		theTag=[sender tag];
	switch (theTag)
	{
		case cRedEdit:	//image with
		case cBlueEdit:
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mRedColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mBlueColorEdit floatValue]	
																		alpha:1.0]];
		break;
		case cGreenEdit:
			if( [mGrayOn state]==NSOnState)
			{
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mGreenColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mGreenColorEdit floatValue]	
																		alpha:1.0]];
			}
			else
			{
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[mRedColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																	blue:[mBlueColorEdit floatValue]	
																		alpha:1.0]];
	}	
	
		case cFilterOn:
			enableObjectsAccordingToObject(mFilterOn, mFilterEdit,nil);
			if( sender != self)
				break;
		case cTransmitOn:
			enableObjectsAccordingToObject(mFTransmitOn, mTransmitEdit,nil);
			if( sender != self)
				break;
		case cColorPicker:
    		if ( sender != self)
    		{
		  		NSColor *forcedRBGColor;
			    forcedRBGColor=[[mColorWell color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
				if( [mGrayOn state]==NSOnState)
				{
				[mColorWell setColor:[NSColor colorWithCalibratedRed:[forcedRBGColor greenComponent]	
																green:[forcedRBGColor greenComponent]
																	blue:[forcedRBGColor greenComponent]	
																		alpha:1.0]];			 		
			 		[mGreenColorEdit setFloatValue:[forcedRBGColor greenComponent]];
				}
				else
				{
					[mRedColorEdit setFloatValue:[forcedRBGColor redComponent]];
			 		[mGreenColorEdit setFloatValue:[forcedRBGColor greenComponent]];
			   		[mBlueColorEdit setFloatValue:[forcedRBGColor blueComponent]];
				}

			}		
			if( sender != self)
				break;
		case cGrayButton:
			if( sender != self)
				mGrayOnState=[mGrayOn state];
			if( mGrayOnState==NSOnState)
			{
				[mRedColorEdit setEnabled:NO];
				[mBlueColorEdit setEnabled:NO];
				if( sender != self)
				{
					[mColorWell setColor:[NSColor colorWithCalibratedRed:[mGreenColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																blue:[mGreenColorEdit floatValue]	
																alpha:1.0]];
				}
			}
			else
			{
				[mRedColorEdit setEnabled:YES];
				[mBlueColorEdit setEnabled:YES];
				if( sender != self)
				{
					[mColorWell setColor:[NSColor colorWithCalibratedRed:[mRedColorEdit floatValue]	
																green:[mGreenColorEdit floatValue]	
																blue:[mBlueColorEdit floatValue]	
																	alpha:1.0]];
			}
		}																
		if( sender != self)
			break;
	}
}
@end
