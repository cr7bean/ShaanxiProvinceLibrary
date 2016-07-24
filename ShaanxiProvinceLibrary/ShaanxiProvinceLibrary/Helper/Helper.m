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

+ (void) configurateLabel: (UILabel*) label
                textColor: (UIColor*) color
                     font: (UIFont *) font
                   number: (NSUInteger) number
                alignment: (NSTextAlignment) alignment
{
    label.textColor = color;
    label.font = font;
    label.numberOfLines = number;
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
        if (range.length) {
            NSString *former = [original substringToIndex: range.location];
            NSString *latter = [original substringFromIndex: range.location];
            
            resultString(former, latter);
        }
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

// 删除字符串中的特殊字符
+ (NSString *) deleteSpesicalSymbolInString: (NSString *) string
{
    NSArray *symbolArray = @[@"=", @"?", @".", @"。", @"<", @">", @"《", @"》", @"，", @"+", @"*", @"!", @"@", @"#", @"-", @"——", @"_", @"$", @"&", @"[", @"]"];
    for (NSString * symbol in symbolArray) {
        NSRange range = [string rangeOfString: symbol];
        if (range.length) {
            string = [string stringByReplacingOccurrencesOfString: symbol withString: @""];
        }
    }
    return string;
}



# pragma mark - NSData

//NSData 转 NSString 的时候，返回nil,对NSData 进行处理。
+ (NSData *)UTF8Data: (NSData *) data
{
    //保存结果
    NSMutableData *resData = [[NSMutableData alloc] initWithCapacity:data.length];
    
    //无效编码替代符号(常见 � □ ?)
    NSData *replacement = [@"�" dataUsingEncoding:NSUTF8StringEncoding];
    
    uint64_t index = 0;
    const uint8_t *bytes = data.bytes;
    
    while (index < data.length)
    {
        uint8_t len = 0;
        uint8_t header = bytes[index];
        
        //单字节
        if ((header&0x80) == 0)
        {
            len = 1;
        }
        //2字节(并且不能为C0,C1)
        else if ((header&0xE0) == 0xC0)
        {
            if (header != 0xC0 && header != 0xC1)
            {
                len = 2;
            }
        }
        //3字节
        else if((header&0xF0) == 0xE0)
        {
            len = 3;
        }
        //4字节(并且不能为F5,F6,F7)
        else if ((header&0xF8) == 0xF0)
        {
            if (header != 0xF5 && header != 0xF6 && header != 0xF7)
            {
                len = 4;
            }
        }
        
        //无法识别
        if (len == 0)
        {
            [resData appendData:replacement];
            index++;
            continue;
        }
        
        //检测有效的数据长度(后面还有多少个10xxxxxx这样的字节)
        uint8_t validLen = 1;
        while (validLen < len && index+validLen < data.length)
        {
            if ((bytes[index+validLen] & 0xC0) != 0x80)
                break;
            validLen++;
        }
        
        //有效字节等于编码要求的字节数表示合法,否则不合法
        if (validLen == len)
        {
            [resData appendBytes:bytes+index length:len];
        }else
        {
            [resData appendData:replacement];
        }
        
        //移动下标
        index += validLen;
    }
    
    return resData;
}



#pragma mark - UIColor

+ (UIColor *) setColorWithRed: (NSUInteger) red
                       green: (NSUInteger) green
                        blue: (NSUInteger) blue
{
    UIColor *colour = [UIColor colorWithRed: red/255.0 green: green/255.0 blue: blue/255.0 alpha: 1];
    return colour;
}

#pragma mark - ViewController

+ (void) addViewController: (id) childController
          toViewController: (UIViewController *) parentController
{
    [parentController addChildViewController: childController];
//    [[(UIViewController *)childController view] setFrame: CGRectMake(0, 0, 375, 667-64)];
    [[(UIViewController *)childController view] setFrame: [UIScreen mainScreen].bounds];
    [parentController.view addSubview: [childController view]];
    [childController didMoveToParentViewController: parentController];
}


#pragma mark - setNetworkIndicator
+ (void) setNetworkIndicator: (BOOL) show
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: show];
}


# pragma mark - regularExpression

// 查找字符串中的数字
+ (NSInteger) regexFindNumberInString: (NSString *) checkString
                
{
    NSString *pattern = @"\\d{1,}";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern: pattern
      options: NSRegularExpressionCaseInsensitive error: nil];
   
    NSRange range = [expression rangeOfFirstMatchInString: checkString
                                                  options: 0
                                                    range: NSMakeRange(0, checkString.length)];
    return [[checkString substringWithRange: range] integerValue];
}


+ (NSString *)regexDeleteBlankCharacterInString: (NSString *) checkString
{
    if (!checkString) {
        return nil;
    }
    NSString *pattern = @"\\s";
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern: pattern options: NSRegularExpressionCaseInsensitive error: nil];
    NSString *result = [expression stringByReplacingMatchesInString: checkString options: 0 range: NSMakeRange(0, [checkString length]) withTemplate: @""];
    return result;
}

+ (NSString *) regexDeleteBlankCharacterInString:(NSString *) checkString
                                         pattern: (NSString *) pattern
{
    NSRegularExpression *expression = [NSRegularExpression regularExpressionWithPattern: pattern options: NSRegularExpressionCaseInsensitive error: nil];
    NSString *result = [expression stringByReplacingMatchesInString: checkString options: 0 range: NSMakeRange(0, [checkString length]) withTemplate: @""];
    return result;
}

+ (NSString *) regexDeleteReturnTabAndLineFeedInString: (NSString *) checkString
{
    return [self regexDeleteBlankCharacterInString: checkString pattern: @"[\n\t\r]"];
}






















@end
