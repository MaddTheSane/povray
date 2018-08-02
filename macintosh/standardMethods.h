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
#include <CoreServices/CoreServices.h>
#include <Carbon/Carbon.h>

#import <Cocoa/Cocoa.h>
#define FloatFormat @"%.5f"
void SetSubViewsOfNSTabViewToState( NSTabView *tabv, NSInteger newState);
void SetSubViewsOfNSViewToState( NSView *view, NSInteger newState);

void SetSubViewsOfNSBoxToState( NSBox *group, NSInteger newState);
void SetTabViewToNSPopupButton( NSPopUpButton *button, NSTabView* tabView);
void enableObjectsAccordingToObject( id referenceObject, ...);
void disableItemsFromIndex(NSPopUpButton *popup, NSInteger index);
NSMutableArray * scanForValuesInString(NSString *stringToScan);

//OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend);

//---------------------------------------------------------------------
// remoteObject
//---------------------------------------------------------------------
//	An object to hold some variables to be used with a performSelectorOnMainThread
//	method.
//---------------------------------------------------------------------
@interface remoteObject : NSObject
{
    // variables needed for the image cache method
    NSMutableDictionary *mDict;
 	NSInteger mWidth;
 	NSInteger mHeight;
 	NSInteger mRef;
 	BOOL mReturnValue;
} 
	- (id) initWithObjectsAndKeys:(id) firstObject, ...;
	-(id) initWithWidth: (NSInteger)width andHeight: (NSInteger)height andRef: (NSInteger)ref;
	-(id) initWithRef: (NSInteger)ref;
	-(NSMutableDictionary*) dict;
	-(NSInteger) width;
	-(NSInteger)height;
	-(NSInteger) ref;
	-(BOOL)returnValue;
	-(void)setReturnValue: (BOOL) returnValue;
@end 
