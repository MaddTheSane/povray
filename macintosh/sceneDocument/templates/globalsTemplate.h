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


enum {
	cGlobalsTab 		=0,
	cSubsurfaceTab	=1,
	cRadiosityTab		=2,
	cPhotonsTab			=3,
	};
	
enum {
	cRadiositySamplesDefault=0,
	cRadiositySamplesHalton=1,
	cRadiositySamplesCount=2
};


enum {
	cGlobalsNoiseGenerator1=0,
	cGlobalsNoiseGeneratorSqueesed=1,
	cGlobalsNoiseGeneratorPernlin=2,

	cGlobalsCharSetASCII=0,
	cGlobalsCharSetUTF8=1,
	cGlobalsCharSetSys=2
};
	
enum {
	globalsRadiosityAdaptive0 = 0,
	globalsRadiosityAdaptive1 = 1,
	globalsRadiosityAdaptive2 = 2
};


enum {

//globals
	cGlobalsGlobalsAmbientLightOn			=1,
	cGlobalsGlobalsAmbientLightColor	=2,
	
	cGlobalsGlobalsIridWavelengthOn			=9,
	cGlobalsGlobalsIridWavelengthColor	=10,
	
	cGlobalsGlobalsAssumedGammaOn			=4,
	cGlobalsGlobalsAdcBailoutOn				=5,
	cGlobalsGlobalsMaxTraceLevelOn		=6,
	cGlobalsGlobalsNumberOfWavesOn		=7,
	cGlobalsGlobalsMaxIntersectionsOn	=8,

	cGlobalsGlobalsCharsetOn				=11,
	cGlobalsGlobalsNoiseGeneratorOn	=12,
	cGlobalsGlobalsmmPerUnitOn			=13,
//Subsurface
	cGlobalsSubsurfaceGroupOn				=1,
	cGlobalsSubsurfaceSamplespOn				=2,
	cGlobalsSubsurfaceRadiosityOn				=3,
//radiosity

	cGlobalsRadiosityPretraceStartOn	=1,
	cGlobalsRadiosityPretraceEndOn		=2,
	cGlobalsRadiosityBrightnessOn			=3,
	cGlobalsRadiosityCountOn					=4,
	cGlobalsRadiosityNearestCountOn		=5,
	cGlobalsRadiosityRecursionLimitOn	=6,
	cGlobalsRadiosityCountDirectionsOn					=7,
	cGlobalsRadiosityNearestCountPretraceOn		=8,


	cGlobalsRadiosityMaxSampleOn							=11,
	cGlobalsRadiosityErrorBoundOn							=12,
	cGlobalsRadiosityGrayThresholdOn					=13,
	cGlobalsRadiosityLowErrorFactorOn					=14,
	cGlobalsRadiosityMinimumReuseOn						=15,
	cGlobalsRadiosityAdcBailoutOn							=16,
	

//photons

	cGlobalsPhotonsGatherMinOn					=1,
	cGlobalsPhotonsMediaOn							=3,
	cGlobalsPhotonsMediaFactorOn				=4,
	cGlobalsPhotonsExpandThresholdOn		=5,
	cGlobalsPhotonsExpandThresholdMinOn	=6,

	cGlobalsPhotonsJitterOn					=7,
	cGlobalsPhotonsMaxTraceLevelOn	=8,
	cGlobalsPhotonsRadiusOn					=9,

	cGlobalsPhotonsPhotonsFileOn		=10,
	cGlobalsPhotonsAdcBailoutOn			=11,
	cGlobalsPhotonsAutoStopOn				=12,
	cGlobalsPhotonsReflectionBlurOn	=13,
	cGlobalsPhotonsSpacingMatrix		=14
};

@interface GlobalsTemplate : BaseTemplate
{
	IBOutlet NSTabView 	*globalsTabView;
	IBOutlet id					globalsRadiosityLed;
	IBOutlet id					globalsSubsurfaceLed;
	IBOutlet id					globalsPhotonsLed;
	IBOutlet NSButton 	*globalsDontWrapInGlobalSettings;

//globals
	IBOutlet NSButton				*globalsGlobalsAmbientLightOn;
	IBOutlet NSBox					*globalsGlobalsAmbientLightGroup;
	IBOutlet NSColorWell		*globalsGlobalsAmbientLightColor;
	
	IBOutlet NSButton				*globalsGlobalsIridWavelengthOn;
	IBOutlet NSBox					*globalsGlobalsIridWavelengthGroup;
	IBOutlet NSColorWell 		*globalsGlobalsIridWavelengthColor;
	
	IBOutlet NSButton				*globalsGlobalsAssumedGammaOn;
	IBOutlet NSTextField		*globalsGlobalsAssumedGammaEdit;
	IBOutlet NSButton				*globalsGlobalsAdcBailoutOn;
	IBOutlet NSTextField		*globalsGlobalsAdcBailoutEdit;
	IBOutlet NSButton				*globalsGlobalsMaxTraceLevelOn;
	IBOutlet NSTextField		*globalsGlobalsMaxTraceLevelEdit;
	IBOutlet NSButton				*globalsGlobalsNumberOfWavesOn;
	IBOutlet NSTextField		*globalsGlobalsNumberOfWavesEdit;
	IBOutlet NSButton				*globalsGlobalsMaxIntersectionsOn;
	IBOutlet NSTextField		*globalsGlobalsMaxIntersectionsEdit;

	IBOutlet NSButton				*globalsGlobalsCharsetOn;
	IBOutlet NSPopUpButton	*globalsGlobalsCharsetPopUp;
	IBOutlet NSButton				*globalsGlobalsNoiseGeneratorOn;
	IBOutlet NSPopUpButton	*globalsGlobalsNoiseGeneratorPopUp;
	IBOutlet NSButton				*globalsGlobalsmmPerUnitOn;
	IBOutlet NSTextField		*globalsGlobalsmmPerUnitEdit;
//subsurface
	IBOutlet NSButton				*globalsSubsurfaceGroupOn;
	IBOutlet NSBox					*globalsSubsurfaceGroup;
	IBOutlet NSButton				*globalsSubsurfaceSamplesOn;
	IBOutlet NSTextField    *globalsSubsurfaceSamplesEditA;
	IBOutlet NSTextField    *globalsSubsurfaceSamplesEditB;
	IBOutlet NSButton				*globalsSubSurfaceRadiosityOn;
	IBOutlet NSMatrix				*globalsSubSurfaceRadiosityMatrix;
//radiosity
	IBOutlet NSButton				*globalsRadiosityOn;
	IBOutlet NSBox					*globalsRadiosityGroup;

	IBOutlet NSButton				*globalsRadiosityPretraceStartOn;
	IBOutlet NSTextField		*globalsRadiosityPretraceStartEdit;
	IBOutlet NSButton				*globalsRadiosityPretraceEndOn;
	IBOutlet NSTextField		*globalsRadiosityPretraceEndEdit;
	IBOutlet NSButton				*globalsRadiosityBrightnessOn;
	IBOutlet NSTextField		*globalsRadiosityBrightnessEdit;
	
	IBOutlet NSButton				*globalsRadiosityCountOn;
	IBOutlet NSTextField		*globalsRadiosityCountEdit;
	IBOutlet NSButton				*globalsRadiosityCountDirectionsOn;
	IBOutlet NSTextField		*globalsRadiosityCountDirectionsEdit;
	
	IBOutlet NSButton				*globalsRadiosityNearestCountOn;
	IBOutlet NSTextField		*globalsRadiosityNearestCountEdit;
	IBOutlet NSButton				*globalsRadiosityNearestCountPretraceOn;
	IBOutlet NSTextField		*globalsRadiosityNearestCountPretraceEdit;
	
	IBOutlet NSButton				*globalsRadiosityRecursionLimitOn;
	IBOutlet NSTextField		*globalsRadiosityRecursionLimitEdit;

	IBOutlet NSButton			*globalsRadiosityAlwaysSampleOn;

	IBOutlet NSButton				*globalsRadiosityMaxSampleOn;
	IBOutlet NSTextField		*globalsRadiosityMaxSampleEdit;
	
	IBOutlet NSButton				*globalsRadiosityErrorBoundOn;
	IBOutlet NSTextField		*globalsRadiosityErrorBoundEdit;
	
	IBOutlet NSButton				*globalsRadiosityGrayThresholdOn;
	IBOutlet NSTextField		*globalsRadiosityGrayThresholdEdit;
	IBOutlet NSButton				*globalsRadiosityLowErrorFactorOn;
	IBOutlet NSTextField		*globalsRadiosityLowErrorFactorEdit;
	IBOutlet NSButton				*globalsRadiosityMinimumReuseOn;
	IBOutlet NSTextField		*globalsRadiosityMinimumReuseEdit;
	IBOutlet NSButton				*globalsRadiosityAdcBailoutOn;
	IBOutlet NSTextField		*globalsRadiosityAdcBailoutEdit;
	IBOutlet NSButton				*globalsRadiosityNormalOn;
	IBOutlet NSButton				*globalsRadiositySubsurfaceOn;
	IBOutlet NSButton				*globalsRadiosityMediaOn;

//photons
	IBOutlet NSButton			*globalsPhotonsOn;
	IBOutlet NSBox				*globalsPhotonsGroup;

	IBOutlet NSMatrix			*globalsPhotonsSpacingMatrix;
	IBOutlet NSTextField	*globalsPhotonsSpacingEdit;
	IBOutlet NSTextField	*globalsPhotonsSpacingCountEdit;

	IBOutlet NSButton			*globalsPhotonsGatherMinOn;
	IBOutlet NSTextField	*globalsPhotonsGatherMinEdit;
	IBOutlet NSTextField	*globalsPhotonsGatherMaxText;
	IBOutlet NSTextField	*globalsPhotonsGatherMaxEdit;
	IBOutlet NSButton			*globalsPhotonsMediaOn;
	IBOutlet NSTextField	*globalsPhotonsMediaEdit;
	IBOutlet NSButton			*globalsPhotonsMediaFactorOn;
	IBOutlet NSTextField	*globalsPhotonsMediaFactorEdit;
	IBOutlet NSButton			*globalsPhotonsExpandThresholdOn;
	IBOutlet NSTextField	*globalsPhotonsExpandThresholdEdit;
	IBOutlet NSTextField	*globalsPhotonsExpandThresholdMinText;
	IBOutlet NSTextField	*globalsPhotonsExpandThresholdMinEdit;

	IBOutlet NSButton			*globalsPhotonsJitterOn;
	IBOutlet NSTextField	*globalsPhotonsJitterEdit;
	IBOutlet NSButton			*globalsPhotonsMaxTraceLevelOn;
	IBOutlet NSTextField	*globalsPhotonsMaxTraceLevelEdit;
	IBOutlet NSButton			*globalsPhotonsRadiusOn;
	IBOutlet NSTextField	*globalsPhotonsRadiusEdit;

	IBOutlet NSButton			*globalsPhotonsPhotonsFileOn;
	IBOutlet NSMatrix			*globalsPhotonsPhotonsFileMatrix;
	IBOutlet NSTextField	*globalsPhotonsPhotonsFileEdit;

	IBOutlet NSButton			*globalsPhotonsAdcBailoutOn;
	IBOutlet NSTextField	*globalsPhotonsAdcBailoutEdit;
	IBOutlet NSButton			*globalsPhotonsAutoStopOn;
	IBOutlet NSTextField	*globalsPhotonsAutoStopEdit;



	
}
-(NSString*)currentImportExportTitle:(BOOL)import;
-(NSString *) beginOfKeysForCurrentPanel;
-(void) importSettings;
-(void) exportSettings;

-(IBAction) globalsGlobalsTarget:(id)sender;
-(IBAction) globalsSubsurfaceTarget:(id)sender;
-(IBAction) globalsRadiosityTarget:(id)sender;
-(IBAction) globalsPhotonsTarget:(id)sender;
-(IBAction) globalsRadiosityOn:(id)sender;
-(IBAction) globalsSubsurfaceOn:(id)sender;
-(IBAction) globalsPhotonsOn:(id)sender;

@end
