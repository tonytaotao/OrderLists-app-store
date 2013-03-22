    //
//  SoapIPSet.m
//  OrderLists
//
//  Created by fly on 11/02/28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SoapIPSet.h"
#import "common.h"

@implementation SoapIPSet
@synthesize soapIPTextField;

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[soapIPTextField resignFirstResponder];
	return YES;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	[self getIP];
}


//soap IPをとる
- (void)getIP
{
	
	NSArray		*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	*directory=[paths	objectAtIndex:0];
	
	NSString		*filePath=[[NSString	alloc] initWithString:[directory stringByAppendingPathComponent:@"Server.plist"]];
	NSFileManager	*fileManager=[NSFileManager	defaultManager];
	
    NSLog(@"%@",filePath);   //by chao.tao
    
	if([fileManager fileExistsAtPath:filePath])
	{
		//读取到一个NSDictionary
		NSDictionary *serverInfoDic = [NSDictionary dictionaryWithContentsOfFile:filePath];
		soapIPTextField.text = [serverInfoDic objectForKey:@"ServerIP"];
	}
	else 
	{
			NSMutableDictionary *soapDict=[[NSMutableDictionary alloc]init];
			[soapDict setValue:soapIP forKey:@"ServerIP"];
			[soapDict writeToFile:filePath atomically:NO];
			[soapDict	release];
	}

	[filePath	release];
}


//soap IP 設定する
-(IBAction)btnSet:(id)sender
{
	NSArray		*paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString	*directory=[paths	objectAtIndex:0];
	
	NSString		*filePath=[[NSString	alloc] initWithString:[directory stringByAppendingPathComponent:@"Server.plist"]];
	NSFileManager	*fileManager=[NSFileManager	defaultManager];
	
	if([fileManager fileExistsAtPath:filePath])
	{
		//读取到一个NSDictionary
		NSMutableDictionary* serverInfoDic = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
		
		[serverInfoDic setValue:soapIPTextField.text forKey:@"ServerIP"];
		[serverInfoDic writeToFile:filePath atomically:NO];
		
		[common showSuccessAlert:@"Sucess!"];
	}
	[filePath	release];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[soapIPTextField release];
    [super dealloc];
}


@end
