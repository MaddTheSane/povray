//******************************************************************************
///
/// @file /macintosh/menuFromDirectory.mm
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

#import "menuFromDirectory.h"
#import "appPreferencesController.h"

// this must be the last file included
#import "syspovdebug.h"
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//+++++++++++++++++++++++++++++++++++++++++++++++++
// menuFromDirectory
//+++++++++++++++++++++++++++++++++++++++++++++++++
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

// class will not remove submenu's en menuitems from the submenu's en menuitems
// program is responsible for this

@implementation menuFromDirectory

//---------------------------------------------------------------------
// initWithPath: andExtensions
//---------------------------------------------------------------------
- (id)initWithPath:(NSString*) path andExtensions:(NSArray*) extensions
{
	self=[super init];
	if(self )
	{
		if ( [path hasSuffix:@"/"]==NO)
			path=[path stringByAppendingString:@"/"];
		[self setPath:path];
		[self setExtensions:extensions];
	}
	return self;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self setPath:nil];
	[self setExtensions:nil];
	[self setMainMenuItem:nil];
	[self setMenu:nil];
	// release all objects
	[[ self itemsArray] removeAllObjects];
	[self setItemsArray:nil];
	[super dealloc];
}

//---------------------------------------------------------------------
// menuFromDirectory: withExtensions: forMainMenuItem
//---------------------------------------------------------------------
+(menuFromDirectory*) fromDirectory:(NSString*)path withExtensions:(NSArray*)extensionsArray forMainMenuItem:(NSMenuItem*)mainMenuItem 
											scaleFactor:(float)scale action:(SEL) selector
{
	menuFromDirectory *nw=[[[menuFromDirectory alloc]initWithPath:path andExtensions:extensionsArray ]autorelease];
	if ( nw != nil)
	{
		[nw setMainMenuItem:mainMenuItem];
		if ( [mainMenuItem submenu])
			[nw setMenu:[mainMenuItem submenu]];
		[nw setScaleFactor: scale];
		[nw setAction:selector];
		[nw build];
	}
	return nw;
} 

//---------------------------------------------------------------------
// build
//---------------------------------------------------------------------
-(void) build
{
	BOOL isDir;
	NSArray *directoryContents;
	NSFileManager *fm=[NSFileManager defaultManager];
	if ( [self path]!= nil && [[self path] length])
	{
		if ( [fm fileExistsAtPath:[self path] isDirectory:&isDir]==NO)
			return;
		directoryContents=[fm contentsOfDirectoryAtPath:[self path] error:nil];
		if ( [directoryContents count])
		{
			[self setItemsArray:[[[NSMutableArray alloc]init]autorelease]];
			[self validateContents:directoryContents];
			[self addMenuToMainMenu:[self mainMenuItem]];
		}
	}
}

//---------------------------------------------------------------------
// directoryItemForNSMenuItem: menuItem
//---------------------------------------------------------------------
-(id) directoryItemForNSMenuItem:(NSMenuItem*)menuItem
{
	NSMutableArray *ar=[self itemsArray];
	int num=[ar count];
	if ( num)
	{
		for (int x=0; x<num; x++)
		{
			id obj=[ar objectAtIndex:x];
			if ( [obj menuItem] == menuItem && [obj subDir]==nil)	//menu ok but not a subdir
				return obj;
			else if ( [obj subDir] )	// subdir, scan this one
			{
				id sub=[[obj subDir]directoryItemForNSMenuItem:menuItem];
				if (sub)
					return sub;
			}
		}
	}
	return nil;
}


//---------------------------------------------------------------------
// directories
//---------------------------------------------------------------------
// creates an array with all the directories, not files
// the returned array can be used to watch any changes
//---------------------------------------------------------------------
-(void) directories:(NSMutableArray*)dirAr
{
	NSMutableArray *ar=[self itemsArray];
	int num=[ar count];
	if ( num)
	{
		for (int x=0; x<num; x++)
		{
			id obj=[ar objectAtIndex:x];
			if ( [obj subDir] )	// subdir, scan this one
			{
				[dirAr addObject:[[[obj fullFileName]copy]autorelease]];
				[[obj subDir]directories:dirAr];
			}
		}
	}
}



//---------------------------------------------------------------------
// validateContents: contents
//---------------------------------------------------------------------
-(void) validateContents:(NSArray*)contents
{
	BOOL isDir;
	NSFileManager *fm=[NSFileManager defaultManager];
	NSMenuItem *newMenuItem=nil;
	int items=[contents count];
	
	if ( items==0) 
		return;
	if ([self menu]== nil )
	{
		NSMenu *m=[[[NSMenu alloc]initWithTitle:@""]autorelease];
		[self setMenu:m]; 
	}
		
	for (int x=0; x<items; x++)
	{
		NSString *file=[contents objectAtIndex:x];
		NSString *path=[self path];
		NSString *fileAndPath=[path stringByAppendingString:file];
		[fm fileExistsAtPath:fileAndPath isDirectory:&isDir];
		menuFromDirectoryItem *directoryItem=[[[menuFromDirectoryItem alloc]init]autorelease];
		if ( isDir==YES)
			[directoryItem setKindOfFile:kDirectory];
		else
			[directoryItem setKindOfFile:kFile];
		[directoryItem setFileName:file];
		[directoryItem setPath:[self path]];
		[directoryItem setAction:[self action]];
		[directoryItem setMenuName:[self itemNameFromFilename:file]];
		// separator line?
		if ( [[directoryItem menuName] compare:@"-.txt" options:NSCaseInsensitiveSearch range:NSMakeRange(0,5)]==NSOrderedSame)
			[directoryItem setIsSeparator:YES];
		else
			[directoryItem setIsSeparator:NO];
			
		if ([directoryItem isSeparator]==YES)
		{
			newMenuItem=[NSMenuItem separatorItem];
			[directoryItem setMenuItem:newMenuItem];
			[self addObject:directoryItem];
		}
		else if ( [directoryItem kindOfFile] == kDirectory)
		{
			newMenuItem=[[[NSMenuItem alloc]initWithTitle:[directoryItem menuName] action:[self action] keyEquivalent:@""]autorelease];
			[directoryItem setMenuItem:newMenuItem];
			[self addObject:directoryItem];
			menuFromDirectory *mfd=[menuFromDirectory fromDirectory:fileAndPath withExtensions:[self extensions] 
							forMainMenuItem:newMenuItem  scaleFactor:[[appPreferencesController sharedInstance]scaleFactor] action:[self action]];
			[directoryItem setSubDir:mfd];
		}
		else 
		{
			NSString *foundExtension = nil;
			if ( [self isFileValid:file extensionResult:&foundExtension]==YES)	//is it a valid filename
			{
				if ( [[directoryItem menuName] hasSuffix:@".txt"])// no '.txt' in the menu name
					[directoryItem setMenuName: [[directoryItem menuName]stringByDeletingPathExtension] ];
				newMenuItem=[[[NSMenuItem alloc]initWithTitle:[directoryItem menuName] action:[self action] keyEquivalent:@""]autorelease];
				[directoryItem setMenuItem:newMenuItem];
				NSString *nameWithoutExtension = [[directoryItem fullFileName] stringByDeletingPathExtension];
				NSString *imageName=nil;
				if ( [fm fileExistsAtPath:[nameWithoutExtension stringByAppendingString:@".bmp"]] == YES)
					imageName = [nameWithoutExtension stringByAppendingString:@".bmp"];
				else if ( [fm fileExistsAtPath:[nameWithoutExtension stringByAppendingString:@".png"]] == YES)
					imageName = [nameWithoutExtension stringByAppendingString:@".png"];
				else if ( [fm fileExistsAtPath:[nameWithoutExtension stringByAppendingString:@".tga"]] == YES)
					imageName = [nameWithoutExtension stringByAppendingString:@".tga"];
				else if ( [fm fileExistsAtPath:[nameWithoutExtension stringByAppendingString:@".jpg"]] == YES)
					imageName = [nameWithoutExtension stringByAppendingString:@".jpg"];
				else if ( [fm fileExistsAtPath:[nameWithoutExtension stringByAppendingString:@".jpeg"]] == YES)
					imageName = [nameWithoutExtension stringByAppendingString:@".jpeg"];
				if ( imageName  != nil)
				{
					NSImage *sourceImage=[[[NSImage alloc]initWithContentsOfFile:imageName]autorelease];
					NSSize newSize=[sourceImage size];
					newSize.width *=[self scaleFactor]/100;
					newSize.height*=[self scaleFactor]/100;
					
					
					NSImage *resizedImage = [[[NSImage alloc] initWithSize:newSize ]autorelease];
					NSSize originalSize = [sourceImage size];

					[resizedImage lockFocus];
					[sourceImage drawInRect: NSMakeRect(0, 0, newSize.width, newSize.height) fromRect: NSMakeRect(0, 0, originalSize.width, originalSize.height) operation: NSCompositeSourceOver fraction: 1.0];
					[resizedImage unlockFocus];
					[[directoryItem menuItem]setImage:resizedImage];
				}
				[self addObject:directoryItem];
			}
		}			
	}
}

//---------------------------------------------------------------------
// addObject: obj
//---------------------------------------------------------------------
-(void) addObject:(id)objectToAdd
{
	NSMutableArray *itemsArray=[self itemsArray];
	NSUInteger itemsInArray=[itemsArray count];
	NSInteger firstDirectory, lastDirectory,firstFile,lastFile;
	
	if ( itemsInArray ==0)
	{
		[itemsArray addObject:objectToAdd];
		[[self menu] addItem:[objectToAdd menuItem]];
		return;
	}
	NSString *nameOfObjectToAdd=[objectToAdd fileName];
	NSString *nameOfObjectInArray =nil;
	NSUInteger objectType=[objectToAdd kindOfFile];
	[self indexOfFirstDirectory:firstDirectory andLastDirectory:lastDirectory];
	[self indexOfFirstFile:firstFile andLastFile:lastFile];
	switch (objectType)
	{
		case kDirectory: //adding a directory
			if ( firstDirectory == kNotDefined)	// no direcotry yet, add at the top
			{
				[itemsArray insertObject:objectToAdd atIndex:0] ;
				[[self menu] insertItem:[objectToAdd menuItem] atIndex:0];
				return;
			}
			for (int x=firstDirectory; x<=lastDirectory; x++)
			{
				nameOfObjectInArray=[[itemsArray objectAtIndex:x]fileName];
				NSRange compRange=NSMakeRange(0, MAX([nameOfObjectInArray length], [nameOfObjectToAdd length]));
				if ( [nameOfObjectToAdd compare:nameOfObjectInArray options:NSCaseInsensitiveSearch range:compRange] ==NSOrderedAscending)
				{
					[itemsArray insertObject:objectToAdd atIndex:x] ;
					[[self menu] insertItem:[objectToAdd menuItem] atIndex:x];
					return;
				}
			}
			// object to add is > last dir in list so add at the end of dirs
			[itemsArray insertObject:objectToAdd atIndex:lastDirectory+1] ;
			[[self menu] insertItem:[objectToAdd menuItem] atIndex:lastDirectory+1];
		break;
		default:
			if ( firstFile == kNotDefined)	// no file yet, add at the end of menu
			{
				[[self itemsArray] addObject:objectToAdd];
				[[self menu] addItem:[objectToAdd menuItem]];
				return;
			}
			for (int x=firstFile; x<lastFile; x++)
			{
				NSRange compRange=NSMakeRange(0, MAX([nameOfObjectInArray length], [nameOfObjectToAdd length]));
				nameOfObjectInArray=[[itemsArray objectAtIndex:x]fileName];
				if ( [nameOfObjectToAdd compare:nameOfObjectInArray options:NSCaseInsensitiveSearch range:compRange] ==NSOrderedAscending)
				{
					[itemsArray insertObject:objectToAdd atIndex:x] ;
					[[self menu] insertItem:[objectToAdd menuItem] atIndex:x];
					return;
				}
			}
			// object to add is > last dir in list so add at the end of dirs
			[itemsArray addObject:objectToAdd];
			[[self menu] addItem:[objectToAdd menuItem]];
		break;
	} //switch
}
//---------------------------------------------------------------------
// indexOfFirstDirectory: 
//---------------------------------------------------------------------
-(NSInteger) indexOfFirstDirectory:(NSInteger&) first andLastDirectory:(NSInteger&)last
{
	first=kNotDefined;
	last=kNotDefined;
	
	NSMutableArray *itemsArray=[self itemsArray];
	if ( [itemsArray count]==0)
		return kNotDefined;
	for (NSUInteger idx=0; idx <[itemsArray count]; idx++)
	{
		if ( [[itemsArray objectAtIndex:idx]kindOfFile]==kDirectory)
		{
			if (first == kNotDefined)
			{
				first=idx;
				last=idx;
			}
			else
				last=idx;
		}
	}
	return first;
}

//---------------------------------------------------------------------
// indexOfFirstFile:
//---------------------------------------------------------------------
-(NSInteger) indexOfFirstFile:(NSInteger&) first andLastFile:(NSInteger&)last
{
	first=kNotDefined;
	last=kNotDefined;
	
	NSMutableArray *itemsArray=[self itemsArray];
	if ( [itemsArray count]==0)
		return kNotDefined;
		
	for (NSUInteger idx=0; idx <[itemsArray count]; idx++)
	{
		if ( [[itemsArray objectAtIndex:idx]kindOfFile] == kFile)
		{
			if (first == kNotDefined)
			{
				first=idx;
				last=idx;
			}
			else
				last=idx;
		}
	}
	return first;
}

//---------------------------------------------------------------------
// itemNameFromFilename: file
//---------------------------------------------------------------------
-(NSString *) itemNameFromFilename:(NSString *)file
{
	int length=[file length];
	if ( length < 6)
		return file;
	if ( [file characterAtIndex:3] != '-' || [file characterAtIndex:4]!= ' ')
		return file;
	return [file substringFromIndex:5];
	
}

//---------------------------------------------------------------------
// isFileValid: file
//---------------------------------------------------------------------
-(BOOL) isFileValid: (NSString *)file extensionResult:(NSString**)foundExtension
{
	BOOL valid=NO;
	NSString *extension=[file pathExtension];
	NSArray *ext=[self extensions];
	if ( ext == nil)
		return valid;
	//	NSLog(@"checking file: %@",file);
	if ( extension!= nil && [extension length])
	{
		for ( int c=0; c<[ext count]; c++)
		{
			if ( [extension compare:[ext objectAtIndex:c] options:NSLiteralSearch range:NSMakeRange(0,[extension length])] ==NSOrderedSame)
			{
				*foundExtension = [ext objectAtIndex:c];
	//			NSLog(@"was valid");
				valid = YES;
				return valid;
			}
		}
	}
	//			NSLog(@"was valid: %d", valid);
	return valid;
}

//---------------------------------------------------------------------
// addMenuToMainMenu: mainMenuItem
//---------------------------------------------------------------------
-(void) addMenuToMainMenu:(NSMenuItem*) mainMenuItem
{
	[[[self mainMenuItem]menu]setSubmenu:[self menu] forItem:[self mainMenuItem]];
}

//---------------------------------------------------------------------
// setScaleFactor: float
//---------------------------------------------------------------------
-(void) setScaleFactor:(float) factor
{	
	mScaleFactor=factor;
	if ( mScaleFactor < 10.0)
		mScaleFactor = 10.0;
	if ( mScaleFactor > 100.0)
		mScaleFactor= 100.0;
	
}

//---------------------------------------------------------------------
// scaleFactor: 
//---------------------------------------------------------------------
-(float) scaleFactor{	return mScaleFactor;}

//---------------------------------------------------------------------
// setPath: path
//---------------------------------------------------------------------
-(void) setPath:(NSString*)path
{
	[mPath release];
	mPath=path;
	[mPath retain];
}

//---------------------------------------------------------------------
// setAction: action
//---------------------------------------------------------------------
-(void) setAction:(SEL)selector{	mAction=selector;}

//---------------------------------------------------------------------
// setExtensions: extensions
//---------------------------------------------------------------------
-(void) setExtensions:(NSArray*)extensions{	[mExtensions release];		mExtensions=extensions;		[mExtensions retain];}

//---------------------------------------------------------------------
// setMainMenuItem: mainMenuItem
//---------------------------------------------------------------------
-(void) setMainMenuItem:(NSMenuItem*)mainMenuItem
{
	[mMainMenuItem release];		mMainMenuItem=mainMenuItem;		[mMainMenuItem retain];
}

//---------------------------------------------------------------------
// setMenu: menu
//---------------------------------------------------------------------
-(void) setMenu:(NSMenu*)menu{	[mMenu release];		mMenu=menu;		[mMenu retain];}

//---------------------------------------------------------------------
// setItemsArray: itemsArray
//---------------------------------------------------------------------
-(void) setItemsArray:(NSMutableArray*)itemsArray
{
	[mItemsArray release];		mItemsArray=itemsArray;		[mItemsArray retain];
}

//---------------------------------------------------------------------
// action
//---------------------------------------------------------------------
-(SEL) action{	return mAction;}

//---------------------------------------------------------------------
// itemsArray
//---------------------------------------------------------------------
-(NSMutableArray*) itemsArray{	return mItemsArray;}

//---------------------------------------------------------------------
// path
//---------------------------------------------------------------------
-(NSString*) path{	return mPath;}

//---------------------------------------------------------------------
// extensions
//---------------------------------------------------------------------
-(NSArray*) extensions{	return mExtensions;}

//---------------------------------------------------------------------
// mainMenuItem
//---------------------------------------------------------------------
-(NSMenuItem*) mainMenuItem
{
	return mMainMenuItem;
}

//---------------------------------------------------------------------
// menu
//---------------------------------------------------------------------
-(NSMenu*) menu
{
	return mMenu;
}



@end


//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
//+++++++++++++++++++++++++++++++++++++++++++++++++
// menuFromDirectoryItem
//+++++++++++++++++++++++++++++++++++++++++++++++++
//$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
@implementation menuFromDirectoryItem

//---------------------------------------------------------------------
// init
//---------------------------------------------------------------------
- (id)init
{
	self=[super init];
	if(self )
	{
		/* init code */
	}
	return self;
}

//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self setMenuName:nil];
	[self setFileName:nil];
	[self setPath:nil];
	[self setMenuItem:nil];
	[self setSubDir:nil];
	[super dealloc];
}

//---------------------------------------------------------------------
// setSubDir: subdir
//---------------------------------------------------------------------
-(void) setSubDir:(menuFromDirectory*)subdir
{
	[mSubDir release];		
	mSubDir=subdir;		
	[mSubDir retain];
}

//---------------------------------------------------------------------
// subDir
//---------------------------------------------------------------------
-(menuFromDirectory*) subDir
{
	return mSubDir;
}

//---------------------------------------------------------------------
// setItemName: newName
//---------------------------------------------------------------------
-(void) setMenuName:(NSString*)newName
{
	[mItemName release];		
	mItemName=newName;		
	[mItemName retain];
}

//---------------------------------------------------------------------
// setMenuItem: newName
//---------------------------------------------------------------------
-(void) setMenuItem:(NSMenuItem*)newItem
{
	[mMenuItem release];		
	mMenuItem=newItem;		
	[mMenuItem retain];
}

//---------------------------------------------------------------------
// setFullFileName: newFileName
//---------------------------------------------------------------------
-(void) setPath:(NSString*)newPath
{
	[mPath release];		
	mPath=newPath;		
	[mPath retain];
}


//---------------------------------------------------------------------
// setFullFileName: newFileName
//---------------------------------------------------------------------
-(void) setFileName:(NSString*)newFileName
{
	[mFileName release];		
	mFileName=newFileName;		
	[mFileName retain];
}
//---------------------------------------------------------------------
// setKindOfFile: flag
//---------------------------------------------------------------------
-(void) setKindOfFile:(NSUInteger)kind
{
	mKindOfFile=kind;	
}
//---------------------------------------------------------------------
// setIsSeparator: flag
//---------------------------------------------------------------------
-(void) setIsSeparator:(BOOL)flag;
{
	mIsSeparator=flag;
}

//---------------------------------------------------------------------
// setAction: action
//---------------------------------------------------------------------
-(void) setAction:(SEL)selector
{
	mAction=selector;
}

//---------------------------------------------------------------------
// menuName
//---------------------------------------------------------------------
-(NSString*) menuName
{
	return mItemName;
}


//---------------------------------------------------------------------
// menuItem
//---------------------------------------------------------------------
-(NSMenuItem*) menuItem
{
	return mMenuItem;
}

//---------------------------------------------------------------------
// fullFileName
//---------------------------------------------------------------------
-(NSString*) fullFileName
{
	return [[self path]stringByAppendingString:[self fileName]];
}

//---------------------------------------------------------------------
// fileName
//---------------------------------------------------------------------
-(NSString*) fileName
{
	return mFileName;
}

//---------------------------------------------------------------------
// path
//---------------------------------------------------------------------
-(NSString*) path
{
	return mPath;
	}


//---------------------------------------------------------------------
// kindOfFile
//---------------------------------------------------------------------
-(NSUInteger) kindOfFile
{
	return mKindOfFile;
}

//---------------------------------------------------------------------
// isSeparator
//---------------------------------------------------------------------
-(BOOL) isSeparator
{
	return mIsSeparator;
}
@end
