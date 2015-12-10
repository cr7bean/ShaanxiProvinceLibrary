//
//  MottoModel.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/17.
//  Copyright (c) 2015年 Long. All rights reserved.
//

/*
 
 a model includes a saying and its author,a image
 
 */
#import <Foundation/Foundation.h>

@interface MottoModel : NSObject

@property (nonatomic, copy) NSString *saying;
@property (nonatomic, copy) NSString *personage;
@property (nonatomic, copy) NSString *imageName;

+ (MottoModel*) initWith: (NSString*) saying
               personage: (NSString*) personage
               imageName: (NSString*) imageName;
@end
