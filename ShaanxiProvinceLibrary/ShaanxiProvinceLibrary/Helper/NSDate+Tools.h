//
//  NSDate+Tools.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/14.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Tools)

+ (NSDate *) dateWithString: (NSString *) dateString;
+ (NSDate *) currentDate;
+ (NSInteger) daysFromDateString: (NSString *) dateString;

@end
