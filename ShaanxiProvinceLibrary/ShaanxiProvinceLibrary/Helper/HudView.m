//
//  HudView.m
//  pushTest
//
//  Created by figure2008 on 16/4/26.
//  Copyright © 2016年 Long. All rights reserved.
//

#import "HudView.h"

@interface HudView ()

@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *label;

@end

@implementation HudView

-(instancetype) initWithFrame:(CGRect)frame
                    addOnView:(UIView *)view
{
    self = [super initWithFrame: frame];
    if (self) {
        
        // IndicatorView
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        // Label
        _label = [UILabel new];
        _label.text = @"正在载入...";
        _label.font = [UIFont systemFontOfSize: 14];
        _label.textColor = [UIColor grayColor];
        [_label sizeToFit];
        
        // setFrame
        [self addSubview: _indicatorView];
        [self addSubview: _label];
        [view addSubview: self];
        self.frame = frame;
        self.clipsToBounds = YES;
        
        // center
        self.center = view.center;
        CGFloat y = CGRectGetHeight(frame);
        _indicatorView.center = CGPointMake(CGRectGetWidth(_indicatorView.frame)/2, y/2);
        _label.center = CGPointMake(CGRectGetWidth(_indicatorView.frame) + CGRectGetWidth(_label.frame)/2 + 5, y/2);
        // show animation
        [_indicatorView startAnimating];
        
        // observe
        [_label addObserver: self forKeyPath: @"text" options: NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context: nil];
    }
    return self;
}

+ (instancetype) showHudOnView:(UIView *)view
{
    CGRect frame = CGRectMake(0, 0, 100, 30);
    return [[self alloc] initWithFrame: frame addOnView: view];
}

- (void) hideHudView
{
    [self removeFromSuperview];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    [_label sizeToFit];
    NSLog(@"标签的内容改变了");
}

- (void) dealloc
{
    [_label removeObserver: self forKeyPath: @"text"];
}

@end
