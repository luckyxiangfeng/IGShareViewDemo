//
//  IGCusShareView.h
//  Iguama
//
//  Created by Kennith.Zeng on 2018/1/17.
//  Copyright © 2018年 Kennith.Zeng. All rights reserved.
//

#import <UIKit/UIKit.h>
//色值
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define HEXCOLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]
// 界面宽高
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)


@interface IGCusShareView : UIView
- (void)showFromControlle:(UIViewController *)controller;
- (void)setShareContentWithData:(id)data;

@end
@interface IGCusShareItemView : UIView
@property (nonatomic, strong) UIImage *itemImage;
@property (nonatomic, strong) NSString *itemTitle;
@property (nonatomic, strong) NSString *btnActionKey;
@property (nonatomic, copy) void(^returnShareActionKey)(NSString *actionKey);
@end
@interface IGCusShareButton: UIButton

@property (nonatomic, strong) NSString *actionKey;

@end
