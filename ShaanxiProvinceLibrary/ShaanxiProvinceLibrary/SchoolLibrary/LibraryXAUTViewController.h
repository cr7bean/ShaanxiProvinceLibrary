//
//  LibraryXAUTViewController.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/3/21.
//  Copyright © 2016年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryXAUTViewController : UIViewController

+ (instancetype) searchBookWithWords: (NSString *) words
                          searchType: (NSString *) type;

@end