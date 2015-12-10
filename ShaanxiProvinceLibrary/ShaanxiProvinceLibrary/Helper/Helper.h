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


+ (void) interceptStringWith: (NSString*) identify
                          in: (NSString*) original
                resultString: (void(^)(NSString* formerString, NSString*        latterString)) resultString;
+ (NSString *) deleteSpaceAndCR: (NSString *) string;
+ (NSString *) addSpace: (NSString *) string
             withNumber: (NSUInteger) number;

+ (UIColor *) setColorWithRed: (NSUInteger) red
                       green: (NSUInteger) green
                        blue: (NSUInteger) blue;

@end
