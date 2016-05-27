//
//  DueNotificationManager.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/18.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "DueNotificationManager.h"
#import "NSDate+Tools.h"
#import "BorrowBookModel.h"
#import <UIKit/UIKit.h>
#import "GVUserDefaults+library.h"


@implementation DueNotificationManager

+ (instancetype) sharedManager
{
    static DueNotificationManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [DueNotificationManager new];
    });
    return manager;
}

- (void) scheduleNotification: (NSMutableArray<BorrowBookModel *> *) borrowBooks
                     aheadDay: (NSInteger) aheadDay
                      remind : (BOOL) remind
                       repeat: (BOOL) repeat
                  accountName: (NSString *) accountName
{
    [self cancelNotificationWithName: accountName];
//    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    NSDictionary *returnBookDic= [self convertToDateAndTitlesWithArray: borrowBooks];
    NSArray *keys = [returnBookDic allKeys];
    
    for (NSString *dateString in keys) {
        
        NSInteger dayOffset = [NSDate daysFromDateString: dateString];
        UILocalNotification *booksDueNotification = [self configurateLocalNotification];
        NSString *alertConent = [NSString stringWithFormat: @"帐号%@有%lu本书%@到期，请注意查看", accountName,[returnBookDic[dateString] count], dateString];
        if (dayOffset > aheadDay) {
            booksDueNotification.fireDate = [NSDate dateWithString: dateString offset: aheadDay];
        }else{
            
            if (dayOffset > 0) {
                booksDueNotification.fireDate = [NSDate dateWithString: dateString offset: dayOffset];
            }else{
                booksDueNotification.fireDate = [NSDate dateWithString: [NSDate currentDateString] offset: 0];
                alertConent = [NSString stringWithFormat: @"您有%lu 本书已经到期，请注意查看", [returnBookDic[keys] count]];
            }
        }
        
        // 动态调整第一个通知的时间，就是在当前时间的后一小时.
        booksDueNotification.fireDate = [NSDate dateWithTimeInterval: 60*10
                                                           sinceDate: [NSDate changeHourWithDate: booksDueNotification.fireDate byDate: [NSDate date]]];
        booksDueNotification.userInfo = @{@"account": accountName};
        
        // 防止提醒时间冲突
        NSArray *notifications = [self allNotificationWithName: accountName];
        UILocalNotification *previousNotification  = [notifications lastObject];
        NSDate *previousDate = previousNotification.fireDate;
        if (previousDate) {
            booksDueNotification.fireDate = [NSDate dateWithTimeInterval: 60*10
                                                               sinceDate: [NSDate changeHourWithDate: booksDueNotification.fireDate byDate: previousDate]];
        }
        // 提醒内容
        booksDueNotification.alertBody = alertConent;
//        NSLog(@"%@", booksDueNotification);
    
        // 是否重复提醒
        if (repeat) {
            booksDueNotification.repeatInterval = NSCalendarUnitDay;
        }
        // 是否提醒
        if (remind) {
            [[UIApplication sharedApplication] scheduleLocalNotification: booksDueNotification];
        }
    }
    
}

/**
 *  取消特定名称的通知
 *
 *  @param name
 */
- (void) cancelNotificationWithName: (NSString *) name
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if ([notification.userInfo[@"account"] isEqualToString: name]) {
            [[UIApplication sharedApplication] cancelLocalNotification: notification];
        }
    }
}

+ (void) cancelNotificationWithName: (NSString *) name
{
    DueNotificationManager *manager = [DueNotificationManager sharedManager];
    [manager cancelNotificationWithName: name];
    
}

/**
 *  查找特定名称的通知
 *
 *  @param name
 *
 *  @return
 */
- (NSArray *) allNotificationWithName: (NSString *) name
{
    NSMutableArray *array = [ NSMutableArray array];
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications) {
        if ([notification.userInfo[@"account"] isEqualToString: name]) {
            [array addObject: notification];
        }
    }
    return [array copy];
}

- (UILocalNotification *) configurateLocalNotification
{
    UILocalNotification *notification = [UILocalNotification new];
    notification.timeZone = [NSTimeZone localTimeZone];
    notification.soundName = UILocalNotificationDefaultSoundName;
    return notification;
}

/**
 *  把相同的归还日期的书籍整理在一起
 *
 *  @param borrowBooks
 *
 *  @return 还书的日期和对应的书籍
 */
- (NSDictionary *) convertToDateAndTitlesWithArray: (NSMutableArray<BorrowBookModel *> *) borrowBooks
{
    NSMutableArray *returnDays = [NSMutableArray new];
    NSMutableDictionary *returnDaysDic = [NSMutableDictionary new];
    if (borrowBooks.count) {
        for (BorrowBookModel *book in borrowBooks) {
            [returnDays addObject: book.returnDate];
        }
        NSSet *returnDaySet = [NSSet setWithArray: returnDays];
        for (NSString *daySet  in returnDaySet) {
            NSMutableArray *titles = [NSMutableArray new];
            for (int i=0; i<returnDays.count; i++) {
                if ([daySet isEqualToString: returnDays[i]]) {
                    [titles addObject: [borrowBooks[i] title]];
                }
            }
            [returnDaysDic setObject: titles forKey: daySet];
        }
    }
    return [NSDictionary dictionaryWithDictionary: returnDaysDic];
}


+ (void) scheduleBorrowBookNotification: (NSMutableArray<BorrowBookModel *> *) borrowBooks
                            accountName: (NSString *) accountName
{
    DueNotificationManager *manager = [DueNotificationManager sharedManager];
    [manager scheduleNotification: borrowBooks
                                        aheadDay: [GVUserDefaults standardUserDefaults].aheadDay
                                          remind: [GVUserDefaults standardUserDefaults].remind
                                          repeat: [GVUserDefaults standardUserDefaults].repeat
                                     accountName: accountName];
    
}

@end