//
//  NewsModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/22.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isCued;
@property (nonatomic, copy) NSString *detailUrl;

@end
