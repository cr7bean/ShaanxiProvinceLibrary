//
//  BookContentTableViewCell.h
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/12/20.
//  Copyright © 2015年 Long. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BookContentTableViewCell : UITableViewCell

- (void) configureCell: (NSDictionary *) bookContentDic
           atIndexPath: (NSIndexPath *) indexPath;
             

@end
