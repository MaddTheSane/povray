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

@interface LightTemplate : BaseTemplate
{
   IBOutlet NSTextField 		*lightAreaLightAdaptiveEdit;
    IBOutlet NSButton 			*lightAreaLightAdaptiveOn;

    IBOutlet NSButton 			*lightAreaLightAreaIllumination;
    
    IBOutlet NSMatrix 			*lightAreaLightAxis1Matrix;
    IBOutlet NSTextField		*lightAreaLightAxis1SizeEdit;
    IBOutlet NSPopUpButton 	*lightAreaLightAxis1Popup;
    IBOutlet NSMatrix 			*lightAreaLightAxis2Matrix;
    IBOutlet NSTextField		*lightAreaLightAxis2SizeEdit;
    IBOutlet NSPopUpButton 	*lightAreaLightAxis2Popup;
    IBOutlet NSButton 			*lightAreaLightCircularOn;
    IBOutlet NSBox					*lightAreaLightGroupBox;
    IBOutlet NSButton 			*lightAreaLightGroupOn;
    IBOutlet NSButton 			*lightAreaLightJitterOn;
    IBOutlet NSButton 			*lightAreaLightOrientOn;
    IBOutlet MPColorWell		*lightColor;
    IBOutlet NSTextField 		*lightColorFactorEdit;
    IBOutlet NSTextField 		*lightDirectionalLightFallOfAngleEdit;
    IBOutlet NSBox					*lightDirectionalLightGroupBox;
    IBOutlet NSButton 			*lightDirectionalLightGroupOn;
    IBOutlet NSMatrix 			*lightDirectionalLightPointAtMatrix;
    IBOutlet NSTextField 		*lightDirectionalLightRadiusAngleEdit;
    IBOutlet NSTextField 		*lightDirectionalLightTightnessEdit;
    IBOutlet NSPopUpButton 	*lightDirectionalLightTypePopup;
    IBOutlet NSButton 			*lightFadeDistanceOn;
    IBOutlet NSTextField		*lightFadeDistanceEdit;
    IBOutlet NSPopUpButton	*lightFadePowerPopup;
    IBOutlet NSMatrix 			*lightLocationMatrix;
    IBOutlet NSButton 			*lightLooksLikeOn;
    IBOutlet NSButton 			*lightMediaAttenuationOn;
    IBOutlet NSButton 			*lightMediaInteractionOn;
    IBOutlet NSButton 			*lightParallelLightOn;
    IBOutlet NSMatrix				*lightParallelLightPointAtMatrix;
    IBOutlet NSButton 			*lightPhotonsAreaLightOn;
    IBOutlet NSBox					*lightPhotonsGroupBox;
    IBOutlet NSButton 			*lightPhotonsGroupOn;
    IBOutlet NSMatrix 			*lightPhotonsReflectionMatrix;
    IBOutlet NSButton 			*lightPhotonsReflectionOn;
    IBOutlet NSMatrix 			*lightPhotonsRefractionMatrix;
    IBOutlet NSButton 			*lightPhotonsRefractionOn;
    IBOutlet NSButton 			*lightProjectedTroughOn;
    IBOutlet NSTextField		*lightProjectedTroughObjectEdit;
    IBOutlet NSButton 			*lightShadowlessOn;
}
- (IBAction)lightAreaLightAdaptiveOn:(id)sender;
- (IBAction)lightAreaLightAxis1Popup:(id)sender;
- (IBAction)lightAreaLightAxis2Popup:(id)sender;
- (IBAction)lightAreaLightGroupOn:(id)sender;
- (IBAction)lightDirectionalLightGroupOn:(id)sender;
- (IBAction)lightFadeDistanceOn:(id)sender;
- (IBAction)lightPhotonsGroupChanged:(id)sender;
- (IBAction)lightProjectedTroughOn:(id)sender;

- (void)lightPhotonsReflectionOn;
- (void)lightPhotonsRefractionOn;

@end
