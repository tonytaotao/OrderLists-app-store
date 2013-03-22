    //
//  DetailViewController.m
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright 2010 Blackwhale GmbH. All rights reserved.
//

#import "DetailViewController.h"
#import "NWPickerView.h"
#import "common.h"
#import	"HistoryDetailViewController.h"
#import	"MasterViewController.h"

#define STATE_FIELD 2000


@implementation DetailViewController

@synthesize selectPerson;
@synthesize yoyaku;
@synthesize sex;
@synthesize companyName;
@synthesize	mobileTel;
@synthesize companyFax;
@synthesize _email;

@synthesize memTextView;
@synthesize ngTextView;

@synthesize arerugi_First;
@synthesize arerugi_Second;
@synthesize arerugi_Third;
@synthesize arerugi_Four;

@synthesize vege_First;
@synthesize vege_Second;
@synthesize vege_Third;
@synthesize vege_Four;

@synthesize arerugiArr;
@synthesize vegeArr;

ASIFormDataRequest  *request;
NSMutableArray	    *peopleArr;

NSMutableArray		*keys;					//検索人
//NSMutableArray		*values;
//NSMutableDictionary *dic;


NSMutableArray		*ckeys;					//人の情報
//NSMutableArray		*cvalues;
NSMutableDictionary *cdic;


NSMutableArray		*areKeys;				//アレルギー all
//NSMutableArray		*areValues;
//NSMutableDictionary	*areDic;


NSMutableArray		*vegeKeys;				//ベジタリアに all
//NSMutableArray		*vegeValues;
//NSMutableDictionary	*vegeDic;		


NSMutableArray      *cusVegeKeys;			//客のベジタリアに
NSMutableArray	    *cusVegeValues;
//NSMutableDictionary *cusVegeDic;	
NSMutableArray		*cusVegeArr;
NSString	*customCD;						//客様CD


NSMutableArray		 *oldVegeCD;
- (void)viewDidLoad 
{
    [super viewDidLoad];
				[self varInit];
}

//variable init
- (void)varInit
{
    /*   ---  注意  by chao.tao  --- 
	customCD=[NSString	stringWithString:@""];
    */
    customCD=@"";
	if (oldVegeCD)
 {
		[oldVegeCD release];
	}
	oldVegeCD = [[NSMutableArray alloc] initWithCapacity:4];
	
	if (peopleArr)
 {
		[peopleArr release];
	}
	if (keys) 
	{
		keys=nil;
	}
	if (ckeys) 
	{
		ckeys=nil;
	}
	if (arerugiArr) 
	{
		arerugiArr=nil;
	}
	if (areKeys) 
	{
		areKeys=nil;
	}
	if (vegeArr) 
	{
		vegeArr=nil;
	}
	if (vegeKeys) 
	{
		vegeKeys=nil;
	}
	peopleArr = [[NSMutableArray alloc] init];
	keys =		 [[NSMutableArray alloc] initWithObjects:@"CustomerID",@"CustomerName",nil];
	
	ckeys=	  [[NSMutableArray alloc] initWithObjects:@"knamekana",@"sex",@"email1",@"companyName",@"companyPhone",@"companyFax",@"NG",@"memo",@"allergyID",@"vegetable",nil];
	//cvalues = [[NSMutableArray alloc] init];
	
	arerugiArr = [[NSMutableArray alloc] init];
	areKeys =	 [[NSMutableArray alloc] initWithObjects:@"areid",@"areName",nil];
	//areValues=	 [[NSMutableArray alloc] init];
	
	vegeArr	   = [[NSMutableArray alloc] init];
	vegeKeys   = [[NSMutableArray alloc] initWithObjects:@"vegeid",@"vegeName",nil];
	//vegeValues = [[NSMutableArray alloc] init];
	
	if (cusVegeKeys)
 {
		[cusVegeKeys release];
	}
	
	cusVegeKeys=[[NSMutableArray alloc] initWithObjects:@"vegeName",@"vegeid",nil];
	if (cusVegeValues)
 {
		[cusVegeValues release];
	}
	cusVegeValues=[[NSMutableArray alloc] init];
	if (cusVegeArr) 
	{
		cusVegeArr=nil;
	}
	cusVegeArr = [[NSMutableArray alloc] initWithCapacity:4];
}

//liukeyu add	start 2011-06-09
-	(void)	showHisDetailCopyInfo
{
	NSString	*hisDetailInfo =	[HistoryDetailViewController	getHisDetailUserCdName];
	
	if (hisDetailInfo	!=	nil	&&	![hisDetailInfo	isEqualToString:@""]	&&	[hisDetailInfo	length]	>	0) 
	{
		NSArray	*	detailInfoAry	=	[hisDetailInfo	componentsSeparatedByString:@";"];
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
				[self	getCustomerNameListD:tel];
				if (peopleArr.count>0) 
				{
					for (int	i=0; i<peopleArr.count; i++) 
					{
						if ([userName	isEqualToString:[[peopleArr	objectAtIndex:i]	objectForKey:@"CustomerName"]]) 
						{
							NSString *customID = [[peopleArr objectAtIndex:i] objectForKey:@"CustomerID"];
							customCD = customID;
							
							[self getCusInfo:customID];
							
							[self getAreData];
							[self getVegeData];
							[selectPerson	setText:userName];
							[selectPerson reloadAllComponents];
							break;
						}
					}
				}
			}
		}
	}
	[HistoryDetailViewController	releaseHisDetailInfo];
}

- (void)releaseRefreshView
{
	[yoyaku setText:@""];
	[sex setText:@""];
	
	[companyName setText:@""];
	[mobileTel	 setTitle:@"" forState:UIControlStateNormal];
	[companyFax setText:@""];
	
	[_email setText:@""];
	[memTextView setText:@""];
	[ngTextView setText:@""];
	
	[arerugi_First setText:@""];	
	[arerugi_Second setText:@""];
	[arerugi_Third setText:@""];
	[arerugi_Four setText:@""];
	
	[vege_First setText:@""];
	[vege_Second setText:@""];
	[vege_Third setText:@""];
	[vege_Four setText:@""];

	
}
//liukeyu add	end 2011-06-09

- (IBAction)copySearchInfo:sender
{
	if (detailPhoneCdNameInfo)
	{
			[detailPhoneCdNameInfo	release];
	}
	NSString	*detailPhone	=	[textFieldTel titleLabel].text	==	nil	?	@""	:	[textFieldTel titleLabel].text;
	NSString	*detailUserName = [selectPerson	text] == nil ? @"" :[selectPerson	text];
	detailPhoneCdNameInfo	=	[[NSString	alloc]	initWithFormat:@"%@;%@",detailPhone,detailUserName];
	
	//liukeyu add 20110708 start
	[[MasterViewController getTableViewController] changeView:0 iSection:1];
	//liukeyu add 20110708 end
}

+	(NSString*)	getDetailUserCdName
{
	if (detailPhoneCdNameInfo	==	nil	||	[detailPhoneCdNameInfo	length]	<=	0) 
	{
		return	@"";
	}
	return	detailPhoneCdNameInfo;
}

+	(void)	releaseDetailInfo
{
	detailPhoneCdNameInfo	=	nil;
//	if (detailPhoneCdNameInfo) 
//	{
//		//detailPhoneCdNameInfo	=	nil;
//		[detailPhoneCdNameInfo release];
//	}
}

//情報を検索する
- (IBAction)searchInfo:sender;
{
	[peopleArr removeAllObjects];
	
	NSString *tel = [textFieldTel titleLabel].text;
	if([tel length]==0)
	{
		return;
	}
	[self	getCustomerNameListD:tel];
	[self	releaseRefreshView];
	if ([peopleArr count]>1)
	{
		//[selectPerson	setText:@""];
		[selectPerson	setText:[[peopleArr objectAtIndex:1] objectForKey:@"CustomerName"]];
		NSString *customID = [[peopleArr objectAtIndex:1] objectForKey:@"CustomerID"];
		customCD = customID;
		
		[self getCusInfo:customID];
		
		[self getAreData];
		[self getVegeData];
	}
	[selectPerson reloadAllComponents];
}

-	(void)	getCustomerNameListD:(NSString	*)tel
{	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerNameList"]]];
	[request setPostValue:tel forKey:@"keys"];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	if([str length]==0)
		return;
	[self parseNameList:str];
}

//フォマと xml
- (void)parseNameList:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	NSMutableArray	*pValues =[[NSMutableArray alloc] init];
	
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
						[pValues addObject:@""];
					}
					else 
					{
						CXMLNode *nodem = [[tmpE children] objectAtIndex:0];
						[pValues addObject:[nodem stringValue]];	
					}
				}//end if
			}//end for
			
			if ([pValues count] ==2) // dic objest.count =keys.count
			{
				NSMutableDictionary *Dic = [[NSMutableDictionary alloc] initWithObjects:pValues forKeys:keys];
				[peopleArr addObject:Dic];
				[pValues removeAllObjects];
				[Dic release];
			}
			
		} //end if
	} //end for
//	[selectPerson	setText:@""];
//	[selectPerson reloadAllComponents];
	[pValues release];
}



//客名前によって；情報を検索する
- (void)getCusInfo:(NSString *)strPeopleID
{ 
	[cusVegeArr removeAllObjects];

	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerInfo"]]];
	[request setPostValue:strPeopleID forKey:@"CustomerCD"];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[self parseCustomInfo:str];
	[self refreshView];
}


//客の情報
- (void)parseCustomInfo:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	NSMutableArray *cValues = [[NSMutableArray alloc] init];
	nodes = [theDoc children];
	if (nodes==0) 
	{
		return;
	}
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{				
			NSArray *childs = [node children];						//item 
			
			for (CXMLElement *tmpE in childs)						// ele
			{
				if([tmpE isKindOfClass:[CXMLElement class]])
				{
					if ([tmpE childCount] == 1)						//the node value
					{
						[cValues addObject:[tmpE stringValue]];
					}
					else if([tmpE childCount] ==0)
					{
						[cValues addObject:@""];
					}
					else											//aregugi vegetable
					{
						[cValues addObject:tmpE];	
					}
				}//end if
			}//end for
			
			if ([cValues count] ==10) // dic objest.count =keys.count
			{
				if (cdic)
				{
					cdic=nil;
				}
				cdic = [[NSMutableDictionary alloc] initWithObjects:cValues forKeys:ckeys];
				[cValues removeAllObjects];
			}
			
		} //end if
	} //end for
	[cValues release];
	
}


//設定画面の値
- (void)refreshView
{
	if (cdic.count	<=	0) 
	{
		NSMutableArray	*aryCusVal		=	[[NSMutableArray	alloc]	init];
		[aryCusVal	addObject:@" "];
		[aryCusVal	addObject:@" "];
		NSMutableDictionary	*cusDic= [NSMutableDictionary dictionaryWithObjects:aryCusVal forKeys:vegeKeys];
		[cusVegeArr	removeAllObjects];
		for (int i=0; i<4; i++) 
		{
					[cusVegeArr	addObject:cusDic];
		}
		[aryCusVal	release];
		return;
	}
	[yoyaku setText:[cdic valueForKey:@"knamekana"]];
	[sex setText:[cdic valueForKey:@"sex"]];
	
	[companyName setText:[cdic valueForKey:@"companyName"]];
	[mobileTel	 setTitle:[cdic valueForKey:@"companyPhone"] forState:UIControlStateNormal];
	[companyFax setText:[cdic valueForKey:@"companyFax"]];
	
	[_email setText:[cdic valueForKey:@"email1"]];
	[memTextView setText:[cdic valueForKey:@"memo"]];
	[ngTextView setText:[cdic valueForKey:@"NG"]];
	
	[self setAllegy:[cdic valueForKey:@"allergyID"]];
	[self setVege:[cdic valueForKey:@"vegetable"]];
	
}

 
- (void)setAllegy:(CXMLElement *)allegryIDArr
{
	NSMutableArray *tmpAre = [[NSMutableArray alloc] initWithCapacity:4];
	
	if ([allegryIDArr childCount] >0) 
	{
		for (CXMLElement *tmpE in [allegryIDArr children])						// ele
		{
			if([tmpE isKindOfClass:[CXMLElement class]])
			{
				if ([tmpE childCount] ==0) 
				{
					[tmpAre addObject:@" "];
				}
				else 
				{
					[tmpAre addObject:[tmpE stringValue]];
				}
				
			}
		}
		
		//set value
		[arerugi_First setText:[tmpAre objectAtIndex:0]];	
		[arerugi_Second setText:[tmpAre objectAtIndex:1]];
		[arerugi_Third setText:[tmpAre objectAtIndex:2]];
		[arerugi_Four setText:[tmpAre objectAtIndex:3]];
	}
	[tmpAre	release];
}

- (void)setVege:(CXMLElement *)vegetableArr
{
	NSMutableArray *tmpVege = [[NSMutableArray alloc] initWithCapacity:8];
	
	if ([vegetableArr childCount] >0) 
	{
		for (CXMLElement *tmpE in [vegetableArr children])						// ele
		{
			if([tmpE isKindOfClass:[CXMLElement class]])
			{
				if ([tmpE childCount] ==0) 
				{
					[tmpVege addObject:@" "];
				}
				else 
				{
					[tmpVege addObject:[tmpE stringValue]];
				}

			}
		}
		
		
		[vege_First setText:[tmpVege objectAtIndex:0]];
		[vege_Second setText:[tmpVege objectAtIndex:1]];
		[vege_Third setText:[tmpVege objectAtIndex:2]];
		[vege_Four setText:[tmpVege objectAtIndex:3]];
		
		
		//客様のベジタリアに
		[cusVegeValues addObject:[tmpVege objectAtIndex:0]];
		[cusVegeValues addObject:[tmpVege objectAtIndex:4]];
		NSMutableDictionary *cusVegeDic1 = [NSMutableDictionary dictionaryWithObjects:cusVegeValues forKeys:cusVegeKeys];
		[cusVegeArr addObject:cusVegeDic1];
		[cusVegeValues removeAllObjects];
		
		[cusVegeValues addObject:[tmpVege objectAtIndex:1]];
		[cusVegeValues addObject:[tmpVege objectAtIndex:5]];
		NSMutableDictionary *cusVegeDic2 = [NSMutableDictionary dictionaryWithObjects:cusVegeValues forKeys:cusVegeKeys];
		[cusVegeArr addObject:cusVegeDic2];
		[cusVegeValues removeAllObjects];
		
		[cusVegeValues addObject:[tmpVege objectAtIndex:2]];
		[cusVegeValues addObject:[tmpVege objectAtIndex:6]];
		NSMutableDictionary *cusVegeDic3 = [NSMutableDictionary dictionaryWithObjects:cusVegeValues forKeys:cusVegeKeys];
		[cusVegeArr addObject:cusVegeDic3];
		[cusVegeValues removeAllObjects];
		
		[cusVegeValues addObject:[tmpVege objectAtIndex:3]];
		[cusVegeValues addObject:[tmpVege objectAtIndex:7]];
		NSMutableDictionary *cusVegeDic4 = [NSMutableDictionary dictionaryWithObjects:cusVegeValues forKeys:cusVegeKeys];
		[cusVegeArr addObject:cusVegeDic4];
		[cusVegeValues removeAllObjects];
		
		
		[oldVegeCD removeAllObjects];
		[oldVegeCD addObject:[tmpVege objectAtIndex:4]];
		[oldVegeCD addObject:[tmpVege objectAtIndex:5]];
		[oldVegeCD addObject:[tmpVege objectAtIndex:6]];
		[oldVegeCD addObject:[tmpVege objectAtIndex:7]];


	}
	[tmpVege	release];

}





//---------------------------------------------------------------------------------------------------------
#pragma mark --NWPickerField--
-(void)pickerField:(NWPickerField *)pickerField didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(row<=0)
	{
		if (selectPerson	==	pickerField) 
		{
			[self	releaseRefreshView];
			[self	showHisDetailCopyInfo];
		}
		return;
	}
	
	//お客様の情報を更新する
	if (selectPerson ==pickerField)
	{
		[self	releaseRefreshView];
		if ([peopleArr count]>0)
		{
			//[selectPerson	setText:[[peopleArr objectAtIndex:row] objectForKey:@"CustomerName"]];
			NSString *customID = [[peopleArr objectAtIndex:row] objectForKey:@"CustomerID"];
			customCD = customID;
			
			[self getCusInfo:customID];
			
			[self getAreData];
			[self getVegeData];
		}
	}
	
	if (vege_First ==pickerField) 
	{
		[cusVegeArr replaceObjectAtIndex:0 withObject:[vegeArr objectAtIndex:row]];
	}
	if(vege_Second ==pickerField)
	{
		[cusVegeArr replaceObjectAtIndex:1 withObject:[vegeArr objectAtIndex:row]];
	}
	if(vege_Third ==pickerField)
	{
		[cusVegeArr replaceObjectAtIndex:2 withObject:[vegeArr objectAtIndex:row]];
	}
	if(vege_Four==pickerField)
	{
		[cusVegeArr replaceObjectAtIndex:3 withObject:[vegeArr objectAtIndex:row]];
	}
}


-(NSInteger) numberOfComponentsInPickerField:(NWPickerField*)pickerField 
{	
	return 1;
}


-(NSInteger) pickerField:(NWPickerField*)pickerField numberOfRowsInComponent:(NSInteger)component
{
	
	//selectPerson
	if (pickerField == selectPerson)		
	{
		if([peopleArr count]>0)
			return [peopleArr count];
		return 1;
	}
	else if(pickerField==arerugi_First || arerugi_Second ==pickerField || arerugi_Third==pickerField || arerugi_Four==pickerField)
	{
		if (arerugiArr.count >0) 
			return arerugiArr.count;
	}
	else if(pickerField==vege_First || vege_Second ==pickerField || vege_Third==pickerField || vege_Four==pickerField)
	{
		if (vegeArr.count >0) 
			return vegeArr.count;
	}
	else 
	{
		return 1;
	}


}

-(NSString *) pickerField:(NWPickerField *)pickerField titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if (pickerField == selectPerson) 
	{
		if([peopleArr count]>0)
			return [[peopleArr objectAtIndex:row] objectForKey:@"CustomerName"];
		return @"";
	}
	else if(pickerField==arerugi_First || arerugi_Second ==pickerField || arerugi_Third==pickerField || arerugi_Four==pickerField)
	{
		if(arerugiArr.count>0)
			return [[arerugiArr objectAtIndex:row] objectForKey:@"areName"];
		return @"";
	}
	else if(pickerField==vege_First || vege_Second ==pickerField || vege_Third==pickerField || vege_Four==pickerField)
	{
		if (vegeArr.count >0) 
			return [[vegeArr objectAtIndex:row] objectForKey:@"vegeName"];
		return @"";
	}
	else 
	{
		return @"";
		
	}

	
}


//-(NSInteger) pickerField:(NWPickerField *)pickerField rowForTitle:(NSString*)title {
//	return [data indexOfObject:title];
//}



//アレルギーのデータを取る
- (void)getAreData
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetAllergyNameList"]]];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[arerugiArr	removeAllObjects];
	[self parseAreXml:str];
	[self areComponsReload];
}

- (void)parseAreXml:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray *areValues = [[NSMutableArray alloc] init];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{				
			NSArray *childs = [node children];	
			CXMLElement *child = [childs objectAtIndex:0];			//item
			
			for (CXMLElement *tmpNode in [child children]) 
			{
				if ([tmpNode isKindOfClass:[CXMLElement class]])				//string
				{
					//id aa = tmpNode;
					[areValues addObject:[tmpNode stringValue]];
				}
			}
			if (areValues.count ==2)
			{
				NSMutableDictionary * areDic= [NSMutableDictionary dictionaryWithObjects:areValues forKeys:areKeys];
				[arerugiArr addObject:areDic];
				[areValues removeAllObjects];
			}
		}
	}
	[areValues release];
}

- (void)areComponsReload
{
	[arerugi_First reloadAllComponents];
	[arerugi_Second reloadAllComponents];
	[arerugi_Third reloadAllComponents];
	[arerugi_Four reloadAllComponents];
}


//ベジタリアにデータを取る
- (void)getVegeData
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetVegetaria"]]];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[vegeArr	removeAllObjects];
	[self parseVegeXml:str];
	[self vegeComponsReload];
}

- (void)parseVegeXml:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray * vegeValues = [[NSMutableArray alloc] init];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{				
			NSArray *childs = [node children];	
			CXMLElement *child = [childs objectAtIndex:0];			//item
			
			for (CXMLElement *tmpNode in [child children]) 
			{
				if ([tmpNode isKindOfClass:[CXMLElement class]])				//string
				{
					[vegeValues addObject:[tmpNode stringValue]];
				}
			}
			if (vegeValues.count ==2)
			{
				NSMutableDictionary *vegeDic= [NSMutableDictionary dictionaryWithObjects:vegeValues forKeys:vegeKeys];
				[vegeArr addObject:vegeDic];
				[vegeValues removeAllObjects];
			}
		}
	}
	[vegeValues release];
}

- (void)vegeComponsReload
{
	[vege_First reloadAllComponents];
	[vege_Second reloadAllComponents];
	[vege_Third reloadAllComponents];
	[vege_Four reloadAllComponents];
}

//------------------------------------------------------------------------------------------------//

//text position move 
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if (textView == memTextView) 
	{
		[UIView beginAnimations:nil context:memTextView];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		CGRect frame = textView.frame;
		frame.origin.y = 200;    
		
		frame.size.height=	100;	 
		[textView setFrame:frame];
		[UIView commitAnimations];
	}
	else if(textView == ngTextView)
	{
		[UIView beginAnimations:nil context:ngTextView];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		CGRect frame = textView.frame;
		frame.origin.y = 200;    
		
		frame.size.height=	100;	 
		[textView setFrame:frame];
		[UIView commitAnimations];
	}

}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if(textView == memTextView)
	{
		[UIView beginAnimations:@"mem" context:memTextView];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1];
		
		CGRect frame = textView.frame;
		frame.origin.y = 486;    
		
		frame.size.height=	79;	 
		[textView setFrame:frame];
		[UIView commitAnimations];
	}
	else if(textView ==ngTextView)
	{
		[UIView beginAnimations:@"ng" context:ngTextView];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:1];
		
		CGRect frame = textView.frame;
		frame.origin.y = 590;    
		
		frame.size.height=	93;	 
		[textView setFrame:frame];
		[UIView commitAnimations];
	}

}

#pragma mark --updateCustomInfo--
//お客様の情報を更新
- (IBAction)updateCustomInfo:sender
{
	NSString *loginID = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString *cusCD   = customCD;
	NSString *cusName = yoyaku.text;
	NSString *cusSex  = sex.text;
	
	NSString *cusMail		 =_email.text;
	NSString *cusCompanyname = companyName.text;
	NSString *cusMobileTel  = mobileTel.titleLabel.text;	
	NSString *cusCompanyFax  = companyFax.text;
	
	NSString *cusNg =ngTextView.text;
	NSString *cusMem=memTextView.text;

	
	BOOL didMatch           = NO;
	if([cusMobileTel length]>0)
	{
		didMatch=[cusMobileTel isMatchedByRegex:@"^([0-9]{1,5})-([0-9]{1,4})-([0-9]{4})$"];
		if(!didMatch)
		{
			[common	showErrorAlert:@"電話番号はxxx-xxxx-xxxx形式\n入力してください。"];
			return;
		}
	}
	
	
	
	BOOL	mailMath		=NO;
	if([cusMail length]>0)
	{
		mailMath	=[cusMail isMatchedByRegex:@"\\b([a-zA-Z0-9%_.+\\-]+)@([a-zA-Z0-9.\\-]+?\\.[a-zA-Z]{2,6})\\b"];
		if(!mailMath)
		{
			[common	showErrorAlert:@"正しいメール\n入力してください。"];
			return;
		}
	}
	
	NSString *are1 = [arerugi_First text];
	NSString *are2 = [arerugi_Second text];
	NSString *are3 = [arerugi_Third text];
	NSString *are4 = [arerugi_Four text];
	
	NSString *vege1=    @"";		
	NSString *vege1CD = @"";		
	
	NSString *vege2 =   @"";		
	NSString *vege2CD = @"";		
	
	NSString *vege3  =  @"";		
	NSString *vege3CD = @"";		
	
	NSString *vege4  =  @"";		
	NSString *vege4CD = @"";		
	
//	if(cusVegeArr.count>=3)
//	{
//		[[cusVegeArr objectAtIndex:0] objectForKey:@"vegeName"];
//		[oldVegeCD objectAtIndex:0];
//		
//		[[cusVegeArr objectAtIndex:1] objectForKey:@"vegeName"];
//		[oldVegeCD objectAtIndex:1];
//		
//		[[cusVegeArr objectAtIndex:2] objectForKey:@"vegeName"];
//		[oldVegeCD objectAtIndex:2];
//		
//		[[cusVegeArr objectAtIndex:3] objectForKey:@"vegeName"];
//		[oldVegeCD objectAtIndex:3];
//	}
	
	
	NSString *cusinfo = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@;%@",loginID,cusCD,cusName,cusSex,cusMail,cusCompanyname,cusMobileTel,
						 cusCompanyFax,cusNg,cusMem,are1,are2,are3,are4,vege1,vege2,vege3,vege4,vege1CD,vege2CD,vege3CD,vege4CD];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateCustomerInfo"]]];
	[request setPostValue:cusinfo forKey:@"updateInfo"];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];

	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	if ([[theDoc stringValue] isEqualToString:@"true"]) 
	{
		[common showSuccessAlert:@"更新しました！"];
	}
	else {
		[common showErrorAlert:@"更新失敗しました！"];
	}

}



- (BOOL)priceInputClick:(PriceInput	*)prieInput
{
	return	NO;
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
	[adtextField setTextColor:[UIColor blackColor]];
}
 */

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    // Overriden to allow any orientation.
    //return YES;
	return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}

- (void)dealloc 
{
	[arerugiArr release];
	[vegeArr release];
	
	[selectPerson release];
	
	[yoyaku release];
	[sex release];
	[companyName release];
	[mobileTel	release];
	[companyFax release];
	[_email release];
	
	[ngTextView release];
	[memTextView release];
	
	[arerugi_First release];
	[arerugi_Second release];
	[arerugi_Third release];
	[arerugi_Four release];
	
	[vege_First release];
	[vege_Second release];
	[vege_Third release];
	[vege_Four release];
	
	//[keys	release];
//	[ckeys	release];
//	[areKeys	release];
//	[vegeKeys	release];
//	[cusVegeKeys	release];
	
//	[values	release];
//	[cvalues	release];
//	[areValues	release];
//	[vegeValues	release];
//	[cusVegeValues	release];
//
	if (cusVegeArr)
 {
		cusVegeArr=nil;
	}
//	[cusVegeArr	release];
	if (cdic) 
	{
		cdic=nil;
	}

//	if (dic) 
//	{
//		[dic release];
//	}
//	[oldVegeCD	release];
//	
//	[peopleArr	release];
	[super dealloc];
}


@end
