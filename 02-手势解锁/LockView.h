//
//  LockView.h
//  02-手势解锁
//
//  Created by Scott_Mr on 15/11/5.
//  Copyright © 2015年 Scott_Mr. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LockView;
@protocol LockViewDelegate <NSObject>

- (void)lockViewDidClick:(LockView *)view andPassWord:(NSString *)psd;

@end

@interface LockView : UIView

@property (nonatomic, weak) IBOutlet id<LockViewDelegate> delegate;

@end
