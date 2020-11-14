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
#import "objectTemplate.h"
#import "tooltipAutomator.h"
#import "transformationsTemplate.h"
#import "materialTemplate.h"
#import "functionTemplate.h"
#import "photonsTemplate.h"
#import "objectEditorTemplate.h"
#import "standardMethods.h"

// this must be the last file included
#import "syspovdebug.h"


#define kWriteHollow if ( [[dict objectForKey:@"objectHollowOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"hollow\n"];

#define kWriteUVMapping if ( [[dict objectForKey:@"objectUvMappingOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"uv_mapping\n"];

#define kWriteNoImage if ( [[dict objectForKey:@"objectNoImageOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"no_image\n"];

#define kWriteNoShadow if ( [[dict objectForKey:@"objectNoShadowOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"no_shadow\n"];

#define kWriteNoRadiosity if ( [[dict objectForKey:@"objectNoRadiosityOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"no_radiosity\n"];

#define kWriteNoRadiosity if ( [[dict objectForKey:@"objectNoRadiosityOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"no_radiosity\n"];

#define kWriteRadiosityImportance if ( [[dict objectForKey:@"objectRadiosityImportanceOn"]intValue]==NSOnState)\
					[ds appendTabAndFormat:@"radiosity { importance %@ }\n",[dict objectForKey:@"objectRadiosityImportanceEdit"]];

#define kWriteNoReflection if ( [[dict objectForKey:@"objectNoReflectionOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"no_reflection\n"];

#define kWriteDoubleIlluminate if ( [[dict objectForKey:@"objectDoubleIlluminateOn"]intValue]==NSOnState)\
				[ds copyTabAndText:@"double_illuminate\n"];

static void WriteMaterialAndTrans(MutableTabString *ds,NSDictionary *dict, BOOL checkForUVMapping);


const char Poly2[10][10]={"\px2",	"\py2", "\pz2", "\pxy", "\pxz", 	"\pyz",	"\px", "\py", "\pz",	"\p1"};
const char Poly3[20][10]={"\px3","\px2y","\px2z","\px2","\pxy2","\pxyz","\pxy","\pxz2","\pxz","\px",
											"\py3","\py2z","\py2","\pyz2","\pyz","\py","\pz3","\pz2","\pz","\p1"};
const char Poly4[35][10]={"\px4","\px3y","\px3z","\px3","\px2y2","\px2yz","\px2y","\px2z2","\px2z",
											"\px2","\pxy3","\pxy2z","\pxy2","\pxyz2","\pxyz","\pxy","\pxz3","\pxz2",
											"\pxz","\px","\py4","\py3z","\py3","\py2z2","\py2z","\py2","\pyz3","\pyz2",
											"\pyz","\py","\pz4","\pz3","\pz2","\pz","\p1"};
											
const char Poly5[56][10]={"\px5","\px4y","\px4z","\px4","\px3y2","\px3yz","\px3y","\px3z2","\px3z",
											"\px3","\px2y3","\px2y2z","\px2y2","\px2yz2","\px2yz","\px2y","\px2z3",
											"\px2z2","\px2z","\px2","\pxy4","\pxy3z","\pxy3","\pxy2z2","\pxy2z","\pxy2",
											"\pxyz3","\pxyz2","\pxyz","\pxy","\pxz4","\pxz3","\pxz2","\pxz","\px","\py5",
											"\py4z","\py4","\py3z2","\py3z","\py3","\py2z3","\py2z2","\py2z","\py2","\pyz4",
											"\pyz3","\pyz2","\pyz","\py","\pz5","\pz4","\pz3","\pz2","\pz","\p1"};
const char Poly6[84][10]={"\px6","\px5y","\px5z","\px5","\px4y2","\px4yz","\px4y","\px4z2","\px4z",
											"\px4","\px3y3","\px3y2z","\px3y2","\px3yz2","\px3yz","\px3y","\px3z3","\px3z2",
											"\px3z","\px3","\px2y4","\px2y3z","\px2y3","\px2y2z2","\px2y2z","\px2y2","\px2yz3",
											"\px2yz2","\px2yz","\px2y","\px2z4","\px2z3","\px2z2","\px2z","\px2","\pxy5","\pxy4z",
											"\pxy4","\pxy3z2","\pxy3z","\pxy3","\pxy2z3","\pxy2z2","\pxy2z","\pxy2","\pxyz4",
											"\pxyz3","\pxyz2","\pxyz","\pxy","\pxz5","\pxz4","\pxz3","\pxz2","\pxz","\px","\py6",
											"\py5z","\py5","\py4z2","\py4z","\py4","\py3z3","\py3z2","\py3z","\py3","\py2z4",
											"\py2z3","\py2z2","\py2z","\py2","\pyz5","\pyz4","\pyz3","\pyz2","\pyz","\py",
											"\pz6","\pz5","\pz4","\pz3","\pz2","\pz","\p1"};
const char Poly7[120][10]={"\px7","\px6y","\px5z","\px5","\px5y2","\px5yz","\px5y","\px5z2","\px5z","\px5",
											"\px4y3","\px4y2z","\px4y2","\px4yz2","\px4yz","\px4y","\px4z3","\px4z2","\px4z",
											"\px4","\px3y4","\px3y3z","\px3y3","\px3y2z2","\px3y2z","\px3y2","\px3yz3","\px3yz2",
											"\px3yz","\px3y","\px3z4","\px3z3","\px3z2","\px3z","\px3","\px2y5","\px2y4z","\px2y4",
											"\px2y3z2","\px2y3z","\px2y3","\px2y2z3","\px2y2z2","\px2y2z","\px2y2","\px2yz4",
											"\px2yz3","\px2yz2","\px2yz","\px2y","\px2z5","\px2z4","\px2z3","\px2z2","\px2z",
											"\px2","\pxy6","\pxy5z","\pxy5","\pxy4z2","\pxy4z","\pxy4","\pxy3z3","\pxy3z2",
											"\pxy3z","\pxy3","\pxy2z4","\pxy2z3","\pxy2z2","\pxy2z","\pxy2","\pxyz5","\pxyz4",
											"\pxyz3","\pxyz2","\pxyz","\pxy","\pxz6","\pxz5","\pxz4","\pxz3","\pxz2","\pxz","\px",
											"\py7","\py6z","\py6","\py5z2","\py5z","\py5","\py4z3","\py4z2","\py4z","\py4",
											"\py3z4","\py3z3","\py3z2","\py3z","\py3","\py2z5","\py2z4","\py2z3","\py2z2","\py2z",
											"\py2","\pyz6","\pyz5","\pyz4","\pyz3","\pyz2","\pyz","\py","\pz7","\pz6","\pz5",
											"\pz4","\pz3","\pz2","\pz","\p1"};

@implementation ObjectTemplate

//---------------------------------------------------------------------
// createDescriptionWithDictionary:andTabs
//---------------------------------------------------------------------
+(MutableTabString *) createDescriptionWithDictionary:(NSDictionary*) dict andTabs:(int) tabs extraParam:(int) param mutableTabString:(MutableTabString*) ds

{

	float c1x, c1y, c1z;
	float c2x, c2y, c2z;
	NSArray *funcStr;

	id objectEditorPrefs=nil;
	objectmap *oMap=nil;			

	if ( dict== nil)
		dict=[ObjectTemplate createDefaults:menuTagTemplateObject];
	else
		[BaseTemplate addMissingObjectsInPreferences:dict forClass:[ObjectTemplate class] andTemplateType:menuTagTemplateObject];

	if (ds == nil )
	{
		ds=[[[MutableTabString alloc] initWithTabs:tabs andCallerType:NO]autorelease];
		if (ds == nil )
		return nil;
	}

	[dict retain];

	switch ( [[dict objectForKey:@"objectTypePopUp"]intValue])
	{
//cObjectBicubicPatch
		case cObjectBicubicPatch:
			c1x=[[dict objectForKey:@"objectBicubicPatchCorner1MatrixX"]floatValue];
			c1y=[[dict objectForKey:@"objectBicubicPatchCorner1MatrixY"]floatValue];
			c1z=[[dict objectForKey:@"objectBicubicPatchCorner1MatrixZ"]floatValue];

			c2x=[[dict objectForKey:@"objectBicubicPatchCorner2MatrixX"]floatValue];
			c2y=[[dict objectForKey:@"objectBicubicPatchCorner2MatrixY"]floatValue];
			c2z=[[dict objectForKey:@"objectBicubicPatchCorner2MatrixZ"]floatValue];

			[ds copyTabAndText:@"bicubic_patch {\n"];
			[ds addTab];
			
			switch([[dict objectForKey:@"objectBicubicPatchTypePopUp"]intValue])
			{
				case 0: 	[ds copyTabAndText:@"type 0\n"]; break;
				case 1: 	[ds copyTabAndText:@"type 1\n"]; break;
			}
			[ds appendTabAndFormat:@"flatness %@ u_steps %@ v_steps %@\n", 
												[dict objectForKey:@"objectBicubicPatchFlatnessEdit"],
												[dict objectForKey:@"objectBicubicPatchUStepsEdit"],
												[dict objectForKey:@"objectBicubicPatchVStepsEdit"]];

			[ds appendTabAndFormat:@"<%lf, %lf, %lf>, ", c1x, c2y, c2z];
			[ds appendFormat:@"<%lf,%lf, %lf>,",c1x+(c2x-c1x)/3.0, c2y,c2z];
			[ds appendFormat:@"<%lf, %lf, %lf>,",c2x-(c2x-c1x)/3.0, c2y,c2z];
			[ds appendFormat:@"<%lf, %lf, %lf>,\n",c2x, c2y, c2z];
		
			[ds appendTabAndFormat:@"<%lf,%lf,%lf>,",c1x, c2y-(c2y-c1y)/3.0, c2z-(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf,%lf,%lf>,",c1x+(c2x-c1x)/3.0, c2y-(c2y-c1y)/3.0, c2z-(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf,%lf,%lf>,",c2x-(c2x-c1x)/3.0, c2y-(c2y-c1y)/3.0, c2z-(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf,%lf,%lf>,\n",c2x, c2y-(c2y-c1y)/3.0, c2z-(c2z-c1z)/3.0];

			[ds appendTabAndFormat:@"<%lf,%lf,%lf>,",c1x, c1y+(c2y-c1y)/3.0, c1z+(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf,%lf, %lf>,",c1x+(c2x-c1x)/3.0, c1y+(c2y-c1y)/3.0, c1z+(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf, %lf,%lf>,",c2x-(c2x-c1x)/3.0, c1y+(c2y-c1y)/3.0, c1z+(c2z-c1z)/3.0];
			[ds appendFormat:@"<%lf,%lf,%lf>,\n",c2x, c1y+(c2y-c1y)/3.0, c1z+(c2z-c1z)/3.0];

			[ds appendTabAndFormat:@"<%lf,%lf,%lf>,",c1x, c1y, c1z];
			[ds appendFormat:@"<%lf,%lf,%lf>,",c1x+(c2x-c1x)/3.0, c1y, c1z];
			[ds appendFormat:@"<%lf,%lf,%lf>,",c2x-(c2x-c1x)/3.0, c1y, c1z];
			[ds appendFormat:@"<%lf,%lf,%lf>\n",c2x, c1y, c1z];
			kWriteNoImage
			kWriteNoShadow
			kWriteRadiosityImportance
			kWriteNoRadiosity
			kWriteNoReflection
			
			WriteMaterialAndTrans(ds, dict, YES);
			kWriteDoubleIlluminate
			break;
//	if ( [[dict objectForKey:@"backgroundRainbowArcAngleOn"]intValue]==NSOnState)
//		[ds appendTabAndFormat:@"arc_angle %@\n",[dict objectForKey:@"backgroundRainbowArcAngleEdit"]];

//cObjectBlob
		case cObjectBlob:
			[ds copyTabAndText:@"blob {\n"];
			[ds addTab];
			[ds appendTabAndFormat:@"threshold %@\n",[dict objectForKey:@"objectBlobThresholdEdit"]];
			
			if ([[dict objectForKey:@"objectBlobSphericalOn"]intValue]==NSOnState)	//blob sphere
			{
				for( int x=1; x<=[[dict objectForKey:@"objectBlobSphericalNumberOfComponentsEdit"]intValue]; x++)
				{
					[ds copyTabAndText:@"sphere {\n"];
					[ds addTab];
					[ds appendTabAndFormat:@"<0, 0, 0>, %@ strength %@\n",[dict objectForKey:@"objectBlobSphericalRadiusEdit"],
																										[dict objectForKey:@"objectBlobSphericalStrengthEdit"]];
					if ([[dict objectForKey:@"objectBlobSphericalTextureOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"texture {\n"];
						[ds addTab];
						[ds copyTabAndText:@"pigment { rgb <0.5, 0.5, 0.5> }\n"];
						[ds removeTab];
						[ds copyTabAndText:@"}\n"];
					}	
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
				}
			}

			if ([[dict objectForKey:@"objectBlobCylindricalOn"]intValue]==NSOnState)	//blob cylinder
			{
				for( int x=1; x<=[[dict objectForKey:@"objectBlobCylindricalNumberOfComponentsEdit"]intValue]; x++)
				{
					[ds copyTabAndText:@"cylinder {\n"];
					[ds addTab];
					[ds appendTabAndFormat:@"< %@, %@, %@>, ",[dict objectForKey:@"objectBlobCylindricalEnd1MatrixX"],
																					[dict objectForKey:@"objectBlobCylindricalEnd1MatrixY"],
																					[dict objectForKey:@"objectBlobCylindricalEnd1MatrixZ"]];
					[ds appendTabAndFormat:@"< %@, %@, %@>, ",[dict objectForKey:@"objectBlobCylindricalEnd2MatrixX"],
																					[dict objectForKey:@"objectBlobCylindricalEnd2MatrixY"],
																					[dict objectForKey:@"objectBlobCylindricalEnd2MatrixZ"]];
					[ds appendTabAndFormat:@"%@ strength %@\n",[dict objectForKey:@"objectBlobCylindricalRadiusEdit"],
																						[dict objectForKey:@"objectBlobCylindricalStrengthEdit"]];
					if ([[dict objectForKey:@"objectBlobCylindricalTextureOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"texture {\n"];
						[ds addTab];
						[ds copyTabAndText:@"pigment { rgb <0.5, 0.5, 0.5> }\n"];
						[ds removeTab];
						[ds copyTabAndText:@"}\n"];
					}	
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
				}
			}

			if ( [[dict objectForKey:@"objectBlobSturm"]intValue]==NSOnState)
				[ds copyTabAndText:@"sturm\n"];
			
			kWriteHollow
			kWriteNoImage
			kWriteNoShadow
			kWriteRadiosityImportance
			kWriteNoRadiosity
			kWriteNoReflection
			WriteMaterialAndTrans(ds, dict, YES);
			kWriteDoubleIlluminate

				break;
//cObjectBox
			case cObjectBox:
				[ds copyTabAndText:@"box {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"< %@, %@, %@>, ",[dict objectForKey:@"objectBoxCorner1MatrixX"],
																					[dict objectForKey:@"objectBoxCorner1MatrixY"],
																				[dict objectForKey:@"objectBoxCorner1MatrixZ"]];
				[ds appendTabAndFormat:@"< %@, %@, %@>\n",[dict objectForKey:@"objectBoxCorner2MatrixX"],
																					[dict objectForKey:@"objectBoxCorner2MatrixY"],
																					[dict objectForKey:@"objectBoxCorner2MatrixZ"]];

				kWriteHollow
				kWriteNoImage
				kWriteNoShadow
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoReflection
				kWriteUVMapping
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectCone
			case cObjectCone:
				[ds copyTabAndText:@"cone {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@,  ",[dict objectForKey:@"objectConeBaseMatrixX"],
																					[dict objectForKey:@"objectConeBaseMatrixY"],
																				[dict objectForKey:@"objectConeBaseMatrixZ"],
																					[dict objectForKey:@"objectConeBaseRadiusEdit"]];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@\n",[dict objectForKey:@"objectConeCapMatrixX"],
																					[dict objectForKey:@"objectConeCapMatrixY"],
																					[dict objectForKey:@"objectConeCapMatrixZ"],
																					[dict objectForKey:@"objectConeCapRadiusEdit"]];
				if ( [[dict objectForKey:@"objectConeOpenOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"open\n"];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectCylinder
			case cObjectCylinder:
				[ds copyTabAndText:@"cylinder {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@, %@>, ",[dict objectForKey:@"objectCylinderBaseMatrixX"],
																					[dict objectForKey:@"objectCylinderBaseMatrixY"],
																				[dict objectForKey:@"objectCylinderBaseMatrixZ"]];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@\n",[dict objectForKey:@"objectCylinderCapMatrixX"],
																					[dict objectForKey:@"objectCylinderCapMatrixY"],
																					[dict objectForKey:@"objectCylinderCapMatrixZ"],
																					[dict objectForKey:@"objectCylinderCapRadiusEdit"]];
				if ( [[dict objectForKey:@"objectCylinderOpenOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"open\n"];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectDisc
			case cObjectDisc:
				[ds copyTabAndText:@"disc {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@, %@>, ",[dict objectForKey:@"objectDiscCenterMatrixX"],
																					[dict objectForKey:@"objectDiscCenterMatrixY"],
																				[dict objectForKey:@"objectDiscCenterMatrixZ"]];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@",[dict objectForKey:@"objectDiscNormalMatrixX"],
																					[dict objectForKey:@"objectDiscNormalMatrixY"],
																					[dict objectForKey:@"objectDiscNormalMatrixZ"],
																					[dict objectForKey:@"objectDiscRadiusEdit"]];
				if ( [[dict objectForKey:@"objectDiscHoleRadiusOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@", %@",[dict objectForKey:@"objectDiscHoleRadiusEdit"]];
				[ds copyText:@"\n"];

				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectHeightField
			case cObjectHeightField:
				[ds copyTabAndText:@"height_field {\n"];
				WritePatternPanel(ds, dict, @"objectHeightFieldFileTypePopUp", 
														@"objectHeightFieldFunctionImageWidth", @"objectHeightFieldFunctionImageHeight",
														@"objectHeightFieldFunctionEdit", @"objectHeightFieldPatternPigment",
														@"objectHeightFieldPigmentPigment" ,@"objectHeightFieldFileName");
		
				if ( [[dict objectForKey:@"objectHeightFieldSmoothOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"smooth\n"];
				if ( [[dict objectForKey:@"objectHeightFieldWaterLevelOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"water_level %@\n",[dict objectForKey:@"objectHeightFieldWaterLevelEdit"]];
				if ( [[dict objectForKey:@"objectHeightFieldHierarchyOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"hierarchy off\n"];
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectIsosurface
			case cObjectIsosurface:
				[ds copyTabAndText:@"isosurface {\n"];
				[ds addTab];
				[ds copyTabAndText:@"function {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"objectIsoFunctionEdit"]];
				[ds removeTab];
				[ds copyTabAndText:@"}\n"];

				if ( [[dict objectForKey:@"objectIsoAccuracyOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"accuracy %@\n",[dict objectForKey:@"objectIsoAccuracyEdit"]];
				if ( [[dict objectForKey:@"objectIsoThresholdOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"threshold %@\n",[dict objectForKey:@"objectIsoThresholdEdit"]];

				if ( [[dict objectForKey:@"objectIsoMaxTraceOn"]intValue]==NSOnState)
				{
					if ( [[dict objectForKey:@"objectIsoMaxTraceMatrixl"]intValue]==cSecondCell)
						[ds copyTabAndText:@"all_intersections\n"];
					else
						[ds appendTabAndFormat:@"max_trace %@\n",[dict objectForKey:@"objectIsoMaxTraceEdit"]];
				}
			


				WriteIsoBounding(ds, dict, @"objectIsoContainerObjectPopUp",
										@"objectIsoContainerBoxCorner1MatrixX", @"objectIsoContainerBoxCorner1MatrixY", @"objectIsoContainerBoxCorner1MatrixZ",
										@"objectIsoContainerBoxCorner2MatrixX", @"objectIsoContainerBoxCorner2MatrixY", @"objectIsoContainerBoxCorner2MatrixZ",
										@"objectIsoContainerSphereCenterMatrixX", @"objectIsoContainerSphereCenterMatrixY", @"objectIsoContainerSphereCenterMatrixZ",
										@"objectIsoContainerSphereRadiusEdit");
				if ( [[dict objectForKey:@"objectIsoOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
				
				if ( [[dict objectForKey:@"objectIsoMaxGradientGroupOn"]intValue]==NSOnState)
				{
					if ( [[dict objectForKey:@"objectIsoMaxGradientMatrix"]intValue]==cFirstCell)
						[ds appendTabAndFormat:@"max_gradient %@\n",[dict objectForKey:@"objectIsoMaxGradientEdit"]];
					else
						[ds appendTabAndFormat:@"evaluate %@, %@, %@\n",[dict objectForKey:@"objectIsoEvaluateEditX"],
																					[dict objectForKey:@"objectIsoEvaluateEditY"],
																					[dict objectForKey:@"objectIsoEvaluateEditZ"]];
				}

	/*			if ( [[dict objectForKey:@"objectIsoMessageOn"]intValue]==NSOnState)
				{
					if ( [[dict objectForKey:@"objectIsoMessageMatrix"]intValue]==cFirstCell)
						[ds copyTabAndText:@"message on\n"];
					else
						[ds copyTabAndText:@"message off\n"];
				}*/
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectJuliaFractal
			case cObjectJuliaFractal:
				[ds copyTabAndText:@"julia_fractal {\n"];
				[ds addTab];

				[ds appendTabAndFormat:@"<%@, %@, %@, %@>\n",[dict objectForKey:@"objectFractal4DjuliaParameterMatrixX"],
																					[dict objectForKey:@"objectFractal4DjuliaParameterMatrixY"],
																					[dict objectForKey:@"objectFractal4DjuliaParameterMatrixZ"],
																					[dict objectForKey:@"objectFractal4DjuliaParameterMatrix4"]];
				switch([[dict objectForKey:@"objectFractal4DAlgebraPopUp"]intValue])
				{
					case cQuaternation: 	[ds copyTabAndText:@"quaternion \n"];		break;
					case cHypercomplex:[ds copyTabAndText:@"hypercomplex\n"];	break;
						break;
				}			
				
				switch([[dict objectForKey:@"objectFractalFunctionPopUp"]intValue])
				{
					case cSqrt: 			[ds copyTabAndText:@"sqr\n"];			break;
					case cCube: 			[ds copyTabAndText:@"cube\n"];			break;
					case cExp: 			[ds copyTabAndText:@"exp\n"];			break;
					case cReciprocal:	[ds copyTabAndText:@"reciprocal\n"];	break;
					case cSin : 			[ds copyTabAndText:@"sin\n"];			break;
					case cAsin: 			[ds copyTabAndText:@"asin\n"];			break;
					case cSinh: 			[ds copyTabAndText:@"sinh\n"];			break;
					case cAsinh: 			[ds copyTabAndText:@"asinh\n"];		break;
					case cCos: 			[ds copyTabAndText:@"cos\n"];			break;
					case cAcos: 			[ds copyTabAndText:@"acos\n"];			break;
					case cCosh: 			[ds copyTabAndText:@"cosh\n"];			break;
					case cAcosh: 			[ds copyTabAndText:@"acosh\n"];		break;
					case cTan: 			[ds copyTabAndText:@"tan\n"];			break;
					case cAtan: 			[ds copyTabAndText:@"atan\n"];			break;
					case cTanh: 			[ds copyTabAndText:@"tanh\n"];			break;
					case cAtanh: 			[ds copyTabAndText:@"atanh\n"];		break;
					case cLog: 			[ds copyTabAndText:@"log\n"];			break;
					case cPwr: 			[ds copyTabAndText:@"pwr(x,y)\n"];	break;
				}

				[ds appendTabAndFormat:@"max_iteration %@\n",[dict objectForKey:@"objectFractalMaxIterationEdit"]];
				[ds appendTabAndFormat:@"precision %@\n",[dict objectForKey:@"objectFractalPrecisionEdit"]];
				
				if ( [[dict objectForKey:@"objectFractalSliceOn"]intValue]==NSOnState)
				{			
					[ds appendTabAndFormat:@"slice<%@, %@, %@, %@>, %@\n",[dict objectForKey:@"objectFractal4DNormalMatrixX"],
																					[dict objectForKey:@"objectFractal4DNormalMatrixY"],
																					[dict objectForKey:@"objectFractal4DNormalMatrixZ"],
																					[dict objectForKey:@"objectFractal4DNormalMatrix4"],
																					[dict objectForKey:@"objectFractalDistanceEdit"]];
				}
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectLathe
			case cObjectLathe:
				objectEditorPrefs=[dict objectForKey:@"objectLathe"];
				[BaseTemplate addMissingObjectsInPreferences:objectEditorPrefs forClass:[ObjectEditorTemplate class] andTemplateType:menuTagTemplateLathe];
				
				if ( objectEditorPrefs!=nil)
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				else
				{
					objectEditorPrefs=[ObjectEditorTemplate createDefaults:menuTagTemplateLathe];
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				}
				if ( objectEditorPrefs==nil)	// should never happen
				{
					[dict release];
					return nil;		
				}
				[ds copyTabAndText:@"lathe {\n"];
				[ds addTab];


				oMap=[NSUnarchiver unarchiveObjectWithData:objectEditorPrefs];

				switch([oMap buttonState:cSplineTypePopUp])
				{
					case cLinearSpline: 		[ds copyTabAndText:@"linear_spline\n"];			break;
					case cQuadraticSpline: 	[ds copyTabAndText:@"quadratic_spline\n"];	break;
					case cCubicSpline: 			[ds copyTabAndText:@"cubic_spline\n"];			break;
					case cBezierSpline: 		[ds copyTabAndText:@"bezier_spline\n"];			break;
				}			
				[ds appendTabAndFormat:@"%d,\n",[oMap count]];

				for ( int row=0; row <[oMap count]-1; row++)
				{
					[ds appendTabAndFormat:@"<%@, %@>,\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapXIndex],
																					[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapYIndex]];
				}
				[ds appendTabAndFormat:@"<%@, %@>\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapXIndex],
																		[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapYIndex]];

				if ( [[dict objectForKey:@"objectLatheSturmOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"sturm\n"];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				kWriteUVMapping
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate

				break;
//cObjectParametric
			case cObjectParametric:
				[ds copyTabAndText:@"parametric {\n"];
				[ds addTab];
				[ds copyTabAndText:@"function {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"objectParametricFunctionXEdit"]];
				[ds removeTab];
				[ds copyTabAndText:@"},\n"];
				[ds copyTabAndText:@"function {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"objectParametricFunctionYEdit"]];
				[ds removeTab];
				[ds copyTabAndText:@"},\n"];
				[ds copyTabAndText:@"function {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"objectParametricFunctionZEdit"]];
				[ds removeTab];
				[ds copyTabAndText:@"}\n"];

				[ds appendTabAndFormat:@"<%@, %@>, <%@,%@>\n",[dict objectForKey:@"objectParametricBounderiesUMatrixX"],
																								[dict objectForKey:@"objectParametricBounderiesUMatrixY"],
																								[dict objectForKey:@"objectParametricBounderiesVMatrixX"],
																								[dict objectForKey:@"objectParametricBounderiesVMatrixY"]];
				WriteIsoBounding(ds, dict, @"objectParametricContainerObjectPopUp",
										@"objectParametricContainerBoxCorner1MatrixX", @"objectParametricContainerBoxCorner1MatrixY", @"objectParametricContainerBoxCorner1MatrixZ",
										@"objectParametricContainerBoxCorner2MatrixX", @"objectParametricContainerBoxCorner2MatrixY", @"objectParametricContainerBoxCorner2MatrixZ",
										@"objectParametricContainerSphereCenterMatrixX", @"objectParametricContainerSphereCenterMatrixY", @"objectParametricContainerSphereCenterMatrixZ",
										@"objectParametricContainerSphereRadiusEdit");

				if ( [[dict objectForKey:@"objectParametricMaxGradientOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"max_gradient %@\n",[dict objectForKey:@"objectParametricMaxGradientEdit"]];

				if ( [[dict objectForKey:@"objectParametricAccuracyOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"accuracy %@\n",[dict objectForKey:@"objectParametricAccuracyEdit"]];

				if ( [[dict objectForKey:@"objectParametricPrecomputeDepthsOn"]intValue]==NSOnState)
				{
					[ds appendTabAndFormat:@"precompute %@",[dict objectForKey:@"objectParametricPrecomputeDepthsEdit"]];
					if ( [[dict objectForKey:@"objectParametricOfVariablesXOn"]intValue]==NSOnState)
						[ds copyText:@", x"];
					if ( [[dict objectForKey:@"objectParametricOfVariablesYOn"]intValue]==NSOnState)
						[ds copyText:@", y"];
					if ( [[dict objectForKey:@"objectParametricOfVariablesZOn"]intValue]==NSOnState)
						[ds copyText:@", z"];
					[ds copyText:@"\n"];
				}	
				
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				kWriteUVMapping
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectPlane
			case cObjectPlane:
				[ds copyTabAndText:@"plane {\n"];
				[ds addTab];
				[ds copyTabText];
				[ds addXYZVector:dict popup:@"objectPlaneNormalXYZPopUp" xKey:@"objectPlaneNormalMatrixX" 
														yKey:@"objectPlaneNormalMatrixY" zKey:@"objectPlaneNormalMatrixZ"];
				[ds appendFormat:@", %@\n",[dict objectForKey:@"objectPlaneDistanceEdit"]];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectPoly
			case cObjectPoly:
		{
				int Number=0;
				funcStr=[dict objectForKey:@"polyArray"];
				if ( funcStr==nil)
				{
					[dict release];
					return nil;
				}
				switch ([[dict objectForKey:@"objectPolyPolyTypePopUp"]intValue])
				{
					case cQuadricPoly: 	
						Number=0;
						[ds copyTabAndText:@"quadric {\n"];
						[ds addTab];

						[ds appendTabAndFormat:@"<%@, %@, %@>,\n",[funcStr objectAtIndex:0], [funcStr objectAtIndex:1],[funcStr objectAtIndex:2]];
						[ds appendTabAndFormat:@"<%@, %@, %@>,\n",[funcStr objectAtIndex:3], [funcStr objectAtIndex:4],[funcStr objectAtIndex:5]];
						[ds appendTabAndFormat:@"<%@, %@, %@>,\n",[funcStr objectAtIndex:6], [funcStr objectAtIndex:7],[funcStr objectAtIndex:8]];
						[ds appendTabAndFormat:@"%@\n",[funcStr objectAtIndex:9]];
						break;
					case cCubicPoly: 	[ds copyTabAndText:@"cubic {\n"];	Number=20;	break;
					case cQuarticPoly:	[ds copyTabAndText:@"quartic {\n"];	Number=35;	break;
					case cPoly5: 		[ds copyTabAndText:@"poly { 5,\n"];	Number=56;	break;
					case cPoly6: 		[ds copyTabAndText:@"poly { 6,\n"];	Number=84;	break;
					case cPoly7: 		[ds copyTabAndText:@"poly { 7,\n"];	Number=120;	break;
				}
				if ( Number )
				{
					[ds addTab];
					[ds copyTabAndText:@"<\n"];
					[ds addTab];
					for(int Counter=0, oi=1; Counter<Number; Counter++, oi++)
					{
						if ( Counter ==Number-1)
							[ds appendTabAndFormat:@"%@\n",[funcStr objectAtIndex:Counter]];
						else if ( oi==5)
						{
							oi=0;
							[ds appendTabAndFormat:@"%@,\n",[funcStr objectAtIndex:Counter]];
						}
						else 
							[ds appendTabAndFormat:@"%@, ",[funcStr objectAtIndex:Counter]];
					}
					[ds removeTab];
					[ds copyTabAndText:@">\n"];
				}
				if ( (Number == 20 || Number == 35 )&&  [[dict objectForKey:@"objectPolySturmOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"sturm\n"];
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
		}
				break;
//cObjectPolygon
			case cObjectPolygon:
				objectEditorPrefs=[dict objectForKey:@"objectPolygon"];
				[BaseTemplate addMissingObjectsInPreferences:objectEditorPrefs forClass:[ObjectEditorTemplate class] andTemplateType:menuTagTemplatePolygon];
				
				if ( objectEditorPrefs!=nil)
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				else
				{
					objectEditorPrefs=[ObjectEditorTemplate createDefaults:menuTagTemplatePolygon];
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				}
				if ( objectEditorPrefs==nil)	// should never happen
				{
					[dict release];
					return nil;
				}
				[ds copyTabAndText:@"polygon {\n"];
				[ds addTab];

				oMap=[NSUnarchiver unarchiveObjectWithData:objectEditorPrefs];

				[ds appendTabAndFormat:@"%d\n",[oMap count]];

				for ( int row=0; row <[oMap count]-1; row++)
				{
					[ds appendTabAndFormat:@"<%@, %@>,\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapXIndex],
																					[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapYIndex]];
				}
				[ds appendTabAndFormat:@"<%@, %@>\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapXIndex],
																		[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapYIndex]];

				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectPrism
			case cObjectPrism:
				objectEditorPrefs=[dict objectForKey:@"objectPrism"];
				[BaseTemplate addMissingObjectsInPreferences:objectEditorPrefs forClass:[ObjectEditorTemplate class] andTemplateType:menuTagTemplatePrism];
				
				if ( objectEditorPrefs!=nil)
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				else
				{
					objectEditorPrefs=[ObjectEditorTemplate createDefaults:menuTagTemplatePrism];
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				}
				if ( objectEditorPrefs==nil)	// should never happen
				{
					[dict release];
					return nil;
				}
				oMap=[NSUnarchiver unarchiveObjectWithData:objectEditorPrefs];

				if ( [[dict objectForKey:@"objectPrismBevelPrismGroupOn"]intValue]==NSOnState && [[dict objectForKey:@"objectPrismSweepTypePopUp"]intValue]==cPrismLinearSweep)
				{
					[ds copyTabAndText:@"//*************** START BEVELED PRISM ***************\n"];
					[ds appendTabAndFormat:@"#declare PrismPoints = array [%d] \n",[oMap count]];
					[ds copyTabAndText:@"{\n"];
					[ds addTab];
					for ( int row=0; row <[oMap count]-1; row++)
					{
						[ds appendTabAndFormat:@"<%@, %@>,\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapXIndex],
																						[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapYIndex]];
					}
					[ds appendTabAndFormat:@"<%@, %@>\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapXIndex],
																			[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapYIndex]];
					[ds removeTab];
					[ds copyTabAndText:@"}\n\n"];
			
					[ds appendTabAndFormat:@"#declare Height = %@  - (  %@ );\n",[dict objectForKey:@"objectPrismTopHeightEdit"],
																													[dict objectForKey:@"objectPrismBaseHeightEdit"]];

					[ds appendTabAndFormat:@"#declare Bevel_H =  Height / %@;\n",[dict objectForKey:@"objectPrismBevelPrismFractionHeightEdit"]];
					[ds appendTabAndFormat:@"#declare Base = %@;\n",[dict objectForKey:@"objectPrismBaseHeightEdit"]];
					[ds appendTabAndFormat:@"#declare Angle = %@;\n",[dict objectForKey:@"objectPrismBevelPrismFractionAngleEdit"]];

					[ds copyTabAndText:@"#macro PTS ()\n"];
					[ds addTab];
					[ds copyTabAndText:@"#local Nr = dimension_size (PrismPoints,1);\n"];
					[ds copyTabAndText:@"Nr,\n"];
					[ds copyTabAndText:@"#local C = 0;\n"];
					[ds copyTabAndText:@"#while ( C < Nr)\n"];;
					[ds addTab];
					[ds copyTabAndText:@"#local Va = (1 + (C * (Nr - (1))/(Nr -1)));\n"];
					[ds copyTabAndText:@"PrismPoints [Va-1]\n"];
					[ds copyTabAndText:@"#declare C = C +1;\n"];
					[ds removeTab];
					[ds copyTabAndText:@"#end\n"];
					[ds removeTab];
					[ds copyTabAndText:@"#end\n"];

					
					[ds copyTabAndText:@"union {\n"];
					[ds addTab];
					[ds copyTabAndText:@"prism {\n"]; 
					[ds addTab];
					
					switch([oMap buttonState:cSplineTypePopUp])
					{
						case cLinearSpline: 		[ds copyTabAndText:@"linear_spline\n"];			break;
						case cQuadraticSpline: 	[ds copyTabAndText:@"quadratic_spline\n"];	break;
						case cCubicSpline: 			[ds copyTabAndText:@"cubic_spline\n"];			break;
						case cBezierSpline: 		[ds copyTabAndText:@"bezier_spline\n"];			break;
					}			
					[ds copyTabAndText:@"linear_sweep\n"];

					[ds copyTabAndText:@"Base,\t//Base height\n"];
					[ds copyTabAndText:@"Base+(Height-Bevel_H),\t//Top Height\n"];
					[ds copyTabAndText:@"PTS()\n"];

					if ( [[dict objectForKey:@"objectPrismOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
					[ds copyTabAndText:@"//texture prism\n"];
					if ( [[dict objectForKey:@"objectPrismSturmOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"sturm\n"];


					[ds removeTab];
					
					[ds copyTabAndText:@"}\n"];
									
					[ds copyTabAndText:@"intersection {\n"];
					[ds addTab];
					[ds copyTabAndText:@"prism {\n"];
					[ds addTab];

					switch([oMap buttonState:cSplineTypePopUp])
					{
						case cLinearSpline: 		[ds copyTabAndText:@"linear_spline\n"];			break;
						case cQuadraticSpline: 	[ds copyTabAndText:@"quadratic_spline\n"];	break;
						case cCubicSpline: 			[ds copyTabAndText:@"cubic_spline\n"];			break;
						case cBezierSpline: 		[ds copyTabAndText:@"bezier_spline\n"];			break;
					}			
					[ds copyTabAndText:@"conic_sweep\n"];
					[ds copyTabAndText:@"-(1/tan(radians(Angle))),\t//Base height\n"];
					[ds copyTabAndText:@"min((-(1/tan(radians(Angle))) + min(Bevel_H, Height))+0.0001, 0),\t//Top Height\n"];
					[ds copyTabAndText:@"PTS()\n"];
					if ( [[dict objectForKey:@"objectPrismOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
					[ds copyTabAndText:@"scale < 1/(1/tan(radians(Angle))),1, 1/(1/tan(radians(Angle)))>\n"];
					[ds copyTabAndText:@"rotate y*180\n"];
					[ds copyTabAndText:@"translate y* (1/tan(radians(Angle)))\n"];
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];
					
					[ds copyTabAndText:@"prism {\n"];
					[ds addTab];
					switch([oMap buttonState:cSplineTypePopUp])
					{
						case cLinearSpline: 		[ds copyTabAndText:@"linear_spline\n"];			break;
						case cQuadraticSpline: 	[ds copyTabAndText:@"quadratic_spline\n"];	break;
						case cCubicSpline: 			[ds copyTabAndText:@"cubic_spline\n"];			break;
						case cBezierSpline: 		[ds copyTabAndText:@"bezier_spline\n"];			break;
					}			
					[ds copyTabAndText:@"conic_sweep\n"];
					[ds copyTabAndText:@"(1/tan(radians(Angle))),\t//Base height\n"];
					[ds copyTabAndText:@"max(((1/tan(radians(Angle))) + min(Bevel_H, Height)), 0), \t//Top Height\n"];
					[ds copyTabAndText:@"PTS()\n"];
					if ( [[dict objectForKey:@"objectPrismOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
					[ds copyTabAndText:@"scale < 1/(1/tan(radians(Angle))),1, 1/(1/tan(radians(Angle)))>\n"];
					[ds copyTabAndText:@"translate y* -(1/tan(radians(Angle)))\n"];
					if ( [[dict objectForKey:@"objectPrismSturmOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"sturm\n"];
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];

					[ds copyTabAndText:@"translate y* (Base+(Height - Bevel_H))\n"];

					[ds copyTabAndText:@"//texture bevel\n"];
				
					[ds removeTab];
					[ds copyTabAndText:@"}\n"];

					[ds copyTabAndText:@"//texture all\n"];
					kWriteHollow
					kWriteNoImage
				kWriteRadiosityImportance
					kWriteNoRadiosity
					kWriteNoShadow
					kWriteNoReflection
					WriteMaterialAndTrans(ds, dict, YES);
					kWriteDoubleIlluminate
				}
				else
				{
					BOOL doSpecialScale=NO;
					[ds copyTabAndText:@"prism {\n"];
					[ds addTab];
					switch([oMap buttonState:cSplineTypePopUp])
					{
						case cLinearSpline: 		[ds copyTabAndText:@"linear_spline\n"];			break;
						case cQuadraticSpline: 	[ds copyTabAndText:@"quadratic_spline\n"];	break;
						case cCubicSpline: 			[ds copyTabAndText:@"cubic_spline\n"];			break;
						case cBezierSpline: 		[ds copyTabAndText:@"bezier_spline\n"];			break;
					}			

					switch([[dict objectForKey:@"objectPrismSweepTypePopUp"]intValue])
					{
						case cPrismLinearSweep: 	[ds copyTabAndText:@"linear_sweep\n"];	doSpecialScale=NO;	break;
						case cPrismConicSweep: 	[ds copyTabAndText:@"conic_sweep\n"];	doSpecialScale=YES;	break;
					}			

					[ds appendTabAndFormat:@"%@,\t//Base height\n",[dict objectForKey:@"objectPrismBaseHeightEdit"]];
					[ds appendTabAndFormat:@"%@,\t//Top height\n",[dict objectForKey:@"objectPrismTopHeightEdit"]];

					[ds appendTabAndFormat:@"%d\n",[oMap count]];
				
					for ( int row=0; row <[oMap count]-1; row++)
					{
						[ds appendTabAndFormat:@"<%@, %@>,\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapXIndex],
																						[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapYIndex]];
					}
					[ds appendTabAndFormat:@"<%@, %@>\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapXIndex],
																			[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapYIndex]];


					if ( doSpecialScale==YES &&[[dict objectForKey:@"objectPrismKeepDimensionsOn"]intValue]==NSOnState)
					{
						switch([[dict objectForKey:@"objectPrismKeepDimensionsPopUp"]intValue])
						{
							case cPrismBase: 		
								[ds appendTabAndFormat:@"scale <1/%lf,1, 1/%lf>\n",
									([[dict objectForKey:@"objectPrismBaseHeightEdit"]floatValue] != 0.0 ? 
									fabs([[dict objectForKey:@"objectPrismBaseHeightEdit"]floatValue]) : 1.0) ,
									([[dict objectForKey:@"objectPrismBaseHeightEdit"]floatValue] != 0.0 ? 
									fabs([[dict objectForKey:@"objectPrismBaseHeightEdit"]floatValue]) : 1.0 )];
							break;
							case cPrismTop: 		
								[ds appendTabAndFormat:@"scale <1/%lf,1, 1/%lf>\n",
								([[dict objectForKey:@"objectPrismTopHeightEdit"]floatValue] != 0.0 ? 
									fabs([[dict objectForKey:@"objectPrismTopHeightEdit"]floatValue]): 1.0 ),
									([[dict objectForKey:@"objectPrismTopHeightEdit"]floatValue] != 0.0 ? 
									fabs([[dict objectForKey:@"objectPrismTopHeightEdit"]floatValue]) : 1.0 )];
								break;
						}
					}
					if ( [[dict objectForKey:@"objectPrismOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
					if ( [[dict objectForKey:@"objectPrismSturmOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"sturm\n"];
					kWriteHollow
					kWriteNoImage
				kWriteRadiosityImportance
					kWriteNoRadiosity
					kWriteNoShadow
					kWriteNoReflection
					WriteMaterialAndTrans(ds, dict, YES);
					kWriteDoubleIlluminate
				}
				break;
//cObjectSor
			case cObjectSor:
				objectEditorPrefs=[dict objectForKey:@"objectSor"];
				[BaseTemplate addMissingObjectsInPreferences:objectEditorPrefs forClass:[ObjectEditorTemplate class] andTemplateType:menuTagTemplateSor];
				
				if ( objectEditorPrefs!=nil)
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				else
				{
					objectEditorPrefs=[ObjectEditorTemplate createDefaults:menuTagTemplateSor];
					objectEditorPrefs=[objectEditorPrefs objectForKey:@"objectmap"];
				}
				if ( objectEditorPrefs==nil)	// should never happen
				{
					[dict release];
					return nil;		
				}
					oMap=[NSUnarchiver unarchiveObjectWithData:objectEditorPrefs];
					[ds copyTabAndText:@"sor {\n"];
					[ds addTab];
					[ds appendTabAndFormat:@"%d\n",[oMap count]];
					for ( int row=0; row <[oMap count]-1; row++)
					{
						[ds appendTabAndFormat:@"<%@, %@>,\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapXIndex],
																						[oMap stringFromFloatWithFormat:FloatFormat atRow:row atColumn:cObjectmapYIndex]];
					}
					[ds appendTabAndFormat:@"<%@, %@>\n",[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapXIndex],
																			[oMap stringFromFloatWithFormat:FloatFormat atRow:[oMap count]-1 atColumn:cObjectmapYIndex]];
					if ( [[dict objectForKey:@"objectSorOpenOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"open\n"];
					if ( [[dict objectForKey:@"objectSorSturmOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"sturm\n"];
					kWriteHollow
					kWriteNoImage
				kWriteRadiosityImportance
					kWriteNoRadiosity
					kWriteNoShadow
					kWriteNoReflection
					WriteMaterialAndTrans(ds, dict, YES);
					kWriteDoubleIlluminate
				break;
//cObjectSphere
			case cObjectSphere:
				[ds copyTabAndText:@"sphere {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@, %@>, %@\n",[dict objectForKey:@"objectSphereCenterMatrixX"],
																					[dict objectForKey:@"objectSphereCenterMatrixY"],
																					[dict objectForKey:@"objectSphereCenterMatrixZ"],
																					[dict objectForKey:@"objectSphereRadiusEdit"]];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectSpheresweep
			case cObjectSpheresweep:
				[ds copyTabAndText:@"sphere_sweep {\n"];
				[ds addTab];

				switch([[dict objectForKey:@"objectSpheresweepSplineTypePopUp"]intValue])
				{
					case cSpheresweepLinearSpline: 	[ds copyTabAndText:@"linear_spline,\n"];		break;
					case cSpheresweepb_spline: 	[ds copyTabAndText:@"b_spline,\n"];				break;
					case cSpheresweepCubicSpline: 	[ds copyTabAndText:@"cubic_spline,\n"];		break;
				}			

				[ds appendTabAndFormat:@"%@,\n",[dict objectForKey:@"objectSpheresweepEntriesEdit"]];

				for ( int counter=1; counter <=[[dict objectForKey:@"objectSpheresweepEntriesEdit"]intValue]; counter++)
				{
					[ds appendTabAndFormat:@"<0.0, %d, 0.0>, 0.5\n",counter];
				}
				
				if ( [[dict objectForKey:@"objectSpheresweepToleranceOn"]intValue]==NSOnState)
					[ds appendTabAndFormat:@"tolerance %@\n",[dict objectForKey:@"objectSpheresweepToleranceEdit"]];
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectSuperelipsoid
			case cObjectSuperelipsoid:
				[ds copyTabAndText:@"superellipsoid {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"<%@, %@>\n",[dict objectForKey:@"objectSuperellipsoidEastWestEdit"],
														[dict objectForKey:@"objectSuperellipsoidNorthSouthEdit"]];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectText
			case cObjectText:
				[ds copyTabAndText:@"text {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"ttf \"%@\"\n",[dict objectForKey:@"objectTextTTFFileNameEdit"]];
				[ds appendTabAndFormat:@"\"%@\"\n",[dict objectForKey:@"objectTextTextEdit"]];
				[ds appendTabAndFormat:@"%@\n",[dict objectForKey:@"objectTextThicknessEdit"]];
				[ds appendTabAndFormat:@"<%@, %@, %@>\n",[dict objectForKey:@"objectTextOffsetMatrixX"],
														[dict objectForKey:@"objectTextOffsetMatrixY"],
														[dict objectForKey:@"objectTextOffsetMatrixZ"]];

	/*			switch([[dict objectForKey:@"objectTextHorizontalAlignmentTypePopUp"]intValue])
				{
					default: break; //standard, don't write
					case cLeftAlignment: 		[ds copyTabAndText:@"h_align_left\n"];		break;
					case cCenterAlignment: 	[ds copyTabAndText:@"h_align_center\n"];	break;
					case cRightAlignment: 	[ds copyTabAndText:@"h_align_right\n"];		break;
				}			
*/
/*				switch([[dict objectForKey:@"objectTextVerticalAlignmentTypePopUp"]intValue])
				{
					default: break; //standard, don't write
					case cTopAlignment: 		[ds copyTabAndText:@"v_align_top\n"];		break;
					case cCenterAlignment: 	[ds copyTabAndText:@"v_align_center\n"];	break;
					case cBottomAlignment: 	[ds copyTabAndText:@"v_align_bottom\n"];	break;
				}			*/
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectTorus
			case cObjectTorus:
				[ds copyTabAndText:@"torus {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@, %@\n",[dict objectForKey:@"objectTorusMajorRadiusEdit"],
																			[dict objectForKey:@"objectTorusMinorRadiusEdit"]];

				if ( [[dict objectForKey:@"objectTorusSturmOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"sturm\r"];

				kWriteHollow
				kWriteNoImage
				kWriteNoShadow
				kWriteNoReflection
				kWriteUVMapping
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectOvus
			case cObjectOvus:
				[ds copyTabAndText:@"ovus {\n"];
				[ds addTab];
				[ds appendTabAndFormat:@"%@, %@\n",[dict objectForKey:@"objectOvusBottomRadiusEdit"],
																			[dict objectForKey:@"objectOvusTopRadiusEdit"]];

				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				kWriteUVMapping
				WriteMaterialAndTrans(ds, dict, YES);
				kWriteDoubleIlluminate
				break;
//cObjectTriangle
			case cObjectTriangle:

				int numberOfPoints=1;
				if ( [[dict objectForKey:@"objectTriangleWriteMeshTriangleOn"]intValue]==NSOnState)
				{
					[ds copyTabAndText:@"mesh {\n"];
					[ds addTab];
					numberOfPoints=[[dict objectForKey:@"objectTriangleWriteMeshEntriesEdit"]intValue];
				}

				for ( int counter=1; counter <=numberOfPoints; counter++)
				{
					if ( [[dict objectForKey:@"objectTriangleSmoothTriangleOn"]intValue]==NSOnState)
						[ds copyTabAndText:@"smooth_triangle {\n"];
					else
					[ds copyTabAndText:@"triangle {\n"];
					[ds addTab];

					[ds appendTabAndFormat:@"<%@, %@, %@>,",[dict objectForKey:@"objectTriangleCorner1MatrixX"],
																						[dict objectForKey:@"objectTriangleCorner1MatrixY"],
																						[dict objectForKey:@"objectTriangleCorner1MatrixZ"]];


					if ( [[dict objectForKey:@"objectTriangleSmoothTriangleOn"]intValue]==NSOnState)
					{
						[ds appendTabAndFormat:@" <%@, %@, %@>,",[dict objectForKey:@"objectTriangleNormal1MatrixX"],
																						[dict objectForKey:@"objectTriangleNormal1MatrixY"],
																						[dict objectForKey:@"objectTriangleNormal1MatrixZ"]];
					}
					[ds copyText:@"\n"];

					[ds appendTabAndFormat:@"<%@, %@, %@>,",[dict objectForKey:@"objectTriangleCorner2MatrixX"],
																						[dict objectForKey:@"objectTriangleCorner2MatrixY"],
																						[dict objectForKey:@"objectTriangleCorner2MatrixZ"]];


					if ( [[dict objectForKey:@"objectTriangleSmoothTriangleOn"]intValue]==NSOnState)
					{
						[ds appendTabAndFormat:@" <%@, %@, %@>,",[dict objectForKey:@"objectTriangleNormal2MatrixX"],
																						[dict objectForKey:@"objectTriangleNormal2MatrixY"],
																						[dict objectForKey:@"objectTriangleNormal2MatrixZ"]];
					}
					[ds copyText:@"\n"];

					[ds appendTabAndFormat:@"<%@, %@, %@>",[dict objectForKey:@"objectTriangleCorner3MatrixX"],
																						[dict objectForKey:@"objectTriangleCorner3MatrixY"],
																						[dict objectForKey:@"objectTriangleCorner3MatrixZ"]];


					if ( [[dict objectForKey:@"objectTriangleSmoothTriangleOn"]intValue]==NSOnState)
					{
						[ds appendTabAndFormat:@", <%@, %@, %@>",[dict objectForKey:@"objectTriangleNormal3MatrixX"],
																						[dict objectForKey:@"objectTriangleNormal3MatrixY"],
																						[dict objectForKey:@"objectTriangleNormal3MatrixZ"]];
					}
					[ds copyText:@"\n"];
					if ( counter<numberOfPoints || [[dict objectForKey:@"objectTriangleWriteMeshTriangleOn"]intValue]==NSOnState)
					{
						[ds removeTab];
						[ds copyTabAndText:@"}\n"];
					}
				}


				if ( [[dict objectForKey:@"objectTriangleWriteMeshTriangleOn"]intValue]==NSOnState)
				{
					if ( [[dict objectForKey:@"objectTriangleInsideVectorOn"]intValue]==NSOnState)
					{
						[ds copyTabAndText:@"inside_vector "];
						[ds addXYZVector:dict popup:@"objectTriangleInsideXYZVectorPopUp" xKey:@"objectTriangleInsideXYZVectorMatrixX" 
														yKey:@"objectTriangleInsideXYZVectorMatrixY" zKey:@"objectTriangleInsideXYZVectorMatrixZ"];
						[ds copyText:@"\n"];
					}
				}
				kWriteHollow
				kWriteNoImage
				kWriteRadiosityImportance
				kWriteNoRadiosity
				kWriteNoShadow
				kWriteNoReflection
				WriteMaterialAndTrans(ds, dict, YES);
				if ( [[dict objectForKey:@"objectTriangleWriteMeshTriangleOn"]intValue]==NSOnState)
				{
					if ( [[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
					{
						kWriteUVMapping
					}
				}
				kWriteDoubleIlluminate

				break;
		}		
		if ([[dict objectForKey:@"objectPhotonsGroupOn"]intValue]==NSOnState)
		{
			[PhotonsTemplate createDescriptionWithDictionary:[dict objectForKey:@"objectPhotons"]
				andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
		}	

	[ds removeTab];
	[ds copyTabAndText:@"}\n"];
	switch ( [[dict objectForKey:@"objectTypePopUp"]intValue])
	{
		case cObjectIsosurface:
			if ( [[dict objectForKey:@"objectIsoShowContainerObjectOn"]intValue]==NSOnState)
			{
				WriteShowContainingObject(ds, dict, @"objectIsoContainerObjectPopUp",
								@"objectIsoContainerBoxCorner1MatrixX", @"objectIsoContainerBoxCorner1MatrixY", @"objectIsoContainerBoxCorner1MatrixZ",
								@"objectIsoContainerBoxCorner2MatrixX", @"objectIsoContainerBoxCorner2MatrixY", @"objectIsoContainerBoxCorner2MatrixZ",
								@"objectIsoContainerSphereCenterMatrixX", @"objectIsoContainerSphereCenterMatrixY", @"objectIsoContainerSphereCenterMatrixZ",
								@"objectIsoContainerSphereRadiusEdit");
			}
				break;
		case cObjectParametric:
			if ( [[dict objectForKey:@"objectParametricShowContainerObjectOn"]intValue]==NSOnState)
			{
				WriteShowContainingObject(ds, dict, @"objectParametricContainerObjectPopUp",
								@"objectParametricContainerBoxCorner1MatrixX", @"objectParametricContainerBoxCorner1MatrixY", @"objectParametricContainerBoxCorner1MatrixZ",
								@"objectParametricContainerBoxCorner2MatrixX", @"objectParametricContainerBoxCorner2MatrixY", @"objectParametricContainerBoxCorner2MatrixZ",
								@"objectParametricContainerSphereCenterMatrixX", @"objectParametricContainerSphereCenterMatrixY", @"objectParametricContainerSphereCenterMatrixZ",
								@"objectParametricContainerSphereRadiusEdit");
			}

				break;
	}
//	[ds autorelease];
	[dict release];
	return ds;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	if ( mPolyArray != nil)
	{
		[mPolyArray release];
		mPolyArray=nil;
	}
	[super dealloc];
}

//---------------------------------------------------------------------
// initialize
//---------------------------------------------------------------------
+(void) initialize
{
	NSDictionary *initialDefaults=[ObjectTemplate createDefaults:menuTagTemplateObject];


	NSDictionary *factoryDefaults=[NSDictionary dictionaryWithObjectsAndKeys:
		initialDefaults,@"objectDefaultSettings",
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
		[NSNumber numberWithInt:cObjectBicubicPatch],						@"objectTypePopUp",
		
		[NSNumber numberWithInt:NSOffState],		@"objectMaterialGroupOn",
		[NSNumber numberWithInt:NSOffState],		@"objectTransformationGroupOn",
		[NSNumber numberWithInt:NSOnState],			@"objectIgnoreMaterialOn",
		[NSNumber numberWithInt:NSOffState],		@"objectPhotonsGroupOn",
		[NSNumber numberWithInt:NSOffState],		@"objectUvMappingOn",
		[NSNumber numberWithInt:NSOffState],		@"objectDoubleIlluminateOn",
		[NSNumber numberWithInt:NSOffState],		@"objectHollowOn",
		[NSNumber numberWithInt:NSOffState],		@"objectNoImageOn",
		[NSNumber numberWithInt:NSOffState],		@"objectNoReflectionOn",
		[NSNumber numberWithInt:NSOffState],		@"objectNoShadowOn",
		[NSNumber numberWithInt:NSOffState],		@"objectNoRadiosityOn",
		[NSNumber numberWithInt:NSOffState],		@"objectRadiosityImportanceOn",
		@"1.0",																	@"objectRadiosityImportanceEdit",

		//bicubic patch
		[NSNumber numberWithInt:0],							@"objectBicubicPatchTypePopUp",
		@"0.0",																	@"objectBicubicPatchFlatnessEdit",
		@"3",																		@"objectBicubicPatchUStepsEdit",
		@"3",																		@"objectBicubicPatchVStepsEdit",

		@"-0.5",																@"objectBicubicPatchCorner1MatrixX",
		@"-0.5",																@"objectBicubicPatchCorner1MatrixY",
		@"-0.5",																@"objectBicubicPatchCorner1MatrixZ",

		@"0.5",																	@"objectBicubicPatchCorner2MatrixX",
		@"0.5",																	@"objectBicubicPatchCorner2MatrixY",
		@"0.5",																	@"objectBicubicPatchCorner2MatrixZ",
		//blob
		[NSNumber numberWithInt:NSOffState],		@"objectBlobSphericalOn",
		@"2",																		@"objectBlobSphericalNumberOfComponentsEdit",
		@"0.5",																	@"objectBlobSphericalRadiusEdit",
		@"2",																		@"objectBlobSphericalStrengthEdit",
		[NSNumber numberWithInt:NSOnState],			@"objectBlobSphericalTextureOn",
		[NSNumber numberWithInt:NSOffState],		@"objectBlobCylindricalOn",
		@"2",																		@"objectBlobCylindricalNumberOfComponentsEdit",
		@"0.5",																	@"objectBlobCylindricalRadiusEdit",
		@"2",																		@"objectBlobCylindricalStrengthEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectBlobCylindricalTextureOn",
		@"0.0",																	@"objectBlobCylindricalEnd1MatrixX",
		@"-0.5",																@"objectBlobCylindricalEnd1MatrixY",
		@"0.0",																	@"objectBlobCylindricalEnd1MatrixZ",
		@"0.0",																	@"objectBlobCylindricalEnd2MatrixX",
		@"0.5",																	@"objectBlobCylindricalEnd2MatrixY",
		@"0.0",																	@"objectBlobCylindricalEnd2MatrixZ",
		@"1",																		@"objectBlobThresholdEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectBlobSturm",
//box		
		@"-0.5",																@"objectBoxCorner1MatrixX",
		@"-0.5",																@"objectBoxCorner1MatrixY",
		@"-0.5",																@"objectBoxCorner1MatrixZ",
		@"0.5",																	@"objectBoxCorner2MatrixX",
		@"0.5",																	@"objectBoxCorner2MatrixY",
		@"0.5",																	@"objectBoxCorner2MatrixZ",
//cone		
		[NSNumber numberWithInt:NSOffState],		@"objectConeOpenOn",
		@"0.0",																	@"objectConeBaseMatrixX",
		@"-0.5",																@"objectConeBaseMatrixY",
		@"0.0",																	@"objectConeBaseMatrixZ",
		@"0.0",																	@"objectConeCapMatrixX",
		@"0.5",																	@"objectConeCapMatrixY",
		@"0.0",																	@"objectConeCapMatrixZ",
		@"0.5",																	@"objectConeBaseRadiusEdit",
		@"0.0",																	@"objectConeCapRadiusEdit",
//cylinder		
		[NSNumber numberWithInt:NSOffState],		@"objectCylinderOpenOn",
		@"0.0",																	@"objectCylinderBaseMatrixX",
		@"-0.5",																@"objectCylinderBaseMatrixY",
		@"0.0",																	@"objectCylinderBaseMatrixZ",
		@"0.0",																	@"objectCylinderCapMatrixX",
		@"0.5",																	@"objectCylinderCapMatrixY",
		@"0.0",																	@"objectCylinderCapMatrixZ",
		@"0.0",																	@"objectCylinderCapRadiusEdit",
																			
//disc		
		@"0.0",																	@"objectDiscCenterMatrixX",
		@"0.0",																	@"objectDiscCenterMatrixY",
		@"0.0",																	@"objectDiscCenterMatrixZ",
		@"0.0",																	@"objectDiscNormalMatrixX",
		@"1.0",																	@"objectDiscNormalMatrixY",
		@"0.0",																	@"objectDiscNormalMatrixZ",
		@"0.5",																	@"objectDiscRadiusEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectDiscHoleRadiusOn",
		@"0.2",																	@"objectDiscHoleRadiusEdit",
//height field
		[NSNumber numberWithInt:cGif],					@"objectHeightFieldFileTypePopUp",
		@"MyFile",															@"objectHeightFieldFileName",
		@"x+y+z",																@"objectHeightFieldFunctionEdit",
		@"300",																	@"objectHeightFieldFunctionImageWidth",
		@"300",																	@"objectHeightFieldFunctionImageHeight",
		[NSNumber numberWithInt:NSOffState],		@"objectHeightFieldWaterLevelOn",
		@"0.0",																	@"objectHeightFieldWaterLevelEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectHeightFieldSmoothOn",
		[NSNumber numberWithInt:NSOffState],		@"objectHeightFieldHierarchyOn",
//isosurface
		@"x+y+z",																@"objectIsoFunctionEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectIsoMaxGradientGroupOn",
		[NSNumber numberWithInt:cFirstCell],		@"objectIsoMaxGradientMatrix",
		@"5.0",																	@"objectIsoMaxGradientEdit",
		@"0.0",																	@"objectIsoEvaluateEditX",
		@"0.0",																	@"objectIsoEvaluateEditY",
		@"0.0",																	@"objectIsoEvaluateEditZ",
		[NSNumber numberWithInt:NSOffState],		@"objectIsoMessageOn",
		[NSNumber numberWithInt:cSecondCell],		@"objectIsoMessageMatrix",

		[NSNumber numberWithInt:NSOnState],			@"objectIsoThresholdOn",
		@"0.0",																	@"objectIsoThresholdEdit",
		[NSNumber numberWithInt:NSOnState],			@"objectIsoAccuracyOn",
		@"0.001",																@"objectIsoAccuracyEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectIsoMaxTraceOn",
		[NSNumber numberWithInt:cSecondCell],		@"objectIsoMaxTraceMatrix",
		@"0",																		@"objectIsoMaxTraceEdit",
		[NSNumber numberWithInt:cBoxContainer],	@"objectIsoContainerObjectPopUp",
		[NSNumber numberWithInt:NSOffState],		@"objectIsoShowContainerObjectOn",
		@"0.0",																	@"objectIsoContainerBoxCorner1MatrixX",
		@"0.0",																	@"objectIsoContainerBoxCorner1MatrixY",
		@"0.0",																	@"objectIsoContainerBoxCorner1MatrixZ",
		@"0.0",																	@"objectIsoContainerBoxCorner2MatrixX",
		@"0.0",																	@"objectIsoContainerBoxCorner2MatrixY",
		@"0.0",																	@"objectIsoContainerBoxCorner2MatrixZ",
		@"0.0",																	@"objectIsoContainerSphereCenterMatrixX",
		@"0.0",																	@"objectIsoContainerSphereCenterMatrixY",
		@"0.0",																	@"objectIsoContainerSphereCenterMatrixZ",
		@"0.0",																	@"objectIsoContainerSphereRadiusEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectIsoOpenOn",
//fractal
		@"1.0",																	@"objectFractal4DjuliaParameterMatrixX",
		@"0.0",																	@"objectFractal4DjuliaParameterMatrixY",
		@"0.0",																	@"objectFractal4DjuliaParameterMatrixZ",
		@"0.0",																	@"objectFractal4DjuliaParameterMatrix4",
		[NSNumber numberWithInt:cQuaternation],	@"objectFractal4DAlgebraPopUp",
		[NSNumber numberWithInt:cSqrt],					@"objectFractalFunctionPopUp",
		@"5",																		@"objectFractalMaxIterationEdit",
		@"15",																	@"objectFractalPrecisionEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectFractalSliceOn",
		@"0.0",																	@"objectFractal4DNormalMatrixX",
		@"0.0",																	@"objectFractal4DNormalMatrixY",
		@"0.0",																	@"objectFractal4DNormalMatrixZ",
		@"1.0",																	@"objectFractal4DNormalMatrix4",
		@"0.0",																	@"objectFractalDistanceEdit",
//lathe																			
		[NSNumber numberWithInt:NSOffState],		@"objectLatheSturmOn",
//Parametric
		@"x+y+z",																@"objectParametricFunctionXEdit",
		@"x+y+z",																@"objectParametricFunctionYEdit",
		@"x+y+z",																@"objectParametricFunctionZEdit",
		@"0.0",																	@"objectParametricBounderiesUMatrixX",
		@"0.0",																	@"objectParametricBounderiesUMatrixY",
		@"0.0",																	@"objectParametricBounderiesVMatrixX",
		@"0.0",																	@"objectParametricBounderiesVMatrixY",
		[NSNumber numberWithInt:NSOnState],			@"objectParametricMaxGradientOn",
		@"5.0",																	@"objectParametricMaxGradientEdit",
		[NSNumber numberWithInt:NSOnState],			@"objectParametricAccuracyOn",
		@"0.0",																	@"objectParametricAccuracyEdit",
		[NSNumber numberWithInt:NSOnState],			@"objectParametricPrecomputeDepthsOn",
		@"0.0",																	@"objectParametricPrecomputeDepthsEdit",
		[NSNumber numberWithInt:NSOffState],		@"objectParametricOfVariablesXOn",
		[NSNumber numberWithInt:NSOffState],		@"objectParametricOfVariablesYOn",
		[NSNumber numberWithInt:NSOnState],			@"objectParametricOfVariablesZOn",
		[NSNumber numberWithInt:cBoxContainer],	@"objectParametricContainerObjectPopUp",
		[NSNumber numberWithInt:NSOffState],		@"objectParametricShowContainerObjectOn",
		@"0.0",																	@"objectParametricContainerBoxCorner1MatrixX",
		@"0.0",																	@"objectParametricContainerBoxCorner1MatrixY",
		@"0.0",																	@"objectParametricContainerBoxCorner1MatrixZ",
		@"0.0",																	@"objectParametricContainerBoxCorner2MatrixX",
		@"0.0",																	@"objectParametricContainerBoxCorner2MatrixY",
		@"0.0",																	@"objectParametricContainerBoxCorner2MatrixZ",
		@"0.0",																	@"objectParametricContainerSphereCenterMatrixX",
		@"0.0",																	@"objectParametricContainerSphereCenterMatrixY",
		@"0.0",																	@"objectParametricContainerSphereCenterMatrixZ",
		@"0.0",																	@"objectParametricContainerSphereRadiusEdit",
//plane
		[NSNumber numberWithInt:cXYZVectorPopupX],		@"objectPlaneNormalXYZPopUp",
		@"0.0",																	@"objectPlaneNormalMatrixX",
		@"1.0",																	@"objectPlaneNormalMatrixY",
		@"0.0",																	@"objectPlaneNormalMatrixZ",
		@"0.0",																	@"objectPlaneDistanceEdit",
//poly
		[NSNumber numberWithInt:cCubicPoly],		@"objectPolyPolyTypePopUp",
		[NSNumber numberWithInt:NSOffState],		@"objectPolySturmOn",

//prism
		[NSNumber numberWithInt:cPrismLinearSweep],		@"objectPrismSweepTypePopUp",
		[NSNumber numberWithInt:NSOffState],					@"objectPrismKeepDimensionsOn",
		[NSNumber numberWithInt:cPrismBase],					@"objectPrismKeepDimensionsPopUp",
		@"1.0",																				@"objectPrismTopHeightEdit",
		@"0.0",																				@"objectPrismBaseHeightEdit",
		[NSNumber numberWithInt:NSOffState],					@"objectPrismBevelPrismGroupOn",
		@"10",																				@"objectPrismBevelPrismFractionHeightEdit",
		@"45",																				@"objectPrismBevelPrismFractionAngleEdit",
		[NSNumber numberWithInt:NSOffState],					@"objectPrismOpenOn",
		[NSNumber numberWithInt:NSOnState],						@"objectPrismSturmOn",
//sor
		[NSNumber numberWithInt:NSOffState],					@"objectSorOpenOn",
		[NSNumber numberWithInt:NSOnState],						@"objectSorSturmOn",
//sphere
		@"0.0",																				@"objectSphereCenterMatrixX",
		@"0.0",																				@"objectSphereCenterMatrixY",
		@"0.0",																				@"objectSphereCenterMatrixZ",
		@"0.5",																				@"objectSphereRadiusEdit",
//sphereSweep
		@"4",																					@"objectSpheresweepEntriesEdit",
		[NSNumber numberWithInt:cSpheresweepLinearSpline],	@"objectSpheresweepSplineTypePopUp",
		[NSNumber numberWithInt:NSOnState],						@"objectSpheresweepToleranceOn",
		@"1.0e-6",																		@"objectSpheresweepToleranceEdit",
//Superellipsoid
		@"0.5",																			@"objectSuperellipsoidEastWestEdit",
		@"0.5",																			@"objectSuperellipsoidNorthSouthEdit",
//text
		@"Geneva.ttf",															@"objectTextTTFFileNameEdit",
		@"MegaPOV",																	@"objectTextTextEdit",
		@"0.3",																			@"objectTextThicknessEdit",
		@"0.0",																			@"objectTextOffsetMatrixX",
		@"0.0",																			@"objectTextOffsetMatrixY",
		@"0.0",																			@"objectTextOffsetMatrixZ",
		[NSNumber numberWithInt:cDefaultAlignment],	@"objectTextHorizontalAlignmentTypePopUp",
		[NSNumber numberWithInt:cDefaultAlignment],	@"objectTextVerticalAlignmentTypePopUp",
//ovus
		@"0.33",																		@"objectOvusBottomRadiusEdit",
		@"0.083",																		@"objectOvusTopRadiusEdit",
//torus
		@"0.33",																		@"objectTorusMajorRadiusEdit",
		@"0.083",																		@"objectTorusMinorRadiusEdit",
		[NSNumber numberWithInt:NSOnState],					@"objectTorusSturmOn",
//triangle
		@"0.0",																		@"objectTriangleCorner1MatrixX",
		@"0.0",																		@"objectTriangleCorner1MatrixY",
		@"-0.5",																	@"objectTriangleCorner1MatrixZ",
		@"0.0",																		@"objectTriangleCorner2MatrixX",
		@"0.0",																		@"objectTriangleCorner2MatrixY",
		@"-0.5",																	@"objectTriangleCorner2MatrixZ",
		@"0.0",																		@"objectTriangleCorner3MatrixX",
		@"0.0",																		@"objectTriangleCorner3MatrixY",
		@"-0.5",																	@"objectTriangleCorner3MatrixZ",
		@"0.0",																		@"objectTriangleNormal1MatrixX",
		@"0.0",																		@"objectTriangleNormal1MatrixY",
		@"-0.5",																	@"objectTriangleNormal1MatrixZ",
		@"0.0",																		@"objectTriangleNormal2MatrixX",
		@"0.0",																		@"objectTriangleNormal2MatrixY",
		@"-0.5",																	@"objectTriangleNormal2MatrixZ",
		@"0.0",																		@"objectTriangleNormal3MatrixX",
		@"0.0",																		@"objectTriangleNormal3MatrixY",
		@"-0.5",																	@"objectTriangleNormal3MatrixZ",
		[NSNumber numberWithInt:NSOffState],			@"objectTriangleSmoothTriangleOn",
		[NSNumber numberWithInt:NSOnState],				@"objectTriangleWriteMeshTriangleOn",
		@"2",																			@"objectTriangleWriteMeshEntriesEdit",
		[NSNumber numberWithInt:NSOnState],				@"objectTriangleInsideVectorOn",
		[NSNumber numberWithInt:cXYZVectorPopupXisYisZ],	@"objectTriangleInsideXYZVectorPopUp",
		@"0.0",																		@"objectTriangleInsideXYZVectorMatrixX",
		@"0.0",																		@"objectTriangleInsideXYZVectorMatrixY",
		@"-1.0",																	@"objectTriangleInsideXYZVectorMatrixZ",

	nil];
	return initialDefaults;
}

//---------------------------------------------------------------------
// awakeFromNib
//---------------------------------------------------------------------
-(void) awakeFromNib
{
	[super awakeFromNib];

	[objectFractalFunctionPopUp setAutoenablesItems:NO];
	mOutlets =[NSDictionary dictionaryWithObjectsAndKeys:
		objectTypePopUp,																	@"objectTypePopUp",
		objectMaterialGroupOn,														@"objectMaterialGroupOn",
		objectTransformationGroupOn,											@"objectTransformationGroupOn",
		objectIgnoreMaterialOn,														@"objectIgnoreMaterialOn",
		objectPhotonsGroupOn,															@"objectPhotonsGroupOn",
		objectUvMappingOn,																@"objectUvMappingOn",
		objectDoubleIlluminateOn,													@"objectDoubleIlluminateOn",
		objectHollowOn,																		@"objectHollowOn",
		objectNoImageOn,																	@"objectNoImageOn",
		objectNoReflectionOn,															@"objectNoReflectionOn",
		objectNoShadowOn,																	@"objectNoShadowOn",
		objectNoRadiosityOn,															@"objectNoRadiosityOn",
		objectRadiosityImportanceOn,											@"objectRadiosityImportanceOn",
		objectRadiosityImportanceEdit,										@"objectRadiosityImportanceEdit",

		objectBicubicPatchTypePopUp,											@"objectBicubicPatchTypePopUp",
		objectBicubicPatchFlatnessEdit,										@"objectBicubicPatchFlatnessEdit",
		objectBicubicPatchUStepsEdit,											@"objectBicubicPatchUStepsEdit",
		objectBicubicPatchVStepsEdit,											@"objectBicubicPatchVStepsEdit",
		[objectBicubicPatchCorner1Matrix cellWithTag:0],	@"objectBicubicPatchCorner1MatrixX",
		[objectBicubicPatchCorner1Matrix cellWithTag:1],	@"objectBicubicPatchCorner1MatrixY",
		[objectBicubicPatchCorner1Matrix cellWithTag:2],	@"objectBicubicPatchCorner1MatrixZ",
		[objectBicubicPatchCorner2Matrix cellWithTag:0],	@"objectBicubicPatchCorner2MatrixX",
		[objectBicubicPatchCorner2Matrix cellWithTag:1],	@"objectBicubicPatchCorner2MatrixY",
		[objectBicubicPatchCorner2Matrix cellWithTag:2],	@"objectBicubicPatchCorner2MatrixZ",
			//blob
		objectBlobSphericalOn,														@"objectBlobSphericalOn",
		objectBlobSphericalNumberOfComponentsEdit,				@"objectBlobSphericalNumberOfComponentsEdit",
		objectBlobSphericalRadiusEdit,										@"objectBlobSphericalRadiusEdit",
		objectBlobSphericalStrengthEdit,									@"objectBlobSphericalStrengthEdit",
		objectBlobSphericalTextureOn,											@"objectBlobSphericalTextureOn",
		objectBlobCylindricalOn,													@"objectBlobCylindricalOn",
		objectBlobCylindricalNumberOfComponentsEdit,			@"objectBlobCylindricalNumberOfComponentsEdit",
		objectBlobCylindricalRadiusEdit,									@"objectBlobCylindricalRadiusEdit",
		objectBlobCylindricalStrengthEdit,								@"objectBlobCylindricalStrengthEdit",
		objectBlobCylindricalTextureOn,										@"objectBlobCylindricalTextureOn",
		[objectBlobCylindricalEnd1Matrix cellWithTag:0],	@"objectBlobCylindricalEnd1MatrixX",
		[objectBlobCylindricalEnd1Matrix cellWithTag:1],	@"objectBlobCylindricalEnd1MatrixY",
		[objectBlobCylindricalEnd1Matrix cellWithTag:2],	@"objectBlobCylindricalEnd1MatrixZ",
		[objectBlobCylindricalEnd2Matrix cellWithTag:0],	@"objectBlobCylindricalEnd2MatrixX",
		[objectBlobCylindricalEnd2Matrix cellWithTag:1],	@"objectBlobCylindricalEnd2MatrixY",
		[objectBlobCylindricalEnd2Matrix cellWithTag:2],	@"objectBlobCylindricalEnd2MatrixZ",
		objectBlobThresholdEdit,													@"objectBlobThresholdEdit",
		objectBlobSturm,																	@"objectBlobSturm",
	//box		
		[objectBoxCorner1Matrix cellWithTag:0],						@"objectBoxCorner1MatrixX",
		[objectBoxCorner1Matrix cellWithTag:1],						@"objectBoxCorner1MatrixY",
		[objectBoxCorner1Matrix cellWithTag:2],						@"objectBoxCorner1MatrixZ",
		[objectBoxCorner2Matrix cellWithTag:0],						@"objectBoxCorner2MatrixX",
		[objectBoxCorner2Matrix cellWithTag:1],						@"objectBoxCorner2MatrixY",
		[objectBoxCorner2Matrix cellWithTag:2],						@"objectBoxCorner2MatrixZ",
	//cone		
		objectConeOpenOn,																	@"objectConeOpenOn",
		[objectConeBaseMatrix cellWithTag:0],							@"objectConeBaseMatrixX",
		[objectConeBaseMatrix cellWithTag:1],							@"objectConeBaseMatrixY",
		[objectConeBaseMatrix cellWithTag:2],							@"objectConeBaseMatrixZ",
		[objectConeCapMatrix cellWithTag:0],							@"objectConeCapMatrixX",
		[objectConeCapMatrix cellWithTag:1],							@"objectConeCapMatrixY",
		[objectConeCapMatrix cellWithTag:2],							@"objectConeCapMatrixZ",
		objectConeBaseRadiusEdit,													@"objectConeBaseRadiusEdit",
		objectConeCapRadiusEdit,													@"objectConeCapRadiusEdit",
	//Cylinder		
		objectCylinderOpenOn,															@"objectCylinderOpenOn",
		[objectCylinderBaseMatrix cellWithTag:0],					@"objectCylinderBaseMatrixX",
		[objectCylinderBaseMatrix cellWithTag:1],					@"objectCylinderBaseMatrixY",
		[objectCylinderBaseMatrix cellWithTag:2],					@"objectCylinderBaseMatrixZ",
		[objectCylinderCapMatrix cellWithTag:0],					@"objectCylinderCapMatrixX",
		[objectCylinderCapMatrix cellWithTag:1],					@"objectCylinderCapMatrixY",
		[objectCylinderCapMatrix cellWithTag:2],					@"objectCylinderCapMatrixZ",
		objectCylinderCapRadiusEdit,											@"objectCylinderCapRadiusEdit",
	//disc		
		[objectDiscCenterMatrix cellWithTag:0],						@"objectDiscCenterMatrixX",
		[objectDiscCenterMatrix cellWithTag:1],						@"objectDiscCenterMatrixY",
		[objectDiscCenterMatrix cellWithTag:2],						@"objectDiscCenterMatrixZ",
		[objectDiscNormalMatrix cellWithTag:0],						@"objectDiscNormalMatrixX",
		[objectDiscNormalMatrix cellWithTag:1],						@"objectDiscNormalMatrixY",
		[objectDiscNormalMatrix cellWithTag:2],						@"objectDiscNormalMatrixZ",
		objectDiscRadiusEdit,															@"objectDiscRadiusEdit",
		objectDiscHoleRadiusOn,														@"objectDiscHoleRadiusOn",
		objectDiscHoleRadiusEdit,													@"objectDiscHoleRadiusEdit",
	//height field
		objectHeightFieldFileTypePopUp,										@"objectHeightFieldFileTypePopUp",
		objectHeightFieldFileName,												@"objectHeightFieldFileName",
		objectHeightFieldFunctionEdit,										@"objectHeightFieldFunctionEdit",
		objectHeightFieldFunctionImageWidth,							@"objectHeightFieldFunctionImageWidth",
		objectHeightFieldFunctionImageHeight,							@"objectHeightFieldFunctionImageHeight",
		objectHeightFieldWaterLevelOn,										@"objectHeightFieldWaterLevelOn",
		objectHeightFieldWaterLevelEdit,									@"objectHeightFieldWaterLevelEdit",
		objectHeightFieldSmoothOn,												@"objectHeightFieldSmoothOn",
		objectHeightFieldHierarchyOn,											@"objectHeightFieldHierarchyOn",
	//isosurface
		objectIsoFunctionEdit,														@"objectIsoFunctionEdit",
		objectIsoMaxGradientMatrix,												@"objectIsoMaxGradientMatrix",
		objectIsoMaxGradientEdit,													@"objectIsoMaxGradientEdit",
		objectIsoMaxGradientGroupOn,											@"objectIsoMaxGradientGroupOn",
		objectIsoEvaluateEditX,														@"objectIsoEvaluateEditX",
		objectIsoEvaluateEditY,														@"objectIsoEvaluateEditY",
		objectIsoEvaluateEditZ,														@"objectIsoEvaluateEditZ",
		objectIsoMessageOn,																@"objectIsoMessageOn",
		objectIsoMessageMatrix,														@"objectIsoMessageMatrix",
		
		
		
		objectIsoThresholdOn,																@"objectIsoThresholdOn",
		objectIsoThresholdEdit,															@"objectIsoThresholdEdit",
		objectIsoAccuracyOn,																@"objectIsoAccuracyOn",
		objectIsoAccuracyEdit,															@"objectIsoAccuracyEdit",
		objectIsoMaxTraceOn,																@"objectIsoMaxTraceOn",
		objectIsoMaxTraceMatrix,														@"objectIsoMaxTraceMatrix",
		objectIsoMaxTraceEdit,															@"objectIsoMaxTraceEdit",
		objectIsoContainerObjectPopUp,											@"objectIsoContainerObjectPopUp",
		objectIsoShowContainerObjectOn,											@"objectIsoShowContainerObjectOn",
		[objectIsoContainerBoxCorner1Matrix cellWithTag:0],	@"objectIsoContainerBoxCorner1MatrixX",
		[objectIsoContainerBoxCorner1Matrix cellWithTag:1],	@"objectIsoContainerBoxCorner1MatrixY",
		[objectIsoContainerBoxCorner1Matrix cellWithTag:2],	@"objectIsoContainerBoxCorner1MatrixZ",
		[objectIsoContainerBoxCorner2Matrix cellWithTag:0],	@"objectIsoContainerBoxCorner2MatrixX",
		[objectIsoContainerBoxCorner2Matrix cellWithTag:1],	@"objectIsoContainerBoxCorner2MatrixY",
		[objectIsoContainerBoxCorner2Matrix cellWithTag:2],	@"objectIsoContainerBoxCorner2MatrixZ",
		[objectIsoContainerSphereCenterMatrix cellWithTag:0],	@"objectIsoContainerSphereCenterMatrixX",
		[objectIsoContainerSphereCenterMatrix cellWithTag:1],	@"objectIsoContainerSphereCenterMatrixY",
		[objectIsoContainerSphereCenterMatrix cellWithTag:2],	@"objectIsoContainerSphereCenterMatrixZ",
		objectIsoContainerSphereRadiusEdit,										@"objectIsoContainerSphereRadiusEdit",
		objectIsoOpenOn,																			@"objectIsoOpenOn",
	//fractal
		[objectFractal4DjuliaParameterMatrix cellWithTag:0],	@"objectFractal4DjuliaParameterMatrixX",
		[objectFractal4DjuliaParameterMatrix cellWithTag:1],	@"objectFractal4DjuliaParameterMatrixY",
		[objectFractal4DjuliaParameterMatrix cellWithTag:2],	@"objectFractal4DjuliaParameterMatrixZ",
		[objectFractal4DjuliaParameterMatrix cellWithTag:3],	@"objectFractal4DjuliaParameterMatrix4",
		objectFractal4DAlgebraPopUp,													@"objectFractal4DAlgebraPopUp",
		objectFractalFunctionPopUp,														@"objectFractalFunctionPopUp",
		objectFractalMaxIterationEdit,												@"objectFractalMaxIterationEdit",
		objectFractalPrecisionEdit,														@"objectFractalPrecisionEdit",
		objectFractalSliceOn,																	@"objectFractalSliceOn",
		[objectFractal4DNormalMatrix cellWithTag:0],					@"objectFractal4DNormalMatrixX",
		[objectFractal4DNormalMatrix cellWithTag:1],					@"objectFractal4DNormalMatrixY",
		[objectFractal4DNormalMatrix cellWithTag:2],					@"objectFractal4DNormalMatrixZ",
		[objectFractal4DNormalMatrix cellWithTag:3],					@"objectFractal4DNormalMatrix4",
		objectFractalDistanceEdit,														@"objectFractalDistanceEdit",
	//lathe
		objectLatheSturmOn,																		@"objectLatheSturmOn",
	//Parametric
		objectParametricFunctionXEdit,												@"objectParametricFunctionXEdit",
		objectParametricFunctionYEdit,												@"objectParametricFunctionYEdit",
		objectParametricFunctionZEdit,												@"objectParametricFunctionZEdit",
		[objectParametricBounderiesUMatrix cellWithTag:0],		@"objectParametricBounderiesUMatrixX",
		[objectParametricBounderiesUMatrix cellWithTag:1],		@"objectParametricBounderiesUMatrixY",
		[objectParametricBounderiesVMatrix cellWithTag:0],		@"objectParametricBounderiesVMatrixX",
		[objectParametricBounderiesVMatrix cellWithTag:1],		@"objectParametricBounderiesVMatrixY",
		objectParametricMaxGradientOn,												@"objectParametricMaxGradientOn",
		objectParametricMaxGradientEdit,											@"objectParametricMaxGradientEdit",
		objectParametricAccuracyOn,														@"objectParametricAccuracyOn",
		objectParametricAccuracyEdit,													@"objectParametricAccuracyEdit",
		objectParametricPrecomputeDepthsOn,										@"objectParametricPrecomputeDepthsOn",
		objectParametricPrecomputeDepthsEdit,									@"objectParametricPrecomputeDepthsEdit",
		objectParametricOfVariablesXOn,												@"objectParametricOfVariablesXOn",
		objectParametricOfVariablesYOn,												@"objectParametricOfVariablesYOn",
		objectParametricOfVariablesZOn,												@"objectParametricOfVariablesZOn",
		objectParametricContainerObjectPopUp,									@"objectParametricContainerObjectPopUp",
		objectParametricShowContainerObjectOn,								@"objectParametricShowContainerObjectOn",
		[objectParametricContainerBoxCorner1Matrix cellWithTag:0],		@"objectParametricContainerBoxCorner1MatrixX",
		[objectParametricContainerBoxCorner1Matrix cellWithTag:1],		@"objectParametricContainerBoxCorner1MatrixY",
		[objectParametricContainerBoxCorner1Matrix cellWithTag:2],		@"objectParametricContainerBoxCorner1MatrixZ",
		[objectParametricContainerBoxCorner2Matrix cellWithTag:0],		@"objectParametricContainerBoxCorner2MatrixX",
		[objectParametricContainerBoxCorner2Matrix cellWithTag:1],		@"objectParametricContainerBoxCorner2MatrixY",
		[objectParametricContainerBoxCorner2Matrix cellWithTag:2],		@"objectParametricContainerBoxCorner2MatrixZ",
		[objectParametricContainerSphereCenterMatrix cellWithTag:0],	@"objectParametricContainerSphereCenterMatrixX",
		[objectParametricContainerSphereCenterMatrix cellWithTag:1],	@"objectParametricContainerSphereCenterMatrixY",
		[objectParametricContainerSphereCenterMatrix cellWithTag:2],	@"objectParametricContainerSphereCenterMatrixZ",
		objectParametricContainerSphereRadiusEdit,							@"objectParametricContainerSphereRadiusEdit",
	//plane
		objectPlaneNormalXYZPopUp,										@"objectPlaneNormalXYZPopUp",
		[objectPlaneNormalMatrix cellWithTag:0],			@"objectPlaneNormalMatrixX",
		[objectPlaneNormalMatrix cellWithTag:1],			@"objectPlaneNormalMatrixY",
		[objectPlaneNormalMatrix cellWithTag:2],			@"objectPlaneNormalMatrixZ",
		objectPlaneDistanceEdit,											@"objectPlaneDistanceEdit",
	//poly
		objectPolyPolyTypePopUp,											@"objectPolyPolyTypePopUp",
		objectPolySturmOn,														@"objectPolySturmOn",
	
	//prism
		objectPrismSweepTypePopUp,										@"objectPrismSweepTypePopUp",
		objectPrismKeepDimensionsOn,									@"objectPrismKeepDimensionsOn",
		objectPrismKeepDimensionsPopUp,								@"objectPrismKeepDimensionsPopUp",
		objectPrismTopHeightEdit,											@"objectPrismTopHeightEdit",
		objectPrismBaseHeightEdit,										@"objectPrismBaseHeightEdit",
		objectPrismBevelPrismGroupOn,									@"objectPrismBevelPrismGroupOn",
		objectPrismBevelPrismFractionHeightEdit,			@"objectPrismBevelPrismFractionHeightEdit",
		objectPrismBevelPrismFractionAngleEdit,				@"objectPrismBevelPrismFractionAngleEdit",
		objectPrismOpenOn,														@"objectPrismOpenOn",
		objectPrismSturmOn,														@"objectPrismSturmOn",
	//sor	
		objectSorOpenOn,															@"objectSorOpenOn",
		objectSorSturmOn,															@"objectSorSturmOn",
	//sphere
		[objectSphereCenterMatrix cellWithTag:0],			@"objectSphereCenterMatrixX",
		[objectSphereCenterMatrix cellWithTag:1],			@"objectSphereCenterMatrixY",
		[objectSphereCenterMatrix cellWithTag:2],			@"objectSphereCenterMatrixZ",
		objectSphereRadiusEdit,												@"objectSphereRadiusEdit",
	//sphereSweep
		objectSpheresweepEntriesEdit,									@"objectSpheresweepEntriesEdit",
		objectSpheresweepSplineTypePopUp,							@"objectSpheresweepSplineTypePopUp",
		objectSpheresweepToleranceOn,									@"objectSpheresweepToleranceOn",
		objectSpheresweepToleranceEdit,								@"objectSpheresweepToleranceEdit",
	//Superellipsoid
		objectSuperellipsoidEastWestEdit,							@"objectSuperellipsoidEastWestEdit",
		objectSuperellipsoidNorthSouthEdit,						@"objectSuperellipsoidNorthSouthEdit",
	//text
		objectTextTTFFileNameEdit,										@"objectTextTTFFileNameEdit",
		objectTextTextEdit,														@"objectTextTextEdit",
		objectTextThicknessEdit,											@"objectTextThicknessEdit",
		[objectTextOffsetMatrix cellWithTag:0],				@"objectTextOffsetMatrixX",
		[objectTextOffsetMatrix cellWithTag:1],				@"objectTextOffsetMatrixY",
		[objectTextOffsetMatrix cellWithTag:2],				@"objectTextOffsetMatrixZ",
		objectTextHorizontalAlignmentTypePopUp,				@"objectTextHorizontalAlignmentTypePopUp",
		objectTextVerticalAlignmentTypePopUp,					@"objectTextVerticalAlignmentTypePopUp",
//ovus
		objectOvusBottomRadiusEdit,										@"objectOvusBottomRadiusEdit",
		objectOvusTopRadiusEdit,										@"objectOvusTopRadiusEdit",
//tours
		objectTorusMajorRadiusEdit,										@"objectTorusMajorRadiusEdit",
		objectTorusMinorRadiusEdit,										@"objectTorusMinorRadiusEdit",
		objectTorusSturmOn,														@"objectTorusSturmOn",
//triangle
		[objectTriangleCorner1Matrix cellWithTag:0],					@"objectTriangleCorner1MatrixX",
		[objectTriangleCorner1Matrix cellWithTag:1],					@"objectTriangleCorner1MatrixY",
		[objectTriangleCorner1Matrix cellWithTag:2],					@"objectTriangleCorner1MatrixZ",
		[objectTriangleCorner2Matrix cellWithTag:0],					@"objectTriangleCorner2MatrixX",
		[objectTriangleCorner2Matrix cellWithTag:1],					@"objectTriangleCorner2MatrixY",
		[objectTriangleCorner2Matrix cellWithTag:2],					@"objectTriangleCorner2MatrixZ",
		[objectTriangleCorner3Matrix cellWithTag:0],					@"objectTriangleCorner3MatrixX",
		[objectTriangleCorner3Matrix cellWithTag:1],					@"objectTriangleCorner3MatrixY",
		[objectTriangleCorner3Matrix cellWithTag:2],					@"objectTriangleCorner3MatrixZ",
		[objectTriangleNormal1Matrix cellWithTag:0],					@"objectTriangleNormal1MatrixX",
		[objectTriangleNormal1Matrix cellWithTag:1],					@"objectTriangleNormal1MatrixY",
		[objectTriangleNormal1Matrix cellWithTag:2],					@"objectTriangleNormal1MatrixZ",
		[objectTriangleNormal2Matrix cellWithTag:0],					@"objectTriangleNormal2MatrixX",
		[objectTriangleNormal2Matrix cellWithTag:1],					@"objectTriangleNormal2MatrixY",
		[objectTriangleNormal2Matrix cellWithTag:2],					@"objectTriangleNormal2MatrixZ",
		[objectTriangleNormal3Matrix cellWithTag:0],					@"objectTriangleNormal3MatrixX",
		[objectTriangleNormal3Matrix cellWithTag:1],					@"objectTriangleNormal3MatrixY",
		[objectTriangleNormal3Matrix cellWithTag:2],					@"objectTriangleNormal3MatrixZ",
		objectTriangleSmoothTriangleOn,												@"objectTriangleSmoothTriangleOn",
		objectTriangleWriteMeshTriangleOn,										@"objectTriangleWriteMeshTriangleOn",
		objectTriangleWriteMeshEntriesEdit,										@"objectTriangleWriteMeshEntriesEdit",
		objectTriangleInsideVectorOn,													@"objectTriangleInsideVectorOn",
		objectTriangleInsideXYZVectorPopUp,										@"objectTriangleInsideXYZVectorPopUp",
		[objectTriangleInsideXYZVectorMatrix cellWithTag:0],	@"objectTriangleInsideXYZVectorMatrixX",
		[objectTriangleInsideXYZVectorMatrix cellWithTag:1],	@"objectTriangleInsideXYZVectorMatrixY",
		[objectTriangleInsideXYZVectorMatrix cellWithTag:2],	@"objectTriangleInsideXYZVectorMatrixZ",

	nil];	
	[mOutlets retain];
	[ToolTipAutomator setTooltips:@"objectLocalized" andDictionary:mOutlets];
	//additional objects
	[ToolTipAutomator setTooltips:@"objectLocalized" andDictionary:
		[NSDictionary dictionaryWithObjectsAndKeys:
			
			[NSArray arrayWithObjects:
						objectIsoMaxGradientMatrix,
						@"objectIsoMaxGradientOn",		[objectIsoMaxGradientMatrix cellWithTag:0],
						@"objectIsoEvaluateOn",				[objectIsoMaxGradientMatrix cellWithTag:1],
					nil],	@"objectIsoMaxGradientMatrix",
					

			objectMaterialGroupEditButton,				@"objectMaterialGroupEditButton",
			objectTransformationEditButton,				@"objectTransformationEditButton",
			objectPhotonsGroupEditButton,					@"objectPhotonsGroupEditButton",
			objectHeightFieldPigmentButton,				@"objectHeightFieldPigmentButton",
			objectHeightFieldPatternButton,				@"objectHeightFieldPatternButton",
			objectHeightFieldFunctionButton,			@"objectHeightFieldFunctionButton",
			objectHeightFieldFileButton,					@"objectHeightFieldFileButton",
			objectLatheEditButton,								@"objectLatheEditButton",
			objectParametricFunctionXButton,			@"objectParametricFunctionXButton",
			objectParametricFunctionYButton,			@"objectParametricFunctionYButton",
			objectParametricFunctionZButton,			@"objectParametricFunctionZButton",
			objectPrismEditButton,								@"objectPrismEditButton",
			objectPolygonEditButton,							@"objectPolygonEditButton",
			objectSorEditButton,									@"objectSorEditButton",
			objectTextTTFFileSelectButton,				@"objectTextTTFFileSelectButton",

			objectBicubicPatchCorner1Matrix,			@"objectBicubicPatchCorner1Matrix",
			objectBicubicPatchCorner2Matrix,			@"objectBicubicPatchCorner2Matrix",
			objectBlobCylindricalEnd1Matrix,			@"objectBlobCylindricalEnd1Matrix",
			objectBlobCylindricalEnd2Matrix,			@"objectBlobCylindricalEnd2Matrix",
			objectBoxCorner1Matrix,								@"objectBoxCorner1Matrix",
			objectBoxCorner2Matrix,								@"objectBoxCorner2Matrix",
			objectConeBaseMatrix,									@"objectConeBaseMatrix",
			objectConeCapMatrix,									@"objectConeCapMatrix",
			objectCylinderBaseMatrix,							@"objectCylinderBaseMatrix",
			objectCylinderCapMatrix,							@"objectCylinderCapMatrix",
			objectDiscCenterMatrix,								@"objectDiscCenterMatrix",
			objectDiscNormalMatrix,								@"objectDiscNormalMatrix",


			objectIsoContainerBoxCorner1Matrix,						@"objectIsoContainerBoxCorner1Matrix",
			objectIsoContainerBoxCorner2Matrix,						@"objectIsoContainerBoxCorner2Matrix",
			objectIsoContainerSphereCenterMatrix,					@"objectIsoContainerSphereCenterMatrix",
			objectFractal4DjuliaParameterMatrix,					@"objectFractal4DjuliaParameterMatrix",
			objectFractal4DNormalMatrix,									@"objectFractal4DNormalMatrix",
			objectParametricBounderiesUMatrix,						@"objectParametricBounderiesUMatrix",
			objectParametricBounderiesVMatrix,						@"objectParametricBounderiesVMatrix",
			objectParametricContainerBoxCorner1Matrix,		@"objectParametricContainerBoxCorner1Matrix",
			objectParametricContainerBoxCorner2Matrix,		@"objectParametricContainerBoxCorner2Matrix",
			objectParametricContainerSphereCenterMatrix,	@"objectParametricContainerSphereCenterMatrix",
			objectPlaneNormalMatrix,											@"objectPlaneNormalMatrix",
			objectSphereCenterMatrix,											@"objectSphereCenterMatrix",
			objectTextOffsetMatrix,												@"objectTextOffsetMatrix",

			objectTriangleCorner1Matrix,							@"objectTriangleCorner1Matrix",
			objectTriangleCorner2Matrix,							@"objectTriangleCorner2Matrix",
			objectTriangleCorner3Matrix,							@"objectTriangleCorner3Matrix",
			objectTriangleNormal1Matrix,							@"objectTriangleNormal1Matrix",
			objectTriangleNormal2Matrix,							@"objectTriangleNormal2Matrix",
			objectTriangleNormal3Matrix,							@"objectTriangleNormal3Matrix",

			objectTriangleInsideXYZVectorMatrix,			@"objectTriangleInsideXYZVectorMatrix",

		nil]
	];
	mExcludedObjectsForReset=[NSArray arrayWithObjects:
		@"objectTypePopUp",nil];
	[mExcludedObjectsForReset retain];
	[self  setValuesInPanel:[self preferences]];
}

//---------------------------------------------------------------------
// setValuesInPanel
//---------------------------------------------------------------------
-(void) setValuesInPanel:(NSMutableDictionary*)preferences
{
	[self setObjectMaterial:[preferences objectForKey:@"objectMaterial"]];
	[self setObjectTransformations:[preferences objectForKey:@"objectTransformations"]];
	[self setObjectPhotons:[preferences objectForKey:@"objectPhotons"]];

	[self setObjectHeightFieldFunction:[preferences objectForKey:@"objectHeightFieldFunction"]];
	[self setObjectHeightFieldPatternPigment:[preferences objectForKey:@"objectHeightFieldPatternPigment"]];
	[self setObjectHeightFieldPigmentPigment:[preferences objectForKey:@"objectHeightFieldPigmentPigment"]];
	[self setObjectIsoFunction:[preferences objectForKey:@"objectIsoFunction"]];

	[self setObjectLathe:[preferences objectForKey:@"objectLathe"]];
	[self setObjectPolygon:[preferences objectForKey:@"objectPolygon"]];
	[self setObjectPrism:[preferences objectForKey:@"objectPrism"]];
	[self setObjectSor:[preferences objectForKey:@"objectSor"]];
	if ( mPolyArray != nil)
	{
		[mPolyArray release];
	}
	mPolyArray=[[[preferences objectForKey:@"polyArray"]mutableCopy]retain];

	[super setValuesInPanel:preferences];
	[self objectTypePopUp:nil];
}


//---------------------------------------------------------------------
// retrivePreferences
//---------------------------------------------------------------------
-(void) retrivePreferences
{
	[super retrivePreferences];	// will create new prefs and store them
	//now we can add a few things
	NSMutableDictionary *dict=[self preferences];

//store material if selected
	if ( objectMaterial != nil )
		if ( [[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
			[dict setObject:objectMaterial forKey:@"objectMaterial"];

								
//store transformations if selected
	if ( objectTransformations != nil )
		if ( [[dict objectForKey:@"objectTransformationGroupOn"]intValue]==NSOnState)
			[dict setObject:objectTransformations forKey:@"objectTransformations"];

//store photons if selected
	if ( objectPhotons != nil )
		if ([[dict objectForKey:@"objectPhotonsGroupOn"]intValue]==NSOnState)
			[dict setObject:objectPhotons forKey:@"objectPhotons"];

//store function, pigment or pattern if selected
//in either colorPatternImageMap or image map
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectHeightField)
	{
		if ( [[dict objectForKey:@"objectHeightFieldFileTypePopUp"]intValue]==cFunctionImage && objectHeightFieldFunction != nil)
			[dict setObject:objectHeightFieldFunction forKey:@"objectHeightFieldFunction"];
		else if ( [[dict objectForKey:@"objectHeightFieldFileTypePopUp"]intValue]==cPatternImage && objectHeightFieldPatternPigment != nil)
			[dict setObject:objectHeightFieldPatternPigment forKey:@"objectHeightFieldPatternPigment"];
		else if ( [[dict objectForKey:@"objectHeightFieldFileTypePopUp"]intValue]==cPigmentImage && objectHeightFieldPigmentPigment != nil)
			[dict setObject:objectHeightFieldPigmentPigment forKey:@"objectHeightFieldPigmentPigment"];
	}
//store function for iso
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectIsosurface)
	{
		if (  objectIsoFunction != nil)
			[dict setObject:objectIsoFunction forKey:@"objectIsoFunction"];
	}		
//	[dict setObject:[NSArchiver archivedDataWithRootObject:mMap] forKey:@"bodymap"];

//store Lathe
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectLathe)
	{
		if (  objectLathe != nil)
			[dict setObject:objectLathe forKey:@"objectLathe"];
	}		
//store Polygon
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectPolygon)
	{
		if (  objectPolygon != nil)
			[dict setObject:objectPolygon forKey:@"objectPolygon"];
	}		
//store Prism
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectPrism)
	{
		if (  objectPrism != nil)
			[dict setObject:objectPrism forKey:@"objectPrism"];
	}		
//store Sor
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectSor)
	{
		if (  objectSor != nil)
			[dict setObject:objectSor forKey:@"objectSor"];
	}		
//store poly array
	if ( [[dict objectForKey:@"objectTypePopUp"]intValue]==cObjectPoly)
	{
		if (  mPolyArray != nil)
		{
			[dict setObject:mPolyArray forKey:@"polyArray"];
		}
	}	
}

//---------------------------------------------------------------------
// updateControls
//---------------------------------------------------------------------
-(void) updateControls
{
	[self objectTarget:self];	
	[self setNotModified];
}


//---------------------------------------------------------------------
// objectObjectTarget:sender
//---------------------------------------------------------------------
-(IBAction) objectTarget:(id)sender
{
	BOOL on=YES;
	int theTag;
	if ( sender==self)
		theTag=cObjectMaterialGroupOn;
	else
		theTag=[sender tag];
	switch( theTag)
	{
		case cObjectMaterialGroupOn:
			[self setSubViewsOfNSBox:objectMaterialGroupBox toNSButton:objectMaterialGroupOn];
			if ( sender != self) break;
		case cObjectRadiosityImportanceOn:
			[self enableObjectsAccordingToObject:objectRadiosityImportanceOn,objectRadiosityImportanceEdit,nil];
			if ( sender != self) break;
		case cObjectTransformationGroupOn:
			[self setSubViewsOfNSBox:objectTransformationGroupBox toNSButton:objectTransformationGroupOn];
			if ( sender != self) break;
		case cObjectPhotonsGroupOn:
			[self setSubViewsOfNSBox:objectPhotonsGroupBox toNSButton:objectPhotonsGroupOn];
			if ( sender != self) break;
	//blob
		case cObjectBlobSphericalOn:
			[self setSubViewsOfNSBox:objectBlobSphericalGroup toNSButton:objectBlobSphericalOn];
			if ( sender != self) break;
		case cObjectBlobCylindricalOn:
			[self setSubViewsOfNSBox:objectBlobCylindricalGroup toNSButton:objectBlobCylindricalOn];
			if ( sender != self) break;
	//disc
		case cObjectDiscHoleRadiusOn:
			[self enableObjectsAccordingToObject:objectDiscHoleRadiusOn ,	objectDiscHoleRadiusEdit, nil];
			if ( sender != self) break;
	//height field
		case cObjectHeightFieldWaterLevelOn:
			[self enableObjectsAccordingToObject:objectHeightFieldWaterLevelOn, objectHeightFieldWaterLevelEdit,nil];
			if ( sender !=self )	break;
		case cObjectHeightFieldFileTypePopUp:
			switch([objectHeightFieldFileTypePopUp indexOfSelectedItem])
			{
				case 	cGif:	case cHdr:		case cJpeg:	case cPgm:	case cPng:
				case cPot:	case cPpm:	case cSys:		case cTga:		case cTiff:
					[objectHeightFieldFileView setHidden:NO];
					[objectHeightFieldWidthHeightView setHidden:YES];
					[objectHeightFieldFunctionView setHidden:YES];
					[objectHeightFieldPatternView setHidden:YES];
					[objectHeightFieldPigmentView setHidden:YES];
					break;
				case cFunctionImage:
					[objectHeightFieldFileView setHidden:YES];
					[objectHeightFieldWidthHeightView setHidden:NO];
					[objectHeightFieldFunctionView setHidden:NO];
					[objectHeightFieldPatternView setHidden:YES];
					[objectHeightFieldPigmentView setHidden:YES];
					break;
				case cPatternImage:
					[objectHeightFieldFileView setHidden:YES];
					[objectHeightFieldWidthHeightView setHidden:NO];
					[objectHeightFieldFunctionView setHidden:YES];
					[objectHeightFieldPatternView setHidden:NO];
					[objectHeightFieldPigmentView setHidden:YES];
					break;
				case cPigmentImage:
					[objectHeightFieldFileView setHidden:YES];
					[objectHeightFieldWidthHeightView setHidden:NO];
					[objectHeightFieldFunctionView setHidden:YES];
					[objectHeightFieldPatternView setHidden:YES];
					[objectHeightFieldPigmentView setHidden:NO];
					break;
			}
			if ( sender !=self )	break;
	//iso
		case cObjectIsoMessageOn:
			[self enableObjectsAccordingToObject:objectIsoMessageOn, objectIsoMessageMatrix,nil];
			if ( sender !=self )	break;		
		case cObjectIsoMaxGradientGroupOn:
			[self setSubViewsOfNSBox:objectIsoMaxGradientGroup toNSButton:objectIsoMaxGradientGroupOn];
			if ( [objectIsoMaxGradientGroupOn state]==NSOnState)
			{
				if ([[objectIsoMaxGradientMatrix selectedCell]tag]==cFirstCell)
				{
					[self enableObjectsAccordingToState:NSOnState,objectIsoMaxGradientEdit,nil];
					[self enableObjectsAccordingToState:NSOffState,objectIsoEvaluateEditX, objectIsoEvaluateEditY, objectIsoEvaluateEditZ,nil];
				}
				else
				{
					[self enableObjectsAccordingToState:NSOffState,objectIsoMaxGradientEdit,nil];
					[self enableObjectsAccordingToState:NSOnState,objectIsoEvaluateEditX, objectIsoEvaluateEditY, objectIsoEvaluateEditZ,nil];
				}
			}
			if ( sender !=self )	break;
		case cObjectIsoMaxGradientMatrix:
			if ( [objectIsoMaxGradientGroupOn state]==NSOnState)
			{
				if ([[objectIsoMaxGradientMatrix selectedCell]tag]==cFirstCell)
				{
					[self enableObjectsAccordingToState:NSOnState,objectIsoMaxGradientEdit,nil];
					[self enableObjectsAccordingToState:NSOffState,objectIsoEvaluateEditX, objectIsoEvaluateEditY, objectIsoEvaluateEditZ,nil];
				}
				else
				{
					[self enableObjectsAccordingToState:NSOffState,objectIsoMaxGradientEdit,nil];
					[self enableObjectsAccordingToState:NSOnState,objectIsoEvaluateEditX, objectIsoEvaluateEditY, objectIsoEvaluateEditZ,nil];
				}
			}
			if ( sender !=self )	break;
		case cObjectIsoThresholdOn:
			[self enableObjectsAccordingToObject:objectIsoThresholdOn, objectIsoThresholdEdit,nil];
			if ( sender !=self )	break;
		case cObjectIsoAccuracyOn:
			[self enableObjectsAccordingToObject:objectIsoAccuracyOn, objectIsoAccuracyEdit,nil];
			if ( sender !=self )	break;
		case cObjectIsoMaxTraceOn:
			[self enableObjectsAccordingToObject:objectIsoMaxTraceOn, objectIsoMaxTraceMatrix,objectIsoMaxTraceEdit,nil];
//			if ( sender !=self )	break;
		case cObjectIsoMaxTraceMatrix:
			if ([[objectIsoMaxTraceMatrix selectedCell]tag]==cFirstCell)
				[self enableObjectsAccordingToObject:objectIsoMaxTraceOn,objectIsoMaxTraceEdit,nil];
			else
				[self enableObjectsAccordingToState:NSOffState,objectIsoMaxTraceEdit,nil];
			if ( sender !=self )	break;
		case cObjectIsoContainerObjectPopUp:
			switch ( [objectIsoContainerObjectPopUp indexOfSelectedItem])
			{
				case cBoxContainer:
					[objectIsoContainerBoxView setHidden:NO];
					[objectIsoContainerSphereView setHidden:YES];
					break;
				case cSphereContainer:
					[objectIsoContainerBoxView setHidden:YES];
					[objectIsoContainerSphereView setHidden:NO];
				break;
			}
			if ( sender !=self )	break;
	//fractal
		case cObjectFractalSliceOn:
			[self setSubViewsOfNSBox:objectFractalSliceGroup toNSButton:objectFractalSliceOn];
			if ( sender != self) break;
		case cObjectFractal4DAlgebraPopUp:
			on=YES;
			if  ([objectFractal4DAlgebraPopUp indexOfSelectedItem]==cQuaternation)
				on=NO;
			for (int x=cExp; x<=cPwr; x++)
					[[objectFractalFunctionPopUp itemAtIndex:x]setEnabled:on];
			if  ([objectFractal4DAlgebraPopUp indexOfSelectedItem]==cQuaternation && 	[objectFractalFunctionPopUp indexOfSelectedItem]>cCube)
				[objectFractalFunctionPopUp selectItemAtIndex:cSqrt];
			if ( sender != self) break;
	//parametric
		case cObjectParametricMaxGradientOn:
			[self enableObjectsAccordingToObject:objectParametricMaxGradientOn, objectParametricMaxGradientEdit,nil];
			if ( sender !=self )	break;
		case cObjectParametricAccuracyOn:
			[self enableObjectsAccordingToObject:objectParametricAccuracyOn, objectParametricAccuracyEdit,
													objectParametricPrecomputeDepthsEdit,nil];
			[self enableObjectsAccordingToObject:objectParametricPrecomputeDepthsOn, 
											objectParametricOfVariablesText, objectParametricOfVariablesXOn,
											objectParametricOfVariablesYOn,objectParametricOfVariablesZOn,nil];
			if ( sender !=self )	break;
		case cObjectParametricPrecomputeDepthsOn:
			[self enableObjectsAccordingToObject:objectParametricPrecomputeDepthsOn, objectParametricPrecomputeDepthsEdit,
											objectParametricOfVariablesText, objectParametricOfVariablesXOn,
											objectParametricOfVariablesYOn,objectParametricOfVariablesZOn,nil];
			if ( sender !=self )	break;
		case cObjectParametricContainerObjectPopUp:
			switch ( [objectParametricContainerObjectPopUp indexOfSelectedItem])
			{
				case cBoxContainer:
					[objectParametricContainerBoxView setHidden:NO];
					[objectParametricContainerSphereView setHidden:YES];
					break;
				case cSphereContainer:
					[objectParametricContainerBoxView setHidden:YES];
					[objectParametricContainerSphereView setHidden:NO];
				break;
			}
			if ( sender !=self )	break;
	//plane
		case cObjectPlaneNormalXYZPopUp:
			[ self setXYZVectorAccordingToPopup:objectPlaneNormalXYZPopUp xyzMatrix:objectPlaneNormalMatrix];
			if ( sender !=self )	break;
	//poly
		case cObjectPolyPolyTypePopUp:
			if ( sender !=self )	
				[objectPolyTableView noteNumberOfRowsChanged]; // data source will do the rect :-)
			if ( sender !=self )	break;
	//prism
			case cObjectPrismBevelPrismGroupOn:
				[self setSubViewsOfNSBox:objectPrismBevelPrismGroup toNSButton:objectPrismBevelPrismGroupOn];
				if ( sender !=self )	break;
			case cObjectPrismSweepTypePopUp:
				if ( [objectPrismSweepTypePopUp indexOfSelectedItem]==cPrismLinearSweep)
				{
					[objectPrismBevelPrismGroup setHidden:NO];
					[objectPrismBevelPrismGroupOn setHidden:NO];
					[objectPrismKeepDimensionsView setHidden:YES];
				}
				else
				{
					[objectPrismBevelPrismGroup setHidden:YES];
					[objectPrismBevelPrismGroupOn setHidden:YES];
					[objectPrismKeepDimensionsView setHidden:NO];
				}	
				if ( sender !=self )	break;

			case cObjectPrismKeepDimensionsOn:
				[self enableObjectsAccordingToObject:objectPrismKeepDimensionsOn, objectPrismKeepDimensionsPopUp,nil];
				if ( sender !=self )	break;
	//spheresweep
			case cObjectSpheresweepToleranceOn:
				[self enableObjectsAccordingToObject:objectSpheresweepToleranceOn, objectSpheresweepToleranceEdit,nil];
				if ( sender !=self )	break;
		//triangle
			case cObjectTriangleWriteMeshTriangleOn:
				[self enableObjectsAccordingToObject:objectTriangleWriteMeshTriangleOn, objectTriangleWriteMeshEntriesText,objectTriangleWriteMeshEntriesEdit,nil];
				[self setSubViewsOfNSBox:objectTriangleInsideVectorBox toNSButton:objectTriangleWriteMeshTriangleOn];
				[self objectTypePopUp:nil];


					if ( sender !=self )	break;
			case cObjectTriangleSmoothTriangleOn:
				[self setSubViewsOfNSBox:objectTriangleNormalGroup toNSButton:objectTriangleSmoothTriangleOn ];
				if ( sender !=self )	break;
			case cObjectTriangleInsideXYZVectorPopUp:
				[ self setXYZVectorAccordingToPopup:objectTriangleInsideXYZVectorPopUp xyzMatrix:objectTriangleInsideXYZVectorMatrix];
				if ( sender !=self )	break;
			case cObjectTriangleInsideVectorOn:
				[self enableObjectsAccordingToObject:objectTriangleInsideVectorOn, objectTriangleInsideXYZVectorPopUp,
						objectTriangleInsideXYZVectorMatrix, nil];
				if ( sender !=self )	break;

			
	}
	[self setModified:nil];
}

//---------------------------------------------------------------------
// acceptsPreferences:forKey
//---------------------------------------------------------------------
-(void)	acceptsPreferences:(NSDictionary*)dict forKey:(NSString*)key
{
	NSString *str=nil;
	 if( [key isEqualToString:@"objectTransformations"])
	{
		[self setObjectTransformations:dict];
	}
	else if( [key isEqualToString:@"objectPhotons"])
	{
		[self setObjectPhotons:dict];
	}
	else if( [key isEqualToString:@"objectMaterial"])
	{
		[self setObjectMaterial:dict];
	}
	else if( [key isEqualToString:@"objectHeightFieldFunction"])
	{
		[self setObjectHeightFieldFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[objectHeightFieldFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"objectIsoFunction"])
	{
		[self setObjectIsoFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[objectIsoFunctionEdit  insertText:str];
	}
	else if( [key isEqualToString:@"objectParametricXFunction"])
	{
		[self setObjectIsoFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[objectParametricFunctionXEdit  insertText:str];
	}
	else if( [key isEqualToString:@"objectParametricYFunction"])
	{
		[self setObjectIsoFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[objectParametricFunctionYEdit  insertText:str];
	}
	else if( [key isEqualToString:@"objectParametricZFunction"])
	{
		[self setObjectIsoFunction:dict];
		str=[[FunctionTemplate createDescriptionWithDictionary:dict andTabs:0 extraParam:0 mutableTabString:nil]string];
		if (str==nil)
			return;
		[objectParametricFunctionZEdit  insertText:str];
	}
	else if( [key isEqualToString:@"objectHeightFieldPatternPigment"])
	{
		[self setObjectHeightFieldPatternPigment:dict];
	}
	else if( [key isEqualToString:@"objectHeightFieldPigmentPigment"])
	{
		[self setObjectHeightFieldPigmentPigment:dict];
	}

	else if( [key isEqualToString:@"objectLathe"])
	{
		[self setObjectLathe:dict];
	}
	else if( [key isEqualToString:@"objectPolygon"])
	{
		[self setObjectPolygon:dict];
	}
	else if( [key isEqualToString:@"objectPrism"])
	{
		[self setObjectPrism:dict];
	}
	else if( [key isEqualToString:@"objectSor"])
	{
		[self setObjectSor:dict];
	}



	
	[self setKeyName:nil];	//release key
}

//---------------------------------------------------------------------
// objectButtons:sender
//---------------------------------------------------------------------
-(IBAction) objectButtons:(id)sender
{
	id prefs=nil;
	switch ([sender tag])
	{
		case cObjectMaterialEditButton:
			if (objectMaterial!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectMaterial];
			[self callTemplate:menuTagTemplateMaterial  withDictionary:prefs andKeyName:@"objectMaterial"];
			break;
		case cObjectTransformationEditButton:
			if (objectTransformations!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectTransformations];
			[self callTemplate:menuTagTemplateTransformations withDictionary:prefs andKeyName:@"objectTransformations"];
			break;
		case cObjectPhotonsEditButton:
			if (objectPhotons!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectPhotons];
			[self callTemplate:menuTagTemplatePhotons withDictionary:prefs andKeyName:@"objectPhotons"];
			break;

	//height field
		case cObjectHeightFieldSelectImageFileButton:
			[self selectFile:objectHeightFieldFileName withTypes:nil keepFullPath:NO];
			break;
	 	case cObjectHeightFieldEditFunctionButton:
			if (objectHeightFieldFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectHeightFieldFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"objectHeightFieldFunction"];
			break;
	 	case cObjectHeightFieldEditPatternButton:
			if (objectHeightFieldPatternPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectHeightFieldPatternPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"objectHeightFieldPatternPigment"];
			break;
	 	case cObjectHeightFieldEditPigmentButton:
			if (objectHeightFieldPigmentPigment!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectHeightFieldPigmentPigment];
			[self callTemplate:menuTagTemplatePigment withDictionary:prefs andKeyName:@"objectHeightFieldPigmentPigment"];
			break;
	//iso
	 	case cObjectIsoFunctionEditButton:
			if (objectIsoFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectIsoFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"objectIsoFunction"];
			break;
	//lathe		
	 	case cObjectLatheEditButton:
			if (objectLathe!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectLathe];
			[self callTemplate:menuTagTemplateLathe withDictionary:prefs andKeyName:@"objectLathe"];
			break;
	//polyugon
	 	case cObjectPolygonEditButton:
			if (objectPolygon!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectPolygon];
			[self callTemplate:menuTagTemplatePolygon withDictionary:prefs andKeyName:@"objectPolygon"];
			break;
	//prism
	 	case cObjectPrismEditButton:
			if (objectPrism!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectPrism];
			[self callTemplate:menuTagTemplatePrism withDictionary:prefs andKeyName:@"objectPrism"];
			break;
	//sor
	 	case cObjectSorEditButton:
			if (objectSor!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectSor];
			[self callTemplate:menuTagTemplateSor withDictionary:prefs andKeyName:@"objectSor"];
			break;
	//parametric   use the same function as iso
	 	case cObjectParametricFunctionXEditButton:
			if (objectIsoFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectIsoFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"objectParametricXFunction"];
			break;
	 	case cObjectParametricFunctionYEditButton:
			if (objectIsoFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectIsoFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"objectParametricYFunction"];
			break;
	 	case cObjectParametricFunctionZEditButton:
			if (objectIsoFunction!=nil)
				prefs=[NSMutableDictionary dictionaryWithDictionary:objectIsoFunction];
			[self callTemplate:menuTagTemplateFunctions withDictionary:prefs andKeyName:@"objectParametricZFunction"];
			break;
	//ttf
		case cObjectTextSelectTTFButton:
			[self selectFile:objectTextTTFFileNameEdit withTypes:nil keepFullPath:NO];;
			break;
	
	}
}


//---------------------------------------------------------------------
// objectTypePopUp:sender
//---------------------------------------------------------------------
-(IBAction) objectTypePopUp:(id)sender
{
	int item=[objectTypePopUp indexOfSelectedItem];
	[objectTabView selectTabViewItemAtIndex:item];
	BOOL showUv=YES;
	BOOL showHollow=YES;
	
	switch (item)
	{
		case cObjectBicubicPatch:	showHollow=NO;
			break;

		case cObjectTriangle:
			if ( [objectTriangleWriteMeshTriangleOn state]==NSOnState)
				showUv=YES;
			else
				showUv=NO;
			break;		
		case cObjectCone:	
		case cObjectPolygon:	showUv=NO;	showHollow=NO;	
			break;

		case cObjectCylinder:			
		case cObjectDisc:				
		case cObjectHeightField:
		case cObjectIsosurface:
		case cObjectJuliaFractal:		
		case cObjectPlane:				
		case cObjectPoly:
		case cObjectBlob:
		case cObjectPrism:
		case cObjectText: 	showUv=NO;
			break;

		case cObjectLathe:
		case cObjectParametric:
		case cObjectBox:
		case cObjectSor:
		case cObjectSphere:
		case cObjectSpheresweep:
		case cObjectSuperelipsoid:
		case cObjectOvus:
		case cObjectTorus:			
	
			break;
	}
	[objectUvMappingOn setEnabled:showUv];
	[objectHollowOn setEnabled:showHollow];
}


//---------------------------------------------------------------------
// datasource
//---------------------------------------------------------------------
// numberOfRowsInTableView
//---------------------------------------------------------------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	if( tableView==objectPolyTableView)
	{
		switch ([objectPolyPolyTypePopUp indexOfSelectedItem])
		{
			case cQuadricPoly: return 10;		break;
			case cCubicPoly:		return 20;		break;
			case cQuarticPoly:	return 35;		break;
			case cPoly5:			return 56;		break;
			case cPoly6:			return 84;		break;
			case cPoly7:			return 120;	break;
		}
	}
	return 0;
}

//---------------------------------------------------------------------
// tableView:objectValueForTableColumn:row
//---------------------------------------------------------------------
- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
//	if ( tableView == objectPolyTableView)
	{
		if( mPolyArray == nil)			//not created yet, so do it
		{
			mPolyArray=[[NSMutableArray  alloc]init];
			for (int x=1; x<=120; x++)
				[mPolyArray addObject:[NSNumber numberWithFloat:0.0]];
		}
		if ( mPolyArray == nil)
			return nil;

		if ( [identifier isEqualToString:@"nr"])
			return [NSNumber numberWithInt:rowIndex+1];
		else if ( [identifier isEqualToString:@"value"])
			return [NSString stringWithFormat:FloatFormat,[[mPolyArray objectAtIndex:rowIndex]floatValue]];
		else if ( [identifier isEqualToString:@"description"])
		{
			switch ([objectPolyPolyTypePopUp indexOfSelectedItem])
			{
				case cQuadricPoly: return [NSString stringWithUTF8String:&Poly2[rowIndex][0]]; break;
				case cCubicPoly: 	return [NSString stringWithUTF8String:&Poly3[rowIndex][0]]; break;
				case cQuarticPoly: 	return [NSString stringWithUTF8String:&Poly4[rowIndex][0]]; break;
				case cPoly5: 			return [NSString stringWithUTF8String:&Poly5[rowIndex][0]]; break;
				case cPoly6: 			return [NSString stringWithUTF8String:&Poly6[rowIndex][0]]; break;
				case cPoly7: 			return [NSString stringWithUTF8String:&Poly7[rowIndex][0]]; break;
			}
		}
	}
	return nil;

}

//---------------------------------------------------------------------
// tableView:setObjectValue:row
//---------------------------------------------------------------------
- (void)tableView:(NSTableView *)aTableView setObjectValue:(id)anObject forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)rowIndex
{
	id identifier=[tableColumn identifier];
//	if ( aTableView == objectPolyTableView)
	{
		if ( [identifier isEqualToString:@"value"])
			[mPolyArray replaceObjectAtIndex:rowIndex withObject:[NSNumber numberWithFloat:[anObject floatValue]]];
		[objectPolyTableView reloadData];		// redraw the table
	}
}


@end

//--------------------------------------------------------------------
// WriteMaterialAndTrans
//--------------------------------------------------------------------
static void WriteMaterialAndTrans(MutableTabString *ds,NSDictionary *dict, BOOL checkForUVMapping)
{
		if ([[dict objectForKey:@"objectIgnoreMaterialOn"]intValue]==NSOnState)
		{
			if ([[dict objectForKey:@"objectTransformationGroupOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"objectTransformations"]
					andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}	
			if ([[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
			{
				if ( checkForUVMapping && [[dict objectForKey:@"objectUvMappingOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"uv_mapping\n"];
				if ( checkForUVMapping && [[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
					[MaterialTemplate createDescriptionWithDictionary:[dict objectForKey:@"objectMaterial"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
		}
		else
		{
			if ([[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
			{
				if ( checkForUVMapping && [[dict objectForKey:@"objectUvMappingOn"]intValue]==NSOnState)
					[ds copyTabAndText:@"uv_mapping\n"];
				if ( checkForUVMapping && [[dict objectForKey:@"objectMaterialGroupOn"]intValue]==NSOnState)
					[MaterialTemplate createDescriptionWithDictionary:[dict objectForKey:@"objectMaterial"]
						andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}
			if ([[dict objectForKey:@"objectTransformationGroupOn"]intValue]==NSOnState)
			{
				[TransformationsTemplate createDescriptionWithDictionary:[dict objectForKey:@"objectTransformations"]
					andTabs:[ds currentTabs] extraParam:0 mutableTabString:ds];
			}	
		}
}								
