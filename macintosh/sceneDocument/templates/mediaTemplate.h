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

#define mediaDensityEditPattern mTemplatePrefs[0]
#define mediaDensityEditMap mTemplatePrefs[1]

#define setMediaDensityEditPattern setTemplatePrefs:0 withObject
#define setMediaDensityEditMap setTemplatePrefs:1 withObject
	
enum eMediaTags{
	cMediaAbsorptionGroupOn			=10 ,
	cMediaEmissionGroupOn				=20 ,
	cMediaDensityGroupOn				=40 ,
	cMediaDensityMatrix					=50 ,
	cMediaDensityEditPatternButton	=60 ,
	cMediaDensityEditMapButton		=70 ,
	cMediaScatteringGroupOn			=80 ,
	cMediaScatteringTypePopUp		=85,
	cMediaScatteringExtinctionOn		=90 ,
	cMediaSamplingMethodPopUp		=100 ,
	cMediaSamplingIntervalsOn			=110 ,
	cMediaSamplingSamplesOn			=120 ,
	cMediaSamplingJitterOn				=130 ,
	cMediaSamplingAaDepthOn			=140 ,
	cMediaSamplingAaThresholdOn	=150 ,
	cMediaSamplingConfidenceOn		=160 ,
	cMediaSamplingVarianceOn			=170 ,
	cMediaSamplingRatioOn				=180 
};

enum eMediaScatteringTypes {
	cIsotropic 				=0,
	cMieHazy 				=1,
	cMieMurky				=2,
	cRayleigh				=3,
	cHenyeyGreenstein	=4
};

enum eMediaSamplingMethod {
	cMethod1 				=0,
	cMethod2 				=1,
	cMethod3				=2
};

@interface MediaTemplate : BaseTemplate
{

	//main
	IBOutlet NSButton 					*mediaDontWrapInMedia;
	IBOutlet NSButton 					*mediaIgnorePhotonsOn;

	IBOutlet NSButton 					*mediaAbsorptionGroupOn;
	IBOutlet NSBox	 					*mediaAbsorptionGroup;
	IBOutlet NSColorWell 				*mediaAbsorptionGroupColorWell;

	IBOutlet NSButton 					*mediaEmissionGroupOn;
	IBOutlet NSBox	 					*mediaEmissionGroup;
	IBOutlet NSColorWell 				*mediaEmissionGroupColorWell;

	IBOutlet NSButton 					*mediaDensityGroupOn;
	IBOutlet NSBox	 					*mediaDensityGroup;
	IBOutlet NSMatrix					*mediaDensityMatrix;
	IBOutlet NSButton					*mediaDensityEditPatternButton;
	IBOutlet NSButton					*mediaDensityEditMapButton;

	IBOutlet NSButton 					*mediaScatteringGroupOn;
	IBOutlet NSBox	 					*mediaScatteringGroup;
	IBOutlet NSColorWell 				*mediaScatteringColorWell;
	IBOutlet NSPopUpButton			*mediaScatteringTypePopUp;
	IBOutlet NSTextField				*mediaScatteringEccentricityText;
	IBOutlet NSTextField				*mediaScatteringEccentricityEdit;
	IBOutlet NSButton					*mediaScatteringExtinctionOn;
	IBOutlet NSTextField				*mediaScatteringExtinctionEdit;

	IBOutlet NSPopUpButton			*mediaSamplingMethodPopUp;
	IBOutlet NSButton					*mediaSamplingIntervalsOn;
	IBOutlet NSTextField				*mediaSamplingIntervalsEdit;
	IBOutlet NSButton					*mediaSamplingSamplesOn;
	IBOutlet NSTextField				*mediaSamplingSamplesMinText;
	IBOutlet NSTextField				*mediaSamplingSamplesMinEdit;
	IBOutlet NSTextField				*mediaSamplingSamplesMaxText;
	IBOutlet NSTextField				*mediaSamplingSamplesMaxEdit;

	IBOutlet NSButton					*mediaSamplingJitterOn;
	IBOutlet NSTextField				*mediaSamplingJitterEdit;
	IBOutlet NSButton					*mediaSamplingAaDepthOn;
	IBOutlet NSTextField				*mediaSamplingAaDepthEdit;
	IBOutlet NSButton					*mediaSamplingAaThresholdOn;
	IBOutlet NSTextField				*mediaSamplingAaThresholdEdit;
	IBOutlet NSButton					*mediaSamplingConfidenceOn;
	IBOutlet NSTextField				*mediaSamplingConfidenceEdit;
	IBOutlet NSButton					*mediaSamplingVarianceOn;
	IBOutlet NSTextField				*mediaSamplingVarianceEdit;
	IBOutlet NSButton					*mediaSamplingRatioOn;
	IBOutlet NSTextField				*mediaSamplingRatioEdit;
}

-(IBAction) mediaTarget:(id)sender;
-(IBAction) mediaButtons:(id)sender;

@end
