
#import "HistoryDetailViewController.h"
#import "common.h"
#import	"DetailViewController.h"
#import "MasterViewController.h"

@implementation HistoryDetailViewController
@synthesize _tableView;
@synthesize selectPerson;

#pragma mark -
#pragma mark View lifecycle

ASIFormDataRequest *request;
NSMutableArray *tkey;

NSMutableArray *itemArr;
NSMutableArray *recordArr;
NSMutableArray *_hrecords;

NSMutableArray		*keys;					//検索人
NSMutableArray	    *peopleArr;

-(void) viewDidLoad 
{
	itemArr = [[NSMutableArray alloc] init];
	recordArr = [[NSMutableArray alloc] init];
	_hrecords = [[NSMutableArray alloc] init];
	
	peopleArr = [[NSMutableArray alloc] init];
	keys =		 [[NSMutableArray alloc] initWithObjects:@"CustomerID",@"CustomerName",nil];

	[super viewDidLoad];
}

-	(void)	showDetailCopyInfo
{
	NSString	*detailInfo =	[DetailViewController	getDetailUserCdName];
	
	if (![detailInfo	isEqualToString:@""]	&&	[detailInfo	length]	>	0) 
	{
		NSArray	*	detailInfoAry	=	[detailInfo	componentsSeparatedByString:@";"];
		if (detailInfoAry!=nil	&&	[detailInfoAry	count]	==	2) 
		{
			NSString	*tel	=	[detailInfoAry	objectAtIndex:0];
			NSString	*userName	=	[detailInfoAry	objectAtIndex:1];
			if (![tel	isEqualToString:@""]) 
			{
				[textFieldTel	setTitle:tel	forState:UIControlStateNormal];
			}
			if (![userName	isEqualToString:@""]	||	[userName	length]	>	0) 
			{
				[peopleArr	removeAllObjects];
				[self	getCustomerNameList:tel];
				if (peopleArr	!=	nil	&&	peopleArr.count>1) 
				{
					for (int	i=0; i<peopleArr.count; i++) 
					{
						if ([userName	isEqualToString:[[peopleArr	objectAtIndex:i]	objectForKey:@"CustomerName"]]) 
						{
							NSString *customID = [[peopleArr objectAtIndex:i] objectForKey:@"CustomerID"];
							[selectPerson	setText:userName];
							[self getCusHis:userName CustomerCD:customID CusteomerPhone:tel];
							[selectPerson reloadAllComponents];
							break;
						}
					}
				}
			}
		}
	}
	[DetailViewController	releaseDetailInfo];
}

//電話番号によって、データを検索する
- (IBAction)HistorySearch:(id)sender
{
	[peopleArr removeAllObjects];
	[_hrecords	removeAllObjects];
	[_tableView	reloadData];
	
	if (![common	requestDidError]) 
	{
		return;			
	}
	
	NSString *tel = [textFieldTel titleLabel].text;
	
	[self	getCustomerNameList:tel];
	
	if(peopleArr	!=	nil	&&	peopleArr.count>1)
	{
		[selectPerson setText:[[peopleArr objectAtIndex:1] objectForKey:@"CustomerName"]];
		
		NSString *customID = [[peopleArr objectAtIndex:1] objectForKey:@"CustomerID"];
		NSString *customName = [[peopleArr objectAtIndex:1] objectForKey:@"CustomerName"];
		
		[self getCusHis:customName CustomerCD:customID CusteomerPhone:textFieldTel.titleLabel.text];
		
	}
	else 
	{
		[selectPerson	setText:@""];
	}

	[selectPerson reloadAllComponents];
	
}

-	(void)	getCustomerNameList:(NSString	*)tel
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerNameList"]]];
	[request setPostValue:tel forKey:@"keys"];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[self parseNameList:str];
}

//フォマと xml
- (void)parseNameList:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray * pValues = [[NSMutableArray alloc] init];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{
			CXMLNode *child =[node childAtIndex:0];					//item 
			NSArray *childs = [child children];
			
			for (CXMLElement *tmpE in childs)						// ele
			{
				if([tmpE isKindOfClass:[CXMLElement class]])
				{
					if ([tmpE childCount] == 0)						//the node is empty
					{
						[pValues addObject:@""];
					}
					else 
					{
						CXMLNode *node = [[tmpE children] objectAtIndex:0];
						[pValues addObject:[node stringValue]];	
					}
				}//end if
			}//end for
			
			if ([pValues count] ==2) // dic objest.count =keys.count
			{
				NSMutableDictionary *mdic = [[NSMutableDictionary alloc] initWithObjects:pValues forKeys:keys];
				[peopleArr addObject:mdic];
				[pValues removeAllObjects];
				[mdic release];
			}
			
		} //end if
	} //end for
	[pValues release];
	
}


- (void)getCusHis:(NSString *)CustomerName CustomerCD:(NSString *)CustomerCD CusteomerPhone:(NSString *)cusPhone
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetOrderHistoryByCustomerCDNamePhone"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:CustomerName forKey:@"CustomerName"];
	[request setPostValue:CustomerCD   forKey:@"CustomerCd"];
	[request setPostValue:cusPhone     forKey:@"Phone"];
	
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	
	if ([str rangeOfString:@"Child"].location == NSNotFound) 
	{
//		[common showErrorAlert:@"データなし！"];
		[_hrecords removeAllObjects];
		[_tableView reloadData];
	}
	else 
	{
		[self parseXml:str];
	}
}



#pragma mark -
//将xml字符串中的某些元素解析
- (void)parseXml: (NSString*)xmlString 
{
	tkey = [NSMutableArray arrayWithObjects:@"itemCD",@"itemName",@"shopName",@"itemPrice",@"itemCount",nil];
	
	if(0 == [xmlString length])
		return ;
	
	//-----------------------------------------------------------------------------------------------------------
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray * tValue=[[NSMutableArray alloc] init];
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])		//string
		{
			CXMLNode *child =[node childAtIndex:0];			//child
			NSArray *childs = [child children];
			
			for (CXMLElement *tmpE in childs)				// Child
			{
				if([tmpE isKindOfClass:[CXMLElement class]])
				{
					
					if ([tmpE childCount] == 1)				//Date 
					{
						//NSLog([tmpE stringValue]);		
						[recordArr addObject:[tmpE stringValue]];
					}
					else //Item 
					{
						NSArray *sons = [tmpE children];     //item
						for (CXMLElement *son in sons) 
						{
							if ([son isKindOfClass:[CXMLElement class]]) 
							{
								//NSLog([son stringValue]);
								[tValue addObject:[son stringValue]];
							}
						}
						NSMutableDictionary *tDic= [[NSMutableDictionary alloc] initWithObjects:tValue forKeys:tkey];		//single item[key;value]
						[itemArr addObject:tDic];
						[tValue removeAllObjects];
						[tDic release];
					}
					
				}	
					
			}
			NSMutableArray	*itemArrCopy	=	[itemArr copy];
			[recordArr addObject:itemArrCopy];
			[itemArr removeAllObjects];
			[itemArrCopy	release];
			
			NSMutableArray	*recordArrCopy	=	[recordArr copy];
			[_hrecords addObject:recordArrCopy];
			[recordArr removeAllObjects];
			[recordArrCopy	release];
		}
	}
	[tValue release];
	//[_hrecords addObject:recordArr];
	[_tableView reloadData];
}


/*
- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)atextField
{
	[atextField setText:@""];
	[textField setTextColor:[UIColor blackColor]];
}

*/


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	if(_hrecords.count	==	nil)
	{
		return	0;
	}
	return _hrecords.count;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [[[_hrecords objectAtIndex:section] objectAtIndex:1] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50.0;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//用来标识窗格为一个普通窗格
	static NSString *MyIdentifierHistory = @"HistoryDetailCell";
	
	HistoryDetailCell *cell = (HistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifierHistory];
	if(cell == nil)
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HistoryDetailCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	cell.tag      = indexPath.row;
	cell.delegate = self;
	
	NSString *strName =		 [[[[_hrecords objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemName"];
	NSString *strPrice=		 [[[[_hrecords objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemPrice"]; 
	NSString *strCount=		 [[[[_hrecords objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemCount"];
		NSString *strShopName=		 [[[[_hrecords objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"shopName"];
	
	cell._foodCD=		[[[[_hrecords objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemCD"];
	[[cell _foodName] setText:strName];
	[[cell _foodPrice] setText:strPrice];
	[[cell _foodCount] setText:strCount];
	[[cell _foodShopName] setText:strShopName];
	

//	//NSMutableArray *array = [[_hrecords objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
//	
//	[[cell _btnOrder] setTag:indexPath.section];
//	[[cell _btnOrder] addTarget:self action:@selector(appendHistoryRecords:) forControlEvents:UIControlEventTouchUpInside];

	
	return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	NSString *HeaderString = nil;
	HeaderString = [[_hrecords objectAtIndex:section] objectAtIndex:0];
	
//	switch (section) 
//	{
//		case 0:
//			HeaderString = [NSString stringWithFormat:@"2010/10/10 12:30"];
//			break;
//			
//		case 1:
//			HeaderString= [NSString stringWithFormat:@"2011/11/12 13:30"];
//			break;
//			
//		case 2:
//			HeaderString = [NSString stringWithFormat:@"2012/12/11 17:30"];
//			break;
//	}
	
	UIView  *seHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 80)];
	seHeader.backgroundColor = [UIColor clearColor];
	
	UILabel *HeaderLabel = [[[UILabel alloc] initWithFrame:CGRectMake(50, 15, 200, 40)] autorelease];
	HeaderLabel.backgroundColor = [UIColor clearColor];
	HeaderLabel.font = [UIFont boldSystemFontOfSize:14];
	HeaderLabel.textColor = [UIColor blueColor];
	HeaderLabel.text = HeaderString;
	
//	UIButton *btnHisAdd = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//	[btnHisAdd addTarget:self action:@selector(appendHistoryRecords:) forControlEvents:UIControlEventTouchUpInside];
//	
//	[btnHisAdd setTitle:@"同じ追加" forState:UIControlStateNormal];
//	[btnHisAdd setFrame:CGRectMake(520, 15, 90, 30)];
//	btnHisAdd.tag = section;
	
	[seHeader addSubview:HeaderLabel];
	[seHeader	autorelease];
//	[seHeader addSubview:btnHisAdd];
	return seHeader;
}









//注文履歴を追加
- (void)appendHistRecord:(HistoryDetailCell *)cell
{
	NSMutableArray *aryKeys = [NSMutableArray arrayWithObjects:@"_foodCD",@"_foodName",@"_foodShopName",@"_foodPrice",@"_foodCount",nil];
	NSMutableArray *aryValues=[NSMutableArray arrayWithObjects:[cell	_foodCD],[cell _foodName].text,[cell _foodShopName].text,[cell _foodPrice].text,@"1",nil];
	NSMutableDictionary *aryDic = [NSMutableDictionary dictionaryWithObjects:aryValues forKeys:aryKeys];
	
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    NSString *filePath = [path stringByAppendingPathComponent:@"hisRecords.dat"];
    
    NSMutableArray *hisRecordsDefault = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    if (hisRecordsDefault == nil) {
        hisRecordsDefault = [[[NSMutableArray alloc] init] autorelease];
    }
    [hisRecordsDefault addObject:aryDic];
    
    [NSKeyedArchiver archiveRootObject:hisRecordsDefault toFile:filePath];
}

//- (void)appendHistoryRecords:(id)sender
//{
////	NSInteger index = [sender tag];
////	if (hisRecords == nil) 
////	{
////		hisRecords = [[NSMutableArray alloc] init];
////	}
////	
////	//add it to the hisRecords array
////	[hisRecords addObject:[_hrecords objectAtIndex:index]];
//	id aa = array;
//}


#pragma mark --NWPickerField--
-(void)pickerField:(NWPickerField *)pickerField didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{ 
	if(row==0)
	{
		[self	showDetailCopyInfo];
		return;
	}
	if (peopleArr	!=	nil	&&	[peopleArr count]>0)
	{
		[_hrecords removeAllObjects];
		[_tableView	reloadData];
		
		NSString *customID = [[peopleArr objectAtIndex:row] objectForKey:@"CustomerID"];
		NSString *customName = [[peopleArr objectAtIndex:row] objectForKey:@"CustomerName"];
		
		[self getCusHis:customName CustomerCD:customID CusteomerPhone:textFieldTel.titleLabel.text];
	}
	
}


-(NSInteger) numberOfComponentsInPickerField:(NWPickerField*)pickerField 
{	
	return 1;
}


-(NSInteger) pickerField:(NWPickerField*)pickerField numberOfRowsInComponent:(NSInteger)component
{
	if(peopleArr	!=	nil	&&	[peopleArr count]>0)
		return [peopleArr count];
	return 1;
}

-(NSString *) pickerField:(NWPickerField *)pickerField titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(peopleArr	!=	nil	&&	[peopleArr count]>0)
		return [[peopleArr objectAtIndex:row] objectForKey:@"CustomerName"];
	return @"";
}

#pragma mark -
#pragma mark Rotation support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}


//liukeyu add 2011-06-09	start
-	(IBAction)	copyHisTelAndName:(id)sender
{
	if (hisPhoneCdNameInfo)
 {
		[hisPhoneCdNameInfo	release];
	}
	NSString	*hisPhone	=	[textFieldTel titleLabel].text	==	nil	?	@""	:	[textFieldTel titleLabel].text;
	NSString	*UserName = [selectPerson	text] == nil ? @"" :[selectPerson	text];
	hisPhoneCdNameInfo	=	[[NSString	alloc]	initWithFormat:@"%@;%@",hisPhone,UserName];
	[[MasterViewController	getTableViewController] changeView:0 iSection:0];
}

+	(NSString*)	getHisDetailUserCdName
{
	if (hisPhoneCdNameInfo	==	nil) 
	{
		return	@"";
	}
	return	hisPhoneCdNameInfo;
}

+	(void)	releaseHisDetailInfo
{
//	if (hisPhoneCdNameInfo)
// {
//		[hisPhoneCdNameInfo	release];
//	}
	detailPhoneCdNameInfo	=	nil;
}
//liukeyu add 2011-06-09	end

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
	[selectPerson release];
	[_tableView release];
	
//	[tvalue	release];
//	[itemArr	release];
//	[recordArr	release];
//	[_hrecords	release];
//	
//	//[peopleArr	release];
//	[keys	release];
//	[values	release];
	
	[super dealloc];
}	


@end
