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

@interface MutableTabString: NSObject
{
	NSInteger mTabCount;
	NSMutableString *mTabString;
	NSMutableString *mString;
	BOOL mCallerIsSceneDocument;	// YES is the object asking to write is a scenedocument
	BOOL mFirstTimeWritten;			// have we written something already?
}
-(instancetype) initWithTabs:(NSInteger)tabs andCallerType:(BOOL) callerIsSceneDocument;
-(void) removeTab;
-(void) addTab;
@property (readonly) NSInteger currentTabs;

@property (retain) NSMutableString *string;
@property (retain) NSMutableString *tabString;
@property (readonly) NSUInteger length;

-(void) copyTabAndText:(NSString*)string;
-(void) copyText:(NSString *) string;
-(void) copyTabText;
-(void) addXYZVector:(NSDictionary*)dict popup:(NSString*)popup xKey:(NSString*)x yKey:(NSString*)y zKey:(NSString*)z;
-(void) addScaleVector:(NSDictionary*)dict popup:(NSString*)popup xKey:(NSString*)x yKey:(NSString*)y zKey:(NSString*)z;
-(void) addRGBColor:(NSDictionary*)dict forKey:(NSString*)key andTitle:(NSString*) title comma:(BOOL)cm newLine:(BOOL)nl;
-(void)appendFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
-(void)appendFormat:(NSString *)format arguments:(va_list)args NS_FORMAT_FUNCTION(1,0);
-(void) appendTabAndFormat:(NSString*)format,... NS_FORMAT_FUNCTION(1,2);
-(void)appendTabAndFormat:(NSString *)format arguments:(va_list)args NS_FORMAT_FUNCTION(1,0);

@end

