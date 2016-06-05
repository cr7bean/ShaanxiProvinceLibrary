//
//  NSDate+Tools.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/14.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Tools)

+ (NSDate *) dateWithString:(NSString *) string
                     offset: (NSInteger) days;
+ (NSString *) currentDateString;

/**
 *  把字符串格式的日期转换为 NSDate
 *
 */
+ (NSDate *) dateWithString: (NSString *) dateString;
/**
 *  给定日期和当天日期(字符串形式)的差值
 */
+ (NSInteger) daysFromDateString: (NSString *) dateString;

/**
 *  给定日期和当天日期的差值
 */
+ (NSInteger) daysFromDate: (NSDate *)date;

/**
 *  比给定日期早些天数的日期
 */

+ (NSDate *) changeHourWithDate: (NSDate *) date
                         byDate: (NSDate *) byDate;

@end
