//******************************************************************************
///
/// @file /macintosh/sceneDocument/customDocumentController.mm
///
/// to make save/open menu's work when a template dialog is on top
/// of a scene window
///
/// @copyright
/// @parblock
///
/// Unofficial Macintosh GUI port of POV-Ray 3.7
/// Copyright 2002-2016 Yvo Smellenbergh
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
/// Tracer ('POV-Ray') version 3.7, Copyright 1991-2016 Persistence of Vision
/// Raytracer Pty. Ltd.
///
/// ----------------------------------------------------------------------------
///
/// POV-Ray is based on the popular DKB raytracer version 2.12.
/// DKBTrace was originally written by David K. Buck.
/// DKBTrace Ver 2.0-2.12 were written by David K. Buck & Aaron A. Collins.
///
/// @endparblock
///
//******************************************************************************

#import "CustomDocumentController.h"
#import "BaseTemplate.h"
#import "SceneDocument.h"
#import "GlobalsTemplate.h"
#import "MaterialTemplate.h"
#import "maincontroller.h"
static CustomDocumentController* _customDocumentController;

@implementation CustomDocumentController
//---------------------------------------------------------------------
// sharedInstance
//---------------------------------------------------------------------
+ (CustomDocumentController*)sharedInstance
{
	if ( _customDocumentController ==nil)
		[[self alloc]init];
	 return _customDocumentController;
}

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
-(id) init
{
	self=_customDocumentController=[super init];
	return self;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
- (void) dealloc
{
	[_customDocumentController release];
	_customDocumentController=nil;
	[super dealloc];
}

//---------------------------------------------------------------------
// openDocument
//---------------------------------------------------------------------
// make sure that when a template is on top 
// it saves it
//---------------------------------------------------------------------
-(void) openDocument:(id)sender
{
	if ( [self topDocumentIsBaseTemplate] == YES)
	{
		//mCurrentTopDocument is set in topDocumentIsBaseTamplate
		[mCurrentTopDocument openButton:sender];
		return;
	}
	[super openDocument:sender];
}

//---------------------------------------------------------------------
// saveDocument
//---------------------------------------------------------------------
-(void) saveDocument:(id)sender
{
	if ( [self topDocumentIsBaseTemplate] == YES)
	{
		//mCurrentTopDocument is set in topDocumentIsBaseTamplate
		[mCurrentTopDocument saveButton:sender];
		return;
	}
}

//---------------------------------------------------------------------
// topDocument
//---------------------------------------------------------------------
-(id) topDocument
{
	id doc=[self currentDocument];
	if ( doc !=nil)
	{
		if ( [doc isKindOfClass:[SceneDocument class]] == YES)
		{
			id owner=[doc fileOwner];
			while (owner != nil && [owner fileOwner] != nil)
				owner=[owner fileOwner];
			if ( owner != nil)
			{
				if ( [owner isKindOfClass:[BaseTemplate class]] == YES)
				{
					mCurrentTopDocument=owner;
					return owner;
				}
			}
		}
	}
	return nil;
}

//---------------------------------------------------------------------
// topDocumentIsBaseTemplate
//---------------------------------------------------------------------
-(BOOL) topDocumentIsBaseTemplate
{
	id doc=[self currentDocument];
	if ( doc !=nil)
	{
		if ( [doc isKindOfClass:[SceneDocument class]] == YES)
		{
			id owner=[doc fileOwner];
			while (owner != nil && [owner fileOwner] != nil)
				owner=[owner fileOwner];
			if ( owner != nil)
			{
				if ( [owner isKindOfClass:[BaseTemplate class]] == YES)
				{
					mCurrentTopDocument=owner;
					return YES;
				}
			}
		}
	}
	mCurrentTopDocument=nil;
	return NO;
}

//---------------------------------------------------------------------
// validateMenuItem
//---------------------------------------------------------------------
//- (BOOL)validateMenuItem:(id <NSMenuItem >)aMenuItem
- (BOOL)validateMenuItem:(NSMenuItem*)aMenuItem
{
	SEL action = [aMenuItem action];
	if (action == @selector(importTarget:) || action == @selector(exportTarget:))
	{
		if ( [self topDocumentIsBaseTemplate]==YES)
		{
			if ( [mCurrentTopDocument isMemberOfClass:[GlobalsTemplate class]]==YES || [mCurrentTopDocument isMemberOfClass:[MaterialTemplate class]]==YES)
			{
				NSString *newTitle=nil;
				if ([aMenuItem tag]==eTag_Import)
				{
					newTitle=[mCurrentTopDocument currentImportExportTitle:YES];
				}
				else
				{
					newTitle=[mCurrentTopDocument currentImportExportTitle:NO];
				}
				if (newTitle != nil)
					[aMenuItem setTitle:newTitle];
				return YES;
			}
			else
			{
				if ([aMenuItem tag]==eTag_Import)
					[aMenuItem setTitle:NSLocalizedStringFromTable(@"importMenuItem", @"applicationLocalized", @"")];
				else
					[aMenuItem setTitle:NSLocalizedStringFromTable(@"exportMenuItem", @"applicationLocalized", @"")];
				return NO;
			}
		}
	}
	return [super validateMenuItem:aMenuItem];
}


//---------------------------------------------------------------------
// importTarget
//---------------------------------------------------------------------
-(IBAction) importTarget:(id) sender
{
	if ( [self topDocumentIsBaseTemplate]==YES)
	{
		if ( [mCurrentTopDocument isMemberOfClass:[GlobalsTemplate class]]==YES || [mCurrentTopDocument isMemberOfClass:[MaterialTemplate class]]==YES)
			[mCurrentTopDocument importSettings];
	}
}

//---------------------------------------------------------------------
// exportTarget
//---------------------------------------------------------------------
-(IBAction) exportTarget:(id) sender
{
	if ( [self topDocumentIsBaseTemplate]==YES)
	{
		if ( [mCurrentTopDocument isMemberOfClass:[GlobalsTemplate class]]==YES || [mCurrentTopDocument isMemberOfClass:[MaterialTemplate class]]==YES)
			[mCurrentTopDocument exportSettings];
	}

}

@end