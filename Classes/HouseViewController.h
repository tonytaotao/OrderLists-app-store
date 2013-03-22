//
//  HouseViewController.h
//  MasterDetail
//
//  Created by fly on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderMenuViewController.h"
#import "CustomUISplitViewController.h"
#import "MasterViewController.h"
#import "FreeRoomController.h"
#import "HouseViewCell.h"
#import "CustomerAndOrderController.h"
#import "PriceInput.h"

@class PriceInput;

@interface HouseViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
OrderMenuViewControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate,FreeRoomDelegate,HouseViewCellDelegate,CustomerAndOrderDelegate,PriceInputDelegate>
{
	IBOutlet UITableView *_tableView;
    IBOutlet UITableView *_tableViewDelete;
    
	NSMutableArray       *records;
    NSMutableArray       *recordsDelete;
	
	IBOutlet   UIButton  *dateLabel;
	IBOutlet			UILabel			*weekLabel;
		
	NSString				*dateString;					//xxxx年xx月xx日
	
	IBOutlet   UIButton		*editButton;
	IBOutlet   UIButton		*doneButton;
	
	NSMutableArray			*houseData;
	UIPickerView			*housePicker;
	UIDatePicker			*theDatePicker;
	
	//--
	NSString				*userId;
	NSString				*shopId;
	NSString				*VisitDate;							//xxxx/xx/xx
	
	NSString				*memoStr;
	IBOutlet	UITextView	*memoTextView;
	
	NSString				*hIsDayOrNight;
	
	NSMutableArray			*houseImageSelectedArray;			//選択部屋の画像アレイ
	
	IBOutlet	UIButton				*houseLock;
	IBOutlet	UIButton				*houseUnLock;
	BOOL								isClearMode;
	NSMutableArray						*clearModeChangeHousePeople;
	
	NSIndexPath							*cell_selectIndex; 

}

@property(nonatomic,retain) UITableView *_tableView;
@property(nonatomic,retain) UITableView *_tableViewDelete;

@property(nonatomic,retain) UIButton     *dateLabel;
@property(nonatomic,retain) UILabel     *weekLabel;
@property(nonatomic,retain) NSString     *dateString;

@property(nonatomic,retain) UIButton   *editButton;
@property(nonatomic,retain) UIButton   *doneButton;
 
@property(nonatomic,retain) NSMutableArray	*houseData;

@property(nonatomic,retain) NSString		*userId;
@property(nonatomic,retain)	NSString		*shopId;
@property(nonatomic,retain) NSString		*VisitDate;

@property(nonatomic,retain) NSString		*memoStr;
@property(nonatomic,retain) UITextView		*memoTextView;
@property(nonatomic,retain) NSString		*hIsDayOrNight;
@property(nonatomic,retain) NSMutableArray  *houseImageSelectedArray;

@property(nonatomic,retain) UIButton		*houseLock;
@property(nonatomic,retain) UIButton		*houseUnLock;

@property(nonatomic,retain)	NSIndexPath		*cell_selectIndex;

@property(nonatomic,retain)NSMutableArray *recordsDelete;
	

- (NSString *)parseXmlResult: (NSString*)xmlString ;
- (void) getRoomData;
- (void)parseXml: (NSString*)xmlString ;

- (IBAction)editButton:sender;
- (IBAction)doneButton:sender;
- (IBAction)calButton:sender;

- (IBAction)goToFreeRoom:(id)sender; 

- (IBAction)btnDayMemo:(id)sender;

- (void)GoToCustomerAndOrder:(id)sender;

- (void)drawMsterHouse;
- (void)parseHouseXml:(NSString *)emptyHouseList;
- (void)houseImageSelectedArrayInit;
- (void)parseMasterHouseXml: (NSString *)houseMasterXmlStr;
- (void)parseGroup:(NSMutableArray *)groupArr;
- (BOOL)isLockSuccess:(NSString *)houseCD LockState:(NSString *)lockState;
- (NSString *)parseStrRedColor:(NSString *)commaString;
- (NSString *)parseStrGreenColor:(NSString *)commaString;
- (NSString *)parseStrBlueColor:(NSString *)commaString;
- (void)splitRoomCD:(NSString	*)houseCD;
- (BOOL)checkShopLock:(NSString *)houseCD;
- (BOOL) changeHouseNewNo:(NSString	*)orderId newNo:(NSString*)changeNo;
- (void) SiftData:(NSMutableArray *) recordsArr;
- (void)showDetailData:(HouseViewCell *)cell;


-(UITableViewCell *)GetOrderInfoCell:(NSIndexPath *)indexPath;
-(UITableViewCell *)GetOrderDeleteInfoCell:(NSIndexPath *)indexPath;

@end
