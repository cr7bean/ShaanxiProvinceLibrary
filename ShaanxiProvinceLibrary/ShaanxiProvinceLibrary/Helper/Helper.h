//
//  Helper.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/18.
//  Copyright © 2015年 Long. All rights reserved.
//
/*
 一些常用的方法集合
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Helper : NSObject

+ (void) configurateLabel: (UILabel*) label
                     text: (NSString*) text
                textColor: (UIColor*) color
                     font: (UIFont *) font
            textAlignment: (NSTextAlignment) alignment;

+ (void) configurateLabel: (UILabel*) label
                textColor: (UIColor*) color
                     font: (UIFont *) font
                   number: (NSUInteger) number
                alignment: (NSTextAlignment) alignment;


+ (void) interceptStringWith: (NSString*) identify
                          in: (NSString*) original
                resultString: (void(^)(NSString* formerString, NSString* latterString)) resultString;
+ (NSString *) deleteSpaceAndCR: (NSString *) string;
+ (NSString *) addSpace: (NSString *) string
             withNumber: (NSUInteger) number;

+ (NSData *)UTF8Data: (NSData *) data;

+ (UIColor *) setColorWithRed: (NSUInteger) red
                       green: (NSUInteger) green
                        blue: (NSUInteger) blue;


+ (void) addViewController: (id) childController
          toViewController: (UIViewController *) parentController;

+ (void) setNetworkIndicator: (BOOL) show;

+ (NSString *) deleteSpesicalSymbolInString: (NSString *) string;


/**
 *  从字符串中找到某个范围内的数字
 *
 *  @param checkString 要检索的字符串
 */
+ (NSInteger) regexFindNumberInString: (NSString *) checkString;


/**
 *  删除字符串中的所有空白符。包括 \f(换页符)、\n(换行符)、\r(回车符)、\t(制表符)、\v(垂直制表符)
 *
 *  @param checkString 目标字符串
 *
 *  @return 删除空白符后的字符串
 */
+ (NSString *)regexDeleteBlankCharacterInString: (NSString *) checkString;
@end
