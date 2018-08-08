//******************************************************************************
///
/// @file /macintosh/sceneDocument/sceneDocument+highlighting.h
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
#import  "sceneDocument.h"

enum recoloringType {
	cComment = 1,
	cKeywords = 2,
	cAll =3,
	cNoColor
	};

@interface  SceneDocument(highlighting)

	+(void) initializeSyntaxHightlighting;
	+(void) releaseKeywords;	
	+(void) releaseCharacterSets;	
	-(void) replaceAllNonCommentAndStringAttributes:(NSMutableAttributedString*)ms inRange:(NSRange)r withStyle:(NSDictionary*)newStyle;
	-(void)	recolorCompleteAttributedString:(NSMutableAttributedString*)ms sender:(id)sender;
	-(void) recolorAttributedString:(NSMutableAttributedString*) attributedString forRange: (NSRange)range recoloringType:(int)typeToRecolor blackSet:(BOOL) blackIsSet;
	-(void) applySyntaxHighlighting:(NSMutableAttributedString *) s forRange:(NSRange) r blackSet:(BOOL) blackIsSet;
	-(void) applySyntaxHighlightingOnlyComment:(NSMutableAttributedString *) ms forRange:(NSRange) r blackSet:(BOOL) blackIsSet;
	-(void) applySyntaxHighlightingOnlyKeywords:(NSMutableAttributedString *) ms forRange :(NSRange) r blackSet:(BOOL) blackIsSet;

	-(void) addMacro:(NSString*) macroName atLocation:(NSUInteger) macroLocation;
	-(void) addDeclare:(NSString*) declareName atLocation:(NSUInteger) declareLocation isLocal:(BOOL) isLocal;
	-(void) addInclude:(NSString*) macroName atLocation:(NSUInteger) macroLocation;
	-(void) buildMacro:(NSMutableAttributedString*) ms;
	-(void) buildDeclare:(NSMutableAttributedString*) ms;
	-(void) buildInclude:(NSMutableAttributedString*) ms;
	-(void) releaseMacroList;
	-(void) releaseDeclareList;
	
@end
