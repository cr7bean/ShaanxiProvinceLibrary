//
//  DoubanBookModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/24.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DoubanBookModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *shortTitle;
@property (nonatomic, copy) NSString *originalTitle;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *publisher;
@property (nonatomic, copy) NSString *pubdate;
@property (nonatomic, copy) NSString *pages;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *binding;
@property (nonatomic, copy) NSString *idString;
@property (nonatomic, copy) NSString *rating;

@property (nonatomic, copy) NSString *authorIntro;
@property (nonatomic, copy) NSString *catalog;
@property (nonatomic, copy) NSString *summary;

@property (nonatomic, copy) NSString *translator;
@property (nonatomic, copy) NSString *imageString;




@end
