//
//  GVUserDefaults+library.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/3/6.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (library)

@property (nonatomic, strong) NSArray *collectionTag;
@property (nonatomic, assign) NSInteger aheadDay;
@property (nonatomic, assign) BOOL remind;
@property (nonatomic, assign) BOOL repeat;
@property (nonatomic, assign) BOOL firstLogin;
@property (nonatomic, strong) NSMutableDictionary *libraryType;
@property (nonatomic, assign) NSUInteger removeAdState;
@property (nonatomic, strong) NSDate *clickADDate;

// 用来标识学校图书馆和省图书馆
@property (nonatomic, copy) NSString *libraryName;
@property (nonatomic, copy) NSString *libraryShortName;
@property (nonatomic, assign) BOOL isSchoolLibrary;
@property (nonatomic, strong) NSDictionary *schoolLibraryInfo;
@end

