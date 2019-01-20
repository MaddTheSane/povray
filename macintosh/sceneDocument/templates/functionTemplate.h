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

#import <Cocoa/Cocoa.h>
#import "baseTemplate.h"

enum {
	Function_Empty		=1,
	Function_A				=2,
	Function_AB			=3,
	Function_S				=4,
//	Function_SA			=5,
//	Function_SV			=6,
	Function_S1S2		=7,
	Function_V1V2		=8,
	Function_V				=9,
	Function_V1V2A		=10,
	Function_SPL			=11,
	Function_ALP			=12,
	Function_NVSLP		=13,
	Function_XYZ			=14,
	Function_VLOO		=15,
	Function_ABCD		=16,
	Function_XYZP0		=17,
	Function_XYZP0_P1	=18,
	Function_XYZP0_P2	=19,
	Function_XYZP0_P3	=20,
	Function_XYZP0_P4	=21,
	Function_XYZP0_P5	=22,
	Function_XYZP0_P6	=23,
	Function_XYZP0_P9	=24,
	Function_ID			=25,
	Function_IDA			=26,
	Function_IDV			=27,
	Function_ABC			=28,

	F_All						=0,
	F_BuiltIn					,
	F_BuiltInFloat			,
	F_Evaluate				,
	F_Math					,
	F_String					,
	F_Trigonometry		,
	F_Pattern						
};

const UInt16 All 				=1;
const UInt16 Iso				=2;
const UInt16 Parametric	=4;
const UInt16 Endlist		=16;


typedef struct {
	unsigned short RefNr;
	unsigned short	Kind;
	unsigned short Pane;
	unsigned short Where;
	NSString *	Syntax;
	NSString *	Result;
	const char 		*Description;
	NSString *	X;
	NSString *	Y;
	NSString *	Z;
	NSString *	P0;
	NSString *	P1;
	NSString *	P2;
	NSString *	P3;
	NSString *	P4;
	NSString *	P5;
	NSString *	P6;
	NSString *	P7;
	NSString *	P8;
	NSString *	P9;
	NSString *	S;
	NSString *	S1;
	NSString *	S2;
	NSString *	V1A;
	NSString *	V1B;
	NSString *	V1C;
	NSString *	V1D;
	NSString *	V1E;
	NSString *	V2A;
	NSString *	V2B;
	NSString *	V2C;
	NSString *	A;
	NSString *	B;
	NSString *	C;
	NSString *	D;
	NSString *	L;
	NSString *	P;
	NSString *	OM;
	NSString *	OC;
	NSString *	LA;
	NSString *	ID;
//	unsigned char	N;

}SFunctionList, *SFunctionListPtr;

extern SFunctionList FunctionList[];
 
@interface FunctionTemplate : BaseTemplate
{
	IBOutlet	NSTabView		*mainTabView;
	IBOutlet NSView				*emptyView;
	IBOutlet NSView				*xyzpView;
	IBOutlet NSView				*abView;
	IBOutlet NSView				*idaView;
	IBOutlet NSView				*idvView;
	IBOutlet NSView				*s1s2View;
	IBOutlet NSView				*abcdView;
	IBOutlet NSView				*alpView;
	IBOutlet NSView				*splView;
	IBOutlet NSView				*v1v2aView;
	IBOutlet NSView				*nvslpView;
	IBOutlet NSView				*vlooView;
	
	IBOutlet NSTableView 		*functionTableView;
	IBOutlet	NSTextView		*functionDescriptionView;
	IBOutlet NSPopUpButton 	*functionTypesPopup;
	
	IBOutlet	NSTextField		*xyzpViewX, *xyzpViewY, *xyzpViewZ;
	IBOutlet NSTextField		*xyzpViewp0, *xyzpViewp1, *xyzpViewp2, *xyzpViewp3, *xyzpViewp4; 
	IBOutlet NSTextField		*xyzpViewp5, *xyzpViewp6, *xyzpViewp7, *xyzpViewp8, *xyzpViewp9; 

	IBOutlet	NSTextField		*abViewA, *abViewB;

	IBOutlet	NSTextField		*s1s2ViewS1, *s1s2ViewS2;

	IBOutlet	NSTextField		*idaViewID, *idaViewA;

	IBOutlet	NSTextField		*idvViewID, *idvViewV0, *idvViewV1, *idvViewV2;

	IBOutlet	NSTextField		*abcdViewA, *abcdViewB, *abcdViewC, *abcdViewD;

	IBOutlet	NSTextField		*alpViewA, *alpViewL, *alpViewP;

	IBOutlet	NSTextField		*splViewS, *splViewP, *splViewL;

	IBOutlet	NSTextField		*v1v2aViewV10, *v1v2aViewV11, *v1v2aViewV12, *v1v2aViewV20, *v1v2aViewV21, *v1v2aViewV22, *v1v2aViewA;

	IBOutlet	NSPopUpButton	*nvslpViewN;
	IBOutlet NSTextField 		*nvslpViewV0, *nvslpViewV1, *nvslpViewV2, *nvslpViewV3, *nvslpViewV4, *nvslpViewS, *nvslpViewL, *nvslpViewP;

	IBOutlet	NSTextField		*vlooViewV0, *vlooViewV1, *vlooViewV2, *vlooViewLa, *vlooViewOm, *vlooViewOc;
	SFunctionListPtr 				mCurrentFunctions;
	int mItems;
}
- (IBAction)functionTypesPopup:(id)sender;
-(void) buildCurrentFunctions:(int) type;
+(SFunctionListPtr) functionForIndex:(int)reference;
-(int) findCurrentIndexForReference:(int)reference;
-(void) updateViews;


@end
