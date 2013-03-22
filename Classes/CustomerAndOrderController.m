//
//  CustomerAndOrderController.m
//  OrderLists
//
//  Created by fly on 12/10/22.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "CustomerAndOrderController.h"
#import "HistoryDetailCell.h"
#import "common.h"

@implementation CustomerAndOrderController

@synthesize delegate;
@synthesize _tableView, showView;

@synthesize textFieldName, textFieldPhone, textFieldCompany, textViewNG, textViewRemark;

@synthesize memberCD, memberInfoDic, historyDetailArr;

CGRect frameView;

- (void)dealloc
{
   // [super dealloc];
    
    delegate = nil;
    
    [textFieldName release];
    [textFieldPhone release];
    [textFieldCompany release];
    
    [textViewNG release];
    [textViewRemark release];
        //
    [memberCD release];
    [memberInfoDic release];
    
    [_tableView release];
    [showView release];
    //[common showErrorAlert:@"ok1"];
    [historyDetailArr release];
    //self.memberCD = nil;
    //self.memberInfoDic = nil;
    //self.historyDetailArr = nil;
    [super dealloc];
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
    self._tableView.allowsSelectionDuringEditing = NO;
    frameView = self.showView.frame;
    [self GetMemberInfoByCD:self.memberCD];
    [self InitMember];
    //[self._tableView reloadData];
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

#pragma（HistoryDetailCellDelegate 方法实现）点击预约处理事件
- (void)appendHistRecord:(HistoryDetailCell *)cell{
    NSMutableArray *aryKeys = [NSMutableArray arrayWithObjects:@"_foodCD",@"_foodName",@"_foodShopName",@"_foodPrice",@"_foodCount",nil];
	NSMutableArray *aryValues=[NSMutableArray arrayWithObjects:[cell _foodCD],[cell _foodName].text,[cell _foodShopName].text,[cell _foodPrice].text,@"1",nil];
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

#pragma 关闭页面 
- (IBAction) close:(id)sender{
    [delegate CloseCustomerAndOrder:self];
}

#pragma upadte
- (IBAction) updateMember:(id)sender{
    
    if (self.memberInfoDic == nil) return;
    NSString *memberId = [self.memberInfoDic objectForKey:@"id"];
    
    NSString *memberName = self.textFieldName.text==nil?@"":self.textFieldName.text;
    NSString *memberPhone = self.textFieldPhone.text==nil?@"":self.textFieldPhone.text;
    NSString *companyName = self.textFieldCompany.text==nil?@"":self.textFieldCompany.text;
    NSString *NG = self.textViewNG.text==nil?@"":self.textViewNG.text;
    NSString *remark = self.textViewRemark.text==nil?@"":self.textViewRemark.text;
    
    NSString *keys = [NSString stringWithFormat:
                      @"%@;%@;%@;%@;%@",memberName,memberPhone,companyName,NG,remark];
    NSString *updateOrder = @"0";
    if (![[self.memberInfoDic objectForKey:@"memberName"] isEqualToString:memberName] ||
        ![[self.memberInfoDic objectForKey:@"memberPhone"] isEqualToString:memberPhone] ||
        ![[self.memberInfoDic objectForKey:@"companyName"] isEqualToString:companyName] ) {
        updateOrder = self.memberCD;
    }
    //更新数据
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateMemberInfo"]]];
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:memberId forKey:@"id"];
    [request setPostValue:keys forKey:@"keys"];
    [request setPostValue:updateOrder forKey:@"updateOrder"];
    
    [request startSynchronous];
    NSError *error = [request error];
    if (error) {
        [common	showErrorAlert:@"ネットワークを確認してください。"];
		return;
    }
    
    NSString *str = [request responseString];
	str=[common formateXmlString:str];
    
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theElement = [doc rootElement];
	NSString *strE = [[theElement childAtIndex:0] stringValue];
    if ([strE isEqualToString:@"true"]) {
        [common showSuccessAlert:@"更新しました！"];
    }else{
        [common showErrorAlert:@"更新失敗しました！"];
    }
}
#pragma 显示或隐藏view
- (IBAction) showOrHiddenView:(id)sender{
    
    int type = [sender tag];
    float x,y,w,h;
    CGRect frameTable = self._tableView.frame;
    NSString *title = @"";
    switch (type) {
        case 0:
            title = @"顧客情報表示";
            [sender setTag:1];
            self.showView.hidden = YES;
            x = frameView.origin.x;
            y = frameView.origin.y+10;
            w = frameTable.size.width;
            h = frameTable.origin.y-y+frameTable.size.height;
            self._tableView.frame = CGRectMake(x, y, w, h);
            break;
        case 1:
            title = @"履歴表示";
            [sender setTag:0];
            self.showView.hidden = NO;
            x = frameTable.origin.x;
            y = frameTable.origin.y+frameView.size.height-10;
            w = frameTable.size.width;
            h = frameTable.size.height-(y-frameTable.origin.y);
            self._tableView.frame = CGRectMake(x, y, w, h);
            break;
        default:
            break;
    }
    [(UIButton *)sender setTitle:title forState:UIControlStateNormal];
}

-(void) InitMember{
    if (self.memberInfoDic == nil) return;
    NSString *memberName = [self.memberInfoDic objectForKey:@"memberName"];
    NSString *memberPhone = [self.memberInfoDic objectForKey:@"memberPhone"];
    
    NSString *companyName = [self.memberInfoDic objectForKey:@"companyName"];
    NSString *NG = [self.memberInfoDic objectForKey:@"NG"];
    NSString *remark = [self.memberInfoDic objectForKey:@"remark"];
    //初始化信息
    [self.textFieldName setText:memberName];
    [self.textFieldPhone setText:memberPhone];
    [self.textFieldCompany setText:companyName];
    [self.textViewNG setText:NG];
    [self.textViewRemark setText:remark];
    
    //获取菜单信息
    [self GetHistoryDetailByMemberCD:self.memberCD MemberName:memberName MemberPhone:memberPhone];
}

#pragma 获取客户信息
-(void)GetMemberInfoByCD:(NSString *)memCD{
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetMemberInfo"]]];
    
	[request setRequestMethod:@"POST"];
	[request setPostValue:memCD forKey:@"memberCD"];
	
	[request startSynchronous];
	
	NSError	*error = [request error];
	if (error) 
	{
		[common	showErrorAlert:@"ネットワークを確認してください。"];
		return;
	}
    
    
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
    [self PasteMemberXml:str];
	
}

#pragma 解析xml获取客户信息
- (void) PasteMemberXml:(NSString *)str{
    
    //if (str == nil || str == @" ") return;
    // top  change  by chao.tao
    if (str == nil || [str isEqual:@""]) return;
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
    NSMutableArray *lists=[[NSMutableArray alloc] init];
	NSMutableArray *values=[[NSMutableArray alloc] init];
	NSMutableArray 	*Xkeys = [[NSMutableArray alloc]
                              initWithObjects:@"id",@"memberCD",@"memberName",@"companyPhone",
                              @"companyName",@"memberPhone",@"NG",@"remark",nil];
	
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
						[values addObject:@""];
					}
					else 
					{
						CXMLNode *cnode = [[tmpE children] objectAtIndex:0];
                        if ([[cnode stringValue] isEqual: @"Error"] || [[cnode stringValue] isEqual: @"error"]) {
                            break;
                        }
						[values addObject:[cnode stringValue]];	
					}
				}//end if
			}//end for
			if ([values count] ==8) // dic objest.count =keys.count
			{
				NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:values forKeys:Xkeys];
				[lists addObject:dic];
				[values removeAllObjects];
			}
			
		} //end if
	} //end for
    if ([lists count] == 1) {
        self.memberInfoDic = [lists objectAtIndex:0];
    }
    [lists release];
	[Xkeys release];
	[values release];
}

#pragma 获取菜单信息
-(void) GetHistoryDetailByMemberCD:(NSString *)memCD MemberName:(NSString *)memberName MemberPhone:(NSString *)phone{
    
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:
                                   [NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetOrderHistoryByCustomerCDNamePhone"]]];
	[request setRequestMethod:@"POST"];
	[request setPostValue:memberName forKey:@"CustomerName"];
	[request setPostValue:memCD   forKey:@"CustomerCd"];
	[request setPostValue:phone     forKey:@"Phone"];
	
	[request startSynchronous];
	
    
	NSError	*error = [request error];
	if (error) 
	{
		[common	showErrorAlert:@"ネットワークを確認してください。"];
		return;
	}
    
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	
	if ([str rangeOfString:@"Child"].location == NSNotFound) 
	{
        //NSMutableArray *tempArray = [[NSMutableArray alloc] init];
        [self.historyDetailArr removeAllObjects];
		//self.historyDetailArr = tempArray;
       // [tempArray release];
	}
	else 
	{
		[self PasteHistoryDetailXml:str];
	}
}

#pragma 解析菜单信息XML
- (void) PasteHistoryDetailXml:(NSString *)str{
    
    if (str == nil || str == @"") return;
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
    NSMutableArray *lists=[[NSMutableArray alloc] init];
	NSMutableArray *values=[[NSMutableArray alloc] init];
	NSMutableArray 	*Xkeys = [[NSMutableArray alloc]
                              initWithObjects:@"itemCD",@"itemName",@"shopName",@"itemPrice",@"itemCount",nil];
    
    for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])		//string
		{
            NSMutableArray *allLists = [[NSMutableArray alloc] init];
            NSMutableArray *itemLists=[[NSMutableArray alloc] init];
            
			CXMLNode *child =[node childAtIndex:0];			//child
			NSArray *childs = [child children];
			
			for (CXMLElement *tmpE in childs)				// Child
			{
				if([tmpE isKindOfClass:[CXMLElement class]])
				{
					
					if ([tmpE childCount] == 1)				//Date 
					{
                        //CXMLNode *cnode = [[tmpE children] objectAtIndex:0];
                        NSString *cs = [[tmpE childAtIndex:0] stringValue];
						[allLists addObject:cs];
					}
					else //Item 
					{
						NSArray *sons = [tmpE children];     //item
						for (CXMLElement *son in sons) 
						{
							if ([son isKindOfClass:[CXMLElement class]]) 
							{
                                //CXMLNode *sonNode = [[son children] objectAtIndex:0];
                                NSString *s = [[son childAtIndex:0] stringValue];
								[values addObject:s];
							}
						}
                        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjects:values forKeys:Xkeys];
						[itemLists addObject:dic];
                        [dic release];
						[values removeAllObjects];
					}
					
				}
			}
			[allLists addObject:itemLists];
            [itemLists release];
            [lists addObject:allLists];
            [allLists release];
		}
	}
    self.historyDetailArr = lists;
    [lists release];
    [values release];
    [Xkeys release];
}

#pragma mark - TableView 相关

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.historyDetailArr==nil) {
        return 0;
    }
	return [self.historyDetailArr count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
    if (self.historyDetailArr==nil || [self.historyDetailArr count]<=0) {
        return 0;
    }
	return [[[self.historyDetailArr objectAtIndex:section] objectAtIndex:1] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 50.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if (self.historyDetailArr == nil) {
        return nil;
    }
    NSString *title = [[self.historyDetailArr objectAtIndex:section] objectAtIndex:0];
    return [title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//用来标识窗格为一个普通窗格
	static NSString *MyIdentifierHistoryDetail = @"HistoryDetailCell";
	
	HistoryDetailCell *cell = (HistoryDetailCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifierHistoryDetail];
	if(cell == nil)
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"HistoryDetailCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	cell.tag = indexPath.row;
	cell.delegate = self;
	
	NSString *strName =		 [[[[self.historyDetailArr objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemName"];
	NSString *strPrice=		 [[[[self.historyDetailArr objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemPrice"]; 
	NSString *strCount=		 [[[[self.historyDetailArr objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemCount"];
    NSString *strShopName=		 [[[[self.historyDetailArr objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"shopName"];
	
	cell._foodCD=		[[[[self.historyDetailArr objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row] valueForKey:@"itemCD"];
	[[cell _foodName] setText:strName];
	[[cell _foodPrice] setText:strPrice];
	[[cell _foodCount] setText:strCount];
	[[cell _foodShopName] setText:strShopName];
	
	return cell;
    
}

@end
