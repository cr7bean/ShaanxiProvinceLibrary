//
//  RemoveAdViewController.m
//  ShaanxiProvinceLibrary
//
//  Created by figure2008 on 16/5/27.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "RemoveAdViewController.h"

@interface RemoveAdViewController ()

@property (strong, nonatomic) IBOutlet UILabel *label;

@property (strong, nonatomic) IBOutlet UIButton *button;

@end

@implementation RemoveAdViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIColor *color = [UIColor colorWithRed:0/255.0 green:175/255.0 blue:240/255.0 alpha:1];
    self.label.layer.borderColor = color.CGColor;
    self.label.layer.borderWidth = 1;
    
}

- (void)didReceiveMemoryWarnin
{
    [super didReceiveMemoryWarning];
    
}

- (IBAction)clickButton:(UIButton *)sender
{
    
}



@end
