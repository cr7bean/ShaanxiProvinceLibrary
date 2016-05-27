//
//  BorrowBookModel.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/12.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "BorrowBookModel.h"
#import "NSDate+Tools.h"

@implementation BorrowBookModel

- (NSInteger) dayOffset
{
    return [NSDate daysFromDateString: _returnDate];
}

- (BOOL) isEqualToBorrowBookModel: (BorrowBookModel *) book
{
    BOOL isEqual = [_title isEqualToString: book.title] &&
    [_location isEqualToString: book.location] &&
    [_borrowDate isEqualToString: book.borrowDate] &&
    [_returnDate isEqualToString: book.returnDate] &&
    [_location isEqualToString: book.location];
    if (isEqual) {
        return YES;
    }else{
        return NO;
    }
    
}

@end
