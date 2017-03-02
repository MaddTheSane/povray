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
#import "objectEditorPreview.h"
#import "objectmap.h"
#import "basetemplate.h"


@implementation objectmap

//---------------------------------------------------------------------
// standardLatheMapWithView
//---------------------------------------------------------------------
+(id) standardMap:(int) type withView:(id)view
{
	objectmap *c=[[objectmap alloc] init];	 
	[c setButtonState:cLinearSpline forButton:cSplineTypePopUp];
	[c setButtonState:NSOnState forButton:cSlopeButton];
	[c setButtonState:NSOnState forButton:cPointButton];
	[c setButtonState:NSOnState forButton:cCurveButton];
	[c setButtonState:NSOnState forButton:cRasterButton];
	[c setTemplateType:type];
	[c makeMapWithPoints:6];
	[c setPreview:view];	
	[c autorelease]; 
	return c;
}

//---------------------------------------------------------------------
// setTemplateType
//---------------------------------------------------------------------
-(void) setTemplateType:(int)type
{
	mTemplateType=type;
}

//---------------------------------------------------------------------
// templateType
//---------------------------------------------------------------------
-(int) templateType
{
	return mTemplateType;
}

//---------------------------------------------------------------------
// makeMap: withPoint
//---------------------------------------------------------------------
-(void) makeMapWithPoints:(int)numberOfPoints 
{
	switch ([self templateType])
	{
		case menuTagTemplatePolygon: 	numberOfPoints++;	break;
		case menuTagTemplateLathe	:
		case menuTagTemplatePrism:
			switch( [self buttonState:cSplineTypePopUp])
			{
				case cLinearSpline:			numberOfPoints++;	break;
				case cQuadraticSpline:	numberOfPoints+=2;	break;
				case cCubicSpline:			numberOfPoints+=3;	break;
				case cBezierSpline:			numberOfPoints*=4;	break;
			}
			break;
		case menuTagTemplateSor	:numberOfPoints+=3;	break;
	}
		
	switch ([self templateType])
	{
		case menuTagTemplatePolygon:
			[self buildPolygonmap:numberOfPoints];
			break;
		case menuTagTemplateLathe:
			switch( [self buttonState:cSplineTypePopUp])
			{
				case cLinearSpline:
				case cQuadraticSpline:
				case cCubicSpline:
					[self buildSormap:numberOfPoints];
					break;
				case cBezierSpline:
					[self buildLathemap:numberOfPoints];
					break;		
			}
			break;
		case menuTagTemplateSor:
			[self buildSormap:numberOfPoints];
			break;
		case menuTagTemplatePrism:
			[self buildPrismmap:numberOfPoints];
			break;
	}
}

//---------------------------------------------------------------------
// buildPolygonmap:numberOfPoints
//---------------------------------------------------------------------
-(void)	buildPolygonmap:(int)numberOfPoints
{
	NSMutableArray *mainArray=nil;
	NSMutableArray *subArray=nil;
	int counter;

	double Degrees=(360.0/(double)(numberOfPoints-1))*(3.1415926535897932384626)/180.0;
	for (counter=1; counter<=numberOfPoints; counter++)
	{
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:cos(Degrees*(double)(counter-1))]];
		[subArray addObject:[NSNumber numberWithFloat:sin(Degrees*(double)(counter-1))]];

		if ( mainArray==nil)	//no entry yet
			mainArray=[NSMutableArray arrayWithObject:subArray];
		else
			[mainArray addObject:subArray];
	}
	[self setArray:mainArray];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buildSormap:numberOfPoints
//---------------------------------------------------------------------
-(void)	buildSormap:(int)numberOfPoints
{
	NSMutableArray *mainArray=nil;
	NSMutableArray *subArray=nil;
	int counter;

	int startPoint=1,endPoint=1,decreaser=0,counterdecreaser=2;
	if ( [self templateType]==menuTagTemplateSor)
	{
		startPoint=2;
		endPoint=numberOfPoints-1;
		decreaser=2;
		counterdecreaser=2;
		mainArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
	}
	else
	{
		switch( [self buttonState:cSplineTypePopUp])
		{
			case cLinearSpline:			
				startPoint=1;	endPoint=numberOfPoints; decreaser=0; counterdecreaser=1; 	break;
			case cQuadraticSpline:	
				//temporary object at index 0
				// just to be able to add objects from index 1
				mainArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
				startPoint=2;		endPoint=numberOfPoints;			decreaser=1;		counterdecreaser=2;		break;
			case cCubicSpline:			
				//temporary object at index 0
				// just to be able to add objects from index 1
				mainArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
				startPoint=2;		endPoint=numberOfPoints-1;		decreaser=2;		counterdecreaser=2;		break;
		}
	}
		
	double s90=-90.0*(3.1415926535897932384626)/180.0;
	double Degrees=(180.0/(double)(numberOfPoints-(1+decreaser)))*(3.1415926535897932384626)/180.0;
	for (counter=startPoint; counter<=endPoint; counter++)
	{
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.5*cos(s90+(Degrees*(double)(counter-counterdecreaser)))]];
		[subArray addObject:[NSNumber numberWithFloat:0.5+(0.5*sin(s90+(Degrees*(double)(counter-counterdecreaser))))]];

		if ( mainArray==nil)	//no entry yet
			mainArray=[NSMutableArray arrayWithObject:subArray];
		else
			[mainArray addObject:subArray];
		subArray=nil;

	}
	if ( [self templateType]==menuTagTemplateSor || [self buttonState:cSplineTypePopUp] == cQuadraticSpline || [self buttonState:cSplineTypePopUp]==cCubicSpline)
	{
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
		[subArray addObject:[NSNumber numberWithFloat:0.0]];
		[mainArray replaceObjectAtIndex:0 withObject:subArray];
	}
	if ([self templateType]==menuTagTemplateSor || [self buttonState:cSplineTypePopUp] == cCubicSpline )
	{
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];
		[subArray addObject:[NSNumber numberWithFloat:1.0]];
		[mainArray addObject:subArray];
	}
	[self setArray:mainArray];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buildLathemap:numberOfPoints
//---------------------------------------------------------------------
-(void)	buildLathemap:(int)numberOfPoints
{
	NSMutableArray *mainArray=nil;
	NSMutableArray *subArray=nil;
	int counter;

	int Segments=numberOfPoints/4;

	if ( Segments > 1)
		Segments=numberOfPoints-(Segments-1);
	else
		Segments=numberOfPoints;
		
	double s90=-90.0*(3.1415926535897932384626)/180.0;
	double Degrees=(180.0/(double)(Segments-1))*(3.1415926535897932384626)/180.0;


	for (counter=1,Segments=1; counter<=numberOfPoints; counter++,Segments++)
	{
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.5*cos(s90+(Degrees*(double)(Segments-1)))]];
		[subArray addObject:[NSNumber numberWithFloat:0.5+(0.5*sin(s90+(Degrees*(double)(Segments-1))))]];

		if ( mainArray==nil)	//no entry yet
			mainArray=[NSMutableArray arrayWithObject:subArray];
		else
			[mainArray addObject:subArray];
		subArray=nil;

		if ( counter % 4 ==0 && ( counter != 1 && counter != numberOfPoints))
		{
			//duplicate entry
			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.5*cos(s90+(Degrees*(double)(Segments-1)))]];
			[subArray addObject:[NSNumber numberWithFloat:0.5+(0.5*sin(s90+(Degrees*(double)(Segments-1))))]];
			[mainArray addObject:subArray];
			subArray=nil;
			counter ++;
		}
	}
	[self setArray:mainArray];
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buildPrismmap:numberOfPoints
//---------------------------------------------------------------------
-(void)	buildPrismmap:(int)numberOfPoints
{
	NSMutableArray *mainArray=nil;
	NSMutableArray *subArray=nil;
	int counter;
	int NumberOfPoints=numberOfPoints;
	double Degrees;

	if ( [self buttonState:cSplineTypePopUp] == cLinearSpline)
	{
		Degrees=(360.0/(double)(NumberOfPoints-1))*(3.1415926535897932384626)/180.0;
		for (counter=1; counter<=numberOfPoints; counter++)
		{
			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:cos(Degrees*(double)(counter-1))]];
			[subArray addObject:[NSNumber numberWithFloat:sin(Degrees*(double)(counter-1))]];

			if ( mainArray==nil)	//no entry yet
				mainArray=[NSMutableArray arrayWithObject:subArray];
			else
				[mainArray addObject:subArray];
			subArray=nil;
		}
	}
	else if ( [self buttonState:cSplineTypePopUp] == cQuadraticSpline)
	{
		Degrees=(360.0/(double)(NumberOfPoints-2))*(3.1415926535897932384626)/180.0;
		for (counter=1; counter<=numberOfPoints-1; counter++)
		{
			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:cos(Degrees*(double)(counter-1))]];
			[subArray addObject:[NSNumber numberWithFloat:sin(Degrees*(double)(counter-1))]];

			if ( mainArray==nil)	//no entry yet
				mainArray=[NSMutableArray arrayWithObject:subArray];
			else
				[mainArray addObject:subArray];
			subArray=nil;
		}
		subArray=[NSMutableArray arrayWithObject:[[mainArray objectAtIndex:1] objectAtIndex:0]];
		if(mainArray != nil)
			[subArray addObject:[[mainArray objectAtIndex:1] objectAtIndex:1]];
		[mainArray addObject:subArray];
	}
	else if ( [self buttonState:cSplineTypePopUp] == cCubicSpline)
	{
		Degrees=(360.0/(double)(NumberOfPoints-3))*(3.1415926535897932384626)/180.0;
		//temporary object at index 0
		// just to be able to add objects from index 1
		mainArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:0.0]];

		for (counter=2; counter<=numberOfPoints-1; counter++)
		{
			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:cos(Degrees*(double)(counter-2))]];
			[subArray addObject:[NSNumber numberWithFloat:sin(Degrees*(double)(counter-2))]];
			if ( mainArray==nil)	//no entry yet
				mainArray=[NSMutableArray arrayWithObject:subArray];
			else
				[mainArray addObject:subArray];
			subArray=nil;
		}
		subArray=[NSMutableArray arrayWithObject:[[mainArray objectAtIndex:2] objectAtIndex:0]];
		[subArray addObject:[[mainArray objectAtIndex:2] objectAtIndex:1]];
		[mainArray addObject:subArray];

		subArray=[NSMutableArray arrayWithObject:[[mainArray objectAtIndex:numberOfPoints-3] objectAtIndex:0]];
		[subArray addObject:[[mainArray objectAtIndex:numberOfPoints-3] objectAtIndex:1]];
		[mainArray replaceObjectAtIndex:0 withObject:subArray];
	}

	else
	{
		int counter=1;
		int temp=NumberOfPoints/4;
		Degrees=(360.0/(double)(temp))*(3.1415926535897932384626)/180.0;
		for ( int cnt=1; cnt <=NumberOfPoints; cnt+=4,counter++)
		{
			double p1x=cos(Degrees*(double)(counter-1));
			double p1y=sin(Degrees*(double)(counter-1));

			double p4x=cos(Degrees*(double)(counter));
			double p4y=sin(Degrees*(double)(counter));
			
			double p2x=((p4x-p1x)/3)+p1x;
			double p2y=((p4y-p1y)/3)+p1y;
			double p3x=(((p4x-p1x)/3)*2)+p1x;
			double p3y=(((p4y-p1y)/3)*2)+p1y;
			
			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:p1x]];
			[subArray addObject:[NSNumber numberWithFloat:p1y]];
			if ( mainArray==nil)	//no entry yet
				mainArray=[NSMutableArray arrayWithObject:subArray];
			else
				[mainArray addObject:subArray];

			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:p2x]];
			[subArray addObject:[NSNumber numberWithFloat:p2y]];
			[mainArray addObject:subArray];

			subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:p3x]];
			[subArray addObject:[NSNumber numberWithFloat:p3y]];
			[mainArray addObject:subArray];

			if ( cnt+3 < NumberOfPoints)
			{
				subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:p4x]];
				[subArray addObject:[NSNumber numberWithFloat:p4y]];
				[mainArray addObject:subArray];
				subArray=nil;
				}
		}
	
		subArray=[NSMutableArray arrayWithObject:[NSNumber numberWithFloat:cos(Degrees*(double)(1-1))]];
		[subArray addObject:[NSNumber numberWithFloat:sin(Degrees*(double)(1-1))]];
		[mainArray addObject:subArray];
		subArray=nil;
	}
	[self setArray:mainArray];
	[self setViewDirty];
}


//---------------------------------------------------------------------
// insertEntryAtIndex
//---------------------------------------------------------------------
-(void) insertEntryAtIndex:(int)index
{
//	int outRows=[self count];
	int selectedRow=[self firstSelectedRow];	//
	NSMutableArray *newArray;
	int SelectedSegment,firstSelectedSegmentPoint;
	float newX;
	float newY;

	if ( selectedRow!=dNoRowSelected)
	{
		switch ([self buttonState:cSplineTypePopUp])
		{
			case cLinearSpline:
			case cQuadraticSpline:
			case cCubicSpline:
				newX=0.0;
				newY=1.0;
				if ( selectedRow >0)
				{
					newX=([self floatAtRow:selectedRow atColumn:cObjectmapXIndex]+[self floatAtRow:selectedRow-1 atColumn:cObjectmapXIndex])/2.0;
					newY=([self floatAtRow:selectedRow atColumn:cObjectmapYIndex]+[self floatAtRow:selectedRow-1 atColumn:cObjectmapYIndex])/2.0;
				}
				newArray=[NSMutableArray arrayWithObjects:
															[NSNumber numberWithFloat:newX],[NSNumber numberWithFloat:newY],
														nil];
				[mMapArray insertObject:newArray atIndex:selectedRow];
			 	[ [self tableView] reloadData];
				[self setViewDirty];
				break;
			case cBezierSpline:

				SelectedSegment=(((selectedRow+1)-1)/4)+1;
				firstSelectedSegmentPoint=((SelectedSegment-1)*4);	
				for (int x=1; x<=4; x++)
				{
					newArray=[NSMutableArray arrayWithObjects:
											[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],
											nil];
					[mMapArray insertObject:newArray atIndex:firstSelectedSegmentPoint];
				}
	//			outRows=[self count];

				float tempH[4],tempL[4];
				for (int x=0; x<4; x++)
				{
					tempL[x]=[self floatAtRow:firstSelectedSegmentPoint+4+x atColumn:cObjectmapXIndex];
					tempH[x]=[self floatAtRow:firstSelectedSegmentPoint+4+x atColumn:cObjectmapYIndex];
				}
				[self setFloat:tempL[0] atRow:firstSelectedSegmentPoint atColumn:cObjectmapXIndex];
				[self setFloat:tempH[0] atRow:firstSelectedSegmentPoint atColumn:cObjectmapYIndex];
					
				[self setFloat:(tempL[0]+tempL[3])/2.0 atRow:firstSelectedSegmentPoint+3 atColumn:cObjectmapXIndex];
				[self setFloat:(tempH[0]+tempH[3])/2.0 atRow:firstSelectedSegmentPoint+3 atColumn:cObjectmapYIndex];
					
				[self setFloat:(tempL[0]+tempL[3])/2.0 atRow:firstSelectedSegmentPoint+4 atColumn:cObjectmapXIndex];
				[self setFloat:(tempH[0]+tempH[3])/2.0 atRow:firstSelectedSegmentPoint+4 atColumn:cObjectmapYIndex];

					
				[self setFloat:tempL[1] atRow:firstSelectedSegmentPoint+1 atColumn:cObjectmapXIndex];
				[self setFloat:tempH[1] atRow:firstSelectedSegmentPoint+1 atColumn:cObjectmapYIndex];

				[self setFloat:tempL[2] atRow:firstSelectedSegmentPoint+6 atColumn:cObjectmapXIndex];
				[self setFloat:tempH[2] atRow:firstSelectedSegmentPoint+6 atColumn:cObjectmapYIndex];

				[self setFloat:tempL[0]-((tempL[0]-tempL[3])/4.0) atRow:firstSelectedSegmentPoint+2 atColumn:cObjectmapXIndex];
				[self setFloat:tempH[0]-((tempH[0]-tempH[3])/4.0) atRow:firstSelectedSegmentPoint+2 atColumn:cObjectmapYIndex];

				[self setFloat:tempL[3]+((tempL[0]-tempL[3])/4.0) atRow:firstSelectedSegmentPoint+5 atColumn:cObjectmapXIndex];
				[self setFloat:tempH[3]+((tempH[0]-tempH[3])/4.0) atRow:firstSelectedSegmentPoint+5 atColumn:cObjectmapYIndex];
			 	[ [self tableView] reloadData];
				[self setViewDirty];
				break;
		}
	}
}

//---------------------------------------------------------------------
// addEntry
//---------------------------------------------------------------------
-(void) addEntry
{
	NSMutableArray *newArray;
	switch ([self buttonState:cSplineTypePopUp])
	{
		case cLinearSpline:
		case cQuadraticSpline:
		case cCubicSpline:
			newArray=[NSMutableArray arrayWithObjects:
											[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],
											nil];
			[mMapArray addObject:newArray];
		 	[ [self tableView] reloadData];
			[self setViewDirty];
			break;
		case cBezierSpline:
			if (  [self templateType]==menuTagTemplatePrism )
			{
				[self selectTableRow:[self count]];
				[self insertEntryAtIndex:[self count]];	//value not used in insertEntryAtIndex
				return;
			}
			for (int x=1; x<=4; x++)
			{
				newArray=[NSMutableArray arrayWithObjects:
											[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],
											nil];
				[mMapArray addObject:newArray];
			}	
			int firstSelectedSegmentPoint = ([self count]-3)-1;
			if (  [self templateType]==menuTagTemplateLathe)
			{
				//first point of segment == 0.0
				[self setObject:[self objectAtRow:firstSelectedSegmentPoint-1 atColumn:cObjectmapXIndex]
					
					atRow:firstSelectedSegmentPoint atColumn:cObjectmapXIndex];

				[self setObject:[self objectAtRow:firstSelectedSegmentPoint-1 atColumn:cObjectmapYIndex]
					atRow:firstSelectedSegmentPoint atColumn:cObjectmapYIndex];
				//last point of segment == first point of next segment
				[self setFloat:0.0 atRow:firstSelectedSegmentPoint+3 atColumn:cObjectmapXIndex];
				[self setFloat:1.0 atRow:firstSelectedSegmentPoint+3 atColumn:cObjectmapYIndex];

				[self setFloat:0.2 atRow:firstSelectedSegmentPoint+2 atColumn:cObjectmapXIndex];
				[self setFloat:0.8 atRow:firstSelectedSegmentPoint+2 atColumn:cObjectmapYIndex];

				NSInteger ControlPoint=-1,CenterPoint=-1;
				//1 st  control point of segment follows first control point of previous segment
				[mPreview getControlPoint:firstSelectedSegmentPoint-2 controlPoint:ControlPoint centerPoint:CenterPoint event:nil];
				if ( ControlPoint != -1)
				{
					[mPreview calculateControlPoint:firstSelectedSegmentPoint-2 controlPoint:ControlPoint centerPoint:CenterPoint];
				}
				
			}
		 	[ [self tableView] reloadData];
		 	[ self reloadData];
			[self setViewDirty];
			break;
	}

}

//---------------------------------------------------------------------
// removeEntryAtIndex
//---------------------------------------------------------------------
-(void) removeEntryAtIndex:(int)index
{
	int outRows=[self count];
	int selectedRow=[self firstSelectedRow];	//

	int SelectedSegment,firstSelectedSegmentPoint;

	if ( selectedRow!=dNoRowSelected)
	{
		if (  [self templateType]==menuTagTemplateSor )
		{
			if ( outRows-1 < 4)
				return;
			[super removeEntryAtIndex:selectedRow reload:YES];
		}
		else
		{				
			switch ([self buttonState:cSplineTypePopUp])
			{
				case cLinearSpline:
					if ( outRows-1 < 2)
						return;
					[super removeEntryAtIndex:selectedRow reload:YES];
					break;
				case cQuadraticSpline:
					if ( outRows-1 < 3)
						return;
					[super removeEntryAtIndex:selectedRow reload:YES];
					break;
				case cCubicSpline:
					if ( outRows-1 < 4)
						return;
					[super removeEntryAtIndex:selectedRow reload:YES];
					break;
				case cBezierSpline:
					if ( outRows-4 < 4)
						return;
					SelectedSegment=(((selectedRow+1)-1)/4)+1;
					firstSelectedSegmentPoint=((SelectedSegment-1)*4);	
					for (int x=1; x<=4; x++)
						[super removeEntryAtIndex:firstSelectedSegmentPoint reload:YES];

					outRows=[self count];
					if ( firstSelectedSegmentPoint != 0 && (firstSelectedSegmentPoint+2) <= outRows)
					{
						[self setObject:[self objectAtRow:firstSelectedSegmentPoint-1 atColumn:cObjectmapXIndex]
							atRow:firstSelectedSegmentPoint atColumn:cObjectmapXIndex];

						[self setObject:[self objectAtRow:firstSelectedSegmentPoint-1 atColumn:cObjectmapYIndex]
							atRow:firstSelectedSegmentPoint atColumn:cObjectmapYIndex];
		 	[ [self tableView] noteNumberOfRowsChanged];
						[self setViewDirty];
					}
					break;
			}
		}
	}

}

	
//---------------------------------------------------------------------
// setButtonState:forButton
//---------------------------------------------------------------------
-(void) setButtonState:(int) state forButton:(int)button
{
	switch ( button)
	{
		case cSlopeButton:			mSlopeOn=state; 				break;
		case cPointButton:			mPointOn=state;				break;
		case cCurveButton:			mCurveOn=state;				break;
		case cRasterButton:		mRasterOn=state;				break;
		case cSplineTypePopUp:	mSplineTypePopUp=state;	break;
	}
	[self setViewDirty];
}

//---------------------------------------------------------------------
// buttonState
//---------------------------------------------------------------------
-(int) buttonState:(int)button
{
	switch ( button)
	{
		case cSlopeButton:		return mSlopeOn; 	break;
		case cPointButton:		return mPointOn;	break;
		case cCurveButton:		return mCurveOn;	break;
		case cRasterButton:	return mRasterOn;	break;
		case cSplineTypePopUp: return mSplineTypePopUp; break;
		default:
		return NSOffState;
	}
}

//---------------------------------------------------------------------
// encodeWithCoder:encoder
//---------------------------------------------------------------------
-(void) encodeWithCoder:(NSCoder *) encoder
{
	[encoder encodeObject:mMapArray];
	[encoder encodeValueOfObjCType:@encode(int) at:&mSlopeOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mPointOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mRasterOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mCurveOn];
	[encoder encodeValueOfObjCType:@encode(int) at:&mSplineTypePopUp];
	[encoder encodeValueOfObjCType:@encode(int) at:&mTemplateType];
}

//---------------------------------------------------------------------
// initWithCoder:decoder
//---------------------------------------------------------------------
-(id)initWithCoder:(NSCoder*) decoder
{
	[self setArray:[decoder decodeObject]];
	[decoder decodeValueOfObjCType:@encode(int) at:&mSlopeOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mPointOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mRasterOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mCurveOn];
	[decoder decodeValueOfObjCType:@encode(int) at:&mSplineTypePopUp];
	[decoder decodeValueOfObjCType:@encode(int) at:&mTemplateType];
	[self setSelectedRow:dNoRowSelected];
	return self;
}


@end
