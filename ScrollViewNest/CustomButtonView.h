//
//  CustomButtonView.h
//  ScrollViewNest
//
//  Created by wisdom on 2017/6/15.
//  Copyright © 2017年 wisdom. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomButtonView;
@protocol CustomButtonViewDelegate <NSObject>

- (void)customButtonView:(CustomButtonView *)buttonView didClicked:(NSInteger)index;

@end

@interface CustomButtonView : UIView
@property (nonatomic, weak) id<CustomButtonViewDelegate> delegate;

- (void)setSelectButtonIndex:(NSInteger)index;
@end
