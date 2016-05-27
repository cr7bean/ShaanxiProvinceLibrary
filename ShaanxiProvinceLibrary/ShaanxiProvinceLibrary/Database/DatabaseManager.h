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
/**
 *  在 Account database 中创建 Table
 *
 *  @param tableName 
 */
+ (void) createAccountTableWithName: (NSString *) tableName;

/**
 *  在 CollectionBook database 中创建 Table
 *
 *  @param tableName
 */
+ (void) createCollectionBookTableWithName: (NSString *) tableName;

/**
 *  在 Account database 对应的 Table 中插入数据
 *
 *  @param tableName
 *  @param borrowBooks
 */
+ (void) insertIntoAccountTable: (NSString *) tableName
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks;

/**
 * 从 Account database 对应的 Table 中取出数据
 *
 *  @param tableName
 *  @param success
 */
+ (void) selectFromAccountTable: (NSString *) tableName
                        success: (selectSuccess) success;


+ (void) dropAccountTable: (NSString *) tableName;

+ (void) dropCollectionBookTable: (NSString *) tableName;

@end
