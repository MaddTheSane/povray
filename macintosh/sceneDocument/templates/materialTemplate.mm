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
#import "materialTemplate.h"
#import "transformationsTemplate.h"
#import "standardMethods.h"
#import "sceneDocument+templates.h"
#import "appPreferencesController.h"
#import "maincontroller.h"

// this must be the last file included
#import "syspovdebug.h"


static BOOL mSkySphereWritten;

@implementation MaterialTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) WritingPattern mutableTabString:(MutableTabString*) ds
{
	mSkySphereWritten=NO;
	if ( dict== nil)
		dict=[MaterialTemplate createDefaults:menuTagTemplateMaterial];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[MaterialTemplate class] andTemplateType:menuTagTemplateMaterial];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	materialEditorMap *cmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"materialEditorMap"]];
	
	if ( [[dict objectForKey:@"materialDontWrapInMaterial"]intValue]==NSOffState)
	{
		[ds copyTabAndText:@"material {\n"];
		[ds addTab];
	}

	for ( int x=1; x<=[cmap count]; x++)
	{
		int index=x-1;
		if ( [cmap count] > 1)
			[ds appendTabAndFormat:@"//Layer: %@\n",[cmap objectAtRow:index atColumn:cMaterialmapLayerNameIndex]];
		[MaterialTemplate addLayer:ds atIndex:index fromMap:cmap];
		
	}
	if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
	{
		[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
				andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
	}

	if ( [[dict objectForKey:@"materialDontWrapInMaterial"]intValue]==NSOffState)
	{
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}

	
//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// addLayer:fromMap
//---------------------------------------------------------------------
+(void) addLayer:(MutableTabString*) ds atIndex:(int)index fromMap:(id)cmap
{

	if ( [cmap intAtRow:index atColumn:cMaterialmapOnOffIndex]==NSOnState)
	{
		[ds copyTabAndText:@"texture {\n"];
		[ds addTab];
		if ( [cmap intAtRow:index atColumn:cMaterialmapPigmentOnIndex]==NSOnState )
		{
			WritePigment(cForceWrite, ds,	[cmap objectAtRow:index atColumn:cMaterialmapPigmentDictIndex],NO);
		}

		if ( [cmap intAtRow:index atColumn:cMaterialmapNormalOnIndex]==NSOnState )
		{
			WriteNormal(cForceWrite, ds,	[cmap objectAtRow:index atColumn:cMaterialmapNormalDictIndex],NO);
		}
		if ( [cmap intAtRow:index atColumn:cMaterialmapFinishOnIndex]==NSOnState )
		{
			[FinishTemplate createDescriptionWithDictionary:[cmap objectAtRow:index atColumn:cMaterialmapFinishDictIndex] 
			andTabs:[ds currentTabs]extraParam:menuTagTemplateFinish mutableTabString:ds];
		}

		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
		if ( [cmap intAtRow:index atColumn:cMaterialmapInteriorOnIndex]==NSOnState )
		{
			[InteriorTemplate createDescriptionWithDictionary:[cmap objectAtRow:index atColumn:cMaterialmapInteriorDictIndex] 
			andTabs:[ds currentTabs]extraParam:menuTagTemplateInterior mutableTabString:ds];
		}
		
	}
}

//---------------------------------------------------------------------
// previewMaterial:selectedLayerOnly
//---------------------------------------------------------------------
-(void) previewMaterial:(BOOL) selectedLayerOnly
{
	mSkySphereWritten=NO;
	[self retrivePreferences];
	NSDictionary *dict=[self preferences];
	NSUInteger beginLayer=0;
	NSUInteger endLayer=0;
	
	if ( selectedLayerOnly==YES)
	{
		beginLayer=[mMap selectedRow];
		endLayer=beginLayer;
	}
	else
	{
		beginLayer=0;
		endLayer=[mMap count]-1;
	}
	
	if ( dict== nil)
		return;
		
	MutableTabString *ds=[[[MutableTabString alloc] initWithTabs:0 andCallerType:NO]autorelease];
	materialEditorMap *cmap=[NSUnarchiver unarchiveObjectWithData:[dict objectForKey:@"materialEditorMap"]];
	[ds copyTabAndText:@"#version 3.7;"];
	[ds copyTabAndText:@"global_settings {assumed_gamma 1.0}"];
	[MaterialTemplate addCameraToString:ds withDict:dict];
	[MaterialTemplate addLightToString:ds withDict:dict];
	[MaterialTemplate addBackgroundToString:ds withDict:dict];
	[MaterialTemplate addReflectionToString:ds withDict:dict];

	switch( [[dict objectForKey:@"materialObjectPopUp"]intValue])
	{
		case cObjectBox_0505:
			[ds copyTabAndText:@"box {<-0.5, -0.5, 0.0>, <0.5, 0.5, 0.2>\n"];
			[ds addTab];
			[ds copyTabAndText:@"material {\n"];
			[ds addTab];
			for (int x=beginLayer; x<=endLayer; x++)
				[MaterialTemplate addLayer:ds atIndex:x fromMap:cmap];
			[ds removeTab];
			if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			[ds copyTabAndText:@"}\n"];
			[ds copyTabAndText:@"hollow\n"];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;
		case cObjectUnion:
			[ds copyTabAndText:@"union {\n"];
			[ds addTab];
			[ds copyTabAndText:@"box {<-0.5, -0.5, -0.1>, <0.5, 0.5, 0.1>}\n"];
			[ds copyTabAndText:@"sphere {	0.0, 0.35}\n"];
			[ds copyTabAndText:@"material {\n"]; [ds addTab];
			[ds addTab];
			for (int x=beginLayer; x<=endLayer; x++)
				[MaterialTemplate addLayer:ds atIndex:x fromMap:cmap];
			if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			[ds copyTabAndText:@"hollow\n"];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;
		case cObjectDifference:
			[ds copyTabAndText:@"difference {\n"];
			[ds addTab];
			[ds copyTabAndText:@"box {<-0.5, -0.5, 0.0>, <0.5, 0.5, 0.5>}\n"];
			[ds copyTabAndText:@"sphere {	<0.0, 0.0, 0.0>, 0.35}\n"];
			[ds copyTabAndText:@"material {\n"];
			[ds addTab];
			for (int x=beginLayer; x<=endLayer; x++)
				[MaterialTemplate addLayer:ds atIndex:x fromMap:cmap];
			if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			[ds copyTabAndText:@"hollow\n"];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;			
		case cObjectSphere_0005:
			[ds copyTabAndText:@"sphere { <0.0,0.0,0.05 >,0.5\n"];
			[ds addTab];
			[ds copyTabAndText:@"material {\n"]; 
			[ds addTab];
			for (int x=beginLayer; x<=endLayer; x++)
				[MaterialTemplate addLayer:ds atIndex:x fromMap:cmap];
			if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			[ds copyTabAndText:@"hollow\n"];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;
		case cObjectBox_0010:
			[ds copyTabAndText:@"box {0, <1, 1, 0.1>\n"];
			[ds addTab];
			[ds copyTabAndText:@"material {\n"];
			[ds addTab];
			for (int x=beginLayer; x<=endLayer; x++)
				[MaterialTemplate addLayer:ds atIndex:x fromMap:cmap];
			if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"materialTransformations"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			[ds copyTabAndText:@" translate <-0.5, -0.5, 0>\n"];
			break;
		
	}

//	[ds autorelease];
	NSString *content=[ds string];
	NSURL *materialFileURL =[NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"material.pov"]];
	[content writeToURL:materialFileURL atomically:NO encoding: NSUTF8StringEncoding error:NULL];

	NSRect bounds=[mateiralPreviewView bounds];
	NSMutableDictionary *currentSettings=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:bounds.size.width], @"frameWidth",
		[NSNumber numberWithInt:bounds.size.height], @"frameHeight",
		[materialFileURL path], 				@"fileName",
	nil];
		
	if ( currentSettings)	//make sure we have usable settings to render the file
	{
		//switch to preview panel
		[materialPreviewTabView selectTabViewItemAtIndex:cPreviewTab];
		gMaterialPreview=mateiralPreviewView;
		NSDictionary *dict=[NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithBool:YES] ,	@"shouldStartRendering",
			currentSettings,				@"rendersettings",
			[NSNumber numberWithBool:YES],  @"renderMaterial",
			[NSDate date],					@"dateOfPosting",
			nil];

		[[NSNotificationCenter defaultCenter]
			postNotificationName:@"renderDocument" 
			object:self 
			userInfo:dict];
	}

	
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[MaterialTemplate createDefaults:menuTagTemplateMaterial];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"materialDefaultSettings",
		nil];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:factoryDefaults];
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType
{
		
		
	NSMutableDictionary *initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSArchiver archivedDataWithRootObject:		[materialEditorMap standardMap]],		@"materialEditorMap",
		[NSNumber numberWithInt:NSOffState],		@"materialMainTabView",
		[NSNumber numberWithInt:NSOffState],		@"materialDontWrapInMaterial",

		[NSNumber numberWithInt:NSOffState],		@"materialTransformationsOn",
		@"0.0",																	@"materialVEdit",
		@"0.0",																	@"materialHEdit",
		[NSNumber numberWithInt:NSOnState],			@"materialFillOn",
		@"25",																	@"materialFillEdit",
		
		[NSNumber numberWithInt:cObjectUnion],			@"materialObjectPopUp",
		[NSNumber numberWithInt:cBackgroundBlack],	@"materialBackgroundPopUp",
		[NSNumber numberWithInt:cReflectNothing],		@"materialReflectPopUp",

	nil];

	return initialDefaults;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[mPigmentFileOwner release];
	[mNormalFileOwner release];
	[mFinishFileOwner release];
	[mInteriorFileOwner release];
	[super dealloc];
}

//---------------------------------------------------------------------
// renderState
//---------------------------------------------------------------------
// notification
//	when the dispatcher started a render or finished a render
//---------------------------------------------------------------------
-(void) renderState:(NSNotification *) notification
{
	NSNumber *number=[[notification userInfo] objectForKey: @"renderStarted"];
	if ( number)
	{
		if ( [number boolValue] == YES)
		{
			[materialDrawLayer setEnabled:NO];
			[materialDrawMaterial setEnabled:NO];
			[materialDrawLayer setTitle:@"Busy..."];
			[materialDrawMaterial setTitle:@"Busy..."];
		}
		else
		{
			[materialDrawLayer setEnabled:YES];
			[materialDrawMaterial setEnabled:YES];
			[materialDrawLayer setTitle:@"Draw Layer"];
			[materialDrawMaterial setTitle:@"Draw Material"];
		}
		
	}
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"renderState"
		object:nil];
		
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(renderState:)
		name:@"preparingState"
		object:nil];
	if ( [[renderDispatcher sharedInstance] rendering]==YES 
				|| [[renderDispatcher sharedInstance] preparingToRender]==YES)
	{
		[materialDrawLayer setEnabled:NO];
		[materialDrawMaterial setEnabled:NO];
	}

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		materialTransformationsOn,	@"materialTransformationsOn",
		materialDontWrapInMaterial,	@"materialDontWrapInMaterial",
		materialMainTabView,				@"materialMainTabView",
		materialVEdit,							@"materialVEdit",
		materialHEdit,							@"materialHEdit",
		materialFillOn,							@"materialFillOn",
		materialFillEdit,						@"materialFillEdit",

		materialObjectPopUp,				@"materialObjectPopUp",
		materialBackgroundPopUp,		@"materialBackgroundPopUp",
		materialReflectPopUp,				@"materialReflectPopUp",

	nil] ;
	
	[mOutlets retain];

	[ToolTipAutomator setTooltips:@"materialEditorLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"materialEditorLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			materialTransformationsEditButton,	@"materialTransformationsEditButton",
			materialDrawLayer,						@"materialDrawLayer",
			materialDrawMaterial,						@"materialDrawMaterial",
			materialHorizontalSlider,					@"materialHorizontalSlider",
			materialVerticalSlider,						@"materialVerticalSlider",
			materialPigmentOn,						@"materialPigmentOn",
			materialNormalOn,							@"materialNormalOn",
			materialFinishOn,							@"materialFinishOn",
			materialInteriorOn,							@"materialInteriorOn",

			mAddButton	,								@"mAddButton",		
			mInsertButton,								@"mInsertButton",
			mTrashButton,								@"mTrashButton",
		nil]
		];

	mPigmentFileOwner=[[PigmentTemplate alloc] initWithDocumentPointer:self 
		andDictionary:nil forType:menuTagTemplatePigment];
	[NSBundle loadNibNamed:@"pigmentTemplate.nib" owner:mPigmentFileOwner];
	[mPigmentFileOwner setWindow:[self getWindow]];	//for sheets
	[materialPigmentViewHolder  addSubview:[mPigmentFileOwner pigmentMainViewNIBView]];

	mNormalFileOwner=[[NormalTemplate alloc] initWithDocumentPointer:self 
		andDictionary:nil forType:menuTagTemplateNormal];
	[NSBundle loadNibNamed:@"normalTemplate.nib" owner:mNormalFileOwner];
	[mNormalFileOwner setWindow:[self getWindow]];	//for sheets
	[materialNormalViewHolder  addSubview:[mNormalFileOwner normalMainViewNIBView]];

	mFinishFileOwner=[[FinishTemplate alloc] initWithDocumentPointer:self 
		andDictionary:nil forType:menuTagTemplateFinish];
	[NSBundle loadNibNamed:@"finishTemplate.nib" owner:mFinishFileOwner];
	[mFinishFileOwner setWindow:[self getWindow]];	//for sheets
	[materialFinishViewHolder  addSubview:[mFinishFileOwner finishMainViewNIBView]];

	mInteriorFileOwner=[[InteriorTemplate alloc] initWithDocumentPointer:self 
		andDictionary:nil forType:menuTagTemplateInterior];
	[NSBundle loadNibNamed:@"interiorTemplate.nib" owner:mInteriorFileOwner];
	[mInteriorFileOwner setWindow:[self getWindow]];	//for sheets
	[materialInteriorViewHolder  addSubview:[mInteriorFileOwner interiorMainViewNIBView]];


    // setup the NSButtonCell to place inside the table view
 	id checkboxCell;
     checkboxCell = [[[NSButtonCell alloc] initTextCell: @""] autorelease];
    [checkboxCell setEditable: YES];
    [checkboxCell setButtonType: NSSwitchButton];
    [checkboxCell setImagePosition: NSImageOnly];
    [checkboxCell setControlSize: NSSmallControlSize];
    
    // actually place the button cell on the table view
    [[mTableView tableColumnWithIdentifier: @"Active"] setDataCell: checkboxCell];
        // register for drag action, using the drag type we defined
    [mTableView registerForDraggedTypes: [NSArray arrayWithObjects: SITDADDragType, nil]];

	[self  setValuesInPanel:[self preferences]];
	
	
}

//---------------------------------------------------------------------
// currentImportExportTitle
//---------------------------------------------------------------------
-(NSString*)currentImportExportTitle:(BOOL)import
{
	NSString *menuItemString=nil;
	NSString *titleString=nil;
	if( import==YES)
		menuItemString=[NSString stringWithString:
			NSLocalizedStringFromTable(@"importMenuItem", @"applicationLocalized", @"")];
	else
		menuItemString=[NSString stringWithString:
			NSLocalizedStringFromTable(@"exportMenuItem", @"applicationLocalized", @"")];
	
	switch ([materialMainTabView indexOfTabViewItem:[materialMainTabView selectedTabViewItem]])
	{
		case cMaterialPigmentTab:	titleString = 
			NSLocalizedStringFromTable(@"cMaterialPigmentTab", @"applicationLocalized", @"");
			break;

		case cMaterialNormalTab:	titleString =
			NSLocalizedStringFromTable(@"cMaterialNormalTab", @"applicationLocalized", @""); 
			break;

		case cMaterialFinishTab:		titleString =
			NSLocalizedStringFromTable(@"cMaterialFinishTab", @"applicationLocalized", @""); 		
			break;

		case cMaterialInteriorTab:	titleString =
			NSLocalizedStringFromTable(@"cMaterialInteriorTab", @"applicationLocalized", @""); 			
			break;
	}
	menuItemString=[menuItemString stringByAppendingString:@" "];
	
	return [menuItemString stringByAppendingString:titleString];
}

//---------------------------------------------------------------------
// importSettings
//---------------------------------------------------------------------
-(void) importSettings
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];
	[openPanel setDirectoryURL:nil];
	void (^importPreferencesOpenSavePanelHandler)(NSInteger) = ^( NSInteger resultCode )
	{
		@autoreleasepool
		{
			NSMutableDictionary *dict=nil;
			if ( resultCode == NSOKButton )
				dict=[NSMutableDictionary dictionaryWithContentsOfURL:[openPanel URL]];
			NSString *LocalizedSettingsfileToBeUsed=nil;
			if ( dict != nil)
			{
				id dictName=[dict objectForKey:@"dictionaryTypeDefaults"];
				NSString *templateName=@"";
				NSMutableDictionary *defaultDict=nil;
				NSInteger currentTab=[materialMainTabView indexOfTabViewItem:[materialMainTabView selectedTabViewItem]];
				switch (currentTab)
				{
					case cMaterialPigmentTab:
						templateName=NSStringFromClass([PigmentTemplate class]);
						defaultDict=[PigmentTemplate createDefaults:menuTagTemplatePigment];
						LocalizedSettingsfileToBeUsed=NSLocalizedStringFromTable(@"OnlyPigmetSettingsfile", @"applicationLocalized", @"Only pigment files can be used.");
						break;
					case cMaterialNormalTab:
						templateName=NSStringFromClass([NormalTemplate class]);
						defaultDict=[NormalTemplate createDefaults:menuTagTemplateNormal];
						LocalizedSettingsfileToBeUsed=NSLocalizedStringFromTable(@"OnlyNormalSettingsFile", @"applicationLocalized", @"Only normal files can be used.");
						break;
					case cMaterialFinishTab:
						templateName=NSStringFromClass([FinishTemplate class]);
						defaultDict=[FinishTemplate createDefaults:menuTagTemplateFinish];
						LocalizedSettingsfileToBeUsed=NSLocalizedStringFromTable(@"OnlyFinisSettingsFile", @"applicationLocalized", @"Only finish files can be used.");
						break;
					case cMaterialInteriorTab:
						templateName=NSStringFromClass([InteriorTemplate class]);
						defaultDict=[InteriorTemplate createDefaults:menuTagTemplateInterior];
						LocalizedSettingsfileToBeUsed=NSLocalizedStringFromTable(@"OnlyInteriorSettingsFile", @"applicationLocalized", @"Only interior files can be used.");
						break;
				}
				if ( defaultDict != nil)
				{
					// add missing settings from the default dict to the loaded dict
					NSEnumerator *en=[defaultDict keyEnumerator];
					NSString *key;
					while ( (key = [en nextObject]) != nil )
					{
						if ( [dict objectForKey:key]==nil)
							[dict setObject:[defaultDict objectForKey:key] forKey:key];
					}
				}
				
				if ( dictName && [dictName isEqualToString:templateName])
				{
					switch (currentTab)
					{
						case cMaterialPigmentTab:
							[mMap setObject:dict atRow:[mMap selectedRow] atColumn:cMaterialmapPigmentDictIndex];
							[mPigmentFileOwner setPreferences: dict];
							[mPigmentFileOwner  setValuesInPanel:[mPigmentFileOwner preferences]];
							break;
						case cMaterialNormalTab:
							[mMap setObject:dict atRow:[mMap selectedRow] atColumn:cMaterialmapNormalDictIndex];
							[mNormalFileOwner setPreferences: dict];
							[mNormalFileOwner  setValuesInPanel:[mNormalFileOwner preferences]];
							break;
						case cMaterialFinishTab:
							[mMap setObject:dict atRow:[mMap selectedRow] atColumn:cMaterialmapFinishDictIndex];
							[mFinishFileOwner setPreferences: dict];
							[mFinishFileOwner  setValuesInPanel:[mFinishFileOwner preferences]];
							break;
						case cMaterialInteriorTab:
							[mMap setObject:dict atRow:[mMap selectedRow] atColumn:cMaterialmapInteriorDictIndex];
							[mInteriorFileOwner setPreferences: dict];
							[mInteriorFileOwner  setValuesInPanel:[mInteriorFileOwner preferences]];
							break;
					}
					
				}
				else
				{
					NSRunAlertPanel(NSLocalizedStringFromTable(@"WrongTemplateSettings", @"applicationLocalized", @"Wrong preferences file"),
					@"%@",
					NSLocalizedStringFromTable(@"Ok", @"applicationLocalized", @"Cancel"),
													nil, 
													nil, LocalizedSettingsfileToBeUsed);
				}
				[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionDidChangeNotification" object:mTableView];
			}
		}
	};
	[openPanel beginSheetModalForWindow:[self getWindow] 
                              completionHandler:importPreferencesOpenSavePanelHandler];

}

//---------------------------------------------------------------------
// exportSettings
//---------------------------------------------------------------------
// saves only the settings of the active panel
//---------------------------------------------------------------------
-(void) exportSettings
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	id trimmedPrefs=nil;
	NSString *PanelTitle=nil;
	int currentTab=[materialMainTabView indexOfTabViewItem:[materialMainTabView selectedTabViewItem]];
	switch (currentTab)
	{
		case cMaterialPigmentTab:	
			[mPigmentFileOwner retrivePreferences];
			trimmedPrefs=[mPigmentFileOwner  removeStandardSettingsFromPreference:[mPigmentFileOwner preferences] ];
			PanelTitle=@"Export Pigment";
			break;
		case cMaterialNormalTab:	
			[mNormalFileOwner retrivePreferences];
			trimmedPrefs=[mNormalFileOwner  removeStandardSettingsFromPreference:[mNormalFileOwner preferences] ];
			PanelTitle=@"Export Normal";
			break;
		case cMaterialFinishTab:		
			[mFinishFileOwner retrivePreferences];
			trimmedPrefs=[mFinishFileOwner  removeStandardSettingsFromPreference:[mFinishFileOwner preferences] ];
			PanelTitle=@"Export Finish";
			break;
		case cMaterialInteriorTab:	
			[mInteriorFileOwner retrivePreferences];
			trimmedPrefs=[mInteriorFileOwner  removeStandardSettingsFromPreference:[mInteriorFileOwner preferences] ];
			PanelTitle=@"Export Interior";
			break;
	}
//	[trimmedPrefs retain];

	NSSavePanel *savePanel=[NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];
	[savePanel setDirectoryURL:nil];
	[savePanel setTitle:PanelTitle];
	
 [savePanel beginSheetModalForWindow:[self getWindow] 
                              completionHandler: ^( NSInteger resultCode )
	{
		@autoreleasepool
	 	{
			if( resultCode ==NSOKButton )
				[trimmedPrefs writeToURL:[savePanel URL] atomically:YES];
    }
	}
  ];	
}

	
//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	
	//make sure we have all changed settings in the selected layer
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionIsChangingNotification" object:mTableView];

	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];

	if (dict == nil)
		return;
		
	for (int x=1; x<=[mMap count]; x++)
	{
		int z=x-1;
		id obj;
		id trimmedPrefs;
		obj=[mMap objectAtRow:z atColumn:cMaterialmapPigmentDictIndex];
		trimmedPrefs=[mPigmentFileOwner  removeStandardSettingsFromPreference:obj ];
		[mMap setObject:trimmedPrefs atRow:z atColumn:cMaterialmapPigmentDictIndex];

		obj=[mMap objectAtRow:z atColumn:cMaterialmapNormalDictIndex];
		trimmedPrefs=[mNormalFileOwner  removeStandardSettingsFromPreference:obj ];
		[mMap setObject:trimmedPrefs atRow:z atColumn:cMaterialmapNormalDictIndex];

		obj=[mMap objectAtRow:z atColumn:cMaterialmapFinishDictIndex];
		trimmedPrefs=[mFinishFileOwner  removeStandardSettingsFromPreference:obj ];
		[mMap setObject:trimmedPrefs atRow:z atColumn:cMaterialmapFinishDictIndex];

		obj=[mMap objectAtRow:z atColumn:cMaterialmapInteriorDictIndex];
		trimmedPrefs=[mInteriorFileOwner  removeStandardSettingsFromPreference:obj];
		[mMap setObject:trimmedPrefs atRow:z atColumn:cMaterialmapInteriorDictIndex];
	}	

	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"materialEditorMap"];

//store transformations if selected
	if ( materialTransformations != nil )
		if ( [[dict objectForKey:@"materialTransformationsOn"]intValue]==NSOnState)
			[dict setObject:materialTransformations forKey:@"materialTransformations"];

}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
 	[self setMap:[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"materialEditorMap"]]];
	[mMap selectTableRow:0];
	[self setMaterialTransformations:[preferences objectForKey:@"materialTransformations"]];
	[super setValuesInPanel:preferences];
	[mTableView reloadData];
// 	[ mTableView noteNumberOfRowsChanged];
	[self updateControls];
}


//---------------------------------------------------------------------
// openPreferencesOpenSavePanelDidEnd
//---------------------------------------------------------------------
/*- (void) openPreferencesOpenSavePanelDidEnd:(NSOpenPanel *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	[super openPreferencesOpenSavePanelDidEnd:sheet returnCode:returnCode  contextInfo:contextInfo];
	// make sure the new data is loaded to the panels
	[self tableViewSelectionDidChange:nil];

}
*/
//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{	
	[self materialTarget:self];
	[self setNotModified];
}


//---------------------------------------------------------------------
// materialTarget:sender
//---------------------------------------------------------------------
-(IBAction) materialTarget:(id)sender
{
	int theTag;
	if ( sender==self)
		theTag=cMaterialTransformationsOn;
	else
		theTag=[sender tag];

	switch( theTag)
	{
		case 	cMaterialTransformationsOn:
			[self enableObjectsAccordingToObject:materialTransformationsOn, materialTransformationsEditButton,nil];
			if ( sender !=self )	break;

/*		case cMaterialObjectPopUp:
			[materialObjectPopUp selectIte:[materialObjectPopUp titleOfSelectedItem]];
			if ( sender !=self )	break;
		case cMaterialBackgroundPopUp:
			[materialBackgroundPopUp setTitle:[materialBackgroundPopUp titleOfSelectedItem]];
			if ( sender !=self )	break;
		case cMaterialReflectPopUp:
			[materialReflectPopUp setTitle:[materialReflectPopUp titleOfSelectedItem]];
			if ( sender !=self )	break;
*/
		case cMaterialVEdit:
			[materialVerticalSlider setIntValue:[materialVEdit intValue]];
			if ( sender !=self )	break;
		case cMaterialHEdit:
			[materialHorizontalSlider setIntValue:[materialHEdit intValue]*-1];
			if ( sender !=self )	break;
		case cMaterialFillOn:
			[self enableObjectsAccordingToObject:materialFillOn, materialFillEdit,nil];
			break;		//always break here, settings done wiht edit field
		case cMaterialHorizontalSlider:
			[materialHEdit  setIntValue:[materialHorizontalSlider intValue]*-1];
			break;		//always break here, settings done wiht edit field
		case cMaterialVerticalSlider:
			[materialVEdit  setIntValue:[materialVerticalSlider intValue]];
			break;		//always break here, settings done wiht edit field

	}
	[self setModified:nil];
}
//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	if( [key isEqualToString:@"materialTransformations"])
	{
		[self setMaterialTransformations:dict];
	}
}

//---------------------------------------------------------------------
// materialButtons:sender
//---------------------------------------------------------------------
-(IBAction) materialButtons:(id)sender
{
	id 	prefs=nil;

	int tag=[sender tag];
	
	switch( tag)
	{

		case cMaterialDrawLayer:
			[self previewMaterial:YES];
			break;
		case cMaterialDrawMaterial:
			[self previewMaterial:NO];
			break;

		case cMaterialTransformationsEditButton:
			if (materialTransformations!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:materialTransformations];
			[self callTemplate:menuTagTemplateTransformations withDictionary:prefs andKeyName:@"materialTransformations"];
			break;
		case cPigmentOn:
			[mMap setInt:[sender state] atRow:[mMap selectedRow] atColumn:cMaterialmapPigmentOnIndex];
			[self updateGreenLeds];
			break;
		case cNormalOn:
			[mMap setInt:[sender state] atRow:[mMap selectedRow] atColumn:cMaterialmapNormalOnIndex];
			[self updateGreenLeds];
			break;
		case cFinishOn:
			[mMap setInt:[sender state] atRow:[mMap selectedRow] atColumn:cMaterialmapFinishOnIndex];
			[self updateGreenLeds];
			break;
		case cInteriorOn:
			[mMap setInt:[sender state] atRow:[mMap selectedRow] atColumn:cMaterialmapInteriorOnIndex];
			[self updateGreenLeds];
			break;
	}
	[self setModified:nil];
}


//---------------------------------------------------------------------
// setButtons
//---------------------------------------------------------------------
-(void) setButtons
{
	if ( [mMap selectedRow] == dNoRowSelected)	
	{
		[mInsertButton setEnabled:NO];
		[mAddButton setEnabled:YES];
		[mTrashButton setEnabled:NO];
	}
	else  
	{
		[mInsertButton setEnabled:YES];
		[mAddButton setEnabled:YES];
		[mTrashButton setEnabled:YES];
	}
	if ([mMap count] <=1)
		[mTrashButton setEnabled:NO];
	[self updateGreenLeds];
}

//---------------------------------------------------------------------
// updateGreenLeds
//---------------------------------------------------------------------
-(void) updateGreenLeds
{
	if ( [mMap selectedRow]!= dNoRowSelected)
	{
		//pigment
		[materialPigmentOn setIntValue:[mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapPigmentOnIndex]];
		if ( [mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapPigmentOnIndex]==NSOnState)
			[mPigmentGreenLed setHidden:NO];
		else
			[mPigmentGreenLed setHidden:YES];
		//normal
		[materialNormalOn setIntValue:[mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapNormalOnIndex]];
		if ( [mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapNormalOnIndex]==NSOnState)
			[mNormalGreenLed setHidden:NO];
		else
			[mNormalGreenLed setHidden:YES];
		//finish
		[materialFinishOn setIntValue:[mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapFinishOnIndex]];
		if ( [mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapFinishOnIndex]==NSOnState)
			[mFinishGreenLed setHidden:NO];
		else
			[mFinishGreenLed setHidden:YES];
		//interior
		[materialInteriorOn setIntValue:[mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapInteriorOnIndex]];
		if ( [mMap intAtRow:[mMap selectedRow] atColumn:cMaterialmapInteriorOnIndex]==NSOnState)
			[mInteriorGreenLed setHidden:NO];
		else
			[mInteriorGreenLed setHidden:YES];
	
	}
}

//---------------------------------------------------------------------
// selectionIncludePathTableViewChanged
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	if ( mMap && [mMap respondsToSelector:@selector(setSelectedRow:)])
		[mMap setSelectedRow:[mTableView selectedRow]];
	if ( [mMap selectedRow]!= dNoRowSelected)
	{
		[mPigmentFileOwner setPreferences: [mMap objectAtRow:[mMap selectedRow] atColumn:cMaterialmapPigmentDictIndex]];
		[mPigmentFileOwner  setValuesInPanel:[mPigmentFileOwner preferences]];

		[mNormalFileOwner setPreferences: [mMap objectAtRow:[mMap selectedRow] atColumn:cMaterialmapNormalDictIndex]];
		[mNormalFileOwner  setValuesInPanel:[mNormalFileOwner preferences]];

		[mFinishFileOwner setPreferences: [mMap objectAtRow:[mMap selectedRow] atColumn:cMaterialmapFinishDictIndex]];
		[mFinishFileOwner  setValuesInPanel:[mFinishFileOwner preferences]];

		[mInteriorFileOwner setPreferences: [mMap objectAtRow:[mMap selectedRow] atColumn:cMaterialmapInteriorDictIndex]];
		[mInteriorFileOwner  setValuesInPanel:[mInteriorFileOwner preferences]];

	}

	[self setButtons];
}

//---------------------------------------------------------------------
// tableViewSelectionIsChanging
//---------------------------------------------------------------------
// notification
//---------------------------------------------------------------------
- (void)tableViewSelectionIsChanging:(NSNotification *)aNotification
{
	if ( [mMap selectedRow]!= dNoRowSelected)
	{
		[mPigmentFileOwner retrivePreferences];
		[mMap setObject:[mPigmentFileOwner preferences] atRow:[mMap selectedRow] atColumn:cMaterialmapPigmentDictIndex];
		
		[mNormalFileOwner retrivePreferences];
		[mMap setObject:[mNormalFileOwner preferences] atRow:[mMap selectedRow] atColumn:cMaterialmapNormalDictIndex];
		
		[mFinishFileOwner retrivePreferences];
		[mMap setObject:[mFinishFileOwner preferences] atRow:[mMap selectedRow] atColumn:cMaterialmapFinishDictIndex];
		
		[mInteriorFileOwner retrivePreferences];
		[mMap setObject:[mInteriorFileOwner preferences] atRow:[mMap selectedRow] atColumn:cMaterialmapInteriorDictIndex];
	}
}


//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];

	if ( [identifier isEqualToString:@"layerName"])
		return [mMap objectAtRow:rowIndex atColumn:cMaterialmapLayerNameIndex];
	else if ( [identifier isEqualToString:@"Active"])
		return [mMap objectAtRow:rowIndex atColumn:cMaterialmapOnOffIndex];
	return nil;
}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"layerName"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cMaterialmapLayerNameIndex];
	else if ( [identifier isEqualToString:@"Active"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cMaterialmapOnOffIndex];
	[mTableView reloadData];		// redraw the table
}



/*********************************************/
/*  table view dragging data source methods  */
/*********************************************/

//---------------------------------------------------------------------
// tableView:writeRows:toPasteboard
//---------------------------------------------------------------------
// This method is called after it has been determined that a drag should begin, but before the drag has 0
//	been started.  
//	To refuse the drag, return NO.  
//	To start a drag, return YES and place the drag data onto the pasteboard (data, owner, etc...).  
//	The drag image and other drag related information will be set up and provided by the table view once 
//	this call returns with YES.  The rows array is the list of row numbers that will be participating in the drag. 
//---------------------------------------------------------------------
- (BOOL)tableView: (NSTableView *)aTableView writeRowsWithIndexes: (NSIndexSet *)rowIndexes toPasteboard: (NSPasteboard *)pboard
{
    if ([rowIndexes count] > 1)	// don't allow dragging with more than one row
        return NO;
    mDraggedRow = [rowIndexes firstIndex];

    // the NSArray "rows" is actually an array of the indecies dragged
    
    // declare our dragged type in the paste board
    [pboard declareTypes: [NSArray arrayWithObjects: SITDADDragType, nil] owner: self];
    
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionIsChangingNotification" object:mTableView];

    // put the data value into the paste board
    [pboard setData: [mMap archivedObjectAtIndex: mDraggedRow] forType: SITDADDragType];
    
    return YES;
}

//---------------------------------------------------------------------
// tableView:validateDrop:proposedRow:proposedDropOperation
//---------------------------------------------------------------------
// This method is used by NSTableView to determine a valid drop target.  Based on the mouse position, 
//	the table view will suggest a proposed drop location.  
//	This method must return a value that indicates which dragging operation the data source will perform.  
//	The data source may "re-target" a drop if desired by calling setDropRow:dropOperation: and returning 
//	something other than NSDragOperationNone.  One may choose to re-target for various reasons (eg. for 
//	better visual feedback when inserting into a sorted position). 
//---------------------------------------------------------------------
- (NSDragOperation)tableView: (NSTableView *)aTableView validateDrop: (id <NSDraggingInfo>)item
    proposedRow: (NSInteger)row  proposedDropOperation: (NSTableViewDropOperation)op
{
    // means the drag operation can be desided by the destination
    return NSDragOperationGeneric;
}

//---------------------------------------------------------------------
// tableView:acceptDrop:row:dropOperation
//---------------------------------------------------------------------
// This method is called when the mouse is released over an outline view that previously decided to 
//	allow a drop via the validateDrop method.  The data source should incorporate the data from the 
//	dragging pasteboard at this time. 
//---------------------------------------------------------------------
- (BOOL)tableView:(NSTableView*)aTableView acceptDrop: (id <NSDraggingInfo>)item
    row: (NSInteger)row dropOperation:(NSTableViewDropOperation)op
{
    NSPasteboard *pboard = [item draggingPasteboard];	// get the paste board
    NSData *data;
    if (row >= [mMap count])
    {
        row = [mMap count] - 1;
    }
		
    if ([pboard availableTypeFromArray:[NSArray arrayWithObject: SITDADDragType]])
    // test to see if the string for the type we defined in the paste board.
    // if doesn't, do nothing.
    {
				data = [pboard dataForType: SITDADDragType];	// get the data from paste board

        // remove the index that got dragged, now that we are accepting the dragging
        [mMap removeEntryAtIndex: mDraggedRow reload:NO];
        // insert the new data (same one that got dragger) into the array
        [mMap insertArchivedObject: data atIndex: row];
    }
    [mTableView reloadData];
  
    [mTableView selectRowIndexes:[[[NSIndexSet alloc] initWithIndex:row]autorelease] byExtendingSelection: NO];	// select the row
    
    return YES;
}

//---------------------------------------------------------------------
// addBackgroundToString:withDict
//---------------------------------------------------------------------
+(void) addBackgroundToString:(MutableTabString *)ds withDict:(NSDictionary *)dict 
{
	switch( [[dict objectForKey:@"materialBackgroundPopUp"]intValue])
	{
		case cBackgroundBlack:		// no Background
			break;
		case cBackgroundWhite:
			[ds copyTabAndText:@"background { rgb 1.0 }\n"];
			break;
		case cBackgroundSkysphere:
			[MaterialTemplate addSkySphereToString:ds withDict:dict];
			break;
		case cBackgroundGridBlack:
			[ds copyTabAndText:@"#declare C = 0;\n"];
			[ds copyTabAndText:@"#declare Copies = 10;\n"];
			[ds copyTabAndText:@"#while ( C < Copies)\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -0.6, 0.0>, <0, 0.6, 0.0>, 0.01\n"];
			[ds copyTabAndText:@"		translate <(-0.6 + (C * (1.2)/(Copies -1))),0,0.55>\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 0 } finish { ambient 0 } }\n"];
			[ds copyTabAndText:@"	} //object\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -0.6, 0.0>, <0, 0.6, 0.0>, 0.01\n"];
			[ds copyTabAndText:@"		translate <(-0.6 + (C * (1.2)/(Copies -1))),0,0.55>\n"];
			[ds copyTabAndText:@"		rotate z*90\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 0 }finish { ambient 0 }  }\n"];
			[ds copyTabAndText:@"	} //object\n"];
			[ds copyTabAndText:@"	#declare C = C +1;\n"];
			[ds copyTabAndText:@"#end  //while (C < Copies)\n"];
			break;
		case cBackgroundGridWhite:
			[ds copyTabAndText:@"#declare C = 0;\n"];
			[ds copyTabAndText:@"#declare Copies = 10;\n"];
			[ds copyTabAndText:@"#while ( C < Copies)\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -0.6, 0.0>, <0, 0.6, 0.0>, 0.01\n"];
			[ds copyTabAndText:@"		translate <(-0.6 + (C * (1.2)/(Copies -1))),0,0.55>\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 1 } finish { ambient 1 } }\n"];
			[ds copyTabAndText:@"	} //object\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -0.6, 0.0>, <0, 0.6, 0.0>, 0.01\n"];
			[ds copyTabAndText:@"		translate <(-0.6 + (C * (1.2)/(Copies -1))),0,0.55>\n"];
			[ds copyTabAndText:@"		rotate z*90\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 1 } finish { ambient 1 } }\n"];
			[ds copyTabAndText:@"	} //object\n"];
			[ds copyTabAndText:@"	#declare C = C +1;\n"];
			[ds copyTabAndText:@"#end  //while (C < Copies)\n"];
			break;
		case cBackgroundChecker:
			[ds copyTabAndText:@"box {\n"];
			[ds copyTabAndText:@"<-6, -6, 0.55>, <6, 6, 0.6>\n"];
			[ds copyTabAndText:@"pigment { checker rgb 0, rgb 2 scale 0.1}\n"];
			[ds copyTabAndText:@"}\n"];
			break;
		default:
			break;
	}
}

//---------------------------------------------------------------------
// addSkySphereToString:withDict
//---------------------------------------------------------------------
+(void) addSkySphereToString:(MutableTabString *)ds withDict:(NSDictionary *)dict 
{
	if ( mSkySphereWritten==NO)
	{
		mSkySphereWritten=YES;
		[ds copyTabAndText:@"sky_sphere {pigment {gradient y pigment_map {\n"];
		[ds copyTabAndText:@"[ 0.00 rgb <0.847, 0.749, 0.847> ]	\n"];
		[ds copyTabAndText:@"[ 0.10 rgb <0.196078, 0.6, 0.8> ]\n"];
		[ds copyTabAndText:@"[ 0.20 wrinkles turbulence 0.1 lambda 2.2 omega 0.707\n"];
		[ds copyTabAndText:@"color_map {\n"];
		[ds copyTabAndText:@"[ 0.20 rgb <0.196078, 0.6, 0.8>*0.85 ]	\n"];
		[ds copyTabAndText:@"[ 0.70 rgb 1 ]\n"];
		[ds copyTabAndText:@"[ 1.00 rgb 0.7 ]	}\n"];
		[ds copyTabAndText:@"scale <0.5, 0.15, 1>]}}\n"];
		[ds copyTabAndText:@"translate y*-0.4 }\n"];
	}
}

//---------------------------------------------------------------------
// addReflectionToString:withDict
//---------------------------------------------------------------------
+(void) addReflectionToString:(MutableTabString *)ds withDict:(NSDictionary *)dict 
{
	switch( [[dict objectForKey:@"materialReflectPopUp"]intValue])
	{
		case cReflectNothing:		// no reflection
			break;
		case cReflectSkysphereClouds:
			[MaterialTemplate addSkySphereToString:ds withDict:dict];
			break;
		case cReflectSkysphereWhite:
			[ds copyTabAndText:@"sky_sphere{pigment{rgb 1}}\n"];
			break;
		case cReflectGridWhite:
			[ds copyTabAndText:@"#declare C = 0;\n"];
			[ds copyTabAndText:@"#declare Copies = 40;\n"];
			[ds copyTabAndText:@"#while ( C < Copies)\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -6, 0.0>, <0, 6, 0.0>, 0.02\n"];
			[ds copyTabAndText:@"		translate <(-6 + (C*12/(Copies -1))),0,-2.0>\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 1 } finish {ambient 1}}\n"];
			[ds copyTabAndText:@"	no_shadow} //object\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -6, 0.0>, <0, 6, 0.0>, 0.02\n"];
			[ds copyTabAndText:@"		translate <(-6 + (C *12/(Copies -1))),0,-2.0>\n"];
			[ds copyTabAndText:@"		rotate z*90\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 1 } finish {ambient 1} }\n"];
			[ds copyTabAndText:@"	no_shadow} //object\n"];
			[ds copyTabAndText:@"	#declare C = C +1;\n"];
			[ds copyTabAndText:@"#end  //while (C < Copies)\n"];
			break;
		case cRefelctGridBlack:
			[ds copyTabAndText:@"#declare C = 0;\n"];
			[ds copyTabAndText:@"#declare Copies = 40;\n"];
			[ds copyTabAndText:@"#while ( C < Copies)\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -6, 0.0>, <0, 6, 0.0>, 0.02\n"];
			[ds copyTabAndText:@"		translate <(-6 + (C *12/(Copies -1))),0,-2.0>\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 0 } finish {ambient 0}}\n"];
			[ds copyTabAndText:@"	no_shadow} //object\n"];
			[ds copyTabAndText:@"	cylinder {\n"];
			[ds copyTabAndText:@"		<0, -6, 0.0>, <0, 6, 0.0>, 0.02\n"];
			[ds copyTabAndText:@"		translate <(-6 + (C *12/(Copies -1))),0,-2.0>\n"];
			[ds copyTabAndText:@"		rotate z*90\n"];
			[ds copyTabAndText:@"		texture { pigment { rgb 0 } finish {ambient 0} }\n"];
			[ds copyTabAndText:@"	no_shadow} //object\n"];
			[ds copyTabAndText:@"	#declare C = C +1;\n"];
			[ds copyTabAndText:@"#end  //while (C < Copies)\n"];
			break;
		default:
			break;
	}		
}

//---------------------------------------------------------------------
// addCameraToString:withDict
//---------------------------------------------------------------------
+(void) addCameraToString:(MutableTabString *)ds withDict:(NSDictionary *)dict 
{
	//[ds copyTabAndText:@"#version unofficial MegaPOV 1.2;\n"];
	
	[ds copyTabAndText:@"camera {\n"];
	[ds addTab];
	[ds copyTabAndText:@"location <0.0, 0.0, -1.65>\n"];
	[ds copyTabAndText:@"up y right x\n\tangle 35\n"];
	[ds copyTabAndText:@"look_at 0.0\n"];
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];

}

//---------------------------------------------------------------------
// addLightToString:withDict
//---------------------------------------------------------------------
+(void) addLightToString:(MutableTabString *)ds withDict:(NSDictionary *)dict 
{
	[ds copyTabAndText:@"light_source {\n"];
	[ds addTab];
	[ds copyTabAndText:@"<0, 0, -1000> rgb 1.0\n"];
	[ds appendTabAndFormat:@"rotate <%@, %@, 0.0>\n",[dict objectForKey:@"materialVEdit"],[dict objectForKey:@"materialHEdit"]];
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
	
	if ([[dict objectForKey:@"materialFillOn"]intValue]==NSOnState)
		[ds appendTabAndFormat:@"light_source { <0, 0, -1.65>, rgb %@/100 }\n",[dict objectForKey:@"materialVEdit"]];
}

@end




