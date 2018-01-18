//
//  IGCusShareView.m
//  Iguama
//
//  Created by Kennith.Zeng on 2018/1/17.
//  Copyright © 2018年 Kennith.Zeng. All rights reserved.
//


#import "IGCusShareView.h"
//#import <FBSDKShareKit/FBSDKShareKit.h>
//#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <MessageUI/MessageUI.h>

//色值
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define HEXCOLOR(hex) [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16)) / 255.0 green:((float)((hex & 0xFF00) >> 8)) / 255.0 blue:((float)(hex & 0xFF)) / 255.0 alpha:1]
// 界面宽高
#define SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

#define SHARE_CANCEL_BUTTON_HEIGHT  50  //取消按钮高度
#define SHARE_BODY_VIEW_HEIGHT  105  //bodyview高度
#define SHARE_ITEM_HEIGHT  60   //item 高度
#define SHARE_ITEM_WIDTH  60    //item 宽度
#define SHARE_ITEM_LEFT_MARGIN  15  //左右边距
#define SHARE_ITEM_TOP_MARGIN  5   //顶部边距
#define SHARE_ITEM_TOTALCOLUMNS_COUNT  3  //九宫格
#define SHARE_ITEM_VIEW_WIDTH  (SCREEN_WIDTH-(4*SHARE_ITEM_LEFT_MARGIN))/SHARE_ITEM_TOTALCOLUMNS_COUNT  //ItemView宽度


#define SHARE_CONTENT_VIEW_HEIGHT (SHARE_BODY_VIEW_HEIGHT+SHARE_CANCEL_BUTTON_HEIGHT) //设定初始高度，后面会根据计算改变

NSString *const  IGShareHandleMessenger = @"IGShareHandleMessenger";
NSString *const  IGShareHandleWhatsapp = @"IGShareHandleWhatsapp";
NSString *const  IGShareHandleEmail = @"IGShareHandleEmail";
@interface IGCusShareView()<MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UIControl *maskView;
@property (nonatomic, strong) UIView *contenView;
@property (nonatomic, strong) UIView *bodyView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIViewController *myViewController;
@end
@implementation IGCusShareView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        //初始化分享类别数组，随便添加了几种，随意扩展
        if (!_itemArray) {
            _itemArray = [[NSMutableArray alloc] init];
            NSDictionary *dic1 = @{@"imageName":@"wharsapp_share_btn_icon",@"title":@"Whatsapp",@"action":IGShareHandleWhatsapp};
            NSDictionary *dic2 = @{@"imageName":@"email_share_btn_icon",@"title":@"Mail",@"action":IGShareHandleEmail};
            NSDictionary *dic3 = @{@"imageName":@"share_messenger_btn_icon",@"title":@"Messenger",@"action":IGShareHandleMessenger};
            [_itemArray addObject:dic1];
            [_itemArray addObject:dic2];
            [_itemArray addObject:dic3];
            [_itemArray addObject:dic1];
            [_itemArray addObject:dic2];
            [_itemArray addObject:dic3];
        }
        [self layoutUI];
    }
    
    return self;
}

-(void)layoutUI
{
    if (!_maskView) {
        _maskView = [[UIControl alloc] initWithFrame:self.frame];
        _maskView.backgroundColor = RGBA(0, 0, 0, 0.6);
        _maskView.tag = 100;
        [_maskView addTarget:self action:@selector(maskViewClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_maskView];
    }
    if (!_contenView) {
        _contenView = [[UIView alloc] initWithFrame: CGRectMake(0,  SCREEN_HEIGHT, SCREEN_WIDTH, SHARE_BODY_VIEW_HEIGHT)];
        _contenView.backgroundColor = RGBA(255, 255, 255, 0.9);
        _contenView.userInteractionEnabled = YES;
        [self addSubview:_contenView];
    }
    if (!_bodyView) {
        _bodyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SHARE_BODY_VIEW_HEIGHT)];
        _bodyView.backgroundColor = HEXCOLOR(0xf4f4f4);
        [_contenView addSubview:_bodyView];
    }
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, SHARE_CONTENT_VIEW_HEIGHT-SHARE_CANCEL_BUTTON_HEIGHT, SCREEN_WIDTH, SHARE_CANCEL_BUTTON_HEIGHT)];
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelButton setTitleColor:RGBA(51, 51, 51, 1) forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[self imageWithColor:[UIColor whiteColor] size:CGSizeMake(1.0, 1.0)] forState:UIControlStateNormal];
        [_cancelButton setBackgroundImage:[self imageWithColor:RGBA(234, 234, 234, 1) size:CGSizeMake(1.0, 1.0)] forState:UIControlStateHighlighted];
        [_cancelButton addTarget:self action:@selector(tappedCancel) forControlEvents:UIControlEventTouchUpInside];
        [_contenView addSubview:_cancelButton];
    }

    
    [self configShareBtnItemView];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    UIView *theMaskView = (UIView *)[self viewWithTag:100];
    theMaskView.alpha = 0;
    CGFloat  height = [self getBodyViewHeight];
    CGRect rect = self.bodyView.frame;
    rect.size.height = height;
    self.bodyView.frame = rect;
    
    CGFloat contenViewHeight = height+SHARE_CANCEL_BUTTON_HEIGHT;
    CGRect cancelBtnRect = self.cancelButton.frame;
    cancelBtnRect.origin.y = contenViewHeight-SHARE_CANCEL_BUTTON_HEIGHT;
    self.cancelButton.frame = cancelBtnRect;
    //执行动画
    [UIView animateWithDuration:0.25 animations:^{
        if (_contenView) {
            _contenView.frame = CGRectMake(0, SCREEN_HEIGHT - contenViewHeight, SCREEN_WIDTH, contenViewHeight);
        }
        theMaskView.alpha = 0.6;
        
    } completion:nil];
}

#pragma mark private action

- (void)maskViewClick:(UIControl *)sender {
    [self tappedCancel];
    
}
//消失动画
- (void)tappedCancel {

    [UIView animateWithDuration:0.25 animations:^{
        UIView *theMaskView = (UIView *)[self viewWithTag:100];
        theMaskView.alpha = 0;
        
        if (_contenView) {
            _contenView.frame = CGRectMake(0, SCREEN_HEIGHT,SCREEN_WIDTH, _contenView.frame.size.height);
        }
        
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}
//配置分享种类
- (void)configShareBtnItemView{

    for (int i = 0; i<self.itemArray.count; i++) {
        NSDictionary *dic = self.itemArray[i];
        // 计算行号  和   列号
        int row = i / SHARE_ITEM_TOTALCOLUMNS_COUNT;
        int col = i % SHARE_ITEM_TOTALCOLUMNS_COUNT;
        //根据行号和列号来确定 子控件的坐标
        CGFloat itemX = SHARE_ITEM_LEFT_MARGIN + col * (SHARE_ITEM_VIEW_WIDTH + SHARE_ITEM_LEFT_MARGIN);
        CGFloat itemY = row * (SHARE_BODY_VIEW_HEIGHT + SHARE_ITEM_TOP_MARGIN);
        IGCusShareItemView *itemView = [[IGCusShareItemView alloc] initWithFrame:CGRectMake(itemX, itemY, SHARE_ITEM_VIEW_WIDTH, SHARE_BODY_VIEW_HEIGHT)];
        itemView.itemImage = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[dic objectForKey:@"imageName"]]];
        itemView.itemTitle = [dic objectForKey:@"title"];
        itemView.btnActionKey = [dic objectForKey:@"action"];
        itemView.returnShareActionKey = ^(NSString *actionKey) {
            [self tappedCancel];
            [self pushViewWithActionKey:actionKey];
        };
        [self.bodyView addSubview:itemView];
    }

}
//获取分享种类高度
- (CGFloat)getBodyViewHeight{
    CGFloat height = 0;
    int count = 1;
    if (self.itemArray.count%SHARE_ITEM_TOTALCOLUMNS_COUNT==0) {
        count = 0;
    }
    height =(self.itemArray.count/SHARE_ITEM_TOTALCOLUMNS_COUNT+count)*SHARE_BODY_VIEW_HEIGHT+(self.itemArray.count/SHARE_ITEM_TOTALCOLUMNS_COUNT+count)*SHARE_ITEM_TOP_MARGIN;
    return height;
}


//分享种类事件
- (void)pushViewWithActionKey:(NSString *)actionKey{
    
    if ([actionKey isEqualToString:IGShareHandleMessenger]) {
        [self facebookShareBtnAction];
    }
    if ([actionKey isEqualToString:IGShareHandleWhatsapp]) {
        [self whatsappShareBtnAction];
    }
    if ([actionKey isEqualToString:IGShareHandleEmail]) {
        [self emailShareBtnAction];
    }
    
}


- (void)setShareContentWithData:(id)data{
    
    //设置分享数据
}
//messenger 分享
- (void)facebookShareBtnAction{
    NSLog(@"messenger分享");
    /*
    FBSDKShareMessengerURLActionButton *urlButton = [[FBSDKShareMessengerURLActionButton alloc] init];
    urlButton.title =@"标题";
    urlButton.url = @"https://www.baidu.com";
    
    FBSDKShareMessengerGenericTemplateElement *element = [[FBSDKShareMessengerGenericTemplateElement alloc] init];
    element.title = @"标题";
    element.subtitle = @"副标题";
    element.imageURL = [NSURL URLWithString:model.image_url];
    element.button = urlButton;
    
    FBSDKShareMessengerGenericTemplateContent *content = [[FBSDKShareMessengerGenericTemplateContent alloc] init];
    content.pageID = @"";// Your page ID, required for attribution
    content.element = element;
    
    FBSDKMessageDialog *messageDialog = [[FBSDKMessageDialog alloc] init];
    messageDialog.shareContent = content;
    
    if ([messageDialog canShow]) {
        [messageDialog show];
    }
    */
     
}
//whatsapp 分享
- (void)whatsappShareBtnAction{
    NSLog(@"whatsapp分享");
    NSString *content = [@"内容内容内容" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",content]];
    if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
        [[UIApplication sharedApplication] openURL: whatsappURL];
    }
     
}
//邮件分享
- (void)emailShareBtnAction{
    //判断用户是否已设置邮件账户
    if ([MFMailComposeViewController canSendMail]) {
        [self sendEmailActionWithModel:nil];
    }else{
        //给出提示,设备未开启邮件服务
//        [SVProgressHUD showInfoWithStatus:@"设备未开启邮件服务"];
        NSLog(@"设备未开启邮件服务");
    }
    
}

-(void)sendEmailActionWithModel:(id)model{
    // 创建邮件发送界面
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置收件人
    [mailCompose setToRecipients:nil];
    // 设置抄送人
    [mailCompose setCcRecipients:nil];
    // 设置密送人
    [mailCompose setBccRecipients:nil];
    // 设置邮件主题
    [mailCompose setSubject:@"邮件标题"];
    //设置邮件的正文内容
    NSString *emailContent =@"邮件内容";
    // 是否为HTML格式
    [mailCompose setMessageBody:emailContent isHTML:YES];
    // 如使用HTML格式，则为以下代码
    // [mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    //添加附件
    //    UIImage *image = [UIImage imageNamed:@"notification_none_image_icon"];
    //    NSData *imageData = UIImagePNGRepresentation(image);
    //    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"qq.png"];
    //    NSString *file = [[NSBundle mainBundle] pathForResource:@"EmptyPDF" ofType:@"pdf"];
    //    NSData *pdf = [NSData dataWithContentsOfFile:file];
    //    [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"EmptyPDF.pdf"];
    // 弹出邮件发送视图
    [self.myViewController presentViewController:mailCompose animated:YES completion:nil];
}

//颜色生成图片方法
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size {
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

#pragma mark public action
//展示分享页面
- (void)showFromControlle:(UIViewController *)controller{
    self.myViewController = controller;
    [controller.view.window addSubview:self];
    
}


#pragma mark - MFMailComposeViewControllerDelegate的代理方法：
-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled: 用户取消编辑");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: 用户保存邮件");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent: 用户点击发送");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@ : 用户尝试保存或发送邮件失败", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self.myViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

//分享种类每个ITEMVIEW ，直接写在一个类，方便使用
@interface IGCusShareItemView()

@property (nonatomic, strong) IGCusShareButton *itemButton;
@property (nonatomic, strong) UILabel *itemTitleLab;
@end

@implementation IGCusShareItemView
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self layoutUI];
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

-(void)layoutUI
{

    if (!_itemButton) {
        _itemButton = [[IGCusShareButton alloc] initWithFrame:CGRectMake(((CGRectGetWidth(self.frame)-SHARE_ITEM_WIDTH)/2), 15, SHARE_ITEM_WIDTH, SHARE_ITEM_HEIGHT)];
        [_itemButton setBackgroundColor:[UIColor clearColor]];
        [_itemButton addTarget:self action:@selector(itemButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_itemButton];
    }
    if (!_itemTitleLab) {
        _itemTitleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_itemButton.frame)+5, CGRectGetWidth(self.frame), 15)];
        _itemTitleLab.font = [UIFont systemFontOfSize:10];
        _itemTitleLab.backgroundColor = [UIColor clearColor];
        _itemTitleLab.textAlignment = NSTextAlignmentCenter;
        _itemTitleLab.numberOfLines = 1;
        [self addSubview:_itemTitleLab];
    }
    
}



#pragma mark private action
- (void)itemButtonAction:(IGCusShareButton *)btn{

    if (self.returnShareActionKey) {
        self.returnShareActionKey(btn.actionKey);
    }
    
}

#pragma mark pubilc action
//设置图片
- (void)setItemImage:(UIImage *)itemImage{
    
    [self.itemButton setImage:itemImage forState:UIControlStateNormal];
    
}
//设置动作
- (void)setBtnActionKey:(NSString *)actionKey{
    
    self.itemButton.actionKey = actionKey;
    
}
//设置标题
- (void)setItemTitle:(NSString *)itemTitle{
    
    self.itemTitleLab.text = itemTitle;
    
}

@end
//自定义按钮
@implementation IGCusShareButton


@end


