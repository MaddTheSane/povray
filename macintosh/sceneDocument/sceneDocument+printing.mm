//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument+printing.mm
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

#import "sceneDocument+printing.h"

// this must be the last file included
#import "syspovdebug.h"


@implementation SceneDocument (printing)


//---------------------------------------------------------------------
// printDocumentWithSettings 
//---------------------------------------------------------------------
- (void) printDocumentWithSettings: (NSDictionary*) printSettings  showPrintPanel: (BOOL) show delegate: (id) delegate
            didPrintSelector: (SEL) didPrint  contextInfo: (void *) contextInfo
{
	NSPrintInfo *prnInfo;
	NSPrintOperation *printOp;
	
	/*	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		id dict=[self  unarchiveForKey:@"scenefilePrinterInfoDict"];
		if( dict != nil)
		{
			prnInfo=[[[NSPrintInfo alloc]initWithDictionary:dict]autorelease];
		}
		else
		{*/
			prnInfo=[self printInfo];
			[prnInfo setLeftMargin:20];
			[prnInfo setTopMargin: 20];
			[prnInfo setBottomMargin:20];
			[prnInfo setRightMargin:20];
			[prnInfo setVerticallyCentered:NO];
			[prnInfo setHorizontallyCentered:NO];
//		}
			printOp = [NSPrintOperation printOperationWithView: mSceneTextView printInfo:prnInfo];
			[printOp runOperation];
/*			NSMutableDictionary *md=[[[[printOp printInfo]dictionary]copy]autorelease];
		[self archive:md withKey:@"scenefilePrinterInfoDict"];*/
}
- (BOOL)archive:(NSDictionary *)dict withKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = nil;
    if (dict) {
        data = [NSKeyedArchiver archivedDataWithRootObject:dict];
    }
    [defaults setObject:data forKey:key];
    return [defaults synchronize];
}

- (NSDictionary *)unarchiveForKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:key];
    NSDictionary *userDict = nil;
    if (data) {
        userDict = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return userDict;
}
@end
