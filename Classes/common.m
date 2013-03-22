//
//  common.m
//  OrderList
//
//  Created by fly on 10/11/11.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "common.h"

@implementation common

+ (void)showErrorAlert:(NSString *)err
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:err delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+ (void)showSuccessAlert:(NSString *)msg
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[alert show];
	[alert release];
}


+ (NSString	*)formatCntStr:(NSString *)str Count:(NSInteger)count
{
	
	if([str length]>=count)
	{
		str=[str substringToIndex:count];
	}
	else 
	{
		int retainCount=count-[str length];
		NSString	*whiteSpace=@"";
		
		
		NSScanner      *scanner = [NSScanner scannerWithString:str];
		NSCharacterSet *charactersToCount = [NSCharacterSet	characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyz1234567890"];
		NSString       *tmp;
		if(([scanner scanCharactersFromSet:charactersToCount intoString:&tmp]))
		{
			whiteSpace=@" ";
		}
		else 
		{
			whiteSpace=@"  ";
		}

			
			
		for (int i=0; i<retainCount; i++) 
		{
			str = [str stringByAppendingString:whiteSpace];
		}
	}
	return str;

}


+ (NSString *)formateXmlString:(NSString *)htmlString
{
	//&lt; <
	NSMutableString *strht = [htmlString stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
	strht= [strht stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
	return strht;
}

+ (NSString *)serverSoapIp
{
	
	NSArray		*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	*directory=[paths	objectAtIndex:0];
	
	NSString		*filePath=[[NSString	alloc] initWithString:[directory stringByAppendingPathComponent:@"Server.plist"]];
	NSFileManager	*fileManager=[NSFileManager	defaultManager];
	
	if([fileManager fileExistsAtPath:filePath])
	{
		//读取到一个NSDictionary
		NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
		NSString *serverIP = [dictionary valueForKey:@"ServerIP"];
		
		serverIP = [serverIP stringByAppendingString:@"/"];
		
		[dictionary release];
		[filePath	release];
		return serverIP;
	}
	else 
	{
		NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
		[dict setValue:soapIP forKey:@"ServerIP"];
		[dict writeToFile:filePath atomically:NO];
		
		[filePath	release];
		[dict	release];
		return	[soapIP	stringByAppendingString:@"/"];
	}
}

+ (BOOL)requestDidError
{
	ASIFormDataRequest  *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[common serverSoapIp]]];
	
	[request startSynchronous];
	
	NSError	*error	=	[request	error];
	if (error) {
		[self	showErrorAlert:@"ネットワークを確認してください。"];
		return	FALSE;
	}else {
		return	YES;
	}
}
@end
