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

# pragma mark - create Database

- (FMDatabase *) createDatabaseWithName: (NSString *) name
{
    NSString *fileDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [fileDir stringByAppendingPathComponent: name];
    return [FMDatabase databaseWithPath: filePath];
}

// Account database
- (FMDatabase *) createAccountDatabase
{
   return [self createDatabaseWithName: kAccountTable];
}

+ (FMDatabase *) createAccountDatabase
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    return [manager createDatabaseWithName: kAccountTable];
}

// collectionBook database
- (FMDatabase *) createCollectionBookDatabase
{
    return [self createDatabaseWithName: kCollectionBookTable];
}

+ (FMDatabase *) createCollectionBookDatabase
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    return [manager createDatabaseWithName: kCollectionBookTable];
}

# pragma mark - create table

- (void) createAccountTableWithName: (NSString *) tableName
                         inDatabase: (FMDatabase *) database
{
    NSString *table = [NSString stringWithFormat: @"creat table if not exists %@ (title text not null, renewUrlString text not nll, borrowDate text not null, returnDate text not null, location text not null)", tableName];
    [database executeQuery: table];
}

+ (void) createAccountTableWithName: (NSString *) tableName
                         inDatabase: (FMDatabase *) database
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager createAccountTableWithName: tableName inDatabase: database];
}

- (void) createCollectionBookTableWithName: (NSString *) tableName
                                inDatabase: (FMDatabase *) database
{
    NSString *table = [NSString stringWithFormat: @"creat table if not exists %@ (title text not null, location text not null)", tableName];
    [database executeQuery: table];
}

+ (void) createCollectionBookTableWithName: (NSString *) tableName
                                inDatabase: (FMDatabase *) database
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager createCollectionBookTableWithName: tableName inDatabase: database];
}
# pragma mark - insert into table

- (void) insertIntoAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks
{
    if ([database open]) {
        [self deleteFromTable: tableName inDatabase: database];
        NSString *insert = [NSString stringWithFormat: @"insert into %@ (title, renewUrlString, borrowDate, returnDate, location) values (?,?,?,?)", tableName];
        for (BorrowBookModel *book in borrowBooks) {
            [database executeUpdate: insert, book.title, book.renewUrlString, book.borrowDate, book.returnDate, book.location];
        }
        [database close];
    }
}

+ (void) insertIntoAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                         object: (NSMutableArray<BorrowBookModel *> *) borrowBooks
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager insertIntoAccountTable: tableName inDatabase: database object: borrowBooks];
}

# pragma mark - select from table

- (void) selectFromAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                        success: (selectSuccess) success
{
    NSMutableArray *borrowBooks = [NSMutableArray new];
    NSString *select = [NSString stringWithFormat: @"select * from %@", tableName];
    FMResultSet *result = [database executeQuery: select];
    while ([result next]) {
        BorrowBookModel *borrowBook = [BorrowBookModel new];
        borrowBook.title = [result stringForColumn: @"title"];
        borrowBook.renewUrlString = [result stringForColumn: @"renewUrlString"];
        borrowBook.borrowDate = [result stringForColumn: @"borrowDate"];
        borrowBook.returnDate = [result stringForColumn: @"returnDate"];
        borrowBook.location = [result stringForColumn: @"location"];
        [borrowBooks addObject: borrowBook];
    }
    success(borrowBooks);
}

+ (void) selectFromAccountTable: (NSString *) tableName
                     inDatabase: (FMDatabase *) database
                        success: (selectSuccess) success
{
    DatabaseManager *manager = [DatabaseManager sharedManager];
    [manager selectFromAccountTable: tableName inDatabase: database success:^(NSMutableArray *books) {
        success(books);
    }];
}


# pragma mark - delete from table

- (void) deleteFromTable: (NSString *) tableName
              inDatabase: (FMDatabase *) database
{
    [database executeUpdate: [NSString stringWithFormat: @"delete from %@", tableName]];
}




@end
