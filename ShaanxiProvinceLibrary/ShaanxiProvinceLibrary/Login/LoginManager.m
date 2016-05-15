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
#import "BorrowBookModel.h"

# define wangLogObject(x) NSLog(@"%@", x)
# define wangLogValue(x) NSLog(@"%lu", x)

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
    NSLog(@"%p", manager);
    [manager loginWithAccont: account
                    password: password
                 libraryType: typeIndex
                     success:^(id responseObject) {
                         id json = [NSJSONSerialization JSONObjectWithData: responseObject options: 0 error: nil];
                         NSInteger code = [[json objectForKey: @"result"] integerValue];
//                         NSLog(@"login %@", NSStringFromClass([json[@"result"] class]));
                         statusCode(code);
                     }
                     failure:^(NSError *error) {
                         failure(error);
                     }];
}

# pragma mark - borrowBook url

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


# pragma mark - borrowBooks

- (void) fetchBorrowInfo: (borrowBook) borrowBook
                 failure: (failure) failure
{
    [self fetchBorrowUrlString:^(id responseObject) {
        id json = [NSJSONSerialization JSONObjectWithData: responseObject options: 0 error: nil];
//        NSLog(@"borrow %@",NSStringFromClass([json[@"result"] class]));
        NSArray *node = json[@"opacUrl"];
        if (node.count) {
            NSString *borrowUrl = [node[0] objectForKey: @"opaclendurl"];
            [self basicRequestWithUrl: borrowUrl
                           parameters: nil
                              success:^(id responseObject) {
                                  [self parseBowerInfoWithData: responseObject
                                                    borrowBook:^(NSMutableArray *borrowBooks) {
                                                        borrowBook(borrowBooks);
                                                    }];
                              }
                              failure:^(NSError *error) {
                                  failure(error);
                              }];
        }else{
            NSMutableArray *temp = [NSMutableArray new];
            borrowBook(temp);
        }
            }
                        failue:^(NSError *error) {
                            failure(error);
                        }];
}

// parse borrow book html

- (void) parseBowerInfoWithData: (NSData *) responseData
                     borrowBook: (borrowBook) borrowBook
{
    NSMutableArray *books = [[NSMutableArray alloc] initWithCapacity: 20];
    TFHpple *parse = [TFHpple hppleWithHTMLData: responseData];
    NSArray *sheets = [parse searchWithXPathQuery: @"//div[@class='sheet']"];
    if (sheets.count) {
        for (TFHppleElement *element in sheets) {
            NSData *sheetData = [[element raw] dataUsingEncoding: NSUTF8StringEncoding];
            TFHpple *sheetParse = [TFHpple hppleWithHTMLData: sheetData];
            NSString *sheetPath = @"//th[@class='sheetHd']/text() | //td";
            NSArray *borrowInfo = [sheetParse searchWithXPathQuery: sheetPath];
            if (borrowInfo.count == 6) {
                BorrowBookModel *book  = [BorrowBookModel new];
                book.title = [borrowInfo[0] content];
                book.renewUrlString = [[borrowInfo[1] firstChild] objectForKey: @"href"];
                book.borrowDate = [borrowInfo[3] text];
                book.returnDate = [borrowInfo[4] text];
                book.location = [borrowInfo[5] text];
                [books addObject: book];
//                wangLogObject(book.title);
//                wangLogObject(book.renewUrlString);
//                wangLogObject(book.borrowDate);
//                wangLogObject(book.returnDate);
//                wangLogObject(book.location);
            }
            
        }
        borrowBook(books);
    }
}

+ (void) fetchBorrowInfo: (borrowBook) borrowBook
                 failure: (failure) failure
{
    LoginManager *manager = [LoginManager sharedManager];
    [manager fetchBorrowInfo:^(NSMutableArray *borrowBooks) {
        borrowBook(borrowBooks);
    }
                     failure:^(NSError *error) {
                         failure(error);
    }];
    
}






@end
