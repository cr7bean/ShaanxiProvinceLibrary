//
//  LoginManager.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/12.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "LoginManager.h"
#import <AFNetworking.h>
#import "BBRSACryptor.h"
#import "GTMBase64.h"
#import <TFHpple.h>

@interface LoginManager ()




@end

@implementation LoginManager


+ (instancetype) sharedManager
{
    static LoginManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

# pragma  mark - basic network request

- (void) basicRequestWithUrl: (NSString *) urlString
                  parameters: (NSDictionary *) parameters
                     success: (success) success
                     failure: (failure) failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager GET: urlString
      parameters: parameters
        progress:^(NSProgress *downloadProgress) {
            
        }
         success:^(NSURLSessionDataTask *task, id responseObject) {
             success(responseObject);
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             failure(error);
         }];
}

# pragma mark - public key and encode password
- (void) fetchEncodePassword: (NSString *) password
                   RSAEncode: (RSAEncode) RSAEncode

{
    NSString *url = @"http://mc.m.5read.com/apis/user/getLoginKey.jspx";
    [self basicRequestWithUrl: url
                   parameters: nil
                      success:^(id responseObject) {
                          
                          id json = [NSJSONSerialization JSONObjectWithData: responseObject options: 0 error: nil];
                          if ([[json objectForKey:@"result"] isEqualToNumber: @1]) {
                              NSString *publicKey = [[json objectForKey: @"msg"] objectForKey: @"key"];
                              NSString *rsaPassword = [self rsaEncryptionWithPublicKey: publicKey password: password];
                              RSAEncode(rsaPassword);
                          }
                      }
                      failure:^(NSError *error) {
                          
                          NSLog(@"fetchPublikKeyError: %@",error.description);
                          
                      }];
    
}

# pragma mark - RSA encode

- (NSString *) rsaEncryptionWithPublicKey: (NSString *) publicKey
                                 password: (NSString *) password
{
    BBRSACryptor *rsaCryptor = [BBRSACryptor new];
    BOOL importSuccess = [rsaCryptor importRSAPublicKeyBase64: publicKey];
    if (!importSuccess) {
        return nil;
    }
    NSData *cipherData = [rsaCryptor encryptWithPublicKeyUsingPadding: RSA_PADDING_TYPE_PKCS1 plainData: [password dataUsingEncoding: NSUTF8StringEncoding]];
    return [GTMBase64 stringByEncodingData: cipherData];
}


# pragma mark - login

- (void) loginWithAccont: (NSString *) account
                password: (NSString *) password
             libraryType: (NSInteger) typeIndex
                 success: (success) success
                 failure: (failure) failure
{
    NSArray *schools = [NSArray arrayWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"schools" ofType: @"plist"]];
    NSDictionary *school = schools[typeIndex];
    
    
    [self fetchEncodePassword: password
                    RSAEncode:^(NSString *encodePassword) {
                        NSString *urlString = @"http://mc.m.5read.com/apis/user/userLogin.jspx";
                        NSDictionary *parameter = @{@"areaid": school[@"areaId"],
                                                    @"schoolid": school[@"schoolId"],
                                                    @"userType": @"0",
                                                    @"username": account,
                                                    @"password": encodePassword,
                                                    @"encPwd": @"1"};
                        [self basicRequestWithUrl: urlString
                                       parameters: parameter
                                          success:^(id responseObject) {
                                              success(responseObject);
                                          }
                                          failure:^(NSError *error) {
                                              failure(error);
                                          }];
                    }];
}

+ (void) loginWithAccont: (NSString *) account
                password: (NSString *) password
             libraryType: (NSInteger) typeIndex
                 success: (loginStatus) statusCode
                 failure: (failure) failure
{
    LoginManager *manager = [LoginManager sharedManager];
    [manager loginWithAccont: account
                    password: password
                 libraryType: typeIndex
                     success:^(id responseObject) {
                         id json = [NSJSONSerialization JSONObjectWithData: responseObject options: 0 error: nil];
                         NSInteger code = [[json objectForKey: @"result"] integerValue];
                         statusCode(code);
                     }
                     failure:^(NSError *error) {
                         failure(error);
                     }];
}

# pragma borrowBook url

- (void) fetchBorrowUrlString: (success) success
                       failue: (failure) failure
{
    NSString *urlString = @"http://mc.m.5read.com/api/opac/showOpacLink.jspx?newSign";
    [self basicRequestWithUrl: urlString
                   parameters: nil
                      success:^(id responseObject) {
                          success(responseObject);
                          
                    }
                      failure:^(NSError *error) {
                          failure(error);
                      }];
    
}








@end
