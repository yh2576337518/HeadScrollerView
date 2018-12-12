//
//  ViewController.m
//  HeadScrollerView
//
//  Created by 惠上科技 on 2018/3/23.
//  Copyright © 2018年 惠上科技. All rights reserved.
//

#import "ViewController.h"
#import "XLCardSwitch.h"
@interface ViewController ()<XLCardSwitchDelegate>
@property (nonatomic, strong) NSMutableArray *headerArr;
@property (nonatomic, strong) NSMutableArray *imageArr;
@property (nonatomic ,strong) XLCardSwitch *imageSwitch;
@end
@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.headerArr = [NSMutableArray array];
    self.imageArr = [NSMutableArray array];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self requestHeaderScrDeatils];
}

- (void)requestHeaderScrDeatils{
//    [[MyAFNetworkingClient getInstance] requestRecommendHeader:@"1" resultBlock:^(NSError *error, id respondObj) {
//        if (!error) {
//            if ([[respondObj objectForKey:@"code"] integerValue] == 0) {
//                NSArray *objArr = [respondObj objectForKey:@"obj"];
                NSMutableArray * imagrArray = [NSMutableArray array];
                [_imageArr removeAllObjects];
                for (int i = 0; i < 5; i++) {
                    [imagrArray addObject:@"fsfs"];
                    [_imageArr addObject:@"sfds"];
                }
                [self layouHeaderView:imagrArray];
//                [self.mainTabView reloadData];
//            }
//        }
//    }];
}

#pragma mark ---------------UITableView
- (void)layouHeaderView:(NSArray *)arr{
    [_headerArr removeAllObjects];
    if (self.imageSwitch) {
        [self.imageSwitch removeFromSuperview];
        self.imageSwitch.delegate = nil;
        self.imageSwitch = nil;
    }
    for (NSString *string in arr) {
        XLCardItem *item = [[XLCardItem alloc] init];
        item.imageName = string;
        [_headerArr addObject:item];
    }
    if (_headerArr.count>0) {
        [self addHeadSwitchView];
        [self.view addSubview:self.imageSwitch];
    }
}

-(void)addHeadSwitchView{
    _imageSwitch = [[XLCardSwitch alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 200)];
    _imageSwitch.needCirculation = YES;
    _imageSwitch.useLocalImage = NO;//判断是不是本地图片 可以用网址 要用sdWeb库

    //上面两个bool 要先放

    _imageSwitch.items = _headerArr;
    _imageSwitch.delegate = self;

    //分页切换
    _imageSwitch.pagingEnabled = YES;
    //设置初始位置，默认为0
    _imageSwitch.selectedIndex = 1;
    _imageSwitch.autoScrollTimeInterval=3;
    [_imageSwitch startCirculation];
}

#pragma mark CardSwitchDelegate
- (void)XLCardSwitchTouchSelectAt:(NSInteger)index{
    NSLog(@"%zd",index);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
