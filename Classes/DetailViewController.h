//
//  DetailViewController.h
//  MasterDetail
//
//  Created by Andreas Katzian on 15.05.10.
//  Copyright 2010 Blackwhale GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NWPickerField;

@interface DetailViewController : UIViewController 
{
	IBOutlet NWPickerField  *selectPerson;				//選択の人
	IBOutlet UIButton       *textFieldTel;				//検索用の携帯電話番号
	
	
	IBOutlet UITextField    *yoyaku;					//予約名
	IBOutlet UITextField	*sex;						//性別
	IBOutlet UITextField	*companyName;				//会社名
	IBOutlet  UIButton		*mobileTel;					//携帯Tel
	IBOutlet UITextField	*companyFax;				//会社Fax
	IBOutlet UITextField	*_email;					//メール
	
	
	IBOutlet UITextView		*memTextView;
	IBOutlet UITextView		*ngTextView;
	
	
	IBOutlet NWPickerField	*arerugi_First;				//アレルギー First
	IBOutlet NWPickerField	*arerugi_Second;			//アレルギー Second
	IBOutlet NWPickerField	*arerugi_Third;				//アレルギー Third
	IBOutlet NWPickerField	*arerugi_Four;				//アレルギー Four
	
	IBOutlet NWPickerField  *vege_First;				//ベジタリアに First
	IBOutlet NWPickerField	*vege_Second;				//ベジタリアに Second
	IBOutlet NWPickerField	*vege_Third;				//ベジタリアに Third;
	IBOutlet NWPickerField	*vege_Four;					//ベジタリアに Four
	
	NSMutableArray *arerugiArr;
	NSMutableArray *vegeArr;
	
}

@property(nonatomic,retain) NWPickerField	*selectPerson;

@property(nonatomic,retain) UITextField		*yoyaku;
@property(nonatomic,retain) UITextField		*sex;
@property(nonatomic,retain) UITextField		*companyName;
@property(nonatomic,retain) UIButton		*mobileTel;
@property(nonatomic,retain) UITextField		*companyFax;
@property(nonatomic,retain) UITextField		*_email;



@property(nonatomic,retain) UITextView		*memTextView;
@property(nonatomic,retain) UITextView		*ngTextView;

@property(nonatomic,retain) NWPickerField	*arerugi_First;
@property(nonatomic,retain) NWPickerField	*arerugi_Second;
@property(nonatomic,retain) NWPickerField	*arerugi_Third;
@property(nonatomic,retain) NWPickerField	*arerugi_Four;

@property(nonatomic,retain) NWPickerField   *vege_First;
@property(nonatomic,retain) NWPickerField	*vege_Second;
@property(nonatomic,retain) NWPickerField	*vege_Third;
@property(nonatomic,retain) NWPickerField	*vege_Four;

@property(nonatomic,retain) NSMutableArray  *arerugiArr;
@property(nonatomic,retain) NSMutableArray  *vegeArr;

- (IBAction)searchInfo:sender;
- (IBAction)updateCustomInfo:sender;

- (IBAction)copySearchInfo:sender;

+	(NSString*)	getDetailUserCdName;
+	(void)	releaseDetailInfo;

-	(void)	showHisDetailCopyInfo;
-	(void)	getCustomerNameListD:(NSString	*)tel;
- (void)releaseRefreshView;
@end
