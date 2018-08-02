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

enum eColormapButtonsTags {
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

@interface colormap : MapBase <NSCoding> 
{
	int 				mUseGrayColorOn;
	int 				mFilterOn;
	int 				mTransmitOn;
	
}
+(id) standardMapWithView:(id)view;
+(id) rainbowMapWithView:(id)view;
+(id) blackAndWhiteMapWithView:(id)view;

-(void) makeDefaultMap;
-(void) makeRainbowMap;
-(void) makeBlackAndWhiteMap;

-(void)replaceEntryAtIndex:(unsigned int) index withObject:(NSColor *) color;
-(void) addEntry;
-(void) insertEntryAtIndex:(int)index;


-(void) setButtonState:(int) state forButton:(int)button;
-(int) buttonState:(int)button;


-(NSString *) redAtIndex:(unsigned int) index;
-(NSString *) greenAtIndex:(unsigned int) index;
-(NSString *) blueAtIndex:(unsigned int) index;

-(void) setRed:(NSString *)red atIndex:(unsigned int) index;
-(void) setGreen:(NSString *)green atIndex:(unsigned int) index;
-(void) setBlue:(NSString *)blue atIndex:(unsigned int) index;

@end

@interface ColorCell : NSActionCell 
{
	BOOL mUseGrayScale;
}
-(BOOL) isGrayScale;
-(void) setIsGrayScale:(BOOL) is;

@end