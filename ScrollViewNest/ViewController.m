//
//  ViewController.m
//  ScrollViewNest
//
//  Created by wisdom on 2017/6/14.
//  Copyright © 2017年 wisdom. All rights reserved.
//

#import "ViewController.h"
#import "MJRefresh.h"
#import "CustomHeadView.h"
#import "LJDynamicItem.h"
#import "CustomButtonView.h"
#import "UINavigationController+NavAlpha.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

static const CGFloat kNavigationHeight = 64.f;
static const CGFloat kHeadViewHeight = 200;
static const CGFloat kButtonHeigth = 40;

static const CGFloat kTableViewEdgeTop = kNavigationHeight+kHeadViewHeight+kButtonHeigth;

static NSString * const kCellReuse = @"cell";

static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,CustomHeadViewDelegate,CustomButtonViewDelegate>{
    
    __block BOOL isVertical;//是否是垂直
}

@property (nonatomic, strong) CustomHeadView * headView;
@property (nonatomic, strong) CustomButtonView * buttonView;

@property (nonatomic, strong) UIScrollView * mainScrollView;

@property (nonatomic, strong) NSMutableArray * tableViewArray;
@property (nonatomic, strong) NSMutableArray * dataArray;
@property (nonatomic, assign) NSInteger currentPage;


//弹性和惯性动画
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;
@property (nonatomic, strong) LJDynamicItem * dynamicItem;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.mainScrollView];
    [self.view addSubview:self.buttonView];
    [self.view addSubview:self.headView];
    [self.view addSubview:self.buttonView];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicItem = [[LJDynamicItem alloc] init];
    
    /// 设置颜色
    self.navTintColor = [UIColor whiteColor];
    self.navBarTintColor = [UIColor whiteColor];
    self.navAlpha = 0;
    
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"more"] style:UIBarButtonItemStyleDone target:nil action:nil];
    self.navigationItem.rightBarButtonItem = item;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    UIScrollView * scrollView = (UIScrollView *)object;
    
    if (!(self.tableViewArray[self.currentPage] == scrollView)) {
        return;
    }
    
    if (![keyPath isEqualToString:@"contentOffset"]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    CGFloat tableViewoffsetY = scrollView.contentOffset.y;
    tableViewoffsetY += kTableViewEdgeTop;
    if (tableViewoffsetY > 150) {
        self.navAlpha = (tableViewoffsetY-150) / (kHeadViewHeight-150);
        self.navTintColor = [UIColor blackColor];
        
    } else {
        self.navAlpha = 0.f;
        self.navTintColor = [UIColor whiteColor];
    }
    
    if (tableViewoffsetY > 0 && tableViewoffsetY <= kHeadViewHeight) {
        self.headView.frame = CGRectMake(0, kNavigationHeight-tableViewoffsetY, kScreenWidth, kHeadViewHeight);
        self.buttonView.frame = CGRectMake(0, kNavigationHeight-tableViewoffsetY+kHeadViewHeight, kScreenWidth, kButtonHeigth);
        for (UITableView * tableView in self.tableViewArray) {
            if (tableView != scrollView) {
                tableView.contentOffset = CGPointMake(tableView.contentOffset.x, tableViewoffsetY-kTableViewEdgeTop);
            }
        }
        
    }else if( tableViewoffsetY < 0){
        self.headView.frame = CGRectMake(0, kNavigationHeight, kScreenWidth, kHeadViewHeight);
        self.buttonView.frame = CGRectMake(0, kNavigationHeight+kHeadViewHeight, kScreenWidth, kButtonHeigth);
    }else if (tableViewoffsetY > kHeadViewHeight){
        //置顶时
        self.headView.frame = CGRectMake(0, kNavigationHeight-kHeadViewHeight, kScreenWidth, kHeadViewHeight);
        self.buttonView.frame = CGRectMake(0, kNavigationHeight, kScreenWidth, kButtonHeigth);
        for (UITableView * tableView in self.tableViewArray) {
            if (tableView != scrollView) {
                if(tableView.contentOffset.y < kHeadViewHeight){
                    tableView.contentOffset = CGPointMake(tableView.contentOffset.x, kHeadViewHeight-kTableViewEdgeTop);
                }
            }
        }
    }else if (tableViewoffsetY == 0){
        for (UITableView * tableView in self.tableViewArray) {
            if (tableView != scrollView) {
                tableView.contentOffset = CGPointMake(tableView.contentOffset.x, -kTableViewEdgeTop);
            }
        }
    }
}

#pragma mark - UITableViewDataSource && UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.dataArray[self.currentPage] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kCellReuse forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1f;
}

#pragma mark - UIScrollViewDelgate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.mainScrollView) {
        NSInteger page = self.mainScrollView.contentOffset.x/self.mainScrollView.frame.size.width;
        self.currentPage = page;
        [self.buttonView setSelectButtonIndex:self.currentPage];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if (scrollView == self.tableViewArray[self.currentPage]) {
        //不加 如果有spring动画未结束 tableView滑动 会有问题
        [self.animator removeAllBehaviors];
    }
}

#pragma mark - CustomHeadViewDelegate
- (void)customHeadViewDelegate:(CustomHeadView *)headView didPan:(UIPanGestureRecognizer *)recognizer{
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:{
            CGFloat currentY = [recognizer translationInView:self.view].y;
            CGFloat currentX = [recognizer translationInView:self.view].x;
            
            if (currentY == 0.0) {
                isVertical = NO;
            } else {
                if (fabs(currentX)/currentY >= 5.0) {
                    isVertical = NO;
                } else {
                    isVertical = YES;
                }
            }
            [self.animator removeAllBehaviors];
        }break;
        case UIGestureRecognizerStateChanged:
        {
            //locationInView:获取到的是手指点击屏幕实时的坐标点；
            //translationInView：获取到的是手指移动后，在相对坐标中的偏移量
            
            if (isVertical) {
                //往上滑为负数，往下滑为正数
                CGFloat currentY = [recognizer translationInView:self.view].y;
                [self controlScrollForVertical:currentY AndState:UIGestureRecognizerStateChanged];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            if (isVertical) {
                self.dynamicItem.center = self.view.bounds.origin;
                //velocity是在手势结束的时候获取的竖直方向的手势速度
                CGPoint velocity = [recognizer velocityInView:self.view];
                UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
                [inertialBehavior addLinearVelocity:CGPointMake(0, velocity.y) forItem:self.dynamicItem];
                // 通过尝试取2.0比较像系统的效果
                inertialBehavior.resistance = 2.0;
                __block CGPoint lastCenter = CGPointZero;
                __weak typeof(self) weakSelf = self;
                inertialBehavior.action = ^{
                    if (isVertical) {
                        //得到每次移动的距离
                        CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                        [weakSelf controlScrollForVertical:currentY AndState:UIGestureRecognizerStateEnded];
                    }
                    lastCenter = weakSelf.dynamicItem.center;
                };
                [self.animator addBehavior:inertialBehavior];
                self.decelerationBehavior = inertialBehavior;
            }
        }
            break;
        default:
            break;
    }
    //保证每次只是移动的距离，不是从头一直移动的距离
    [recognizer setTranslation:CGPointZero inView:self.view];
    
}

//控制上下滚动的方法
- (void)controlScrollForVertical:(CGFloat)detal AndState:(UIGestureRecognizerState)state {

    UITableView * tableView = self.tableViewArray[self.currentPage];
    CGPoint tableViewContentOffSet = CGPointMake(tableView.contentOffset.x, tableView.contentOffset.y-rubberBandDistance(detal, kScreenHeight));
    tableView.contentOffset = tableViewContentOffSet;
    
    BOOL outsideFrame = tableViewContentOffSet.y < -kTableViewEdgeTop || tableView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height);
    
    if (outsideFrame && state == UIGestureRecognizerStateEnded) {
        
        CGPoint target = CGPointZero;
        if (tableView.contentOffset.y < -kTableViewEdgeTop) {
            self.dynamicItem.center = tableView.contentOffset;
            target = CGPointMake(0, -kTableViewEdgeTop);
            if (tableView.contentOffset.y < -kTableViewEdgeTop-MJRefreshHeaderHeight) {
                [self.animator removeAllBehaviors];
                [tableView.mj_header beginRefreshing];
                return;
            }
            
        } else if (tableView.contentOffset.y > (tableView.contentSize.height - tableView.frame.size.height)) {
            self.dynamicItem.center = tableView.contentOffset;
            target = CGPointMake(tableView.contentOffset.x, (tableView.contentSize.height - tableView.frame.size.height));
            
        }
        [self.animator removeBehavior:self.decelerationBehavior];
        __weak typeof(self) weakSelf = self;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 0;
        springBehavior.action = ^{
            UITableView * tableView = weakSelf.tableViewArray[weakSelf.currentPage];
            tableView.contentOffset = weakSelf.dynamicItem.center;
        };
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }else if (state == UIGestureRecognizerStateChanged){
        if (tableView.contentOffset.y < -kTableViewEdgeTop-MJRefreshHeaderHeight) {
        [((MJRefreshNormalHeader *)tableView.mj_header) customSetState:MJRefreshStatePulling];
        }else{
        [((MJRefreshNormalHeader *)tableView.mj_header) customSetState:MJRefreshStateIdle];
        }
    }
}

#pragma mark - CustomButtonViewDelegate 点击了按钮
- (void)customButtonView:(CustomButtonView *)buttonView didClicked:(NSInteger)index{

    self.currentPage = index;
    self.mainScrollView.contentOffset = CGPointMake(index * kScreenWidth, self.mainScrollView.contentOffset.y);
}

#pragma mark - Getter
- (CustomHeadView *)headView{
    if (!_headView) {
        _headView = [[CustomHeadView alloc] initWithFrame:CGRectMake(0, kNavigationHeight, kScreenWidth, kHeadViewHeight)];
        _headView.delegate = self;
    }
    return _headView;
}

- (CustomButtonView *)buttonView{
    if(!_buttonView){
        _buttonView = [[CustomButtonView alloc] initWithFrame:CGRectMake(0, kNavigationHeight+kHeadViewHeight, kScreenWidth, kButtonHeigth)];
        _buttonView.delegate = self;
    }
    return _buttonView;
}

- (UIScrollView *)mainScrollView{
    if (!_mainScrollView) {
        _mainScrollView = ({
            UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
            
            scrollView.delegate = self;
            scrollView.pagingEnabled = YES;
            
            self.currentPage = 0;
            self.tableViewArray = @[].mutableCopy;
            for (NSInteger i = 0; i < 3; i++) {
                UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(kScreenWidth*i, 0, kScreenWidth, kScreenHeight) style:UITableViewStyleGrouped];
                
                [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellReuse];
                tableView.delegate = self;
                tableView.dataSource = self;
                //占位
//                UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth,kHeadViewHeight+kButtonHeigth+kNavigationHeight)];
//                tableView.tableHeaderView = headView;
                
                tableView.contentInset = UIEdgeInsetsMake(kTableViewEdgeTop, 0, 0, 0);
                
                __weak typeof(self) weakSelf = self;
                tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        weakSelf.dataArray[i] = @(20);
                        [tableView.mj_header endRefreshing];
                        [tableView reloadData];
                    });
                }];
                
                tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        
                        NSInteger count = [weakSelf.dataArray[i] integerValue];
                        count += 20;
                        weakSelf.dataArray[i] = @(count);
                        [tableView.mj_footer endRefreshing];
                        [tableView reloadData];
                    });
                }];
                
                //监听tableView 偏移量
                NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
                [tableView addObserver:self forKeyPath:@"contentOffset" options:options context:nil];
                
                [scrollView addSubview:tableView];
                [self.tableViewArray addObject:tableView];
            }
            
            scrollView.contentSize = CGSizeMake(kScreenWidth*3, kScreenHeight);
            scrollView;
        });
    }
    return _mainScrollView;
}

- (NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = @[@(20),@(20),@(20)].mutableCopy;
    }
    return _dataArray;
}

@end
