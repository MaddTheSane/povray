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
#import "standardMethods.h"

// this must be the last file included
#import "syspovdebug.h"

/*OSStatus SendAppleEventToSystemProcess(AEEventID EventToSend)
{
    AEAddressDesc targetDesc;
    static const ProcessSerialNumber kPSNOfSystemProcess = { 0, kSystemProcess };
    AppleEvent eventReply = {typeNull, NULL};
    AppleEvent appleEventToSend = {typeNull, NULL};

    OSStatus error = noErr;

    error = AECreateDesc(typeProcessSerialNumber, &kPSNOfSystemProcess, 
                                            sizeof(kPSNOfSystemProcess), &targetDesc);

    if (error != noErr)
    {
        return(error);
    }

    error = AECreateAppleEvent(kCoreEventClass, EventToSend, &targetDesc, 
                   kAutoGenerateReturnID, kAnyTransactionID, &appleEventToSend);

    AEDisposeDesc(&targetDesc);
    if (error != noErr)
    {
        return(error);
    }

    error = AESend(&appleEventToSend, &eventReply, kAENoReply, 
                  kAENormalPriority, kAEDefaultTimeout, NULL, NULL);

    AEDisposeDesc(&appleEventToSend);
    if (error != noErr)
    {
        return(error);
    }

    AEDisposeDesc(&eventReply);

    return(error); 
}
*/
//----------------------------------------------------------------------
//	SetSubViewsOfNSBoxToState
//----------------------------------------------------------------------
//	Set all subviews of an NSBox to the state newState
//	which is setEnabled(YES/NO)
//	Note that the array of subviews for NSBox is only one NSView
//	The subviews of that view are the 'real' subviews of an NSBox
//----------------------------------------------------------------------
void SetSubViewsOfNSBoxToState( NSBox *group, NSInteger newState)
{

	NSArray *subviewArray=[[[group subviews]objectAtIndex:0] subviews] ;
	NSUInteger numberOfSubViews=[subviewArray count];
	
	for (NSUInteger x=0; x<numberOfSubViews; x++)
	{
		id subview=[subviewArray objectAtIndex:x];

		if ( [subview isKindOfClass:[NSBox class]] )
			SetSubViewsOfNSBoxToState(subview,newState);
		else if ([subview isKindOfClass:[NSTabView class]])
			SetSubViewsOfNSTabViewToState( subview, newState);
		else if ( [subview isKindOfClass:[NSTextField class]] && [subview isEditable]==NO)
		{
			if ( [subview respondsToSelector:@selector(setTextColor:)])
		 	{
				if ( newState==NSOnState)
					[subview setTextColor:[NSColor controlTextColor]];
				else
					[subview setTextColor:[NSColor disabledControlTextColor]];
			}			
		} 
		else if ( [subview respondsToSelector:@selector(setEnabled:)])
		{ 
			[subview setEnabled:newState];
		}
		else if ( [subview isKindOfClass:[NSView class]])
		{
			SetSubViewsOfNSViewToState(subview,newState);
		}	
	}
}
void SetSubViewsOfNSTabViewToState( NSTabView *tabv, NSInteger newState)
{

	NSArray *tabviewItems=[tabv tabViewItems];
	if ( tabviewItems==nil)
		return;
	for ( NSInteger numberOfTabviewItem=0; numberOfTabviewItem<[tabviewItems count]; numberOfTabviewItem++)
	{
		NSArray *subviewArray=[[[tabviewItems objectAtIndex:numberOfTabviewItem]view] subviews] ;

		NSUInteger numberOfSubViews=[subviewArray count];
		for (NSUInteger x=0; x<numberOfSubViews; x++)
		{
			id subview=[subviewArray objectAtIndex:x];

			if ( [subview isKindOfClass:[NSBox class]] )
				SetSubViewsOfNSBoxToState(subview,newState);
		
			else if ( [subview isKindOfClass:[NSTextField class]] && [subview isEditable]==NO)
			{
				if ( [subview respondsToSelector:@selector(setTextColor:)])
			 	{
					if ( newState==NSOnState)
						[subview setTextColor:[NSColor controlTextColor]];
					else
						[subview setTextColor:[NSColor disabledControlTextColor]];
				}			
			} 
			else if ( [subview respondsToSelector:@selector(setEnabled:)])
			{
				[subview setEnabled:newState];
			}
			else if ( [subview isKindOfClass:[NSView class]])
			{
				SetSubViewsOfNSViewToState(subview,newState);
			}	

		}
	}
}


void SetSubViewsOfNSViewToState( NSView *view, NSInteger newState)
{

	NSArray *subviewArray=[view subviews] ;
	if ( subviewArray==nil)
		return;
	NSUInteger numberOfSubViews=[subviewArray count];
	
	for (NSUInteger x=0; x<numberOfSubViews; x++)
	{
		id subview=[subviewArray objectAtIndex:x];

		if ( [subview isKindOfClass:[NSBox class]] )
			SetSubViewsOfNSBoxToState(subview,newState);
		else if ([subview isKindOfClass:[NSTabView class]])
			SetSubViewsOfNSTabViewToState( subview, newState);
		else if ( [subview isKindOfClass:[NSTextField class]] && [subview isEditable]==NO)
		{
			if ( [subview respondsToSelector:@selector(setTextColor:)])
		 	{
				if ( newState==NSOnState)
					[subview setTextColor:[NSColor controlTextColor]];
				else
					[subview setTextColor:[NSColor disabledControlTextColor]];
			}			
		} 
		else if ( [subview respondsToSelector:@selector(setEnabled:)])
		{
			[subview setEnabled:newState];
		}
		else if ( [subview isKindOfClass:[NSView class]])
		{
			SetSubViewsOfNSViewToState(subview,newState);
		}

	}
}

//---------------------------------------------------------------------
// enableObjectsAccordingToObject
//---------------------------------------------------------------------
//	if referenceObject is enabled and the state is NSOnState
// each object that responds to setEnabled will be turnded on or off
// according to the state of the referenceObject
//	In case of a NSMatrix, no need to add all the cells, a NSMatrix
//	will be scanned for all cells
//---------------------------------------------------------------------
void enableObjectsAccordingToObject( id referenceObject, ...)
{
	NSInteger enabling=NO;
	id nextObject;
	va_list argumentList;
	//if the reference object isn't enabled,
	// no need to check further, disable all other objects as well
	if([referenceObject respondsToSelector:@selector(isEnabled)] && [referenceObject isEnabled]==NO)	// if the reference object isn't enabled and on 
		enabling=NO;
	else	//if the reference object is enabled, check the state and set other objects according to this state.
	{
		if([referenceObject respondsToSelector:@selector(state)] && [referenceObject state]==NSOnState)
			enabling=YES;
		else if([referenceObject respondsToSelector:@selector(intValue)] && [referenceObject intValue]==NSOnState)
			enabling=YES;
	}

	va_start(argumentList, referenceObject);          // Start scanning for arguments after firstObject.
		
	while ((nextObject = va_arg(argumentList, id)) !=nil) // As many times as we can get an argument of type "id"
	{
		if ( [nextObject isKindOfClass:[NSMatrix class]])	//all cells will be set
		{
			NSArray *matrixObject=[nextObject cells];
			NSEnumerator *en=[matrixObject objectEnumerator];
			id objectFromMatrix;
			while ( (objectFromMatrix =[en nextObject] )!= nil)
			{
				if( [objectFromMatrix respondsToSelector:@selector(setEnabled:)])
				{
					if( [objectFromMatrix respondsToSelector:@selector(stringValue)])
						[objectFromMatrix stringValue];// force validation if control is bein edited at this time
					else if( [objectFromMatrix respondsToSelector:@selector(intValue)])
						[objectFromMatrix intValue];
					[objectFromMatrix setEnabled:enabling];               // that isn't nil, add it to self's contents.
				}
			}
		}
		else
		{
			if ( [nextObject isKindOfClass:[NSTextField class]] && [nextObject isEditable]==NO)
			{
				if ( [nextObject respondsToSelector:@selector(setTextColor:)])
			 	{
					if ( enabling==NSOnState)
						[nextObject setTextColor:[NSColor controlTextColor]];
					else
						[nextObject setTextColor:[NSColor disabledControlTextColor]];
				}			
			} 
			else if ( [nextObject respondsToSelector:@selector(setEnabled:)])
			{
				
				if( [nextObject respondsToSelector:@selector(stringValue)])
					[nextObject stringValue]; // force validation if control is bein edited at this time
				else if( [nextObject respondsToSelector:@selector(intValue)])
					[nextObject intValue];
				[nextObject setEnabled:enabling];
			}
		}
	}
	va_end(argumentList);
}
//----------------------------------------------------------------------
//	SetTabViewToNSPopupButton
//----------------------------------------------------------------------
//	select the tabview item according to the 
// selected item in the popupbutton
//----------------------------------------------------------------------
void SetTabViewToNSPopupButton( NSPopUpButton *button, NSTabView* tabView)
{
	NSInteger item=[button indexOfSelectedItem];
	[tabView selectTabViewItemAtIndex:item];
}

//----------------------------------------------------------------------
//	disableItemsFromIndex
//----------------------------------------------------------------------
//	disables menuitems froma poppup from index
// enables all before index
//----------------------------------------------------------------------
void disableItemsFromIndex(NSPopUpButton *popup, NSInteger index)
{
	NSInteger selectedItem=[popup indexOfSelectedItem];
	NSMenuItem *lastItem=[popup lastItem];
	NSInteger indexLastItem=[popup indexOfItem:lastItem];
	
	if ( index > indexLastItem) // enable them all
	{
		for (NSInteger x= 0; x<= indexLastItem; x++)
			[[popup itemAtIndex:x] setEnabled:YES];
		return;
	}
	for (NSInteger x= 0; x<= indexLastItem; x++)
		if ( x < index)
			[[popup itemAtIndex:x] setEnabled:YES];
		else
			[[popup itemAtIndex:x] setEnabled:NO];
	if ( selectedItem == index)
		[popup selectItemAtIndex:index-1];
}

//---------------------------------------------------------------------
// scanForValuesInString
//---------------------------------------------------------------------
// scans the string for values en returns them in an array
//---------------------------------------------------------------------

NSMutableArray * scanForValuesInString(NSString *stringToScan)
{
	NSScanner *scanner=[NSScanner scannerWithString:stringToScan];
	NSCharacterSet *decimalsCharacterString=[NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	NSString *scannedCharacters;
	
	NSMutableArray *result = [[[NSMutableArray alloc]init]autorelease];
	
	[scanner scanUpToCharactersFromSet:decimalsCharacterString intoString:nil];
	while ([scanner scanCharactersFromSet:decimalsCharacterString intoString:&scannedCharacters] )
	{
		[result addObject:scannedCharacters];
		[scanner scanUpToCharactersFromSet:decimalsCharacterString intoString:nil];
	}
	
	return result;
	
 }

//---------------------------------------------------------------------
// remoteObject
//---------------------------------------------------------------------
//An object to hold some variables to be used with a performSelectorOnMainThread	
//	method.
//---------------------------------------------------------------------
@implementation remoteObject
	- (id) initWithObjectsAndKeys:(id) firstObject, ...
	{
		self=[super init];
		va_list argumentList;
		id nextObject;

		if ( mDict==nil)
			mDict=[[NSMutableDictionary alloc]init];
		va_start(argumentList, firstObject);          // Start scanning for arguments after firstObject.
			
		while ((nextObject = va_arg(argumentList, id)) !=nil) // As many times as we can get an argument of type "id"
		{
			[mDict setObject:firstObject forKey:nextObject];
			firstObject = va_arg(argumentList, id);
			if ( firstObject == nil)
			{
				va_end(argumentList);
				return self;
			}
		}
		va_end(argumentList);
		return self;
	}
	-(id) initWithWidth: (NSInteger)width andHeight: (NSInteger)height andRef: (NSInteger) ref
	{
		self=[super init];
		mWidth=width;
		mHeight=height;
		mRef=ref;
		mReturnValue=0;
		return self;
	}
	-(id) initWithRef: (NSInteger)ref
	{
		self=[super init];
		mRef=ref;
		mReturnValue=0;
		return self;
	}
	-(NSMutableDictionary*) dict
	{
		return mDict;
	}

	-(NSInteger) width
	{
		return mWidth;
	}
	
	-(NSInteger)height
	{
		return mHeight;
	}

	-(NSInteger) ref
	{
		return mRef;
	}
	
	-(BOOL) returnValue
	{
		return mReturnValue;
	}

	-(void) setReturnValue: (BOOL) returnValue
	{
		mReturnValue=returnValue;
	}
	-(void) dealloc
	{
		if ( mDict != nil)
		{
			[mDict release];
			mDict=nil;
		}
		[super dealloc];
	}
@end
