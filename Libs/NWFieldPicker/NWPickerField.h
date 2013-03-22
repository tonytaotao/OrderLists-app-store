//
//  CNPickerField.h
//  NWFieldPicker


#import <Foundation/Foundation.h>

extern NSString* UIPickerViewBoundsUserInfoKey;

extern NSString* UIPickerViewWillShownNotification;
extern NSString* UIPickerViewDidShowNotification;
extern NSString* UIPickerViewWillHideNotification;
extern NSString* UIPickerViewDidHideNotification;

@class NWPickerView;
@protocol NWPickerFieldDelegate;


@interface NWPickerField : UITextField<UIPickerViewDataSource, UIPickerViewDelegate> 
{
@private
	NWPickerView* pickerView;
	NSMutableArray* componentStrings;
	NSString* formatString;
	UIImageView* indicator;
	
	id<NWPickerFieldDelegate> delegate;
	UIButton		*btnpvClose;

}

@property(nonatomic,assign) IBOutlet id<NWPickerFieldDelegate> delegate;
@property(nonatomic, copy) NSString* formatString;

-(void) selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
-(NSInteger) selectedRowInComponent:(NSInteger)component;
- (void)reloadAllComponents;

@end

@protocol NWPickerFieldDelegate
@required
-(NSInteger) numberOfComponentsInPickerField:(NWPickerField*)pickerField;
-(NSInteger) pickerField:(NWPickerField*)pickerField numberOfRowsInComponent:(NSInteger)component;
-(NSString*) pickerField:(NWPickerField *)pickerField titleForRow:(NSInteger)row forComponent:(NSInteger)component;
-(void)pickerField:(NWPickerField *)pickerField didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
@end
