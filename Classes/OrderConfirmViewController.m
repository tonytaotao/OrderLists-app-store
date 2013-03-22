    //
//  OrderConfirmViewController.m
//  OrderList
//
//  Created by fly on 10/11/08.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OrderConfirmViewController.h"
#import "common.h"

@implementation OrderConfirmViewController{
    UIFont *leftFont;
}
@synthesize delegate;
@synthesize _tableView;

@synthesize _leftScrollView;
@synthesize _topScrollView;
@synthesize _contentScrollView;


@synthesize records;
@synthesize shopId;

ASIFormDataRequest *request;
NSMutableArray *leftConditions;			//leftボタンのcategoryCD
NSMutableArray *topConditions;			//topボタンのcategoryCD
NSMutableArray *topParentConditions;	//topの父categoryCD
NSMutableArray *itemFoodCD;				//itemsのfoodCD
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self._tableView setEditing:TRUE animated:TRUE];
	self._tableView.allowsSelectionDuringEditing = YES;
	
	[_leftScrollView setContentSize:CGSizeMake(LeftScrollViewWidth, 850)];
	[_topScrollView setContentSize:CGSizeMake( 1500, TopScrollViewHeight)];
	[_contentScrollView setContentSize:CGSizeMake(ContentScrollViewWidth, 500)];
	
	if (nil==records)
	{
		if (records)
		{
			[records	release];
		}
		records = [[NSMutableArray alloc] init];
	}

	
	[self initLayoutScroll];
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
	leftFont = [UIFont systemFontOfSize:10];
	
	
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
			//[leftButton setFont:leftFont];
			
			NSString *categoryCD = [[strItem childAtIndex:0] stringValue];
			[leftConditions addObject:categoryCD];
			
			leftButton.tag = lci;
			[leftButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:3] stringValue]]];
			[leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
			
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
			[topConditions	release];
	}
	
	topConditions =	[[NSMutableArray alloc] init];
	if (topParentConditions) 
	{
		[topParentConditions	release];
	}
	topParentConditions = [[NSMutableArray alloc] init];
	int tci = 0;
	
	int x_pos = 2;
	leftFont = [UIFont systemFontOfSize:10];
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
			//[topButton setFont:leftFont];
			
			NSString *categoryCD = [[strItem childAtIndex:0] stringValue]; 
			[topConditions addObject:categoryCD];
			
			NSString *parentCategoryCD= [[strItem childAtIndex:1] stringValue];
			[topParentConditions addObject:parentCategoryCD];
			
			topButton.tag = tci;
			[topButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:3] stringValue]]];
			[topButton addTarget:self action:@selector(topButtonClick:) forControlEvents:UIControlEventTouchUpInside];
			
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


//--------------------------------content buttons-------------------------------
//top条件によって
- (void)layoutContentScroll
{
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *condition = [NSString stringWithFormat:@"%@;%@;%@;%@", uid,@"All",@"ChildAll",shopId];
	
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
	leftFont = [UIFont systemFontOfSize:10];
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
			
			NSString *btnTitle = [NSString stringWithFormat:@"%@\r\n%@円",[[strItem childAtIndex:3] stringValue] ,[[strItem childAtIndex:4] stringValue]] ;
			[contentButton setTitle:btnTitle forState:UIControlStateNormal];
            //contentButton.titleLabel.lineBreakMode = UILineBreakModeCharacterWrap;
            //by.chao.tao
			[contentButton.titleLabel setLineBreakMode:UILineBreakModeCharacterWrap];
			[contentButton setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
			[contentButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
			
		
			NSString *itemCD = [[strItem childAtIndex:1] stringValue];
			[itemFoodCD addObject:itemCD];
			contentButton.tag = cci;
			
			[contentButton setBackgroundColor:[self parseColor:[[strItem childAtIndex:5] stringValue]]];
			[contentButton addTarget:self action:@selector(itemButtonClick:) forControlEvents:UIControlEventTouchUpInside];
			
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

#pragma mark -- item [menu]クリック--
- (IBAction)itemButtonClick:(id)sender
{
	NSString *btntitle = [sender currentTitle];
	NSArray  *titleArray = [btntitle componentsSeparatedByString:@"\r\n"];
	
	NSString *foodName  = [titleArray objectAtIndex:0];
	NSString *foodPrice = [titleArray objectAtIndex:1];
	NSString *foodCD    = [itemFoodCD objectAtIndex:[sender tag]];
	
	NSArray *foodKeys   = [NSArray arrayWithObjects:@"_foodName",@"_foodPrice",@"_foodCount",@"_foodCD",nil];
	NSArray *foodValues = [NSArray arrayWithObjects:foodName,foodPrice, @"1",foodCD, nil];
	
	NSMutableDictionary *dit = [[NSMutableDictionary alloc] initWithObjects:foodValues forKeys:foodKeys];
	
	
	BOOL isNotSort = YES;
	BOOL isNotExist = YES;
	NSUInteger i, count = [records count];
	for (i = 0; i < count; i++) 
	{
		NSMutableDictionary * rDic = [records objectAtIndex:i];
		
		if([[rDic valueForKey:@"_foodCD"] isEqualToString:[dit valueForKey:@"_foodCD"]])	//もう存在しているの場合、数量をPlusする
		{
			int rCount = [[rDic valueForKey:@"_foodCount"] intValue];
			rCount    += 1;
			NSString *rfCount = [NSString stringWithFormat:@"%d",rCount];
			
			[rDic setObject:rfCount forKey:@"_foodCount"];
			
			isNotExist = NO;
			isNotSort  = NO;
			break;
		}
	}
	
	if(isNotExist)		//新規の場合は追加
		[records addObject:dit];
	
	[dit release];

	
	if(isNotSort)
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
	
	
	[_tableView reloadData];
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


//close this view
- (IBAction)btnClose:(id)sender
{
//	if (![common	requestDidError]) 
//	{
//		return;			
//	}
	
	[delegate OrderConfirmViewControllerDidClose:self];
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
	static NSString *MyIdentifierOrder = @"OrderConfirmCellIdentifier";
	
	OrderConfirmCell *cell = (OrderConfirmCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifierOrder];
	if(cell ==nil)
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"OrderConfirmCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	cell.delegate = self;
	NSInteger rowIndex = [indexPath indexAtPosition: 1];
//	cell.tag      = rowIndex;
	cell.number	  = rowIndex;
	
	NSString *strName =		 [[records objectAtIndex:indexPath.row] valueForKey:@"_foodName"];
	NSString *strPrice=		 [[records objectAtIndex:indexPath.row] valueForKey:@"_foodPrice"];  
	NSString *strCount=		 [[records objectAtIndex:indexPath.row] valueForKey:@"_foodCount"];
	
	
	[[cell _foodName] setText:strName];
	[[cell _foodPrice] setText:strPrice];
	[[cell _foodCount] setTitle:strCount forState:UIControlStateNormal];
	
//	[[cell _foodPlus] setTag:indexPath.row];
//	[[cell _foodMinus] setTag:indexPath.row];
	
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
		[_tableView	reloadData];
	} 
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}



#pragma mark -
#pragma mark OrderConfirmCellDelegate
//数量をPLus
- (void)orderConfirmCellDidPlus:(OrderConfirmCell *)cell
{
	NSUInteger  fCount   = [[cell _foodCount].titleLabel.text  intValue] + 1;
	NSString   *foodCount= [NSString stringWithFormat:@"%d",fCount]; 
	
	//update cell
	[[cell _foodCount] setTitle:foodCount forState:UIControlStateNormal];		
	
	int number = cell.number;
	[[records objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
	
	//update records
//	[[records objectAtIndex:cell.tag] setObject:foodCount forKey:@"_foodCount"];
}

//数量をMinus
- (void)orderConfirmCellDidMinus:(OrderConfirmCell *)cell
{
	NSUInteger  fCount   = [[cell _foodCount].titleLabel.text  intValue] - 1;
	NSString   *foodCount= [NSString stringWithFormat:@"%d",fCount]; 
	
	//update cell
	[[cell _foodCount] setTitle:foodCount forState:UIControlStateNormal];		

	int number = cell.number;
	[[records objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
	
	//update records
//	[[records objectAtIndex:cell.tag] setObject:foodCount forKey:@"_foodCount"];
}


- (void)orderConfirmCellDidInput:(OrderConfirmCell *)cell
{
	NSUInteger  fCount   = [[cell _foodCount].titleLabel.text  intValue];
	NSString   *foodCount= [NSString stringWithFormat:@"%d",fCount]; 
	
	int number = cell.number;
	[[records objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
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


- (void)dealloc 
{
	[shopId release];
	[records release];
	
	[_leftScrollView release];
	[_topScrollView release];
	[_contentScrollView release];
	
	[_tableView release];
	if (topConditions) 
	{
		[topConditions	release];
	}
	[leftConditions	release];
	if (topParentConditions)
 {
		[topParentConditions	release];
	}
	[itemFoodCD	release];
	
	[super dealloc];
}


@end
