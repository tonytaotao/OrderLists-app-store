    //
//  HouseViewController.m
//  MasterDetail
//
//  Created by fly on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "HouseViewController.h"
#import "common.h"
#import "HistoryDetailViewController.h"
#import "CustomUISplitViewController.h"
#import "MasterViewController.h"
#import "HouseViewCell.h"
#import "FreeRoomController.h"
#import "CustomerAndOrderController.h"
#import "PriceInput.h"

@implementation HouseViewController
@synthesize _tableView, _tableViewDelete;
@synthesize dateLabel;
@synthesize weekLabel;
@synthesize dateString;

@synthesize editButton;
@synthesize doneButton;

@synthesize houseData;

@synthesize userId ;
@synthesize shopId ;
@synthesize VisitDate;

@synthesize memoStr;
@synthesize memoTextView;
@synthesize hIsDayOrNight;
@synthesize houseImageSelectedArray;

@synthesize houseLock;
@synthesize houseUnLock;
@synthesize	cell_selectIndex;
@synthesize recordsDelete;

static UIButton *scal = nil;
static UIButton *shouse = nil;



ASIFormDataRequest  *request;
NSMutableArray      *tkey;
NSMutableArray      *tvalue;
//NSMutableDictionary *tdic;

NSMutableArray		*recordsClone;

NSMutableArray		*roomCDArr;

int	masterHouseX = 8;
int masterHouseY = 59;
int masterTHouseX = 8;
int masterTHouseY = 107;


UIButton	*housePIckerChangePeopleCount;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

//位置を初期化
- (void)masteposInit
{
	masterHouseX = 8;
	masterHouseY = 59;
	masterTHouseX = 8;
	masterTHouseY = 107;
}

- (void)viewWillAppear:(BOOL)animated
{
	isClearMode=FALSE;
    if (clearModeChangeHousePeople!=nil) {
        [clearModeChangeHousePeople release];
    }
	clearModeChangeHousePeople=[[NSMutableArray	alloc] init];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{	
	[super viewDidLoad];
	[dateLabel setTitle:dateString forState:UIControlStateNormal];
	
	NSDateFormatter *formatterCal = [[NSDateFormatter alloc] init]; 
	//formatterCal.dateFormat = @"yyyy年MM月dd日";
	[formatterCal	setDateFormat:@"yyyy年M月d日"];
	
	NSDate	*dateWeek	=	[formatterCal	dateFromString:dateString];
	
 [formatterCal	setDateFormat:@"EEEE"];
	
	NSString *weekTampCal = [formatterCal stringFromDate:dateWeek]; 
	[weekLabel	setText:weekTampCal];
	[formatterCal release];
	
//[self._tableView setEditing:TRUE animated:TRUE];
	self._tableView.allowsSelectionDuringEditing = YES;
	[memoTextView setText:memoStr];
	
//	[tvalue	release];
//	[records	release];
	tvalue=[[NSMutableArray alloc] init];
	records=[[NSMutableArray alloc] init];
	//[self isUnLockSuccess:@"1-200" LockState:@"1"];
	[self masteposInit];
	[self drawMsterHouse];
	[self getRoomData];
	
	houseImageSelectedArray = [[NSMutableArray alloc] init];		//部屋選択かどうか 画像のアレイ
	[self	houseImageSelectedArrayInit];
}

-(void)houseImageSelectedArrayInit
{
	for (int i=0; i<records.count; i++) 
	{
		[houseImageSelectedArray addObject:@"0" ];
	}
}

//Master House
- (void)drawMsterHouse
{	
	//clear textField
	for (UIView *view in self.view.subviews) 
	{
		if ([view isKindOfClass:[UITextField class]] ) 
		{
			[view removeFromSuperview];
		}
		
	} 
	
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,strdate,hIsDayOrNight];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetEmptySetRoom"]]];
	[request setPostValue:strPost forKey:@"keys"];
	
//	[request setPostValue:VisitDate forKey:@"VisitDate"];
	[request setPostValue:strdate forKey:@"VisitDate"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	NSError	*error	=	[request	error];
	if (error) 
	{
		[common	showErrorAlert:@"ネットワークを確認してください。"];
		return;
	}
		
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[self parseMasterHouseXml:str];
}

//xmlを分析する
- (void)parseMasterHouseXml: (NSString *)houseMasterXmlStr
{	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: houseMasterXmlStr options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	NSMutableArray *groupArr = [NSMutableArray arrayWithCapacity:1];
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{
			CXMLNode *child =[node childAtIndex:0];					//Group [RoomItem_RoomSetItem]
			NSArray *childs = [child children];
			
			for (CXMLElement *tmpE in childs)						// ele
			{
				if([tmpE isKindOfClass:[CXMLElement class]])
				{
					[groupArr addObject:tmpE];
				}
			}
			if(groupArr.count>0)
			{
				[self parseGroup:groupArr];
				masterHouseX += 10;
				[groupArr removeAllObjects];
			}
			
		}
	}
}



//group　XMLを分析する
//パラメーター　０；RoomItemのxml
//パラメーター　１；RoomSetItemのxml
- (void)parseGroup:(NSMutableArray *)groupArr
{
	
	//NSMutableArray *RoomItemArr =[NSMutableArray arrayWithCapacity:1];
	NSMutableArray *RoomSetItemArr = [NSMutableArray arrayWithCapacity:1];
	
	NSMutableArray *RoomItemArr	  =  [groupArr objectAtIndex:0];

	NSMutableArray *RoomItemChildsArr = [NSMutableArray arrayWithCapacity:1];
	
	for (CXMLElement *tmpEE in [RoomItemArr children])						// ele
	{
		if([tmpEE isKindOfClass:[CXMLElement class]])
		{
			[RoomItemChildsArr addObject:tmpEE];
		}
	}
	
	
	
	
	
	NSMutableArray *isShowArr = [NSMutableArray arrayWithCapacity:1];
	
	if ([groupArr count]==2) 
	{
		RoomSetItemArr = [groupArr objectAtIndex:1];
		
		NSString *isShowStr = [[[RoomSetItemArr childAtIndex:0] childAtIndex:3] stringValue];
		isShowArr = [isShowStr componentsSeparatedByString:@";"];
		
	}
	int flagCount = [isShowArr count]-1;
	
	if ( (masterHouseX ==18)) 
	{
		masterHouseX =8;
		masterTHouseY = 197;
	}
	
	if(masterHouseX > 650)							//single room
	{
		masterHouseX  = 8;
		masterHouseY += 90;
		masterTHouseY = 197;
	}
	
	if ((masterHouseX +30*flagCount )>700)			//長過ぎ改行する
	{
		masterHouseX  = 8;
		masterHouseY += 90;
		masterTHouseY = 197;
	}
	

	
	masterTHouseX = masterHouseX;//488->18
	
	
 //-------------------------------draw -------------------------
	//draw 1 level; 2 level
	if (flagCount<0)			//MsterRoomSetItem not exitst
	{
		[self drawMasterRoomItem:[RoomItemChildsArr objectAtIndex:0]];
	}
	else 
	{
		for (int i=0; i<flagCount; i++) 
		{
			[self drawMasterRoomItem:[RoomItemChildsArr objectAtIndex:i]];
		}
	}

	
	
	
	//RoomSetItem
	if (groupArr.count ==2) 
	{
		//draw 3 level
		int memberCount = [self memberCount:isShowArr];
		int memberPos   = [self memberBeginPos:isShowArr];   //if not exist then return -1;
		
		if (memberPos >=0) //exist
		{
			[self drawMasterRoomSetItem:RoomSetItemArr bginPos:memberPos  count:memberCount];
		}//end if
	}
	
	
	
}


//draw チーム部屋
- (void)drawMasterRoomSetItem:(CXMLElement *)_roomSetItem bginPos:(int)beginPos count:(int)count
{
	
	CXMLElement *roomSetItem = [_roomSetItem childAtIndex:0];
	
	//NSString *SetRoomCD = [[roomSetItem childAtIndex:0] stringValue];
	NSString *customerCount = [[roomSetItem childAtIndex:1] stringValue];
	if([customerCount rangeOfString:@"/"].length >0)
		customerCount = [customerCount stringByAppendingString:@""]; 
	else
		customerCount = [customerCount stringByAppendingString:@"名"]; //名

	
	NSString *colorValue =[[roomSetItem childAtIndex:2] stringValue];
	NSArray  *colorValueArr = [colorValue componentsSeparatedByString:@";"];	//argb
	
	float alph = (float)[[colorValueArr objectAtIndex:0] floatValue];
	float red = (float)[[colorValueArr objectAtIndex:1] floatValue];
	float green = (float)[[colorValueArr objectAtIndex:2] floatValue];
	float blue = (float)[[colorValueArr objectAtIndex:3] floatValue];
	
	UIColor  *roomColor = [UIColor colorWithRed:red green:green blue:blue alpha:alph];
	UIFont	*wordFont = [UIFont	systemFontOfSize:12];
	
	
	float beginPostion = masterTHouseX + 31*beginPos;
	float gropWidth = 31 *count - count+1;
	CGRect groupFrame = CGRectMake(beginPostion, masterTHouseY, gropWidth, 19);				//x
	UITextField *groupTextField = [[UITextField alloc] initWithFrame:groupFrame];
	
	[groupTextField setBorderStyle:UITextBorderStyleLine];
	[groupTextField setText:customerCount];
	[groupTextField setFont:wordFont];
	[groupTextField setTextAlignment:UITextAlignmentCenter];
	[groupTextField setUserInteractionEnabled:FALSE];
	[groupTextField setBackgroundColor:roomColor];
	
	[self.view addSubview:groupTextField];
	[groupTextField	release];
	//NSLog(@"-------- masterHouseX  %d------masterTHouseX %d -------",masterHouseX,masterTHouseX);
}


//member の数量
- (int)memberCount :(NSMutableArray *)isShowArr
{
	BOOL isBegin = FALSE;
	int  combineCount=0;
	
	for (int i=0; i<[isShowArr count]-1; i++) 
	{
		NSString *flag = [isShowArr objectAtIndex:i];
		if ([flag isEqualToString:@"1"])					//show the group label
		{
			isBegin = TRUE;
			combineCount +=1; 
		}
		else //0
		{
			if (isBegin) 
			{
//				isBegin =FALSE;
				break;
			}//end if
			
		} //end else
	}
	return combineCount;
}


//member の位置
- (int)memberBeginPos:(NSMutableArray *)isShowArr
{
	for (int i=0; i<[isShowArr count]-1; i++) 
	{
		NSString *flag = [isShowArr objectAtIndex:i];
		if ([flag isEqualToString:@"1"])					//show the group label
		{
			return i;
		}
	}
	return -1;
}





//^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

//draw roomItem
- (void)drawMasterRoomItem:(CXMLElement *)roomItemElement
{
	NSString *RoomCD = [[roomItemElement childAtIndex:0] stringValue];
	NSString *PersonNum = [[roomItemElement childAtIndex:1] stringValue];
	if([PersonNum rangeOfString:@"/"].length >0)
		PersonNum = [PersonNum stringByAppendingString:@""];
	else
		PersonNum = [PersonNum stringByAppendingString:@"名"];
	
	NSString *colorValue =[[roomItemElement childAtIndex:2] stringValue];
//	NSArray  *colorValueArr = [colorValue componentsSeparatedByString:@";"];	//argb
//	
//	float alph = (float)[[colorValueArr objectAtIndex:0] floatValue];
//	float red = (float)[[colorValueArr objectAtIndex:1] floatValue];
//	float green = (float)[[colorValueArr objectAtIndex:2] floatValue];
//	float blue = (float)[[colorValueArr objectAtIndex:3] floatValue];
	
	UIColor  *roomColor = [self	parseFenHao:colorValue];	//[UIColor colorWithRed:red green:green blue:blue alpha:alph];
	UIColor	 *lockRoomColor=[self	parseFenHao:[[roomItemElement childAtIndex:3] stringValue]];
	UIFont	*wordFont = [UIFont	systemFontOfSize:10.7];
	
	
	
	//-----------------------部屋番号----------------------
	CGRect numberFrame = CGRectMake(masterHouseX, masterHouseY, 31, 31);				//x
	UITextField *numberTextField = [[UITextField alloc] initWithFrame:numberFrame];
	
	[numberTextField setBorderStyle:UITextBorderStyleLine];
	[numberTextField setText:RoomCD];
	[numberTextField setFont:wordFont];
	[numberTextField setTextAlignment:UITextAlignmentCenter];
	[numberTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[numberTextField setUserInteractionEnabled:FALSE];
	[numberTextField setBackgroundColor:lockRoomColor];
	//-------------------------部屋容量---------------------
	CGRect	countFrame = CGRectMake(masterHouseX, (masterHouseY +30), 31, 19);				//x
	UITextField *countTextField = [[UITextField alloc] initWithFrame:countFrame];
	
	[countTextField setBorderStyle:UITextBorderStyleLine];
	[countTextField setText:PersonNum];
	[countTextField setFont:wordFont];
	[countTextField setTextAlignment:UITextAlignmentCenter];
	[countTextField setUserInteractionEnabled:FALSE];
	[countTextField setBackgroundColor:roomColor];
	
	
	[self.view addSubview:numberTextField];
	[self.view addSubview:countTextField];
	[numberTextField	release];
	[countTextField	release];
	
	masterHouseX += 30;
}

//------------------------------------------------------------------------------------------------------

//soapを利用して、データを取ります
- (void)getRoomData
{
	//	NSLog(@"-----userId----%@",userId);
	//	NSLog(shopId);
	//	NSLog(VisitDate);
	
	if ([shopId isEqualToString:@""]) 
	{
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetRoomOrderDataWithDateOnly"]]];
		[request setPostValue:userId forKey:@"userId"];
	}
	else 
	{
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetRoomOrderDataWithDate"]]];
		[request setPostValue:shopId forKey:@"shopId"];
	}
	
	
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	
	
	[request setPostValue:hIsDayOrNight forKey:@"dayNightKbn"];
//	[request setPostValue:VisitDate forKey:@"VisitDate"];
	[request setPostValue:strdate forKey:@"VisitDate"];
	
	[request setRequestMethod:@"POST"];

	[request startSynchronous];
	
	NSError	*	error	=	[request	error];
	NSString *str = nil;
	if (error) 
	{
		[common	showErrorAlert:@"ネットワークを確認してください。"];
		str		=	@"";
	}else 
	{
		str = [request responseString];
		str	=	[common formateXmlString:str];
	}
	[self parseXml:str];
}



- (void)parseXml: (NSString*)xmlString 
{
	tkey = [NSMutableArray arrayWithObjects:@"roomName",@"visitTime",@"companyName",@"orderName",@"customerCount",@"itemCount",@"memo",@"selCommentId",@"selComment",@"houseCellColor",@"OrderId",@"roomCD",@"memberCD",@"lockFlag",@"lockRoomColor",@"wordsColorFlag",@"isDelete",nil];
	if(0 == [xmlString length])
		return ;
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
    NSMutableArray *recordsArr = [[NSMutableArray alloc] init];
    
	NSArray *nodes = NULL;
	nodes = [theDoc children];
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
						[tvalue addObject:@""];
					}
					else 
					{
						CXMLNode *node = [[tmpE children] objectAtIndex:0];
						[tvalue addObject:[node stringValue]];	
					}
	
				}
			}
			if ([tvalue count] ==17) // dic objest.count =keys.count
			{
				NSMutableDictionary *tdic = [[NSMutableDictionary alloc] initWithObjects:tvalue forKeys:tkey];
				[recordsArr addObject:tdic];
				[tdic	release];
				[tvalue removeAllObjects];
			}
			
		}
		
	}
    [self SiftData:recordsArr];
    [recordsArr release];
	[_tableView reloadData];
}

- (void) SiftData:(NSMutableArray *) recordsArr
{
    if (recordsArr !=nil && [recordsArr count] >0) {
        NSMutableArray *deleteArr = [[NSMutableArray alloc] init];
        for (NSMutableDictionary *dic in recordsArr) {
            NSString *delete = [dic objectForKey:@"isDelete"];
            if ([delete isEqualToString:@"1"]) {
                [deleteArr addObject:dic];
            }else{
                [records addObject:dic];
            }
        }
        self.recordsDelete = deleteArr;
        [deleteArr release];
    }
}

// shop's メモの処理
- (IBAction)btnDayMemo:(id)sender
{
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	
	
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@;%@",LoginId,shopId,strdate/*VisitDate*/,memoTextView.text,hIsDayOrNight];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"InsertDayMemo"]]];
	[request setPostValue:strPost forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	NSString *strMemo = [theDoc stringValue];
	if ([strMemo isEqualToString:@"true"]) 
	{
		[common showSuccessAlert:@"更新しました！"];
	}
	else 
	{
		[common showErrorAlert:@"Error"];
	}

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    NSInteger result = 0;
    switch (section) {
        case 0:
            result = [records count];
            break;
        case 1:
            result = [self.recordsDelete count];
            break;
        default:
            break;
    }
	return result;
}


-(UITableViewCell *)GetOrderInfoCell:(NSIndexPath *)indexPath{

    //用来标识窗格为一个普通窗格
	static NSString *MyIdentifier = @"NormalCell";
	
	//获取一个可复用窗格
	HouseViewCell *cell = (HouseViewCell *)[_tableView dequeueReusableCellWithIdentifier:MyIdentifier];

    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HouseViewCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    cell.delegate = self;
	NSInteger rowIndex = indexPath.row;
	cell.number	  = rowIndex;
    
	
	//在右侧显示一个箭头
	cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    //	cell.showsReorderControl = YES;
	
    
	NSDictionary *dic = [records objectAtIndex:indexPath.row];
	
	NSString *strRoomName_CD = nil;
	if([[dic objectForKey:@"roomName"] isEqualToString:@""])
		strRoomName_CD = @"            ";
	else
		strRoomName_CD = [NSString stringWithFormat:@"%@  【%@】",[dic objectForKey:@"roomName"],[dic objectForKey:@"roomCD"]];
    //	if ([[dic objectForKey:@"houseCellColor"] isEqualToString:@"0.500000,0.000000,1.000000,0.000000"]) {
    //		strRoomName_CD= @"";
    //	}
	
	NSString *strCell = [NSString stringWithFormat:@"%@   %@　 %@   %@　%@  %@  %@ %@",
                         strRoomName_CD,
                         [dic objectForKey:@"visitTime"],
                         [dic objectForKey:@"orderName"],
                         [dic objectForKey:@"companyName"],
                         [dic objectForKey:@"customerCount"],
                         [dic objectForKey:@"itemCount"],
                         [dic objectForKey:@"selComment"],
                         [dic objectForKey:@"memo"]];	
	cell.cellStr=strCell;
	cell.cellOrderId = [NSString stringWithFormat:@"%@",[dic objectForKey:@"OrderId"]];
	cell.cellColor = [dic objectForKey:@"houseCellColor"];
    
	
	NSString	*strRoomName=	  [common	formatCntStr:[dic objectForKey:@"roomName"] Count:6];			//[NSString	stringWithFormat:@"%-3s",[[dic objectForKey:@"roomName"]	UTF8String]];
	NSString	*strVisitTime=    [common	formatCntStr:[dic objectForKey:@"visitTime"] Count:5];			//[NSString	stringWithFormat:@"%-6s",[[dic objectForKey:@"visitTime"]	UTF8String]];
	
	NSString	*strOrderName=    [common	formatCntStr:[dic objectForKey:@"orderName"] Count:6];
	NSString	*strCompanyName=  [common	formatCntStr:[dic objectForKey:@"companyName"] Count:6];
	NSString	*strCustomerCount=[common	formatCntStr:[dic objectForKey:@"customerCount"] Count:6];
	NSString	*strItemCount=    [common	formatCntStr:[dic objectForKey:@"itemCount"] Count:6]; 
	
	NSString	*strSelCom   =    [common	formatCntStr:[dic objectForKey:@"selComment"] Count:6]; 
	NSString	*strCom   =    [common	formatCntStr:[dic objectForKey:@"memo"] Count:6]; 
	if ([[dic objectForKey:@"houseCellColor"] isEqualToString:@"0.500000,0.000000,1.000000,0.000000"]) {
		strRoomName= @"						";
	}
	
	NSString	*cellShowStr=[NSString	stringWithFormat:@"%@  %@	   %@  %@	  %@  %@  %@  %@",
                              strRoomName,strVisitTime,strOrderName,strCustomerCount,strCompanyName,strItemCount,strSelCom,strCom];

	cell.textLabel.text=cellShowStr;
	cell.textLabel.textAlignment=UITextAlignmentLeft;
	cell.textLabel.font = [UIFont systemFontOfSize:12];
	
    NSString *memberCD = [dic objectForKey:@"memberCD"];
	if ([memberCD length] > 0 && [memberCD intValue] > 0) {
        UIButton *btnCustomer = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btnCustomer.tag = indexPath.row;
        [btnCustomer setFrame:CGRectMake(550, 7, 80, 30)];
        [btnCustomer setTitle:@"情報" forState:UIControlStateNormal];
        [btnCustomer addTarget:self action:@selector(GoToCustomerAndOrder:) forControlEvents:UIControlEventTouchUpInside];
        [cell addSubview:btnCustomer];
    }
    
	if([[dic	objectForKey:@"wordsColorFlag"] isEqualToString:@"1"])
		cell.textLabel.textColor=[UIColor redColor];
    
	if(indexPath.row>=houseImageSelectedArray.count)
	{
		cell.imageView.image = [UIImage imageNamed:@"NotSelected.png"];
	}
	else 
	{
		if( [[ houseImageSelectedArray objectAtIndex:indexPath.row ] isEqualToString:@"1" ] ) 
		{
			cell.imageView.image = [UIImage imageNamed:@"IsSelected.png"];
		} 
		else 
		{
			cell.imageView.image = [UIImage imageNamed:@"NotSelected.png"];
		}
		
	}
    return cell;
}


-(UITableViewCell *)GetOrderDeleteInfoCell:(NSIndexPath *)indexPath{
    
    //用来标识窗格为一个普通窗格
	static NSString *MyIdentifierd = @"NormalCelld";
	
	//获取一个可复用窗格
	HouseViewCell *cell = (HouseViewCell *)[_tableView dequeueReusableCellWithIdentifier:MyIdentifierd];
    
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HouseViewCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }

    NSMutableDictionary *dic = [self.recordsDelete objectAtIndex:indexPath.row];
    NSString	*strRoomName=	  [common	formatCntStr:[dic objectForKey:@"roomName"] Count:6];
	NSString	*strVisitTime=    [common	formatCntStr:[dic objectForKey:@"visitTime"] Count:5];
	
	NSString	*strOrderName=    [common	formatCntStr:[dic objectForKey:@"orderName"] Count:6];
	NSString	*strCompanyName=  [common	formatCntStr:[dic objectForKey:@"companyName"] Count:6];
	NSString	*strCustomerCount=[common	formatCntStr:[dic objectForKey:@"customerCount"] Count:6];
	NSString	*strItemCount=    [common	formatCntStr:[dic objectForKey:@"itemCount"] Count:6]; 
	
	NSString	*strSelCom   =    [common	formatCntStr:[dic objectForKey:@"selComment"] Count:6]; 
	NSString	*strCom   =    [common	formatCntStr:[dic objectForKey:@"memo"] Count:6];
	
	NSString	*cellShowStr=[NSString	stringWithFormat:@"%@  %@	   %@  %@	  %@  %@  %@  %@",
                              strRoomName,strVisitTime,strOrderName,strCustomerCount,strCompanyName,strItemCount,strSelCom,strCom];
    
	cell.textLabel.text=cellShowStr;
	cell.textLabel.textAlignment=UITextAlignmentLeft;
	cell.textLabel.font = [UIFont systemFontOfSize:12];
	//cell.textLabel.textColor=[UIColor redColor];
    
    cell.imageView.image = [UIImage imageNamed:@"NotSelected.png"];

    return cell;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //liukeyu 20121016
    UITableViewCell * cell = nil;
    switch (indexPath.section) {
        case 0:
            cell = [self GetOrderInfoCell:indexPath];
            break;
        case 1:
            cell = [self GetOrderDeleteInfoCell:indexPath];
            break;
        default:
            break;
    }
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (self.recordsDelete == nil || [self.recordsDelete count]<=0) {
        return nil;
    }
    switch (section) {
        case 1:
            return @"削除履歴";
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section ==1) {
        return;
    }
	NSDictionary *dic = [records objectAtIndex:indexPath.row];
	
	NSString *lockFlag=[dic objectForKey:@"lockFlag"];
	if ([lockFlag isEqualToString:@"1"])								//部屋ロックの状態
	{
		NSString *lockHouseColor=[dic objectForKey:@"lockRoomColor"];
		cell.backgroundColor=[self	parseFenHao:lockHouseColor];
	}
	else																//部屋ロックではないの場合
	{
		NSString *_houseCellColor = [dic objectForKey:@"houseCellColor"];		//1.0,1.0,1.0,1.0  argb
		cell.backgroundColor = [self parseComma:_houseCellColor];
		
		//部屋名前とCD削除の場合は背景色は緑
		NSString *tmpOrderId = [dic valueForKey:@"OrderId"];
		NSString *tmpRoomCD = [dic valueForKey:@"roomCD"];
		NSString *tmpRoomName=[dic valueForKey:@"roomName"];
		
		if( (![tmpOrderId isEqualToString:@""]) && ([tmpRoomCD isEqualToString:@""]) && ([tmpRoomName isEqualToString:@""]) )
			cell.backgroundColor=[UIColor colorWithRed:0 green:1.0 blue:0 alpha:.5];
	}

	
	
}

//modify by liukeyu 2012-10-08 start
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}
//modify by liukeyu 2012-10-08 end
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    if (indexPath.section ==1) {
        return;
    }
	
	if (editingStyle == UITableViewCellEditingStyleDelete) 
	{
//		[records removeObjectAtIndex:indexPath.row];
//		
//		// remove the row from the table
//		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
//		
		
		
		UITableViewCell *delCell = [tableView cellForRowAtIndexPath:indexPath];	
		NSString *cellStr = [delCell textLabel].text;
		//modify by jinxin 2012-02-16 start
        //NSLog(@"%@",cellStr);
        //modify by jinxin 2012-02-16 start
		if([cellStr rangeOfString:@"人"].length >0)		//予約したのレコード
		{
			
	
			NSInteger recordNumber = [indexPath indexAtPosition: 1];
			NSMutableDictionary *delDic = [records objectAtIndex:recordNumber];
			[delDic setObject:@"" forKey:@"roomCD"];
			[delDic setObject:@"" forKey:@"roomName"];
			
			
			//データをsortする；   roomCD,roomName削除したのは一番上にする
			NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:0];
			for (int i=0; i<records.count; i++)													//最初のは部屋を削除したのデータ
			{
				NSString *tmpOrderId = [[records objectAtIndex:i] valueForKey:@"OrderId"];
				NSString *tmpRoomCD = [[records objectAtIndex:i] valueForKey:@"roomCD"];
				NSString *tmpRoomName=[[records objectAtIndex:i] valueForKey:@"roomName"];
				
				if( ((![tmpOrderId isEqualToString:@""]) && ([tmpRoomCD isEqualToString:@""]) && ([tmpRoomName isEqualToString:@""]))	||	
								((![tmpOrderId isEqualToString:@""]) && (![tmpRoomCD isEqualToString:@""]) && (![tmpRoomName isEqualToString:@""]))	||
								(([tmpOrderId isEqualToString:@""]) && (![tmpRoomCD isEqualToString:@""]) && (![tmpRoomName isEqualToString:@""])))
				{
					[tmpArr addObject:[records objectAtIndex:i]];
				}
			}
			
			[records removeAllObjects];
			NSMutableArray	*temCopy	=	[tmpArr copy];
			records = [[NSMutableArray alloc]initWithArray:temCopy];
			
			//[records addObject:[tmpArr copy]];	// = [addObject:[tmpArr copy];
			[tmpArr release];
			[temCopy	release];
			[_tableView reloadData];
		}
	}
}

//XMLの結果をフォマートする
- (NSString *)parseXmlResult: (NSString*)xmlString 
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theElement = [doc rootElement];
	NSString *strE = [[theElement childAtIndex:0] stringValue];
	
    
    
	return strE;
}


#pragma mark --close orderMenuview--
- (void)orderViewControllerDidClose:(OrderMenuViewController *)controller
{
    
	NSString *houseCD = controller.roomCD;
if(![self isUnLockSuccess:houseCD LockState:@"0"])									//部屋を解除する
{
	[common	showErrorAlert:@"この部屋は、既に予約しています。"];
}
    [_tableView deselectRowAtIndexPath:cell_selectIndex animated:NO];
	
    [self dismissModalViewControllerAnimated:YES];
	if(records)
	[records removeAllObjects];
	[self masteposInit];
	[self drawMsterHouse];
	[self getRoomData];

	
}



//accessor Button Tap
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	if (!isClearMode) //クリアモードではない
	{
		[common	showErrorAlert:@"[クリア]モードではない！"];
		return;
	}
	
	NSDictionary *dic = [records objectAtIndex:indexPath.row];
	NSString *lockFlag=[dic objectForKey:@"lockFlag"];
	if ([lockFlag isEqualToString:@"1"])								//部屋ロックの状態
	{
		[common	showErrorAlert:@"部屋ロックの場合は変更できない！"];
		return;
	}
	
	UITableViewCell *aCell = [tableView cellForRowAtIndexPath:indexPath];
	if(	![aCell.backgroundColor	isEqual:[UIColor colorWithRed:0 green:1.0 blue:0 alpha:.5]])
	{
		[common	showErrorAlert:@"[クリア]モードではない！"];
		return;
	}
	
	
	shouse = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
	[shouse addTarget:self action:@selector(DismissHouse:) forControlEvents:UIControlEventTouchUpInside];
	shouse.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.7];

	UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(50, 768, 600, 300)];		//一番下から
	[frameView setBackgroundColor:[UIColor grayColor]];
	[self.view addSubview:shouse];
	[shouse addSubview:frameView];
	
	UILabel *titleLabel= [[UILabel alloc] initWithFrame:CGRectMake(50, 768, 200, 40)];
	[titleLabel setText:@"部屋を選択ください！"];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	
	UILabel *titlePeopleLabel= [[UILabel alloc] initWithFrame:CGRectMake(250, 768, 220, 40)];
	[titlePeopleLabel setText:@"人数を入力してください！"];
	[titlePeopleLabel setTextAlignment:UITextAlignmentCenter];
	
	
	
	
	housePicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 50, 768, 200, 162 )] autorelease];
	[UIView beginAnimations:nil context:nil];
	
	housePicker.showsSelectionIndicator = YES;
	housePicker.tag = 0;
	housePicker.delegate = self;
	housePicker.dataSource = self;
	

	
	housePIckerChangePeopleCount = [PriceInput buttonWithType:UIButtonTypeCustom];
	[housePIckerChangePeopleCount setBackgroundImage:[UIImage imageNamed:@"inputField"] forState:UIControlStateNormal];
	[housePIckerChangePeopleCount setFrame:CGRectMake(50, 768, 200, 30)] ;
	[housePIckerChangePeopleCount setTag:indexPath.row] ;
	[housePIckerChangePeopleCount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal] ;
	
	
	UIButton *btnHouse = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnHouse setFrame:CGRectMake(70, 768, 100, 30)];
	[btnHouse setTitle:@"部屋を変更" forState:UIControlStateNormal];
	[btnHouse setTag:indexPath.row];
	[btnHouse addTarget:self action:@selector(changeHouse:) forControlEvents:UIControlEventTouchUpInside];
	

	UIButton *btnChangePeople = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnChangePeople setFrame:CGRectMake(70, 768, 100, 30)];
	[btnChangePeople setTitle:@"人数を変更" forState:UIControlStateNormal];
	[btnChangePeople setTag:indexPath.row];
	[btnChangePeople addTarget:self action:@selector(changePeople:) forControlEvents:UIControlEventTouchUpInside];
	
	
	UIButton *btnHousePeople = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnHousePeople setFrame:CGRectMake(70, 768, 120, 30)];
	[btnHousePeople setTitle:@"部屋と人数を変更" forState:UIControlStateNormal];
	[btnHousePeople setTag:indexPath.row];
	[btnHousePeople	addTarget:self action:@selector(changeHousePeople:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[frameView addSubview:titleLabel];
	[frameView addSubview:titlePeopleLabel];
	[frameView addSubview:housePicker];
	[frameView addSubview:housePIckerChangePeopleCount];
	[frameView addSubview:btnHouse];
	[frameView addSubview:btnChangePeople];
	[frameView addSubview:btnHousePeople];

	
	[frameView setFrame:CGRectMake(50, 300, 530, 400)];					//表示の場所
	
	[housePicker selectRow:0 inComponent:0 animated:NO];
	housePicker.frame = CGRectMake(50, 80, 200, 162);
	[housePIckerChangePeopleCount setFrame:CGRectMake(290, 80, 200, 30)];   //変更人数textField
	
	[btnHouse setFrame:CGRectMake(70, 250, 150, 30)];						//部屋変更のボタン
	[btnChangePeople setFrame:CGRectMake(320, 130, 150, 30)];				//部屋人数変更のボタン
	[btnHousePeople setFrame:CGRectMake(130, 320, 300, 30)];					//部屋と人数変更のボタン
	
	
	[titleLabel setFrame:CGRectMake(55, 30, 200, 30)];
	[titlePeopleLabel setFrame:CGRectMake(280, 30, 220, 30)];		   //変更人数label
	
	[UIView setAnimationDuration:2.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView commitAnimations];
	
	[self updateHousePicker];
	[frameView	release];
	[titleLabel	release];
	[titlePeopleLabel	release];
}



#pragma mark -
#pragma mark picker dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [houseData count];
}

#pragma mark -
#pragma mark picker delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return [[houseData objectAtIndex:row] valueForKey:@"RoomName"];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	housePicker.tag=row;
}

//- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	return YES;
//}
//
//- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
//{
//	NSLog([NSString stringWithFormat:@"from --%d===========to --%d",fromIndexPath,toIndexPath]);
//}


#pragma mark --HouseViewCellDelegate--
//詳細画面を転換する
- (void)singleTap:(HouseViewCell *)cell
{
//liukeyu add 2011-07-01 start
	NSString	*cellCD	=	cell.cellStr;
	NSString	*houseCD=nil;
	
	if([cellCD rangeOfString:@"【"].location!=NSNotFound)
	{
		cellCD=[cellCD	substringFromIndex:[cellCD	rangeOfString:@"【"].location+1];
		cellCD=[cellCD	substringToIndex:[cellCD	rangeOfString:@"】"].location];
		houseCD = cellCD;
	}
	if ([self	checkShopLock:houseCD])
 {
		[common	showErrorAlert:@"部屋ロックの状態入れない！"]	;
		return;
	}
//liukeyu add 2011-07-01 end
	
	if(editButton.hidden==YES)			//クリアモード；もう一個設定できない
	{return;}
	
	NSRange	range=[cell.cellStr	rangeOfString:@"人"];		//[cell.textLabel.text	rangeOfString:@"人"];	//空白の一行はクリアできない
	NSInteger number=	cell.number;	
	NSInteger	houseImageFlag=[[houseImageSelectedArray objectAtIndex:number] intValue];
	if(range.location!=NSNotFound)
	{
		//NSInteger number=	cell.number;				   //cellの番
		//NSInteger	houseImageFlag=[[houseImageSelectedArray objectAtIndex:number] intValue];
		houseImageFlag=houseImageFlag^ 1 ;					//0->1	1->0
	}
	else 
	{
//		NSInteger number=	cell.number;				   //cellの番
		houseImageFlag=0 ;
	}

	[houseImageSelectedArray replaceObjectAtIndex:number withObject:[NSString	stringWithFormat:@"%d",houseImageFlag]];
	
	[_tableView reloadData];	
}


- (void)doubleTap:(HouseViewCell *)cell
{
	if(isClearMode)
	{
		[common	showErrorAlert:@"[クリア]モード！"];
		return;
	}
	//[records removeAllObjects];
	//[self masteposInit];
	//[self drawMsterHouse];
//	[self getRoomData];
//	[_tableView	reloadData];
	
	
	//int rowNumber=cell.number;
//	//最新の番号を取る
//	for (int j=0; j<records.count; j++) 
//	{
//		NSString	*stroomCD=[[records	objectAtIndex:j]	valueForKey:@"roomCD"];
//		NSString	*cellCD	=cell.cellStr;				//cell.textLabel.text;
//		
//		if([cellCD rangeOfString:@"【"].location!=NSNotFound)
//		{
//			cellCD=[cellCD	substringFromIndex:[cellCD	rangeOfString:@"【"].location+1];
//			cellCD=[cellCD	substringToIndex:[cellCD	rangeOfString:@"】"].location];
//		}
//		if([cellCD	isEqualToString:stroomCD])
//		{
//			rowNumber=j;
//			break;
//		}
//		
//	}
//	
//	NSIndexPath	*indexPath=[NSIndexPath	indexPathForRow:rowNumber inSection:0];
//	self.cell_selectIndex=[indexPath copy];
	
	[self showDetailData:cell];
	
//	[self	updateWordFlag:indexPath];							//人数と料理数合わない、大丈夫Flag更新します
}


#pragma mark --clear モード--
- (IBAction)editButton:sender
{
//	if([self	isLockSuccess:@"1-200" LockState:@"1"])
//	{
	
	if (recordsClone) 
	{
		[recordsClone	removeAllObjects];
	}
	else
	{
		recordsClone=[[NSMutableArray	alloc] init];
	}
	//	recordsClone=[[NSMutableArray	alloc] init];
	//	recordsClone=(NSMutableArray*)CFPropertyListCreateDeepCopy(kCFAllocatorDefault,(CFPropertyListRef)records, kCFPropertyListMutableContainers);
		
		BOOL	isHaveChoice=FALSE;
	//	[self._tableView setEditing:TRUE animated:TRUE];
		
		for (int i=0; i<houseImageSelectedArray.count;i++) 
		{
			if( [[ houseImageSelectedArray objectAtIndex:i ] isEqualToString:@"1" ] )
			{
				NSIndexPath	*indexPath=[NSIndexPath	indexPathForRow:i inSection:0];				//空白の一行の場合は選択できない
				UITableViewCell *selCell = [_tableView cellForRowAtIndexPath:indexPath];	
				NSString *cellStr = [selCell textLabel].text;
				if ([cellStr rangeOfString:@"人"].location==NSNotFound) 
				{
					break;
				}
				
				
				isClearMode=YES;
				isHaveChoice=TRUE;
				NSMutableDictionary *delDic = [records objectAtIndex:i];			
				
				NSMutableDictionary *delDicCopy=[delDic	copy];
				
				//[recordsClone	addObject:[delDic	copy]];
				[recordsClone	addObject:delDicCopy];
				[delDic setObject:@"" forKey:@"roomCD"];
				[delDic setObject:@"" forKey:@"roomName"];
				[delDicCopy	release];
			}
		}
		if(isHaveChoice)
		{
			[self	resortData];			//デーだを順番にする[roomCD roomName削除のdata]
			[self changeHouseNewNo:@"0" newNo:@"0"];
			[editButton setHidden:YES];
			[doneButton setHidden:NO];
		}else
		{
			[common	showErrorAlert:@"部屋を選択してください!"];
		}
//	}

}

//done mode
- (IBAction)doneButton:sender
{
//	if([self isUnLockSuccess:@"1-200" LockState:@"1"])
//	{
		[recordsClone	removeAllObjects];
//		if(isClearMode)
//		{
//			
//		}
		isClearMode=FALSE;
		
	//	UITableViewCell *selCell = [_tableView cellForRowAtIndexPath:indexPath];	 
	//	id	bb=_tableView;
		
		[self housePeopleRoomUpdate];
		[clearModeChangeHousePeople removeAllObjects];
		
	//	[self._tableView setEditing:FALSE animated:TRUE];
		[editButton setHidden:NO];
		[doneButton setHidden:YES];	
	//}

}

//部屋　人数を変更
- (void)housePeopleRoomUpdate
{
	BOOL	update	=	YES;
	for (int m=0; m<records.count; m++) 
	{
		NSDictionary	*tmpdic=[records	objectAtIndex:m];
		NSString		*strOrderId=[tmpdic valueForKey:@"OrderId"];
		NSString	*strRoomCd	=[tmpdic valueForKey:@"roomCD"];
		
		if(![strOrderId isEqualToString:@""])
		{
			for (int n=0; n<clearModeChangeHousePeople.count; n++) 
			{
					NSDictionary	*cmDic	=[clearModeChangeHousePeople	objectAtIndex:n];
					if (![strOrderId	isEqualToString:[cmDic	valueForKey:@"OrderId"]]) 
					{
						if ([strRoomCd	isEqualToString:[cmDic	valueForKey:@"roomCD"]]) 
						{
							update	=	FALSE;
							break;
						}
						else	if([[cmDic	valueForKey:@"roomCD"]	rangeOfString:@"_"].location!=NSNotFound	||	[strRoomCd	rangeOfString:@"_"].location!=NSNotFound) 
						{
							NSArray	*changeRoomCd	=	[strRoomCd	componentsSeparatedByString:@"_"];
							
							NSArray	*fromRoomCd	=	[[cmDic	valueForKey:@"roomCD"]	componentsSeparatedByString:@"_"];

							for (int	i=0;i<changeRoomCd.count ;i++ ) 
							{
								NSString	*selectCD = [changeRoomCd objectAtIndex:i];
								for (int	j=0; j<fromRoomCd.count;j++ ) 
								{
									if ([selectCD	isEqualToString:[fromRoomCd objectAtIndex:j]]) 
									{
										update	=	FALSE;
										break;
									}	
								}
								if (!update) 
								{
									break;
								}
							}
						}
					}
					if (!update) 
					{
						break;
					}
				}
				if (!update) 
				{
					break;
				}
			}
		}
	if (update) 
	{
		NSMutableString *clrStr=[NSMutableString	stringWithString:@"["];

		for (int i=0; i<clearModeChangeHousePeople.count; i++) {
			NSDictionary	*cmDic	=[clearModeChangeHousePeople	objectAtIndex:i];
			NSString	*peopleCount=[cmDic	valueForKey:@"customerCount"];
			if([peopleCount rangeOfString:@"人"].location!=NSNotFound)
			{
				peopleCount=[peopleCount	substringToIndex:peopleCount.length-1];
			}
		
			clrStr=[clrStr	stringByAppendingFormat:@"<%@;",[cmDic	valueForKey:@"OrderId"]];
			clrStr=[clrStr	stringByAppendingFormat:@"%@;",[cmDic	valueForKey:@"roomCD"]];
			clrStr=[clrStr	stringByAppendingFormat:@"%@;",[cmDic	valueForKey:@"houseCellColor"]];
			clrStr=[clrStr	stringByAppendingFormat:@"%@>",peopleCount];
		}
//	clrStr=[clrStr	stringByAppendingString:@"]"];
//	id	aa=clrStr;
	
	//残るのデータ
//	for (int i=clearModeChangeHousePeople.count; i<records.count; i++) 
//	{
//		NSDictionary	*tmpdic=[records	objectAtIndex:i];
//		NSString		*strOrderId=[tmpdic valueForKey:@"OrderId"];
//		
//		if(![strOrderId isEqualToString:@""])
//		{
//			NSString	*peopleCount=[tmpdic	valueForKey:@"customerCount"];
//			if([peopleCount rangeOfString:@"人"].location!=NSNotFound)
//			{
//				peopleCount=[peopleCount	substringToIndex:peopleCount.length-1];
//			}
//			
//			clrStr=[clrStr	stringByAppendingFormat:@"<%@;",[tmpdic	valueForKey:@"OrderId"]];
//			clrStr=[clrStr	stringByAppendingFormat:@"%@;",[tmpdic	valueForKey:@"roomCD"]];
//			clrStr=[clrStr	stringByAppendingFormat:@"%@;",[tmpdic	valueForKey:@"houseCellColor"]];
//			clrStr=[clrStr	stringByAppendingFormat:@"%@>",peopleCount];
//		}
//	}
	
	
		clrStr=[clrStr	stringByAppendingString:@"]"];
	
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateRoomToOrderTableAll"]]];
		[request setPostValue:clrStr forKey:@"Keys"];
		[request setRequestMethod:@"POST"];
	
		[request startSynchronous];
		NSString *str = [request responseString];
		str=[common formateXmlString:str];
	
	
		CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
		CXMLElement *theDoc = [doc rootElement];
		NSString	*strResult=[theDoc stringValue];
	
		if ([strResult isEqualToString:@"true"]) 
		{
			[common showSuccessAlert:@"部屋変更しました！"];
		}
		else 
		{
			[common showErrorAlert:@"変更失敗しました！"];
		}
	}
	else 
	{
		[common showErrorAlert:@"変更失敗しました！"];
	}

	[records removeAllObjects];
	[self masteposInit];
	[self drawMsterHouse];
	[self getRoomData];
}

//roomCD;roomName削除しての場合はデータの一番にする
- (void)resortData
{
	[houseImageSelectedArray	removeAllObjects];
	[self	houseImageSelectedArrayInit];
	
	//データをsortする；   roomCD,roomName削除したのは一番上にする
	NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithCapacity:0];
	for (int i=0; i<records.count; i++)													//最初のは部屋を削除したのデータ
	{
		NSString *tmpOrderId = [[records objectAtIndex:i] valueForKey:@"OrderId"];
		NSString *tmpRoomCD = [[records objectAtIndex:i] valueForKey:@"roomCD"];
		NSString *tmpRoomName=[[records objectAtIndex:i] valueForKey:@"roomName"];
		
		if( (![tmpOrderId isEqualToString:@""]) && ([tmpRoomCD isEqualToString:@""]) && ([tmpRoomName isEqualToString:@""]) )
		{
			[tmpArr addObject:[records objectAtIndex:i]];
		}
		
	}
	
	for (int p=0; p<records.count; p++)													//次は普通のデータ
	{
		NSString *tmppOrderId = [[records objectAtIndex:p] valueForKey:@"OrderId"];
		NSString *tmppRoomCD = [[records objectAtIndex:p] valueForKey:@"roomCD"];
		NSString *tmppRoomName=[[records objectAtIndex:p] valueForKey:@"roomName"];
		
		if( (![tmppOrderId isEqualToString:@""]) && (![tmppRoomCD isEqualToString:@""]) && (![tmppRoomName isEqualToString:@""]) )
			[tmpArr addObject:[records objectAtIndex:p]];
		
	}
	
	for (int q=0; q<records.count; q++)													//最後は空いてのデータ
	{
		NSString *tmpqOrderId = [[records objectAtIndex:q] valueForKey:@"OrderId"];
		NSString *tmpqRoomCD = [[records objectAtIndex:q] valueForKey:@"roomCD"];
		NSString *tmpqRoomName=[[records objectAtIndex:q] valueForKey:@"roomName"];
		
		if( ([tmpqOrderId isEqualToString:@""]) && (![tmpqRoomCD isEqualToString:@""]) && (![tmpqRoomName isEqualToString:@""]) )
			[tmpArr addObject:[records objectAtIndex:q]];
		
	}
	
	[records removeAllObjects];
	NSMutableArray	*tmpArrCopy=[tmpArr	copy];
	if (records)
 {
		[records	release];
	}
	records = [[NSMutableArray alloc]initWithArray:tmpArrCopy];
	
	//[records addObject:[tmpArr copy]];	// = [addObject:[tmpArr copy];
	[tmpArr release];
	[tmpArrCopy	release];
	[_tableView reloadData];
}

//人数と料理数合わない；確認して	Flagを更新します
-	(void)updateWordFlag:(NSIndexPath *)indexPath
{
	NSString	*LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString	*orderid=[[records objectAtIndex:indexPath.row] objectForKey:@"OrderId"];
	NSString	*strPost=[NSString	stringWithFormat:@"%@;%@;%@",LoginId,orderid,@"0"];
	
	if([orderid length]==0)
		return;
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateWordsColorFlag"]]];
	[request setPostValue:strPost forKey:@"keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
//	id cc =[xmlDoc	stringValue];
	
	[xmlDoc	release];
//	if([@"true" isEqualToString:[[xmlDoc childAtIndex:0] stringValue]])
//	{
//		[common showSuccessAlert:@"Success"];
//	}
//	else
//	{
//		[common showErrorAlert:@"失敗しました！"];
//	}
}




-	(void)showMenuVC:(OrderMenuViewController *)orderMenuViewController
{
	[self presentModalViewController:orderMenuViewController animated:NO];
}

//ダブルクリークすると、詳しい情報画面のデータを用意する
- (void)showDetailData:(HouseViewCell *)cell
{
    
	NSString *houseCD = @"";
	NSString *omRoomName = @"";
	NSString *_hhouseCellColor = [NSString stringWithString:cell.cellColor];
	NSString *cellOrderId = [NSString stringWithString:cell.cellOrderId];
	NSString *cellCD = [NSString stringWithString:cell.cellStr];
	
	if([cellCD rangeOfString:@"【"].location!=NSNotFound){
		omRoomName=[cellCD substringToIndex:[cellCD	rangeOfString:@"【"].location];
		cellCD=[cellCD	substringFromIndex:[cellCD	rangeOfString:@"【"].location+1];
		cellCD=[cellCD	substringToIndex:[cellCD	rangeOfString:@"】"].location];
		houseCD = cellCD;
	}
    
	///---lock house---------

	//liu add 2011-05-26
	if (houseCD	== nil || houseCD.length <=0)return;
    
	if([houseCD rangeOfString:@"_"].location!=NSNotFound)
	{
		roomCDArr	=	[[NSMutableArray	alloc]	init];
		[self splitRoomCD:houseCD];
		for (int	i=0;i<roomCDArr.count ;i++ ) 
		{
			NSString	*selectCD = [roomCDArr objectAtIndex:i];
			if ([self	checkShopLock:selectCD]) 
			{
				[common	showSuccessAlert:[NSString	stringWithFormat:@"No%@部屋ロックの状態入れない！",selectCD]]	;
				[roomCDArr release];
				return;
			}
		}
		[roomCDArr	release];
	}
    
	//liu add end 2011-05-26
	
	
	if(![self isLockSuccess:houseCD LockState:@"0"])
    {
        [common	showSuccessAlert:@"部屋ロックの状態入れない！"];
        return;
    }
			//------------------------------------------------------------
    OrderMenuViewController *orderMenuViewController = [[OrderMenuViewController alloc] initWithNibName:@"OrderMenuViewController" bundle:nil];
    orderMenuViewController.delegate = self;
    orderMenuViewController.shopId =shopId;										
    orderMenuViewController.roomName = omRoomName;
    orderMenuViewController.roomCD=houseCD;
			
    NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
    strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
    strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
    orderMenuViewController.dateStr = strdate;
			
    NSString   *red = [self parseStrRedColor:_hhouseCellColor];
    orderMenuViewController.redValue =  (float)[red floatValue];
			
	NSString   *green =[self parseStrGreenColor:_hhouseCellColor];
	orderMenuViewController.greenValue = (float)[green floatValue];
			
	NSString    *blue = [self parseStrBlueColor:_hhouseCellColor];
	orderMenuViewController.blueValue  = (float)[blue floatValue];
			
	orderMenuViewController.orderId = cellOrderId;
    orderMenuViewController.isDayOrNight = hIsDayOrNight;
    
    if(![cellOrderId isEqualToString:@""])	//更新
    {
        //@"[003;62;６号室;03-0062-0001;2011/2/28 12:30;2011/2/18;小田運送株式会社;三神　良子;三神　良子1;18;36;南向こうの個室;{<menu>1234567;雪会席;8,000;18</menu><menu>1234567;雪会席;8,000;18</menu>}]"
        NSString *visitTime	= [cell.cellStr	substringFromIndex:[cell.cellStr rangeOfString:@"】"].location+4];
        orderMenuViewController.visitTime = [visitTime substringWithRange:NSMakeRange(0,5)];
		orderMenuViewController.isUpdateOrInsert = @"1";
		
    }
	else //新規
	{
    		
		orderMenuViewController.isUpdateOrInsert = @"0";
                
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [path stringByAppendingPathComponent:@"hisRecords.dat"];
        NSMutableArray *hisRecordsDefault = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
                
		orderMenuViewController.mrecords = hisRecordsDefault;      //if use history order;
        NSFileManager *fileManage = [NSFileManager defaultManager];
        if ([fileManage isDeletableFileAtPath:filePath]) {
            [fileManage removeItemAtPath:filePath error:nil];
        }
                 
    }
			
    //[self performSelector:@selector(showMenuVC:) withObject:orderMenuViewController afterDelay:0.1];
    [self presentModalViewController:orderMenuViewController animated:YES];
	[orderMenuViewController release];
}

//liu	add	start	11-05-26
-	(void)splitRoomCD:(NSString	*)houseCD
{
	
	if ([houseCD	rangeOfString:@"_"].location	!=	NSNotFound) 
	{
			NSString	*	roomID	=	[houseCD	substringToIndex:[houseCD	rangeOfString:@"_"].location];
			NSString	*	houseID	=	[houseCD	substringFromIndex:[houseCD	rangeOfString:@"_"].location+1];
			[roomCDArr	addObject:roomID];
			[self	splitRoomCD:houseID];
	}
	else 
	{
			[roomCDArr	addObject:houseCD];
			return;
	}

}
//liu	add	start	11-05-26

#pragma mark ----カレンダーの日付を変更---
- (IBAction)calButton:sender
{
//	NSLog(@"--------------------calendar----------------");
	[memoTextView setText:@""];
	
	scal = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
	[scal addTarget:self action:@selector(DismissCalendar:) forControlEvents:UIControlEventTouchUpInside];
	scal.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.7];
	
	UIView *frameViewCal = [[UIView alloc] initWithFrame:CGRectMake(200, 768, 300, 300)];
	[frameViewCal setBackgroundColor:[UIColor grayColor]];
	[self.view addSubview:scal];
	[scal addSubview:frameViewCal];
	
	UILabel *titleLabelCal= [[UILabel alloc] initWithFrame:CGRectMake(50, 768, 200, 40)];
	[titleLabelCal setText:@"日付を選択ください！"];
	[titleLabelCal setTextAlignment:UITextAlignmentCenter];
	
	theDatePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake( 20, 768, 250, 162 )] autorelease];
	theDatePicker.datePickerMode = UIDatePickerModeDate;
	
	NSDateFormatter *formatterCal = [[[NSDateFormatter alloc] init] autorelease]; 
	//formatterCal.dateFormat = @"yyyy年MM月dd日";
	[formatterCal	setDateFormat:@"yyyy年M月d日"];
	
	NSDate	*dateShow	=	[formatterCal	dateFromString:dateString];
	[theDatePicker	setDate:dateShow];
	[UIView beginAnimations:nil context:nil];
	
	
	UIButton *btnCal = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btnCal setFrame:CGRectMake(70, 768, 100, 30)];
	[btnCal setTitle:@"O K" forState:UIControlStateNormal];
	[btnCal addTarget:self action:@selector(changeCalendar:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[frameViewCal addSubview:titleLabelCal];
	[frameViewCal addSubview:theDatePicker];
	[frameViewCal addSubview:btnCal];
	

	[frameViewCal setFrame:CGRectMake(50, 300, 300, 300)];	//200,80 300,300
	theDatePicker.frame = CGRectMake(20, 80, 250, 162);
//	[theDatePicker selectRow:0 inComponent:0 animated:NO];
	
	[btnCal setFrame:CGRectMake(70, 240, 150, 50)];
	[titleLabelCal setFrame:CGRectMake(55, 30, 200, 30)];
	
	[UIView setAnimationDuration:2.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView commitAnimations];
	[frameViewCal	release];
	[titleLabelCal	release];
}

//change calendar click
- (void)changeCalendar:sender
{
	NSDateFormatter *formatterCal = [[[NSDateFormatter alloc] init] autorelease]; 
	formatterCal.dateFormat = @"yyyy年M月d日"; 
	NSString *timestampCal = [formatterCal stringFromDate:theDatePicker.date]; 
	[dateLabel setTitle:timestampCal forState:UIControlStateNormal];
	dateString = timestampCal;
	
	NSDateFormatter *weekFormatterCal = [[[NSDateFormatter alloc] init] autorelease]; 
	
 [weekFormatterCal	setDateFormat:@"EEEE"];
	
	NSString *weekTampCal = [weekFormatterCal stringFromDate:theDatePicker.date]; 
	[weekLabel	setText:weekTampCal];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	VisitDate = strdate;
	
	[self DismissCalendar:scal];
	
	
	[records removeAllObjects];
	[self masteposInit];
	[self drawMsterHouse];
	[self getRoomData];
}

-(void)DismissCalendar:(id)p
{
	[UIView beginAnimations:nil context:p];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	//	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	if (UIInterfaceOrientationLandscapeLeft == [UIApplication sharedApplication].statusBarOrientation) {
		
	}
	
	scal.frame = CGRectMake( 0, 768, 1024, 748 );
	[UIView commitAnimations];
}

//liukeyu add 20110707 start
-(BOOL) changeHouseNewNo:(NSString	*)orderId newNo:(NSString*)changeNo
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"changeHouseNewNo"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:orderId forKey:@"orderId"];
	
	[request setPostValue:changeNo forKey:@"newRoomCD"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	if([[[xmlDoc childAtIndex:0] stringValue] isEqualToString:@"yes"])
	{
		[xmlDoc	release];
		return YES;
	}
	else
	{
		[xmlDoc	release];
		return FALSE;
	}
}
//liukeyu add 20110707 end

#pragma mark --部屋を変更する--
- (void)changeHouse:sender
{
	BOOL	isAdd=TRUE;
	NSDictionary *dic = [records objectAtIndex:[sender tag]];	
	
	NSString	*orderId=		[dic	objectForKey:@"OrderId"];
	NSString	*customerCount=[dic	objectForKey:@"customerCount"];
	NSString	*toRoomCDStr = [[houseData objectAtIndex:housePicker.tag] valueForKey:@"RoomCD"];
	NSString	*houseCellColor	=	[dic	objectForKey:@"houseCellColor"];
	if ([houseCellColor isEqualToString:@"0.500000,0.000000,1.000000,0.000000"]) {
		houseCellColor =	@"1.000000,1.000000,1.000000,1.000000";
	}
//	if([toRoomCDStr rangeOfString:@"["].location!=NSNotFound)
//	{
//		toRoomCDStr=[toRoomCDStr	substringFromIndex:[toRoomCDStr	rangeOfString:@"["].location+1];
//		toRoomCDStr=[toRoomCDStr	substringToIndex:toRoomCDStr.length-1];
//	}
	
//	for (int i=0; i<records.count; i++) {								//changeto部屋　islock or not
//		NSDictionary *dicc = [records objectAtIndex:i];
//		NSString	*tormId=[dicc	objectForKey:@"roomCD"];
//		
//		if([toRoomCDStr isEqualToString:tormId])						//toChangeRoomId 
//		{
//			NSString *lockFlag=[dicc objectForKey:@"lockFlag"];
//			if ([lockFlag isEqualToString:@"1"])
//			{
//				[common	showErrorAlert:@"部屋ロックしました,別の部屋選択してください!"];
//				return;
//			}
//			
//		}
//		
//	}
	
	//liu	add	start	2011-05-31
	roomCDArr	=	[[NSMutableArray	alloc]	init];
	[self	splitRoomCD:toRoomCDStr];
	for (int	i=0;i<roomCDArr.count ;i++ ) 
	{
		NSString	*selectCD = [roomCDArr objectAtIndex:i];
		if ([self	checkShopLock:selectCD]) 
		{
			[common	showSuccessAlert:[NSString	stringWithFormat:@"No%@部屋ロックしました,別の部屋選択してください!",selectCD]]	;
			[roomCDArr	release];
			return;
		}
	}
	[roomCDArr	release];
		
	//liu	add	end	2011-05-31
	
	NSArray	*key=[NSArray	arrayWithObjects:@"OrderId",@"roomCD",@"customerCount",@"houseCellColor",nil];
	NSMutableArray	*value=[NSMutableArray	arrayWithObjects:orderId,toRoomCDStr,customerCount,houseCellColor,nil];
	NSMutableDictionary	*tmdic=[NSMutableDictionary	dictionaryWithObjects:value forKeys:key];
	if (![self changeHouseNewNo:orderId newNo:toRoomCDStr])
 {
		[common	showErrorAlert:@"部屋を変更失敗!"];
		return;
	}
	
	for (int i=0;i<clearModeChangeHousePeople.count;i++)					//同じレコードを修正の場合
	{
		NSMutableDictionary*dicc=[clearModeChangeHousePeople	objectAtIndex:i];
		if([[dicc valueForKey:@"OrderId"] isEqualToString:orderId])
		{
			[dicc	setObject:toRoomCDStr forKey:@"roomCD"];
			isAdd=FALSE;
			break;
		}
	}
	
	
	if(isAdd)
		[clearModeChangeHousePeople addObject:tmdic];
	
	[self DismissHouse:sender];

	//-----------表示を更新する---------------//	
	UITableViewCell *selCell = [_tableView cellForRowAtIndexPath:[NSIndexPath	indexPathForRow:[sender tag] inSection:0]];
	NSString	*changeStr=@"";		
	NSString	*tmpname=[[houseData objectAtIndex:housePicker.tag] valueForKey:@"RoomName"];			

	changeStr=[NSString	stringWithFormat:@"   %@         ",tmpname];
	int	beginPos	=	[selCell.textLabel.text	rangeOfString:@":"].location;
	changeStr=			[changeStr	stringByAppendingString:[selCell.textLabel.text	substringFromIndex:beginPos-2]];
	selCell.textLabel.text=changeStr;

}



//人数のみ変更する
- (void)changePeople:(id)sender
{	
	BOOL	isAdd=TRUE;
	NSDictionary *dic = [records objectAtIndex:[sender tag]];	
	
	NSString	*orderId=		[dic	objectForKey:@"OrderId"];
	NSString	*customerCount=	housePIckerChangePeopleCount.titleLabel.text;
	NSString	*toRoomCDStr = [dic objectForKey:@"roomCD"];
	NSString	*houseCellColor	=	[dic	objectForKey:@"houseCellColor"];
	if ([houseCellColor isEqualToString:@"0.500000,0.000000,1.000000,0.000000"]) {
		houseCellColor =	@"1.000000,1.000000,1.000000,1.000000";
	}
	
	if([customerCount length]==0)
		return;
	
	NSInteger	numCheck	=	[customerCount	intValue];
	if ([customerCount	rangeOfString:@"-"].location!=NSNotFound	||	numCheck	<=0) 
	{
		[common	showErrorAlert:@"人数が正しく入力してください。"];
		return;
	}
	
	NSArray	*key=				[NSArray	arrayWithObjects:@"OrderId",@"roomCD",@"customerCount",@"houseCellColor",nil];
	NSMutableArray	*value=		[NSMutableArray	arrayWithObjects:orderId,toRoomCDStr,customerCount,houseCellColor,nil];
	NSMutableDictionary	*tmdic=[NSMutableDictionary	dictionaryWithObjects:value forKeys:key];
	
	
	for (int i=0;i<clearModeChangeHousePeople.count;i++)					//同じレコードを修正の場合
	{
		NSMutableDictionary*dicc=[clearModeChangeHousePeople	objectAtIndex:i];
		if([[dicc valueForKey:@"OrderId"] isEqualToString:orderId])
		{
			[dicc	setObject:customerCount forKey:@"customerCount"];
			isAdd=FALSE;
			break;
		}
	}
	
	
	if(isAdd)
		[clearModeChangeHousePeople addObject:tmdic];
	[self DismissHouse:sender];
	
	
	//-----------表示を更新する---------------//	
/*	UITableViewCell *selCell = [_tableView cellForRowAtIndexPath:[NSIndexPath	indexPathForRow:[sender tag] inSection:0]];
	int	beginPos	=	[selCell.textLabel.text	rangeOfString:@":"].location;
	
	NSDictionary *dicp = [recordsClone objectAtIndex:[sender tag]];
	NSString	*strRoomName_CD=[NSString	stringWithFormat:@"   %@  【%@】         ",[dicp objectForKey:@"roomName"],[dicp objectForKey:@"roomCD"]];
	
	
	NSString *strCell = [NSString stringWithFormat:@"%@     %@　   %@     %@　    %@人      %@       %@		%@",strRoomName_CD,[dicp objectForKey:@"visitTime"],[dicp objectForKey:@"companyName"],
						 [dicp objectForKey:@"orderName"],customerCount,[dicp objectForKey:@"itemCount"],[dicp objectForKey:@"selComment"],[dicp objectForKey:@"memo"]];

	selCell.textLabel.text=strCell;
*/	
	
	HouseViewCell *selCell = (HouseViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath	indexPathForRow:[sender tag] inSection:0]];
//	int	beginPos	=	[selCell.cellStr	rangeOfString:@":"].location;
	
	NSDictionary *dicp = [recordsClone objectAtIndex:[sender tag]];
	NSString	*strRoomName_CD=[NSString	stringWithFormat:@"   %@         ",[dicp objectForKey:@"roomName"]];
	
	
	NSString *strCell = [NSString stringWithFormat:@"%@     %@　   %@     %@　    %@人      %@       %@		%@",strRoomName_CD,[dicp objectForKey:@"visitTime"],[dicp objectForKey:@"companyName"],
						 [dicp objectForKey:@"orderName"],customerCount,[dicp objectForKey:@"itemCount"],[dicp objectForKey:@"selComment"],[dicp objectForKey:@"memo"]];
	
	selCell.textLabel.text=strCell;
	
	
	
	//itemcount<peopleCount 色は赤
	int peopleCount=[customerCount	intValue];
	int itemCount=[[dicp objectForKey:@"itemCount"]	intValue];
	if(itemCount<peopleCount)
	{
		selCell.textLabel.textColor=[UIColor	redColor];
	}
	else 
	{
		selCell.textLabel.textColor=[UIColor	blackColor];
	}

}

//部屋と人数変更する
- (void)changeHousePeople:(id)sender
{
	BOOL	isAdd=TRUE;
	NSDictionary *dic = [records objectAtIndex:[sender tag]];	
	
	NSString	*orderId=		[dic	objectForKey:@"OrderId"];
	NSString	*customerCount=	housePIckerChangePeopleCount.titleLabel.text;
	NSString	*toRoomCDStr =	[[houseData objectAtIndex:housePicker.tag] valueForKey:@"RoomCD"];
	NSString	*houseCellColor	=	[dic	objectForKey:@"houseCellColor"];
	if ([houseCellColor isEqualToString:@"0.500000,0.000000,1.000000,0.000000"]) {
		houseCellColor =	@"1.000000,1.000000,1.000000,1.000000";
	}
	
	if([customerCount length]==0)
		return;
	
	NSInteger	numCheck	=	[customerCount	intValue];
	if ([customerCount	rangeOfString:@"-"].location!=NSNotFound	||	numCheck	<=0) 
	{
		[common	showErrorAlert:@"人数が正しく入力してください。"];
		return;
	}
//	if([toRoomCDStr rangeOfString:@"["].location!=NSNotFound)
//	{
//		toRoomCDStr=[toRoomCDStr	substringFromIndex:[toRoomCDStr	rangeOfString:@"["].location+1];
//		toRoomCDStr=[toRoomCDStr	substringToIndex:toRoomCDStr.length-1];
//	}
	
	for (int i=0; i<records.count; i++) {								//changeto部屋　islock or not
		NSDictionary *dicc = [records objectAtIndex:i];
		NSString	*tormId=[dicc	objectForKey:@"roomCD"];
		
		if([toRoomCDStr isEqualToString:tormId])						//toChangeRoomId 
		{
			NSString *lockFlag=[dicc objectForKey:@"lockFlag"];
			if ([lockFlag isEqualToString:@"1"])
			{
				[common	showErrorAlert:@"部屋ロックしました,別の部屋選択してください!"];
				return;
			}
			
		}
		
	}
	
	
	NSArray	*key=[NSArray	arrayWithObjects:@"OrderId",@"roomCD",@"customerCount",@"houseCellColor",nil];
	NSMutableArray	*value=[NSMutableArray	arrayWithObjects:orderId,toRoomCDStr,customerCount,houseCellColor,nil];
	NSMutableDictionary	*tmdic=[NSMutableDictionary	dictionaryWithObjects:value forKeys:key];
	
	[self changeHouseNewNo:orderId newNo:toRoomCDStr];
	
	for (int i=0;i<clearModeChangeHousePeople.count;i++)					//同じレコードを修正の場合
	{
		NSMutableDictionary*dicc=[clearModeChangeHousePeople	objectAtIndex:i];
		if([[dicc valueForKey:@"OrderId"] isEqualToString:orderId])
		{
			[dicc	setObject:toRoomCDStr forKey:@"roomCD"];
			[dicc	setObject:customerCount forKey:@"customerCount"];
			isAdd=FALSE;
			break;
		}
	}
	
	
	if(isAdd)
		[clearModeChangeHousePeople addObject:tmdic];
	
	//	[self chageHouseToNew:old	NewHouse:new];
	[self DismissHouse:sender];
	
	//-----------表示を更新する---------------//	
/*	UITableViewCell *selCell = [_tableView cellForRowAtIndexPath:[NSIndexPath	indexPathForRow:[sender tag] inSection:0]];
	NSDictionary *dicp = [recordsClone objectAtIndex:[sender tag]];
	int	beginPos	=	[selCell.textLabel.text	rangeOfString:@":"].location;
*/	
	HouseViewCell *selCell = (HouseViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath	indexPathForRow:[sender tag] inSection:0]];
	NSDictionary *dicp = [recordsClone objectAtIndex:[sender tag]];
	//int	beginPos	=	[selCell.cellStr rangeOfString:@":"].location;
	
	NSString	*changeStr=@"";			
	NSString	*tmpname=[[houseData objectAtIndex:housePicker.tag]	 valueForKey:@"RoomName"];		


	
	
//	NSString	*tmpid=[tmpArr objectAtIndex:0];
//	NSString	*tmpname=[tmpArr objectAtIndex:1];
//	tmpname=[tmpname substringToIndex:tmpname.length-1];
/*	
	NSString	*strRoomName_CD=[NSString	stringWithFormat:@"   %@  【%@】         ",tmpid,tmpname];
	NSString *strCell = [NSString stringWithFormat:@"%@     %@　   %@     %@　    %@人      %@       %@		%@",strRoomName_CD,[dicp objectForKey:@"visitTime"],[dicp objectForKey:@"companyName"],
						 [dicp objectForKey:@"orderName"],customerCount,[dicp objectForKey:@"itemCount"],[dicp objectForKey:@"selComment"],[dicp objectForKey:@"memo"]];
	selCell.textLabel.text=strCell;
*/	
	
	NSString	*strRoomName_CD=	[NSString	stringWithFormat:@"   %@         ",tmpname];
	NSString	*strCell	   =    [NSString stringWithFormat:@"%@     %@　   %@     %@　    %@人      %@       %@		%@",strRoomName_CD,[dicp objectForKey:@"visitTime"],[dicp objectForKey:@"companyName"],
									[dicp objectForKey:@"orderName"],customerCount,[dicp objectForKey:@"itemCount"],[dicp objectForKey:@"selComment"],[dicp objectForKey:@"memo"]];
	selCell.textLabel.text=strCell;
	
	//itemcount<peopleCount 色は赤
	int	peopleCount=[customerCount	intValue];
	int	itemCount=[[dicp objectForKey:@"itemCount"]	intValue];
	if(itemCount<peopleCount)
		selCell.textLabel.textColor=[UIColor	redColor];
	
}

/*
//from oldHouse to newHouse
- (void)chageHouseToNew:(NSString *)oldHouse NewHouse:(NSString *)toHouse
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",LoginId,shopId,oldHouse,toHouse,VisitDate,hIsDayOrNight];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateRoomToOrderTable"]]];
	[request setPostValue:strPost forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	NSString	*strResult=[theDoc stringValue];
	
	if ([strResult isEqualToString:@"1"]) 
	{
		[common showSuccessAlert:@"部屋変更しました！"];
	}
	else 
	{
		[common showErrorAlert:@"error"];
	}
	
	[records removeAllObjects];
	[self masteposInit];
	[self drawMsterHouse];
	[self getRoomData];
}

*/

//get the emptyhouse's list
- (void)updateHousePicker
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,strdate,hIsDayOrNight];
	
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetEmptyRoomList"]]];
	[request setPostValue:strPost forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	[self parseHouseXml:str];
}

- (void)parseHouseXml:(NSString *)emptyHouseList
{
	emptyHouseList = [emptyHouseList stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:emptyHouseList options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//item" error:&error];
	
	
	[xmlDoc	release];	
	DDXMLNode		*team;
	NSString		*romName;
	NSString		*romCD;
	NSArray			*key=[NSArray	arrayWithObjects:@"RoomName",@"RoomCD",nil];
	NSMutableArray  *emptyHouseArr=[[NSMutableArray	alloc] init];
	
	for (int j=0; j<resultNodes.count; j++) 
	{
		team =[resultNodes	objectAtIndex:j];
		NSArray *itemArrs = [team children];
		if(itemArrs.count==0)
			continue;
		
		romName=[[itemArrs objectAtIndex:0] stringValue];	
		romCD  =[[itemArrs objectAtIndex:1] stringValue];
		
		NSMutableArray		*value=		[NSMutableArray	arrayWithObjects:romName,romCD,nil];
		NSMutableDictionary	*tmdic=		[NSMutableDictionary	dictionaryWithObjects:value forKeys:key];
		
		[emptyHouseArr addObject:tmdic];
	}


	

	self.houseData = emptyHouseArr;
    [emptyHouseArr release];
	[housePicker reloadAllComponents];
}

- (void)DismissHouse:(id)sender
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	
	shouse.frame = CGRectMake( 0, 768, 1024, 748 );
	[UIView commitAnimations];
}






//-------------------------------------Parse RGBColor ---------------------------------------//

//ファマート　カラーカンマstring
- (UIColor *)parseComma:(NSString *)commaString
{
	NSArray *colorArr = [commaString componentsSeparatedByString:@","];
	if ([colorArr count] >1) 
	{
		float alph = [[colorArr objectAtIndex:0] floatValue];
		float red =  [[colorArr objectAtIndex:1] floatValue];
		float green = [[colorArr objectAtIndex:2] floatValue];
		float blue = [[colorArr objectAtIndex:3] floatValue];
		
		return [UIColor colorWithRed:red green:green blue:blue alpha:alph];
	}
	return [UIColor whiteColor];
}

//ファマート　カラーカンマstring ;
- (UIColor *)parseFenHao:(NSString *)commaString
{
	NSArray *colorArr = [commaString componentsSeparatedByString:@";"];
	if ([colorArr count] >1) 
	{
		float alph = [[colorArr objectAtIndex:0] floatValue];
		float red =  [[colorArr objectAtIndex:1] floatValue];
		float green = [[colorArr objectAtIndex:2] floatValue];
		float blue = [[colorArr objectAtIndex:3] floatValue];
		
		return [UIColor colorWithRed:red green:green blue:blue alpha:alph];
	}
	return [UIColor whiteColor];
}


- (NSString *)parseStrRedColor:(NSString *)commaString
{ 
	NSArray *colorArr = [commaString componentsSeparatedByString:@","];
	if ([colorArr count] >1) {
		return [NSString stringWithFormat:@"%@" ,[colorArr objectAtIndex:1]];
	}
	return @"1.0";
		
}

- (NSString *)parseStrGreenColor:(NSString *)commaString
{
	NSArray *colorArr = [commaString componentsSeparatedByString:@","];
	if ([colorArr count]>1) {
		return [NSString stringWithFormat:@"%@" ,[colorArr objectAtIndex:2]];
	}
	return @"1.0";

}

- (NSString *)parseStrBlueColor:(NSString *)commaString
{
	NSArray *colorArr = [commaString componentsSeparatedByString:@","];
	if ([colorArr count]>1) {
		return [NSString stringWithFormat:@"%@" ,[colorArr objectAtIndex:3]];
	}
	return @"1.0";
}

#pragma mark --House Lock---

- (BOOL)priceInputClick:(PriceInput	*)prieInput
{
	if(editButton.hidden==YES)			//clear mode
	{
		return YES;
	}
    return NO;
}

//部屋ロッ| 解除
- (void)priceInputDidClose:(PriceInput *)prieInput
{

	NSString *houseCD = prieInput.keyboard.label.text;
	if(houseLock == prieInput)
	{
		[prieInput setTitle:@"部屋ロック" forState:UIControlStateNormal];
		if([self isLockSuccess:houseCD LockState:@"0"])
		{
			[common showSuccessAlert:@"ロックしました！"];
			[records removeAllObjects];
			[self masteposInit];
			[self drawMsterHouse];
			[self getRoomData];
		}
		else
			[common showErrorAlert:@"ロック失敗しました！"];
	}
	else if(houseUnLock==prieInput)
	{
		[prieInput setTitle:@"ロック解除" forState:UIControlStateNormal];
		if([self isUnLockSuccess:houseCD LockState:@"0"])
		{
			[common showSuccessAlert:@"解除しました！"];
			[records removeAllObjects];
			[self masteposInit];
			[self drawMsterHouse];
			[self getRoomData];
		}
		else
			[common showErrorAlert:@"解除失敗しました！"];
	}
	
	
}

//部屋ロックの結果
- (BOOL)checkShopLock:(NSString *)houseCD
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,strdate,hIsDayOrNight];
	
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"checkShopLock"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:strPost forKey:@"Keys"];
	
	[request setPostValue:houseCD forKey:@"roomCD"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	if([[[xmlDoc childAtIndex:0] stringValue] isEqualToString:@"yes"])
	{
		[xmlDoc	release];
		return YES;
	}
	else
	{
		[xmlDoc	release];
		return FALSE;
	}
}

//部屋ロックの結果
- (BOOL)isLockSuccess:(NSString *)houseCD LockState:(NSString *)lockState
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",LoginId,shopId,strdate,hIsDayOrNight,houseCD,lockState];

	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"LockRoom"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:strPost forKey:@"Keys"];
	
	[request startSynchronous];
	NSString *str = [request responseString];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	if([[[xmlDoc childAtIndex:0] stringValue] isEqualToString:@"true"])
	{
		[xmlDoc	release];
		return YES;
	}
	else
	{
		[xmlDoc	release];
		return FALSE;
	}
}

//部屋解除の結果
- (BOOL)isUnLockSuccess:(NSString *)houseCD LockState:(NSString	*)lockState
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strdate = [dateString stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",LoginId,shopId,strdate,hIsDayOrNight,houseCD,lockState];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"unLockRoom"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:strPost forKey:@"Keys"];
	
	[request startSynchronous];
	
	
	NSString *str = [request responseString];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	if([[[xmlDoc childAtIndex:0] stringValue] isEqualToString:@"true"])
	{
		[xmlDoc	release];
		return YES;
	}
	else
	{
		[xmlDoc	release];
		return FALSE;
	}
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
	[weekLabel	release];
	[houseLock release];
	[houseUnLock release];
	
	[houseImageSelectedArray release];
	[hIsDayOrNight release];
	[memoStr release];
	[memoTextView release];
	
	[houseData release];
	[doneButton release];
	[editButton release];
	
	[records	release];
	
//	[VisitDate release];
	[dateString release];
	[_tableView release];
	[super dealloc];
}

//liukeyu add 20121010

- (IBAction) goToFreeRoom:(id)sender{

    if (![common requestDidError]) 
	{
		return;			
	}
    
    CustomUISplitViewController *csplitViewController = (CustomUISplitViewController *)[self parentViewController];      
	NSArray	*controllers = [csplitViewController viewControllers];
    //SplitViewDelegate
	
	MasterViewController *masterView = [controllers objectAtIndex:0];						//MasterViewController
	
	
    FreeRoomController *controller = [[FreeRoomController alloc] initWithNibName:@"FreeRoomController" bundle:nil];
    controller.delegate = [self retain] ;
    controller.selectedDate = self.dateString;
    controller.selectedShopId = self.shopId;
    controller.selectedDayNig = [self.hIsDayOrNight intValue];
    
	NSArray *hoControllers = [NSArray arrayWithObjects:masterView,controller,nil];
	masterView.splitViewController.viewControllers = hoControllers;
    [controller release];
    
}

- (void) CloseFreeRoomController:(FreeRoomController *)controller{
    
    //[self dismissModalViewControllerAnimated:YES];
    
    CustomUISplitViewController *csplitViewController = (CustomUISplitViewController *)[controller parentViewController];      
	NSArray	*controllers = [csplitViewController viewControllers];
    //SplitViewDelegate
	
	MasterViewController *masterView = [controllers objectAtIndex:0];						//MasterViewController
	
	NSArray *hoControllers = [NSArray arrayWithObjects:masterView,self,nil];
	masterView.splitViewController.viewControllers = hoControllers;

}
//liukeyu add 20121016
- (void) GoToCustomerAndOrder:(id)sender{
    
    CustomUISplitViewController *csplitViewController = (CustomUISplitViewController *)[self parentViewController];      
	NSArray	*controllers = [csplitViewController viewControllers];
    //SplitViewDelegate
	
	MasterViewController *masterView = [controllers objectAtIndex:0];
    
    int row = [sender tag];
    NSDictionary *dic = [records objectAtIndex:row];
    
    CustomerAndOrderController *control = [[CustomerAndOrderController alloc] initWithNibName:@"CustomerAndOrderController" bundle:nil];
    control.delegate = [self retain];
    control.memberCD = [dic objectForKey:@"memberCD"];
    
	NSArray *hoControllers = [NSArray arrayWithObjects:masterView,control,nil];
	masterView.splitViewController.viewControllers = hoControllers;

    [control release];
}

- (void)CloseCustomerAndOrder:(CustomerAndOrderController *)controller{
    
    CustomUISplitViewController *csplitViewController = (CustomUISplitViewController *)[controller parentViewController];      
	NSArray	*controllers = [csplitViewController viewControllers];
    //SplitViewDelegate
	MasterViewController *masterView = [controllers objectAtIndex:0];						//MasterViewController
	
	NSArray *hoControllers = [NSArray arrayWithObjects:masterView,self,nil];
    
    masterView.splitViewController.viewControllers = hoControllers;
    
    if(tvalue && [tvalue count]>0)
    [tvalue removeAllObjects];
    if(records && [records count]>0)
    [records removeAllObjects];
    [self getRoomData];
}

@end
	