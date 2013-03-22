    //
//  OrderMenuViewController.m
//  MasterDetail
//
//  Created by fly on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "OrderMenuViewController.h"
#import "SearchCustomerController.h"
#import "OrderConfirmCell.h"
#import "common.h"

@implementation OrderMenuViewController
@synthesize delegate;

@synthesize searchCustomerController;
@synthesize _orderMenuSelect;
@synthesize _orderMenuName;
@synthesize buttonTel;
@synthesize _orderCustomerCount;

@synthesize _tableView;
@synthesize mrecords;
@synthesize timeField;
@synthesize type;
@synthesize typePickerData;

@synthesize kuponField;
@synthesize kuponPickerData;
@synthesize buttonCheckBox;

@synthesize houseField,housePickerData;
@synthesize toMergeHouse;
@synthesize shopId;
@synthesize roomName;
@synthesize	roomCD;
@synthesize dateStr;
@synthesize visitTime;
@synthesize companyName;
@synthesize daihyou;
@synthesize memo;
@synthesize _visitDateText;
@synthesize	weekDateLabel;
@synthesize isUpdateOrInsert;

@synthesize sliderView;
@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;

@synthesize redValue;
@synthesize greenValue;
@synthesize blueValue;

@synthesize orderId;
@synthesize isDayOrNight;

//@synthesize yoyakuField;

@synthesize oldHouseCD;
@synthesize selectComment;
@synthesize selectCommentPickerData;
@synthesize selectCommentId;
@synthesize	cusCD;
@synthesize	labelRoom;

ASIFormDataRequest *request;
static UIButton *s = nil;
static UIButton *sscal = nil;

//NSMutableArray		*setRoomArr;
//NSMutableArray		*setRoomKeys;
//NSMutableArray		*setRoomValues;
NSMutableDictionary *setDic;
NSMutableArray		*roomValueArr;

NSMutableArray	 *peopleArr;
NSMutableArray		*keys;					//検索人
NSMutableArray		*values;
NSMutableDictionary *dic;

NSString			*cusCD;

//------------------------------------------------begin--------------------------------------------------//
#pragma mark --textFieldShouldBeginEditing--
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	if (textField == timeField)  //1024 748
	{
		s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		timePicker = [[[UIDatePicker alloc] init] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		timePicker.frame = CGRectMake( 500, 1024, 200, 200 );			//149 69;
		timePicker.tag = 201;
		timePicker.datePickerMode = UIDatePickerModeTime;
		timePicker.minuteInterval = 15;
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"HH:mm"];
		
		NSDate *date;
		if ([isDayOrNight isEqualToString:@"1"]) 
		{
			date = [dateFormat dateFromString:@"12:00"];
		}
		else 
		{
			date = [dateFormat dateFromString:@"18:00"];
		}
		
		[dateFormat	release];
		[timePicker setDate:date];
		[self performSelector:@selector(timeFieldDefaultTime) withObject:nil afterDelay:.3];
		
		
		[s addSubview:timePicker];
		timePicker.frame = CGRectMake(500, 100, 200, 200);
		[timePicker addTarget:self action:@selector(chagedDate:) forControlEvents:UIControlEventValueChanged];
		
		[UIView setAnimationDuration:2.0];
		[UIView commitAnimations];
		
		return NO;
	}
	else if(textField == type)
	{
		s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		
		typePicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 500, 768, 200, 162 )] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		typePicker.showsSelectionIndicator = YES;
		typePicker.tag = 202;
		typePicker.delegate = self;
		typePicker.dataSource = self;
		
		[s addSubview:typePicker];
		typePicker.frame = CGRectMake(500, 100, 300, 162);
		[typePicker selectRow:0 inComponent:0 animated:YES];
		
		
		[UIView setAnimationDuration:2.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
		
		return NO;
	}
	else if(textField == kuponField)
	{
		s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		
		kuponPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 500, 768, 200, 162 )] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		kuponPicker.showsSelectionIndicator = YES;
		kuponPicker.tag = 202;
		kuponPicker.delegate = self;
		kuponPicker.dataSource = self;
		
		[s addSubview:kuponPicker];
		kuponPicker.frame = CGRectMake(500, 100, 300, 162);
		[kuponPicker selectRow:0 inComponent:0 animated:YES];
		
		[UIView setAnimationDuration:2.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
		
		return NO;
		
	}
	else if(textField == houseField)
	{
		s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		housePicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 500, 768, 200, 162 )] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		housePicker.showsSelectionIndicator = YES;
		housePicker.tag = 202;
		housePicker.delegate = self;
		housePicker.dataSource = self;

		[s addSubview:housePicker];
		housePicker.frame = CGRectMake(500, 100, 300, 162);
		[housePicker selectRow:0 inComponent:0 animated:YES];
		
		
		[UIView setAnimationDuration:2.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
		
		return NO;
		
	}
    
	else if(textField == _orderMenuSelect)
	{
        NSString *tel = buttonTel.titleLabel.text;
        if([tel length]==0){
            return NO;
        }
        s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		yoyakuPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 500, 768, 200, 162 )] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		yoyakuPicker.showsSelectionIndicator = YES;
		yoyakuPicker.tag = 209;
		yoyakuPicker.delegate = self;
		yoyakuPicker.dataSource = self;
		
		[s addSubview:yoyakuPicker];
		yoyakuPicker.frame = CGRectMake(500, 100, 300, 162);
		[yoyakuPicker selectRow:0 inComponent:0 animated:YES];
		
		[UIView setAnimationDuration:2.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
		
        [self searchInfo];
        [yoyakuPicker reloadAllComponents];
		return NO;
		
	}
    
    
    
	else if(textField == selectComment)
	{
		s = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
		[s addTarget:self action:@selector(Dismiss:) forControlEvents:UIControlEventTouchUpInside];
		s.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.5];
		[self.view addSubview:s];
		
		
		selectCommentPicker = [[[UIPickerView alloc] initWithFrame:CGRectMake( 500, 768, 200, 162 )] autorelease];
		[UIView beginAnimations:nil context:nil];
		
		selectCommentPicker.showsSelectionIndicator = YES;
		selectCommentPicker.delegate = self;
		selectCommentPicker.dataSource = self;
		
		[s addSubview:selectCommentPicker];
		selectCommentPicker.frame = CGRectMake(500, 100, 300, 162);
		[selectCommentPicker selectRow:0 inComponent:0 animated:YES];
		
		
		[UIView setAnimationDuration:2.0];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView commitAnimations];
		
		[self getSelectComments];
		[selectCommentPicker reloadAllComponents];
		return NO;
	}
	

	
	return YES;
}

//選択できるコメンート
- (void)getSelectComments
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetSelectComment"]]];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//item" error:&error];
	selectCommentPickerData = [[NSMutableArray alloc]initWithArray:resultNodes];
	[xmlDoc	release];
}


-(void)timeFieldDefaultTime
{
	if ([isDayOrNight isEqualToString:@"1"]) 
	{
		[timeField setText:@"12:00"];
	}
	else 
	{
		[timeField setText:@"18:00"];
	}
}


#pragma mark --情報を検索する--
- (void)searchInfo
{	//liukeyu	add	release
	if (peopleArr)
    {
			[peopleArr	release];
	}
	//liukeyu	add	end
	
	peopleArr = [[NSMutableArray alloc] init];
	keys      = [[NSMutableArray alloc] initWithObjects:@"CustomerCD",@"CustomerName",nil];
	values    = [[NSMutableArray alloc] init];
	
	NSString *tel = buttonTel.titleLabel.text;
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerNameList"]]];
	[request setPostValue:tel forKey:@"keys"];
	
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
	[self parseNameList:str];

     }


- (void)getShopType
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetShopType"]]];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	//[self parseNameList:str];
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray *shopType=[[NSMutableArray alloc] initWithObjects:@" ",nil]; 

	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{
			CXMLNode *childs =[[[node childAtIndex:0]	childAtIndex:0]	childAtIndex:0];					//item 
			[shopType addObject:[childs stringValue]];
		}
	}
	self.typePickerData = shopType;
	[shopType release];
}

//フォマと xml
- (void)parseNameList:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	NSMutableArray *shopValues=[[NSMutableArray alloc] init];
	NSMutableArray 	*Xkeys = [[NSMutableArray alloc] initWithObjects:@"CustomerCD",@"CustomerName",nil];
	
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
						[shopValues addObject:@""];
					}
					else 
					{
						CXMLNode *node = [[tmpE children] objectAtIndex:0];
						[shopValues addObject:[node stringValue]];	
					}
				}//end if
			}//end for
			
			if ([shopValues count] ==2) // dic objest.count =keys.count
			{
				NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjects:shopValues forKeys:Xkeys];
				[peopleArr addObject:dic];
				[shopValues removeAllObjects];
			}
			
		} //end if
	} //end for
	[Xkeys release];
	[shopValues release];
	//[yoyakuPicker reloadAllComponents];
//	[doc	release];
}



//picker value change
- (void)chagedDate:sender
{
	NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease]; 
	formatter.dateFormat = @"HH:mm"; 
	NSString *timestamp = [formatter stringFromDate:timePicker.date]; 
	
	[timeField setText:timestamp];
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
//	[ timePicker removeFromSuperview ];
//	NSInteger	srCount=[s	retainCount];
//	if(srCount==0)
//		return;
	
	if([context	isKindOfClass:[UITextView	class]])
	{
		return;
	}
	[ s removeFromSuperview ];
}

-(void)Dismiss:(id)p
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	if (UIInterfaceOrientationLandscapeLeft == [UIApplication sharedApplication].statusBarOrientation) {
		
	}
	
	s.frame = CGRectMake( 0, 768, 1024, 748 );
	[UIView commitAnimations];
}



#pragma mark -
#pragma mark picker dataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(pickerView == typePicker)
	{
		return [typePickerData count];
	}
	else if(pickerView == kuponPicker)
	{
		return [kuponPickerData count];
	}
	else if(pickerView == housePicker)
	{
		return [housePickerData count];
	}
	else if(pickerView ==yoyakuPicker)
		return peopleArr.count;
	else if(pickerView==selectCommentPicker)
		return	selectCommentPickerData.count;
	
	return 1;
}

#pragma mark -
#pragma mark picker delegate
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(pickerView ==typePicker)
	{
		return [typePickerData objectAtIndex:row];
	}
	else if(pickerView == kuponPicker)
	{
		return [kuponPickerData objectAtIndex:row];
	}
	else if(pickerView == housePicker)
	{
		return [housePickerData objectAtIndex:row];
	}
    
	else if(pickerView ==yoyakuPicker)
	{
		if(peopleArr.count>0)
			return [[peopleArr objectAtIndex:row] objectForKey:@"CustomerName"];
	}
	else if(pickerView ==selectCommentPicker)
	{
		if(selectCommentPickerData.count>0)
		{
			DDXMLNode *item =[selectCommentPickerData objectAtIndex:row];
			return [[item childAtIndex:1] stringValue];
		}
	}
	return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	if(pickerView == typePicker)
	{
		if(typePickerData.count>0)
			[type setText:[typePickerData objectAtIndex:row]];
	}
	else if(pickerView == kuponPicker)
	{
		if(kuponPickerData.count>0)
			[kuponField setText:[kuponPickerData objectAtIndex:row]];
	}
	else if(pickerView == housePicker)
	{
		if(housePickerData.count >0)
			[houseField setText:[housePickerData objectAtIndex:row]];
	}
   
	else if(pickerView ==yoyakuPicker)
	{
		if(peopleArr.count>0)
		{
			[_orderMenuSelect setText:[[peopleArr objectAtIndex:row]objectForKey:@"CustomerName"]];
            [_orderMenuName setText:[[peopleArr objectAtIndex:row]objectForKey:@"CustomerName"]];
			self.cusCD= [[peopleArr objectAtIndex:row]objectForKey:@"CustomerCD"];
			[self peoPelCDUpInfo:self.cusCD];
		}
			
	}
     
	else if(pickerView ==selectCommentPicker)
	{
		if(selectCommentPickerData.count>0)
		{
			DDXMLNode *item =[selectCommentPickerData objectAtIndex:row];
		//	NSString *strSelCommentId=[[item childAtIndex:0] stringValue];
			self.selectCommentId = [[[selectCommentPickerData objectAtIndex:row] childAtIndex:0] stringValue];
			
			NSString  *selCommentStr = [[item childAtIndex:1] stringValue];
			[selectComment setText:selCommentStr];
		}
	}
	
}


//お客様CDによって；予約名、会社名を取る
- (void)peoPelCDUpInfo:(NSString *)custCD
{
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCustomerInfo2"]]];
	[request setPostValue:custCD forKey:@"customerCD"];
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	[self parsePelUpInfoXML:str];
}

//company
- (void)parsePelUpInfoXML:(NSString *)str
{
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//companyName" error:&error];
	[xmlDoc	release];
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	if(resultNodes.count ==0)
	{
//		[companyName setText:@""];
		return;
	}
	NSString *strCompany = [[resultNodes objectAtIndex:0] stringValue];
	[companyName setText:strCompany];
}


//==============================================================================================================================
static	BOOL IsHavingToCombineHouse() 
{
	return [ [ NSUserDefaults standardUserDefaults ] integerForKey:@"IsCombineHouseSaveFlag" ];
}

static	BOOL HavingToCombineHouse( BOOL p ) 
{
	[ [ NSUserDefaults standardUserDefaults ] setInteger:p forKey:@"IsCombineHouseSaveFlag" ];
	[ NSUserDefaults standardUserDefaults ].synchronize;
	return p;
}


- (void) SyncCheckBox 
{
	[ buttonCheckBox setBackgroundImage:[UIImage imageNamed:IsHavingToCombineHouse()? @"check01.png" :@"check02.png"] forState:UIControlStateNormal];
}

- (IBAction)checkboxAction 
{	
	HavingToCombineHouse( ! IsHavingToCombineHouse() );
	self.SyncCheckBox;
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

- (BOOL)textFieldShouldReturn:(UITextField*)aTextField
{
    [aTextField resignFirstResponder];
    return YES;
}


//-------------------------------------------------------------------------------------------------------------------------------

- (void)customSlider
{
	UIImage *redimg = [[UIImage imageNamed:@"redslider.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	UIImage *greenimg = [[UIImage imageNamed:@"greenslider.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	UIImage *blueimg = [[UIImage imageNamed:@"blueslider.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	
	UIImage *thumimg = [[UIImage imageNamed:@"ball.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	UIImage *whiteimg = [[UIImage imageNamed:@"whiteslider.png"] stretchableImageWithLeftCapWidth:10.0 topCapHeight:0.0];
	
//	greenSlider.backgroundColor = [UIColor clearColor];
	
	
	[redSlider setMinimumTrackImage:redimg forState:UIControlStateNormal];
	[redSlider setThumbImage:thumimg forState:UIControlStateNormal];
	[redSlider setMaximumTrackImage:whiteimg forState:UIControlStateNormal];
	[redSlider addTarget:self action:@selector(SliderClick:) forControlEvents:UIControlEventValueChanged];
	[redSlider setValue:redValue];
	
	[greenSlider setMinimumTrackImage:greenimg forState:UIControlStateNormal];
	[greenSlider setThumbImage:thumimg forState:UIControlStateNormal];
	[greenSlider setMaximumTrackImage:whiteimg forState:UIControlStateNormal];
	[greenSlider addTarget:self action:@selector(SliderClick:) forControlEvents:UIControlEventValueChanged];
	[greenSlider setValue:greenValue];
	
	[blueSlider setMinimumTrackImage:blueimg forState:UIControlStateNormal];
	[blueSlider setThumbImage:thumimg forState:UIControlStateNormal];
	[blueSlider setMaximumTrackImage:whiteimg forState:UIControlStateNormal];
	[blueSlider addTarget:self action:@selector(SliderClick:) forControlEvents:UIControlEventValueChanged];
	[blueSlider setValue:blueValue];
	
	UIColor *sliderColor = [UIColor colorWithRed:redValue green:greenValue blue:blueValue alpha:1.0];
	sliderView.backgroundColor = sliderColor;

}

#pragma mark --sliderColor--
- (IBAction)SliderClick:(id)sender
{
	UIColor *sliderColor = [UIColor colorWithRed:redSlider.value green:greenSlider.value blue:blueSlider.value alpha:1.0];
	sliderView.backgroundColor = sliderColor;
}

#pragma mark --viewDidLoad--
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
    //setRoomValues= [[NSMutableArray alloc] init];
	
	[self customSlider];
	[_visitDateText setTitle:dateStr forState:UIControlStateNormal];
	
	NSDateFormatter *formatterCal = [[[NSDateFormatter alloc] init] autorelease]; 
	//formatterCal.dateFormat = @"yyyy年MM月dd日";
	[formatterCal	setDateFormat:@"yyyy/M/d"];
	
	NSDate	*dateWeek	=	[formatterCal	dateFromString:dateStr];
	
    [formatterCal	setDateFormat:@"EEEE"];
	
	NSString *weekTampCal = [formatterCal stringFromDate:dateWeek]; 
	[weekDateLabel	setText:weekTampCal];
	
	NSString	*roomLabelShow=[NSString	stringWithFormat:@"%@	[%@]",roomName,roomCD];
	[labelRoom	setText:roomLabelShow];
	
	[self._tableView setEditing:TRUE animated:TRUE];
	self._tableView.allowsSelectionDuringEditing = YES;
	
    
	[self getReceiptedDataSource];	//応答データ
	[self syokikakuponDateScoure];	//クーポン初期化picker
	
	[self getSetRoomDataSource];	//SetRoomを取る
    [self getShopType];
	
//	NSArray *houseArray = [[NSArray alloc] initWithObjects:@"",@"部屋1",@"部屋2",@"部屋3",@"部屋4",@"部屋5",@"部屋6",@"部屋7",@"部屋8",@"部屋9",@"部屋10",nil];
//	self.housePickerData = houseArray;
//	[houseArray release];
/*
	if (mrecords == nil) 
	{
		mrecords = [[NSMutableArray alloc] init];
	}
*/
//	[_tableView reloadData];
   }


#pragma mark --SetRoomを取る--
- (void)getSetRoomDataSource
{
	NSString	*uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString	*replayKeys = [NSString stringWithFormat:@"%@;%@;%@;%@;%@",uid,shopId,dateStr,self.roomName,isDayOrNight];
    
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetRoomBySingleRoom"]]];
	[request setPostValue:replayKeys forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	//[setRoomArr	removeAllObjects];
    
	[self parseSetRoomDataXml:str];
	//[self sethousePickerData];
}
- (void)parseSetRoomDataXml:(NSString *)str
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
    
    NSMutableArray *setRoomArr = [[NSMutableArray alloc] initWithObjects:@"",nil];
    
	NSMutableArray *setRoomKeys= [[NSMutableArray alloc] initWithObjects:@"roomCD",@"roomName",nil];

    
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	NSMutableArray	*tempRoomVal=[[NSMutableArray alloc] init];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{
			CXMLNode *child = [node childAtIndex:0];
			for (CXMLElement *tmpE in [child children]) 
			{
				if ([tmpE isKindOfClass:[CXMLElement class]])				//string
				{
					if ([[tmpE	stringValue]	length]	>	0) {
						[tempRoomVal addObject:[tmpE stringValue]];
					}
				}
			}
			if (tempRoomVal.count==2) 
			{
				setDic = [NSMutableDictionary dictionaryWithObjects:tempRoomVal forKeys:setRoomKeys];
				[setRoomArr addObject:[setDic objectForKey:@"roomName"]];
			}
			[tempRoomVal removeAllObjects];
		}
	}
    self.housePickerData = setRoomArr;
    [setRoomArr release];
    [setRoomKeys release];
	[tempRoomVal release];		
}
/* liukeyu 20121129
//housePickerDataを設定する
- (void)sethousePickerData
{
	NSMutableArray *tmpArr = [[NSMutableArray alloc] initWithObjects:@"",nil];
	for (int i=0; i<setRoomArr.count; i++) 
	{
		[tmpArr addObject:[[setRoomArr objectAtIndex:i] objectForKey:@"roomName"]];
	}
	self.housePickerData = tmpArr;
    [tmpArr release];
}
*/


//クーポンを初期化する
- (void)syokikakuponDateScoure
{	
	
	NSString	*uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString	*replayKeys = [NSString stringWithFormat:@"%@;%@;%@;",uid,shopId,dateStr];
	
	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetCouponNameList"]]];
	[request setPostValue:replayKeys forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	[self parsekuponXml:str];
}

//kupon xmlを分析する
- (void)parsekuponXml:(NSString *)str
{	
	str = [str stringByReplacingOccurrencesOfString:@"xmlns" withString:@"noNSxml"];
	NSError	 *error=nil;
	DDXMLDocument *xmlDoc = [[DDXMLDocument alloc] initWithXMLString:str options:0 error:&error];
	
	if(error)
		NSLog(@"%@",[error localizedDescription]);
	
	NSArray *resultNodes = nil;
	resultNodes = [xmlDoc nodesForXPath:@"//couponName" error:&error];
	
	NSMutableArray *tmpPickArr = [[NSMutableArray alloc] initWithObjects:@"   ",nil];
	for(int i=0;i<resultNodes.count;i++)
	{
		[tmpPickArr addObject:[[resultNodes objectAtIndex:i] stringValue]];
	}
	self.kuponPickerData = tmpPickArr;
    [tmpPickArr release];
	[xmlDoc	release];
}


//応答データ
- (void)getReceiptedDataSource
{
	NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	if([visitTime length]==0)
		return;
	
	if([visitTime rangeOfString:@":"].length >0) //部屋内容を更新
	{
		NSString	*keyDateTime = [NSString stringWithFormat:@"%@ %@",dateStr,visitTime];
		NSString	*replayKeys = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",uid,shopId,keyDateTime,roomName,isDayOrNight,orderId];
		if([roomName isEqualToString:@""])	//roomName削除したの場合；詳細情報を表示しない
			return;
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"GetReceiptedOrderData"]]];
		[request setPostValue:replayKeys forKey:@"Keys"];
		[request setRequestMethod:@"POST"];
		[request startSynchronous];
		
		NSString *str = [request responseString];
		str = [common formateXmlString:str];
		[self parseXmlReplayResult:str];
	}
	
}


//応答のデータをフォマートする
- (void)parseXmlReplayResult:(NSString *)strReplay
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: strReplay options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	
	NSArray *nodes = NULL;
	nodes = [theDoc children];
	
	for (CXMLElement *node in nodes) 
	{
		if ([node isKindOfClass:[CXMLElement class]])				//string
		{	
			self.shopId	 =  ([[node childAtIndex:0] stringValue] ==nil) ? @"" : [[node childAtIndex:0] stringValue];
			self.oldHouseCD = ([[node childAtIndex:1] stringValue] ==nil) ? @"" : [[node childAtIndex:1] stringValue];
			NSString *rphoneNo = ([[node childAtIndex:2] stringValue] ==nil) ? @"" : [[node childAtIndex:2] stringValue];
			
			self.cusCD=([[node childAtIndex:3] stringValue] ==nil) ? @"0" : [[node childAtIndex:3] stringValue];
			NSString *rvisitDateTime = ([[node childAtIndex:4] stringValue] ==nil) ? @"" : [[node childAtIndex:4] stringValue];
			
		//	NSString *rorderDate = ( [[node childAtIndex:5] stringValue] ==nil) ? @"" : [[node childAtIndex:5] stringValue];
			NSString *rcompanyName =( [[node childAtIndex:6] stringValue] ==nil) ? @"" : [[node childAtIndex:6] stringValue];
			
			NSString *rorderName = ( [[node childAtIndex:7] stringValue] ==nil) ? @"" : [[node childAtIndex:7] stringValue];
			NSString *rrepresentName=(  [[node childAtIndex:8] stringValue] ==nil) ? @"" : [[node childAtIndex:8] stringValue];
			
			NSString *rcustomerCount = ( [[node childAtIndex:9] stringValue]==nil) ? @"" : [[node childAtIndex:9] stringValue];
			NSString *rmemo = ( [[node childAtIndex:11] stringValue] ==nil) ? @"" : [[node childAtIndex:11] stringValue];
			
			NSString *kupon = ( [[node childAtIndex:12] stringValue]==nil) ? @"" :[[node childAtIndex:12] stringValue];
			NSString *typStr = ( [[node childAtIndex:13] stringValue]==nil) ? @"" :[[node childAtIndex:13] stringValue];
			self.orderId = ( [[node childAtIndex:15] stringValue]==nil) ? @"" : [[node childAtIndex:15] stringValue];
		
			self.selectCommentId = ( [[node childAtIndex:16] stringValue]==nil) ? @"" : [[node childAtIndex:16] stringValue];
			NSString *selComent = ( [[node childAtIndex:17] stringValue]==nil) ? @"" : [[node childAtIndex:17] stringValue];
			
			
			
			//setting
			NSArray *dateTimeArr = [rvisitDateTime componentsSeparatedByString:@" "];
			[_visitDateText setTitle:[dateTimeArr objectAtIndex:0] forState:UIControlStateNormal];
			[companyName setText:rcompanyName];
			if (dateTimeArr.count>=2) 
			{
				[timeField setText:[dateTimeArr objectAtIndex:1]];
			}
			[buttonTel setTitle:rphoneNo forState:UIControlStateNormal];
			[_orderMenuName setText:rorderName];
			[daihyou setText:rrepresentName];
			
			[_orderCustomerCount setTitle:rcustomerCount forState:UIControlStateNormal];
			[memo setText:rmemo];
			
			
			[kuponField setText:kupon];
			[type setText:typStr];
			[selectComment setText:selComent];
			[self parseRecords:[node childAtIndex:18]];
		}
		
	}
	
}

//menu's itemフォマーとする
- (void)parseRecords:(CXMLElement *)items
{
	NSMutableArray *menuRecords= [[NSMutableArray alloc] init];
	NSArray *nodes = NULL;
	
	NSMutableArray *tkey =  [NSMutableArray arrayWithObjects:@"_foodCD",@"_foodCount",@"_foodName",@"_foodPrice",nil];  //@"_foodDescription"
	NSMutableArray *tvalue =[[NSMutableArray alloc] init];
	NSMutableDictionary   *tdic;
	
	if([items	childCount]==0)
	{
		[tvalue	release];
		[menuRecords	release];
		return;
	}
	
	nodes = [items children];
	for (CXMLElement *tmpE in nodes)
	{
		if([tmpE isKindOfClass:[CXMLElement class]])			//item
		{
			for (CXMLElement *itemE in [tmpE children]) 
			{
				if ([itemE isKindOfClass:[CXMLElement class]]) 
				{
					[tvalue addObject:[itemE stringValue]];
				}
			}
			tdic = [[NSMutableDictionary alloc] initWithObjects:tvalue forKeys:tkey];
			[menuRecords addObject:tdic];
			[tvalue removeAllObjects];
			[tdic	release];
		}
	}
	[menuRecords	retain];
    /*
	if (mrecords)
    {
		[mrecords release];
	}
     */
	self.mrecords = menuRecords;
	[menuRecords	release];
	[_tableView reloadData];
	[tvalue	release];
	
}

#pragma mark -- close this view --
- (IBAction)btnClose:(id)sender
{
    //modify by jinxin 2012-02-16 start
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Close" message:@"Closeしてよろしいですか？" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:@"NO", nil];
    [alert show];
    [alert release];
    //modify by jinxin 2012-02-16 end
	
}


/*
//合并房间
- (IBAction)btnCombin:(id)sender
{
	NSString	*uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	NSString	*dateTime=[NSString stringWithFormat:@"%@ %@",dateStr,timeField.text];
	NSString	*toCombineHouse= houseField.text;
	
	if([toCombineHouse isEqualToString:@""])
		return;
	
	NSString	*replayKeys = [NSString stringWithFormat:@"%@;%@;%@;%@;%@;%@",uid,self.shopId,dateTime,toCombineHouse,isDayOrNight,oldHouseCD];

	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"SetRoomBySingleRoom"]]];
	[request setPostValue:replayKeys forKey:@"Keys"];
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	NSString *str = [request responseString];
	str = [common formateXmlString:str];
	
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: str options: 0 error: nil] autorelease];
	CXMLElement *theDoc = [doc rootElement];
	if ([[theDoc stringValue] isEqualToString:@"true"]) 
	{
		[common showSuccessAlert:@"Sucess!"];
	}
	//	self.toMergeHouse =  houseField.text;
	[delegate orderViewControllerDidClose:self];
}
*/


#pragma mark --追加ボタン-ー pop confirm view
- (IBAction)btnConfirm:(id)sender
{
	if (![common	requestDidError]) 
	{
		return;			
	}
	
	OrderConfirmViewController *control = [[OrderConfirmViewController alloc] initWithNibName:@"OrderConfirmViewController" bundle:nil];
	control.delegate = self;
	control.shopId = shopId;
	
	control.records = self.mrecords;
	[self presentModalViewController:control animated:YES];
	[control release];
	
}

//close orderConfirm view
- (void)OrderConfirmViewControllerDidClose:(OrderConfirmViewController *)controller
{
	self.mrecords = controller.records;
	[self dismissModalViewControllerAnimated:YES];
	[_tableView reloadData];
}

//liukeyu 20121008 add  start 

#pragma mark --追加ボタン-ー 客户检索 view
- (IBAction)btnSearchCustomer:(id)sender
{
	if (![common requestDidError]) 
	{
		return;			
	}
	
    if(self.searchCustomerController == nil){
        SearchCustomerController *controller = [[SearchCustomerController alloc] initWithNibName:@"SearchCustomerController" bundle:nil];
        controller.delegate = [self retain];
        self.searchCustomerController = controller;
       
        [controller release];
    }
    
	[self presentModalViewController:self.searchCustomerController animated:YES];
    NSString *data =@"";
    //检索关键字 电话号码
    if ([self.buttonTel.titleLabel.text length]!=0) {
        data=self.buttonTel.titleLabel.text;
    }
    //检索关键字 姓名
    if ([self._orderMenuName.text length]!=0) {
        if([data length]!=0){
           data=[data stringByAppendingString:@" "];
        }
        data=[data stringByAppendingString:self._orderMenuName.text];
    }
    //检索关键字 公司名称
    if ([self.companyName.text length]!=0) {
        if([data length]!=0){
          data=[data stringByAppendingString:@" "];
        }
       data=[data stringByAppendingString:self.companyName.text];
    }
    self.searchCustomerController.textFieldKey.text=data;
   if([data length]>0)
    [self.searchCustomerController searchCommon];
   
       }

//close orderConfirm view
- (void)SearchCustomerControllerDidClose:(SearchCustomerController *)controller
{
	//mrecords = controller.records;
    
    if(controller.customerInfo != nil){
        //self.myCusCD = [controller.customerInfo objectForKey:@"customerCD"];
        [self.buttonTel setTitle:[controller.customerInfo objectForKey:@"phone"] forState:UIControlStateNormal];
        self._orderMenuName.text = [controller.customerInfo objectForKey:@"customerName"];
        self.companyName.text = [controller.customerInfo objectForKey:@"companyName"];
        self._orderMenuSelect.text=@"";
    }
    
	[self dismissModalViewControllerAnimated:YES];
	//[_tableView reloadData];
}

//liukeyu 20121008 add  start 


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return self.mrecords.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//用来标识窗格为一个普通窗格
	static NSString *MyIdentifierOrderMenu = @"OrderMenuCellIdentifier";
	
	OrderConfirmCell *cell = (OrderConfirmCell *)[tableView dequeueReusableCellWithIdentifier:MyIdentifierOrderMenu];
	if(cell == nil)
	{
		NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"OrderConfirmCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	cell.delegate = self;
	
	NSInteger rowIndex = [indexPath indexAtPosition: 1];
//	cell.tag      = rowIndex;
	cell.number	  = rowIndex;
	
	NSString *strName =		 [[self.mrecords objectAtIndex:indexPath.row] valueForKey:@"_foodName"];
	NSString *strPrice=		 [[self.mrecords objectAtIndex:indexPath.row] valueForKey:@"_foodPrice"];  
	NSString *strCount=		 [[self.mrecords objectAtIndex:indexPath.row] valueForKey:@"_foodCount"];
	
	[[cell _foodName] setText:strName];
	[[cell _foodPrice] setText:strPrice];
	[[cell _foodCount] setTitle:strCount forState:UIControlStateNormal];
	
//	[[cell _foodPlus] setTag:rowIndex];
//	[[cell _foodMinus] setTag:rowIndex];
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
		[self.mrecords removeObjectAtIndex:indexPath.row];
		
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
	[[self.mrecords objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
	
	
	//update records
//[[mrecords objectAtIndex:cell.tag] setObject:foodCount forKey:@"_foodCount"];
	
	
	
//	NSMutableDictionary *tmpDic = [[NSMutableDictionary alloc] init];
//	tmpDic = [[mrecords objectAtIndex:number] copy];
//	
//	[tmpDic setObject:foodCount forKey:@"_foodCount"];
//	[mrecords replaceObjectAtIndex:number withObject:tmpDic];
	
}

//数量をMinus
- (void)orderConfirmCellDidMinus:(OrderConfirmCell *)cell
{
	NSUInteger  fCount   = [[cell _foodCount].titleLabel.text  intValue] - 1;
	NSString   *foodCount= [NSString stringWithFormat:@"%d",fCount]; 
	
	//update cell
	[[cell _foodCount] setTitle:foodCount forState:UIControlStateNormal];		
	
	int number = cell.number;
	[[self.mrecords objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
	
	//update records
//	[[mrecords objectAtIndex:cell.tag] setObject:foodCount forKey:@"_foodCount"];
}


- (void)orderConfirmCellDidInput:(OrderConfirmCell *)cell
{
	NSUInteger  fCount   = [[cell _foodCount].titleLabel.text  intValue];
	NSString   *foodCount= [NSString stringWithFormat:@"%d",fCount]; 
	
	int number = cell.number;
	[[self.mrecords objectAtIndex:number] setObject:foodCount forKey:@"_foodCount"];
}


#pragma mark --予約--
//予約する
- (IBAction)btnOrder:(id)sender
{
	if (![common	requestDidError]) 
	{
		return;			
	}
	
	NSString	*toCombineHouse= houseField.text;
	if(![toCombineHouse isEqualToString:@""])		//ガ別部屋
	{
		roomName=toCombineHouse;
	}
    NSString *oTel = buttonTel.titleLabel.text == nil ? @"" : buttonTel.titleLabel.text;
    NSString *orderName =  _orderMenuName.text == nil ? @"" : _orderMenuName.text;
    NSString *oCompanyName = self.companyName.text== nil ? @"" : self.companyName.text;
	NSString *odaihyou= daihyou.text ==nil ? @"":daihyou.text;
	NSString *oCustomCount = [_orderCustomerCount titleLabel].text ==nil ? @"" : [_orderCustomerCount titleLabel].text;
	if([self.cusCD length]==0){
		self.cusCD=@"0";
    }
	if([oCustomCount	isEqualToString:@""])
	{
		[common	showErrorAlert:@"人数を入力してください。"];
		return;
	}
	NSInteger	numCheck	=	[oCustomCount	intValue];
	if ([oCustomCount	rangeOfString:@"-"].location!=NSNotFound	||	numCheck	<=0) 
	{
		[common	showErrorAlert:@"人数が正しく入力してください。"];
		return;
	}
	NSString *visiteDate = [NSString stringWithFormat:@"%@ %@",dateStr,timeField.text];
	NSString	*strdate	=	[self.delegate	dateString];
//	NSArray *ary_roomName = [roomName componentsSeparatedByString:@""]
	strdate = [strdate stringByReplacingOccurrencesOfString:@"年" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"月" withString:@"/"];
	strdate =[strdate stringByReplacingOccurrencesOfString:@"日" withString:@""];
	
	if (![dateStr	isEqualToString:strdate]) 
	{
			roomValueArr	=	[[NSMutableArray	alloc]	init];
			[self	splitRoomCdOrder:roomCD];
			for (int	i=0;i<roomValueArr.count ;i++ ) 
			{
				NSString	*selectCD = [roomValueArr objectAtIndex:i];
				if ([self	CheckShopLockDate:selectCD	checkDate:dateStr]) 
				{
					[common	showSuccessAlert:[NSString	stringWithFormat:@"%@のNo%@部屋ロックの状態入れない！",dateStr,selectCD]]	;
					[roomValueArr	release];
					return;
				}
			}
			[roomValueArr	release];
	}
	NSInteger menuCount  = [self countMenu];
	
	NSString *houseCellColorStr = [NSString stringWithFormat:@"%f,%f,%f,%f",1.0,redSlider.value,greenSlider.value,blueSlider.value];
	NSString *orderStr1 = [NSString stringWithFormat:@"[%@;%@;%@;%@;%@;%@;%@;",[[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"],shopId,roomName,houseCellColorStr,oTel,visiteDate,dateStr];
	NSString *orderStr2 = [NSString stringWithFormat:@"%@;%@;%@;%@;%d;%@;",oCompanyName,orderName,odaihyou, oCustomCount, menuCount,memo.text];
	 
//	id aa = _orderCustomerCount.titleLabel.text;
	NSString *orderStr = [NSString stringWithString:orderStr1];
	orderStr = [orderStr stringByAppendingString:orderStr2];
	
	
	//クーポン;タイプ;orderId;昼夜
	NSString *orderkupon = kuponField.text;
	NSString *ordertype  = type.text;
	if(self.selectCommentId==nil)
		selectCommentId=@"";
	
	if ([self.shopId	isEqualToString:@""])
		self.isUpdateOrInsert	=	@"0";
	
	orderStr = [orderStr stringByAppendingFormat:@"%@;%@;%@;%@;%@;%@",orderkupon,ordertype,isDayOrNight,orderId,self.cusCD,self.selectCommentId];
	
	
	orderStr = [self getItemrecords:orderStr];
	if ([orderStr	isEqualToString:@"Error"]) {
		return;
	}
	
	[self tyumonn:orderStr];
	
}

-	(void)splitRoomCdOrder:(NSString	*)houseCD
{
	
	if ([houseCD	rangeOfString:@"_"].location	!=	NSNotFound) 
	{
		NSString	*	roomID	=	[houseCD	substringToIndex:[houseCD	rangeOfString:@"_"].location];
		NSString	*	houseID	=	[houseCD	substringFromIndex:[houseCD	rangeOfString:@"_"].location+1];
		[roomValueArr	addObject:roomID];
		[self	splitRoomCdOrder:houseID];
	}
	else 
	{
		[roomValueArr	addObject:houseCD];
		return;
	}
	
}

- (BOOL)CheckShopLockDate:(NSString *)houseCD	checkDate:(NSString	*)strDate
{
	NSString *LoginId = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
	
	NSString *strPost = [NSString stringWithFormat:@"%@;%@;%@;%@",LoginId,shopId,strDate,isDayOrNight];
	
	
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


//料理の数量を計算する
- (NSInteger)countMenu
{
	NSInteger count = 0;
	for (int i=0; i<self.mrecords.count; i++) 
	{
		count += [[[self.mrecords objectAtIndex:i] objectForKey:@"_foodCount"] intValue];
	}
	return count;
}




//レコードの詳細情報を取ります
- (NSString *)getItemrecords:(NSString *)orderString
{
	NSString *menuRecord = @"{";
	for (int i =0; i<self.mrecords.count; i++) 
	{
		menuRecord =[menuRecord stringByAppendingString:@"<menu>"] ;
		NSString *mCD = [[self.mrecords objectAtIndex:i] objectForKey:@"_foodCD"];
		NSString *mName = [[self.mrecords objectAtIndex:i] objectForKey:@"_foodName"];
		
		NSString *mPrice = [[[self.mrecords objectAtIndex:i] objectForKey:@"_foodPrice"] stringByReplacingOccurrencesOfString:@"円" withString:@""];
		NSString *mCount = [[self.mrecords objectAtIndex:i] objectForKey:@"_foodCount"];
		
		NSInteger	numCheck	=	[mCount	intValue];
		if (numCheck	<=	0) {
			[common	showErrorAlert:@"料理数量が正しく入力してください。"];
			return	@"Error";
		}
		
		menuRecord =[menuRecord stringByAppendingFormat:@"%@;%@;%@;%@</menu>",mCD,mName,mPrice,mCount];
	}
	orderString =[orderString stringByAppendingFormat:@"%@}]",menuRecord];
	
	return orderString;
}


//注文するのsoapを発信する
- (void)tyumonn:(NSString *)recordString
{
	if ([isUpdateOrInsert isEqualToString:@"0"]) //新規
	{
//		if(![delegate isUnLockSuccess:self.roomCD LockState:@"0"])
//		{
//			[common showErrorAlert:@"fangjian"];
//			return;
//		}
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"InsertOrderData"]]];
		[request setPostValue:recordString forKey:@"OrderDate"];
	}
	else	//更新
	{
		request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"UpdateOrderData"]]];
		[request setPostValue:recordString forKey:@"OrderDate"];
	}

	
	
	[request setRequestMethod:@"POST"];
	[request startSynchronous];
	
	//@"[003;62;６号室;03-0062-0001;2011/2/28 12:30;2011/2/18;小田運送株式会社;三神　良子;三神　良子1;18;36;南向こうの個室;{<menu>1234567;雪会席;8,000;18</menu><menu>1234567;雪会席;8,000;18</menu>}]"
	NSString *str = [request responseString];
	str=[common formateXmlString:str];
	str = [self parseXmlResult:str];
	
	if ([str isEqualToString:@"true"]) 
	{
		//[common showSuccessAlert:str];
		
//		self.toMergeHouse =  houseField.text;
		[self.delegate orderViewControllerDidClose:self];
	}
	else
	{
		[common showErrorAlert:str];
	}
	
}


- (NSString *)parseXmlResult: (NSString*)xmlString 
{
	CXMLDocument *doc = [[[CXMLDocument alloc] initWithXMLString: xmlString options: 0 error: nil] autorelease];
	CXMLElement *theElement = [doc rootElement];
	NSString *strE = [[theElement childAtIndex:0] stringValue];
	
	return strE;
}



- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	// the user clicked one of the OK/Cancel buttons
	if ([actionSheet.title isEqualToString:@"削除!"] && actionSheet.tag==100)
    {
		if (buttonIndex==0) 
		{
			if (![common	requestDidError]) 
			{
				return;			
			}
			
			//NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
			request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"DeleteOrderData"]]];
			
			if(![ visitTime length]==0 && [isUpdateOrInsert isEqualToString:@"1"])
			{
				//		NSString *visitDateTime = [NSString stringWithFormat:@"%@ %@",dateStr,visitTime];	
				//		NSString *delString     = [NSString stringWithFormat:@"%@;%@;%@;%@;%@",uid,shopId,visitDateTime,roomName,isDayOrNight];
				
				
				[request setPostValue:orderId forKey:@"Keys"];
				[request startSynchronous];
				NSString *str = [request responseString];
				str=[common formateXmlString:str];
				
				NSString *strResult = [self parseXmlResult:str];
				if ([strResult isEqualToString:@"true"]) 
				{
					[common showSuccessAlert:@"削除しました！"];
				}
				else 
				{
					[common showErrorAlert:@"削除失敗しました！"];
				}
				
			}
			[delegate orderViewControllerDidClose:self];
		}
    //modify by jinxin 2012-02-16 start
	}else if([actionSheet.title isEqualToString:@"Close"]){
        if(buttonIndex == 0){
            if (![common	requestDidError]) 
            {
                return;			
            }
            [delegate orderViewControllerDidClose:self];
        }
    //modify by jinxin 2012-02-16 start
    }
	else 
	{
		if (buttonIndex == 0)
		{
			NSLog(@"注文しました！");
			[delegate orderViewControllerDidClose:self];
		}
	}
}



- (NSString *)stringForColor:(UIColor *)color 
{
    CGColorRef c = color.CGColor;
    const CGFloat *components = CGColorGetComponents(c);
	
    size_t numberOfComponents = CGColorGetNumberOfComponents(c);
    NSMutableString *s = [[[NSMutableString alloc] init] autorelease];
    [s appendString:@"{"];
	
    for (size_t i = 0; i < numberOfComponents; ++i) 
	{
        if (i > 0) 
		{
            [s appendString:@","];
        }
        [s appendString:[NSString stringWithFormat:@"%f", components[i]]];
    }
    [s appendString:@"}"];
    return s;
}


- (void)SetRed:(float)_redValue green:(float)_greenValue blue:(float)_blueValue
{
	redValue = _redValue;
	greenValue = _greenValue;
	blueValue = _blueValue;
	
}




#pragma mark ----カレンダーの日付を変更---
- (IBAction)calButton:sender
{
//	NSLog(@"--------------------calendar----------------");
	
	sscal = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 1024, 748)] autorelease];
	[sscal addTarget:self action:@selector(DismissCalendar:) forControlEvents:UIControlEventTouchUpInside];
	sscal.backgroundColor = [UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.7];
	
	UIView *frameView = [[UIView alloc] initWithFrame:CGRectMake(200, 768, 300, 300)];
	[frameView setBackgroundColor:[UIColor grayColor]];
	[self.view addSubview:sscal];
	[sscal addSubview:frameView];
	
	UILabel *titleLabel= [[UILabel alloc] initWithFrame:CGRectMake(50, 768, 200, 40)];
	[titleLabel setText:@"日付を選択ください！"];
	[titleLabel setTextAlignment:UITextAlignmentCenter];
	
	theDatePicker = [[[UIDatePicker alloc] initWithFrame:CGRectMake( 20, 768, 250, 150 )] autorelease];
	theDatePicker.datePickerMode = UIDatePickerModeDate;
	NSDateFormatter *formatterCal = [[[NSDateFormatter alloc] init]	autorelease];
 
	formatterCal.dateFormat = @"yyyy/M/d"; 
	
	NSDate *timestampCal = [formatterCal dateFromString:dateStr];
	[theDatePicker	setDate:timestampCal];
	[UIView beginAnimations:nil context:nil];
	
	
	UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[btn setFrame:CGRectMake(70, 768, 100, 30)];
	[btn setTitle:@"O K" forState:UIControlStateNormal];
	[btn addTarget:self action:@selector(changeCalendar:) forControlEvents:UIControlEventTouchUpInside];
	
	
	[frameView addSubview:titleLabel];
	[frameView addSubview:theDatePicker];
	[frameView addSubview:btn];
	
	
	[frameView setFrame:CGRectMake(200, 80, 300, 300)];
	theDatePicker.frame = CGRectMake(20, 80, 250, 150);
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
- (void)changeCalendar:sender
{	
	NSDateFormatter *formatterCal = [[NSDateFormatter alloc] init]; 
	//formatterCal.dateFormat = @"yyyy/MM/dd"; 
	formatterCal.dateFormat = @"yyyy/M/d"; 
	
	NSString *timestampCal = [formatterCal stringFromDate:theDatePicker.date]; 
	[_visitDateText setTitle:timestampCal forState:UIControlStateNormal];
	
	formatterCal.dateFormat = @"EEEE";
	
	NSString *weekTampCal = [formatterCal stringFromDate:theDatePicker.date]; 
	[weekDateLabel setText:weekTampCal];

	
	[formatterCal	release];
	self.dateStr = timestampCal;
	
	[self DismissCalendar:sscal];
}

-(void)DismissCalendar:(id)p
{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:.3];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStopCal:finished:context:)];
	
	sscal.frame = CGRectMake( 0, 768, 1024, 748 );
	[UIView commitAnimations];
}

- (void)animationDidStopCal:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context 
{
	[ sscal removeFromSuperview ];
}

/* wangjianxu 
#pragma mark --連絡先--
- (void)priceInputDidClose:(PriceInput *)prieInput
{
    
	if([prieInput.titleLabel.text	isEqualToString:@""])
		return;
	
	[self	searchInfo];
	
	if(peopleArr.count>1)
	{
		[yoyakuField setText:[[peopleArr objectAtIndex:1]objectForKey:@"CustomerName"]];
		self.cusCD= [[peopleArr objectAtIndex:1]objectForKey:@"CustomerCD"];
		[self peoPelCDUpInfo:cusCD];
	}
	else 
	{
		
		_orderMenuName.text=@"";
		companyName.text=@"";
		self.cusCD=@"0";		
	}


}
*/

- (BOOL)priceInputClick:(PriceInput	*)prieInputh
{
	return	NO;
}



#pragma mark --レコドを削除する--
- (IBAction)btnDelete:(id)sender
{
	UIAlertView	*alert=[[UIAlertView alloc]
                        initWithTitle:@"削除!"
                        message:@"本当に削除しますか?"
                        delegate:self
                        cancelButtonTitle:@"削除"
                        otherButtonTitles:@"キャンセル",nil];
    
	alert.tag=100;
	[alert show];
	[alert release];
	
// liukeyu zhushi start 20110713
//	if (![common	requestDidError]) 
//	{
//		return;			
//	}
//	
//	//NSString *uid = [[NSUserDefaults standardUserDefaults] objectForKey:@"LoginId"];
//	request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[[common serverSoapIp] stringByAppendingString:@"DeleteOrderData"]]];
//
//	if(![ visitTime length]==0 && [isUpdateOrInsert isEqualToString:@"1"])
//	{
////		NSString *visitDateTime = [NSString stringWithFormat:@"%@ %@",dateStr,visitTime];	
////		NSString *delString     = [NSString stringWithFormat:@"%@;%@;%@;%@;%@",uid,shopId,visitDateTime,roomName,isDayOrNight];
//		
//		
//		[request setPostValue:orderId forKey:@"Keys"];
//		[request startSynchronous];
//		NSString *str = [request responseString];
//		str=[common formateXmlString:str];
//		
//		NSString *strResult = [self parseXmlResult:str];
//		if ([strResult isEqualToString:@"true"]) 
//		{
//			[common showSuccessAlert:@"削除しました！"];
//		}
//		else 
//		{
//			[common showErrorAlert:@"削除失敗しました！"];
//		}
//	
//	}
//	[delegate orderViewControllerDidClose:self];
// liukeyu zhushi end 20110713
}


#pragma mark --コメント02---
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	if(textView==memo)
	{
		//yoyakuField.hidden=YES;
		selectComment.hidden=YES;
		
		[UIView beginAnimations:@"memo" context:memo];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:.7];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		
		CGRect frame = textView.frame;
		frame.origin.y = 150;    
		
		frame.size.height=	200;	 
		[textView setFrame:frame];
		[UIView commitAnimations];		
	}
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if(textView == memo)
	{
		[UIView beginAnimations:@"memo" context:memo];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:.7];
		
		CGRect frame = textView.frame;
		frame.origin.y = 327;    
		
		frame.size.height=	75;	 
		[textView setFrame:frame];
		[UIView commitAnimations];
		
		[self performSelector:@selector(backState) withObject:nil afterDelay:.7];
	}
}


-(void)backState
{
	//yoyakuField.hidden=NO;
	selectComment.hidden=NO;
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
	[labelRoom	release];
	[cusCD	release];
	[selectCommentId	release];
	[selectComment release];
	[selectCommentPickerData release];
	
	[oldHouseCD release];
	//S[yoyakuField release];
	
	[isDayOrNight release];
	[orderId release];
	[sliderView release];
	[redSlider release];
	[greenSlider release];
	[blueSlider release];
	
	[isUpdateOrInsert release];
	[visitTime release];
	[_visitDateText release];

	[weekDateLabel	release];
	
	[memo release];
	[daihyou release];
	[companyName release];
	[dateStr release];
	[roomName release];
	[roomCD	release];
	[shopId release];
	[toMergeHouse release];
	[houseField release];
	[housePickerData release];
	
	[buttonCheckBox release];
	[kuponField release];
	[kuponPickerData release];
	
	[typePickerData release];
	[type release];
	[timeField release];
	[mrecords release];
	[_tableView release];
	

	[_orderMenuName release];
    [buttonTel release];
	[_orderCustomerCount release];
    
    [searchCustomerController release];
	[super dealloc];
	
}


@end