//******************************************************************************
///
/// @file /macintosh/menuFromDirectory.h
///
/// compiles an "insert" menu from the windows insert-menu-folder
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
enum {
	kDirectory=0,
	kFile= 1,
	kSeparator= 2,
	
	kNotDefined=-1
	
	}entryType;

//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//+++++++++++++++++++++++++++++++++++++++++++++++++
// menuFromDirectory
//+++++++++++++++++++++++++++++++++++++++++++++++++
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
@interface menuFromDirectory : NSObject
{
	NSString				*mPath;
	NSMenuItem			*mMainMenuItem;
	NSArray 				*mExtensions;
	NSMutableArray 	*mItemsArray;
	NSMenu					*mMenu;
	SEL 						mAction;
	float						mScaleFactor;

}

+(menuFromDirectory*) fromDirectory:(NSString*)path withExtensions:(NSArray*)extensionsArray 
											forMainMenuItem:(NSMenuItem*)mainMenuItem  
											scaleFactor:(float)scale	action:(SEL)selector;
- (id)initWithPath:(NSString*) path andExtensions:(NSArray*) extensions;
-(BOOL) isFileValid: (NSString *)file extensionResult:(NSString**)foundExtension;
-(id) directoryItemForNSMenuItem:(NSMenuItem*)menuItem;
-(void) directories:(NSMutableArray*)dirAr;
-(float) scaleFactor;
-(void) setScaleFactor:(float)factor;
-(NSString *) itemNameFromFilename:(NSString *)file;
-(void) addObject:(id)objectToAdd;
-(NSInteger) indexOfFirstDirectory:(NSInteger&) first andLastDirectory:(NSInteger&)last;
-(NSInteger) indexOfFirstFile:(NSInteger&) first andLastFile:(NSInteger&)last;
-(void) setAction:(SEL)selector;
-(void) setPath:(NSString*)path;
-(void) setExtensions:(NSArray*)extensions;
-(void) setItemsArray:(NSMutableArray*)itemsArray;
-(void) setMainMenuItem:(NSMenuItem*)mainMenuItem;
-(void) setMenu:(NSMenu*)menu;
-(NSMenu*)menu;
-(NSString*) path;
-(NSArray*) extensions;
-(NSMenuItem*)	 mainMenuItem;
-(NSMutableArray*) itemsArray; 
-(void) validateContents:(NSArray*)contents;
-(void) addMenuToMainMenu:(NSMenuItem*) mainMenuItem;
-(SEL) action;

-(void) build;
@end


//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//+++++++++++++++++++++++++++++++++++++++++++++++++
// menuFromDirectoryItem
//+++++++++++++++++++++++++++++++++++++++++++++++++
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
@interface menuFromDirectoryItem : NSObject
{
	NSString 		*mItemName;
	NSString		*mFileName;
	NSString		*mPath;

	NSUInteger	mKindOfFile;
	BOOL				mIsSeparator;
	SEL 				mAction;
	NSMenuItem	*mMenuItem;

 	menuFromDirectory *mSubDir;	//if not a directory, nil
}
-(void) setSubDir:(menuFromDirectory*)subdir;

-(menuFromDirectory*)subDir;
-(void) setAction:(SEL)selector;
-(void) setMenuName:(NSString*)newName;
-(void) setMenuItem:(NSMenuItem*)newItem;
-(void) setFileName:(NSString*)newFileName;
-(void) setPath:(NSString*)newPath;
-(void) setKindOfFile:(NSUInteger) kind;
-(void) setIsSeparator:(BOOL)flag;
-(NSString*) menuName;
-(NSString*) fullFileName;
-(NSString*) fileName;
-(NSString*)	path;
-(NSMenuItem*) menuItem;
-(NSUInteger) kindOfFile;
-(BOOL) isSeparator;
@end
