//
//  SearchCustomerController.m
//  OrderLists
//
//  Created by fly on 12/10/10.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "SearchCustomerController.h"


@implementation SearchCustomerController

@synthesize delegate, textFieldKey,_tableView,customerInfo,customerList;

- (void)dealloc
{
    [super dealloc];
    
    delegate = nil;
    
    [textFieldKey release];
    [_tableView release];
    
    [customerList release];
    [customerInfo release];
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
    _tableView.allowsSelection = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

#pragma mark 检索
- (IBAction) search:(id)sender{
    NSString *key = textFieldKey.text==nil?@"":textFieldKey.text;
    [self GetCustomerList:key];
    [_tableView reloadData]; 
}
-(void) searchCommon{
    NSString *key = textFieldKey.text==nil?@"":textFieldKey.text;
    [self GetCustomerList:key];
    [_tableView reloadData];
}
#pragma mark 关闭
- (IBAction) close:(id)sender{
    
    self.customerInfo = nil;
    [self.delegate SearchCustomerControllerDidClose:self];
}

#pragma mark 获取客户信息
- (void) GetCustomerList:(NSString *)key{
    
    if (key == nil || [key isEqual: @""]) return;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerList"]]];
	[request setPostValue:key forKey:@"keys"];
	
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
	[self PasteCustomerList:str];
}

#pragma mark 解析xml
- (void) PasteCustomerList:(NSString *)str{
    
    if (str == nil || [str isEqual: @""]) return;
    CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
    NSMutableArray *lists=[[NSMutableArray alloc] init];
	NSMutableArray *values=[[NSMutableArray alloc] init];
	NSMutableArray 	*Xkeys = [[NSMutableArray alloc] initWithObjects:@"customerCD",@"phone",@"customerPhone",@"customerName",@"companyPhone",@"companyName",nil];
	
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
                            [lists release];
                            [Xkeys release];
                            [values release];
                            return;
                        }
						[values addObject:[cnode stringValue]];	
					}
				}//end if
			}//end for
			if ([values count] ==6) // dic objest.count =keys.count
			{
				NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:values forKeys:Xkeys];
				[lists addObject:dic];
				[values removeAllObjects];
			}
			
		} //end if
	} //end for
    self.customerList = lists;
    [lists release];
	[Xkeys release];
	[values release];

}

#pragma mark - TableView 相关

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [customerList count];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{

    //if(tableView == _tableView && section == 0){
    //    return @"检索结果";
    //}
    return @"検索結果";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	//用来标识窗格为一个普通窗格
	static NSString *MyIdentifier = @"NormalCell";
	
	//获取一个可复用窗格
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell ==nil)
	{
		cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier: MyIdentifier] autorelease];
	}
    
	NSMutableDictionary *dic = [self.customerList objectAtIndex:indexPath.row];
    
    NSString *customerName = [dic objectForKey:@"customerName"];
    NSString *customerPhone = [dic objectForKey:@"customerPhone"];
    NSString *companyName = [dic objectForKey:@"companyName"];
    NSString *companyPhone = [dic objectForKey:@"companyPhone"];
    
    int row = indexPath.row + 1;
    
    NSString *showInfo = [NSString stringWithFormat:@"%d  %@  %@  %@  %@",row,customerName,companyName,customerPhone,companyPhone];
    cell.textLabel.text = showInfo;
    
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    self.customerInfo = [self.customerList objectAtIndex:indexPath.row];
    [self.delegate SearchCustomerControllerDidClose:self];
}


@end
