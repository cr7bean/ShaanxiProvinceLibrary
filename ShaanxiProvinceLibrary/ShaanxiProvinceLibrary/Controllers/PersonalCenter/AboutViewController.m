//
//  AboutViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/30.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "AboutViewController.h"
#import <DTCoreText.h>
#import <GHMarkdownParser.h>
#import <NSString+GHMarkdownParser.h>

@interface AboutViewController ()

@property (strong, nonatomic) IBOutlet UITextView *textView;


@end

@implementation AboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self markDownString];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (void) markDownString
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        self.automaticallyAdjustsScrollViewInsets = NO;
//        self.textView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        NSString *markdown = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource: @"about.md" ofType: nil] encoding: NSUTF8StringEncoding error: nil];
        GHMarkdownParser *parse = [GHMarkdownParser new];
        parse.options = kGHMarkdownAutoLink;
        parse.githubFlavored = YES;
        NSString *html = [parse HTMLStringFromMarkdownString: markdown];
        NSDictionary *DTCoreText_options = @{DTUseiOS6Attributes:@YES,
                                             DTIgnoreInlineStylesOption:@YES,
                                             DTDefaultLinkDecoration:@NO,
                                             DTDefaultLinkColor:[UIColor blueColor],
                                             DTLinkHighlightColorAttribute:[UIColor redColor],
                                             DTDefaultFontSize:@15,
                                             DTDefaultFontFamily:@"Helvetica Neue",
                                             DTDefaultFontName:@"HelveticaNeue-Light"};
        
        NSMutableAttributedString *preview = [[NSMutableAttributedString alloc] initWithHTMLData: [html dataUsingEncoding: NSUTF8StringEncoding] options: DTCoreText_options documentAttributes: nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.textView.attributedText = preview;
        });
    });
}


@end
