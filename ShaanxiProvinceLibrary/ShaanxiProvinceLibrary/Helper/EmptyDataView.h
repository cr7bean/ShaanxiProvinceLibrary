//
//  EmptyDataView.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/3.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EmptyDataType) {
    EmptyDataTypeNetworkInterruption,
    EmptyDataTypeDoubanServerBusy,
    EmptyDataTypeLibrayServerBusy,
};

@interface EmptyDataView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *mainLabel;
@property (nonatomic, strong) UILabel *subLabel;
@property (nonatomic, strong) UIButton *refreshButton;

- (instancetype) initOnView: (UIView *) view;
- (void) configurateEmptyDataView;

@end
