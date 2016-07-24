//
//  ParseHTML.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/19.
//  Copyright © 2015年 Long. All rights reserved.
//
/*
 从网页抓取内容，解析相关数据
*/
#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "MottoModel.h"
#import "UIViewController+AddView.h"

@class DoubanBookModel;

typedef NS_ENUM(NSInteger, requestMethodType) {
    requestMethodTypeGet = 1,
    requestMethodTypePost,
};
typedef NS_ENUM(NSInteger, searchBookState) {
    searchBookStateServeBusy = 1,
    searchBookStateZero,
    searchBookStateOne,
    searchBookStateMore,
};

typedef void(^requestSuccessBlock)(NSURLSessionDataTask *task, id responseObject);
typedef void(^requestFailurerBlock)(NSURLSessionDataTask *task, NSError *error);

@interface ParseHTML : NSObject

+ (void) parseMottoAndImage: (void(^)(MottoModel *motto)) success
                    failure: (requestFailurerBlock) failure;

+ (void) parseNewsContentSuccess: (void(^)(NSMutableArray *newsContent)) newsContent
                         failure: (requestFailurerBlock) failure;

+ (void) parseHotSearchingBookSuccess: (void(^)(NSMutableArray *hotSearchingBooks)) success
                              failure: (requestFailurerBlock) failure;

+ (void) parseBooksListWithString: (NSString *) urlSstring
                       dictionary: (NSDictionary *) dictionary
                          success: (void(^)(searchBookState searchState, NSDictionary *searchBook)) success
                          failure: (requestFailurerBlock) failure;

+ (void) booksNumberIsMoreNextPage: (NSString *) urlString
                         parameter: (NSDictionary *) parameter
                           success: (void(^)(NSDictionary *booklist)) success
                           failure: (requestFailurerBlock) failure;

+ (void) booksNumberIsOneNextPage: (NSString *) urlString
                        parameter: (NSDictionary *) parameter
                          success: (void(^)(NSDictionary *bookContent)) success
                          failure: (requestFailurerBlock) failure;

+ (void) bookContentFromDouban: (NSString *) urlString
                       success: (void(^)(DoubanBookModel *book)) success
                       failure: (requestFailurerBlock) failure;

+ (void) bookTags: (NSString *) urlString
         successs: (void(^)(NSMutableArray *tagsArray)) success
          failure: (requestFailurerBlock) failure;


+ (void) searchBookWithTagInUrl: (NSString *) urlString
                      parameter: (NSDictionary *) parameter
                       successs: (void(^)(NSMutableArray *bookArray, NSArray *tagsRecommended)) success
                        failure: (requestFailurerBlock) failure;

+ (void) amazonBooksWithUrl: (NSString *) urlString
                  parameter: (NSDictionary *) parameter
                   successs: (void(^)(NSMutableArray *amazonBookArray, NSUInteger pageNumber)) success
                    failure: (requestFailurerBlock) failure;

+ (void) JDBooksWithUrl: (NSString *) urlString
               successs: (void(^)(NSMutableArray *JDBookArray, NSUInteger pageNumber)) success
                failure: (requestFailurerBlock) failure;

+ (void) DDBooksWithUrl: (NSString *) urlString
               successs: (void(^)(NSMutableArray *DDBookArray, NSUInteger pageNumber)) success
                failure: (requestFailurerBlock) failure;

+ (void) bookListInNPULibraryWithUrl: (NSString *) urlString
                           parameter: (NSDictionary *) parameter
                             success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                             failure: (requestFailurerBlock) failure;

+ (void) bookListInXidianLibraryWithUrl: (NSString *) urlString
                              parameter: (NSDictionary *) parameter
                                success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                                failure: (requestFailurerBlock) failure;

+ (void) bookListInXAUTLibraryWithUrl: (NSString *) urlString
                            parameter: (NSDictionary *) parameter
                              success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                              failure: (requestFailurerBlock) failure;

+ (void) bookListInSchoolLibraryWithUrl: (NSString *) urlString
                              parameter: (NSDictionary *) parameter
                                success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString, NSString *nextPage)) success
                                failure: (requestFailurerBlock) failure;

@end
