                                                                                                                                                                                                                                                             //
//  ParseHTML.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/19.
//  Copyright © 2015年 Long. All rights reserved.
//


# define wangLogObject(x) NSLog(@"%@", x)
# define wangLogValue(x) NSLog(@"%lu", x)

#import "ParseHTML.h"
#import "Helper.h"
#import <TFHpple.h>
#import "NewsModel.h"
#import "DoubanBookModel.h"

#import "RecommendedBookModel.h"
#import "BookListModel.h"


@implementation ParseHTML

#pragma mark - basical request
+ (void) requestWithUrl: (NSString *) url
              parameter: (NSDictionary *) parameter
             methodType: (requestMethodType) methodType
                success: (requestSuccessBlock) success
                failure: (requestFailurerBlock) failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setTimeoutInterval: 20];
    [Helper setNetworkIndicator: YES];

    switch (methodType) {
        case requestMethodTypeGet:{
            [manager GET: url parameters: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [Helper setNetworkIndicator: NO];
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [Helper setNetworkIndicator: NO];
                failure(task, error);
            }];
            break;
        }
        case requestMethodTypePost:{
            [manager POST: url parameters: parameter success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [Helper setNetworkIndicator: NO];
                success(task, responseObject);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [Helper setNetworkIndicator: NO];
                failure(task, error);
            }];
            break;
        }
    }
}


#pragma mark -  motto and image
/**
 *  获取首页名言和图片
 *
 */

+ (void) parseMottoAndImage: (void(^)(MottoModel *motto)) success
                    failure: (requestFailurerBlock) failure
{
    NSString *urlString = @"http://huaban.com/boards/26435559/";

    [self requestWithUrl: urlString parameter: nil methodType:(requestMethodTypeGet) success:^(NSURLSessionDataTask *task, id responseObject) {
        
        MottoModel *motto = [MottoModel new];
        
        //查找封面图片
        TFHpple *mottoParse = [TFHpple hppleWithHTMLData: responseObject];
        NSArray *nodes = [mottoParse searchWithXPathQuery: @"//img"];
        if (nodes.count >2) {
            motto.imageName =[(TFHppleElement*)nodes[2] objectForKey: @"src"];
        }
        
        //查找名言和作者
        NSString *mottoXpath = @"//div[@class='description']/text()";
        NSArray *mottoNodes = [mottoParse searchWithXPathQuery: mottoXpath];
        if (mottoNodes.count > 2) {
            motto.saying = [(TFHppleElement*)mottoNodes[0] content];
            motto.personage = [(TFHppleElement*)mottoNodes[1] content];
            success(motto);
        }
    }failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
    
}


#pragma mark - news content
/**
 *  首页新闻数据
 */

+ (void) parseNewsContentSuccess: (void(^)(NSMutableArray *newsContent)) success
                         failure: (requestFailurerBlock) failure
{
    NSString *newsUrl = @"http://www.sxlib.org.cn/";
    [self requestWithUrl: newsUrl parameter: nil methodType:(requestMethodTypeGet) success:^(NSURLSessionDataTask *task, id responseObject) {
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        
        NSArray *xpathArray = @[@"//*[@id='shantunew']/div/div[1]/ul/li/a",
                                @"//*[@id='shantunew']/div/div[2]/ul/li/a",
                                @"//*[@id='shantunew']/div/div[3]/ul/li/a",
                                @"//*[@id='shantunew']/div/div[4]/ul/li/a",];
        NSMutableArray *newsContentArray = [NSMutableArray new];
        for (NSString *xpath in xpathArray) {
            
            NSMutableArray *partNews = [NSMutableArray new];
            NSArray *nodes = [parse searchWithXPathQuery: xpath];
            for (TFHppleElement *element in nodes) {
                
                NSString *title = [element objectForKey: @"title"];
                NSString *url = [element objectForKey: @"href"];
                
                url = [self correctNewsDetailUrl: url];
                title = [self correctNewsTitle: title];
                
                NewsModel *news = [NewsModel new];
                news.title = title;
                news.detailUrl = url;
                [partNews addObject: news];
            }
            [newsContentArray addObject: partNews];
        }
        success(newsContentArray);

    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}

/**
 *  有些新闻页面的 URL 前缀不同，需要单独设置
 *
 */
+ (NSString *) correctNewsDetailUrl: (NSString *) url
{
    NSRange findRange = [url rangeOfString: @"http"];
    if (!findRange.length) {
        NSRange range = {0,1};
        url = [url stringByReplacingCharactersInRange:range withString: @""];
        NSString *baseUrlString = @"http://www.sxlib.org.cn";
        url = [baseUrlString stringByAppendingString: url];
    }
    return url;
}

/**
 *  去掉陕图讲坛板块新闻的前缀
 *
 */
+ (NSString *) correctNewsTitle: (NSString *) title
{
    NSRange range = [title rangeOfString: @"【陕图讲坛】"];
    if (range.length) {
        title = [title stringByReplacingCharactersInRange: range withString: @""];
    }
    return title;
}

#pragma mark - hot searching books

/**
 *  图书馆热门搜索书籍
 *
 */
+ (void) parseHotSearchingBookSuccess: (void(^)(NSMutableArray *hotSearchingBooks)) success
                              failure: (requestFailurerBlock) failure
{
    NSString *urlString = @"http://61.185.242.108/uhtbin/cgisirsi/0/%E9%99%95%E8%A5%BF%E7%9C%81%E9%A6%86/0/122/2002";
    
    [self requestWithUrl: urlString parameter: nil methodType:(requestMethodTypeGet) success:^(NSURLSessionDataTask *task, id responseObject) {
        
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        NSString *xpath = @"//td[@class='indented']";
        NSArray *nodes = [parse searchWithXPathQuery: xpath];
        
        NSMutableArray *names = [NSMutableArray new];
        if (nodes.count == 3) {
            TFHppleElement *element = nodes[0];
            NSArray *booksName = [element childrenWithTagName: @"a"];
            for (TFHppleElement *element in booksName) {
                NSArray *nodeContents = [element childrenWithTagName: @"text"];
                if (nodeContents.count == 1) {
                    NSString *bookName = [nodeContents[0] content];
                    [names addObject: bookName];
                }
            }
            success(names);
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task,error);
    }];
}


#pragma mark - search books

/**
 *  搜索图书馆书籍
 *
 *  @param urlSstring 网络地址
 *  @param dictionary post 请求参数
 */
+ (void) parseBooksListWithString: (NSString *) urlSstring
                       dictionary: (NSDictionary *) dictionary
                          success: (void(^)(searchBookState searchState, NSDictionary *searchBook)) success
                          failure: (requestFailurerBlock) failure

{
    [self requestWithUrl: urlSstring parameter: dictionary methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {
        
        TFHpple *booksParse = [TFHpple hppleWithHTMLData: responseObject];
        BOOL serverBusy;
        BOOL numberZero;
        BOOL numberOne;
        BOOL numberMore;
        
        //状态判断
        NSString *amountXpath = @"//div[@class='pagecontainer']/form[@method='post']/input[@name='last_hit']";
        NSArray *amountNodes = [booksParse searchWithXPathQuery: amountXpath];
        if (amountNodes.count > 0) {
            NSUInteger getValue = 0;
            getValue = [[(TFHppleElement*)amountNodes[0] objectForKey: @"value"] integerValue];
            
            serverBusy = NO;
            numberZero = NO;
            
            if (getValue == 1) {
                numberOne = YES;
                numberMore = NO;
            }else{
                numberMore = YES;
                numberOne = NO;
            }
        }else{
            numberOne = NO;
            numberMore = NO;
            
            NSString *serverXpath = @"//p/strong";
            NSArray *serverNodes = [booksParse searchWithXPathQuery: serverXpath];
            if (serverNodes.count == 1) {
                NSString *serverErrorString = [(TFHppleElement*)serverNodes[0] text];
                NSString *compareString = @"The OPAC is currently unavailable.  Please try again later.";
                if ([serverErrorString isEqualToString: compareString]) {
                    serverBusy = YES;
                    numberZero = NO;
                }else{
                    serverBusy = NO;
                    numberZero = YES;
                }
            }
        }
        
        //根据不同状态赋值
        if (serverBusy) {
            success(searchBookStateServeBusy, nil);
        }
        if (numberZero) {
            [self booksNumberIsZero: booksParse recommendedBooks:^(NSDictionary *recommendedBooks) {
                success(searchBookStateZero, recommendedBooks);
            }];
        }
        if (numberOne) {
            [self booksNumberIsOne: booksParse bookContent:^(NSDictionary *bookContent) {
                success(searchBookStateOne, bookContent);
            }];
        }
        if (numberMore) {
            [self booksNumberIsMore: booksParse booklist:^(NSDictionary *booklist) {
                success(searchBookStateMore, booklist);
            }];
        }
        
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
        
    }];
}

/**
 *  图书馆搜索结果为零
 *
 *  @param recommendedBooks 搜索结果为零时，获取推荐的书籍。
 */
+ (void) booksNumberIsZero: (TFHpple *) booksParse
          recommendedBooks: (void(^)(NSDictionary *recommendedBooks)) recommendedBooks
{
    NSString *xpath = @"//table[@cellpadding='3']//tr";
    NSArray *nodes = [booksParse searchWithXPathQuery: xpath];
    NSMutableArray *booksArray = [NSMutableArray new];
    NSDictionary *suggestedBooks = [NSDictionary new];
    
    for (TFHppleElement *element in nodes) {
        TFHpple *suggestedBook = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
        NSString *suggestedBookXpath = @"//a|//strong";
        NSArray *suggestedBookNodes = [suggestedBook searchWithXPathQuery: suggestedBookXpath];
        if (suggestedBookNodes.count == 2) {
            NSString *name = [(TFHppleElement*)suggestedBookNodes[0] text];
            NSString *url = [(TFHppleElement*)suggestedBookNodes[0] objectForKey: @"href"];
            NSString *number = [(TFHppleElement*)suggestedBookNodes[1] text];
            
            RecommendedBookModel *books = [RecommendedBookModel initWithName: name urlString: url numberString: number];
            [booksArray addObject: books];
        }
    }
    suggestedBooks = @{@"suggestedBooks": booksArray};
    recommendedBooks(suggestedBooks);
}

/**
 *  图书馆搜索结果为 1，直接跳转到图书详情页面。
 *
 *  @param bookContent 图书详细信息。
 */
+ (void) booksNumberIsOne: (TFHpple *) booksParse
              bookContent: (void(^)(NSDictionary *bookContent)) bookContent
{
    NSMutableArray *bookRightInfoArray = [NSMutableArray new];
    NSMutableArray *bookLocationArray = [NSMutableArray new];
    NSMutableArray *bookSummaryArray = [NSMutableArray new];
    NSDictionary *bookTotalInfo = [NSDictionary new];
    
    //作者名称
    NSString *authorXpath = @"//div[@id='panel1']//strong";
    NSArray *authorNodes = [booksParse searchWithXPathQuery: authorXpath];
    if (authorNodes.count == 1) {
       NSString *bookAuthor = [authorNodes[0] text];
        [bookRightInfoArray addObject: bookAuthor];
    }

    //图书右栏详细信息
    NSString *xpath = @"//div[@id='panel3']//tr";
    NSArray *nodes = [booksParse searchWithXPathQuery: xpath];
    for (TFHppleElement *element in nodes) {
        TFHpple *book = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
        NSArray *rightNodes = [book searchWithXPathQuery: @"//th/text()|//td"];
        if (rightNodes.count == 3) {
            NSString *bookRightKey = [rightNodes[1] content];
            NSString *bookRightValue = [rightNodes[2] text];
            
            //删除多余空格和回车
            bookRightKey = [Helper deleteSpaceAndCR: bookRightKey];
            bookRightValue = [Helper deleteSpaceAndCR: bookRightValue];
            
            //选择出版信息，稽核项，概要
            NSArray *detailArray = @[@"出版信息", @"稽核项", @"概要"];
            NSUInteger detailIndex = [detailArray indexOfObject: bookRightKey];
            if (detailIndex == 0 || detailIndex == 1) {
                [bookRightInfoArray addObject: bookRightValue];
            }
            if (detailIndex == 2) {
                [bookSummaryArray addObject: bookRightValue];
            }
        }
    }
    
    //ISBN
    NSString *isbnMainXpath = @"//div[@class='bibinfo2']//tr";
    NSArray *isbnMainNodes = [booksParse searchWithXPathQuery: isbnMainXpath];
    NSUInteger nodeCount = isbnMainNodes.count;
    if (nodeCount == 2 || nodeCount == 3) {
        NSString *isbnXpath = [NSString stringWithFormat: @"//div[@class='bibinfo2']//tr[%lu]/th|//div[@class='bibinfo2']//tr[%lu]/td", nodeCount - 1, nodeCount - 1];
        NSArray *isbnNodes = [booksParse searchWithXPathQuery: isbnXpath];
        if (isbnNodes.count == 2) {
            NSString *isbnNumber = [isbnNodes[1] text];
            if (isbnNumber) {
                isbnNumber = [@"ISBN: " stringByAppendingString: isbnNumber];
            }
            [bookRightInfoArray addObject: isbnNumber];
        }
    }
    
    //图书馆藏信息
    NSString *bookLocationXpath = @"//div[@id='panel1']/table//tr";
    NSArray *bookLocationNodes = [booksParse searchWithXPathQuery: bookLocationXpath];
    for (TFHppleElement *element in bookLocationNodes) {
        
        TFHpple *location = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
        NSArray *locationNodes = [location searchWithXPathQuery: @"//td[@class='holdingslist']|//td[@class='holdingslist']/script/text()"];
        NSUInteger count = locationNodes.count;
        
        //正常情况是4，有些书籍的借阅号在 HTML 中显示了2次
        if (count == 4 || count == 5) {
            NSString *callNumber = [locationNodes[0] text];
            
//            NSString *bookCallNumber = [locationNodes[0] text];
            NSString *bookNumber = [locationNodes[1] text];
            NSString *bookType = [locationNodes[2] text];
            NSString *bookLocation;
            NSString *combineString;
            
            NSAttributedString *bookCallNumber = [[NSAttributedString alloc] initWithString: callNumber attributes: @{NSForegroundColorAttributeName: [Helper setColorWithRed:0 green:175 blue:240]}];
            
            bookNumber = [Helper addSpace: bookNumber withNumber: 1];
            bookType = [Helper deleteSpaceAndCR: bookType];
            bookType = [Helper addSpace: bookType withNumber: 1];
            
            if (bookCallNumber.length > 2) {
                [bookLocationArray addObject: bookCallNumber];
            }
            if (count == 4) {
                bookLocation = [locationNodes[count - 1] text];
            }else {
                bookLocation = [locationNodes[count - 1] content];
                bookLocation = [self correctLocationString: bookLocation];
            }
            bookLocation = [Helper deleteSpaceAndCR: bookLocation];
            combineString = [bookType stringByAppendingString: bookLocation];
            if (combineString.length > 1) {
               [bookLocationArray addObject: combineString];
            }
            
        }
    }
    
    bookTotalInfo = @{@"bookRightInfo": bookRightInfoArray,
                      @"bookLocation": bookLocationArray,
                      @"bookSummary": bookSummaryArray};
    
    
    bookContent(bookTotalInfo);
}

/**
 *  图书搜索结果有多个。
 *
 *  @param booklist   多个图书列表
 */
+ (void) booksNumberIsMore: (TFHpple *) booksParse
              booklist: (void(^)(NSDictionary *booklist)) booklist
{
    NSString *nextPageAddress;
    NSString *totalNumberString;
    NSMutableArray *booklistArray = [NSMutableArray new];
    NSString *firstHitNumber;
    NSString *lastHitNumber;
    NSDictionary *booklistDic = [NSDictionary new];
    
    //翻页和书籍详情URL
    NSString *newAddressXpath = @"//form[@name='hitlist']";
    NSArray *newAddressNodes = [booksParse searchWithXPathQuery: newAddressXpath];
    if (newAddressNodes.count) {
        nextPageAddress = [newAddressNodes[0] objectForKey: @"action"];
    }
    
    //书籍总数
    NSString *seachTotalNumberXpath = @"//p[@class='searchsum']/em";
    NSArray *searchTotalNumbetNodes = [booksParse searchWithXPathQuery: seachTotalNumberXpath];
    if (searchTotalNumbetNodes.count) {
        totalNumberString = [searchTotalNumbetNodes[0] text];
    }
    
    //书籍信息
    NSString *xpathString = @"//td[@valign='top'and@class='searchsum']/table[@cellpadding='3']";
    NSArray *nodes = [booksParse searchWithXPathQuery: xpathString];
    for (TFHppleElement *element in nodes) {
        TFHpple *book = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
        NSArray *bookNodes = [book searchWithXPathQuery: @"//strong|//p"];
        
        //搜 朝花夕拾 的时候发现最后一本书没有出版日期，所以添加节点为4的情况。
        if (bookNodes.count == 5 || bookNodes.count == 4) {
            NSString *number;
            NSString *callNumber;
            NSString *publicationDate;
            NSString *authorAndTitle;
            NSString *libraryHoldings;
            if (bookNodes.count == 5) {
                number = [bookNodes[0] text];
                callNumber = [bookNodes[1] text];
                publicationDate = [bookNodes[2] text];
                authorAndTitle = [bookNodes[3] text];
                libraryHoldings = [bookNodes[4] text];
            }else{
                number = [bookNodes[0] text];
                callNumber = [bookNodes[1] text];
//                publicationDate = [bookNodes[2] text];
                authorAndTitle = [bookNodes[2] text];
                libraryHoldings = [bookNodes[3] text];
            }
        
            number = [number stringByReplacingOccurrencesOfString: @"#" withString: @""];
            libraryHoldings = [Helper deleteSpaceAndCR: libraryHoldings];
            libraryHoldings = [libraryHoldings stringByReplacingOccurrencesOfString: @"\n" withString: @""];
            libraryHoldings = [libraryHoldings stringByReplacingOccurrencesOfString: @"   " withString: @""];
            libraryHoldings = [libraryHoldings stringByReplacingOccurrencesOfString: @"\t \t\t" withString: @""];
            
            BookListModel *books = [BookListModel initWithNumber: number callNumber: callNumber publicationDate: publicationDate authorAndTitle: authorAndTitle libraryHoldings: libraryHoldings];
            [booklistArray addObject: books];
        }
    }
    
    //翻页序号
    NSUInteger count = booklistArray.count;
    if (count) {
        firstHitNumber = [booklistArray[0] number];
        lastHitNumber = [booklistArray[count - 1] number];
    }
    
    booklistDic = @{@"nextPageAddress": nextPageAddress,
                    @"totalNumberString": totalNumberString,
                    @"booklistArray": booklistArray,
                    @"firstHitNumber": firstHitNumber,
                    @"lastHitNumber": lastHitNumber};
    booklist(booklistDic);
}

/**
 *  修正图书馆藏地址
 *
 */
+ (NSString *) correctLocationString: (NSString *) string
{
    NSRange rangeOne = [string rangeOfString:@"'"];
    string = [string substringFromIndex: rangeOne.location+1];
    NSRange rangeTwo = [string rangeOfString:@"'"];
    string = [string substringWithRange:NSMakeRange(0, rangeTwo.location)];
    return string;
}

/**
 *  图书搜索结果有多个，查看下一页图书。
 *
 */
+ (void) booksNumberIsMoreNextPage: (NSString *) urlString
                         parameter: (NSDictionary *) parameter
                          success: (void(^)(NSDictionary *booklist)) success
                           failure: (requestFailurerBlock) failure
{
    [self requestWithUrl: urlString
               parameter: parameter
              methodType:(requestMethodTypePost)
                 success:^(NSURLSessionDataTask *task, id responseObject) {
        TFHpple *booksParse = [TFHpple hppleWithHTMLData: responseObject];
        [self booksNumberIsMore: booksParse booklist:^(NSDictionary *booklist) {
            success(booklist);
        }];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}

/**
 *  图书搜索结果为多个时，点击图书列表时，获取图书详细内容。
 *
 */
+ (void) booksNumberIsOneNextPage: (NSString *) urlString
                        parameter: (NSDictionary *) parameter
                          success: (void(^)(NSDictionary *bookContent)) success
                          failure: (requestFailurerBlock) failure
{
    
    [self requestWithUrl: urlString
               parameter: parameter
              methodType: requestMethodTypePost
                 success:^(NSURLSessionDataTask *task, id responseObject) {
                     TFHpple *booksParse = [TFHpple hppleWithHTMLData: responseObject];
                     [self booksNumberIsOne: booksParse bookContent:^(NSDictionary *bookContent) {
                         success(bookContent);
                     }];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}


#pragma mark  - bookContent from Douban
/**
 *  获取图书在豆瓣的信息
 *
 */
+ (void) bookContentFromDouban: (NSString *) urlString
                       success: (void(^)(DoubanBookModel *book)) success
                       failure: (requestFailurerBlock) failure
{
    [Helper setNetworkIndicator: YES];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setTimeoutInterval: 20];
    [AFJSONResponseSerializer serializer].removesKeysWithNullValues = YES;
    [manager GET: urlString parameters: nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [Helper setNetworkIndicator: NO];
        NSDictionary *bookDic;
        if ([responseObject[@"books"] count]) {
            bookDic = [NSDictionary dictionaryWithDictionary: [responseObject[@"books"] objectAtIndex: 0]];
        }else{
            bookDic = [NSDictionary dictionaryWithDictionary: responseObject];
        }
        
        DoubanBookModel *bookModel = [DoubanBookModel new];
        bookModel.title = bookDic[@"title"];
        bookModel.originalTitle = bookDic[@"origin_title"];
        bookModel.publisher = bookDic[@"publisher"];
        bookModel.pubdate = bookDic[@"pubdate"];
        bookModel.pages = bookDic[@"pages"];
        bookModel.price = bookDic[@"price"];
        bookModel.binding = bookDic[@"binding"];
        bookModel.idString = bookDic[@"id"];
        bookModel.authorIntro = bookDic[@"author_intro"];
        bookModel.catalog = bookDic[@"catalog"];
        bookModel.summary = bookDic[@"summary"];
        bookModel.rating = [bookDic[@"rating"] objectForKey: @"average"];
        
        bookModel.catalog = [Helper deleteSpaceAndCR: bookModel.catalog];
        
        if ([bookDic[@"author"] count]) {
          bookModel.author  = bookDic[@"author"][0];
        }
        NSString *image = bookDic[@"image"];
        NSDictionary *images = bookDic[@"images"];
        if (images[@"large"]) {
            bookModel.imageString = images[@"large"];
        }else if (image){
            bookModel.imageString = image;
        }
        success(bookModel);
        
     } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         [Helper setNetworkIndicator: NO];
         failure(task, error);
    }];
   
}

# pragma mark - bookTags

/**
 *  豆瓣热门标签，获取来之后保存到了 plist 文件中。以后不再调用该方法。
 */
+ (void) bookTags: (NSString *) urlString
         successs: (void(^)(NSMutableArray *tagsArray)) success
          failure: (requestFailurerBlock) failure
{
    NSMutableArray *totalTagsArray = [NSMutableArray new];
    
    
    [self requestWithUrl: urlString parameter: nil methodType: requestMethodTypeGet success:^(NSURLSessionDataTask *task, id responseObject) {
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        NSArray *nodes = [parse searchWithXPathQuery: @"//table[@class='tagCol']/tbody"];
        for (TFHppleElement *element in nodes) {
            TFHpple *tagParse = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
            NSArray *tagNodes = [tagParse searchWithXPathQuery: @"//a[@class='tag']"];
            NSMutableArray *tags = [NSMutableArray new];
            for (TFHppleElement *tag in tagNodes) {
               
                NSString *tagName = [tag.children[0] content];
                [tags addObject: tagName];
            }
            [totalTagsArray addObject: tags];
        }
        success(totalTagsArray);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}

# pragma mark - searching Content with tag

/**
 *  用标签在豆瓣图书中搜索内容
 *
 */
+ (void) searchBookWithTagInUrl: (NSString *) urlString
                       parameter: (NSDictionary *) parameter
                       successs: (void(^)(NSMutableArray *bookArray, NSArray *tagsRecommended)) success
                        failure: (requestFailurerBlock) failure
{
    NSMutableArray *bookArray = [NSMutableArray new];
    NSMutableArray *tagsArray = [NSMutableArray new];
    
    [self requestWithUrl: urlString parameter: parameter methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {

        NSString *htmlString = [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding];
        if (!htmlString) {
            responseObject = [Helper UTF8Data: responseObject];
        }
        [self searchBookInData: responseObject addInArray: bookArray tags: tagsArray];
        success(bookArray, [tagsArray copy]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}

/**
 *  解析标签搜索内容网页
 *
 */
+ (void) searchBookInData: (NSData *) responseObject
               addInArray: (NSMutableArray *) bookArray
                     tags: (NSMutableArray *) tagsArray
{
    TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
    NSArray *nodes = [parse searchWithXPathQuery: @"//li[@class='subject-item']"];
    NSArray *tagNodes = [parse searchWithXPathQuery: @"//div[@class='tags-list']/a"];
    
    
    if (nodes.count) {
        
        for (TFHppleElement *element in nodes) {
            TFHpple *bookParse = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
            NSString *xpath = @"//img|//h2/a|//div[@class='pub']|//span[@class='pl']";
            NSArray *bookNodes = [bookParse searchWithXPathQuery: xpath];
            NSArray *ratingNodes = [bookParse searchWithXPathQuery: @"//span[@class='rating_nums']|//p"];
       
            DoubanBookModel *bookModel = [DoubanBookModel new];
            [self configureBookContent: bookNodes ratingArray: ratingNodes withModel:bookModel];
            [bookArray addObject: bookModel];
        }
        
        if (tagNodes.count) {
            for (TFHppleElement *element in tagNodes) {
                [tagsArray addObject: [[[element childrenWithTagName: @"text"] firstObject] content]];
            }
        }
    }
    
    
}

/**
 *  整理标签搜索内容
 *
 */
+ (void) configureBookContent: (NSArray *) bookNodes
                  ratingArray: (NSArray *) ratingNodes
             withModel: (DoubanBookModel *) bookModel
{
    // 书籍详细信息
    NSUInteger bookCount = bookNodes.count;
    if (bookCount == 4) {
        bookModel.imageString = [bookNodes[0] objectForKey: @"src"];
        bookModel.imageString = [bookModel.imageString stringByReplacingOccurrencesOfString: @"mpic" withString: @"lpic"];
        bookModel.title = [bookNodes[1] objectForKey: @"title"];
        bookModel.rating = [Helper deleteSpaceAndCR: [bookNodes[3] text]];
        NSString *bookIdString = [bookNodes[1] objectForKey: @"href"];
        bookModel.idString = [self bookIdString: bookIdString];

        NSString *basicInfo = [bookNodes[2] text];
        basicInfo = [Helper deleteSpaceAndCR: basicInfo];
        NSArray *basicInfoArray = [basicInfo componentsSeparatedByString: @"/"];
        NSUInteger index = basicInfoArray.count;
        if (index == 4 || index >= 5) {
            if (index == 4) {
                bookModel.author = basicInfoArray[0];
            }else{
                NSString *translator = [Helper deleteSpaceAndCR: basicInfoArray[1]];
                bookModel.author = [basicInfoArray[0] stringByAppendingFormat: @"(%@)", translator];
            }
            bookModel.publisher = basicInfoArray[index - 3];
            bookModel.publisher = [Helper deleteSpaceAndCR: bookModel.publisher];
            bookModel.pubdate = basicInfoArray[index - 2];
            bookModel.pubdate = [Helper deleteSpaceAndCR: bookModel.pubdate];
            bookModel.price = basicInfoArray[index - 1];
        }
    }
    
//    NSLog(@"%@", bookModel.title);
    // 评分信息
    NSUInteger ratingCount = ratingNodes.count;
    if (ratingCount == 1) {
        if ([[ratingNodes[0] text] length] > 5) {
            bookModel.summary = [ratingNodes[0] text];
        }else{
            bookModel.rating = [[ratingNodes[0] text] stringByAppendingString: bookModel.rating];
        }
    }else if (ratingCount == 2){
        bookModel.rating = [[ratingNodes[0] text] stringByAppendingString: bookModel.rating];
        bookModel.summary = [ratingNodes[1] text];
    }
    bookModel.summary = [Helper deleteSpaceAndCR: bookModel.summary];
}


//获取书籍 ID
+ (NSString *) bookIdString: (NSString *) string
{
    if (string) {
//        string = [string stringByReplacingOccurrencesOfString: @"https://book.douban.com/subject/" withString:@""];
//        string = [string stringByReplacingOccurrencesOfString:@"/" withString:@""];
        string = [NSString stringWithFormat: @"%lu", [Helper regexFindNumberInString: string]];
    }
    return string;
}



# pragma mark - Amazon book

/**
 *  亚马逊图书榜单
 *
 */
+ (void) amazonBooksWithUrl: (NSString *) urlString
                  parameter: (NSDictionary *) parameter
                   successs: (void(^)(NSMutableArray *amazonBookArray, NSUInteger pageNumber)) success
                    failure: (requestFailurerBlock) failure
{
    [self requestWithUrl: urlString parameter: parameter methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *bookArray = [NSMutableArray new];
        NSUInteger pageCount = 0;
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        
        //总页码数
        NSArray *pageNodes = [parse searchWithXPathQuery: @"//li[@class='zg_page']"];
        pageCount = pageNodes.count + 1;
        
        //书籍列表,有些书没有评分，所以把评分这一项单独来写
        NSArray *nodes = [parse searchWithXPathQuery: @"//div[@class='zg_item_normal']"];
        for (TFHppleElement *element in nodes) {
            TFHpple *bookParse = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
            NSString *xpath = @"//img|//div[@class='zg_byline']|//div[@class='zg_bindingPlatform']|//strong[@class='price']";
            NSArray *bookNodes = [bookParse searchWithXPathQuery: xpath];
            DoubanBookModel *bookModel = [DoubanBookModel new];
            if (bookNodes.count == 4) {
                bookModel.imageString = [bookNodes[0] objectForKey: @"src"];
                bookModel.title = [bookNodes[0] objectForKey: @"title"];
                bookModel.author = [[Helper deleteSpaceAndCR: [bookNodes[1] text]] stringByReplacingOccurrencesOfString: @"~" withString: @""];
//                bookModel.rating = [bookNodes[2] text];
                bookModel.binding = [bookNodes[2] text];
                bookModel.price = [bookNodes[3] text];
                
                [self bookshortTitle: bookModel];
                
            }
            
            NSArray *ratingNodes = [bookParse searchWithXPathQuery: @"//span[@class='a-icon-alt']"];
            if (ratingNodes.count) {
                bookModel.rating = [ratingNodes[0] text];
            }
            
//            NSLog(@"%@", bookModel.shortTitle);
            [bookArray addObject: bookModel];
        }
        success(bookArray, pageCount);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}


# pragma mark - JDBook


/**
 *  京东图书榜单
 *
 */
+ (void) JDBooksWithUrl: (NSString *) urlString
               successs: (void(^)(NSMutableArray *JDBookArray, NSUInteger pageNumber)) success
                failure: (requestFailurerBlock) failure
{
    [self requestWithUrl: urlString parameter: nil methodType: requestMethodTypeGet
                 success:^(NSURLSessionDataTask *task, id responseObject) {
                     
        NSMutableArray *bookArray = [NSMutableArray new];
        NSUInteger pageCount = 0;

        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        NSArray *nodes = [parse searchWithXPathQuery: @"//ul[@class='clearfix']/li"];
        for (TFHppleElement *element in nodes) {
            
            TFHpple *bookParse = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
            NSString *xpath = @"//img|//div[@class='p-detail']/a|//div[@class='p-detail']/dl[2]/dd/a";
            NSArray *bookNodes = [bookParse searchWithXPathQuery: xpath];
            NSArray *titleNodes = [bookParse searchWithXPathQuery: @"//div[@class='p-detail']/dl[1]/dd//text()"];
            DoubanBookModel *bookModel = [DoubanBookModel new];
            
            // 封面图片，书名，出版社，
            if (bookNodes.count == 3) {
                
                //可以把图片链接中的 n3 换为 n1 则为高清图片
                bookModel.imageString = [bookNodes[0] objectForKey: @"data-lazy-img"];
                bookModel.title = [bookNodes[1] text];
                bookModel.publisher = [bookNodes[2] text];
                
                if (bookModel.imageString) {
                    bookModel.imageString = [bookModel.imageString stringByReplacingOccurrencesOfString: @"n3" withString: @"n1"];
                    bookModel.imageString = [@"http:" stringByAppendingPathComponent: bookModel.imageString];
                }
                
                [self bookshortTitle: bookModel];
            }
            
            //拼接作者和翻译者
            __block NSMutableString *titleString;
            if (titleNodes.count) {
                [titleNodes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSString *subTitle = [Helper deleteSpaceAndCR: [obj content]];
                    if ([subTitle isEqualToString: @"著"]) {
                        subTitle = @" 著 ";
                    }
                    if ([subTitle isEqualToString: @"译"]) {
                        subTitle = @" 译 ";
                    }
                    if (subTitle) {
                        if (idx == 0) {
                            titleString = [subTitle mutableCopy];
                        }else{
                            [titleString appendString: subTitle];
                        }
                    }
                }];
                bookModel.author = [titleString mutableCopy];
            }
            [bookArray addObject: bookModel];
        }
        
        success(bookArray, pageCount);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}


# pragma mark - DDBook

/**
 *  当当图书榜单
 *
 */
+ (void) DDBooksWithUrl: (NSString *) urlString
               successs: (void(^)(NSMutableArray *DDBookArray, NSUInteger pageNumber)) success
                failure: (requestFailurerBlock) failure
{
    [self requestWithUrl: urlString parameter: nil methodType: requestMethodTypeGet success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *bookArray = [NSMutableArray new];
        NSUInteger pageCount = 0;
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        NSArray *nodes = [parse searchWithXPathQuery: @"//ul[@class='bang_list clearfix bang_list_mode']/li"];
        for (TFHppleElement *element in nodes) {
            TFHpple *bookParse = [TFHpple hppleWithHTMLData: [element.raw dataUsingEncoding: NSUTF8StringEncoding]];
            NSString *xpath = @"//div[@class='pic']//img|//div[@class='publisher_info']//a[1]|//span[@class='price_n'][1]";
            NSArray *bookNodes = [bookParse searchWithXPathQuery: xpath];
            
            DoubanBookModel *bookModel = [DoubanBookModel new];
            if (bookNodes.count >= 4) {
                bookModel.imageString = [bookNodes[0] objectForKey: @"src"];
                bookModel.title = [bookNodes[0] objectForKey: @"title"];
                bookModel.author = [bookNodes[1] objectForKey: @"title"];
                bookModel.publisher = [bookNodes[2] text];
                bookModel.price = [bookNodes[3] text];
                
                [self bookshortTitle: bookModel];
                
                [bookArray addObject: bookModel];
            }
        }
        success(bookArray, pageCount);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}

// 截取书籍的短标题，方便搜索
+ (void) bookshortTitle: (DoubanBookModel *) bookModel
{
    // 标题中会出现中文括号或英文括号
    bookModel.title = [Helper deleteSpaceAndCR: bookModel.title];
    NSRange rangeA = [bookModel.title rangeOfString: @"（"];
    NSRange rangeB = [bookModel.title rangeOfString: @"("];
    if (rangeA.length || rangeB.length) {
        NSRange range;
        if (rangeA.length) {
            range = rangeA;
        }else if (rangeB.length){
            range = rangeB;
        }
        bookModel.shortTitle = [bookModel.title substringToIndex: range.location];
       
    }else{
        bookModel.shortTitle = bookModel.title;
    }
//     NSLog(@"%@", bookModel.shortTitle);
}


// 西工大图书馆、长安大学图书馆
+ (void) bookListInNPULibraryWithUrl: (NSString *) urlString
                           parameter: (NSDictionary *) parameter
                             success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                             failure: (requestFailurerBlock) failure
{
    NSMutableArray *bookListArray = [NSMutableArray new];
    __block NSString *numberString;
    [self requestWithUrl: urlString parameter: parameter methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        
        // 搜索总数
        NSArray *totalNodes = [parse searchWithXPathQuery: @"//strong[@class='red']"];
        if (totalNodes.count) {
            numberString = [totalNodes[0] text];
        }
        
        // 图书信息
        NSString *xpath = @"//ol[@id='search_book_list']/li[@class='book_list_info']";
        NSArray *nodes = [parse searchWithXPathQuery: xpath];
        for (TFHppleElement *element in nodes) {
            
            NSData *listData = [NSData dataWithData: [[element raw] dataUsingEncoding: NSUTF8StringEncoding]];
            TFHpple *listParse = [TFHpple hppleWithHTMLData: listData];
            NSString *listXpath = @"//text()";
            NSArray *listNodes = [listParse searchWithXPathQuery: listXpath];

            if (listNodes.count == 17) {
                
                BookListModel *book = [BookListModel new];
                
                // 标题和序号
                NSString *title = [Helper deleteSpaceAndCR: [listNodes[2] content]];
                NSRange range = [title rangeOfString: @"."];
                NSString *numberString;
                if (range.length) {
                    numberString = [title substringToIndex: range.location];
                    title = [title substringFromIndex: range.location+1];
                }
                book.number = numberString;
                book.authorAndTitle = title;
                
                // 作者和出版社
                NSString *author = [Helper deleteSpaceAndCR: [listNodes[8] content]];
                NSString *publisher = [Helper deleteSpaceAndCR: [listNodes[9] content]];
                if (publisher) {
                    book.publicationDate = [author stringByAppendingPathComponent: publisher];
                }
                
                // 借阅号
                book.callNumber = [Helper deleteSpaceAndCR: [listNodes[3] content]];
                
                // 馆藏
                NSString *holding = [listNodes[6] content];
                NSString *loanable = [listNodes[7] content];
                holding = [Helper deleteSpaceAndCR: holding];
                loanable = [Helper deleteSpaceAndCR: loanable];
                if (loanable) {
                    holding = [holding stringByAppendingString: @" "];
                    book.libraryHoldings = [holding stringByAppendingString: loanable];
                }
                // 详细信息 URL
                NSArray *detailStrings = [listParse searchWithXPathQuery: @"//p/a"];
                if (detailStrings.count) {
                    book.detailNumString = [detailStrings[0] objectForKey: @"href"];
                    book.detailNumString = [urlString stringByAppendingPathComponent: book.detailNumString];
                }
                [bookListArray addObject: book];

//                NSLog(@"%@\n%@\n%@\n%@\n", book.authorAndTitle, book.publicationDate, book.callNumber, book.libraryHoldings);
            }
        }
        success(bookListArray, numberString);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
    
}


// 西电图书馆、陕西师范图书馆
+ (void) bookListInXidianLibraryWithUrl: (NSString *) urlString
                           parameter: (NSDictionary *) parameter
                             success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                             failure: (requestFailurerBlock) failure
{
    NSMutableArray *bookListArray = [NSMutableArray new];
    __block NSString *numberString;
    [self requestWithUrl: urlString parameter: parameter methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSString *html = [[NSString alloc] initWithData: responseObject encoding: NSUTF8StringEncoding];
//        wangLogObject(html);
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        
        
        // 搜索总数,总数在原网页中夹在多个文字中间，通过两次取 substring 来获取总数。
        NSArray *totalNodes = [parse searchWithXPathQuery: @"//div[@id='hitnum']/text()"];
        if (totalNodes.count == 2) {
            numberString = [totalNodes[1] content];
            NSRange range = [numberString rangeOfString: @"of"];
            if (range.length) {
                numberString = [numberString substringFromIndex: range.location+range.length];
                NSRange newRange = [numberString rangeOfString: @"("];
                if (newRange.length) {
                    numberString = [numberString substringToIndex: newRange.location];
                    numberString = [Helper deleteSpaceAndCR: numberString];
                }
            }
        }
        

        // 图书详情
        NSString *xPath = @"//table[@class='items']";
        NSArray *nodes = [parse searchWithXPathQuery: xPath];
        for (TFHppleElement *element in nodes) {
            
            NSData *listData = [NSData dataWithData: [[element raw] dataUsingEncoding: NSUTF8StringEncoding]];
            TFHpple *listParse = [TFHpple hppleWithHTMLData: listData];
            
            BookListModel *book = [BookListModel new];
            //编号
            NSArray *numberNodes = [listParse searchWithXPathQuery: @"//td[@class='col1']/a"];
            if (numberNodes.count) {
                book.number = [Helper deleteSpaceAndCR: [numberNodes[0] text]];
               
            }
            
            // 书名
            NSArray *titleNodes = [listParse searchWithXPathQuery: @"//td[@class='col2']/div[@class='itemtitle']/a//text()"];
            if (titleNodes.count) {
                book.authorAndTitle = [Helper deleteSpaceAndCR: [titleNodes[0] content]];
            }
            
            //其他信息(作者等)
            NSArray *contentNodes = [listParse searchWithXPathQuery: @"//td[@class='col2']//td[@class='content'and@valign='top']"];
            
            if (contentNodes.count == 5) {
                NSString *author = [contentNodes[0] text];
                NSString *publisher = [contentNodes[2] text];
                NSString *pubdate = [contentNodes[3] text];
                book.callNumber = [Helper deleteSpaceAndCR: [contentNodes[1] text]];

                if (pubdate && publisher) {
                    book.publicationDate = [[author stringByAppendingString: publisher] stringByAppendingString: pubdate];
                    book.publicationDate = [Helper deleteSpaceAndCR: book.publicationDate];
                   }
            }
            
            // 借阅信息
            NSArray *holdingNodes = [listParse searchWithXPathQuery: @"//a"];
//            wangLogObject(holdingNodes);
//            wangLogValue(holdingNodes.count);
            NSUInteger count = holdingNodes.count;
            if (count == 5 || count == 4) {
                // 借阅信息
                NSString *holding = [[holdingNodes[count-1] firstChild] content];
                
                holding = [holding stringByReplacingOccurrencesOfString: @"     " withString: @""];
                book.libraryHoldings = holding;
                
                // 借阅详情页面 URL
                book.detailNumString = [holdingNodes[count-1] objectForKey: @"href"];
                
//                wangLogObject(book.libraryHoldings);
//                wangLogObject(book.detailNumString);
            }
            
            [bookListArray addObject: book];
        }
        success(bookListArray, numberString);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
}


// 西安理工大学图书馆
+ (void) bookListInXAUTLibraryWithUrl: (NSString *) urlString
                              parameter: (NSDictionary *) parameter
                                success: (void(^)(NSMutableArray *bookArray, NSString *totalNumberString)) success
                                failure: (requestFailurerBlock) failure
{
    [self requestWithUrl: urlString parameter: parameter methodType: requestMethodTypePost success:^(NSURLSessionDataTask *task, id responseObject) {
        
        NSMutableArray *bookListArray = [NSMutableArray new];
        __block NSString *numberString;
        
        TFHpple *parse = [TFHpple hppleWithHTMLData: responseObject];
        // 书籍总数
        NSArray *totalNodes = [parse searchWithXPathQuery: @"//div[@class='account']"];
        if (totalNodes.count) {
            numberString = [[totalNodes[0] firstChild] content];
        }
        
        
        // 书籍详细信息
        NSArray *nodes = [parse searchWithXPathQuery: @"//ul[@class='list']/li"];
        for (TFHppleElement *element in nodes) {
            
            BookListModel *book = [BookListModel new];
            NSData *listData = [NSData dataWithData: [[element raw] dataUsingEncoding: NSUTF8StringEncoding]];
            TFHpple *listParse = [TFHpple hppleWithHTMLData: listData];
            NSString *listXpath = @"//span/text() | //p/text() | //p | //a |//font";
            NSArray *listNodes = [listParse searchWithXPathQuery: listXpath];
            
            if (listNodes.count == 10) {
                
                // 图书详细信息 URL
                NSString *prefix = @"http://202.200.117.15:8081";
                NSString *detail = [listNodes[0] objectForKey: @"href"];
                if (detail.length) {
                  book.detailNumString = [prefix stringByAppendingString: detail];
                }
                
                // 编号
                NSString *titlePrefix;
                NSString *serial = [listNodes[1] content];
                NSRange range = [serial rangeOfString: @"."];
                if (range.length) {
                    book.number = [serial substringToIndex: range.location];
                    titlePrefix = [serial substringFromIndex: range.location + 1];
                }
                
                // 题名
                NSString *title = [[listNodes[2] text] stringByAppendingString: [listNodes[3] content]];
                if (titlePrefix.length) {
                    book.authorAndTitle = [titlePrefix stringByAppendingString: title];
                }else{
                    book.authorAndTitle = title;
                }
                
                
                // 出版社
                NSString *publisher = [listNodes[5] content];
                publisher = [publisher stringByReplacingOccurrencesOfString: @"\n" withString: @""];
                publisher = [publisher stringByReplacingOccurrencesOfString: @"           " withString: @""];
                book.publicationDate = [Helper deleteSpaceAndCR: publisher];
                
                // 馆藏
                NSString *holding = [listNodes[7] content];
                holding = [holding stringByReplacingOccurrencesOfString: @"          " withString: @""];
                holding = [holding stringByReplacingOccurrencesOfString: @"\n" withString: @""];
                book.libraryHoldings = [Helper deleteSpaceAndCR: holding];
                
                // 借阅信息
                NSString *callNumber = [listNodes[9] content];
                book.callNumber = [Helper deleteSpaceAndCR: callNumber];
//                wangLogObject([book description]);
                [bookListArray addObject: book];
            }
            
        }
        
        success(bookListArray, numberString);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(task, error);
    }];
    
}



@end
