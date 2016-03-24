//
//  bookListModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BookListModel : NSObject

@property (nonatomic, copy) NSString *number;
@property (nonatomic, copy) NSString *authorAndTitle;
@property (nonatomic, copy) NSString *callNumber;
@property (nonatomic, copy) NSString *publicationDate;
@property (nonatomic, copy) NSString *libraryHoldings;
@property (nonatomic, copy) NSString *detailNumString;

+ (BookListModel *) initWithNumber: (NSString *) number
                        callNumber: (NSString *) callNumber
                   publicationDate: (NSString *) publicationDate
                    authorAndTitle: (NSString *) authorAndTitle
                   libraryHoldings: (NSString *) libraryHoldings;
- (NSString *) description;

@end
