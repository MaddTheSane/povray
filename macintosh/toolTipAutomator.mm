//******************************************************************************
///
/// @file /macintosh/toolTipAutomator.mm
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
#import "toolTipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"
@implementation ToolTipAutomator

+(void) setTooltips:(NSString*)nibFile andDictionary:(NSDictionary<NSString*,id> *) dictionayWithOutlets
{
	NSString *key=nil;
	NSString *tagString=nil;
	NSBundle *main=[NSBundle mainBundle];
	if ( main == nil)
		return;
	

	NSEnumerator<NSString*> *en = [dictionayWithOutlets keyEnumerator];
	for ( key in en )
	{
		id object=[dictionayWithOutlets objectForKey:key];
		
		if ( [object isKindOfClass:[NSArray class]])	// used for cells inmatrix
		{
			NSMatrix *mtx=[object objectAtIndex:0];
			NSUInteger number=([object count]-1)/2;
			for (int x=1, idx=1; x<=number; x++,idx+=2)
			{
				tagString=[main localizedStringForKey:[object objectAtIndex:idx] value:@"_t_" table:nibFile];
				if ( [tagString isEqualToString:@"_t_"] ==NO)
				{
					[mtx setToolTip:tagString forCell:[object objectAtIndex:idx+1]];
				}
			}
		}
		else
		{
			tagString=[main localizedStringForKey:key value:@"_t_" table:nibFile];
			if ( [tagString isEqualToString:@"_t_"] ==NO)
			{
				if ([object respondsToSelector:@selector(setToolTip:)])
				{
					[object setToolTip:tagString];
				}
			}
		}
	}
}
	
@end
