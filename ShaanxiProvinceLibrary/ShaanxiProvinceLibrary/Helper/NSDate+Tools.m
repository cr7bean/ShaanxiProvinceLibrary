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
    return [self creatDateFormatterWithString: @"YYYY-MM-dd"];
}

+ (NSDateFormatter *) creatDateFormatterWithString: (NSString *) formatString
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        formatter = [NSDateFormatter new];
    });
    formatter.timeZone = [NSTimeZone localTimeZone];
    formatter.dateFormat = formatString;
    return formatter;
}


# pragma mark - creatDate
+ (NSDate *) dateWithString: (NSString *) dateString
{
    NSDateFormatter *formatter = [self creatDateFormatter];
    return [formatter dateFromString: dateString];
}

+ (NSDate *) currentDate
{
    NSDateFormatter *formatter = [self creatDateFormatter];
    NSString *todayString = [formatter stringFromDate: [NSDate date]];
    return [formatter dateFromString: todayString];
}

# pragma mark - compare date

+ (NSInteger) daysFromDateString: (NSString *) dateString
{
    NSDate *today = [self currentDate];
    NSDate *borrowDate = [self dateWithString: dateString];
    NSTimeInterval interVal = [borrowDate timeIntervalSinceDate: today];
    return (long)(interVal/(60*60*24));
}


@end
