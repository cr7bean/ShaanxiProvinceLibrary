//
//  GVUserDefaults+library.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/3/6.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "GVUserDefaults+library.h"

@implementation GVUserDefaults (library)

@dynamic libraryName;
@dynamic libraryShortName;
@dynamic collectionTag;
@dynamic aheadDay;
@dynamic remind;
@dynamic repeat;
@dynamic firstLogin;
@dynamic libraryType;

/**
 *  设置初始值
 */
- (NSDictionary *)setupDefaults
{
    return @{
             @"aheadDay": @5,
             @"remind": @YES,
             @"repeat": @YES,
             @"firstLogin": @YES
             };
}


@end
