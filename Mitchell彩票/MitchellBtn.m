//
//  MitchellBtn.m
//  Mitchell彩票
//
//  Created by MENGCHEN on 15/8/27.
//  Copyright (c) 2015年 Mcking. All rights reserved.
//

#import "MitchellBtn.h"

@implementation MitchellBtn

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageW = 40;
    CGFloat imageH = 47;
    CGFloat imageX = (self.bounds.size.width - imageW) * 0.5;
    CGFloat imageY = 20;
    return CGRectMake(imageX, imageY, imageW, imageH);
}



-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    /**
     *  如果点击事件触发在所设置的区域内，则正常触发事件否则，就让时间不能相应
     */
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, 70);
    if (CGRectContainsPoint(rect, point)==NO) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}
-(void)setHighlighted:(BOOL)highlighted{
}
@end
