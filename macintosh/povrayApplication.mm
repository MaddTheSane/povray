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
#import "MainController.h"

#import "povrayApplication.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation PovRayApplication

- (void)sendEvent:(NSEvent *)anEvent
{
	if ( numericBlockPoint != 0 && [anEvent type]==NSKeyDown && [anEvent keyCode]==65)	
	{
		NSString *newString;

		if ( numericBlockPoint == 1)	//comma
			newString=@",";
		else 
			newString=@".";
		
		NSEvent *newEvent=[NSEvent keyEventWithType:[anEvent type]
	
			location:[anEvent locationInWindow]
			modifierFlags:[anEvent modifierFlags]
			timestamp:[anEvent timestamp]
			windowNumber:[anEvent windowNumber]
			context:[anEvent context]
			characters:[NSString stringWithString:newString]
			charactersIgnoringModifiers:[anEvent charactersIgnoringModifiers]
			isARepeat:[anEvent isARepeat]
			keyCode:[anEvent keyCode]
			];
			[super sendEvent:newEvent];
	}
	else
		[super sendEvent:anEvent];

}

//---------------------------------------------------------------------
// terminate
//---------------------------------------------------------------------
-(IBAction) terminate:(id) sender
{
	// store open documents and position
	NSDocumentController *ctrl=[NSDocumentController sharedDocumentController];
	if ( ctrl)
	{
		NSArray *documentsArray=[ctrl documents];
		NSEnumerator *en=[documentsArray objectEnumerator];
		id doc;
		NSMutableArray *dict=[[[NSMutableArray alloc]init]autorelease];
		for ( doc in en )
		{
			if ( [doc fileName]!=nil && [doc isDocumentEdited]==NO)
			{
				NSWindow *win=[doc window];
				NSString *winRect=[win stringWithSavedFrame];
				NSString *winPath=[doc fileName];
				NSString *range=NSStringFromRange([[doc getSceneTextView] selectedRange]);
				NSArray *ar=[NSArray arrayWithObjects: winRect, winPath,range, nil];

				[dict addObject:ar];
			}
		}
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		[defaults  setObject:dict forKey:@"OpenDocuments"];
	}
	[super terminate:sender];
} 

@end
