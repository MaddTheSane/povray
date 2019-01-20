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

typedef NS_ENUM(NSInteger, eColormapButtonsTags) {
	cFilterButton			= 10,
	cTransmitButton		=20,
	cGrayColorButton	=30
};
enum {
	cColormapLocationIndex=0,
	cColormapColorIndex=1,
	cColormapFilterIndex=2,
	cColormapTransmitIndex=3
	};

@interface colormap : MapBase <NSCoding>
{
	NSControlStateValue	mUseGrayColorOn;
	NSControlStateValue	mFilterOn;
	NSControlStateValue	mTransmitOn;
	
}
+(instancetype) standardMapWithView:(id)view;
+(instancetype) rainbowMapWithView:(id)view;
+(instancetype) blackAndWhiteMapWithView:(id)view;

-(void) makeDefaultMap;
-(void) makeRainbowMap;
-(void) makeBlackAndWhiteMap;

-(void)replaceEntryAtIndex:(NSUInteger) index withObject:(NSColor *) color;
-(void) addEntry;
-(void) insertEntryAtIndex:(NSInteger)index;


-(void) setButtonState:(NSControlStateValue) state forButton:(eColormapButtonsTags)button;
-(NSControlStateValue) buttonState:(eColormapButtonsTags)button;


-(NSString *) redAtIndex:(NSUInteger) index;
-(NSString *) greenAtIndex:(NSUInteger) index;
-(NSString *) blueAtIndex:(NSUInteger) index;

-(void) setRed:(NSString *)red atIndex:(NSUInteger) index;
-(void) setGreen:(NSString *)green atIndex:(NSUInteger) index;
-(void) setBlue:(NSString *)blue atIndex:(NSUInteger) index;

@end

@interface ColorCell : NSActionCell 
{
	BOOL mUseGrayScale;
}
@property BOOL isGrayScale;

@end
