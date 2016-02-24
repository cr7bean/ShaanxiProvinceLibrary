//
//  BookTagListViewController.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/1/18.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, contentType){
    contentTypeDoubanTag = 1,
    contentTypeAmazon,
    contentTypeJD,
    contentTypeDD,
};


@interface BookTagListViewController : UIViewController

- (instancetype) initWithTagName: (NSString *) tagName
                     contentType: (contentType) type;

@end
