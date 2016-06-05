//
//  BorrowBookCell.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/19.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BorrowBookCell.h"
#import "BorrowBookModel.h"


@interface BorrowBookCell ()

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UILabel *borrowDateLabel;
@property (strong, nonatomic) IBOutlet UILabel *returnDateLabel;

@property (strong, nonatomic) IBOutlet UIButton *renewButton;
@property (strong, nonatomic) IBOutlet UILabel *remindLabel;

@end

@implementation BorrowBookCell

- (void)awakeFromNib
{
    UIColor *color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];
    _renewButton.layer.borderWidth = 1.0;
    _renewButton.layer.borderColor = color.CGColor;
    _titleLabel.preferredMaxLayoutWidth = [UIScreen mainScreen].bounds.size.width - 15*2;
}

- (void) setBorrowBooks:(BorrowBookModel *)borrowBooks
{
    _titleLabel.text = [self deleteQuotationMarks: borrowBooks.title];
    _borrowDateLabel.text = borrowBooks.borrowDate;
    _returnDateLabel.text = borrowBooks.returnDate;
    
    if (borrowBooks.dayOffset >= 0) {
        _remindLabel.text = [NSString stringWithFormat: @"%lu", (long)borrowBooks.dayOffset];
    }else{
        _remindLabel.text = [NSString stringWithFormat: @"已经超期%ld天",  labs((long)borrowBooks.dayOffset)];
    }
    
}

- (NSString *) deleteQuotationMarks: (NSString *) title
{
    title = [title stringByReplacingOccurrencesOfString: @"《" withString: @""];
    title = [title stringByReplacingOccurrencesOfString: @"》" withString: @""];
    return title;
}




@end
