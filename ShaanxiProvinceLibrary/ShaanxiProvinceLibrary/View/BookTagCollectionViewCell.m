//
//  BookTagCollectionViewCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookTagCollectionViewCell.h"

static const CGFloat kFontSize = 16;

@implementation BookTagCollectionViewCell
{
//    UILabel *_label;
}

- (instancetype) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame: frame];
    if (self) {
        _label = [UILabel new];
//        _label.textColor = [UIColor colorWithRed:0.471 green:0.506 blue:0.529 alpha:1.0];
        
        _label.font = [UIFont systemFontOfSize: kFontSize];
        [self.contentView addSubview: _label];
    }
    return self;
}

- (void) setBookTagName:(NSString *)bookTagName
{
    _label.text = bookTagName;
    _label.frame = self.bounds;
    self.contentView.backgroundColor = [UIColor colorWithRed:1.000 green:1.000 blue:1.000 alpha:1.0];
}

//- (void) setSelected:(BOOL)selected
//{
//    [super setSelected: selected];
//    if (selected) {
//        _label.backgroundColor = [UIColor blueColor];
//        _label.textColor = [UIColor whiteColor];
//    }
//}


@end
