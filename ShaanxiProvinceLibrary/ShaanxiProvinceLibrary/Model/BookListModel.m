//
//  bookListModel.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "BookListModel.h"

@implementation BookListModel



+ (BookListModel *) initWithNumber: (NSString *) number
                        callNumber: (NSString *) callNumber
                   publicationDate: (NSString *) publicationDate
                    authorAndTitle: (NSString *) authorAndTitle
                   libraryHoldings: (NSString *) libraryHoldings;
{
    BookListModel *book = [BookListModel new];
    book.number = number;
    book.authorAndTitle = authorAndTitle;
    book.libraryHoldings = libraryHoldings;
    book.publicationDate = publicationDate;
    book.callNumber = callNumber;
    return book;
}

- (NSString *) description
{
    NSDictionary *dic = @{
                          @"callNumber": _callNumber,
                          @"date": _publicationDate,
                          @"title": _authorAndTitle,
                          @"holding": _libraryHoldings,
                          @"detail": _detailNumString};
    return [NSString stringWithFormat: @"%@", dic];
}

@end
