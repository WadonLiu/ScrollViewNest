//
//  CustomHeadView.h
//  ScrollViewNest
//
//  Created by wisdom on 2017/6/15.
//  Copyright © 2017年 wisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomHeadView;
@protocol CustomHeadViewDelegate <NSObject>

- (void)customHeadViewDelegate:(CustomHeadView *)headView didPan:(UIPanGestureRecognizer *)recognizer;

@end

@interface CustomHeadView : UIView

@property (nonatomic, weak) id<CustomHeadViewDelegate> delegate;

@end
