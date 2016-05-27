//
//  DueNotificationManager.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/18.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BorrowBookModel;
@interface DueNotificationManager : NSObject

+ (void) scheduleBorrowBookNotification: (NSMutableArray<BorrowBookModel *> *) borrowBooks
                            accountName: (NSString *) accountName;
+ (void) cancelNotificationWithName: (NSString *) name;

@end
