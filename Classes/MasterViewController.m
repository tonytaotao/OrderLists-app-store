//
//  MasterViewController.m
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright 2010 Blackwhale GmbH. All rights reserved.
//

#import "MasterViewController.h"
#import "HistoryDetailViewController.h"
#import "HouseViewController.h"
#import "CalendarViewController.h"
#import "DetailViewController.h"
#import "SoapIPSet.h"
#import "CategorySetting.h"
#import "common.h"

NSMutableArray		*shopNameList;
id masViewController;
//NSMutableArray		*shopKeys;
//NSMutableArray		*shopValues;
//NSMutableDictionary *shopDic;

@implementation MasterViewController

- (void)viewDidLoad 
{
	
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *IsLogin = [[NSUserDefaults standardUserDefaults] objectForKey:@"IsLogin"];
	masViewController = self;
	if([LoginId isEqualToString:ResetName])
		return;
	
	if (shopNameList) 
	{
		shopNameList = nil;
	}
	shopNameList = [[NSMutableArray alloc] init];
//	shopKeys= [[NSMutableArray alloc] initWithObjects:@"shopName",@"DayNightKbn",@"shopId",nil];
//	shopValues=[[NSMutableArray alloc] init];

	
	if ([IsLogin isEqualToString:@"0"]) 
	{
		ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetShopNameList"]]];
		
		[request setRequestMethod:@"POST"];
		[request setPostValue:LoginId forKey:@"UserId"];
		
		[request startSynchronous];
		NSString *str = [request responseString];
		str = [common formateXmlString:str];
		[self parseXml:str];
	}
}

#pragma mark -
//将xml字符串中的某些元素解析
- (void)parseXml: (NSString*)xmlString 
{
	if(0 == [xmlString length])
		return ;
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSMutableArray *shopKeys= [[NSMutableArray alloc] initWithObjects:@"shopName",@"DayNightKbn",@"shopId",nil];
	NSMutableArray *shopValues = [[NSMutableArray alloc] init];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]]) 
		{
//			[shopNameList addObject:[node stringValue]];
			
			CXMLElement *child = [node childAtIndex:0];				//item node
			for (CXMLElement *tmpE in [child children]) 
			{
				if ([tmpE isKindOfClass:[CXMLElement class]]) 
				{
					[shopValues addObject:[tmpE stringValue]];
				}
			}
			if (shopValues.count == 3) 
			{
				NSMutableDictionary *shopDic= [NSMutableDictionary dictionaryWithObjects:shopValues forKeys:shopKeys];
				[shopNameList addObject:shopDic];
				[shopValues removeAllObjects];
			}
		}
		
	}
	[shopKeys release];
	[shopValues release];
}





- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // MUST return YES to allow all orientations
    return YES;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 6;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
	if(section == 0) return 1;
	else if(section == 1) return 1;
	else if(section ==2) return 2;
	else if(section == 3) return shopNameList.count;
	else return 1;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	int iSection = indexPath.section;
	int iRow     = indexPath.row;

	/*   ----  注意start  by chao.tao   ---- 
     
	if(iSection == 0 && iRow==0) {cell.textLabel.text = [NSString stringWithString:@"お客様情報"]; }
	else if(iSection == 1 && iRow==0) {cell.textLabel.text = [NSString stringWithString:@"注文履歴"]; }
	else if(iSection == 2 && iRow==0) {cell.textLabel.text = [NSString stringWithString:@"月のカレンダー(昼)"]; }
	else if(iSection == 2 && iRow==1) {cell.textLabel.text = [NSString stringWithString:@"月のカレンダー(夜)"]; }
        
         ----注意end ----
     */
    if(iSection == 0 && iRow==0) {cell.textLabel.text = @"お客様情報"; }
	else if(iSection == 1 && iRow==0) {cell.textLabel.text = @"注文履歴"; }
	else if(iSection == 2 && iRow==0) {cell.textLabel.text = @"月のカレンダー(昼)"; }
	else if(iSection == 2 && iRow==1) {cell.textLabel.text = @"月のカレンダー(夜)"; }
	else if(iSection ==3)
	{
		NSString	*shopName = [[shopNameList objectAtIndex:indexPath.row] objectForKey:@"shopName"];
		cell.textLabel.text   = shopName;
	}
	else   if(iSection ==4)
	{
		cell.textLabel.text = @"soap IPアドレス設定";
	}
	else   if(iSection ==5)
	{
		cell.textLabel.text = @"料理設定";
	}
//	else 
//	{		
//		CGRect frame = cell.frame;
//		frame.size.width =300;
//		frame.size.height = 200;
//		frame.origin.x = 5;
//		
//		theDatePicker = [[UIDatePicker alloc] initWithFrame:frame];
//		theDatePicker.datePickerMode = UIDatePickerModeDate;		
//
//		
//		//--button Date ---//
//		CGRect btnFrame = frame;
//		btnFrame.size.width = 100;
//		btnFrame.size.height = 40;
//		btnFrame.origin.x= 200;
//		btnFrame.origin.y = frame.origin.x + frame.size.height + 10;
//		
//		UIButton *btnDate = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//		[btnDate setTitle:@"OK" forState:UIControlStateNormal];
//		[btnDate setFrame:btnFrame];
//		[btnDate setBackgroundColor:[UIColor blueColor]];
//		[btnDate addTarget:self action:@selector(calUpdateData) forControlEvents:UIControlEventTouchUpInside]; 
//
//		
//		frame.size.height = 250;
//		UIView  *view = [[UIView alloc] initWithFrame:frame];
//		[view addSubview:theDatePicker];
//		[view addSubview:btnDate];
//		
//		[cell addSubview:view];
//		[theDatePicker release];
//		[view release];
//
//	}

    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//	if (indexPath.section == 3) 
//	{
//		return 270.0;
//	}
	return 50.0;
}


#pragma mark -
#pragma mark Table view delegate

//get the detail controller
UIViewController *detailViewController= nil;

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	//need to remove cell selection 
//	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	if (![common	requestDidError]) 
	{
		return;			
	}
	
	if(self.splitViewController == nil)
		return;
	
	//since we are the master view controller of a split view 
	//we know there is a parent UISplitViewController
	NSArray *controllers = self.splitViewController.viewControllers;
	if([controllers count] < 2)
		return;
	
	//get the detail controller;
	if (detailViewController == nil) {
		detailViewController= [controllers objectAtIndex:1];
	}
//	if (hisPhoneCdNameInfo) 
//	{
//		hisPhoneCdNameInfo=nil;
//	}
//	
//	if (detailPhoneCdNameInfo) 
//	{
//		detailPhoneCdNameInfo=nil;
//	}
	
	//お客様情報
	if(indexPath.section ==0 && indexPath.row == 0)
	{
		DetailViewController *hiVController = [[DetailViewController alloc] initWithNibName:@"Detail" bundle:nil];
		NSArray *defaultControllers = [NSArray arrayWithObjects:self, hiVController, nil];
		self.splitViewController.viewControllers = defaultControllers;
		[hiVController	release];
	}
	else if (indexPath.section ==1 && indexPath.row ==0)
	{//お客様履歴
		HistoryDetailViewController *hisDetailController = [[HistoryDetailViewController alloc] initWithNibName:@"HistoryDetailView" bundle:nil];
		NSArray *newControllers = [NSArray arrayWithObjects:self, hisDetailController, nil];
		
		self.splitViewController.viewControllers = newControllers;
		[hisDetailController release];
	}
	else if(indexPath.section == 2 && indexPath.row ==0)
	{//カレンダー  昼
		CalendarViewController *calController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
		NSArray *calControllers = [NSArray arrayWithObjects:self,calController,nil];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:@"0"]) 
		{
			calController.shopId = @"";
		}
		else
		{
			calController.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		}
		calController.selectShopRow= 0;
		calController.selectShopSection=2;
		
		calController.cIsDayOrNight=@"1";
		self.splitViewController.viewControllers = calControllers;
		[calController release];
	}
	else if(indexPath.section == 2 && indexPath.row ==1)
	{//カレンダー　夜
		CalendarViewController *calController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
		NSArray *calControllers = [NSArray arrayWithObjects:self,calController,nil];
	//	calController.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:@"0"]) 
		{
			calController.shopId = @"";
		}
		else
		{
			calController.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		}
		calController.selectShopRow=1;
		calController.selectShopSection=2;
		
		calController.cIsDayOrNight=@"2";
		self.splitViewController.viewControllers = calControllers;
		[calController release];
	}
	else if (indexPath.section ==3)
	{//店
//		HouseViewController *houseViewController = [[HouseViewController alloc] initWithNibName:@"HouseViewController" bundle:nil];
//		NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
//		
//		formatter.dateFormat = @"yyyy年MM月dd日"; 
//		NSString *timestamp = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]]; 
//		houseViewController.dateString = timestamp;
//		
//	
//		NSArray *hoControllers = [NSArray arrayWithObjects:self,houseViewController,nil];
//		self.splitViewController.viewControllers = hoControllers;
//		[houseViewController release];
		

		CalendarViewController *calController = [[CalendarViewController alloc] initWithNibName:@"CalendarViewController" bundle:nil];
		calController.cIsDayOrNight= [[shopNameList objectAtIndex:indexPath.row] objectForKey:@"DayNightKbn"];
		calController.shopId = [[shopNameList objectAtIndex:indexPath.row] objectForKey:@"shopId"];
		
		
		NSInteger rowIndex = [indexPath indexAtPosition: 1];
		calController.selectShopRow = rowIndex;			    //indexPath.row;
		calController.selectShopSection=3;
		NSArray *calControllers = [NSArray arrayWithObjects:self,calController,nil];
		
		self.splitViewController.viewControllers = calControllers;
		[calController release];
		
	}
	else if(indexPath.section ==4)
	{
		SoapIPSet *soapIPControl = [[SoapIPSet alloc] initWithNibName:@"SoapIPSet" bundle:nil];
		NSArray *soapControllers = [NSArray arrayWithObjects:self,soapIPControl,nil];
		
		self.splitViewController.viewControllers = soapControllers;
		[soapIPControl release];
	}
	else if(indexPath.section==5)
	{
		CategorySetting *cateSet=[[CategorySetting alloc] initWithNibName:@"CategorySetting" bundle:nil];
		//cateSet.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"] isEqualToString:@"0"]) 
		{
			cateSet.shopId = @"";
		}
		else
		{
			cateSet.shopId = [[NSUserDefaults standardUserDefaults] objectForKey:@"ShopId"];
		}
		cateSet.delegate=self;
		
		[self presentModalViewController:cateSet animated:YES];
		[cateSet release];
 
	}
}

- (void)CategorySettingDidClose:(CategorySetting *)controller
{
	[self dismissModalViewControllerAnimated:YES];
}

//click the calendar ok button
//- (void)calUpdateData
//{
//	HouseViewController *houseViewController = [[HouseViewController alloc] initWithNibName:@"HouseViewController" bundle:nil];
//	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
//	formatter.dateFormat = @"yyyy年MMMMdd日"; 
//	NSString *timestamp = [formatter stringFromDate:theDatePicker.date]; 
//	houseViewController.dateString = timestamp;
//	
//	
//	NSArray *hoControllers = [NSArray arrayWithObjects:self,houseViewController,nil];
//	self.splitViewController.viewControllers = hoControllers;
//	[houseViewController release];
//	
//	NSLog(@"calendar down......");
//}


#pragma mark -
#pragma mark Memory management

//liukeyu add 2011-07-08 start
+ (MasterViewController*) getTableViewController
{
	return masViewController;
}

- (void) changeView:(int)indexRow iSection:(int)section 
{
// if (indexRow==0 && section==1)
// {
//		HistoryDetailViewController *hisDetailController = [[HistoryDetailViewController alloc] initWithNibName:@"HistoryDetailView" bundle:nil];
//		NSArray *newControllers = [NSArray arrayWithObjects:self, hisDetailController, nil];
//		self.splitViewController.viewControllers = newControllers;
//		[hisDetailController release];
//	}
//	else 
//	{
//		DetailViewController *hiVController = [[DetailViewController alloc] initWithNibName:@"Detail" bundle:nil];
//		NSArray *defaultControllers = [NSArray arrayWithObjects:self, hiVController, nil];
//		self.splitViewController.viewControllers = defaultControllers;
//		[hiVController	release];
//	}
	[self tableView:(UITableView *)self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:section]];
	[self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:indexRow inSection:section] animated:FALSE scrollPosition:UITableViewScrollPositionMiddle];
}
//liukeyu add 2011-07-08 end

- (void)dealloc {
    [super dealloc];
}


@end

