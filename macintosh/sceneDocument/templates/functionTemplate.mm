//******************************************************************************
///
/// @file <File Name>
///
/// @todo   What's in here?
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
#import "functionTemplate.h"
#import "standardMethods.h"


@implementation FunctionTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	if ( dict== nil)
		dict=[FunctionTemplate createDefaults:menuTagTemplateFunctions];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[FunctionTemplate class] andTemplateType:menuTagTemplateFunctions];


	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
			return nil;
	}

	[dict retain];

	SFunctionListPtr data=[FunctionTemplate functionForIndex:[[dict objectForKey:@"referenceNumberOfSelectedFunction"]intValue]];
	if ( data)
	{
		NSString *s1=[NSString stringWithString:data->Syntax];
		NSRange rg=[s1 rangeOfString:@"("];
		if ( rg.location != NSNotFound)
		{
			s1=[s1 substringToIndex:rg.location+1];
		}
		[ds copyText:s1];
		
		switch (data->Pane)
		{
			case	Function_Empty:
				break;
			case Function_A:
				[ds appendFormat:@"%@)",[dict objectForKey:@"abViewA"]];
				break;
			case Function_AB:
				[ds appendFormat:@"%@, %@)",[dict objectForKey:@"abViewA"],[dict objectForKey:@"abViewB"]];
				break;
			case Function_S:
				[ds appendFormat:@"%@)",[dict objectForKey:@"s1s2ViewS1"]];
				break;


			case Function_ID:
				[ds appendFormat:@"%@)",[dict objectForKey:@"idaViewID"]];
				break;
			case Function_IDA:
				[ds appendFormat:@"%@, %@)",[dict objectForKey:@"idaViewID"],[dict objectForKey:@"idaViewA"]];
				break;
			case Function_IDV:
				[ds appendFormat:@"%@,<%@, %@, %@>)",[dict objectForKey:@"idaViewID"],[dict objectForKey:@"idvViewV0"],[dict objectForKey:@"idvViewV1"],[dict objectForKey:@"idvViewV2"]];
				break;
			case Function_ABC:
				[ds appendFormat:@"%@, %@, %@)",[dict objectForKey:@"abcdViewA"],[dict objectForKey:@"abcdViewB"],[dict objectForKey:@"abcdViewC"]];
				break;

			case Function_ABCD:
				[ds appendFormat:@"%@, %@, %@, %@)",[dict objectForKey:@"abcdViewA"],[dict objectForKey:@"abcdViewB"],[dict objectForKey:@"abcdViewC"],[dict objectForKey:@"abcdViewD"]];
				break;

			case Function_S1S2:
				[ds appendFormat:@"%@, %@)",[dict objectForKey:@"s1s2ViewS1"],[dict objectForKey:@"s1s2ViewS2"]];
				break;
			case Function_V1V2:
				[ds appendFormat:@"<%@, %@, %@>, <%@, %@, %@>)",[dict objectForKey:@"v1v2aViewV10"],[dict objectForKey:@"v1v2aViewV11"],[dict objectForKey:@"v1v2aViewV12"],
																								[dict objectForKey:@"v1v2aViewV20"],[dict objectForKey:@"v1v2aViewV21"],[dict objectForKey:@"v1v2aViewV22"]];
				break;
			case Function_V:
				[ds appendFormat:@"<%@, %@, %@>)",[dict objectForKey:@"idvViewV0"],[dict objectForKey:@"idvViewV1"],[dict objectForKey:@"idvViewV2"]];
				break;
			case Function_V1V2A:
				[ds appendFormat:@"<%@, %@, %@>, <%@, %@, %@>,)",[dict objectForKey:@"v1v2aViewV10"],[dict objectForKey:@"v1v2aViewV11"],[dict objectForKey:@"v1v2aViewV12"],
																								[dict objectForKey:@"v1v2aViewV20"],[dict objectForKey:@"v1v2aViewV21"],[dict objectForKey:@"v1v2aViewV22"],
																								[dict objectForKey:@"v1v2aViewA"]];
				break;
			case Function_SPL:
				[ds appendFormat:@"%@, %@, %@)",[dict objectForKey:@"splViewS"],[dict objectForKey:@"splViewP"],[dict objectForKey:@"splViewL"]];
				break;
			case Function_ALP:
				[ds appendFormat:@"%@, %@, %@)",[dict objectForKey:@"alpViewA"],[dict objectForKey:@"alpViewL"],[dict objectForKey:@"alpViewP"]];
				break;
			case Function_NVSLP:
				[ds appendFormat:@"<%@, %@",[dict objectForKey:@"nvslpViewV0"],[dict objectForKey:@"nvslpViewV1"]];
				switch ( [[dict objectForKey:@"nvslpViewN"]intValue])
				{
					case 0:
						[ds copyText:@", "];
						break;						
					case 2:	// 3 params
						[ds appendFormat:@", %@, ",[dict objectForKey:@"nvslpViewV2"]];
						break;
					case 3: // 4 params
						[ds appendFormat:@", %@, %@, ",[dict objectForKey:@"nvslpViewV2"],[dict objectForKey:@"nvslpViewV3"]];
						break;
					case 4: // 5 params
						[ds appendFormat:@", %@, %@, %@, ",[dict objectForKey:@"nvslpViewV2"],[dict objectForKey:@"nvslpViewV3"],[dict objectForKey:@"nvslpViewV4"]];
						break;
				}
				[ds appendFormat:@"%@, %@, %@) ",[dict objectForKey:@"nvslpViewS"],[dict objectForKey:@"nvslpViewP"],[dict objectForKey:@"nvslpViewL"]];
				break;
			case Function_XYZ:
				[ds appendFormat:@"%@, %@, %@) ",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				break;
			case Function_VLOO:	
				[ds appendFormat:@"<%@, %@, %@>, %@, %@, %@) ",[dict objectForKey:@"vlooViewV0"],[dict objectForKey:@"vlooViewV1"],[dict objectForKey:@"vlooViewV2"],
																						[dict objectForKey:@"vlooViewLa"],[dict objectForKey:@"vlooViewOm"],[dict objectForKey:@"vlooViewOc"]];
				break;
			case Function_XYZP0:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@)", [dict objectForKey:@"xyzpViewp0"]];
				break;
			case Function_XYZP0_P1:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@)", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"]];
				break;
			case Function_XYZP0_P2:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@)", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				break;
			case Function_XYZP0_P3:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				[ds appendFormat:@", %@)", [dict objectForKey:@"xyzpViewp3"]];
				break;
			case Function_XYZP0_P4:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				[ds appendFormat:@", %@, %@)", [dict objectForKey:@"xyzpViewp3"], [dict objectForKey:@"xyzpViewp4"]];
				break;
			case Function_XYZP0_P5:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				[ds appendFormat:@", %@, %@, %@)", [dict objectForKey:@"xyzpViewp3"], [dict objectForKey:@"xyzpViewp4"], [dict objectForKey:@"xyzpViewp5"]];
				break;
			case Function_XYZP0_P6:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp3"], [dict objectForKey:@"xyzpViewp4"], [dict objectForKey:@"xyzpViewp5"]];
				[ds appendFormat:@", %@)", [dict objectForKey:@"xyzpViewp6"]];
				break;
			case Function_XYZP0_P9:
				[ds appendFormat:@"%@, %@, %@",[dict objectForKey:@"xyzpViewX"],[dict objectForKey:@"xyzpViewY"],[dict objectForKey:@"xyzpViewZ"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp0"], [dict objectForKey:@"xyzpViewp1"], [dict objectForKey:@"xyzpViewp2"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp3"], [dict objectForKey:@"xyzpViewp4"], [dict objectForKey:@"xyzpViewp5"]];
				[ds appendFormat:@", %@, %@, %@", [dict objectForKey:@"xyzpViewp6"], [dict objectForKey:@"xyzpViewp7"], [dict objectForKey:@"xyzpViewp8"]];
				[ds appendFormat:@", %@)", [dict objectForKey:@"xyzpViewp9"]];
				break;
	
		}
	}

	
//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[FunctionTemplate createDefaults:menuTagTemplateFunctions];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"functionDefaultSettings",
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
		[NSNumber numberWithInt:F_All],	 					@"functionTypesPopup",
		[NSNumber numberWithInt:1],							@"referenceNumberOfSelectedFunction",
		@"x",	@"xyzpViewX",
		@"y",	@"xyzpViewY",
		@"z",	@"xyzpViewZ",
		@"1",	@"xyzpViewp0",
		@"1.5",	@"xyzpViewp1",
		@"1",	@"xyzpViewp2",
		@"0",	@"xyzpViewp3",
		@"0",	@"xyzpViewp4",
		@"",	@"xyzpViewp5",
		@"",	@"xyzpViewp6",
		@"",	@"xyzpViewp7",
		@"",	@"xyzpViewp8",
		@"",	@"xyzpViewp9",

		@"",	@"abViewA",
		@"",	@"abViewB",

		@"",	@"s1s2ViewS1",
		@"",	@"s1s2ViewS2",

		@"",	@"idaViewID",
		@"",	@"idaViewA",

		@"",	@"idvViewID",
		@"",	@"idvViewV0",
		@"",	@"idvViewV1",
		@"",	@"idvViewV2",

		@"",	@"abcdViewA",
		@"",	@"abcdViewB",
		@"",	@"abcdViewC",
		@"",	@"abcdViewD",

		@"",	@"alpViewA",
		@"",	@"alpViewL",
		@"",	@"alpViewP",

		@"",	@"splViewS",
		@"",	@"splViewP",
		@"",	@"splViewL",

		@"",	@"v1v2aViewV10",
		@"",	@"v1v2aViewV11",
		@"",	@"v1v2aViewV12",
		@"",	@"v1v2aViewV20",
		@"",	@"v1v2aViewV21",
		@"",	@"v1v2aViewV22",
		@"",	@"v1v2aViewA",

		[NSNumber numberWithInt:1],		@"nvslpViewN",
		@"",	@"nvslpViewV0",
		@"",	@"nvslpViewV1",
		@"",	@"nvslpViewV2",
		@"",	@"nvslpViewV3",
		@"",	@"nvslpViewV4",
		@"",	@"nvslpViewS",
		@"",	@"nvslpViewL",
		@"",	@"nvslpViewP",

		@"",	@"vlooViewV0",
		@"",	@"vlooViewV1",
		@"",	@"vlooViewV2",
		@"",	@"vlooViewLa",
		@"",	@"vlooViewOm",
		@"",	@"vlooViewOc",

	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[emptyView release];
	[xyzpView release];
	[abView release];
	[idaView release];
	[idvView release];
	[s1s2View release];
	[abcdView release];
	[alpView release];
	[splView release];
	[v1v2aView release];
	[nvslpView release];
	[vlooView release];
	if ( mCurrentFunctions != nil)
		delete mCurrentFunctions;
	[[NSNotificationCenter defaultCenter]removeObserver:self];
	[super dealloc];
}
	
//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	[emptyView retain];
	[xyzpView retain];
	[abView retain];
	[idaView retain];
	[idvView retain];
	[s1s2View retain];
	[abcdView retain];
	[alpView retain];
	[splView retain];
	[v1v2aView retain];
	[nvslpView retain];
	[vlooView retain];

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		functionTypesPopup,	 					@"functionTypesPopup",
		
		xyzpViewX,		@"xyzpViewX",
		xyzpViewY,		@"xyzpViewY",
		xyzpViewZ,		@"xyzpViewZ",
		xyzpViewp0,		@"xyzpViewp0",
		xyzpViewp1,		@"xyzpViewp1",
		xyzpViewp2,		@"xyzpViewp2",
		xyzpViewp3,		@"xyzpViewp3",
		xyzpViewp4,		@"xyzpViewp4",
		xyzpViewp5,		@"xyzpViewp5",
		xyzpViewp6,		@"xyzpViewp6",
		xyzpViewp7,		@"xyzpViewp7",
		xyzpViewp8,		@"xyzpViewp8",
		xyzpViewp9,		@"xyzpViewp9",

		abViewA,			@"abViewA",
		abViewB,			@"abViewB",

		s1s2ViewS1,		@"s1s2ViewS1",
		s1s2ViewS2,		@"s1s2ViewS2",

		idaViewID,			@"idaViewID",
		idaViewA,			@"idaViewA",

		idvViewID,			@"idvViewID",
		idvViewV0,		@"idvViewV0",
		idvViewV1,		@"idvViewV1",
		idvViewV2,		@"idvViewV2",

		abcdViewA,		@"abcdViewA",
		abcdViewB,		@"abcdViewB",
		abcdViewC,		@"abcdViewC",
		abcdViewD,		@"abcdViewD",

		alpViewA,			@"alpViewA",
		alpViewL,			@"alpViewL",
		alpViewP,			@"alpViewP",

		splViewS,			@"splViewS",
		splViewP,			@"splViewP",
		splViewL,			@"splViewL",

		v1v2aViewV10,	@"v1v2aViewV10",
		v1v2aViewV11,	@"v1v2aViewV11",
		v1v2aViewV12,	@"v1v2aViewV12",
		v1v2aViewV20,	@"v1v2aViewV20",
		v1v2aViewV21,	@"v1v2aViewV21",
		v1v2aViewV22,	@"v1v2aViewV22",
		v1v2aViewA,		@"v1v2aViewA",

		nvslpViewN,		@"nvslpViewN",
		nvslpViewV0,		@"nvslpViewV0",
		nvslpViewV1,		@"nvslpViewV1",
		nvslpViewV2,		@"nvslpViewV2",
		nvslpViewV3,		@"nvslpViewV3",
		nvslpViewV4,		@"nvslpViewV4",
		nvslpViewS,		@"nvslpViewS",
		nvslpViewL,		@"nvslpViewL",
		nvslpViewP,		@"nvslpViewP",

		vlooViewV0,		@"vlooViewV0",
		vlooViewV1,		@"vlooViewV1",
		vlooViewV2,		@"vlooViewV2",
		vlooViewLa,		@"vlooViewLa",
		vlooViewOm,		@"vlooViewOm",
		vlooViewOc,		@"vlooViewOc",

	nil] ;
	[mOutlets retain];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(tableViewSelectionDidChange:)
		name:NSTableViewSelectionDidChangeNotification
		object:functionTableView];

	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self buildCurrentFunctions:[[preferences objectForKey:@"functionTypesPopup"]intValue]];
	int index=[self findCurrentIndexForReference:[[preferences objectForKey:@"referenceNumberOfSelectedFunction"]intValue]];
	[super setValuesInPanel:[self preferences]];
	[functionTableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self updateViews];
	[self setNotModified];

}

//---------------------------------------------------------------------
// findCurrentIndexForReference
//---------------------------------------------------------------------
-(int) findCurrentIndexForReference:(int)reference
{
	if ( mCurrentFunctions==nil)
		return 0;
		
	int x=0;
	for (x=0; x<=mItems; x++)
	{
		if ( mCurrentFunctions[x].RefNr==reference)
			return x;
	}
	return 0;
}

//---------------------------------------------------------------------
// findIndexForReference
//---------------------------------------------------------------------
+(SFunctionListPtr) functionForIndex:(int)reference
{
	int x=0;
	while (FunctionList[x].Kind != Endlist)
	{
		if ( FunctionList[x].RefNr==reference)
			return &FunctionList[x];
		x++;
	};
	return nil;
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];
	NSMutableDictionary *dict=[self preferences];
	if ( dict )
	{
		int row=[functionTableView selectedRow];
		[dict setObject:[NSNumber numberWithInt:mCurrentFunctions[row].RefNr]	 forKey:@"referenceNumberOfSelectedFunction"];
	}
}

//---------------------------------------------------------------------
// buildCurrentFunctions
//---------------------------------------------------------------------
-(void) buildCurrentFunctions:(int) type
{
	if ( mCurrentFunctions != nil)
		delete mCurrentFunctions;
	int x=0;
	mItems=0;
	while (FunctionList[x].Kind != Endlist)
	{
		if ( FunctionList[x].Kind==type || type==F_All)
			mItems++;
		x++;
	};
	
	mCurrentFunctions=new SFunctionList[mItems];
	
	x=0;
	int item=0;
	while (FunctionList[x].Kind != Endlist)
	{
		if ( FunctionList[x].Kind==type || type==F_All)
		{
			memcpy(&mCurrentFunctions[item], &FunctionList[x], sizeof(SFunctionList));
			item++;
		}
		x++;
	};
	[functionTableView noteNumberOfRowsChanged];

}

//---------------------------------------------------------------------
// functionTypesPopup
//---------------------------------------------------------------------
-(void) updateViews
{
	int row=[functionTableView selectedRow];

	
	if ( row != -1) 	//a row is selected
	{
		NSString *ds=[NSString stringWithUTF8String:mCurrentFunctions[row].Description];
		if ( ds == nil)
			[functionDescriptionView setString:@""];
		else
			[functionDescriptionView setString:ds];
 
		NSTabViewItem *tvi=[mainTabView tabViewItemAtIndex:0];
		id currentView=[tvi view];
		NSRect rc=[currentView frame];
		switch(mCurrentFunctions[row].Pane)
		{
			case Function_Empty:
				[tvi setView:emptyView];
				break;
			default:
				[tvi setView:abView];
				break;			
			case Function_A:
			case Function_AB:
				[tvi setView:abView];
				if( mCurrentFunctions[row].Pane == Function_A)
					[abViewB setHidden:YES];
				else
					[abViewB setHidden:NO];
				
				break;
			case Function_S:
			case Function_S1S2:
				[tvi setView:s1s2View];
				if( mCurrentFunctions[row].Pane == Function_S)
					[s1s2ViewS2 setHidden:NO];
				else
					[s1s2ViewS2 setHidden:YES];

				break;
			case Function_V1V2:
			case Function_V:
			case Function_V1V2A:
				[tvi setView:v1v2aView];
				if( mCurrentFunctions[row].Pane == Function_V)
				{
					[v1v2aViewV20 setHidden:YES];		[v1v2aViewV21 setHidden:YES];			[v1v2aViewV22 setHidden:YES];
					[v1v2aViewA setHidden:YES];
				}
				else if( mCurrentFunctions[row].Pane == Function_V1V2)
				{
					[v1v2aViewV20 setHidden:NO];		[v1v2aViewV21 setHidden:NO];			[v1v2aViewV22 setHidden:NO];
					[v1v2aViewA setHidden:YES];
				}
				else
				{
					[v1v2aViewV20 setHidden:NO];		[v1v2aViewV21 setHidden:NO];			[v1v2aViewV22 setHidden:NO];
					[v1v2aViewA setHidden:NO];
				}
	
				break;
			case Function_SPL:
				[tvi setView:splView];
				break;
			case Function_ALP:
				[tvi setView:alpView];
				break;
			case Function_NVSLP:
				[tvi setView:nvslpView];
				break;
			case Function_VLOO:
				[tvi setView:vlooView];
				break;
			case Function_ABCD:
			case Function_ABC:
				[tvi setView:abcdView];
				if( mCurrentFunctions[row].Pane == Function_ABC)
					[abcdViewD setHidden:YES];
				else
					[abcdViewD setHidden:NO];

				break;
			case Function_ID:
			case Function_IDA:
				[tvi setView:idaView];
				break;
			case Function_IDV:
				[tvi setView:idvView];
				break;
		
			case Function_XYZ:
			case Function_XYZP0:
			case Function_XYZP0_P1:
			case Function_XYZP0_P2:
			case Function_XYZP0_P3:
			case Function_XYZP0_P4:
			case Function_XYZP0_P5:
			case Function_XYZP0_P6:
			case Function_XYZP0_P9:
				[tvi setView:xyzpView];
				switch (mCurrentFunctions[row].Pane)
				{
					case Function_XYZ:
						[xyzpViewp0 setHidden:YES]; [xyzpViewp1 setHidden:YES]; [xyzpViewp2 setHidden:YES]; [xyzpViewp3 setHidden:YES]; [xyzpViewp4 setHidden:YES];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:YES]; [xyzpViewp2 setHidden:YES]; [xyzpViewp3 setHidden:YES]; [xyzpViewp4 setHidden:YES];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P1:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:YES]; [xyzpViewp3 setHidden:YES]; [xyzpViewp4 setHidden:YES];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P2:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:YES]; [xyzpViewp4 setHidden:YES];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P3:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:NO]; [xyzpViewp4 setHidden:YES];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P4:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:NO]; [xyzpViewp4 setHidden:NO];
						[xyzpViewp5 setHidden:YES]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P5:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:NO]; [xyzpViewp4 setHidden:NO];
						[xyzpViewp5 setHidden:NO]; [xyzpViewp6 setHidden:YES]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P6:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:NO]; [xyzpViewp4 setHidden:NO];
						[xyzpViewp5 setHidden:NO]; [xyzpViewp6 setHidden:NO]; [xyzpViewp7 setHidden:YES]; [xyzpViewp8 setHidden:YES]; [xyzpViewp9 setHidden:YES];
						break;
					case Function_XYZP0_P9:
						[xyzpViewp0 setHidden:NO]; [xyzpViewp1 setHidden:NO]; [xyzpViewp2 setHidden:NO]; [xyzpViewp3 setHidden:NO]; [xyzpViewp4 setHidden:NO];
						[xyzpViewp5 setHidden:NO]; [xyzpViewp6 setHidden:NO]; [xyzpViewp7 setHidden:NO]; [xyzpViewp8 setHidden:NO]; [xyzpViewp9 setHidden:NO];
						break;
				}
				break;
		}
			currentView=[tvi view];
		[currentView setFrame:rc];

	}
}

//---------------------------------------------------------------------
// functionTypesPopup
//---------------------------------------------------------------------
- (IBAction)functionTypesPopup:(id)sender
{
	[self buildCurrentFunctions:[sender indexOfSelectedItem]];
	[functionTableView noteNumberOfRowsChanged];
	[self updateViews];
}

// datasource
//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return mItems;
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	switch( [[tableColumn identifier]intValue])
	{
		case 1:	//syntax
			return mCurrentFunctions[row].Syntax;
			break;
		case 2:	//result
			return mCurrentFunctions[row].Result;
			break;
		default:
			return nil;
	}
}

//---------------------------------------------------------------------
// tableViewSelectionDidChange
//---------------------------------------------------------------------
- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	[self updateViews];
}



@end
