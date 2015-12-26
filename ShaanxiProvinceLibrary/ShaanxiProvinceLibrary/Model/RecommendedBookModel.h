//
//  recommendedBookModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/30.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecommendedBookModel : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *numberString;

+ (RecommendedBookModel *) initWithName: (NSString *) name
                              urlString: (NSString *) urlSttring
                           numberString: (NSString *) numberString;

@end
