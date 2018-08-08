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
#import "cameraTemplate.h"
#import "functionTemplate.h"
#import "pigmentTemplate.h"
#import "standardMethods.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation CameraTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(NSInteger) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{
	if ( dict== nil)
	{
		dict=[CameraTemplate createDefaults:menuTagTemplateCamera];
	}
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[CameraTemplate class] andTemplateType:menuTagTemplateCamera];
	[dict retain];
	
	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
		{
			[dict release];
			return nil;
			
		}
	}
	
	
	
	if ( param==NO)		//don't write keyword if used as pigment camera_view
	{
		[ds copyTabAndText:@"camera {\n"];
		[ds addTab];
	}
	switch( [[dict objectForKey:@"cameraTabView"] intValue])
	{
		case cCameraPredefinedTab:
			//type
			switch ( [[dict objectForKey:@"cameraTypePopup"] intValue])
		{
			case cCameraTypePerspective:							[ds copyTabAndText:@"perspective \n"];											break;
			case cCameraTypeOrthoGraphic:							[ds copyTabAndText:@"orthographic \n"];											break;
			case cCameraTypeFisheye:									[ds copyTabAndText:@"fisheye \n"];													break;
			case cCameraTypeUltraWideAngle:						[ds copyTabAndText:@"ultra_wide_angle \n"];									break;
			case cCameraTypeOmnimax:									[ds copyTabAndText:@"omnimax \n"];													break;
			case cCameraTypePanoramic:								[ds copyTabAndText:@"panoramic \n"];												break;
			case cCameraTypeSpherical:								[ds copyTabAndText:@"spherical\n"];													break;
			case cCameraTypeCylinderVerticalFixed:		[ds copyTabAndText:@"cylinder 1 // vertical - fixed\n"]; 		break;
			case cCameraTypeCylinderHorizontalFixed:	[ds copyTabAndText:@"cylinder 2 // horizontal - fixed\n"]; 	break;
			case cCameraTypeCylinderVerticalMoving:		[ds copyTabAndText:@"cylinder 3 // vertical - moving\n"]; 	break;
			case cCameraTypeCylinderHorizontalMoving:	[ds copyTabAndText:@"cylinder 4 // horizontal - moving\n"]; break;
		}
			[ds copyTabText];
			
			//Location
			[ds appendFormat:@"location < %@, %@, %@>\n",[dict objectForKey:@"cameraLocationMatrixX"],
			 [dict objectForKey:@"cameraLocationMatrixY"],
			 [dict objectForKey:@"cameraLocationMatrixZ"]];
			
			//	sky
			if ( [[dict objectForKey:@"cameraSkyOn"] intValue]==NSOnState)
			{
				[ds copyTabText];
				[ds appendFormat:@"sky < %@, %@, %@>\n",[dict objectForKey:@"cameraSkyMatrixX"],
				 [dict objectForKey:@"cameraSkyMatrixY"],
				 [dict objectForKey:@"cameraSkyMatrixZ"]];
			}
			//	aspec
			
			if ( [[dict objectForKey:@"cameraAspectRatioGroupOn"] intValue]==NSOnState)
			{
				switch ([[dict objectForKey:@"cameraTypePopup"] intValue])
				{
					case cCameraTypePerspective:
					case cCameraTypeOmnimax:
						if ( [[dict objectForKey:@"cameraAspectRatioAutoOn"] intValue]==NSOnState)
						{
							[ds copyTabAndText:@"right x * image_width\n"];
							[ds copyTabAndText:@"up y * image_height\n"];
						}
						else
							[CameraTemplate writeAspectRatioBlockFromDict:dict toMutableTab:ds];
						break;
					case cCameraTypeOrthoGraphic:
					case cCameraTypeCylinderVerticalFixed:
					case cCameraTypeCylinderHorizontalFixed:
					case cCameraTypeCylinderVerticalMoving:
					case cCameraTypeCylinderHorizontalMoving:
						//					if ( [[dict objectForKey:@"cameraAspectRatioAutoOn"] intValue]==NSOffState)
						[CameraTemplate writeAspectRatioBlockFromDict:dict toMutableTab:ds];
						break;
					case cCameraTypeUltraWideAngle:
					case cCameraTypeFisheye:
					case cCameraTypePanoramic:
						if ( [[dict objectForKey:@"cameraAspectRatioAutoOn"] intValue]==NSOnState)
						{
							[ds copyTabAndText:@"right x * max(image_width/image_height,1)\n"];
							[ds copyTabAndText:@"up y * max(image_height/image_width,1)\n"];
						}
						else
							[CameraTemplate writeAspectRatioBlockFromDict:dict toMutableTab:ds];
						break;
						
				} //switch ([[dict objectForKey:@"cameraTypePopup"] intValue])
			} //if ( [[dict objectForKey:@"cameraAspectRatioGroupOn"] intValue]==NSOnState)
			
			
			//angle & direction
			if ( [[dict objectForKey:@"cameraAngleDirectionOn"] intValue] ==NSOnState)
			{
				if ( [[dict objectForKey:@"cameraTypePopup"] intValue] ==cCameraTypeSpherical)
				{
					[ds copyTabAndText:@"angle "];
					[ds appendFormat:@" %@",[dict objectForKey:@"cameraHorizontalAngleEdit"]];
					if ([[dict objectForKey:@"cameraVerticalAngleOn"] intValue] ==NSOnState)
						[ds appendFormat:@" , %@\n",[dict objectForKey:@"cameraVerticalAngleEdit"]];
					else
						[ds copyTabAndText:@"\n"];
				}
				else if ( [[dict objectForKey:@"cameraTypePopup"] intValue] !=cCameraTypeOrthoGraphic && [[dict objectForKey:@"cameraTypePopup"] intValue] !=cCameraTypeOmnimax)
				{
					if ( [[dict objectForKey:@"cameraAngleDirectionPopup"] intValue]==cCameraAngleDirectionPopupAngle)
						[ds appendTabAndFormat:@"angle %@\n",[dict objectForKey:@"cameraAngleAngleEdit"]];
					else
					{
						[ds appendTabAndFormat:@"direction < %@, %@, %@>\n",[dict objectForKey:@"cameraAngleDirectionMatrixX"],
						 [dict objectForKey:@"cameraAngleDirectionMatrixY"],
						 [dict objectForKey:@"cameraAngleDirectionMatrixZ"]];
					}
				}
			}
			//Look At
			[ds appendTabAndFormat:@"look_at < %@, %@, %@>\n",[dict objectForKey:@"cameraLookAtMatrixX"],
			 [dict objectForKey:@"cameraLookAtMatrixY"],
			 [dict objectForKey:@"cameraLookAtMatrixZ"]];
			
			//focal blur
			if ( [[dict objectForKey:@"cameraFocalBlurGroupOn"] intValue] ==NSOnState)
			{
				//focal point
				[ds appendTabAndFormat:@"focal_point < %@, %@, %@>\n",[dict objectForKey:@"cameraFocalBlurFocalPointMatrixX"],
				 [dict objectForKey:@"cameraFocalBlurFocalPointMatrixY"],
				 [dict objectForKey:@"cameraFocalBlurFocalPointMatrixZ"]];
				
				[ds appendTabAndFormat:@"aperture %@\n",[dict objectForKey:@"cameraFocalBlurApertureEdit"]];
				if ([[dict objectForKey:@"cameraFocalBlurConfidenceOn"] intValue] ==NSOnState)
					[ds appendTabAndFormat:@"confidence %@\n",[dict objectForKey:@"cameraFocalBlurConfidenceEdit"]];
				[ds appendTabAndFormat:@"blur_samples %@\n",[dict objectForKey:@"cameraFocalBlurBlurSamplesEdit"]];
				//Variance
				if ([[dict objectForKey:@"cameraFocalBlurVarianceOn"] intValue] ==NSOnState)
					[ds appendTabAndFormat:@"variance %@\n",[dict objectForKey:@"cameraFocalBlurVarianceEdit"]];
			}
			//normal
			if ([[dict objectForKey:@"cameraNormalGroupOn"] intValue] ==NSOnState)
			{
				WriteNormal(cForceWrite, ds, [dict objectForKey:@"cameraNormal"], NO);
			}
			break;
			
		case cCameraUserDefinedTab:
			[ds copyTabAndText:@"user_defined\n"];
			[ds copyTabAndText:@"location {\n"];
			[ds addTab];
			
			switch([[dict objectForKey:@"cameraUserDefinedLocationPopup"] intValue])
		{
			case cCameraUserDefinedFunction:
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedLocationFunctionMatrixX"]];
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedLocationFunctionMatrixY"]];
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedLocationFunctionMatrixZ"]];
				break;
			case cCameraUserDefinedPigment:
				WritePigment(cForceWrite, ds,[dict objectForKey:@"cameraUserDefinedLocationPigment"] ,NO);
				break;
		}//switch([[dict objectForKey:@"cameraUserDefinedLocationPopup"] intValue])
			
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			
			[ds copyTabAndText:@"direction {\n"];
			[ds addTab];
			
			switch([[dict objectForKey:@"cameraUserDefinedDirectionPopup"] intValue])
		{
			case cCameraUserDefinedFunction:
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedDirectionFunctionMatrixX"]];
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedDirectionFunctionMatrixY"]];
				[ds appendTabAndFormat:@"function { %@  }\n",[dict objectForKey:@"cameraUserDefinedDirectionFunctionMatrixZ"]];
				break;
				break;
			case cCameraUserDefinedPigment:
				WritePigment(cForceWrite, ds, [dict objectForKey:@"cameraUserDefinedDirectionPigment"], NO);
				break;
		}//switch([[dict objectForKey:@"cameraUserDefinedDirectionPopup"] intValue])
			[ds removeTab];
			[ds copyTabAndText:@"}\n"];
			break;
	}//switch( [[dict objectForKey:@"cameraTabView"] intValue])
	
	if ( param==NO)		//don't write keyword if used as pigment camera_view
	{
		[ds removeTab];
		[ds copyTabAndText:@"}\n"];
	}
	//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// writeAspectRatioBlockFromDict: toMutableTab
//---------------------------------------------------------------------
+(void) writeAspectRatioBlockFromDict:(NSDictionary *)dict toMutableTab:(MutableTabString*)ds
{
	switch ([[dict objectForKey:@"cameraAspectRatioRightPopup"] intValue])
	{
		case cCameraUpRightX: 
			[ds appendTabAndFormat:@"right x * %@\n",[dict objectForKey:@"cameraAspectRatioRightEdit"]];
			break;
		case cCameraUpRightY: 
			[ds appendTabAndFormat:@"right y * %@\n",[dict objectForKey:@"cameraAspectRatioRightEdit"]];
			break;
		case cCameraUpRightZ: 
			[ds appendTabAndFormat:@"right z * %@\n",[dict objectForKey:@"cameraAspectRatioRightEdit"]];
			break;
	}

	switch ([[dict objectForKey:@"cameraAspectRatioUpPopup"] intValue])
	{
		case cCameraUpRightX:
			[ds appendTabAndFormat:@"up x * %@\n",[dict objectForKey:@"cameraAspectRatioUpEdit"]];
			break;
		case cCameraUpRightY:
			[ds appendTabAndFormat:@"up y * %@\n",[dict objectForKey:@"cameraAspectRatioUpEdit"]];
			break;
		case cCameraUpRightZ:
			[ds appendTabAndFormat:@"up z * %@\n",[dict objectForKey:@"cameraAspectRatioUpEdit"]];
			break;
	}
	
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[CameraTemplate createDefaults:menuTagTemplateCamera];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"cameraDefaultSettings",
		nil];
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
	[defaults registerDefaults:factoryDefaults];
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(NSUInteger) templateType
{
	NSMutableDictionary *initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:cCameraPredefinedTab],					@"cameraTabView",

		@"0.0",																					@"cameraLocationMatrixX",	
		@"0.0",																					@"cameraLocationMatrixY",
		@"-5",																					@"cameraLocationMatrixZ",	
		@(NSOffState),						@"cameraSkyOn",
		[NSNumber numberWithInt:cXYZVectorPopupY],			@"cameraSkyVectorPopup",
		@"0.0",																					@"cameraSkyMatrixX",
		@"1.0",																					@"cameraSkyMatrixY",
		@"0.0",																					@"cameraSkyMatrixZ",
		[NSNumber numberWithInt:cCameraTypePerspective],@"cameraTypePopup",
		@(NSOnState),							@"cameraAspectRatioGroupOn",
		@(NSOffState),						@"cameraAspectRatioAutoOn",
		[NSNumber numberWithInt:cCameraUpRightY],				@"cameraAspectRatioUpPopup",
		@"3/4",																					@"cameraAspectRatioUpEdit",
		[NSNumber numberWithInt:cCameraUpRightX],				@"cameraAspectRatioRightPopup",
		@"1",																						@"cameraAspectRatioRightEdit",
		@(NSOnState),							@"cameraAngleDirectionOn",
		[NSNumber numberWithInt:cCameraAngleDirectionPopupAngle],	@"cameraAngleDirectionPopup",
		[NSNumber numberWithInt:cCameraAngleTabViewSperical],			@"cameraAngleTabView",
		@(NSOffState),						@"cameraVerticalAngleOn",
		@"0.0",																					@"cameraVerticalAngleEdit",
		@"0.0",																					@"cameraHorizontalAngleEdit",
		
		@"0.0",																					@"cameraLookAtMatrixX",
		@"0.0",																					@"cameraLookAtMatrixY",
		@"0.0",																					@"cameraLookAtMatrixZ",
		@(NSOffState),						@"cameraFocalBlurGroupOn",
		@"0.0",																					@"cameraFocalBlurFocalPointMatrixX",
		@"0.0",																					@"cameraFocalBlurFocalPointMatrixY",
		@"0.0",																					@"cameraFocalBlurFocalPointMatrixZ",
		@"0.0",																					@"cameraFocalBlurApertureEdit",
		@"0.0",																					@"cameraFocalBlurBlurSamplesEdit",
		@(NSOffState),						@"cameraFocalBlurConfidenceOn",
		@"0.9",																					@"cameraFocalBlurConfidenceEdit",
		@(NSOffState),						@"cameraFocalBlurVarianceOn",
		@"1/128",																				@"cameraFocalBlurVarianceEdit",
		@(NSOffState),						@"cameraNormalGroupOn",

		//SubPanel!!!!!!!
		@"0.0",																					@"cameraAngleDirectionMatrixX",
		@"0.0",																					@"cameraAngleDirectionMatrixY",	
		@"1.0",																					@"cameraAngleDirectionMatrixZ",	
		@"60",																					@"cameraAngleAngleEdit",
		//user defined
		[NSNumber numberWithInt:cCameraUserDefinedPigment],			@"cameraUserDefinedLocationPopup",
		[NSNumber numberWithInt:cCameraUserDefinedFunction],			@"cameraUserDefinedDirectionPopup",
		@"x*y*z",																				@"cameraUserDefinedLocationFunctionMatrixX",
		@"x*y*z",																				@"cameraUserDefinedLocationFunctionMatrixY",
		@"x*y*z",																				@"cameraUserDefinedLocationFunctionMatrixZ",
		@"x*y*z",																				@"cameraUserDefinedDirectionFunctionMatrixX",
		@"x*y*z",																				@"cameraUserDefinedDirectionFunctionMatrixY",
		@"x*y*z",																				@"cameraUserDefinedDirectionFunctionMatrixZ",

	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];
	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		cameraTabView,									@"cameraTabView",

		[cameraLocationMatrix cellWithTag:0],					@"cameraLocationMatrixX",	
		[cameraLocationMatrix cellWithTag:1],					@"cameraLocationMatrixY",
		[cameraLocationMatrix cellWithTag:2],					@"cameraLocationMatrixZ",	
		cameraSkyOn,																	@"cameraSkyOn",
		cameraSkyVectorPopup,													@"cameraSkyVectorPopup",
		[cameraSkyMatrix cellWithTag:0],							@"cameraSkyMatrixX",
		[cameraSkyMatrix cellWithTag:1],							@"cameraSkyMatrixY",
		[cameraSkyMatrix cellWithTag:2],							@"cameraSkyMatrixZ",
		cameraTypePopup,															@"cameraTypePopup",
		cameraAspectRatioGroupOn,											@"cameraAspectRatioGroupOn",
		cameraAspectRatioAutoOn,											@"cameraAspectRatioAutoOn",
		cameraAspectRatioUpPopup,											@"cameraAspectRatioUpPopup",
		cameraAspectRatioUpEdit,											@"cameraAspectRatioUpEdit",
		cameraAspectRatioRightPopup,									@"cameraAspectRatioRightPopup",
		cameraAspectRatioRightEdit,										@"cameraAspectRatioRightEdit",
		cameraAngleDirectionOn,												@"cameraAngleDirectionOn",
		cameraAngleDirectionPopup,										@"cameraAngleDirectionPopup",
		cameraAngleTabView,														@"cameraAngleTabView",
		cameraVerticalAngleOn,												@"cameraVerticalAngleOn",
		cameraVerticalAngleEdit,											@"cameraVerticalAngleEdit",
		cameraHorizontalAngleEdit,										@"cameraHorizontalAngleEdit",
		
		[cameraLookAtMatrix cellWithTag:0],						@"cameraLookAtMatrixX",
		[cameraLookAtMatrix cellWithTag:1],						@"cameraLookAtMatrixY",
		[cameraLookAtMatrix cellWithTag:2],						@"cameraLookAtMatrixZ",
		cameraFocalBlurGroupOn,												@"cameraFocalBlurGroupOn",
		[cameraFocalBlurFocalPointMatrix cellWithTag:0],	@"cameraFocalBlurFocalPointMatrixX",
		[cameraFocalBlurFocalPointMatrix cellWithTag:1],	@"cameraFocalBlurFocalPointMatrixY",
		[cameraFocalBlurFocalPointMatrix cellWithTag:2],	@"cameraFocalBlurFocalPointMatrixZ",
		cameraFocalBlurApertureEdit,								@"cameraFocalBlurApertureEdit",
		cameraFocalBlurBlurSamplesEdit,							@"cameraFocalBlurBlurSamplesEdit",
		cameraFocalBlurConfidenceOn,								@"cameraFocalBlurConfidenceOn",
		cameraFocalBlurConfidenceEdit,							@"cameraFocalBlurConfidenceEdit",
		cameraFocalBlurVarianceOn,									@"cameraFocalBlurVarianceOn",
		cameraFocalBlurVarianceEdit,								@"cameraFocalBlurVarianceEdit",
		cameraNormalGroupOn,												@"cameraNormalGroupOn",

		//SubPanel!!!!!!!
		[cameraAngleDirectionMatrix cellWithTag:0],	@"cameraAngleDirectionMatrixX",
		[cameraAngleDirectionMatrix cellWithTag:1],	@"cameraAngleDirectionMatrixY",
		[cameraAngleDirectionMatrix cellWithTag:2],	@"cameraAngleDirectionMatrixZ",
		cameraAngleAngleEdit,												@"cameraAngleAngleEdit",
		//user defined
		cameraUserDefinedLocationPopup,				@"cameraUserDefinedLocationPopup",
		cameraUserDefinedDirectionPopup,			@"cameraUserDefinedDirectionPopup",
		cameraUserDefinedLocationFunctionX,		@"cameraUserDefinedLocationFunctionMatrixX",
		cameraUserDefinedLocationFunctionY,		@"cameraUserDefinedLocationFunctionMatrixY",
		cameraUserDefinedLocationFunctionZ,		@"cameraUserDefinedLocationFunctionMatrixZ",
		cameraUserDefinedDirectionFunctionX,	@"cameraUserDefinedDirectionFunctionMatrixX",
		cameraUserDefinedDirectionFunctionY,	@"cameraUserDefinedDirectionFunctionMatrixY",
		cameraUserDefinedDirectionFunctionZ,	@"cameraUserDefinedDirectionFunctionMatrixZ",

	nil] ;
	[mOutlets retain];
	
	[ToolTipAutomator setTooltips:@"cameraLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"cameraLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			cameraPredefinedEditNormalButton,						@"cameraPredefinedEditNormalButton",
			cameraUserDefinedLocationEditPigmentButton,	@"cameraUserDefinedLocationEditPigmentButton",
			cameraUserDefinedLocationFunctionUButton,		@"cameraUserDefinedLocationFunctionUButton",
			cameraUserDefinedLocationFunctionVButton,		@"cameraUserDefinedLocationFunctionVButton",
			cameraUserDefinedLocationFunctionZButton,		@"cameraUserDefinedLocationFunctionZButton",
			cameraUserDefinedDirectionEditPigmentButton,@"cameraUserDefinedDirectionEditPigmentButton",
			cameraUserDefinedDirectionFunctionUButton,	@"cameraUserDefinedDirectionFunctionUButton",
			cameraUserDefinedDirectionFunctionVButton,	@"cameraUserDefinedDirectionFunctionVButton",
			cameraUserDefinedDirectionFunctionZButton,	@"cameraUserDefinedDirectionFunctionZButton",

			cameraLocationMatrix,							@"cameraLocationMatrix",
			cameraSkyMatrix,									@"cameraSkyMatrix",
			cameraLookAtMatrix,								@"cameraLookAtMatrix",
			cameraFocalBlurFocalPointMatrix,	@"cameraFocalBlurFocalPointMatrix",
			cameraAngleDirectionMatrix,				@"cameraAngleDirectionMatrix",
		nil]
		];
		
	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"cameraTabView",
		nil];
	[mExcludedObjectsForReset retain];
		
	[self  setValuesInPanel:[self preferences]];
	
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self setCameraNormal:[preferences objectForKey:@"cameraNormal"]];
	[self setCameraUserDefinedDirectionPigment:[preferences objectForKey:@"cameraUserDefinedDirectionPigment"]];
	[self setCameraUserDefinedDirectionFunctionInsertX:[preferences objectForKey:@"cameraUserDefinedDirectionFunctionInsertX"]];
	[self setCameraUserDefinedDirectionFunctionInsertY:[preferences objectForKey:@"cameraUserDefinedDirectionFunctionInsertY"]];
	[self setCameraUserDefinedDirectionFunctionInsertZ:[preferences objectForKey:@"cameraUserDefinedDirectionFunctionInsertZ"]];

	[self setCameraUserDefinedLocationPigment:[preferences objectForKey:@"cameraUserDefinedLocationPigment"]];
	[self setCameraUserDefinedLocationFunctionInsertX:[preferences objectForKey:@"cameraUserDefinedLocationFunctionInsertX"]];
	[self setCameraUserDefinedLocationFunctionInsertY:[preferences objectForKey:@"cameraUserDefinedLocationFunctionInsertY"]];
	[self setCameraUserDefinedLocationFunctionInsertZ:[preferences objectForKey:@"cameraUserDefinedLocationFunctionInsertZ"]];

	[super setValuesInPanel:preferences];
	
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];

	if ( [[dict objectForKey:@"cameraNormalGroupOn"]intValue]==NSOnState)
	{
		if( cameraNormal != nil )
			[dict setObject:cameraNormal forKey:@"cameraNormal"];
	}

	if ( [[dict objectForKey:@"cameraTabView"]intValue]==cCameraUserDefinedTab)
	{
		if ( [[dict objectForKey:@"cameraUserDefinedLocationPopup"]intValue]==cCameraUserDefinedPigment)
		{
			if( cameraUserDefinedLocationPigment != nil )
				[dict setObject:cameraUserDefinedLocationPigment forKey:@"cameraUserDefinedLocationPigment"];
		}
		else
		{
			if( cameraUserDefinedLocationFunctionInsertX != nil )
				[dict setObject:cameraUserDefinedLocationFunctionInsertX forKey:@"cameraUserDefinedLocationFunctionInsertX"];
			if( cameraUserDefinedLocationFunctionInsertY != nil )
				[dict setObject:cameraUserDefinedLocationFunctionInsertY forKey:@"cameraUserDefinedLocationFunctionInsertY"];
			if( cameraUserDefinedDirectionFunctionInsertZ != nil )
				[dict setObject:cameraUserDefinedLocationFunctionInsertZ forKey:@"cameraUserDefinedLocationFunctionInsertZ"];
		}
		
		if ( [[dict objectForKey:@"cameraUserDefinedDirectionPopup"]intValue]==cCameraUserDefinedPigment)
		{
			if( cameraUserDefinedDirectionPigment != nil )
				[dict setObject:cameraUserDefinedDirectionPigment forKey:@"cameraUserDefinedDirectionPigment"];
		}
		else
		{
			if( cameraUserDefinedDirectionFunctionInsertX != nil )
				[dict setObject:cameraUserDefinedDirectionFunctionInsertX forKey:@"cameraUserDefinedDirectionFunctionInsertX"];
			if( cameraUserDefinedDirectionFunctionInsertY != nil )
				[dict setObject:cameraUserDefinedDirectionFunctionInsertY forKey:@"cameraUserDefinedDirectionFunctionInsertY"];
			if( cameraUserDefinedDirectionFunctionInsertZ != nil )
				[dict setObject:cameraUserDefinedDirectionFunctionInsertZ forKey:@"cameraUserDefinedDirectionFunctionInsertZ"];
		}
	}
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self cameraTarget:self];
	[self setNotModified];
}

//---------------------------------------------------------------------
// cameraTarget:sender
//---------------------------------------------------------------------
-(IBAction) cameraTarget:(id)sender
{
	NSInteger theTag;
	if ( sender==self)
		theTag=cCameraTypePopup;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case cCameraTypePopup:
			switch([cameraTypePopup indexOfSelectedItem])
			{
				case cCameraTypeOmnimax:
					[self enableObjectsAccordingToState:NSOnState,cameraAspectRatioGroupOn ,nil];
					[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
					[cameraFocalBlurGroupOn setEnabled:YES];
			 		[cameraAngleDirectionOn setEnabled:NO];
			 		[cameraAngleDirectionOn setHidden:YES];
			 		[cameraAngleTabView setHidden:YES];
					if ( [cameraTypePopup indexOfSelectedItem]==cCameraTypeSpherical)
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewSperical];
					else
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewNonSperical];
			 		break;

				case cCameraTypePerspective:
				case cCameraTypeFisheye:
				case cCameraTypeUltraWideAngle:
				case cCameraTypePanoramic:
					[self enableObjectsAccordingToState:NSOnState,cameraAspectRatioGroupOn ,nil];
					[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
					[cameraFocalBlurGroupOn setEnabled:YES];
			 		[cameraAngleDirectionOn setEnabled:YES];
			 		[cameraAngleDirectionOn setHidden:NO];
			 		[cameraAngleTabView setHidden:NO];
					if ( [cameraTypePopup indexOfSelectedItem]==cCameraTypeSpherical)
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewSperical];
					else
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewNonSperical];
			 		break;

			 	case cCameraTypeSpherical:
					[self enableObjectsAccordingToState:NSOffState,cameraAspectRatioGroupOn ,nil];
					[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
					[cameraFocalBlurGroupOn setEnabled:YES];
			 		[cameraAngleDirectionOn setEnabled:YES];
			 		[cameraAngleDirectionOn setHidden:NO];
			 		[cameraAngleTabView setHidden:NO];
					if ( [cameraTypePopup indexOfSelectedItem]==cCameraTypeSpherical)
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewSperical];
					else
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewNonSperical];
			 		break;
			 	case cCameraTypeOrthoGraphic:
					[self enableObjectsAccordingToState:NSOnState,cameraAspectRatioGroupOn ,nil];
					[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
			 		[cameraAspectRatioAutoOn setEnabled:NO];
			 		[cameraAngleDirectionOn setEnabled:NO];
			 		[cameraAngleDirectionOn setHidden:YES];
			 		[cameraAngleTabView setHidden:YES];
					[cameraFocalBlurGroupOn setEnabled:NO];
					break;
			 	case cCameraTypeCylinderVerticalFixed:
			 	case cCameraTypeCylinderHorizontalFixed:
			 	case cCameraTypeCylinderVerticalMoving:
			 	case cCameraTypeCylinderHorizontalMoving:
					[self enableObjectsAccordingToState:NSOnState,cameraAspectRatioGroupOn ,nil];
					[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
			 		[cameraAspectRatioAutoOn setEnabled:NO];
			 		[cameraAngleDirectionOn setEnabled:YES];
			 		[cameraAngleDirectionOn setHidden:NO];
			 		[cameraAngleTabView setHidden:NO];
					if ( [cameraTypePopup indexOfSelectedItem]==cCameraTypeSpherical)
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewSperical];
					else
				 		[cameraAngleTabView selectTabViewItemAtIndex:cCameraAngleTabViewNonSperical];
			 		break;

			}			
			[self setSubViewsOfNSBox:cameraFocalBlurGroup toNSButton:cameraFocalBlurGroupOn];
			if ( sender !=self )	break;


		case cCameraAspectRatioGroupOn:
			[self setSubViewsOfNSBox:cameraAspectRatioGroup toNSButton:cameraAspectRatioGroupOn];
//			if ( sender !=self )	break;
		case cCameraAspectRatioAutoOn:
			if ( [cameraAspectRatioGroupOn state]==NSOnState)
			{
				NSInteger tpy=[cameraTypePopup indexOfSelectedItem];
				if ( tpy == cCameraTypeOrthoGraphic)
				{
					SetSubViewsOfNSBoxToState(cameraAspectRatioAutoView, NSOnState);
			 		[cameraAspectRatioAutoOn setEnabled:NO];
				}
				else
					[self setSubViewsOfNSBoxReverse:cameraAspectRatioAutoView toNSButton:cameraAspectRatioAutoOn];
			}
			if ( sender !=self )	break;


		case cCameraAngleDirectionOn:
			[self enableObjectsAccordingToObject:cameraAngleDirectionOn, 
				cameraAngleDirectionPopup, cameraAngleDirectionMatrix,	cameraAngleAngleEdit,nil];
//			if ( sender !=self )	break;
		case cCameraVerticalAngleOn:
			if ( [cameraSkyOn state]==NSOnState)
				[self enableObjectsAccordingToObject:cameraVerticalAngleOn ,cameraVerticalAngleEdit ,nil];
//			if ( sender !=self )	break;
		case cCameraAngleDirectionPopup:
			if ( [cameraAngleDirectionOn state]==NSOnState)
			{
				switch ([cameraAngleDirectionPopup indexOfSelectedItem])
				{
					case cCameraAngleDirectionPopupAngle:
						[cameraAngleDirectionGroup setHidden:YES];
						[cameraAngleAngleEdit setHidden:NO];
						[cameraAngleAngleEdit setEnabled:YES];
						break;
					case cCameraAngleDirectionPopupDirection:
						[cameraAngleDirectionGroup setHidden:NO];
						[cameraAngleAngleEdit setHidden:YES];
						break;
				}
			}
			if ( sender !=self )	break;
		case cCameraSkyOn:
			[self enableObjectsAccordingToObject:cameraSkyOn, cameraSkyVectorPopup, cameraSkyMatrix,nil];
//			if ( sender !=self )	break;
		case cCameraSkyVectorPopup:
			if ( [cameraSkyOn state]==NSOnState)
				[ self setXYZVectorAccordingToPopup:cameraSkyVectorPopup xyzMatrix:cameraSkyMatrix];
			if ( sender !=self )	break;
			

		case cCameraFocalBlurGroupOn:
			[self setSubViewsOfNSBox:cameraFocalBlurGroup toNSButton:cameraFocalBlurGroupOn];
//			if ( sender !=self )	break;
		case cCameraFocalBlurVarianceOn:
			if ( [cameraFocalBlurGroupOn state]==NSOnState)
				[self enableObjectsAccordingToObject:cameraFocalBlurVarianceOn ,	cameraFocalBlurVarianceEdit, nil];
//			if ( sender !=self )	break;
		case cCameraFocalBlurConfidenceOn:
			if ( [cameraFocalBlurGroupOn state]==NSOnState)
				[self enableObjectsAccordingToObject:cameraFocalBlurConfidenceOn, 	cameraFocalBlurConfidenceEdit, nil];
			if ( sender !=self )	break;
		case cCameraNormalGroupOn:
			[self setSubViewsOfNSBox:cameraNormalGroup toNSButton:cameraNormalGroupOn];
			if ( sender !=self )	break;
		case cCameraUserDefinedDirectionPopup:
			[self setTabView:cameraUserDefinedDirectionTabView toIndexOfPopup:cameraUserDefinedDirectionPopup];
			if ( sender !=self )	break;
		case cCameraUserDefinedLocationPopup:
			[self setTabView:cameraUserDefinedLocationTabView toIndexOfPopup:cameraUserDefinedLocationPopup];
			if ( sender !=self )	break;
	}
	[self setModified:nil];
}


//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{

	NSString *str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
	if (str==nil)
		return;

	if( [key isEqualToString:@"cameraUserDefinedDirectionPigment"])
		[self setCameraUserDefinedDirectionPigment:dict];
	if( [key isEqualToString:@"cameraNormal"])
		[self setCameraNormal:dict];
	else if( [key isEqualToString:@"cameraUserDefinedDirectionFunctionInsertX"])
		[cameraUserDefinedDirectionFunctionX  insertText:str];
	else if( [key isEqualToString:@"cameraUserDefinedDirectionFunctionInsertY"])
		[cameraUserDefinedDirectionFunctionY insertText:str];
	else if( [key isEqualToString:@"cameraUserDefinedDirectionFunctionInsertZ"])
		[cameraUserDefinedDirectionFunctionZ insertText:str];

	else if( [key isEqualToString:@"cameraUserDefinedLocationPigment"])
		[self setCameraUserDefinedLocationPigment:dict];
	else if( [key isEqualToString:@"cameraUserDefinedLocationFunctionInsertX"])
		[cameraUserDefinedLocationFunctionX insertText:str];
	else if( [key isEqualToString:@"cameraUserDefinedLocationFunctionInsertY"])
		[cameraUserDefinedLocationFunctionY insertText:str];
	else if( [key isEqualToString:@"cameraUserDefinedLocationFunctionInsertZ"])
		[cameraUserDefinedLocationFunctionZ  insertText:str];

	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// cameraButtons:sender
//---------------------------------------------------------------------
-(IBAction) cameraButtons:(id)sender
{
	id 	prefs=nil;

	NSInteger tag=[sender tag];
	switch( tag)
	{
		case cCameraNormalEditButton:
			if (cameraNormal!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraNormal];
			[self callTemplate:menuTagTemplateNormal withDictionary:prefs andKeyName:@"cameraNormal"];
			break;
		case cCameraUserDefinedDirectionEditPigmentButton:
			if (cameraUserDefinedDirectionPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedDirectionPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"cameraUserDefinedDirectionPigment"];
			break;
		case cCameraUserDefinedDirectionFunctionInsertButtonX:
			if (cameraUserDefinedDirectionFunctionInsertX!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedDirectionFunctionInsertX];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedDirectionFunctionInsertX"];
			break;
		case cCameraUserDefinedDirectionFunctionInsertButtonY:
			if (cameraUserDefinedDirectionFunctionInsertY!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedDirectionFunctionInsertY];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedDirectionFunctionInsertY"];
			break;
		case cCameraUserDefinedDirectionFunctionInsertButtonZ:
			if (cameraUserDefinedDirectionFunctionInsertZ!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedDirectionFunctionInsertZ];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedDirectionFunctionInsertZ"];
			break;

		case cCameraUserDefinedLocationEditPigmentButton:
			if (cameraUserDefinedLocationPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedLocationPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"cameraUserDefinedLocationPigment"];
			break;
		case cCameraUserDefinedLocationFunctionInsertButtonX:
			if (cameraUserDefinedLocationFunctionInsertX!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedLocationFunctionInsertX];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedLocationFunctionInsertX"];
			break;
		case cCameraUserDefinedLocationFunctionInsertButtonY:
			if (cameraUserDefinedLocationFunctionInsertY!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedLocationFunctionInsertY];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedLocationFunctionInsertY"];
			break;
		case cCameraUserDefinedLocationFunctionInsertButtonZ:
			if (cameraUserDefinedLocationFunctionInsertZ!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:cameraUserDefinedLocationFunctionInsertZ];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"cameraUserDefinedLocationFunctionInsertZ"];
			break;

	}
}





@end
