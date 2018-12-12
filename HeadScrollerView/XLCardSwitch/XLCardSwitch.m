//
//  XLCardSwitch.m
//  XLCardSwitchDemo
//
//  Created by Apple on 2017/1/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

#import "XLCardSwitch.h"
#import "XLCardSwitchFlowLayout.h"
#import "XLCard.h"

@interface XLCardSwitch ()<UICollectionViewDelegate,UICollectionViewDataSource> {
    UICollectionView *_collectionView;
    
    CGFloat _dragStartX;
    
    CGFloat _dragEndX;
    
    NSTimer *_timer;
    
    BOOL timerStop;
}
@end

@implementation XLCardSwitch

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self buildUI];
    }
    return self;
}

- (void)buildUI {
    
    [self addCollectionView];
}

- (void)addCollectionView {
    //避免UINavigation对UIScrollView产生的便宜问题
    [self addSubview:[UIView new]];
    XLCardSwitchFlowLayout *flowLayout = [[XLCardSwitchFlowLayout alloc] init];
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.showsHorizontalScrollIndicator = false;
    _collectionView.backgroundColor = [UIColor clearColor];
    [_collectionView registerClass:[XLCard class] forCellWithReuseIdentifier:@"XLCard"];
    _collectionView.userInteractionEnabled = true;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [self addSubview:_collectionView];
}

#pragma mark -
#pragma mark Setter
-(void)setItems:(NSArray<XLCardItem *> *)items {
    if (_needCirculation) {
        NSMutableArray *arr=[[NSMutableArray alloc]initWithArray:items];
        [arr addObject:[items firstObject]];
        [arr insertObject:[items lastObject] atIndex:0];
        _items = arr;
        
    }else{
       _items = items;
    }
    
    [_collectionView reloadData];
}

#pragma mark -
#pragma mark CollectionDelegate
//配置cell居中
- (void)fixCellToCenter {
    //最小滚动距离
    float dragMiniDistance = self.bounds.size.width/20.0f;
    if (_dragStartX -  _dragEndX >= dragMiniDistance) {
        _selectedIndex -= 1;//向右
    }else if(_dragEndX -  _dragStartX >= dragMiniDistance){
        _selectedIndex += 1;//向左
    }
    NSInteger maxIndex = [_collectionView numberOfItemsInSection:0] - 1;
    _selectedIndex = _selectedIndex <= 0 ? 0 : _selectedIndex;
    _selectedIndex = _selectedIndex >= maxIndex ? maxIndex : _selectedIndex;
    [self scrollToCenter];
}

//滚动到中间
- (void)scrollToCenter {
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    
    [self performDelegateMethod];
}

#pragma mark -
#pragma mark CollectionDelegate
//在不使用分页滚动的情况下需要手动计算当前选中位置 -> _selectedIndex
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_pagingEnabled) {return;}
    if (!_collectionView.visibleCells.count) {return;}
    if (!scrollView.isDragging) {return;}
    CGRect currentRect = _collectionView.bounds;
    currentRect.origin.x = _collectionView.contentOffset.x;
    for (XLCard *card in _collectionView.visibleCells) {
        if (CGRectContainsRect(currentRect, card.frame)) {
            NSInteger index = [_collectionView indexPathForCell:card].row;
            if (index != _selectedIndex) {
                _selectedIndex = index;
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if (_needCirculation) {
        
        if (_selectedIndex>=_items.count-1) {
            
            [self setSelectedIndex:1];
            
        }else if (_selectedIndex<=0){
            
            [self setSelectedIndex:_items.count-2];
        }
        
        
        if (timerStop) {
            [_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_pauseScrollTimeInterval?:2]];
            timerStop=false;
        }
        
    }
    
    
    
}

//手指拖动开始
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    if (_needCirculation) {
       //手指拖动暂停计时器
        timerStop=YES;
        [_timer setFireDate:[NSDate distantFuture]];
    }
    
    
    _dragStartX = scrollView.contentOffset.x;
}

//手指拖动停止
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!_pagingEnabled) {return;}
    _dragEndX = scrollView.contentOffset.x;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fixCellToCenter];
    });
}

//点击方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_selectedIndex == indexPath.row) {
        if (_needCirculation) {
            
            if (indexPath.row==0) {
                [self.delegate XLCardSwitchTouchSelectAt:1];
            }else if (indexPath.row==_items.count-1){
                [self.delegate XLCardSwitchTouchSelectAt:_items.count-2];
            }else{
                [self.delegate XLCardSwitchTouchSelectAt:indexPath.row-1];
                
            }
        }else{
            [self.delegate XLCardSwitchTouchSelectAt:indexPath.row];
            
        }
        
        
      
    }else{
        
        _selectedIndex = indexPath.row;
        [self scrollToCenter];
    }
   
    
}

#pragma mark -
#pragma mark CollectionDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _items.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString* cellId = @"XLCard";
    XLCard* card = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    card.useLocalImage=_useLocalImage;
    card.item = _items[indexPath.row];
    return  card;
}

#pragma mark -
#pragma mark 功能方法

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    [self switchToIndex:selectedIndex animated:false];
}

- (void)switchToIndex:(NSInteger)index animated:(BOOL)animated {
    
    if (_needCirculation) {
        if (_items.count ==3) {
            //就一个图的情况
            if (index>_items.count-1) {
                
                index=1;
                
                
            }else if (index<0){
                index=1;
            }
        }else{
            if (index>_items.count-1) {
                
                index=2;
                
                
            }else if (index<0){
                index=_items.count-2;
            }
            
        }
        
        
    }
    _selectedIndex = index;
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:animated];
    [self performDelegateMethod];
}


- (void)performDelegateMethod {
    if ([_delegate respondsToSelector:@selector(XLCardSwitchDidSelectedAt:)]) {
        [_delegate XLCardSwitchDidSelectedAt:_selectedIndex];
    }
}

//创建定时器
- (void)setupTimer
{
    [self invalidateTimer]; // 创建定时器前先停止定时器，不然会出现僵尸定时器，导致轮播频率错误
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollTimeInterval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll{
    
//    NSLog(@"1")
    [self switchToIndex:_selectedIndex+1 animated:true];
    
    
    
}
-(void)startCirculation{
//    []
    [self setSelectedIndex:1];
    [self setupTimer];
}
@end
