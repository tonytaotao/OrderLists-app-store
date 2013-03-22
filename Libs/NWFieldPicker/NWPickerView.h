//
//  CNPickerView.h
//  NWPickerField
//


#import <Foundation/Foundation.h>

@class NWPickerField;

@interface NWPickerView : UIPickerView {
@private
	CGRect hiddenFrame;
	CGRect visibleFrame;
	NWPickerField* field;
}

@property(nonatomic, assign) CGRect hiddenFrame;
@property(nonatomic, assign) CGRect visibleFrame;
@property(nonatomic, assign) NWPickerField* field;

-(void) toggle;

@end
