//
//  NSDate+Tools.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/14.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "NSDate+Tools.h"


@interface NSDate ()


@end

@implementation NSDate (Tools)

# pragma mark - dateFormatter

+ (NSDateFormatter *) creatDateFormatter
{
    return [self creatDateFormatterWithString: @"yyyy-MM-dd"];
}

+ (NSDateFormatter *) creatDateFormatterWithString: (NSString *) formatString
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        formatter = [NSDateFormatter new];
    });
    formatter.dateFormat = formatString;
    formatter.timeZone = [NSTimeZone localTimeZone];
    return formatter;
}


# pragma mark - creatDate

// 转换后的时间和时区有关
+ (NSDate *) dateWithString: (NSString *) dateString
{
    NSDateFormatter *formatter = [self creatDateFormatter];
    return [formatter dateFromString: dateString];
}

+ (NSDate *) currentDate
{
    NSDateFormatter *formatter = [self creatDateFormatter];
    NSString *todayString = [self currentDateString];
    return [formatter dateFromString: todayString];
}

+ (NSString *) currentDateString
{
    NSDateFormatter *formatter = [self creatDateFormatter];
//    NSDate *date = [self convertToLocalDate];
    // 转换为时间字符串的时候，因为 formatter 已经设置了时区。因此不用再把时间转换为当前时区的时间
    NSDate *date = [NSDate date];
    NSString *todayString = [formatter stringFromDate: date];
    return todayString;
}

+ (NSDate *) convertToLocalDate
{
    NSDate *souceDate = [NSDate date];
    NSTimeZone *sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation: @"GMT"];
    NSTimeZone *destinationTimeZone = [NSTimeZone localTimeZone];
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate: souceDate];
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate: souceDate];
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    NSDate *destinationDate = [[NSDate alloc] initWithTimeInterval: interval sinceDate: souceDate];
    return destinationDate;
}

# pragma mark - compare date

+ (NSInteger) daysFromDateString: (NSString *) dateString
{
    NSDate *today = [self currentDate];
    NSDate *borrowDate = [self dateWithString: dateString];
    NSTimeInterval interVal = [borrowDate timeIntervalSinceDate: today];
    return (long)(interVal/(60*60*24));
}

+ (NSInteger) daysFromDate: (NSDate *)date
{
    NSInteger interVal = [[NSDate date] timeIntervalSinceDate: date];
    return (long)(interVal/(60*60*24));
}

/**
 * 把提醒的时间精确到秒，因此这里重新设置 DateFormatter
 */
+ (NSDate *) dateWithString:(NSString *) string
                     offset: (NSInteger) days
{
    NSDateFormatter *formatte = [self creatDateFormatterWithString: @"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [string stringByAppendingString: @" 10:00:00"];
    NSDate *original = [formatte dateFromString: dateString];
    NSTimeInterval originalInterval = original.timeIntervalSince1970;
    NSTimeInterval intervalOffset = 60*60*24*days;
    NSTimeInterval newInterval = originalInterval - intervalOffset;
    return [NSDate dateWithTimeIntervalSince1970: newInterval];
}

#pragma mark - change Hour

/**
 *  把给定的日期的时间变换为当前的时间
 *
 *  @param date   要变换的日期
 *  @param byDate 基准日期
 *
 *  @return
 */
+ (NSDate *) changeHourWithDate: (NSDate *) date
                         byDate: (NSDate *) byDate
{
    NSDateFormatter *formatterDate = [self creatDateFormatterWithString: @"yyyy-MM-dd"];
    NSString *dateString = [formatterDate stringFromDate: date];
    NSDateFormatter *formatteHour = [self creatDateFormatterWithString: @"HH:mm:ss"];
    NSString *hourString = [formatteHour stringFromDate: byDate];
    
    NSString *mix = [dateString stringByAppendingFormat: @" %@", hourString];
    NSDateFormatter *mixFormatter = [self creatDateFormatterWithString: @"yyyy-MM-dd HH:mm:ss"];
    return [mixFormatter dateFromString: mix];
}


@end
