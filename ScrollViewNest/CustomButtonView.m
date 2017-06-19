//
//  CustomButtonView.m
//  ScrollViewNest
//
//  Created by wisdom on 2017/6/15.
//  Copyright © 2017年 wisdom. All rights reserved.
//

#import "CustomButtonView.h"

@interface CustomButtonView ()

@property (nonatomic, strong) NSMutableArray * buttonArray;

@end

@implementation CustomButtonView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        NSInteger buttonCount = 3;
        CGFloat width = frame.size.width / buttonCount;
        CGFloat originX = 0;
        for (NSInteger i = 0; i < buttonCount; i++) {
            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(originX, 0, width, frame.size.height);
            [button setTitle:[NSString stringWithFormat:@"第%ld个",i] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [button addTarget:self action:@selector(buttonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
            if (i == 0) {
                button.selected = YES;
            }
            button.tag = i;
            originX += width;
            [self addSubview:button];
            [self.buttonArray addObject:button];
        }
        self.backgroundColor = [UIColor grayColor];
    }
    return self;
}

- (void)buttonDidClicked:(UIButton *)button{
    for (UIButton * subButton in self.buttonArray) {
        subButton.selected = NO;
    }
    button.selected = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(customButtonView:didClicked:)]) {
        [self.delegate customButtonView:self didClicked:button.tag];
    }
}

- (void)setSelectButtonIndex:(NSInteger)index{
    if (index < 0 || index > 3) {
        return;
    }
    for (NSInteger i = 0; i < 3; i++) {
        UIButton * button = self.buttonArray[i];
        if (i == index) {
            button.selected = YES;
        }else{
            button.selected = NO;
        }
    }
}

#pragma mark - Getter

- (NSMutableArray *)buttonArray{
    if (!_buttonArray) {
        _buttonArray = @[].mutableCopy;
    }
    return _buttonArray;
}

@end
