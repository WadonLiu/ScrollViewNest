//
//  CustomHeadView.m
//  ScrollViewNest
//
//  Created by wisdom on 2017/6/15.
//  Copyright © 2017年 wisdom. All rights reserved.
//

#import "CustomHeadView.h"

@interface CustomHeadView ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView * backgroundImageView;
@property (nonatomic, strong) UIScrollView * scrollView;

@end

@implementation CustomHeadView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backgroundImageView];
        [self addSubview:self.scrollView];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        [self addGestureRecognizer:pan];
        pan.delegate = self;
    }
    return self;
}

#pragma mark - HeadViewPan
- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(customHeadViewDelegate:didPan:)]) {
        [self.delegate customHeadViewDelegate:self didPan:pan];
    }
}

#pragma mark - Getter
- (UIImageView *)backgroundImageView{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)+64)];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.image = [UIImage imageNamed:@"IMG_1639"];
    }
    return _backgroundImageView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(50, 100, CGRectGetWidth(self.frame)-50*2, 50)];
        CGFloat originX = 0;
        CGFloat marginX = 15.f;
        CGFloat width = 50.f;
        for (NSInteger i = 0 ; i < 5; i++) {
            UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(originX, 0, width, width)];
            imageView.image = [UIImage imageNamed:@"image.jpg"];
            [_scrollView addSubview:imageView];
            originX += width + marginX;
        }
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(originX, 0);
    }
    return _scrollView;
}

@end
