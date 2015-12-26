//
//  recommendedBookModel.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "RecommendedBookModel.h"

@implementation RecommendedBookModel

+ (RecommendedBookModel *) initWithName: (NSString *) name
                              urlString: (NSString *) urlSttring
                           numberString: (NSString *) numberString
{
    RecommendedBookModel *book = [RecommendedBookModel new];
    book.name = name;
    book.urlString = urlSttring;
    book.numberString = numberString;
    return book;
}

@end
