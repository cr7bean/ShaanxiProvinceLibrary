//
//  Helper.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 15/11/18.
//  Copyright © 2015年 Long. All rights reserved.
//

#import "Helper.h"


@implementation Helper
{
    
}

#pragma mark -  Label


+ (void) configurateLabel: (UILabel*) label
                     text: (NSString*) text
                textColor: (UIColor*) color
                     font: (UIFont *) font
            textAlignment: (NSTextAlignment) alignment
{
    label.text = text;
    label.numberOfLines = 0;
    label.textColor = color;
    label.font = font;
    label.textAlignment = alignment;
}



#pragma mark - NSString

//截取字符串
+ (void) interceptStringWith: (NSString*) identify
                          in: (NSString*) original
                resultString: (void(^)(NSString* formerString, NSString*        latterString)) resultString
{
    if (original) {
        
        NSRange range = [identify rangeOfString: original];
        NSString *former = [original substringToIndex: range.location];
        NSString *latter = [original substringFromIndex: range.location];
        
        resultString(former, latter);
    }
    
}

//删除多余空格和回车
+  (NSString *) deleteSpaceAndCR: (NSString *) string
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return string;
}

//添加空格
+ (NSString *) addSpace: (NSString *) string
             withNumber: (NSUInteger) number
{
    switch (number) {
        case 1:
            string = [string stringByAppendingString: @" "];
            break;
        default:
            break;
    }
    return string;
}

#pragma mark - UIColor

+ (UIColor *) setColorWithRed: (NSUInteger) red
                       green: (NSUInteger) green
                        blue: (NSUInteger) blue
{
    UIColor *colour = [UIColor colorWithRed: red/255.0 green: green/255.0 blue: blue/255.0 alpha: 1];
    return colour;
}




























@end
