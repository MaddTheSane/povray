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
#import "mutableTabString.h"
#import "BaseTemplate.h"

// this must be the last file included
#import "syspovdebug.h"

@implementation MutableTabString

//---------------------------------------------------------------------
// initWithTabs
//---------------------------------------------------------------------
-(id) initWithTabs:(NSInteger)tabs andCallerType:(BOOL) callerIsSceneDocument
{
	self =[super init];
	if ( self)		
	{
		mTabCount=tabs;
		mCallerIsSceneDocument=callerIsSceneDocument;
		mFirstTimeWritten=NO;
		[self setString:[[[NSMutableString alloc] init]autorelease]];
		[self setTabString:[[[NSMutableString alloc]init]autorelease] ];
		for (NSInteger x=1; x<=mTabCount; x++)
			[[self tabString] appendString:@"\t"];
	}
	return self;
}


//---------------------------------------------------------------------
// tabString
//---------------------------------------------------------------------
@synthesize tabString=mTabString;

//---------------------------------------------------------------------
// string
//---------------------------------------------------------------------
@synthesize string=mString;

//---------------------------------------------------------------------
// length
//---------------------------------------------------------------------
-(NSUInteger) length
{
	return [mString length];
}

//---------------------------------------------------------------------
// copyTabText
//---------------------------------------------------------------------
-(void) copyTabText
{
	if ( mCallerIsSceneDocument ==YES)
	{
		if ( mFirstTimeWritten==NO)
		{
			mFirstTimeWritten=YES;
			return;
		}
	}
	char *cString=(char*)[[self string] UTF8String];
	long length=strlen(cString);
	long z=length;
	int tabs=0;
	while (z>=0 && cString[z]!='\r' && cString[z]!='\n')
	{
		if ( cString[z]=='\t')
			tabs++;
		z--;
	};
	if ( tabs < mTabCount)
		[[self string] appendString:[self tabString]];
}

//---------------------------------------------------------------------
// addTab
//---------------------------------------------------------------------
-(void) addTab
{
	[[self tabString] appendString:@"\t"];
	mTabCount++;
}

//---------------------------------------------------------------------
// currentTabs
//---------------------------------------------------------------------
@synthesize currentTabs=mTabCount;

//---------------------------------------------------------------------
// removeTab
//---------------------------------------------------------------------
-(void) removeTab
{
	if ( [[self tabString] length] >0)
	{
		NSRange range=NSMakeRange([[self tabString] length]-1,1);
		[[self tabString] deleteCharactersInRange:range];
		mTabCount--;
	}
}

//---------------------------------------------------------------------
// copyTabAndText
//---------------------------------------------------------------------
-(void) copyTabAndText:(NSString*)string
{
	[self copyTabText];
	[[self string] appendString:string];
}

//---------------------------------------------------------------------
// copyText
//---------------------------------------------------------------------
-(void) copyText:(NSString *) string
{
	[[self string] appendString:string];
}

//---------------------------------------------------------------------
// appendFormat
//---------------------------------------------------------------------
- (void)appendFormat:(NSString *)format, ...
{
	va_list argumentList;
	va_start(argumentList,format);
	[self appendFormat:format arguments:argumentList];
	va_end(argumentList);
}

//---------------------------------------------------------------------
// appendFormat
//---------------------------------------------------------------------
- (void)appendFormat:(NSString *)format arguments:(va_list)args
{
	
	NSString *temp=[[NSString alloc] initWithFormat:format arguments:args];
	[[self string] appendString:temp];
	[temp release];
}

//---------------------------------------------------------------------
// appendTabAndFormat
//---------------------------------------------------------------------
-(void) appendTabAndFormat:(NSString*)format,...
{
	va_list argumentList;
	va_start(argumentList,format);
	[self appendTabAndFormat:format arguments:argumentList];
	va_end(argumentList);
}

//---------------------------------------------------------------------
// appendTabAndFormat
//---------------------------------------------------------------------
-(void) appendTabAndFormat:(NSString*)format arguments:(va_list)args
{
	[self copyTabText];
	NSString *temp=[[NSString alloc] initWithFormat:format arguments:args];
	[[self string] appendString:temp];
	[temp release];
}

//---------------------------------------------------------------------
// addXYZVector:popup:xKey:yKey:zKey
//---------------------------------------------------------------------
-(void) addXYZVector:(NSDictionary*)dict popup:(NSString*)popup xKey:(NSString*)x yKey:(NSString*)y zKey:(NSString*)z
{
	NSString *a=[dict objectForKey:x];
	NSString *b=[dict objectForKey:y];
	NSString *c=[dict objectForKey:z];
	if ( popup==nil) //no popup, simply write vector
	{
		[self appendFormat:@"<%@, %@, %@>",a,b,c];
	}
	else
	{
		switch([[dict objectForKey:popup]intValue])
		{
			case cXYZVectorPopupXisYisZ:
				[self appendFormat:@"<%@, %@, %@>",a,a,a];
				break;
			case cXYZVectorPopupX:
				[self appendFormat:@"<%@, 0.0, 0.0>",a];
				break;
			case cXYZVectorPopupY:
				[self appendFormat:@"<0.0, %@, 0.0>",b];
				break;
			case cXYZVectorPopupZ:
				[self appendFormat:@"<0.0, 0.0, %@>",c];
				break;
			case cXYZVectorPopupXandYandZ:
				[self appendFormat:@"<%@, %@, %@>",a,b,c];
				break;
		}
	}
}


//---------------------------------------------------------------------
// addXYZVector:popup:xKey:yKey:zKey
//---------------------------------------------------------------------
-(void) addScaleVector:(NSDictionary*)dict popup:(NSString*)popup xKey:(NSString*)x yKey:(NSString*)y zKey:(NSString*)z
{
	NSString *a=[dict objectForKey:x];
	NSString *b=[dict objectForKey:y];
	NSString *c=[dict objectForKey:z];
	if ( popup==nil) //no popup, simply write vector
	{
		[self appendFormat:@"<%@, %@, %@>",a,b,c];
	}
	else
	{
		switch([[dict objectForKey:popup]intValue])
		{
			case cXYZVectorPopupXisYisZ:
				[self appendFormat:@"<%@, %@, %@>",a,a,a];
				break;
			case cXYZVectorPopupX:
				[self appendFormat:@"<%@, 1, 1>",a];
				break;
			case cXYZVectorPopupY:
				[self appendFormat:@"<1, %@, 1>",b];
				break;
			case cXYZVectorPopupZ:
				[self appendFormat:@"<1, 1, %@>",c];
				break;
			case cXYZVectorPopupXandYandZ:
				[self appendFormat:@"<%@, %@, %@>",a,b,c];
				break;
		}
	}
}


//---------------------------------------------------------------------
// addRGBColor:forKey:
//---------------------------------------------------------------------
-(void) addRGBColor:(NSDictionary*)dict forKey:(NSString*)key andTitle:(NSString*) title comma:(BOOL)cm newLine:(BOOL)nl
{
	id obj=[dict objectForKey:key];
	if ( obj==nil)
		return;
		
	id well=[NSUnarchiver unarchiveObjectWithData:obj];
	
	if (well==nil)
		return;

	NSColor *cl;
	NSString *rgbString=@"rgb";
	
	BOOL hasFilter=NO;
	BOOL hasTransmit=NO;
	
	if ( [well isMemberOfClass:[MPColorWell class]])
	{
		cl=[well color];
	}
	else if ( [well isMemberOfClass:[MPFTColorWell class]])
	{
		cl=[well color];
		if ([well filterOn]==YES)
		{
			hasFilter=YES;
			rgbString=[rgbString stringByAppendingString:@"f"];
		}
		if ([well transmitOn]==YES)
		{
			hasTransmit=YES;
			rgbString=[rgbString stringByAppendingString:@"t"];
		}
	}
	else
		cl=well;
	cl=[cl colorUsingColorSpaceName:NSDeviceRGBColorSpace];
	if ( cl==nil)
		return;
	[self appendFormat:@"%@%@ <%f, %f, %f", title,rgbString,
																	[cl redComponent],
																	[cl greenComponent],
																	[cl blueComponent]];
	if ( hasFilter==YES)
		[self appendFormat:@", %f",[well filter]];
	if ( hasTransmit==YES)
		[self appendFormat:@", %f",[well transmit]];
				

	[self copyText:@">"];
	if ( cm==YES)
		[self copyText:@","];
	if ( nl==YES)
		[self copyText:@"\n"];

}


//---------------------------------------------------------------------
// dealloc
//---------------------------------------------------------------------
-(void) dealloc
{
	[self setString:nil];
	[self setTabString:nil];
	[super dealloc];
}
@end
