
#import <UIKit/UIKit.h>
#import "HistoryDetailCell.h"

@class NWPickerField;

@interface HistoryDetailViewController : UIViewController <UITableViewDelegate,UITableViewDataSource,HistoryDetailCellDelegate>  
{
	IBOutlet UIButton       *textFieldTel;
	
	//NSMutableArray          *_hrecords;
	IBOutlet UITableView    *_tableView;
	IBOutlet NWPickerField  *selectPerson;				//選択の人
}
@property(nonatomic,retain) UITableView *_tableView;
@property(nonatomic,retain) NWPickerField	*selectPerson;


+	(NSString*)	getHisDetailUserCdName;
+	(void)	releaseHisDetailInfo;

-	(void)	showDetailCopyInfo;

-	(void)	getCustomerNameList:(NSString	*)tel;
- (void)parseXml: (NSString*)xmlString;
- (IBAction)HistorySearch:(id)sender;
-	(IBAction)	copyHisTelAndName:(id)sender;
@end
