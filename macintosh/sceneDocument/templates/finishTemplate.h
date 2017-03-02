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

	
enum eFinishTags{
	cFinishAmbientLightGroupOn							=10,
	cFinishEmissionGroupOn									=15,
	cFinishSubsurfaceLightTransportGroupOn					=16,
	cFinishReflectionLightGroupOn				=20,
	cFinishReflectionVariableGroupOn		=30,
	cFinishReflectionVariableFallOffOn 	=40,
	cFinishReflectionExponentOn					=50,
	cFinishReflectionMetallicOn					=60,
	cFinishConserveEnergyOn							=70,
	cFinishDiffuseOn										=80,
	cFinishBacksideOn										=81,
	cFinishBrillianceOn									=90,
	cFinishCrandOn											=100,
	cFinishPhongOn											=110,
	cFinishPhongSizeOn									=120,
	cFinishSpecularOn										=130,
	cFinishRoghnessOn										=140,
	cFinishMetallicOn										=150,
	cFinishIridescenceGroupOn						=160,
	cFinishIridescenceTurbulencePopup		=170
};


@interface FinishTemplate : BaseTemplate
{

	//main
	IBOutlet NSView						*finishMainViewHolderView;	
	IBOutlet NSView						*finishMainViewNIBView;			//view in NIB file, contains everything
	IBOutlet NSButton 				*finishDontWrapInFinish;

	IBOutlet NSButton					*finishDiffuseOn;
	IBOutlet NSTextField			*finishDiffuseEdit;
	IBOutlet NSButton					*finishBacksideOn;
	IBOutlet NSTextField			*finishBacksideEdit;
	IBOutlet NSButton					*finishBrillianceOn;
	IBOutlet NSTextField			*finishBrillianceEdit;
	IBOutlet NSButton					*finishCrandOn;
	IBOutlet NSTextField			*finishCrandEdit;

	IBOutlet NSButton 				*finishAmbientColorGroupOn;
	IBOutlet NSBox	 					*finishAmbientColorGroup;
	IBOutlet NSColorWell 			*finishAmbientColorColorWell;

	IBOutlet NSButton 				*finishEmissionColorGroupOn;
	IBOutlet NSBox	 					*finishEmissionColorGroup;
	IBOutlet NSColorWell 			*finishEmissionColorColorWell;

	IBOutlet NSButton 				*finishSubsurfaceLightTransportColorGroupOn;
	IBOutlet NSBox	 					*finishSubsurfaceLightTransportColorGroup;
	IBOutlet NSColorWell 			*finishSubsurfaceLightTransportColorColorWell;

	IBOutlet NSButton					*finishPhongOn;
	IBOutlet NSTextField			*finishPhongEdit;
	IBOutlet NSButton					*finishPhongSizeOn;
	IBOutlet NSTextField			*finishPhongSizeEdit;
	IBOutlet NSButton					*finishSpecularOn;
	IBOutlet NSTextField			*finishSpecularEdit;
	IBOutlet NSButton					*finishRoghnessOn;
	IBOutlet NSTextField			*finishRoghnessEdit;
	IBOutlet NSButton					*finishMetallicOn;
	IBOutlet NSTextField			*finishMetallicEdit;

	IBOutlet NSButton 				*finishIridescenceGroupOn;
	IBOutlet NSBox	 					*finishIridescenceGroup;
	IBOutlet NSTextField			*finishIridescenceAmountEdit;
	IBOutlet NSTextField			*finishIridescenceThicknessEdit;
	IBOutlet NSPopUpButton		*finishIridescenceTurbulencePopUp;
	IBOutlet NSMatrix					*finishIridescenceTurbulenceMatrix;

	IBOutlet NSButton	 				*finishReflectionLightGroupOn;
	IBOutlet NSBox	 					*finishReflectionLightGroup;
	IBOutlet NSButton	 				*finishReflectionVariableGroupOn;
	IBOutlet NSBox	 					*finishReflectionVariableGroup;
	IBOutlet NSColorWell 			*finishReflectionVariableMinColorColorWell;
	IBOutlet NSButton	 				*finishReflectionVariableFresnelOn;
	IBOutlet NSButton	 				*finishReflectionVariableFalloffOn;
	IBOutlet NSTextField 			*finishReflectionVariableFalloffEdit;
	IBOutlet NSColorWell 			*finishReflectionMaxColorColorWell;
	IBOutlet NSButton	 				*finishReflectionExponentOn;
	IBOutlet NSTextField 			*finishReflectionExponentEdit;
	IBOutlet NSButton	 				*finishReflectionMetallicOn;
	IBOutlet NSTextField 			*finishReflectionMetallicEdit;
	IBOutlet NSButton	 				*finishConserveEnergyOn;
}
-(NSView*) finishMainViewNIBView;

-(IBAction) finishTarget:(id)sender;

@end
