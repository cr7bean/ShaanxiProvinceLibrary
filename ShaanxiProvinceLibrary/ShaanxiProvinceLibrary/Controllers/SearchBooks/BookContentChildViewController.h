//
//  BookContentChildViewController.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/13.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, transtionType) {
    transtionTypeMainController = 0,
    transtionTypeListController,
};



@interface BookContentChildViewController : UIViewController

- (instancetype) initWith: (NSDictionary *) dictionary
               transition: (transtionType) transition;

@end
