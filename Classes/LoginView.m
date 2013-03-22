    //
//  LoginView.m
//  MasterDetail
//
//  Created by fly on 10/11/02.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "LoginView.h"
#import "common.h"

//#import "ASIHTTPRequest.h"
//#import "ASIFormDataRequest.h"
//#import <SystemConfiguration/SystemConfiguration.h>
//#import "TouchXML.h"

@implementation LoginView
@synthesize loginID,loginPwd;
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/



- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}


//login action
- (IBAction)Login:(id)sender
{	
	if ( loginID.text.length == 0 ) 
	{
		UIAlertView *alert = [[UIAlertView alloc]  
							  initWithTitle:nil
							  message:@"ログインIDを入力して下さい。"  
							  delegate:self  
							  cancelButtonTitle:@"OK"  
							  otherButtonTitles:nil, nil];  
		[alert show];  
		[alert release];
	} 
	else if ( loginPwd.text.length == 0 ) 
	{
		UIAlertView *alert = [[UIAlertView alloc]  
							  initWithTitle:nil
							  message:@"パスワードを入力して下さい。"  
							  delegate:self  
							  cancelButtonTitle:@"OK"  
							  otherButtonTitles:nil, nil];  
		[alert show];  
		[alert release];
	}
	else 
	{
		
		if ([loginID.text isEqualToString:ResetName] && [loginPwd.text isEqualToString:ResetName]) //soap it 設定用
		{
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			[defaults setObject:@"0" forKey:@"IsLogin"];
			[defaults setObject:ResetName forKey:@"LoginId"];
			
			[delegate addViewControllDidFinishConform:self];
			return;
		}
		
        NSLog(@"%@",[common serverSoapIp]);
        
		//activityIndicator.startAnimating;
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"CheckUser"]]];
		
		[request setRequestMethod:@"POST"];
		[request setPostValue:loginID.text forKey:@"UserId"];
		[request setPostValue:loginPwd.text forKey:@"UserPassword"];
		[request setDidFailSelector:@selector(asyncFail:)];
		[request setDidFinishSelector:@selector(asyncSuccess:)];
		
		[[NSUserDefaults standardUserDefaults] setObject:loginID.text forKey:@"LoginId"];
		
		[request startAsynchronous];
		[request setDelegate:self];
	}
}

- (void)asyncFail:(ASIHTTPRequest *)request
{	
	NSError *error = [request error];
	[common showErrorAlert:(NSString *)[error description]];
//	NSLog( (NSString *)[error description]);
}

- (void)asyncSuccess:(ASIHTTPRequest *)request
{	
	NSString *str = [request responseString];	
	NSString *result = [self parseXml:str];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([result isEqualToString:@"0"]) 
	{
		[defaults setObject:@"0" forKey:@"IsLogin"];
		//NSString *userID = loginID.text; 
		if ([self	getShopIdByUserId:loginID.text]) 
		{
			[delegate addViewControllDidFinishConform:self];
		}
	}
	else if([result isEqualToString:@"1"])
	{
		[defaults setObject:@"1" forKey:@"IsLogin"];
		[defaults setObject:@"" forKey:@"LoginId"];
		[common showErrorAlert:@"ログインID  あるいは パスワードをチェックして下さい。"];                    
	}
	else 
	{
		[defaults setObject:@"1" forKey:@"IsLogin"];
		[defaults setObject:@"" forKey:@"LoginId"];
		[common showErrorAlert:@"Error！"];
	}

}

//liukeyu add start 20110711
- (BOOL) getShopIdByUserId:(NSString	*)UserId
{
	ASIFormDataRequest *shopRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetShopIDByUser"]]];
	
	[shopRequest setRequestMethod:@"POST"];
	[shopRequest setPostValue:UserId forKey:@"UserId"];
	
	[shopRequest startSynchronous];
	
	NSString *str = [shopRequest responseString];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
		
	NSString *shopID = [[xmlDoc childAtIndex:0] stringValue];
	if ([shopID intValue] < 0)
 {
		[common showErrorAlert:@"Error！"];
		[xmlDoc release];
		return FALSE;
	}
	[[NSUserDefaults standardUserDefaults] setObject:shopID forKey:@"ShopId"];
	[xmlDoc release];
	return TRUE;
}
//liukeyu add end 20110711

#pragma mark -
//将xml字符串中的某些元素解析
- (NSString *) parseXml: (NSString*)xmlString 
{
	if(0 == [xmlString length])
		return nil;
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theElement = [doc rootElement];
	NSString *strE = [theElement stringValue];
	
	return strE;
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[loginID release];
	[loginPwd release];
    [super dealloc];
}


@end
