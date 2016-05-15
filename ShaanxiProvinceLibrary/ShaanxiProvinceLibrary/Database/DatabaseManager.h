//
//  DatabaseManager.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/15.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BorrowBookModel;
@class FMDatabase;

typedef void(^selectSuccess)(NSMutableArray *books);

@interface DatabaseManager : NSObject

+ (instancetype) sharedManager;
+ (FMDatabase *) createAccountDatabase;
+ (FMDatabase *) createCollectionBookDatabase;
+ (void) createAccountTableWithName: (NSString *) tableName
                         inDatabase: (FMDatabase *) database;
+ (void) createCollectionBookTableWithName: (NSString *) tableName
                                inDatabase: (FMDatabase *) database;
+ (void) insertIntoAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks;
+ (void) selectFromAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                        success: (selectSuccess) success;

@end
