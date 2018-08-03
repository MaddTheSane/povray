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




@interface MPColorWell: NSColorWell <NSCoding>
{
	CGFloat mFilter;
	CGFloat mTransmit;
	NSControlStateValue mFilterOnState;
	NSControlStateValue mTransmitOnState;
	BOOL mHasFilterTransmit;
	NSControlStateValue mGrayOn;
}
-(BOOL) equals:(id)com;
+(instancetype) withColor:(NSColor*) color andFilter:(BOOL)filter;
+(instancetype) whiteColorAndFilter:(BOOL)filter;
+(instancetype) blackColorAndFilter:(BOOL)filter;
+(instancetype) redColorAndFilter:(BOOL)filter;
+(instancetype) blueColorAndFilter:(BOOL)filter;
+(instancetype) cyanColorAndFilter:(BOOL)filter;
+(instancetype) magentaColorAndFilter:(BOOL)filter;
+(instancetype) yellowColorAndFilter:(BOOL)filter;
+(instancetype) greenColorAndFilter:(BOOL)filter;
+(instancetype) grayColorAndFilter:(BOOL)filter;
+(instancetype) lightGrayColorAndFilter:(BOOL)filter;
+ (instancetype)colorWithCalibratedRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha filter:(BOOL)filter;
-(void) clearFilterTransmit;


@property BOOL hasFilterTransmit;

@property (readonly) CGFloat filter;
@property (readonly) CGFloat transmit;
@property (readonly) NSControlStateValue transmitOn;
@property (readonly) NSControlStateValue filterOn;
@property NSControlStateValue grayOn;

-(void) setFilter:(CGFloat)filter toState:(NSControlStateValue)filterOn andTransmit:(CGFloat)transmit toState:(NSControlStateValue)transmitOn ;


@end


@interface MPFTColorWell: MPColorWell <NSCoding>
{
}
+(instancetype) withColor:(NSColor*) color andFilter:(BOOL)filter;
@property BOOL hasFilterTransmit;

@end


