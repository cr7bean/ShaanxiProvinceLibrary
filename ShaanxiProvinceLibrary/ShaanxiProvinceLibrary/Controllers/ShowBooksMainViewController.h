//
//  ShowBooksMainViewController.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/12.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ShowBooksMainViewController;

@protocol ShowBooksMainViewControllerDelegate <NSObject>

- (void) mainViewController: (ShowBooksMainViewController *) controller
              selectedIndex: (NSUInteger) index;
@end



@interface ShowBooksMainViewController : UIViewController

- (instancetype) initWithDictionary: (NSDictionary *) dictionary;
@property (nonatomic, weak) id<ShowBooksMainViewControllerDelegate> delegate;

@end
