//
//  BookTagContentViewController.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/2/27.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, tagContentType) {
    tagContentTypeDouban = 1,
    tagContentTypeNonDouban,
};

@interface BookTagContentViewController : UIViewController

- (instancetype) initWithSearchWords: (NSString *) searchWords
                         contentType: (tagContentType) bookContenType;

@end
