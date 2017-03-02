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


#import <Cocoa/Cocoa.h>
#import "baseTemplate.h"
#define interiorEditMedia mTemplatePrefs[0]
#define setInteriorEditMedia setTemplatePrefs:0 withObject

	
enum eInteriorTags{
	cInteriorIorIndexPopUp									=10,
	cInteriorDispersionGroupOn								=20,
	cInteriorDispersionSamplesOn							=30,
	cInteriorLightAttenuationGroupOn					=40,
	cIteriorLightAttenuationFadeColorGroupOn	=50,
	cInteriorMediaGroupOn											= 60,
	cInteriorEditMedia												=70,
	cInteriorCausticsOn												=80
};

enum eInteriorIorIndex {
	cIorIndexNone 				=0,
	cIorIndexAcrylic				=2,
	cIorIndexAir,
	cIorIndexAlcohol,
	cIorIndexAmber	,
	cIorIndexDiamond,
	cIorIndexEmerald,
	cIorIndexGlassBorosilicate,
	cIorIndexGlassCrown,
	cIorIndexGlass71Lead,
	cIorIndexGlycerine,
	cIorIndexIce,
	cIorIndexOpal,
	cIorIndexPolycarbonate,
	cIorIndexQuartz,
	cIorIndexSapphire,
	cIorIndexTopaz,
	cIorIndexVacumm,
	cIorIndexWater,
	cIorIndexZircon,
	cIorIndexZirconaCubic

};
	

@interface InteriorTemplate : BaseTemplate
{

	//main
	IBOutlet NSView						*interiorMainViewHolderView;	
	IBOutlet NSView						*interiorMainViewNIBView;			//view in NIB file, contains everything

	IBOutlet NSPopUpButton			*interiorIorIndexPopUp;
	IBOutlet NSTextField				*interiorIorIndexEdit;

	IBOutlet NSButton 					*interiorDispersionGroupOn;
	IBOutlet NSBox	 					*interiorDispersionGroup;
	IBOutlet NSButton					*interiorDispersionSamplesOn;
	IBOutlet NSTextField				*interiorDispersionSamplesEdit;
	IBOutlet NSTextField				*interiorDispersionValueEdit;

	IBOutlet NSButton					*interiorCausticsOn;
	IBOutlet NSTextField				*interiorCausticsEdit;

	IBOutlet NSButton 					*interiorLightAttenuationGroupOn;
	IBOutlet NSBox	 					*interiorLightAttenuationGroup;
	IBOutlet NSTextField				*interiorLightAttenuationFadeDistanceEdit;
	IBOutlet NSTextField				*interiorLightAttenuationFadePowerEdit;
	IBOutlet NSButton 					*interiorLightAttenuationFadeColorGroupOn;
	IBOutlet NSBox	 					*interiorLightAttenuationFadeColorGroup;
	IBOutlet NSColorWell 				*interiorLightAttenuationFadeColorColorWell;

	IBOutlet NSButton 					*interiorMediaGroupOn;
	IBOutlet NSBox	 					*interiorMediaGroup;
	//extra for tooltips
	IBOutlet NSButton					*interiorMediaEditButton;

}
-(NSView*) interiorMainViewNIBView;

-(IBAction) interiorTarget:(id)sender;
-(IBAction) interiorButtons:(id)sender;

@end
