//
//  FreeRoomController.m
//  OrderLists
//
//  Created by fly on 12/10/10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "FreeRoomController.h"
#import "common.h"

@implementation FreeRoomController

@synthesize delegate;
@synthesize selectedDayNig;
@synthesize _tableView,btnDate,segmentedDayNig;

@synthesize btnDateSelectCan,theDatePicker,selectedDate,selectedShopId,allRoomList;

int	masterHouseXF = 40;
int masterHouseYF = 10;
//int masterTHouseX = 0;
int masterTHouseYF = 58;

int masterRoomW = 31;
int masterRoomH = 31;

int masterRoomNumH = 19;

int spaceX = 10;
int spaceY = 20;

- (void)dealloc
{
    [super dealloc];
    
    delegate = nil;
    
    [_tableView release];
    [btnDate release];
    [segmentedDayNig release];
    
    [btnDateSelectCan release];
    
    [theDatePicker release];
    
    [allRoomList release];
    [selectedDate release];
    [selectedShopId release];
}

//位置を初期化
- (void)masteposInit
{
	masterHouseXF = 40;
	masterHouseYF = 10;
	masterTHouseYF = masterHouseYF+masterRoomH-1+masterRoomNumH-1;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self._tableView.allowsSelection = NO;
    
	[self.btnDate setTitle:self.selectedDate forState:UIControlStateNormal];
    self.segmentedDayNig.selectedSegmentIndex = self.selectedDayNig - 1;
    [self search:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark ----カレンダーの日付を変更---
- (IBAction)selectDate:sender
{
    //	NSLog(@"--------------------calendar----------------");
	
    if(self.btnDateSelectCan != nil){
        
        [self.view addSubview:self.btnDateSelectCan];
        return;
    }
	self.btnDateSelectCan = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
	[self.btnDateSelectCan addTarget:self action:@selector(DismissCalendar:) forControlEvents:UIControlEventTouchUpInside];
	self.btnDateSelectCan.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.7];
	
	UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(200, 768, 300, 300)];
	[frameView setBackgroundColor:[UIColor grayColor]];
	[self.view addSubview:self.btnDateSelectCan];
	[self.btnDateSelectCan addSubview:frameView];
	
	UILabel *titleLabel= [[UILabel alloc] initWithFrame:CGRectMake(50, 768, 200, 40)];
	[titleLabel setText:@"日付を選択ください！"];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	
	self.theDatePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake( 20, 768, 250, 150 )] autorelease];
	self.theDatePicker.datePickerMode = UIDatePickerModeDate;
	NSDateFormatter *formatterCal = [[[NSDateFormatter alloc] init]	autorelease];
    
	formatterCal.dateFormat = @"yyyy年M月d日"; 
	
	NSDate *timestampCal = [formatterCal dateFromString:btnDate.titleLabel.text];
	[self.theDatePicker	setDate:timestampCal];
	[UIView beginAnimations:nil context:nil];
	
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setFrame:CGRectMake(70, 768, 100, 30)];
	[btn setTitle:@"O K" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(ChangeCalendar:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[frameView addSubview:titleLabel];
	[frameView addSubview:self.theDatePicker];
	[frameView addSubview:btn];
	
	
	[frameView setFrame:CGRectMake(200, 80, 300, 300)];
	self.theDatePicker.frame = CGRectMake(20, 80, 250, 150);
	//	[theDatePicker selectRow:0 inComponent:0 animated:NO];
	
	[btn setFrame:CGRectMake(70, 240, 150, 50)];
	[titleLabel setFrame:CGRectMake(55, 30, 200, 30)];
	
	[UIView setAnimationDuration:2.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView commitAnimations];
	[frameView	release];
	[titleLabel	release];
}

//change calendar click
- (void)ChangeCalendar:(id)sender
{	
	NSDateFormatter *formatterCal = [[NSDateFormatter alloc] init]; 
	formatterCal.dateFormat = @"yyyy年M月d日";
	
	NSString *timestampCal = [formatterCal stringFromDate:self.theDatePicker.date]; 
	[btnDate setTitle:timestampCal forState:UIControlStateNormal];
    
	[formatterCal	release];
	[self DismissCalendar:self.btnDateSelectCan];
}

-(void)DismissCalendar:(id)sender
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopCal:finished:context:)];
	
	[sender removeFromSuperview];
	[UIView commitAnimations];
}


#pragma mark 搜索
- (IBAction) search:(id)sender{
    
    NSString *date = btnDate.titleLabel.text;
    NSInteger dayNig = segmentedDayNig.selectedSegmentIndex + 1;
    NSString * dayOrNight = [NSString stringWithFormat:@"%d",dayNig];
    [self GetAllRoomInfo:self.selectedShopId SelectDate:date DayNight:dayOrNight];
    [_tableView reloadData];
}

- (void) GetAllRoomInfo:(NSString *)shopId SelectDate:(NSString *)date DayNight:(NSString *)dayNig{
    
    
    NSString *loginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
    
    NSString *strdate = [date stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	
	ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetAllEmptyRoom"]]];
    
    [request setPostValue:loginId forKey:@"userId"];
	[request setPostValue:shopId forKey:@"shopId"];
    [request setPostValue:strdate forKey:@"date"];
    [request setPostValue:dayNig forKey:@"dayOrNight"];
    
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	NSError	*error = [request error];
	if (error) 
	{
		[common	showErrorAlert:@"ネットワークを確認してください。"];
		return;
	}
    
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[self PasteRoomInfo:str];
}

- (void) PasteRoomInfo:(NSString *) str{

    if (str == nil || [str isEqual: @""]) return;
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
    NSMutableArray *lists=[[NSMutableArray alloc] init];
	NSMutableArray *values=[[NSMutableArray alloc] init];
	NSMutableArray 	*Xkeys = [[NSMutableArray alloc] initWithObjects:@"shopId",@"shopCd",@"shopName",@"shopPhone",@"shopRoom",nil];
	
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
                    [values addObject:[tmpE children]];
				}//end if
			}//end for
			if ([values count] ==5) // dic objest.count =keys.count
			{
				NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:values forKeys:Xkeys];
                [self PasteOneShopRoom:dic];
				[lists addObject:dic];
				[values removeAllObjects];
			}
			
		} //end if
	} //end for
    self.allRoomList = lists;
    [lists release];
	[Xkeys release];
	[values release];

}

- (void) PasteOneShopRoom:(NSMutableDictionary *) dic{
    
    
    if(dic == nil || [dic count] < 5) return;
    
    NSArray *keys = [dic allKeys];
    
    for (NSString * key in keys) {
        
        NSArray *elements = [dic objectForKey:key];
        
        if([key isEqualToString:@"shopRoom"])
        {
            UITableViewCell *cell = [self AddRoomView:elements];
            
            [dic setObject:cell forKey:key];
        }else{
        
            NSString * strInfo = @"";
            if ([elements count] > 0) {
                strInfo = [[elements objectAtIndex:0] stringValue];
            }
            [dic setObject:strInfo forKey:key];
        }    
    }
} 

- (UITableViewCell *)AddRoomView:(NSArray *)rooms{
    
    [self masteposInit];
    NSString *myCell = @"myCell";
    UITableViewCell *cell = [[[UITableViewCell alloc]
             initWithStyle:UITableViewCellStyleDefault
             reuseIdentifier: myCell] autorelease];
    
    if ([rooms count] <= 0) {
        //[cell setFrame:CGRectMake(0, 0, 580, 44.0)];
        return cell;
    }
    
    int viewHeight = (masterRoomH-1+masterRoomNumH-1)+20;
    BOOL hasLevel3 = NO;
    for (int i=0; i<[rooms count]; i++) {
        masterHouseXF += spaceX;
        CXMLElement *element = [rooms objectAtIndex:i];
        NSArray *roomItem = [element children]; //one Group
        CXMLElement *elementRoomItem = [roomItem objectAtIndex:0];
        CXMLElement *elemetRoomSet = nil;
        NSArray *isShowArr = nil;
        if ([roomItem count] == 2) {
            elemetRoomSet = [roomItem objectAtIndex:1];
            NSString *showSet = [[[elemetRoomSet childAtIndex:0] childAtIndex:3] stringValue];
            isShowArr = [showSet componentsSeparatedByString:@";"];
        }
        int flagShow = 0;
        if (isShowArr != nil) flagShow = [isShowArr count] - 1;
        
        if (masterHouseXF > 580 || masterHouseXF+flagShow*masterRoomW-flagShow+1 > 620) {
            masterHouseXF = 40 + spaceX;
            masterHouseYF = 10+masterRoomH-1+masterRoomNumH-1+spaceY;
            
            viewHeight += masterRoomH-1+masterRoomNumH-1+spaceY;
            if (hasLevel3) {
                masterHouseYF += masterRoomNumH;
                viewHeight += masterRoomNumH;
                hasLevel3 = NO;
            }
            masterTHouseYF = masterHouseYF + masterRoomH-1+masterRoomNumH-1;
        }
        if (flagShow > 0) hasLevel3 = YES;
        
        if (flagShow > 0 && isShowArr != nil) {
            
            //draw 3 level
            int memberCount = [self memberCount:isShowArr];
            int memberPos   = [self memberBeginPos:isShowArr];   //if not exist then return -1;
            
            if (memberPos >=0) //exist
            {
                [self DrawMasterSetItem:cell Element:elemetRoomSet bginPos:memberPos count:memberCount];
            }
            
            for (CXMLElement *ele in [elementRoomItem children]) {
                if ([ele isKindOfClass:[CXMLElement class]]) {
                    [self DrawMasterRoom:cell Element:ele];
                }
            }
        }else{
            [self DrawMasterRoom:cell Element:[[elementRoomItem children] objectAtIndex:0]];
        }
    }
    if (hasLevel3) {
        viewHeight += masterRoomNumH;
    }
    [cell setFrame:CGRectMake(0, 0, 580, viewHeight)];
    //[view setBackgroundColor:[UIColor whiteColor]];
    
    return cell;
}

-(void)DrawMasterRoom:(UIView *)view Element:(CXMLElement *)roomItemElement{
    NSString *RoomCD = [[roomItemElement childAtIndex:0] stringValue];
	NSString *PersonNum = [[roomItemElement childAtIndex:1] stringValue];
	if([PersonNum rangeOfString:@"/"].length >0)
		PersonNum = [PersonNum stringByAppendingString:@""];
	else
		PersonNum = [PersonNum stringByAppendingString:@"名"];
	
	NSString *colorValue =[[roomItemElement childAtIndex:2] stringValue];

	UIColor  *roomColor = [self ParseColor:colorValue];	//[UIColor colorWithRed:red green:green blue:blue alpha:alph];
	UIColor	 *lockRoomColor=[self ParseColor:[[roomItemElement childAtIndex:3] stringValue]];
	UIFont	*wordFont = [UIFont	systemFontOfSize:10.7];	
		
	//-----------------------部屋番号----------------------
	CGRect numberFrame = CGRectMake(masterHouseXF, masterHouseYF, masterRoomW, masterRoomH);//x
    
	[self DrawMaster:view Text:RoomCD FontSize:wordFont Frame:numberFrame Color:lockRoomColor];
	//-------------------------部屋容量---------------------
	CGRect	countFrame = CGRectMake(masterHouseXF, (masterHouseYF+masterRoomH-1), masterRoomW, masterRoomNumH);	//x
	
    [self DrawMaster:view Text:PersonNum FontSize:wordFont Frame:countFrame Color:roomColor];
	masterHouseXF += masterRoomW - 1;
}

//draw チーム部屋
- (void)DrawMasterSetItem:(UIView *)view Element:(CXMLElement *)_roomSetItem bginPos:(int)beginPos count:(int)count
{
	
	CXMLElement *roomSetItem = [[_roomSetItem children] objectAtIndex:0];
	
	NSString *customerCount = [[roomSetItem childAtIndex:1] stringValue];
	if([customerCount rangeOfString:@"/"].length >0)
		customerCount = [customerCount stringByAppendingString:@""]; 
	else
		customerCount = [customerCount stringByAppendingString:@"名"]; //名
    
	
	NSString *colorValue =[[roomSetItem childAtIndex:2] stringValue];
		
	UIColor  *roomColor = [self ParseColor:colorValue];
    
	UIFont	*wordFont = [UIFont	systemFontOfSize:12];
	
	
	float beginPostion = masterHouseXF + masterRoomW*beginPos;
	float gropWidth = masterRoomW *count - count+1;
	CGRect groupFrame = CGRectMake(beginPostion, masterTHouseYF, gropWidth, masterRoomNumH);	
    
	[self DrawMaster:view Text:customerCount FontSize:wordFont Frame:groupFrame Color:roomColor];
}

//ファマート　カラーカンマstring ;
- (UIColor *)ParseColor:(NSString *)strColor
{
	NSArray *colorArr = [strColor componentsSeparatedByString:@";"];
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

-(void) DrawMaster:(UIView *)view Text:(NSString *)info FontSize:(UIFont *)font Frame:(CGRect)frame Color:(UIColor *)color{

    UITextField *groupTextField = [[UITextField alloc] initWithFrame:frame];
	
	[groupTextField setBorderStyle:UITextBorderStyleLine];
	[groupTextField setText:info];
	[groupTextField setFont:font];
	[groupTextField setTextAlignment:UITextAlignmentCenter];
    //[groupTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	[groupTextField setUserInteractionEnabled:FALSE];
	[groupTextField setBackgroundColor:color];
	
	[view addSubview:groupTextField];
	[groupTextField	release];
}


//member の数量
- (int)memberCount :(NSArray *)isShowArr
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
- (int)memberBeginPos:(NSArray *)isShowArr
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


- (IBAction)close:(id)sender{
    [self.delegate CloseFreeRoomController:self];
}


#pragma mark - TableView 相关

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [self.allRoomList count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 1;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSMutableDictionary *dic = [self.allRoomList objectAtIndex:section];
    NSString *shopName = [dic objectForKey:@"shopName"];
    NSString *shopPhone = [dic objectForKey:@"shopPhone"];
    NSString *title = [NSString stringWithFormat:@"↓ %@ %@",shopName,shopPhone];
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSMutableDictionary *dic = [self.allRoomList objectAtIndex:indexPath.section];
    UITableViewCell *cell = [dic objectForKey:@"shopRoom"];
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    NSMutableDictionary *dic = [self.allRoomList objectAtIndex:indexPath.section];
    UITableViewCell *cell = [dic objectForKey:@"shopRoom"];
    CGFloat height = 44.0;
    if (cell != nil) {
        height = cell.frame.size.height;
    }
    return height;
}

@end
