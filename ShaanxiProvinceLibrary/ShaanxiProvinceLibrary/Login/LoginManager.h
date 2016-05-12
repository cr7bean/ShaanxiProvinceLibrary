//
//  LoginManager.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/12.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^success)(id responseObject);
typedef void(^failure)(NSError *error);
typedef void(^RSAEncode)(NSString *encodePassword);
typedef void(^loginStatus)(NSInteger statusCode);


@interface LoginManager : NSObject

+ (void) loginWithAccont: (NSString *) account
                password: (NSString *) password
             libraryType: (NSInteger) typeIndex
                 success: (loginStatus) statusCode
                 failure: (failure) failure;

+ (instancetype) sharedManager;

@end
