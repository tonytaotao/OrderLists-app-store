//
//  OrderMenuViewController.h
//  MasterDetail
//
//  Created by fly on 10/11/04.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderConfirmViewController.h"
#import "SearchCustomerController.h"

@protocol OrderMenuViewControllerDelegate;
//@protocol SearchCustomerControllerDelegate;

@interface OrderMenuViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,
OrderConfirmViewControllerDelegate,OrderConfirmCellDelegate,UIPickerViewDataSource,UIPickerViewDelegate,SearchCustomerControllerDelegate>
{
	id<OrderMenuViewControllerDelegate> delegate;
	SearchCustomerController * searchCustomerController;
    IBOutlet UITextField    *_orderMenuSelect;
	IBOutlet UITextField    *_orderMenuName;
	IBOutlet UIButton       *_orderCustomerCount;
	IBOutlet UITextField    *timeField;
	IBOutlet UIButton       *buttonTel;
	IBOutlet UITableView    *_tableView;
	
	
	NSMutableArray        *mrecords;
	UIDatePicker          *timePicker;
	
	
	IBOutlet UITextField  *type;
	UIPickerView		  *typePicker;
	NSArray				  *typePickerData;
	
	IBOutlet UITextField  *kuponField;
	UIPickerView		  *kuponPicker;
	NSMutableArray		  *kuponPickerData;
	
	IBOutlet UITextField  *houseField;					//部屋picker
	UIPickerView		  *housePicker;
	NSArray				  *housePickerData;
	
	
	NSString			  *toMergeHouse;
	NSString			  *shopId;
	NSString			  *roomName;
	NSString			  *roomCD;
	NSString			  *dateStr;
	NSString			  *visitTime;	
	
	IBOutlet UITextField  *companyName;
	IBOutlet UITextField  *daihyou;
	IBOutlet UITextView	  *memo;
	IBOutlet UIButton	  *_visitDateText;
	IBOutlet	UILabel		*weekDateLabel;	
	UIDatePicker		  *theDatePicker;
	
	NSString			  *isUpdateOrInsert;

	
	
	
	IBOutlet		UIView		  *sliderView;
	IBOutlet		UISlider	  *redSlider;
	IBOutlet		UISlider	  *greenSlider;
	IBOutlet		UISlider	  *blueSlider;
	
	float					redValue;
	float					greenValue;
	float					blueValue;

	NSString				*orderId;
	NSString				*isDayOrNight;
	
	//IBOutlet UITextField	*yoyakuField;
	UIPickerView			*yoyakuPicker;
	
	NSString				*oldHouseCD;
	
	
	IBOutlet	UITextField *selectComment;				//選択コメントpicker
	UIPickerView			*selectCommentPicker;
	NSMutableArray			*selectCommentPickerData;
	NSString				*selectCommentId;
	NSString				*cusCD;
	
	IBOutlet		UILabel	*labelRoom;
}


@property(nonatomic,assign)id<OrderMenuViewControllerDelegate> delegate;

@property(nonatomic,retain)SearchCustomerController *searchCustomerController;
@property(nonatomic,retain) UITextField     *_orderMenuSelect;
@property(nonatomic,retain) UITextField		*_orderMenuName;
@property(nonatomic,retain) UIButton		*buttonTel;
@property(nonatomic,retain) UIButton		*_orderCustomerCount;

@property(nonatomic,retain) UITableView     *_tableView;
@property(nonatomic,retain) NSMutableArray  *mrecords;

@property(nonatomic,retain) UITextField		*timeField;
@property(nonatomic,retain) UITextField		*type;
@property(nonatomic,retain) NSArray			*typePickerData;


@property(nonatomic,retain) UITextField		*kuponField;
@property(nonatomic,retain) NSArray			*kuponPickerData;

@property(nonatomic,retain) IBOutlet UIButton *buttonCheckBox;

@property(nonatomic,retain) IBOutlet UITextField *houseField;
@property(nonatomic,retain) NSArray		         *housePickerData;

@property(nonatomic,retain) NSString			*toMergeHouse;
@property(nonatomic,retain)	NSString			*shopId;
@property(nonatomic,retain) NSString			*roomName;
@property(nonatomic,retain)	NSString			*roomCD;

@property(nonatomic,retain) NSString			*dateStr;
@property(nonatomic,retain) NSString			*visitTime;

@property(nonatomic,retain) UITextField			*companyName;
@property(nonatomic,retain) UITextField			*daihyou;
@property(nonatomic,retain) UITextView			*memo;
@property(nonatomic,retain) UIButton			*_visitDateText;
@property(nonatomic,retain) UILabel             *weekDateLabel;
@property(nonatomic,retain) NSString			*isUpdateOrInsert;

@property(nonatomic,retain) UIView				*sliderView;
@property(nonatomic,retain) UISlider			*redSlider;
@property(nonatomic,retain)	UISlider			*greenSlider;
@property(nonatomic,retain) UISlider			*blueSlider;

@property(nonatomic,readwrite) float			redValue;
@property(nonatomic,readwrite) float			greenValue;
@property(nonatomic,readwrite) float			blueValue;

@property(nonatomic,retain) NSString			*orderId;
@property(nonatomic,retain) NSString			*isDayOrNight;

//@property(nonatomic,retain) UITextField			*yoyakuField;
@property(nonatomic,retain) NSString			*oldHouseCD;

@property(nonatomic,retain) UITextField			*selectComment;
@property(nonatomic,retain) NSMutableArray		*selectCommentPickerData;
@property(nonatomic,retain) NSString			*selectCommentId;

@property(nonatomic,retain)NSString				*cusCD;

@property(nonatomic,retain)UILabel				*labelRoom;

- (NSInteger)countMenu;
- (NSString *)getItemrecords:(NSString *)orderString;
- (void)tyumonn:(NSString *)recordString;
- (NSString *)parseXmlResult: (NSString*)xmlString;
- (void)SetRed:(float)_redValue green:(float)_greenValue blue:(float)_blueValue;

- (IBAction)checkboxAction;

//close self the view
- (IBAction)btnClose:(id)sender;
//- (IBAction)btnCombin:(id)sender;

//pop confirm view
- (IBAction)btnConfirm:(id)sender;

//pop confirm view
- (IBAction)btnSearchCustomer:(id)sender;

//予約する
- (IBAction)btnOrder:(id)sender;

//日付
- (IBAction)calButton:sender;

//削除
- (IBAction)btnDelete:(id)sender;

-	(void)splitRoomCdOrder:(NSString	*)houseCD;

- (BOOL)CheckShopLockDate:(NSString *)houseCD	checkDate:(NSString	*)strDate;

- (void)getShopType;
@end






@protocol OrderMenuViewControllerDelegate
- (void)orderViewControllerDidClose:(OrderMenuViewController *)controller;

//- (BOOL)isUnLockSuccess:(NSString *)houseCD LockState:(NSString	*)lockState;
@end
