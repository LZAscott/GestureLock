//
//  LockView.m
//  02-手势解锁
//
//  Created by Scott_Mr on 15/11/5.
//  Copyright © 2015年 Scott_Mr. All rights reserved.
//

#import "LockView.h"

@interface LockView ()

// 用于存储点击之后的按钮
@property (nonatomic, strong) NSMutableArray *buttons;

// 记录当前手指的位置(用于非按钮范围内出现绘制的线条)
@property (nonatomic, assign) CGPoint currentPoint;

@end

@implementation LockView

#pragma mark - 懒加载
- (NSMutableArray *)buttons {
    if (_buttons == nil) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

// 通过代码创建的方式走这里
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpButtons];
    }
    return self;
}

// 通过xib和storyboard创建的情况走这里
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self setUpButtons];
    }
    return self;
}

- (void)setUpButtons {
    for (int i=0; i<9; i++) {
        // 1.创建按钮
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        // 2.设置图片
        [btn setImage:[UIImage imageNamed:@"gesture_node_normal"] forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:@"gesture_node_highlighted"] forState:UIControlStateSelected];
        // 3.添加到view上
        [self addSubview:btn];
        
        // 4.禁止交互(因为要监听触摸事件,防止点击事件触发)
        btn.userInteractionEnabled = NO;
        
        // 5.设置tag，用于验证密码，tag值对应数字
        btn.tag = i;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 每个按钮宽高都固定，因此放到for循环外面
    CGFloat btnW = 74;
    CGFloat btnH = 74;
    // 按钮间距
    CGFloat margin = (self.frame.size.width - 3*btnW)/4;
    
    for (int i=0; i<self.subviews.count; i++) {
        // 1.取出btn
        UIButton *btn = self.subviews[i];
        
        CGFloat btnX = i%3*(btnW+margin)+margin;
        CGFloat btnY = i/3*(btnH+margin)+margin;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 获取手指点击的位置
    CGPoint startPoint = [self getCurrentPointWithTouch:touches];
    // 判断是否在按钮内
    UIButton *btn = [self getButtonWithPoint:startPoint];
    
    if (btn) {
        btn.selected = YES;
        [self.buttons addObject:btn];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    // 获取手指点击的位置
    CGPoint movePoint = [self getCurrentPointWithTouch:touches];
    // 判断是否在按钮内
    UIButton *btn = [self getButtonWithPoint:movePoint];
    
    if (btn && btn.selected != YES) {
        btn.selected = YES;
        [self.buttons addObject:btn];
    }
    
    // 记录当前手指位置
    self.currentPoint = movePoint;
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSMutableString *passWord = [NSMutableString string];
    // 获取密码
    for (UIButton *btn in self.buttons) {
        [passWord appendFormat:@"%ld",btn.tag];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(lockViewDidClick:andPassWord:)]) {
        [self.delegate lockViewDidClick:self andPassWord:passWord];
    }
    
    // 清空屏幕上按钮的选中状态
    for (UIButton *btn in self.buttons) {
        btn.selected = NO;
    }
    //???: 不知道为什么没有效果
//    [self.buttons makeObjectsPerformSelector:@selector(setSelected::) withObject:@(NO)];
    
    
    // 清空按钮数组里面的按钮
    [self.buttons removeAllObjects];
    
    [self setNeedsDisplay];
}

/**
 *  根据手势判断触摸的点
 */
- (CGPoint)getCurrentPointWithTouch:(NSSet<UITouch *> *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:touch.view];
    return point;
}

/**
 *  如果点在按钮的范围之内，则返回按钮，否则返回nil
 */
- (UIButton *)getButtonWithPoint:(CGPoint)point {
    for (int i=0; i<self.subviews.count; i++) {
        UIButton *btn = self.subviews[i];
        if (CGRectContainsPoint(btn.frame, point)) {        // 如果point在按钮范围内
            return btn;
        }
    }
    return nil;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // 清空上下文
    CGContextClearRect(ctx, rect);
    
    for (int i=0; i<self.buttons.count; i++) {
        // 1.取出btn
        UIButton *btn = self.buttons[i];
        if (0 == i) {   // 如果是第一个按钮
            CGContextMoveToPoint(ctx, btn.center.x, btn.center.y);
        }else{
            CGContextAddLineToPoint(ctx, btn.center.x, btn.center.y);
        }
    }
    
    // 判断按钮数组中如果有按钮，就说明不是起点，就可以绘制
    if (self.buttons.count != 0) {
        CGContextAddLineToPoint(ctx, self.currentPoint.x, self.currentPoint.y);
    }
    
    // 设置画笔颜色
    [[UIColor greenColor] set];
    // 设置线条连接的样式
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    // 设置线条两端的样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
    // 设置线条宽度
    CGContextSetLineWidth(ctx, 10);
    // 画线
    CGContextStrokePath(ctx);
}

@end
