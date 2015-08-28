//
//  MitchellView.m
//  Mitchell彩票
//
//  Created by MENGCHEN on 15/8/27.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "MitchellView.h"

#import "MitchellBtn.h"
@interface MitchellView()

@property (weak, nonatomic) IBOutlet UIImageView *rotateImg;
@property (weak, nonatomic) IBOutlet UIButton *seletBtn;

@property(nonatomic,weak)MitchellBtn * selectedBtn;
@property(nonatomic,weak)CADisplayLink * link;

@property(nonatomic,strong)NSMutableArray * btnArray;
/**
 *
 */
@property(nonatomic,assign)NSInteger  staticNum;
@end

@implementation MitchellView

#pragma mark ------------------ 初始化方法 ------------------

+ (instancetype)view{
    return [[NSBundle mainBundle] loadNibNamed:@"MitchellView" owner:nil options:nil][0];
}
#pragma mark ------------------ awakeFromNib ------------------
-(void)awakeFromNib{
    UIImage*norImage = [UIImage imageNamed:@"LuckyAstrology"];
    UIImage*hightImage = [UIImage imageNamed:@"LuckyAstrologyPressed"];
    /**
     *  获取
     */
    CGRect clipR = CGRectZero;
    clipR = [self calculateImageRect:norImage];
    //创建按钮
    for (int i = 0; i<12; i++) {
        MitchellBtn*btn = [MitchellBtn buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.userInteractionEnabled = YES;
        [self setBtnFrame:btn];
        clipR.origin.x =btn.tag * clipR.size.width;
        [self setUpImage:norImage highlightedImage:hightImage WithBtn:btn WithClipRect:clipR];
        [_rotateImg addSubview:btn];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnArray addObject:btn];
    }
    
    
}
-(NSMutableArray *)btnArray{
    if (!_btnArray) {
        _btnArray = [NSMutableArray array];
    }
    return _btnArray;
}
#pragma mark ------------------ 初步计算裁剪区域 ------------------
- (CGRect)calculateImageRect:(UIImage*)norImage{
    /**
     *  获取屏幕的像素倍数
     */
    CGFloat scale = [UIScreen mainScreen].scale;
    /**
     *  设置裁剪x,y,宽度、高度、范围
     */
    CGRect  clipR = CGRectZero;
    CGFloat clipW = norImage.size.width/12.0*scale;
    CGFloat clipH = norImage.size.height*scale;
    CGFloat clipY = 0;
    clipR = CGRectMake(0, clipY, clipW, clipH);
    return clipR;
}
#pragma mark ------------------ 设置图片 ------------------
- (void)setUpImage:(UIImage*)norImage highlightedImage:(UIImage*)highImg WithBtn:(MitchellBtn*)btn WithClipRect:(CGRect)clipR{
    [btn setBackgroundImage:[UIImage imageNamed:@"LuckyRototeSelected"] forState:UIControlStateSelected];
    /**
     *  裁剪区域
     */
    /**
     *  正常图片
     */
    CGImageRef imageRef = CGImageCreateWithImageInRect(norImage.CGImage, clipR);
    UIImage * norClipImage = [UIImage imageWithCGImage:imageRef];
    [btn setImage:norClipImage forState:UIControlStateNormal];
    /**
     *  选中图片
     */
    imageRef = CGImageCreateWithImageInRect(highImg.CGImage, clipR);
    UIImage * highClipImage = [UIImage imageWithCGImage:imageRef];
    [btn setImage:highClipImage forState:UIControlStateSelected];
}
#pragma mark ------------------ 设置按钮的位置 ------------------
- (void)setBtnFrame:(MitchellBtn*)btn{
    btn.layer.anchorPoint = CGPointMake(0.5, 1);
    btn.layer.position    = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    btn.layer.bounds      = CGRectMake(0, 0, 68, 143);
    CGFloat angle         = (btn.tag * 30)/180.0 * M_PI;
    btn.transform         = CGAffineTransformMakeRotation(angle);
    
}
#pragma mark ------------------ 开始选号 ------------------
- (IBAction)click:(UIButton *)sender {
    //先停止慢慢旋转
    [self stop];
    //开启动画
    [self createAni];
    
    NSInteger num = arc4random_uniform(12);
    _staticNum = num;
    _seletBtn.userInteractionEnabled = NO;
    [self createAnimation];
}
#pragma mark ------------------ 开始遍历循环 ------------------
- (void)createAnimation{
    NSInteger randomNum = arc4random_uniform(12);
    MitchellBtn*btn = [_btnArray objectAtIndex:randomNum];
    if (_staticNum!=randomNum) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self btnClick:btn];
            [self createAnimation];
        });
    }else{
        _seletBtn.userInteractionEnabled = YES;
        [_rotateImg.layer removeAnimationForKey:@"aaa"];
        [self btnClick:btn];
    }
    
    
    
    
    
}
#pragma mark ------------------ 开启动画 ------------------
- (void)createAni{
    CABasicAnimation*ani = [CABasicAnimation animation];
    ani.keyPath = @"transform.rotation";
    ani.toValue = @(M_PI*4);
    ani.duration = 0.5;
    ani.repeatCount = MAXFLOAT;
    ani.delegate = self;
    [_rotateImg.layer addAnimation:ani forKey:@"aaa"];
}
#pragma mark ------------------ 动画停止的时候 ------------------
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    // 把选中的按钮显示到圆心的最上边
    // 还原选中按钮的位置,恢复之前的旋转
    // 计算选中按钮之前的旋转角度
    // CGFloat angle = (_selectedBtn.tag * 30) / 180.0 * M_PI;
    // 根据形变计算之前的旋转角度
    NSLog(@"%s",__func__);
    CGFloat angle = atan2(_selectedBtn.transform.b, _selectedBtn.transform.a);
    _rotateImg.transform = CGAffineTransformMakeRotation(-angle);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.link.paused = NO;
    });
}
#pragma mark ------------------ 懒加载CADisplayLink ------------------
-(CADisplayLink *)link{
    
    if (!_link) {
        CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(rotate)];
        _link = link;
        [_link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return _link;
}
#pragma mark ------------------ 旋转 ------------------
- (void)rotate{
    
    _rotateImg.transform = CGAffineTransformRotate(_rotateImg.transform, (180/60.0)/180.0*M_PI);
    
}
#pragma mark ------------------ 中奖按钮点击 ------------------
- (void)btnClick:(MitchellBtn*)btn{
//    btn.selected = !btn.selected;
//    if (!_selectedBtn) {
//        _selectedBtn = btn;
//        btn.userInteractionEnabled = NO;
//    }else{
//        _selectedBtn.selected = NO;
//        _selectedBtn.userInteractionEnabled = YES;
//        _selectedBtn = btn;
//    }
    for (MitchellBtn*btn in _btnArray) {
        btn.selected = NO;
        btn.userInteractionEnabled = YES;
    }
    btn.selected = YES;
    btn.userInteractionEnabled = NO;
    
    
    
    
}
#pragma mark ------------------ 暂停 ------------------
-(void)stop{
   
    self.link.paused = YES;
}

#pragma mark ------------------ 开始 ------------------
-(void)start{
    
    self.link.paused = NO;
    
}
@end
