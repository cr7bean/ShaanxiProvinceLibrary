//
//  DoubanContentTableViewCell.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/24.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DoubanBookModel;

@interface DoubanContentTableViewCell : UITableViewCell

- (void) titleCell: (DoubanBookModel *) bookmodel;
- (void) summaryCell: (NSString *) content;

@end
