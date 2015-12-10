//
//  MottoModel.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/17.
//  Copyright (c) 2015年 Long. All rights reserved.
//

#import "MottoModel.h"

@implementation MottoModel

+ (MottoModel*) initWith: (NSString*) saying
               personage: (NSString*) personage
               imageName: (NSString*) imageName
{
    MottoModel *motto = [MottoModel new];
    motto.saying = saying;
    motto.personage = personage;
    motto.imageName = imageName;
    return motto;
}


@end
