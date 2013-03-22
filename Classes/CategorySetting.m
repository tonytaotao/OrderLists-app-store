    //
//  CategorySetting.m
//  OrderLists
//
//  Created by fly on 11/03/07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CategorySetting.h"
#import "common.h"

@implementation CategorySetting
@synthesize _tableView;
@synthesize _leftScrollView;
@synthesize _topScrollView;
@synthesize _contentScrollView;
@synthesize records;
@synthesize shopId;
@synthesize delegate;


ASIFormDataRequest *request;
NSMutableArray *leftConditions;			//leftボタンのcategoryCD
NSMutableArray *topConditions;			//topボタンのcategoryCD
NSMutableArray *topParentConditions;	//topの父categoryCD
NSMutableArray *itemFoodCD;				//itemsのfoodCD



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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self._tableView setEditing:YES animated:YES];
	self._tableView.allowsSelectionDuringEditing = YES;
	
	[_leftScrollView setContentSize:CGSizeMake(LeftScrollViewWidth, 850)];
	[_topScrollView setContentSize:CGSizeMake( 1500, TopScrollViewHeight)];
	[_contentScrollView setContentSize:CGSizeMake(ContentScrollViewWidth, 500)];
	
	if (nil ==records)
	{
		if (records)
		{
			[records release];
		}
		records = [[NSMutableArray alloc] init];
	}
	
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	if([uid	isEqualToString:ResetName])
		return;
	
	[self initLayoutScroll];
	[self getCategoryInfo];
	[_tableView reloadData];
}

//--------------------------------レイアウト　初期化--------------------------------
- (void)initLayoutScroll
{
	[self layoutLeftScroll:@"All"];
	[self layoutTopScroll:@"All"];
	[self layoutContentScroll];
}

#pragma mark -- left buttons --
//-----------------------------left buttons---------------------------
//条件によって、データを検索leftボータンを作成する
-(void)layoutLeftScroll:(NSString *)leftCondition
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCategoy2List"]]];
	[request setPostValue:@"All" forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parseLeftXml:str];
}


- (void)parseLeftXml: (NSString*)xmlString
{
	leftConditions = [[NSMutableArray alloc] init];
	int lci=0;
	
	int y_pos = 5;
	UIFont *leftFont = [UIFont systemFontOfSize:10];
	
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{	
			
			CXMLNode *strItem = [node childAtIndex:0]; //string
			
			CGRect btnFrame = CGRectMake(3, y_pos, 72, 58);
			UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
			
			[leftButton setFrame:btnFrame];
			[leftButton setTitle:[[strItem childAtIndex:2] stringValue] forState:UIControlStateNormal];
			//[leftButton setFont:leftFont]; //change by chao.tao  because 这种方法在IOS3.0以上的版本就不赞成了（しないこのメソッドのバージョンの賛成でIOS3.0以上）
			leftButton.titleLabel.font = leftFont;
            
			NSString *categoryCD = [[strItem childAtIndex:0] stringValue];
			[leftConditions addObject:categoryCD];
			
			leftButton.tag = lci;
			[leftButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:3] stringValue]]];
			[leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
			[leftButton addTarget:self action:@selector(leftButtonDbClick:) forControlEvents:UIControlEventTouchDownRepeat];
			
			[leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			[leftButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
			
			[_leftScrollView addSubview:leftButton];
			y_pos += 61;
			lci++;
		}
	}
}

//leftボタンをクリック、topボタンの表示を更新
- (IBAction)leftButtonClick:(id)sender
{
	NSString *_leftCondition = [leftConditions objectAtIndex:[sender tag]];
	[self layoutTopScroll:_leftCondition];
//	NSLog(@"------leftCondition %@ ------",_leftCondition);
	
	
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *condition = [NSString stringWithFormat:@"%@;%@;%@;%@",uid, _leftCondition,@"ChildAll",shopId];
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetItemList"]]];
	[request setPostValue:condition forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parseItemsXml:str];
}



- (IBAction)leftButtonDbClick:(id)sender
{
	return;
/*	NSString *_CD = [leftConditions objectAtIndex:[sender tag]];
	NSString *_Title=[sender currentTitle];
	
	if ([self isNotExist:_CD]) 
	{
		NSArray *Keys   = [NSArray arrayWithObjects:@"_CD",@"_Title",nil];
		NSArray *Values = [NSArray arrayWithObjects:_CD,_Title, nil];
		
		NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithObjects:Values forKeys:Keys];
		
		[records addObject:dit];
		[dit release];
		
		[self	SortData];
		[_tableView reloadData];
	}
*/	
}

#pragma mark -- top buttons --
//-----------------------------top buttons--------------------------------
//条件によって、データを検索topボタンを作る
- (void)layoutTopScroll:(NSString *)topCondition
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCategoy3List"]]];
	[request setPostValue:topCondition forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parseTopXml:str];
	
}

- (void)parseTopXml:(NSString *)topXmlString
{
	topConditions=nil;
	topParentConditions=nil;
	if (topConditions) 
	{
		[topConditions release];
	}
	if (topParentConditions)
 {
		[topParentConditions release];
	}
	topConditions =		  [[NSMutableArray alloc] init];
	topParentConditions = [[NSMutableArray alloc] init];
	int tci = 0;
	
	int x_pos = 2;
	UIFont *leftFont = [UIFont systemFontOfSize:10];
	[self viewsClear:_topScrollView];						//TopView 初期か
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: topXmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{	
			
			CXMLNode *strItem = [node childAtIndex:0]; //string
			
			CGRect btnFrame = CGRectMake(x_pos, 7, 72, 58);
			UIButton *topButton = [UIButton buttonWithType:UIButtonTypeCustom];
			
			[topButton setFrame:btnFrame];
			[topButton setTitle:[[strItem childAtIndex:2] stringValue] forState:UIControlStateNormal];
			//[topButton setFont:leftFont];   //change by chao.tao
            topButton.titleLabel.font = leftFont;
            
			NSString *categoryCD = [[strItem childAtIndex:0] stringValue]; 
			[topConditions addObject:categoryCD];
			
			NSString *parentCategoryCD= [[strItem childAtIndex:1] stringValue];
			[topParentConditions addObject:parentCategoryCD];
			
			topButton.tag = tci;
			[topButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:3] stringValue]]];
			[topButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
			[topButton	addTarget:self action:@selector(topButtonDbClick:) forControlEvents:UIControlEventTouchDownRepeat];
			
			[topButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[topButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			
			[_topScrollView addSubview:topButton];
			x_pos += 73;
			tci++;
		}
	}
	
}



//topボタンをクリック、itemsの表示を更新
-(IBAction)topButtonClick:(id)sender
{
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *_topCondion = [topConditions	objectAtIndex:[sender tag]];
	NSString *_topParentCondion= [topParentConditions objectAtIndex:[sender tag]];
	NSString *condition = [NSString stringWithFormat:@"%@;%@;%@;%@",uid, _topParentCondion,_topCondion,shopId];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetItemList"]]];
	[request setPostValue:condition forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parseItemsXml:str];
}

-(IBAction)topButtonDbClick:(id)sender
{
	NSString *_CD = [topConditions	objectAtIndex:[sender tag]];
	NSString *_Title=[sender currentTitle];
	
	if ([self isNotExist:_CD]) 
	{
		NSArray *Keys   = [NSArray arrayWithObjects:@"_CD",@"_Title",nil];
		NSArray *Values = [NSArray arrayWithObjects:_CD,_Title, nil];
		
		NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithObjects:Values forKeys:Keys];
		
		[records addObject:dit];
		[dit release];
		
		[self	SortData];
		[_tableView reloadData];
	}
}


//--------------------------------content buttons-------------------------------
//top条件によって
- (void)layoutContentScroll
{
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *condition = [NSString stringWithFormat:@"%@;%@;%@;%@", uid,@"All",@"ChildAll",@"" ];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetItemList"]]];
	[request setPostValue:condition forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parseItemsXml:str];
}

- (void)parseItemsXml:(NSString *)itemsXmlString
{
	itemFoodCD = [[NSMutableArray alloc] init];			//item's array 初期かする
	int x_pos = 3;
	int y_pos = 2;
	int cci = 0;
	UIFont *leftFont = [UIFont systemFontOfSize:10];
	[self viewsClear:_contentScrollView];						//ContentView 初期か
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: itemsXmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{	
			
			CXMLNode *strItem = [node childAtIndex:0];				//string
			
			CGRect btnFrame = CGRectMake(x_pos, y_pos, 100, 60);
			UIButton *contentButton = [UIButton buttonWithType:UIButtonTypeCustom];
			[contentButton setFrame:btnFrame];
			//[contentButton setFont:leftFont];
			contentButton.titleLabel.font = leftFont;
            
			NSString *btnTitle = [NSString stringWithFormat:@"%@\r\n%@円",[[strItem childAtIndex:3] stringValue] ,[[strItem childAtIndex:4] stringValue]] ;
			[contentButton setTitle:btnTitle forState:UIControlStateNormal];
			[contentButton setLineBreakMode:UILineBreakModeCharacterWrap];
            //contentButton.lineBreakMode = NSLineBreakByCharWrapping;  // did not change by chao.tao need use UILable
			[contentButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[contentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
			
			
			NSString *itemCD = [[strItem childAtIndex:1] stringValue];
			[itemFoodCD addObject:itemCD];
			contentButton.tag = cci;
			
			[contentButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:5] stringValue]]];

			
			[contentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			[contentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
			
			[_contentScrollView addSubview:contentButton];
			x_pos += 108;
			
			if (x_pos > 108*8) //7個改行する
			{
				y_pos += 63;
				x_pos = 3;
			}
			cci += 1;
			
		}
	}
	
}




//-------------------------------コンポーネントを初期化--------------------------------------
- (void)viewsClear:(UIView *)reLayoutView
{
	for (UIView *tmpView in [reLayoutView subviews]) 
	{
		[tmpView removeFromSuperview];
	}
}

//カーラをとる
-(UIColor *)parseColor:(NSString *)strColor
{
	NSArray *colorArr = [strColor componentsSeparatedByString:@";"];
	if(colorArr.count<4){};
		//return;
	
	float alph = [[colorArr objectAtIndex:0] floatValue];
	float red = [[colorArr objectAtIndex:1] floatValue];
	
	float green= [[colorArr objectAtIndex:2] floatValue];
	float blue = [[colorArr objectAtIndex:3] floatValue];
	
	
	UIColor *color    = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alph/255.0];
	if (alph==0 && red ==0 && green ==0 && blue ==0) {
		color = [UIColor whiteColor];
	}
	return color;
}





- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return records.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//用来标识窗格为一个普通窗格
	static NSString *MyIdentifierOrderConfirm = @"OrderConfirmCellIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifierOrderConfirm];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifierOrderConfirm] autorelease];
    }
	cell.textLabel.text=[[records	objectAtIndex:indexPath.row] valueForKey:@"_Title"];
		
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}



- (void)setEditing:(BOOL)editing animated:(BOOL)animated 
{
    [super setEditing:editing animated:animated];
    [_tableView setEditing:editing animated:animated];
    // do further tasks below
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return TRUE;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
		[records removeObjectAtIndex:indexPath.row];
		
		// remove the row from the table
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		
	} 
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}



//close this view
- (IBAction)btnClose:(id)sender
{
	[delegate CategorySettingDidClose:self];
}


//料理を設定する
- (IBAction)btnOK:(id)sender
{
	NSMutableString *strCD=[NSMutableString stringWithString:@""];
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	strCD=[strCD	stringByAppendingString:LoginId];
	for (int i=0; i<records.count; i++) 
	{
		NSDictionary *dic=[records objectAtIndex:i];
		strCD=[strCD stringByAppendingFormat:@";%@",[dic valueForKey:@"_CD"]];
	}
	
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateItemInfo"]]];
	
	[request setRequestMethod:@"POST"];
	[request setPostValue:strCD forKey:@"updateInfo"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
//	id cc =[xmlDoc	stringValue];
	if([@"true" isEqualToString:[[xmlDoc childAtIndex:0] stringValue]])
	{
		[common showSuccessAlert:@"Success"];
		[xmlDoc	release];
		[delegate CategorySettingDidClose:self];
	}
	else
	{
		[common showErrorAlert:@"失敗しました！"];
		[xmlDoc	release];
	}
	
}


//もし存在の場合はrecordsを追加しない
-(BOOL)isNotExist:(NSString *)_CDStr
{
	for (int i=0; i<records.count; i++) 
	{
		NSString	*title=[[records objectAtIndex:i] valueForKey:@"_CD"];
		if([title isEqualToString:_CDStr])
			return FALSE;
	}
	return TRUE;
}

//メニューをソートする
-(void)SortData
{
	//sort
	NSUInteger rcount = [records count];
	NSMutableArray *tmpArr = [[NSMutableArray alloc] init];
	
	for (int i=rcount-1; i>=0; i--) 
	{
		[tmpArr addObject:[records objectAtIndex:i]];
	}
	
	[records removeAllObjects];
	[records setArray:tmpArr];
	[tmpArr release];
}


//もう設定しましたのカテゴリをとる
- (void)getCategoryInfo
{
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"SelectItemInfo"]]];
	[request setPostValue:uid forKey:@"UserId"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];

	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//item" error:&error];
	[xmlDoc	release];
	
	for (int i=0; i<resultNodes.count; i++) 
	{
		DDXMLNode	*item=[resultNodes	objectAtIndex:i];
		NSString	*_CD=	[[item	childAtIndex:0] stringValue];
		NSString	*_Title=[[item	childAtIndex:1]	stringValue];
		
		NSArray *Keys   = [NSArray arrayWithObjects:@"_CD",@"_Title",nil];
		NSArray *Values = [NSArray arrayWithObjects:_CD,_Title, nil];
		
		NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithObjects:Values forKeys:Keys];
		
		[records addObject:dit];
		[dit release];
		
	}
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    //return YES;
	return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
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


- (void)dealloc 
{
	[records release];
	
	[_leftScrollView release];
	[_topScrollView release];
	[_contentScrollView release];
	[_tableView release];
    [super dealloc];
}


@end
