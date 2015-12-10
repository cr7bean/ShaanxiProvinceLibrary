//
//  NewsTableViewCell.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/22.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewsModel.h"

@interface NewsTableViewCell : UITableViewCell

- (void) configurateNewsView: (NewsModel*) news;
@property (nonatomic, assign) CGFloat Height;


@end
