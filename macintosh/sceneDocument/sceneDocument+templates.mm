//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument+templates.mm
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
//********************************************************************************
#import "sceneDocument+templates.h"
#import "CameraTemplate.h"
#import "LightTemplate.h"
#import "FunctionTemplate.h"
#import "TransformationsTemplate.h"
#import "PigmentTemplate.h"
#import "ColormapTemplate.h"
#import "HeaderIncludeTemplate.h"
#import "GlobalsTemplate.h"
#import "FinishTemplate.h"
#import "MediaTemplate.h"
#import "BodymapTemplate.h"
#import "InteriorTemplate.h"
#import "NormalTemplate.h"
#import "SlopemapTemplate.h"
#import "ObjectTemplate.h"
#import "PhotonsTemplate.h"
#import "MaterialTemplate.h"
#import "BackgroundTemplate.h"
#import "ObjectEditorTemplate.h"
#import "MaterialmapTemplate.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation SceneDocument (templates)


//---------------------------------------------------------------------
// displayTemplate:owner:caller:dict
//---------------------------------------------------------------------
+(void) displayTemplateNumber:(NSInteger) tagNumber fileowner:(BaseTemplate*&) fileOwner caller:(id)caller dictionary:(NSMutableDictionary*) dict
{
	NSString *bundleName=nil;
	switch (tagNumber)
	{
		case menuTagTemplateCamera:
			fileOwner=[[CameraTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateCamera];
			bundleName=@"cameraTemplate.nib";
			break;
		case menuTagTemplateLight:
			fileOwner=[[LightTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateLight];
			bundleName=@"lightTemplate.nib";
			break;
		case menuTagTemplateObject:
			fileOwner=[[ObjectTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateObject];
			bundleName=@"objectTemplate.nib";
			break;
		case menuTagTemplateTransformations:
			fileOwner=[[TransformationsTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateTransformations];
			bundleName=@"transformationsTemplate.nib";
			break;
		case menuTagTemplateFunctions:
			fileOwner=[[FunctionTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateFunctions];
			bundleName=@"functionTemplate.nib";
			break;
		case menuTagTemplatePigment:
			fileOwner=[[PigmentTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplatePigment];
			bundleName=@"pigmentTemplate.nib";
			break;
		case menuTagTemplateFinish:
			fileOwner=[[FinishTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateFinish];
			bundleName=@"finishTemplate.nib";
			break;
		case menuTagTemplateNormal:
			fileOwner=[[NormalTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateNormal];
			bundleName=@"normalTemplate.nib";
			break;

		case menuTagTemplateInterior:
			fileOwner=[[InteriorTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateInterior];
			bundleName=@"interiorTemplate.nib";
			break;

		case menuTagTemplateMedia:
			fileOwner=[[MediaTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateMedia];
			bundleName=@"mediaTemplate.nib";
			break;
		case menuTagTemplatePhotons:
			fileOwner=[[PhotonsTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplatePhotons];
			bundleName=@"photonsTemplate.nib";
			break;
		case menuTagTemplateBackground:
			fileOwner=[[BackgroundTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateBackground];
			bundleName=@"backgroundTemplate.nib";
			break;

		case menuTagTemplateColormap:
			fileOwner=[[ColormapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateColormap];
			bundleName=@"colormapTemplate.nib";
			break;
			
		case menuTagTemplateDensitymap:
			fileOwner=[[BodymapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateDensitymap];
			bundleName=@"bodymapTemplate.nib";
			break;

		case menuTagTemplateNormalmap:
			fileOwner=[[BodymapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateNormalmap];
			bundleName=@"bodymapTemplate.nib";
			break;
		case menuTagTemplatePigmentmap:
			fileOwner=[[BodymapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplatePigmentmap];
			bundleName=@"bodymapTemplate.nib";
			break;

		case menuTagTemplateMaterialmap:
			fileOwner=[[MaterialmapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateMaterialmap];
			bundleName=@"materialmapTemplate.nib";
			break;

		case menuTagTemplateSlopemap:
			fileOwner=[[SlopemapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateSlopemap];
			bundleName=@"slopemapTemplate.nib";
			break;
			
			
		case menuTagTemplateTexturemap:
			fileOwner=[[BodymapTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateTexturemap];
			bundleName=@"bodymapTemplate.nib";
			break;
		case menuTagTemplateHeaderInclude:
			fileOwner=[[HeaderIncludeTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateHeaderInclude];
			bundleName=@"headerIncludeTemplate.nib";
			break;
		case menuTagTemplateGlobals:
			fileOwner=[[GlobalsTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateGlobals];
			bundleName=@"globalsTemplate.nib";
			break;
		case menuTagTemplateMaterial:
			fileOwner=[[MaterialTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateMaterial];
			bundleName=@"materialTemplate.nib";
			break;

//object
		case menuTagTemplateLathe:
			fileOwner=[[ObjectEditorTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateLathe];
			bundleName=@"objectEditor.nib";
			break;
		case menuTagTemplatePolygon:
			fileOwner=[[ObjectEditorTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplatePolygon];
			bundleName=@"objectEditor.nib";
			break;
		case menuTagTemplatePrism:
			fileOwner=[[ObjectEditorTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplatePrism];
			bundleName=@"objectEditor.nib";
			break;
		case menuTagTemplateSor:
			fileOwner=[[ObjectEditorTemplate alloc] initWithDocumentPointer:caller andDictionary:dict forType:menuTagTemplateSor];
			bundleName=@"objectEditor.nib";
			break;


	}
	if ( fileOwner != nil)
	{
		if ( [NSBundle loadNibNamed:bundleName owner:fileOwner] == YES)
		{
			[caller runTemplateSheet];
		}
		else
		{
			[fileOwner release];
			fileOwner=nil;
		}
	}
}

//---------------------------------------------------------------------
// runTemplateSheet
//---------------------------------------------------------------------
- (void) runTemplateSheet
{
	[[NSApplication sharedApplication] beginSheet:[mFileOwner getWindow] 
				modalForWindow:[self window] modalDelegate:self 
				didEndSelector:@selector(templateSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

//---------------------------------------------------------------------
// openTemplate
//---------------------------------------------------------------------
/*-(void)openTemplate:(id) sender
{
	static int templateTagToCall=[sender tag];
	if ( ([[self fileURL]path]==nil || [self fileType]==nil) && [self isDocumentEdited])
	{
			NSBeginAlertSheet( @"This is an Untitled document!", @"Save",@"Cancel",nil,
									[self window], self,
 			@selector(alertPanelDidEnd:returnCode:contextInfo:),
 			nil, 
 			&templateTagToCall,
 			@"You can not use templates on an untitled document.\nPlease save this document first!",
 			nil);

	}
	else
		[SceneDocument displayTemplateNumber:[sender tag] fileowner:mFileOwner caller:self dictionary:nil ];
} 
*/
//---------------------------------------------------------------------
// alertPanelDidEnd
//---------------------------------------------------------------------
/*- (void) alertPanelDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[sheet orderOut:nil];
	if ( returnCode ==NSAlertDefaultReturn)	//ok
	{
		[self saveDocumentWithDelegate:self didSaveSelector:@selector(untitledFileIsSaved:didSave:contextInfo:) contextInfo:contextInfo];
	}
	else if ( returnCode==NSAlertOtherReturn)	//cancel (dont save and don't close window
	{
	}
}
*/
//---------------------------------------------------------------------
// untitledFileIsSaved
//---------------------------------------------------------------------
/*-(void) untitledFileIsSaved:(NSDocument *)doc didSave:(BOOL)didSave contextInfo:(void*)contextInfo
{
	if ( didSave==YES)
	{
		[SceneDocument displayTemplateNumber:*(int*)contextInfo fileowner:mFileOwner caller:self dictionary:nil ];
	}
}
*/
//---------------------------------------------------------------------
// templateSheetDidEnd
//---------------------------------------------------------------------
-(void) templateSheetDidEnd: (NSWindow*)sheet returnCode: (NSModalResponse)returnCode contextInfo: (void*)contextInfo
{
	if ( returnCode ==NSOKButton)
	{
		NSDictionary *dict=[mFileOwner preferences];
		MutableTabString *ds=[[MutableTabString alloc] initWithTabs:[self findTabsCurrentLine] andCallerType:YES];
		[ds autorelease];
		[[mFileOwner class] createDescriptionWithDictionary:dict andTabs:[self findTabsCurrentLine] extraParam:0 mutableTabString:ds];
		if ( [mSceneTextView shouldChangeTextInRange:[mSceneTextView selectedRange] replacementString:[ds string]])
		{
			[mSceneTextView replaceCharactersInRange:[mSceneTextView selectedRange] withString:[ds string]];
			[mSceneTextView didChangeText];
		}
	}
//	[sheet orderOut: nil];
	[sheet close];	// will release it also
	[mFileOwner release];
	mFileOwner=nil;
}


//---------------------------------------------------------------------
// findTabsCurrentLine
//---------------------------------------------------------------------
-(int) findTabsCurrentLine
{
	
	int tabs=0;
	NSUInteger firstCharacter,lastCharacter;
	NSString *str=[mSceneTextView string];
	if ( [str length]==0)
		return 0;
		
	NSRange selection=[mSceneTextView selectedRange];
		
	selection.length=1;
	if( selection.location+selection.length > [str length])
	{
		if ( selection.location > 0)
			selection.location--;
		else
			return 0;
	}
	
	[str getLineStart:&firstCharacter end:NULL contentsEnd:&lastCharacter forRange:selection];
	for (int x=firstCharacter; x<lastCharacter; x++)
	{
		if ( [str characterAtIndex:x]=='\t')
			tabs++;
		else
			break;
	}
	return tabs;
}

@end
