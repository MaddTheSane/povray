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
#import "baseTemplate.h"
#import "MaterialTemplate.h"
#import "BodymapTemplate.h"
#import "ObjectEditorTemplate.h"
#import "bodyMap.h"
#import "customColorwell.h"
#import "ColorPicker.h"

// this must be the last file included
#import "syspovdebug.h"

															// keep this ordered
															// see BaseTemplate.h  also
static const char *templateTypeNameArray[]={
															"reserved",					//menuTagTemplateReserved					=0,
															"camera",						//menuTagTemplateCamera						=1,	
															"light",						//menuTagTemplateLight						=2,	
															"object",						//menuTagTemplateObject						=3,
															"transformations",	//menuTagTemplateTransformations	=4,	
															"functions",				//menuTagTemplateFunctions				=5,	
															"pigment",					//menuTagTemplatePigment					=6,
															"finish",						//menuTagTemplateFinish						=7,
															"normal",						//menuTagTemplateNormal						=8,
															"interior",					//menuTagTemplateInterior					=9,
															"media",						//menuTagTemplateMedia						=10,
															"photons",					//menuTagTemplatePhotons					=11,
															"background",				//menuTagTemplateBackground				=12,
															"",									//
															"colormap",					//menuTagTemplateColormap					=14,
															"densitymap",				//menuTagTemplateDensitymap				=15,
															"materialmap",			//menuTagTemplateMaterialmap			=16,
															"normalmap",				//menuTagTemplateNormalmap				=17,
															"pigmentmap",				//menuTagTemplatePigmentmap				=18,
															"slopemap",					//menuTagTemplateSlopemap					=19,
															"texturemap",				//menuTagTemplateTexturemap				=20,
															"",									//
															"headerInclude",		//menuTagTemplateHeaderInclude		=22,
															"globals",					//menuTagTemplateGlobals					=23,
															"",									//
															"material"};				//menuTagTemplateMaterial					=25,
				
												
@implementation BaseTemplate

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
// returns a mutalbe dictionary with default settings for this template
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType
{
	return nil;
}

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
// from a given dictionary, build a mutabletabstring containing the 
// template in pov language
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{
	return nil;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[ToolTipAutomator setTooltips:@"applicationLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			templateOkButton,			@"templateOkButton",
			templateCancelButton,	@"templateCancelButton",
			templateResetButton,		@"templateResetButton",
			templateOpenButton,		@"templateOpenButton",
			templateSaveButton,		@"templateSaveButton",
		nil]
		];

}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{

	[self setPreferences:nil];
	[mOutlets release];
	mOutlets=nil;
	[keyName release];
	for (int x=0; x<=24; x++)
		[self setTemplatePrefs:x withObject:nil];
	[mExcludedObjectsForReset release];
	mExcludedObjectsForReset=nil;
	[super dealloc];
}

	
//---------------------------------------------------------------------
// initWithDocumentPointer
//---------------------------------------------------------------------
-(id) initWithDocumentPointer:(id) caller andDictionary:(NSMutableDictionary*)preferences forType:(unsigned int) templateType
{

	self=[super init];
	if ( self)
	{
		mTemplateType=templateType;
		mTemplateCaller=caller;
		if ( preferences!=nil)  // called from another template
		{
			[self setPreferences:preferences];
		}
		else 	if ( [[self caller]isMemberOfClass:[SceneDocument class]])
		{
			NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
			id dict=[defaults  objectForKey:[self defaultPreferencesName]];
			if ( dict != nil)
				dict=[[dict mutableCopy]autorelease];
			[self setPreferences:dict];
		}

		else //if not called from a scenedocument,
				//always create fresh default setttings
		{
		
			[self setPreferences:[[self class] createDefaults:mTemplateType]];
		}

	}
	
	return self;
}


//---------------------------------------------------------------------
// templateSheetDidEnd
//---------------------------------------------------------------------
-(void) templateSheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	if ( returnCode ==NSOKButton)
	{
		NSMutableDictionary *dict=[mFileOwner removeStandardSettingsFromPreference:[mFileOwner preferences] ];
		[self acceptsPreferences:dict forKey:[self keyName]];
	}
//	[sheet orderOut: nil];
	[sheet close];
	[mFileOwner release];
	mFileOwner=nil;
}

//---------------------------------------------------------------------
// runTemplateSheet
//---------------------------------------------------------------------
- (void) runTemplateSheet
{
	[[NSApplication sharedApplication] beginSheet:[mFileOwner getWindow] 
				modalForWindow:[self getWindow] modalDelegate:self 
				didEndSelector:@selector(templateSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}


//---------------------------------------------------------------------
// setKeyName
//---------------------------------------------------------------------
-(void)setKeyName:(NSString*)name
{
	[keyName release];
	keyName=name;
	[keyName retain];
}

//---------------------------------------------------------------------
// keyName
//---------------------------------------------------------------------
-(NSString *) keyName
{
	return keyName;
}

//---------------------------------------------------------------------
// defaultPreferencesName
//---------------------------------------------------------------------
// returns the name for the key @"defaultPreferencesName"
// to identify a settings file
//---------------------------------------------------------------------
-(NSString *) defaultPreferencesName
{
	NSString *defaultPreferencesName=[NSString stringWithUTF8String:templateTypeNameArray[mTemplateType]];
	defaultPreferencesName=[defaultPreferencesName stringByAppendingString:@"DefaultSettings"];
	return defaultPreferencesName;
}



//---------------------------------------------------------------------
// caller
//---------------------------------------------------------------------
-(id) caller
{
	return mTemplateCaller;
}

//---------------------------------------------------------------------
// fileOwner
//---------------------------------------------------------------------
-(id) fileOwner
{
	return mFileOwner;
}

//---------------------------------------------------------------------
// resetButton
//---------------------------------------------------------------------
-(IBAction) resetButton: (id)sender
{
	[self setPreferences:[[self class] createDefaults:mTemplateType]];
	NSMutableDictionary *dict=[[[self preferences]mutableCopy]autorelease];
	if ( dict != nil)
	{
		if ( mExcludedObjectsForReset != nil)
		{
			NSEnumerator *en=[mExcludedObjectsForReset objectEnumerator];
			id key;
			while ( (key = [en nextObject]) != nil ) 
			{
				if ( [dict objectForKey:key] !=nil)
					[dict removeObjectForKey:key];
			}	
		}
		[self  setValuesInPanel:dict];
	}
}

//---------------------------------------------------------------------
// openButton
//---------------------------------------------------------------------
-(IBAction) openButton: (id)sender
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];

	void (^openPreferencesOpenSavePanelHandler)(NSInteger) = ^( NSInteger resultCode )
	{
		@autoreleasepool
			{
			NSDictionary *dict=nil;
     	if ( resultCode == NSOKButton )
			{
				dict=[NSDictionary dictionaryWithContentsOfURL:[openPanel URL]];
				id dictName=[dict objectForKey:@"dictionaryTypeDefaults"];
				if ( dictName)
				{
					if ( [dictName isEqualToString:[self dictionaryTypeName]])
					{
						[self setPreferences:[[dict mutableCopy]autorelease]];
						[self setValuesInPanel:[self preferences]];
					}
					else
					{
						NSString *CurrentPanelString=NSStringFromClass([self class]);
						NSRunAlertPanel( NSLocalizedStringFromTable(
						@"WrongTemplateSettings",
						@"applicationLocalized",
						@"Wrong preferences file"),
										NSLocalizedStringFromTable(@"SelectCorrectFile", @"applicationLocalized",
																   @"Only %@ settings files can be used!"),
														NSLocalizedStringFromTable(@"Ok", @"applicationLocalized", @"Cancel"),
														nil,
														nil, CurrentPanelString);
					}
				}
			}
		}
	};
	[openPanel beginSheetModalForWindow:[self getWindow] 
                              completionHandler:openPreferencesOpenSavePanelHandler];
}
//---------------------------------------------------------------------
// saveButton
//---------------------------------------------------------------------
-(IBAction) saveButton: (id)sender
{
	[self retrivePreferences];
	NSMutableDictionary *trimmedPrefs=[self removeStandardSettingsFromPreference:[self preferences] ];
	NSSavePanel *savePanel=[NSSavePanel savePanel];
	[savePanel setCanCreateDirectories:YES];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"mpTpl"]];
	[savePanel setTitle:@"Save template"];
	
  [savePanel beginSheetModalForWindow:[self getWindow] 
                              completionHandler: ^( NSInteger resultCode )
	{
		@autoreleasepool
		{
			if( resultCode ==NSOKButton )
				[trimmedPrefs writeToURL:[savePanel URL] atomically:YES ];
			}
		}
  ];

}

//---------------------------------------------------------------------
// cancelButton
//---------------------------------------------------------------------
-(IBAction) cancelButton: (id)sender
{
	[[NSApplication sharedApplication] endSheet: [self getWindow] returnCode:NSCancelButton];
}

//---------------------------------------------------------------------
// okButton
//---------------------------------------------------------------------
-(IBAction) okButton:(id)sender
{
	[self retrivePreferences];
	[self writeDefaultPreferences];
	[[NSApplication sharedApplication] endSheet: [self getWindow] returnCode:NSOKButton];
}

//---------------------------------------------------------------------
// writeDefaultPreferences
//---------------------------------------------------------------------
-(void) writeDefaultPreferences
{
	//only store settings if we are at the base,
	//not when called from another template
	if ( [[self caller]isMemberOfClass:[SceneDocument class]])
	{
		NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
		NSString *defaultPreferencesName=[NSString stringWithUTF8String:templateTypeNameArray[mTemplateType]];
		defaultPreferencesName=[defaultPreferencesName stringByAppendingString:@"DefaultSettings"];
		id trimmedPrefs=[self removeStandardSettingsFromPreference:[self preferences] ];
//		NSLog(@"\n%@",trimmedPrefs);
		[defaults  setObject:trimmedPrefs forKey:defaultPreferencesName];
		[defaults synchronize];
	}
}
//---------------------------------------------------------------------
// setPreferences
//---------------------------------------------------------------------
-(void) setPreferences:(id) preferences
{
	[mPreferences release];
	mPreferences=preferences;
	[mPreferences retain];
	
	// now make sure that all keys are available
	// to do this, compare the dictionary we store
	// with a fresh default settings dictionary
	// if a key is missing, just add it
	[BaseTemplate addMissingObjectsInPreferences:preferences forClass:[self class] andTemplateType:mTemplateType];
}

//---------------------------------------------------------------------
// addMissingObjectsInPreferences: forClass: andTamplateType
//---------------------------------------------------------------------
// compare the default preferences for class _Class (Finischtemplate, objecttemplate,..)
// add every missing preference in the dict 'preferences'
// Missing entries will get a default value.
// best to call this before putting preferences in the panel of
// creating the description to put in the source file.
//---------------------------------------------------------------------

+(id) addMissingObjectsInPreferences:(id)preferences forClass:(Class)_Class andTemplateType:(unsigned int)templateType
{
	if ( preferences!=nil)
	{
		NSMutableDictionary *dict=[_Class createDefaults:templateType];
		if ( dict ==nil)
			return preferences;

		NSEnumerator *en = [dict keyEnumerator];
		id key;
		while ( (key = [en nextObject]) != nil ) 
		{
			if ( [preferences objectForKey:key] ==nil)
			{
				[preferences setObject:[dict objectForKey:key] forKey:key];
			}	
		}
	}
	return preferences;
}

//---------------------------------------------------------------------
// preferences
//---------------------------------------------------------------------
-(NSMutableDictionary*) preferences
{
	return mPreferences;
}

//---------------------------------------------------------------------
// getWindow
//---------------------------------------------------------------------
-(NSPanel*) getWindow
{
	return mWindow;
}

//---------------------------------------------------------------------
// setWindow
//---------------------------------------------------------------------
-(void) setWindow:(id)window
{
	// don't release the window,
	// when the owner is released it will be freed
	// if we do it now, some objects will be missing
	// if pigment, normal, .. is used in material editor
//	[mWindow release];	
	mWindow=window;
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
// method for subclasses.
// used for setting controls according to the state of other controls
// like boxgroups etc..
//---------------------------------------------------------------------
-(void) updateControls
{
}

//---------------------------------------------------------------------
// acceptsPreferences
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[[self getWindow]makeFirstResponder: [self getWindow]];
	if  ( mOutlets ==nil)
		return;
		
	NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
	if ( dict ==nil)
		return;

	NSEnumerator *en = [mOutlets keyEnumerator];
	id key;
	id outlet, anObject;
	while ( (key = [en nextObject]) != nil) 
	{
		outlet=[mOutlets objectForKey:key];
		if ( [outlet isMemberOfClass:[NSButton class]])
		{
			anObject=[NSNumber numberWithInteger:[outlet state]];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSTextView class]])
		{
			anObject=[outlet string];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSTextField class]])
		{
			anObject=[outlet stringValue];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSTextFieldCell class]])
		{
			anObject=[outlet stringValue];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSButtonCell class]])
		{
			anObject=[NSNumber numberWithInteger:[outlet state]];
			[dict setObject:anObject forKey:key];
		}
		//color***************************************************************************
		
		else if ( [outlet isMemberOfClass:[MPColorWell class]])
		{
			anObject=	[NSArchiver archivedDataWithRootObject:outlet];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[MPFTColorWell class]])
		{
			anObject=	[NSArchiver archivedDataWithRootObject:outlet];
			[dict setObject:anObject forKey:key];
		}

		else if ( [outlet isMemberOfClass:[NSColorWell class]])
		{
			anObject=	[NSArchiver archivedDataWithRootObject:[outlet color]];
			[dict setObject:anObject forKey:key];
		}

		//end color***************************************************************************

		else if ( [outlet isMemberOfClass:[NSPopUpButton class]])
		{
			anObject=[NSNumber numberWithInteger:[outlet indexOfSelectedItem]];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSMatrix class]])
		{
			anObject=[NSNumber numberWithInteger:[[outlet selectedCell]tag]];
			[dict setObject:anObject forKey:key];
		}
		else if ( [outlet isMemberOfClass:[NSTabView class]])
		{
			anObject=	[NSNumber numberWithInteger:[outlet indexOfTabViewItem:[outlet selectedTabViewItem]]];
			[dict setObject:anObject forKey:key];
		}
	}	

	[self setPreferences:dict];
	[dict release];

}

//---------------------------------------------------------------------
// removeStandardSettingsFromPreference:preferences
//---------------------------------------------------------------------
// returns a mutable copy of the preferences but
// removes all settings from the dictionary that are equal to
// the standard settings.
// this reduces the file when saved.
// the key @"dictionaryType" is also added to identify the 
// settings file later
// function should be called before a dictionary is saved
//---------------------------------------------------------------------

-(NSMutableDictionary*) removeStandardSettingsFromPreference:(NSMutableDictionary*) inPreferences;
{
	id preferences=nil;
	if ( inPreferences!=nil)
	{
//		preferences=[NSUnarchiver unarchiveObjectWithData:[NSArchiver archivedDataWithRootObject:inPreferences]];
		preferences=[[inPreferences mutableCopy]autorelease];
		
		NSMutableDictionary *defaultsPreferencesDict=[[self class] createDefaults:mTemplateType];
		if ( defaultsPreferencesDict ==nil)
			return preferences;

		NSEnumerator *defaultsEnumerator = [defaultsPreferencesDict keyEnumerator];
		id defaultsKey;
		while ( (defaultsKey = [defaultsEnumerator nextObject]) != nil ) 
		{
//			NSLog(@"trimming key: %@",defaultsKey);
			id preferencesObject=[preferences objectForKey:defaultsKey] ;
			if ( preferencesObject !=nil)
			{
				id defaultsObject=[defaultsPreferencesDict objectForKey:defaultsKey];
				//******************
				if ( [preferencesObject isKindOfClass:[NSNumber class]])
				{
				
					if ( [defaultsObject floatValue] == [preferencesObject floatValue])
					{
//						NSLog(@"removed float: %@ default:%f prefs:%f", defaultsKey ,[defaultsObject floatValue], [preferencesObject floatValue]);
						[preferences removeObjectForKey:defaultsKey];
					}
				}
				//****************
				else if ( [preferencesObject isKindOfClass:[NSString class]])
				{
				
					if ( [defaultsObject isEqualToString:preferencesObject])
					{
//						NSLog(@"removed string: %@ default:%@ prefs:%@", defaultsKey ,defaultsObject , preferencesObject);
						[preferences removeObjectForKey:defaultsKey];
					}
				}
				//****************
				else if ( [preferencesObject isKindOfClass:[NSData class]])
				{
					id dataPreferences=[NSUnarchiver unarchiveObjectWithData:preferencesObject] ;
					id dataDefault=[NSUnarchiver unarchiveObjectWithData:defaultsObject];
					if ( [dataPreferences isMemberOfClass:[MPFTColorWell class]] || [dataPreferences isMemberOfClass:[MPColorWell class]])
					{
						if ( [dataPreferences equals:dataDefault])
						{
//							NSLog(@"removed colorwell");
							[preferences removeObjectForKey:defaultsKey];
						}					
					}
					else if ( [defaultsObject isEqualToData:preferencesObject])
					{
//						NSLog(@"removed data: %@ default:%@ prefs:%@", defaultsKey ,defaultsObject , preferencesObject);
						[preferences removeObjectForKey:defaultsKey];
					}
				}

			}
		}
	}
	[preferences setObject:[self dictionaryTypeName] forKey:@"dictionaryTypeDefaults"];
	return preferences;
}

//---------------------------------------------------------------------
// dictionaryTypeName:
//---------------------------------------------------------------------
// returns a string for the key @"dictionaryTypeDefaults" for the dictionary 
// when saving
//---------------------------------------------------------------------
-(NSString *) dictionaryTypeName
{
	NSString *dictionaryTypeDefaults=NSStringFromClass([self class]);
	if ( [self isMemberOfClass:[BodymapTemplate class]])
	{
		switch (mTemplateType)
		{
			case menuTagTemplateDensitymap: dictionaryTypeDefaults=@"DensitymapTemplate";		break;
			case menuTagTemplatePigmentmap: dictionaryTypeDefaults= @"PigmentmapTemplate";	break;
			case menuTagTemplateNormalmap: dictionaryTypeDefaults= @"NormalmapTemplate";		break;
			case menuTagTemplateTexturemap: dictionaryTypeDefaults= @"TexturemapTemplate";	break;
			default: dictionaryTypeDefaults=@"BodymapTemplate"; break;
		}
	}
	else if ( [self isMemberOfClass:[ObjectEditorTemplate class]])
	{
		switch (mTemplateType)
		{
			case menuTagTemplateLathe: 	dictionaryTypeDefaults=@"LatheTemplate";		break;
			case menuTagTemplatePolygon:  dictionaryTypeDefaults= @"PolygonTemplate";	break;
			case menuTagTemplatePrism:		dictionaryTypeDefaults= @"PrismTemplate";		break;
			case menuTagTemplateSor: 		 dictionaryTypeDefaults= @"SorTemplate";	break;
			default: dictionaryTypeDefaults=@"objectEditorTemplate"; break;
		}
	}
	if ( dictionaryTypeDefaults ==nil)
		dictionaryTypeDefaults=@"empty";
		
	return dictionaryTypeDefaults;
}

//---------------------------------------------------------------------
// setValuesInPanel:preferences
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	if ( preferences==nil)
		return;
		
	NSEnumerator *en = [mOutlets keyEnumerator];
	id key;
	id outlet, anObject;
	BOOL found=NO;
	while ((key = [en nextObject]) != nil) 
	{
		found=NO;
		anObject=[preferences objectForKey:key];
		// in case of a reset to default, some object
		// might be missing (like popupbuttons for views,..
		// just skip
		if ( anObject != nil)
		{
			outlet=[mOutlets objectForKey:key];
			if ( outlet != nil)
			{
			//NSLog(@"key: %@ object:%@ class:%@",key,anObject,[anObject class]);
				if ( [outlet isMemberOfClass:[NSButton class]])
				{
					[outlet setState:[anObject intValue]]; 
					found=YES;
				}
				else if ( [outlet isMemberOfClass:[NSTextView class]])
				{
					[outlet setString:anObject];
					found=YES;
				}
				else if ( [outlet isMemberOfClass:[NSTextField class]])
				{
					[outlet setStringValue:anObject];
					found=YES;
				}
				else if ( [outlet isMemberOfClass:[NSTextFieldCell class]])
				{
					[outlet setStringValue:anObject];
					found=YES;
				}	
				else if ( [outlet isMemberOfClass:[NSButtonCell class]])
				{
					[outlet setIntValue:[anObject intValue]];
					found=YES;
				} 
				//color***************************************************************************
				else if ( [outlet isMemberOfClass:[MPColorWell class]])
				{
					id unarchivedObject=[NSUnarchiver unarchiveObjectWithData:anObject];
					if ( [unarchivedObject isKindOfClass:[NSColor class]])
					{
						[outlet setColor:unarchivedObject];
						[outlet setHasFilterTransmit:NO];
					}
					else
					{
						[outlet setColor:[unarchivedObject color]];
						[outlet setHasFilterTransmit:NO];
					}
					found=YES;
				}
				else if ( [outlet isMemberOfClass:[MPFTColorWell class]])
				{
					id unarchivedObject=[NSUnarchiver unarchiveObjectWithData:anObject];
					if ( [unarchivedObject isKindOfClass:[NSColor class]])
					{
						[outlet setColor:unarchivedObject];
						[outlet setHasFilterTransmit:YES];
						[outlet setFilter:0.0 toState:NSOffState andTransmit:0.0 toState:NSOffState];
						[outlet setGrayOn: NSOffState];
					}
					else
					{
						[outlet setColor:[unarchivedObject color]];
						[outlet setFilter:[unarchivedObject filter] toState:[unarchivedObject filterOn] 
									andTransmit:[unarchivedObject transmit] toState:[unarchivedObject transmitOn]];
						[outlet setGrayOn: [unarchivedObject grayOn]];
					}
					found=YES;
				}

				else if ( [outlet isMemberOfClass:[NSColorWell class]])
				{
					[outlet setColor:[NSUnarchiver unarchiveObjectWithData:anObject]];
					found=YES;
				}
				//end color***************************************************************************
				else if ( [outlet isMemberOfClass:[NSPopUpButton class]])
				{
					NSInteger val=[anObject intValue];
					NSInteger maxItems=[outlet numberOfItems];
//					NSLog(@"Setting item: %@ with value: %d max items is: %d",key, val, maxItems	);
					if ( val >maxItems-1 )
						[outlet  selectItemAtIndex:0];
					else
					[outlet  selectItemAtIndex:val];
				found=YES;
				}
				else if ( [outlet isMemberOfClass:[NSMatrix class]])
				{
					[outlet  selectCellWithTag:[anObject intValue]];
					found=YES;
				}
				else if ( [outlet isMemberOfClass:[NSTabView class]])
				{
					[outlet  selectTabViewItemAtIndex:[anObject intValue]];
					found=YES;
				}
				if (found==NO)
					NSLog(@"%@ not found",(NSString*)key);
			}//outlet != nil
		}//anObject != nil
	}	
	[self updateControls];
}


//---------------------------------------------------------------------
// enableObjectsAccordingToObject
//---------------------------------------------------------------------
//	if referenceObject is enabled and the state is NSOnState
// each object that responds to setEnabled will be turnded on or off
// according to the state of the referenceObject
//	In case of a NSMatrix, no need to add all the cells, a NSMatrix
//	will be scanned for all cells
//---------------------------------------------------------------------
- (void) enableObjectsAccordingToObject:(id) referenceObject, ...
{
	int enabling=NO;
	id nextObject;
	va_list argumentList;
	//if the reference object isn't enabled,
	// no need to check further, disable all other objects as well
	if([referenceObject respondsToSelector:@selector(isEnabled)] && [referenceObject isEnabled]==NO)	// if the reference object isn't enabled and on 
		enabling=NO;
	else	//if the reference object is enabled, check the state and set other objects according to this state.
	{
		if([referenceObject respondsToSelector:@selector(state)] && [referenceObject state]==NSOnState)
			enabling=YES;
		else if([referenceObject respondsToSelector:@selector(intValue)] && [referenceObject intValue]==NSOnState)
			enabling=YES;
	}

	va_start(argumentList, referenceObject);          // Start scanning for arguments after firstObject.
		
	while ((nextObject = va_arg(argumentList, id)) !=nil) // As many times as we can get an argument of type "id"
	{
		if ( [nextObject isKindOfClass:[NSMatrix class]])	//all cells will be set
		{
			NSArray *matrixObject=[nextObject cells];
			NSEnumerator *en=[matrixObject objectEnumerator];
			id objectFromMatrix;
			while ( (objectFromMatrix =[en nextObject] )!= nil)
			{
				if( [objectFromMatrix respondsToSelector:@selector(setEnabled:)])
				{
					if( [objectFromMatrix respondsToSelector:@selector(stringValue)])
						[objectFromMatrix stringValue];// force validation if control is bein edited at this time
					else if( [objectFromMatrix respondsToSelector:@selector(intValue)])
						[objectFromMatrix intValue];
					[objectFromMatrix setEnabled:enabling];               // that isn't nil, add it to self's contents.
				}
			}
		}
		else
		{
			if ( [nextObject isKindOfClass:[NSTextField class]] && [nextObject isEditable]==NO)
			{
				if ( [nextObject respondsToSelector:@selector(setTextColor:)])
			 	{
					if ( enabling==NSOnState)
						[nextObject setTextColor:[NSColor controlTextColor]];
					else
						[nextObject setTextColor:[NSColor disabledControlTextColor]];
				}			
			} 
			else if ( [nextObject respondsToSelector:@selector(setEnabled:)])
			{
				if( [nextObject respondsToSelector:@selector(stringValue)])
					[nextObject stringValue];// force validation if control is bein edited at this time
				else if( [nextObject respondsToSelector:@selector(intValue)])
					[nextObject intValue];
				[nextObject setEnabled:enabling];
			}
		}
	}
	va_end(argumentList);
}

//---------------------------------------------------------------------
// enableObjectsAccordingToState
//---------------------------------------------------------------------
//	if  the state is NSOnState
// each object that responds to setEnabled will be turnded on or off
// according to the state 
//	In case of a NSMatrix, no need to add all the cells, a NSMatrix
//	will be scanned for all cells
//---------------------------------------------------------------------
- (void) enableObjectsAccordingToState:(int)state, ...
{
	id nextObject;
	va_list argumentList;
	int enabling=NO;
	if( state == NSOnState)
		enabling=YES;
		
	
	va_start(argumentList, state);          // Start scanning for arguments after firstObject.
		
	while ((nextObject = va_arg(argumentList, id)) != nil) // As many times as we can get an argument of type "id"
	{
		if ( [nextObject isKindOfClass:[NSMatrix class]])	//all cells will be set
		{
			NSArray *matrixObject=[nextObject cells];
			NSEnumerator *en=[matrixObject objectEnumerator];
			id objectFromMatrix;
			while ( (objectFromMatrix =[en nextObject] )!= nil)
			{
				if( [objectFromMatrix respondsToSelector:@selector(setEnabled:)])
					[objectFromMatrix setEnabled:enabling];               // that isn't nil, add it to self's contents.
			}
		}
		else
		{
			if ( [nextObject isKindOfClass:[NSTextField class]] && [nextObject isEditable]==NO)
			{
				if ( [nextObject respondsToSelector:@selector(setTextColor:)])
			 	{
					if ( enabling==NSOnState)
						[nextObject setTextColor:[NSColor controlTextColor]];
					else
						[nextObject setTextColor:[NSColor disabledControlTextColor]];
				}			
			}
			else if ( [nextObject respondsToSelector:@selector(setEnabled:)])
			{
				[nextObject setEnabled:enabling];
			}
		}
	}
	va_end(argumentList);
}

//---------------------------------------------------------------------
// enableObjectsAccordingToObject
//---------------------------------------------------------------------
//	if referenceObject responds to selector state
// each object that responds to setEnabled will be turnded on or off
// according to the state of the referenceObject
//	In case of a NSMatrix, no need to add all the cells, a NSMatrix
//	will be scanned for all cells
//---------------------------------------------------------------------
- (void) setXYZVectorAccordingToPopup:(NSPopUpButton*) popup xyzMatrix: (NSMatrix*)xyzMatrix 
{
	if ( [popup isEnabled]==NO)
		[self enableObjectsAccordingToObject:[NSNumber numberWithInt:NSOffState], 
			xyzMatrix, nil];
	else
	{
		// force update of field in case it is bein edited
		[[xyzMatrix cellWithTag:0] stringValue];
		[[xyzMatrix cellWithTag:1] stringValue];
		[[xyzMatrix cellWithTag:2] stringValue];
		switch([popup indexOfSelectedItem])
		{
			case cXYZVectorPopupXisYisZ:
			case cXYZVectorPopupX:
				[[xyzMatrix cellWithTag:0] setEnabled:YES];
				[[xyzMatrix cellWithTag:1] setEnabled:NO];
				[[xyzMatrix cellWithTag:2] setEnabled:NO];
				break;
			case cXYZVectorPopupY:
				[[xyzMatrix cellWithTag:0] setEnabled:NO];
				[[xyzMatrix cellWithTag:1] setEnabled:YES];
				[[xyzMatrix cellWithTag:2] setEnabled:NO];
				break;
			case cXYZVectorPopupZ:
				[[xyzMatrix cellWithTag:0] setEnabled:NO];
				[[xyzMatrix cellWithTag:1] setEnabled:NO];
				[[xyzMatrix cellWithTag:2] setEnabled:YES];
				break;
			case cXYZVectorPopupXandYandZ:
				[[xyzMatrix cellWithTag:0] setEnabled:YES];
				[[xyzMatrix cellWithTag:1] setEnabled:YES];
				[[xyzMatrix cellWithTag:2] setEnabled:YES];
				break;
		}
	}
}

//----------------------------------------------------------------------
//	setSubViewsOfNSBox
//----------------------------------------------------------------------
//	Set all subviews of an NSBox to the state of button
//	Note that the array of subviews for NSBox is only one NSView
//	The subviews of that view are the 'real' subviews of an NSBox
//----------------------------------------------------------------------

-(void) setSubViewsOfNSBox:( NSBox *) group toNSButton:(NSButton*)button
{
	int newState=[button state];
	if ( [button isEnabled]==NO)	// enabled is also off and all other object should be disabled too
		newState=NSOffState;

	SetSubViewsOfNSBoxToState(group, newState);
}

//----------------------------------------------------------------------
//	setSubViewsOfNSBoxToButtonState
//----------------------------------------------------------------------
//	Set all subviews of an NSBox to the state of button
//	Note that the array of subviews for NSBox is only one NSView
//	The subviews of that view are the 'real' subviews of an NSBox
//----------------------------------------------------------------------

-(void) setSubViewsOfNSBoxReverse:( NSBox *) group toNSButton:(NSButton*)button
{
	NSControlStateValue newState=[button state];
	if ( newState==NSOnState)
		newState=NSOffState;
	else
		newState=NSOnState;
		
	if ( [button isEnabled]==NO)	// enabled is also off and all other object should be disabled too
		newState=NSOffState;

	SetSubViewsOfNSBoxToState(group, newState);
}
//----------------------------------------------------------------------
//	useIndexFromPopup:toSetIndexOfTabView
//----------------------------------------------------------------------
//	select the tabview item according to the 
// selected item in the popupbutton
//----------------------------------------------------------------------
-(void) setTabView: (NSTabView *) tabView toIndexOfPopup:(NSPopUpButton* ) popup
{
	NSInteger item=[popup indexOfSelectedItem];
	[tabView selectTabViewItemAtIndex:item];
}

//----------------------------------------------------------------------
//	enableDisableItemInSuperview:forString:andState
//----------------------------------------------------------------------
//	search for an NSTextField which isn't editable
// disable/enable it according to the newState
// make sure that item is near the control and to the right
//----------------------------------------------------------------------
-(void) enableDisableItemInSuperview:(NSControl*) controlItem forString:searchString andState:(int)newState
{
	NSView *superView=[controlItem superview];
	NSArray *subviewArray=[superView subviews];
	NSRect controlRect=[controlItem frame];
	
	for (unsigned int x=0; x<[subviewArray count]; x++)
	{ 
		id subview=[subviewArray objectAtIndex:x];
			
		if ( [subview isKindOfClass:[NSTextField class]] && [subview isEditable]==NO)
		{
			if ( [subview respondsToSelector:@selector(stringValue)])
		 	{

		 		if ( [[subview stringValue] compare:@"*"]==NSOrderedSame)
		 		{
		 			NSRect itemRect=[subview frame];
		 			if ( (itemRect.origin.y >= controlRect.origin.y) && ( itemRect.origin.y <=controlRect.origin.y+controlRect.size.height))
			 		{
			 			if ( (itemRect.origin.x >= controlRect.origin.x) && ( itemRect.origin.x <=controlRect.origin.x+(controlRect.size.width+20)))
						{
							if ( newState==NSOnState)
								[subview setTextColor:[NSColor controlTextColor]];
							else
								[subview setTextColor:[NSColor disabledControlTextColor]];
						}
					}
				}
			}			
		} 
	}	
}

//----------------------------------------------------------------------
//	setModified
//----------------------------------------------------------------------
-(IBAction) setModified:(id) sender
{
	mModified=YES;
}

//----------------------------------------------------------------------
//	setNotModified
//----------------------------------------------------------------------
-(void)setNotModified
{
	mModified=NO;
}

//----------------------------------------------------------------------
//	modified
//----------------------------------------------------------------------
-(unsigned) modified:(id) sender
{
	return mModified;
}

//---------------------------------------------------------------------
// selectFile:withTypes
//---------------------------------------------------------------------
- (void) selectFile:(id)fileName withTypes:(NSArray*)fileTypes keepFullPath:(BOOL)keepFullPath
{
	NSOpenPanel *openPanel=[NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setCanChooseDirectories:NO];
	[openPanel setCanChooseFiles:YES];
	[openPanel setAllowedFileTypes:fileTypes];
	
  [openPanel beginSheetModalForWindow:[self getWindow]
										completionHandler: ^( NSInteger resultCode )
	 {
			@autoreleasepool
			{
			 if( resultCode ==NSOKButton )
			 {
				 if ( keepFullPath==YES)
					 [fileName setStringValue:[[openPanel URL]path]];
				 else
					 [fileName setStringValue:[[[openPanel URL]path] lastPathComponent]];
			 }
			}
	 }
	 ];
}

@end

@implementation BaseTemplate (callTemplates)

//---------------------------------------------------------------------
// setT1:objc
//---------------------------------------------------------------------
-(void) setTemplatePrefs:(int)number withObject:(id)objc
{
	[mTemplatePrefs[number] release];
			mTemplatePrefs[number]=[objc mutableCopy];	
	[mTemplatePrefs[number] retain];
}


//---------------------------------------------------------------------
// callTemplate:withDictionary:forKey
//---------------------------------------------------------------------
- (void) callTemplate:(int)templateNumber 	withDictionary:(NSMutableDictionary*) dict andKeyName:(NSString*) key
{
	[SceneDocument displayTemplateNumber:templateNumber 
							fileowner:mFileOwner
							caller:self 
							dictionary:dict];
	[self setKeyName:key];
}

//---------------------------------------------------------------------
// displayColorPicker:magicNumber
//---------------------------------------------------------------------
-(void) displayColorPicker:(id)sender
{
	colorPickerController=[[ColorPicker alloc] initWithDelegate:sender];

	if ( colorPickerController != nil)
	{
		if ( [NSBundle loadNibNamed:@"ColorPicker.nib" owner:colorPickerController] == YES)
		{
			[[NSApplication sharedApplication] beginSheet:[colorPickerController getWindow] 
				modalForWindow:[self getWindow] modalDelegate:self 
				didEndSelector:@selector(colorPickerSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
		}
		else
		{
			[colorPickerController release];
			colorPickerController=nil;
		}
	}	
}
//---------------------------------------------------------------------
// colorPickerSheetDidEnd
//---------------------------------------------------------------------
-(void) colorPickerSheetDidEnd: (NSWindow*)sheet returnCode: (int)returnCode contextInfo: (void*)contextInfo
{
	if ( returnCode ==NSOKButton)
	{
	}
	[sheet orderOut: nil];
	[colorPickerController release];
	colorPickerController=nil;
}

@end


//--------------------------------------------------------------------

#import "pigmentTemplate.h"
#import "normalTemplate.h"
#import "FunctionTemplate.h"
#import "ColorMapTemplate.h"

//--------------------------------------------------------------------
// WriteColormap
//--------------------------------------------------------------------
void WriteColormap(MutableTabString *ds,NSDictionary *dict, NSString *colomapTab)
{
	switch ( [[dict objectForKey:colomapTab]intValue])
	{
		case cBlackAndWhite:
			[ColormapTemplate createDescriptionWithDictionary:
				[NSMutableDictionary dictionaryWithObject:[dict objectForKey:@"blackAndWhiteColorMap"]
					forKey:@"colormap"] andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds] ;
			break;
		case cRainBow:
			[ColormapTemplate createDescriptionWithDictionary:
				[NSMutableDictionary dictionaryWithObject:[dict objectForKey:@"rainbowColorMap"]
					forKey:@"colormap"] andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			break;
		case cCustomized:
			[ColormapTemplate createDescriptionWithDictionary:[dict objectForKey:@"customizedColorMap"]
					 andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			break;
		case cBodyMap:
			[BodymapTemplate createDescriptionWithDictionary:
				[dict objectForKey:@"pigmentColorMapEditPigmentMap"]
					 andTabs:[ds currentTabs] extraParam:menuTagTemplatePigmentmap mutableTabString:ds];
			break;
	}
}

//--------------------------------------------------------------------
// AddWavesTypeFromPopup
//--------------------------------------------------------------------
void AddWavesTypeFromPopup(MutableTabString *ds,NSDictionary *dict, NSString *popUp, NSString *polyEdit)
{					

	switch ( [[dict objectForKey:popUp]intValue])
	{
		case cDefault:
			break;
		case cCubicWave:
			[ds copyTabAndText:@"cubic_wave\n"];		break;
		case cPolyWave:
			[ds appendTabAndFormat:@"poly_wave %@\n",[dict objectForKey:polyEdit]];
			break;
		case cRampWave:
			[ds copyTabAndText:@"ramp_wave\n"];		break;
		case cScallopWave:
			[ds copyTabAndText:@"scallop_wave\n"];		break;
		case cSineWave:
			[ds copyTabAndText:@"sine_wave\n"];			break;
		case cTriangleWave:
			[ds copyTabAndText:@"triangle_wave\n"];	break;
	}
}

//--------------------------------------------------------------------
// WriteNormal
//--------------------------------------------------------------------
void WriteNormal(int keyword, MutableTabString *ds,NSDictionary *dict, BOOL writePattern)
{
	NSMutableDictionary *theDict=nil;
	
	if ( dict==nil)
		theDict=[NormalTemplate createDefaults:menuTagTemplateNormal];
	else
		theDict=[[dict mutableCopy]autorelease];

	if( keyword==cForceDontWrite)	//only change if we have to force don't write
		[theDict setObject:[NSNumber numberWithInt:NSOnState] forKey:@"normalDontWrapInPigment"];
	else if( keyword==cForceWrite)	//only change if we have to force don't write
		[theDict setObject:[NSNumber numberWithInt:NSOffState] forKey:@"normalDontWrapInPigment"];

	[NormalTemplate createDescriptionWithDictionary:theDict andTabs:[ds currentTabs]extraParam:writePattern  mutableTabString:ds];

}

//--------------------------------------------------------------------
// WritePigment
//--------------------------------------------------------------------
void WritePigment(int keyword, MutableTabString *ds,NSDictionary *dict, BOOL writePattern)
{
	NSMutableDictionary *theDict=nil;
	
	if ( dict==nil)
		theDict=[PigmentTemplate createDefaults:menuTagTemplatePigment];
	else
		theDict=[[dict mutableCopy]autorelease];

	if( keyword==cForceDontWrite)	//only change if we have to force don't write
		[theDict setObject:[NSNumber numberWithInt:NSOnState] forKey:@"pigmentDontWrapInPigment"];
	else if( keyword==cForceWrite)	//only change if we have to force don't write
		[theDict setObject:[NSNumber numberWithInt:NSOffState] forKey:@"pigmentDontWrapInPigment"];

	[PigmentTemplate createDescriptionWithDictionary:theDict andTabs:[ds currentTabs]extraParam:writePattern mutableTabString:ds];

}
 
//--------------------------------------------------------------------
// WritePatternPanel
//--------------------------------------------------------------------
void WritePatternPanel(MutableTabString *ds,NSDictionary *dict, NSString *FileTypePop, 
								NSString * PatternImageWidth, NSString *PatternImageHeightt,
								NSString *FunctionEdit, NSString *PatternPigment,
								NSString *PigmentPigment, NSString *FileEdit)
{
	BOOL WriteFileName=YES;
	[ds addTab];
	[ds copyTabText];
	switch ([[dict objectForKey:FileTypePop]intValue])
	{
		case cGif:	[ds copyText:@"gif "];		break;
		case cHdr:	[ds copyText:@"hdr "];	break;
		case cJpeg:	[ds copyText:@"jpeg "];	break;
		case cPgm:	[ds copyText:@"pgm "];	break;
		case cPng:	[ds copyText:@"png "];	break;
		case cPot:	[ds copyText:@"pot "];	break;
		case cPpm:	[ds copyText:@"ppm "];	break;
		case cSys:	[ds copyText:@"sys "];		break;
		case cTga:	[ds copyText:@"tga "];		break;
		case cTiff:	[ds copyText:@"tiff "];
			break;

		case cFunctionImage:	//function
			WriteFileName=NO;
			[ds appendFormat:@"function %@, %@ ", [dict objectForKey:PatternImageWidth], [dict objectForKey:PatternImageHeightt]];
			[ds copyText:@" {\n"];
			[ds addTab];
			[ds copyTabAndText:[dict objectForKey:FunctionEdit]];
			[ds copyText:@"\n"];
			
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;

		case cPatternImage:	//pattern image
			WriteFileName=NO;
			[ds appendFormat:@"function %@, %@ ", [dict objectForKey:PatternImageWidth], [dict objectForKey:PatternImageHeightt]];
			[ds copyText:@" {\n"];
				[ds addTab];
				[ds copyTabAndText:@"pattern {\n"];
					[ds addTab];
					WritePigment(cForceDontWrite, ds,[dict objectForKey:PatternPigment] ,YES );
				[ds removeTab];
				[ds copyTabAndText:@"}\n"];
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			
			break;
		case cPigmentImage:	//pigment image
			WriteFileName=NO;
			[ds appendFormat:@"function %@, %@ ", [dict objectForKey:PatternImageWidth], [dict objectForKey:PatternImageHeightt]];
			[ds copyText:@" {\n"];
			[ds addTab];
			WritePigment(cForceWrite, ds, [dict objectForKey:PigmentPigment] ,NO);
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			
			break;
	}
	if ( WriteFileName ==YES)
		[ds appendFormat:@"\"%@\"\n" , [dict objectForKey:FileEdit]];
}	
void WriteIsoBounding(MutableTabString *ds,NSDictionary *dict, NSString *clipPopUp, 
								NSString *corner1X, NSString *corner1Y, NSString *corner1Z,
								NSString *corner2X, NSString *corner2Y, NSString *corner2Z,
								NSString *centerX, NSString *centerY, NSString *centerZ,
								NSString *radius)
{
	[ds copyTabAndText:@"contained_by {\n"];
	[ds addTab];
	switch  ( [[dict objectForKey:clipPopUp]intValue])
	{
		case cBoxContainer:
			[ds copyTabAndText:@"box { "];
				[ds appendTabAndFormat:@"<%@, %@, %@>, ",[dict objectForKey:corner1X],
																					[dict objectForKey:corner1Y],
																					[dict objectForKey:corner1Z]];
				[ds appendTabAndFormat:@"<%@, %@, %@> ",[dict objectForKey:corner2X],
																					[dict objectForKey:corner2Y],
																					[dict objectForKey:corner2Z]];
			break;
		case cSphereContainer:
			[ds copyTabAndText:@"sphere { "];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@ ",[dict objectForKey:centerX],
																					[dict objectForKey:centerY],
																					[dict objectForKey:centerZ],
																					[dict objectForKey:radius]];
			break;
	}
	[ds copyTabAndText:@"} \n"];
		
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
}
							
void WriteShowContainingObject(MutableTabString *ds,NSDictionary *dict, NSString *clipPopUp, 
								NSString *corner1X, NSString *corner1Y, NSString *corner1Z,
								NSString *corner2X, NSString *corner2Y, NSString *corner2Z,
								NSString *centerX, NSString *centerY, NSString *centerZ,
								NSString *radius)
{
	switch  ( [[dict objectForKey:clipPopUp]intValue])
	{
		case cBoxContainer:
			[ds copyTabAndText:@"box {\n"];
			[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@, %@>, ",[dict objectForKey:corner1X],
																					[dict objectForKey:corner1Y],
																					[dict objectForKey:corner1Z]];
				[ds appendTabAndFormat:@"<%@, %@, %@>\n",[dict objectForKey:corner2X],
																					[dict objectForKey:corner2Y],
																					[dict objectForKey:corner2Z]];
			break;
		case cSphereContainer:
			[ds copyTabAndText:@"sphere { "];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@\n",[dict objectForKey:centerX],
																					[dict objectForKey:centerY],
																					[dict objectForKey:centerZ],
																					[dict objectForKey:radius]];
			break;
	}
	[ds copyTabAndText:@"pigment { rgbt <1.0, 0.05, 0.3, 0.9> }\n"];
	[ds removeTab];
	[ds copyTabAndText:@"}\n"];

}
