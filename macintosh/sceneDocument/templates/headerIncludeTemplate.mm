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
#import "headerIncludeTemplate.h"
#import "standardMethods.h"
#import "tooltipAutomator.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cHeaderIncludeComment1		=101 ,
	cHeaderIncludeComment1On	=1 ,
	cHeaderIncludeComment2		=102 ,
	cHeaderIncludeComment2On	=2 ,
	cHeaderIncludeComment3		=103 ,
	cHeaderIncludeComment3On	=3 ,
	cHeaderIncludeComment4		=104 ,
	cHeaderIncludeComment4On	=4 ,
	cHeaderIncludeComment5		=105 ,
	cHeaderIncludeComment5On	=5 ,
	cHeaderIncludeComment6		=106 ,
	cHeaderIncludeComment6On	=6 ,
	cHeaderIncludeComment7		=107 ,
	cHeaderIncludeComment7On	=7 ,

	cHeaderIncludeInclude1			=108 ,
	cHeaderIncludeInclude1On		=8 ,
	cHeaderIncludeInclude2			=109 ,
	cHeaderIncludeInclude2On		=9 ,
	cHeaderIncludeInclude3			=110 ,
	cHeaderIncludeInclude3On		=10 ,
	cHeaderIncludeInclude4			=111 ,
	cHeaderIncludeInclude4On		=11 ,
	cHeaderIncludeInclude5			=112 ,
	cHeaderIncludeInclude5On		=12 ,
	cHeaderIncludeInclude6			=113 ,
	cHeaderIncludeInclude6On		=13 ,
	cHeaderIncludeInclude7			=114 ,
	cHeaderIncludeInclude7On		=14 ,
	cHeaderIncludeInclude8			=115 ,
	cHeaderIncludeInclude8On		=15 ,
	cHeaderIncludeInclude9			=116 ,
	cHeaderIncludeInclude9On		=16 ,
	cHeaderIncludeInclude10		=117 ,
	cHeaderIncludeInclude10On	=17 ,
	cHeaderIncludeInclude11		=118 ,
	cHeaderIncludeInclude11On	=18 ,
	cHeaderIncludeInclude12		=119 ,
	cHeaderIncludeInclude12On	=19 ,

	cHeaderIncludeVersion1			=120 ,
	cHeaderIncludeVersion1On		=20 ,
	cHeaderIncludeVersion2			=121 ,
	cHeaderIncludeVersion2On		=21 
};



@implementation HeaderIncludeTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(NSInteger) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{
	NSString *buttonString;
	NSString *stringString;
	
	if ( dict== nil)
		dict=[HeaderIncludeTemplate createDefaults:menuTagTemplateHeaderInclude];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[HeaderIncludeTemplate class] andTemplateType:menuTagTemplateHeaderInclude];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}
	[dict retain];

	BOOL lineWritten=NO;
	for (int x=1; x<=7; x++)
	{
		buttonString=[NSString stringWithFormat:@"headerIncludeComment%dOn",x];
		stringString=[NSString stringWithFormat:@"headerIncludeComment%d",x];
		if ( [[dict objectForKey:buttonString]intValue]==NSOnState)
		{
			[ds appendFormat:@"//%@\n",[dict objectForKey:stringString]];
			lineWritten=YES;
		}	
	}
	if( lineWritten==YES)
		[ds copyText:@"\n"];

	lineWritten=NO;
	for (int x=1; x<=12; x++)
	{
		buttonString=[NSString stringWithFormat:@"headerIncludeInclude%dOn",x];
		stringString=[NSString stringWithFormat:@"headerIncludeInclude%d",x];
		if ( [[dict objectForKey:buttonString]intValue]==NSOnState)
		{
			[ds appendFormat:@"#include \"%@\"\n",[dict objectForKey:stringString]];
			lineWritten=YES;
		}	
	}
	if( lineWritten==YES)
		[ds copyText:@"\n"];


	if ( [[dict objectForKey:@"headerIncludeVersion1On"]intValue]==NSOnState)
		[ds appendFormat:@"%@\n",[dict objectForKey:@"headerIncludeVersion1"]];
	
	if ( [[dict objectForKey:@"headerIncludeVersion2On"]intValue]==NSOnState)
		[ds appendFormat:@"%@\n",[dict objectForKey:@"headerIncludeVersion2"]];
	
//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[HeaderIncludeTemplate createDefaults:menuTagTemplateHeaderInclude];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"headerIncludeDefaultSettings",
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
		@"Persistence of Vision Ray Tracer Scene Description File",	@"headerIncludeComment1",	
		@(NSOnState),								@"headerIncludeComment1On",
		@"File: .pov",																		@"headerIncludeComment2",	
		@(NSOffState),								@"headerIncludeComment2On",
		@"Date:",																			@"headerIncludeComment3",	
		@(NSOffState),								@"headerIncludeComment3On",
		@"Author:",																		@"headerIncludeComment4",	
		@(NSOffState),								@"headerIncludeComment4On",
		@"",																					@"headerIncludeComment5",	
		@(NSOffState),								@"headerIncludeComment5On",
		@"",																					@"headerIncludeComment6",	
		@(NSOffState),								@"headerIncludeComment6On",
		@"",																					@"headerIncludeComment7",	
		@(NSOffState),								@"headerIncludeComment7On",

		@"colors.inc",																		@"headerIncludeInclude1",	
		@(NSOffState),								@"headerIncludeInclude1On",
		@"textures.inc",																	@"headerIncludeInclude2",	
		@(NSOffState),								@"headerIncludeInclude2On",
		@"glass.inc",																		@"headerIncludeInclude3",	
		@(NSOffState),								@"headerIncludeInclude3On",
		@"metals.inc",																	@"headerIncludeInclude4",	
		@(NSOffState),								@"headerIncludeInclude4On",
		@"stones.inc",																		@"headerIncludeInclude5",	
		@(NSOffState),								@"headerIncludeInclude5On",
		@"stones1.inc",																	@"headerIncludeInclude6",	
		@(NSOffState),								@"headerIncludeInclude6On",
		@"stones2.inc",																	@"headerIncludeInclude7",	
		@(NSOffState),								@"headerIncludeInclude7On",
		@"golds.inc",																		@"headerIncludeInclude8",	
		@(NSOffState),								@"headerIncludeInclude8On",
		@"finish.inc",																		@"headerIncludeInclude9",	
		@(NSOffState),								@"headerIncludeInclude9On",
		@"shapesq.inc",																	@"headerIncludeInclude10",	
		@(NSOffState),								@"headerIncludeInclude10On",
		@"skies.inc",																		@"headerIncludeInclude11",	
		@(NSOffState),								@"headerIncludeInclude11On",
		@"woods.inc",																		@"headerIncludeInclude12",	
		@(NSOffState),								@"headerIncludeInclude12On",

		@"#version unofficial MegaPov 1.2;",									@"headerIncludeVersion1",	
		@(NSOffState),								@"headerIncludeVersion1On",
		@"#default { texture { pigment { color rgb < 1, 0, 0 > } finish { ambient 0.4 } } }",
																								@"headerIncludeVersion2",	
		@(NSOffState),								@"headerIncludeVersion2On",


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
		headerIncludeComment1,		@"headerIncludeComment1",	
		headerIncludeComment1On,	@"headerIncludeComment1On",
		headerIncludeComment2,		@"headerIncludeComment2",	
		headerIncludeComment2On,	@"headerIncludeComment2On",
		headerIncludeComment3,		@"headerIncludeComment3",	
		headerIncludeComment3On,	@"headerIncludeComment3On",
		headerIncludeComment4,		@"headerIncludeComment4",	
		headerIncludeComment4On,	@"headerIncludeComment4On",
		headerIncludeComment5,		@"headerIncludeComment5",	
		headerIncludeComment5On,	@"headerIncludeComment5On",
		headerIncludeComment6,		@"headerIncludeComment6",	
		headerIncludeComment6On,	@"headerIncludeComment6On",
		headerIncludeComment7,		@"headerIncludeComment7",	
		headerIncludeComment7On,	@"headerIncludeComment7On",

		headerIncludeInclude1,			@"headerIncludeInclude1",	
		headerIncludeInclude1On,		@"headerIncludeInclude1On",
		headerIncludeInclude2,			@"headerIncludeInclude2",	
		headerIncludeInclude2On,		@"headerIncludeInclude2On",
		headerIncludeInclude3,			@"headerIncludeInclude3",	
		headerIncludeInclude3On,		@"headerIncludeInclude3On",
		headerIncludeInclude4,			@"headerIncludeInclude4",	
		headerIncludeInclude4On,		@"headerIncludeInclude4On",
		headerIncludeInclude5,			@"headerIncludeInclude5",	
		headerIncludeInclude5On,		@"headerIncludeInclude5On",
		headerIncludeInclude6,			@"headerIncludeInclude6",	
		headerIncludeInclude6On,		@"headerIncludeInclude6On",
		headerIncludeInclude7,			@"headerIncludeInclude7",	
		headerIncludeInclude7On,		@"headerIncludeInclude7On",
		headerIncludeInclude8,			@"headerIncludeInclude8",	
		headerIncludeInclude8On,		@"headerIncludeInclude8On",
		headerIncludeInclude9,			@"headerIncludeInclude9",	
		headerIncludeInclude9On,		@"headerIncludeInclude9On",
		headerIncludeInclude10,			@"headerIncludeInclude10",	
		headerIncludeInclude10On,		@"headerIncludeInclude10On",
		headerIncludeInclude11,			@"headerIncludeInclude11",	
		headerIncludeInclude11On,		@"headerIncludeInclude11On",
		headerIncludeInclude12,			@"headerIncludeInclude12",	
		headerIncludeInclude12On,		@"headerIncludeInclude12On",

		headerIncludeVersion1,			@"headerIncludeVersion1",	
		headerIncludeVersion1On,		@"headerIncludeVersion1On",
		headerIncludeVersion2,			@"headerIncludeVersion2",	
		headerIncludeVersion2On,		@"headerIncludeVersion2On",
	nil] ;
	[ToolTipAutomator setTooltips:@"headerIncludeLocalized" andDictionary:mOutlets];

	[mOutlets retain];
	[self  setValuesInPanel:[self preferences]];
}


//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self setCommentState];
	[self setIncludeState];
	[self setVersionState];
	[self setNotModified];
}

//---------------------------------------------------------------------
// setCommentState
//---------------------------------------------------------------------
-(void) setCommentState
{
	NSString *buttonString, *stringString;
	for (int x=1; x<=7; x++)
	{
		buttonString=[NSString stringWithFormat:@"headerIncludeComment%dOn",x];
		stringString=[NSString stringWithFormat:@"headerIncludeComment%d",x];
		[self enableObjectsAccordingToObject:[mOutlets objectForKey:buttonString], [mOutlets objectForKey:stringString],nil];
	
	}

}

//---------------------------------------------------------------------
// setIncludeState
//---------------------------------------------------------------------
-(void) setIncludeState
{
	NSString *buttonString, *stringString;
	for (int x=1; x<=12; x++)
	{
		buttonString=[NSString stringWithFormat:@"headerIncludeInclude%dOn",x];
		stringString=[NSString stringWithFormat:@"headerIncludeInclude%d",x];
		[self enableObjectsAccordingToObject:[mOutlets objectForKey:buttonString], [mOutlets objectForKey:stringString],nil];
	}

}

//---------------------------------------------------------------------
// setVersionState
//---------------------------------------------------------------------
-(void) setVersionState
{
	NSString *buttonString, *stringString;
	for (int x=1; x<=2; x++)
	{
		buttonString=[NSString stringWithFormat:@"headerIncludeVersion%dOn",x];
		stringString=[NSString stringWithFormat:@"headerIncludeVersion%d",x];
		[self enableObjectsAccordingToObject:[mOutlets objectForKey:buttonString], [mOutlets objectForKey:stringString],nil];
	}

}

//---------------------------------------------------------------------
// switchedOn:sender
//---------------------------------------------------------------------
- (IBAction)switchedOn:(id)sender
{
	NSInteger tag=[sender tag];
	if ( tag >=cHeaderIncludeComment1On && tag <=cHeaderIncludeComment7On)
		[self setCommentState];
	else if ( tag >=cHeaderIncludeInclude1On && tag <=cHeaderIncludeInclude12On)
		[self setIncludeState];
	else if ( tag >=cHeaderIncludeVersion1On && tag <=cHeaderIncludeVersion2On)
		[self setVersionState];
	[self setModified:nil];
	
}

@end
