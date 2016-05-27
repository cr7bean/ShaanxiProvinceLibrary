//
//  DatabaseManager.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/15.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "DatabaseManager.h"
#import <FMDB.h>
#import "BorrowBookModel.h"

static  NSString * const kAccountTable = @"Account.db";
static  NSString * const kCollectionBookTable = @"collectionBook.db";

@interface DatabaseManager ()

@property (nonatomic, strong) FMDatabase *account;
@property (nonatomic, strong) FMDatabase *collectionBook;

@end

@implementation DatabaseManager


+ (instancetype) sharedManager
{
    static DatabaseManager *manager = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        manager = [[DatabaseManager alloc] init];
    });
    return manager;
}

# pragma mark - getter

- (FMDatabase *) account
{
    if (!_account) {
        _account = [self createDatabaseWithName: kAccountTable];
    }
    return _account;
}

- (FMDatabase *) collectionBook
{
    if (!_collectionBook) {
        _collectionBook = [self createDatabaseWithName: kCollectionBookTable];
    }
    return _collectionBook;
}

# pragma mark - create Database

- (FMDatabase *) createDatabaseWithName: (NSString *) name
{
    NSString *fileDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [fileDir stringByAppendingPathComponent: name];
    return [FMDatabase databaseWithPath: filePath];
}

# pragma mark - create table

// creat account table
- (void) createAccountTableWithName: (NSString *) tableName
{
    NSString *table = [NSString stringWithFormat: @"create table if not exists %@ (title text not null, renewUrlString text not null, borrowDate text not null, returnDate text not null, location text not null)", tableName];
    if ([self.account open]) {
        [_account executeUpdate: table];
        [_account close];
    }
}

+ (void) createAccountTableWithName: (NSString *) tableName
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager createAccountTableWithName: tableName];
}

// creat collection book table
- (void) createCollectionBookTableWithName: (NSString *) tableName
{
    NSString *table = [NSString stringWithFormat: @"create table if not exists %@ (title text not null, location text not null)", tableName];
    if ([self.collectionBook open]) {
        [_collectionBook executeUpdate: table];
        [_collectionBook close];
    }
}

+ (void) createCollectionBookTableWithName: (NSString *) tableName
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager createCollectionBookTableWithName: tableName];
}

# pragma mark - insert into table

- (void) insertIntoAccountTable: (NSString *) tableName
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks
{
    if ([self.account open]) {
        [self deleteFromTable: tableName inDatabase: _account];
        NSString *insert = [NSString stringWithFormat: @"insert into %@ (title, renewUrlString, borrowDate, returnDate, location) values (?,?,?,?,?)", tableName];
        for (BorrowBookModel *book in borrowBooks) {
            [_account executeUpdate: insert, book.title, book.renewUrlString, book.borrowDate, book.returnDate, book.location];
        }
        [_account close];
    }
}

+ (void) insertIntoAccountTable: (NSString *) tableName
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager insertIntoAccountTable: tableName object: borrowBooks];
}

# pragma mark - select from table

- (void) selectFromAccountTable: (NSString *) tableName
                        success: (selectSuccess) success
{
    NSMutableArray *borrowBooks = [NSMutableArray new];
    NSString *select = [NSString stringWithFormat: @"select * from %@", tableName];
    [self.account open];
    FMResultSet *result = [self.account executeQuery: select];
    while ([result next]) {
        BorrowBookModel *borrowBook = [BorrowBookModel new];
        borrowBook.title = [result stringForColumn: @"title"];
        borrowBook.renewUrlString = [result stringForColumn: @"renewUrlString"];
        borrowBook.borrowDate = [result stringForColumn: @"borrowDate"];
        borrowBook.returnDate = [result stringForColumn: @"returnDate"];
        borrowBook.location = [result stringForColumn: @"location"];
        [borrowBooks addObject: borrowBook];
    }
    [self.account close];
    success(borrowBooks);
}

+ (void) selectFromAccountTable: (NSString *) tableName
                        success: (selectSuccess) success
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager selectFromAccountTable: tableName success:^(NSMutableArray *books) {
        success(books);
    }];
}


# pragma mark - delete from table

// 删除表中所有数据
- (void) deleteFromTable: (NSString *) tableName
              inDatabase: (FMDatabase *) database
{
        [database executeUpdate: [NSString stringWithFormat: @"delete from %@", tableName]];

}

// 删除表
- (void) dropTable: (NSString *) tableName
        inDatabase: (FMDatabase *) database
{
    if ([database open]) {
        [database executeUpdate: [NSString stringWithFormat: @"drop table %@", tableName]];
        [database close];
    }
}

- (void) deleteAccountTable: (NSString *) tableName
{
    [self dropTable: tableName inDatabase: self.account];
}

- (void) deleteCollectionBookTable: (NSString *) tableName
{
    [self dropTable: tableName inDatabase: self.collectionBook];
}

+ (void) dropAccountTable: (NSString *) tableName
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager deleteAccountTable: tableName];
}

+ (void) dropeCollectionBookTable: (NSString *) tableName
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager deleteCollectionBookTable: tableName];
}

@end
