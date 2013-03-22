    //
//  CalendarViewController.m
//  OrderList
//
//  Created by fly on 10/12/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalendarViewController.h"

//houseView画面を表示の為に
#import "HouseViewController.h"
#import "MasterViewController.h"
#import "CustomUISplitViewController.h"
#import "common.h"

@implementation CalendarViewController
@synthesize shopId,selectShopRow,selectShopSection;
@synthesize cIsDayOrNight;


ASIFormDataRequest *request;

#pragma mark --select the Date--
- (void) selectDateChanged:(CFGregorianDate) selectDate
{
//	NSLog(@"--------------------------------------selectDateChanged selectShoprow %d -----selectShopSection %d-----------------------------------------",selectShopRow,selectShopSection);
		
		if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:@"0"] && 
						![[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:self.shopId]) 
		{
			return;
		}
	
	if (![common	requestDidError]) 
	{
		return;			
	}
	CustomUISplitViewController *csplitViewController = (CustomUISplitViewController *)[self parentViewController];       //CustomUISplitViewController
	NSArray						*controllers		  = [csplitViewController viewControllers];
																	 //SplitViewDelegate
	
	MasterViewController *masterView = [controllers objectAtIndex:0];						//MasterViewController
	UITableView *tableView = [masterView tableView];
	
	HouseViewController *houseViewController = [[HouseViewController alloc] initWithNibName:@"HouseViewController" bundle:nil];
	
//	NSLog(shopId);
	if ([shopId isEqualToString:@""]) 
	{
		houseViewController.userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
		houseViewController.shopId =@"";
		
		if(selectShopRow ==0  && selectShopSection ==0)
			selectShopRow =1;selectShopSection=2;
		
		[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectShopRow inSection:selectShopSection] animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
	else 
	{
		houseViewController.userId =@"";
		houseViewController.shopId =shopId;
		[tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectShopRow inSection:selectShopSection] animated:YES scrollPosition:UITableViewScrollPositionNone];
	}
	NSString	*strVisiteDate=   [NSString stringWithFormat:@"%d/%d/%d",selectDate.year,selectDate.month,selectDate.day];
	houseViewController.VisitDate = strVisiteDate;
	houseViewController.hIsDayOrNight=self.cIsDayOrNight;
	//----------------------------------------------------------------------------------------------
	
	houseViewController.memoStr = [self calendarMemo:houseViewController.VisitDate];
	NSString *timestamp = [NSString stringWithFormat:@"%d年%d月%d日",selectDate.year,selectDate.month,selectDate.day]; 
	houseViewController.dateString = timestamp;
	
	
	NSArray *hoControllers = [NSArray arrayWithObjects:masterView,houseViewController,nil];
	masterView.splitViewController.viewControllers = hoControllers;
	[houseViewController release];
	
}

//- (NSString *)getShopId
//{
//	if (shopId)
// {
//		if ([self.shopId isEqualToString:@""])
//		{
//			return @"0";
//		}
//		else
//		{
//			 if ([self.shopId intValue] >0)
//				{
//					return self.shopId;
//				}
//		}
//	}
//	return nil;
//}


#pragma mark --カレンダー 月の人数と組--
- (NSArray *)getCalendarMonthPeopleData:(NSString *)calDate
{
	NSString *loginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	if ([shopId isEqualToString:@""]) 
	{
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCalendarMonthData"]]];
	}
	else 
	{
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCalendarMonthDataWithShopId"]]];
		[request setPostValue:shopId forKey:@"shopId"];
	}
	
	[request setPostValue:loginId forKey:@"UserId"];
	[request setPostValue:calDate forKey:@"VisitYearMonth"];
	[request setPostValue:cIsDayOrNight forKey:@"dayNightKbn"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	if(!str)
		return NULL;
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//item" error:&error];
	
	[xmlDoc	release];
	return resultNodes;
}



#pragma mark -- 組の数量と人数を表示する --
- (void)drawPeopleCountWords:(CGPoint)groupCount  personCount:(CGPoint)peopleCount team:(DDXMLNode *)team
{
	UIFont *weekfont=[UIFont boldSystemFontOfSize:12];
	NSArray *itemArrs = [team children];
	if(itemArrs.count==0)
		return;
	
//	NSString *vDate = [[itemArrs objectAtIndex:0] stringValue];				//vDate
	NSString *strcustomerCount = [[itemArrs objectAtIndex:1] stringValue];		//customerCount
	NSString *strgroupCount = [[itemArrs objectAtIndex:2] stringValue];		//groupCount

	if(![strgroupCount isEqualToString:@""])
	{
		[[strcustomerCount stringByAppendingString:@"人"]drawAtPoint:peopleCount withFont:weekfont];
		[[strgroupCount stringByAppendingString:@"組"] drawAtPoint:groupCount withFont:weekfont];
	}
	
}



//--------------------------------------------------------------------------------------------------------------------

#pragma mark --カレンダー 月のメモのデータをとる--
- (NSArray *)getCalendarMonthMemoData:(NSString *)calDate
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,calDate,cIsDayOrNight];
	
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetMonthMemo"]]];
	[request setPostValue:strPost forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
	{
		NSLog(@"%@",[error localizedDescription]);
		[xmlDoc	release];
		return NULL;
	}
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//memoContent" error:&error];
	
	[xmlDoc	release];
	
	return resultNodes;
	
}



#pragma mark --実装 カレンダメモの色を表示--
- (void)drawCalendarMemoColor:(CGContextRef)context  dayMemo:(NSString *)dayMemo startPosX:(CGFloat)_startPosX startPosY:(CGFloat)_startPosY endPosX:(CGFloat)_endPosX endPosY:(CGFloat)_endPosY
{	
	CGContextSetRGBFillColor(context, 0.0, 1.0, 0.5, 1.0);										//rgba
	
	if (![dayMemo isEqualToString:@""]) //memo
	{
		CGContextMoveToPoint(   context, _startPosX,   _startPosY);								//itemHeight 45;headHeight 60
		CGContextAddLineToPoint(context, _endPosX,	   _startPosY);
		
		CGContextAddLineToPoint(context, _endPosX,     _endPosY);
		CGContextAddLineToPoint(context, _startPosX,   _endPosY);
		
		CGContextFillPath(context);
	}
	
}



#pragma mark --カレンダーのメモをとる--
- (NSString *)calendarMemo:(NSString *)calDate
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,calDate,cIsDayOrNight];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetDayMemoByDay"]]];
	[request setPostValue:strPost forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	NSString *strMemo = [NSString stringWithString:@""];
	if ([theDoc childCount] >0) //memo
	{
		strMemo = [theDoc stringValue];
	}
	
	return strMemo;
	
}



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
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	if([cIsDayOrNight length]==0)
		cIsDayOrNight=@"2";

}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
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


- (void)dealloc 
{
	[cIsDayOrNight release];
	[shopId release];
    [super dealloc];
}


@end
