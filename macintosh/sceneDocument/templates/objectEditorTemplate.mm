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
#import "objectEditorTemplate.h"

// this must be the last file included
#import "syspovdebug.h"

enum {
	cPolygonMap=0,
	cPrismmap=1,
	cSormap=2,
	cLatheMap=3
};

@implementation ObjectEditorTemplate


//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{
	//nothing here,
	// handled in objectTemplate

	return nil;
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	[ObjectEditorTemplate createDefaults:menuTagTemplateAllObjectmaps];
}

//---------------------------------------------------------------------
// createDefaults
//---------------------------------------------------------------------
// if templateType is menuTagTemplateAllObjectmaps all default maps
// will be created.
// if templateType is of type lathe, polygon, prism or sor,
// only that map will be created and returned. No defaults will
// be written in that case.
//---------------------------------------------------------------------
+(NSMutableDictionary *) createDefaults:(unsigned int) templateType
{
	
	NSDictionary *factoryDefaults=nil;
	NSMutableDictionary *initialDefaults=nil;
	
	NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];

	if (templateType == menuTagTemplateAllObjectmaps || templateType== menuTagTemplateLathe)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[objectmap standardMap:menuTagTemplateLathe withView:nil]],	@"objectmap",
								@"6",																					@"drawPointsEdit",
								[NSNumber numberWithInt:cFirstCell],			@"objectEditorActionOnPoints",
								@"0.1",														@"objectEditorScaleEdit",
								@"5",															@"objectEditorRotateEdit",
								@"0.1",														@"objectEditorMoveEdit",
							nil];
		if ( templateType==menuTagTemplateAllObjectmaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:		
									initialDefaults,@"lathemapDefaultSettings",nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}

	if (templateType == menuTagTemplateAllObjectmaps || templateType== menuTagTemplatePolygon)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[objectmap standardMap:menuTagTemplatePolygon withView:nil]],	@"objectmap",
								@"6",																					@"drawPointsEdit",
								[NSNumber numberWithInt:cFirstCell],			@"objectEditorActionOnPoints",
								@"0.1",														@"objectEditorScaleEdit",
								@"5",															@"objectEditorRotateEdit",
								@"0.1",														@"objectEditorMoveEdit",
							nil];
		if ( templateType==menuTagTemplateAllObjectmaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"pigmentmapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}
	
	if (templateType == menuTagTemplateAllObjectmaps || templateType== menuTagTemplatePrism)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[objectmap standardMap:menuTagTemplatePrism withView:nil]],	@"objectmap",
								@"6",																					@"drawPointsEdit",
								[NSNumber numberWithInt:cFirstCell],			@"objectEditorActionOnPoints",
								@"0.1",														@"objectEditorScaleEdit",
								@"5",															@"objectEditorRotateEdit",
								@"0.1",														@"objectEditorMoveEdit",
							nil];
		if ( templateType==menuTagTemplateAllObjectmaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"prismmapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}
	
	if (templateType == menuTagTemplateAllObjectmaps || templateType== menuTagTemplateSor)
	{
		initialDefaults=[NSMutableDictionary dictionaryWithObjectsAndKeys:
								[NSArchiver archivedDataWithRootObject:[objectmap standardMap:menuTagTemplateSor withView:nil]],	@"objectmap",
								@"6",																					@"drawPointsEdit",
								[NSNumber numberWithInt:cFirstCell],			@"objectEditorActionOnPoints",
								@"0.1",														@"objectEditorScaleEdit",
								@"5",															@"objectEditorRotateEdit",
								@"0.1",														@"objectEditorMoveEdit",
							nil];
		if ( templateType==menuTagTemplateAllObjectmaps)
		{
			factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
				initialDefaults,@"sormapDefaultSettings",
				nil];
			[defaults registerDefaults:factoryDefaults];
		}
		else
			return initialDefaults;
	}

	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	switch (mTemplateType)
	{
		case menuTagTemplateSor:
		case menuTagTemplatePrism:
		case menuTagTemplatePolygon:
			[[yColumn headerCell]setStringValue:@"y-Value"];
			break;
		case menuTagTemplateLathe:
			[[yColumn headerCell]setStringValue:@"z-Depth"];
			break;
	}

	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		drawPointsEdit,						@"drawPointsEdit",
		objectEditorActionOnPoints,		@"objectEditorActionOnPoints",
		objectEditorScaleEdit,				@"objectEditorScaleEdit",
		objectEditorRotateEdit,			@"objectEditorRotateEdit",
		objectEditorMoveEdit,				@"objectEditorMoveEdit",
	nil];

	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"objectEditorLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"objectEditorLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			objectEditorTableView,		@"objectEditorTableView",
			SlopeButton,		@"SlopeButton",
			PointButton,		@"PointButton",
			CurveButton,		@"CurveButton",
			RasterButton,		@"RasterButton",
			splineTypePopUp,		@"splineTypePopUp",
			yColumn,		@"yColumn",
			objectEditorDrawNowButton,					@"objectEditorDrawNowButton",
			objectEditorAddButton,		@"objectEditorAddButton",

			objectEditorInsertButton,		@"objectEditorInsertButton",
			objectEditorTrashButton,		@"objectEditorTrashButton",
			objectEditorApplyScaleButton,		@"objectEditorApplyScaleButton",
			objectEditorApplyRotateButton,		@"objectEditorApplyRotateButton",
			objectEditorApplyMoveLeftButton,		@"objectEditorApplyMoveLeftButton",
			objectEditorApplyMoveRightButton,		@"objectEditorApplyMoveRightButton",
			objectEditorApplyMoveUpButton,		@"objectEditorApplyMoveUpButton",
			objectEditorApplyMoveDownButton,		@"objectEditorApplyMoveDownButton",
		nil]
		];

	[self  setValuesInPanel:[self preferences]];
	if ( mTemplateType == menuTagTemplateSor || mTemplateType==menuTagTemplatePolygon)
	{
		[splineTypePopUp setHidden:YES];
		[splineTypeText setHidden:YES];
		[mMap setButtonState:cLinearSpline forButton:cSplineTypePopUp];	// will show/hide slopebutton
	}
}

//---------------------------------------------------------------------
// slopemapButtons
//---------------------------------------------------------------------
-(IBAction) objectmapmapButtons:(id)sender
{
	switch( [sender tag])
	{
		case cSplineTypePopUp:
			[mMap setButtonState:[sender indexOfSelectedItem] forButton:cSplineTypePopUp];
			[self updateControls];
			break;
		case cSlopeButton:
		case cPointButton:	
		case cCurveButton:	
		case cRasterButton:
			[mMap setButtonState:[sender state] forButton:[sender tag]];
			break;
		case cDrawPointsButton:
			// this will build a new map
			// update the preview
			// keep the spline type
			[mMap makeMapWithPoints:[drawPointsEdit floatValue]];
		 	[ mTableView noteNumberOfRowsChanged];
			[self updateControls];	
			break;
		
		case cObjectEditorApplyScale:
		case cObjectEditorApplyRotate:
			[self applyScaleRotate:[sender tag]];
			break;
		case cObjectEditorMoveUp:
		case cObjectEditorMoveRight:
		case cObjectEditorMoveDown:
		case cObjectEditorMoveLeft:
			[self applyArrows:[sender tag]];
			break;
		
	}
}



// ---------------------------------------------------------------------------
//	setPointToMin: thePoint
// ---------------------------------------------------------------------------
//	See if a point can be les then zero
// ---------------------------------------------------------------------------

-(void) setPointToMin:(float & ) theValue thePoint:(NSInteger&)thePoint
{
	if ( mTemplateType == menuTagTemplateLathe )
	{
			if ( thePoint >=2 && thePoint < ([mMap count]-1) && theValue < 0.0)
				theValue=0.0;
	}
	else if ( mTemplateType == menuTagTemplateSor && theValue < 0.0)
			theValue =0.0;
}	

//---------------------------------------------------------------------
// applyArrows
//---------------------------------------------------------------------
-(void) applyArrows:(int) tag
{
	const char* t=[[objectEditorMoveEdit stringValue] UTF8String];
	float value=atof(t);
	float temp; 
	for( NSInteger ct=0; ct<[mMap count]; ct++)
	{	
		if ([ [objectEditorActionOnPoints selectedCell]tag]==cObjectAllPoints || [mTableView isRowSelected:ct])
		{
			switch (tag)
			{
				case cObjectEditorMoveLeft: 
					temp=[mMap floatAtRow:ct atColumn:cObjectmapXIndex];
					temp-=value;
					[self setPointToMin:temp thePoint:ct];
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapXIndex];
					break;
				case cObjectEditorMoveRight:
					temp=[mMap floatAtRow:ct atColumn:cObjectmapXIndex];
					temp+=value;
					[self setPointToMin:temp thePoint:ct];
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapXIndex];
					break;
				case cObjectEditorMoveDown:
					temp=[mMap floatAtRow:ct atColumn:cObjectmapYIndex];
					temp-=value;
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapYIndex];
					break;
				case cObjectEditorMoveUp:
					temp=[mMap floatAtRow:ct atColumn:cObjectmapYIndex];
					temp+=value;
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapYIndex];
					break;
			}			
		}
	}
	[mMap setViewDirty];
		[mTableView reloadData];		// redraw the table

}

//---------------------------------------------------------------------
// applyScaleRotate
//---------------------------------------------------------------------
-(void) applyScaleRotate:(int)tag
{
	const char* t;
	float value=0.0;
	float temp;
	switch (tag)
	{
		case cObjectEditorApplyScale: 
			t=[[objectEditorScaleEdit stringValue] UTF8String];
			value=atof(t);
			break;
		case cObjectEditorApplyRotate:
			t=[[objectEditorRotateEdit stringValue] UTF8String];
			value=atof(t);
			break;
	}
	
	
	if ( tag==cObjectEditorApplyScale)
	{
		for( NSInteger ct=0; ct<[mMap count]; ct++)
		{	
			if ([ [objectEditorActionOnPoints selectedCell]tag]==cObjectAllPoints || [mTableView isRowSelected:ct])
			{
					temp=[mMap floatAtRow:ct atColumn:cObjectmapXIndex];
					temp*=value;
					[self setPointToMin:temp thePoint:ct];
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapXIndex];

					temp=[mMap floatAtRow:ct atColumn:cObjectmapYIndex];
					temp*=value;
					[self setPointToMin:temp thePoint:ct];
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapYIndex];
			}
		}
	}
	else		//rotate
	{
		float radGr=3.1415927/180.0*value;
		float tempx;
		for( NSInteger ct=0; ct<[mMap count]; ct++)
		{	
			if ([ [objectEditorActionOnPoints selectedCell]tag]==cObjectAllPoints || [mTableView isRowSelected:ct])
			{
				float height,location;
				
					location=[mMap floatAtRow:ct atColumn:cObjectmapXIndex];
					height=[mMap floatAtRow:ct atColumn:cObjectmapYIndex];
					tempx=height *-sin(radGr) + location * cos(radGr);
					temp=height *cos(radGr) - location * -sin(radGr);
					[mMap setFloat:temp atRow:ct atColumn:cObjectmapYIndex];
					[self setPointToMin:tempx thePoint:ct];
					[mMap setFloat:tempx atRow:ct atColumn:cObjectmapXIndex];
			}
		}
	}
	[mMap setViewDirty];
	[mTableView reloadData];		// redraw the table
	
}

//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	
	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];
	if (dict == nil)
		return;
	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"objectmap"];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
 	[self setMap:[NSUnarchiver unarchiveObjectWithData:[preferences objectForKey:@"objectmap"]]];
 	[mMap setPreview:previewView];
	[SlopeButton setState:[mMap buttonState:cSlopeButton]];
	[PointButton setState:[mMap buttonState:cPointButton]];
	[CurveButton setState:[mMap buttonState:cCurveButton]];
	[RasterButton setState:[mMap buttonState:cRasterButton]];
	[splineTypePopUp selectItemAtIndex:[mMap buttonState:cSplineTypePopUp]];
 	[mTableView noteNumberOfRowsChanged];
	[super  setValuesInPanel:preferences];
	[self updateControls];	
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	switch ([mMap buttonState:cSplineTypePopUp])
	{
		case cLinearSpline:
		case cQuadraticSpline:
		case cCubicSpline:
			[SlopeButton setHidden:YES];
			break;
		case cBezierSpline:
				[SlopeButton setHidden:NO];
				break;
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:@"NSTableViewSelectionDidChangeNotification" object:mTableView];
//	[self tableViewSelectionDidChange:nil];
	[self setButtons];
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	NSString *str=@"Err";

	if ( [identifier isEqualToString:@"nr"])
	{
		if (mTemplateType == menuTagTemplateSor || [mMap buttonState:cSplineTypePopUp]==cCubicSpline)
		{
			if ( rowIndex == 0)
				str=@"Cs";
			else if ( rowIndex == [mMap count]-1)
				str=@"Ce";
			else
				str=[NSString stringWithFormat:@"%ld",(long)rowIndex];
		}
		else if (mTemplateType == menuTagTemplatePolygon || ( (mTemplateType == menuTagTemplatePrism || mTemplateType == menuTagTemplateLathe) && [mMap buttonState:cSplineTypePopUp]==cLinearSpline))
			str=[NSString stringWithFormat:@"%ld",rowIndex+1];
		else if (  (mTemplateType == menuTagTemplatePrism || mTemplateType == menuTagTemplateLathe) && [mMap buttonState:cSplineTypePopUp]==cQuadraticSpline)
		{
			if ( rowIndex == 0)
				str=@"Cs";
			else
				str=[NSString stringWithFormat:@"%ld",(long)rowIndex];
		}
		else if (  [mMap buttonState:cSplineTypePopUp]==cBezierSpline)
		{
			NSInteger SelectedSegment=(rowIndex/4)+1;

			if ( rowIndex == 0 )																//first point always start of segment
				str=[NSString stringWithFormat:@"S %d",SelectedSegment];
			else if ( rowIndex == [mMap count]-1)									//last point always end of a segment
				str=[NSString stringWithFormat:@"E %d",SelectedSegment];
			else if ( (((rowIndex+1)/2) & 1)	&& ((rowIndex+1) % 2==0))					// First controlpoint of a segment
				str=[NSString stringWithFormat:@"Cs %d",SelectedSegment];
			else if ( (rowIndex+1) % 4 == 0 )														// end of a segment
				str=[NSString stringWithFormat:@"E %d",SelectedSegment];
			else if ( rowIndex % 4 == 0)												//start of a segment
				str=[NSString stringWithFormat:@"S %d",SelectedSegment];
			else																						//must be last controlpoint of a segment
				str=[NSString stringWithFormat:@"Ce %d",SelectedSegment];
		}	


		return str;
	}
	else if ( [identifier isEqualToString:@"x"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cObjectmapXIndex];
	else if ( [identifier isEqualToString:@"y"])
		return [mMap stringFromFloatWithFormat:FloatFormat atRow:rowIndex atColumn:cObjectmapYIndex];
	return nil;

}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
	if ( [identifier isEqualToString:@"x"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cObjectmapXIndex];
	else if ( [identifier isEqualToString:@"y"])
		[mMap setObject:anObject atRow:rowIndex atColumn:cObjectmapYIndex];
	[mTableView reloadData];		// redraw the table
}


	
@end


