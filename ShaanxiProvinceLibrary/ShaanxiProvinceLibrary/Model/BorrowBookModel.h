//
//  BorrowBookModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/12.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BorrowBookModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *renewUrlString;
@property (nonatomic, copy) NSString *borrowDate;
@property (nonatomic, copy) NSString *returnDate;
@property (nonatomic, copy) NSString *location;

@end
