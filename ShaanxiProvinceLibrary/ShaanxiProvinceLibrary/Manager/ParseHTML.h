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

@end
