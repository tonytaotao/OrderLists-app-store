//
//  MasterDetailAppDelegate.m
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright Blackwhale GmbH 2010. All rights reserved.
//

#import "MasterDetailAppDelegate.h"
#import "MasterViewController.h"
#import "CalendarViewController.h"
#import "SplitViewDelegate.h"
#import "common.h"
#import "SoapIPSet.h"

@implementation MasterDetailAppDelegate

@synthesize window;
@synthesize spViewController;
@synthesize loginViewController;

MasterViewController *masterView;
CalendarViewController *calView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
	
//	[[NSUserDefaults standardUserDefaults] setObject:@"LoginId" forKey:@""];
//	[[NSUserDefaults standardUserDefaults] setObject:@"IsLogin" forKey:@"1"];
	
	
	
	self.loginViewController = [[LoginView alloc] initWithNibName:@"LoginView" bundle:nil];
	self.loginViewController.delegate = self;
	[window addSubview:self.loginViewController.view];
	[window makeKeyAndVisible];
	
	
	
//	//create the master view
//	masterView = [[MasterViewController alloc]
//										initWithNibName:@"Master"
//										bundle:[NSBundle mainBundle]];
//	
//	//create the details view
//	calView = [[CalendarViewController alloc]
//									   initWithNibName:@"CalendarViewController"
//									   bundle:[NSBundle mainBundle]];
//	
//	self.spViewController = [[CustomUISplitViewController alloc] initWithMasterInPortraitMode: NO];
	//spViewController.viewControllers = [NSArray arrayWithObjects:masterView, calView, nil];
//	
//	//create and set the split view delegate
//	SplitViewDelegate* splitViewDelegate = [[SplitViewDelegate alloc] init];
//	splitViewDelegate.detailController = calView;
//	
//	
//	spViewController.delegate = splitViewDelegate;
//	
//	
//	
//	
//	
//	[masterView release];
//	[calView release];
//	[window makeKeyAndVisible];
	
	return YES;
}


//login success then show the main view
- (void) addViewControllDidFinishConform:(LoginView *)controller
{	
	
	//create the master view
	MasterViewController *masterView = [[MasterViewController alloc]
										initWithNibName:@"Master"
										bundle:nil];
	
	
	if ([controller.loginID.text isEqualToString:ResetName] && [controller.loginPwd.text isEqualToString:ResetName]) 
	{
		SoapIPSet *soapIPControl = [[SoapIPSet alloc] initWithNibName:@"SoapIPSet" bundle:nil];
		self.spViewController = [[CustomUISplitViewController alloc] initWithMasterInPortraitMode: NO];
		self.spViewController.viewControllers = [NSArray arrayWithObjects:masterView, soapIPControl, nil];
		
		SplitViewDelegate* splitViewDelegate = [[SplitViewDelegate alloc] init];
		splitViewDelegate.detailController = soapIPControl;
		self.spViewController.delegate = splitViewDelegate;
		
		
		[soapIPControl.view setFrame:CGRectMake(321, 0, 700, 748)];
		[window addSubview:self.spViewController.view];
		
		
		[self.loginViewController.view removeFromSuperview];
		[masterView release];
		[soapIPControl release];
		
		
	}
	else 
	{
		//create the details view
		CalendarViewController *calView = [[CalendarViewController alloc]
										   initWithNibName:@"CalendarViewController"
										   bundle:nil ];	//[NSBundle mainBundle]];  //1024;748
    
		//calView.shopId = @"";
		
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:@"0"]) 
		{
			calView.shopId = @"";
		}
		else
		{
			calView.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		}
		
		self.spViewController = [[CustomUISplitViewController alloc] initWithMasterInPortraitMode: NO];
		self.spViewController.viewControllers = [NSArray arrayWithObjects:masterView, calView, nil];
		
		//create and set the split view delegate
		SplitViewDelegate* splitViewDelegate = [[SplitViewDelegate alloc] init];
		splitViewDelegate.detailController = calView;
		self.spViewController.delegate = splitViewDelegate;
		
		
		
		[calView.view setFrame:CGRectMake(321, 0, 700, 748)];
		[window addSubview:self.spViewController.view];
		
		
		[self.loginViewController.view removeFromSuperview];
		[masterView release];
		[calView release];
		
	}
		
	[window makeKeyAndVisible];

}

-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[common showErrorAlert:@"ReceiveMemoryWarning!"];
}

- (void)dealloc 
{
    [loginViewController release];
    [spViewController release];
    [masterView release];
    [calView release];
    [window release];
    [super dealloc];
}


@end
