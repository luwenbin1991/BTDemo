//
//  JOBTSecondViewController.m
//  BTDemo
//
//  Created by SPRT on 14-10-31.
#import <Foundation/Foundation.h>//

#import "JOBTSecondViewController.h"
#import "SPRTPrint.h"
int cmd=0;

extern CBPeripheral *activeDevice;
extern CBCharacteristic *activeWriteCharacteristic;
extern CBCharacteristic *activeReadCharacteristic;
extern CBCharacteristic *activeFlowControlCharacteristic;
extern int mtu;
extern int credit;
extern int response;

extern int cjFlag;          // qzfeng 2016/05/10

id<CBPeripheralDelegate> deviceDelegate=nil;

@interface JOBTSecondViewController ()

@end

@implementation JOBTSecondViewController

NSThread *thread = NULL;

@synthesize textView_SendData;
@synthesize statusText;
@synthesize centralManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
	 
    deviceDelegate = self;
    if(activeDevice)
    {
        activeDevice.delegate = deviceDelegate;
    }
    centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}
- (void)viewDidAppear:(BOOL)animated
{
    deviceDelegate = self;
    if(activeDevice)
    {
        activeDevice.delegate = deviceDelegate;
    }
}

- (void)viewDidUnload
{
    
    [self setTextView_SendData:nil];
    [super viewDidUnload];
		
    /*if(activeDevice)
    {
        activeDevice.delegate = nil;
    }*/
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        //return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return YES;
    }
}

- (IBAction)buttonCompleteInputContent:(id)sender {

    [textView_SendData resignFirstResponder];
}

- (IBAction)buttonSend:(id)sender {
    NSData* data;
    //if(activeDevice!=nil && activeDevice.isConnected)
    if(activeDevice!=nil && activeDevice.state==CBPeripheralStateConnected)
    {
       
        if (isSwitchOn)//16进制数据,hex->NSData
        {
            NSLog(@"text=%d",[textView_SendData.text length]);
            if (([textView_SendData.text length]%2)!=0 )
            {
                [self alertMessage:@"请输入偶数个字符a-f/A-F，0-9"];
                return;
            }
            
            Byte bt[[textView_SendData.text length]/2];
            for (int i=0;i<[textView_SendData.text length];i=i+2)
            {
                int result=0;
                unichar ch = [textView_SendData.text characterAtIndex:i];
                if (ch>='0' && ch<='9') result = (ch-'0')*16;
                else if (ch>='a' && ch<='f') result = (ch-'a'+10)*16;
                else if (ch>='A' && ch<='F') result = (ch-'A'+10)*16;
                else
                {
                    [self alertMessage:@"请输入16进制字符a-f/A-F，0-9"];
                    return;
                }
                ch = [textView_SendData.text characterAtIndex:(i+1)];
                if (ch>='0' && ch<='9') result += (ch-'0');
                else if (ch>='a' && ch<='f') result += (ch-'a'+10);
                else if (ch>='A' && ch<='F') result += (ch-'A'+10);
                else
                {
                    [self alertMessage:@"请输入16进制字符a-f/A-F，0-9"];
                    return;
                }

                bt[i/2]=result;
            }
            data = [[NSData alloc]initWithBytes:bt length:[textView_SendData.text length]/2];
            NSLog(@"data=%@",data);
        }
        else//文本数据
        {
            //转换成GB2312编码之后，再发送给打印机,否则打印机无法打印
            NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            data=[textView_SendData.text dataUsingEncoding:enc];
            if(data == nil)
            {//转换失败的话，我们转换为UTF8编码，但这个时候只能够打印英文字母
                data = [textView_SendData.text dataUsingEncoding:NSUTF8StringEncoding];
            }
        }
       
        

        if(![SPRTPrint printBin:data])
        {
            [self alertMessage:@"发送数据失败"];
        }
        
       
    }
    else {
        [self alertMessage:@"请连接设备后再发送数据"];
    }
}

- (IBAction)buttonClear:(id)sender {
    self.textView_SendData.text = nil;

    self.statusText.text = nil;
    
}

- (IBAction)buttonPageModePrint:(id)sender {
    if(cjFlag==0){          // qzfeng 2016/05/10
        if (thread == NULL) {
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(pageModePrintThreadProc:) object:sender];
            [thread start];
        } else {
            NSLog(@"Already running");
        }
    } // qzfeng 2016/05/10
    // qzfeng begin 2016/05/10
    else
    {
        [self pageModePrint];
    }
    // qzfeng end 2016/05/10
}

// qzfeng begin 2016/05/10
-(void) pageModePrint {
    /*********************************************************/
    /*
     圆通接口调用; 2015/12/08
     */
    /*********************************************************/
    
    [SPRTPrint pageSetup:560 pageHeightNum:1550];
    [SPRTPrint drawBox:2 leftX:2 leftY:1 rightX:560 rightY:(256+168+128)];      // 第一联边框;
    [SPRTPrint drawLine:2 startX:2 startY:256 endX:560 endY:256 isFullline:false]; // 第一联横线1;
    [SPRTPrint drawLine:2 startX:2 startY:(256+168) endX:(560-32) endY:(256+168) isFullline:false]; // 第一联横线2;
    [SPRTPrint drawLine:2 startX:(2+40) startY:256 endX:(2+40) endY:(256+168+128) isFullline:false]; // 第一联竖线1,从左到右;
    [SPRTPrint drawLine:2 startX:(2+416) startY:(256+168) endX:(2+416) endY:(256+168+128) isFullline:false]; // 第二联竖线2,从左到右;
    [SPRTPrint drawLine:2 startX:(560-32) startY:256 endX:(560-32) endY:(256+168+128) isFullline:false]; // 第一联竖线3,从左到右;
    
    // 目的地;
    [SPRTPrint drawText:(2+320) textY:16 textStr:@"湖南" fontSizeNum:6 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 代收货款；
    [SPRTPrint drawText:(2+8) textY:144 textStr:@"代收货款" fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    // 金额；
    [SPRTPrint drawText:(2+8) textY:(144+48+8) textStr:@"金额" fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 具体金额；
    [SPRTPrint drawText:(2+8+80) textY:(144+48+8) textStr:@"10.0元" fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    // 条码；
    [SPRTPrint drawBarCode:(2+232) startY:135 textStr:@"899900311642" typeNum:1 roateNum:0 lineWidthNum:3 heightNum:80];
    // 条码字符；
    [SPRTPrint drawText:(2+290) textY:216 textStr:@"899900311642" fontSizeNum:3 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件人；
    [SPRTPrint drawText:(2+4) textY:(256+32) widthNum:32 heightNum:120 textStr:@"收件人" fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    // 收件人姓名+电话；
    [SPRTPrint drawText:(2+4+32+8) textY:264 widthNum:480 heightNum:32 textStr:@"付道辉 13031036400" fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    // 收件人地址；
    [SPRTPrint drawText:(2+4+32+8) textY:(264+40) widthNum:448 heightNum:120 textStr:@"北京海淀区永丰屯诚信公寓" fontSizeNum:3 rotateNum:0 isBold:1 isUnderLine:false isReverse:false];
    // 寄件人；
    [SPRTPrint drawText:(2+8) textY:448 widthNum:32 heightNum:96 textStr:@"寄件人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人姓名+电话；
    [SPRTPrint drawText:(2+4+32+8) textY:432 widthNum:480 heightNum:24 textStr:@"刘霞飞 18515135009" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人地址；
    [SPRTPrint drawText:(2+4+32+8) textY:(432+30) widthNum:344 heightNum:112 textStr:@"河南省固始县固始县" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 签收人；
    [SPRTPrint drawText:(2+424) textY:432 textStr:@"签收人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 日期；
    [SPRTPrint drawText:(2+424) textY:520 textStr:@"日期" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 派件联；
    [SPRTPrint drawText:(2+532) textY:368 widthNum:32 heightNum:96 textStr:@"派件联" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 虚线;
    [SPRTPrint drawLine:2 startX:2 startY:(552+8) endX:560 endY:(552+8) isFullline:false];
    
    // 第二联；
    [SPRTPrint drawBox:2 leftX:2 leftY:568 rightX:560 rightY:(568+448)];    //第二联边框；
    [SPRTPrint drawLine:2 startX:2 startY:(568+32) endX:560 endY:(568+32) isFullline:false];    // 第二联横线1，从左到右；
    
    [SPRTPrint drawLine:2 startX:2 startY:(568+32+128) endX:(560-32) endY:(568+32+128) isFullline:false];   // 第二联横线2，从左到右；
    
    [SPRTPrint drawLine:2 startX:2 startY:(568+32+128+112) endX:(560-32) endY:(568+32+128+112) isFullline:false];    // 第二联横线3，从左到右；
    
    [SPRTPrint drawLine:2 startX:(2+40) startY:(568+32+128+112+144) endX:(560-32) endY:(568+32+128+112+144) isFullline:false];    // 第二联横线4，从左到右；
    
    [SPRTPrint drawLine:2 startX:(2+40) startY:(568+32) endX:(2+40) endY:(568+448) isFullline:false];    // 第二联竖线1，从左到右
    
    [SPRTPrint drawLine:2 startX:(560-32) startY:(568+32) endX:(560-32) endY:(568+448) isFullline:false];    // 第二联竖线2，从左到右
    
    // 运单号+订单号；
    [SPRTPrint drawText:(2+8) textY:(568+8) textStr:@"运单号：899900311642     订单号：8786870025" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件人；
    [SPRTPrint drawText:(2+8) textY:624 widthNum:32 heightNum:96 textStr:@"收件人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件人姓名+电话；
    [SPRTPrint drawText:(2+8+32+8) textY:608 widthNum:480 heightNum:24 textStr:@"付道辉 13031036400" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件地址；
    [SPRTPrint drawText:(2+8+32+8) textY:640 widthNum:424 heightNum:80 textStr:@"北京海淀区永丰屯诚信公寓" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人;
    [SPRTPrint drawText:(2+8) textY:744 widthNum:32 heightNum:96 textStr:@"寄件人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人姓名+电话；
    [SPRTPrint drawText:(2+4+32+8) textY:736 widthNum:480 heightNum:24 textStr:@"刘霞飞 18515135009" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人地址；
    [SPRTPrint drawText:(2+4+32+8) textY:768 widthNum:456 heightNum:72 textStr:@"河南省固始县固始县" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 内容品名；
    [SPRTPrint drawText:(2+8) textY:872 widthNum:32 heightNum:120 textStr:@"内容品名" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 内容品名具体；
    [SPRTPrint drawText:(2+4+32+8) textY:848 widthNum:432 heightNum:136 textStr:@"食用油" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 数量；
    [SPRTPrint drawText:(2+4+32+8) textY:988 textStr:@"数量:1" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 重量；
    [SPRTPrint drawText:(2+400) textY:988 textStr:@"重量:1.0kg" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件联；
    [SPRTPrint drawText:(2+532) textY:776 widthNum:32 heightNum:96 textStr:@"收件联" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 虚线；
    [SPRTPrint drawLine:2 startX:2 startY:(568+448+8) endX:560 endY:(568+448+8) isFullline:false];
    
    // 第三联
    [SPRTPrint drawBox:2 leftX:2 leftY:(1016+16) rightX:560 rightY:(1016+16+480)];          // 第三联边框;
    
    [SPRTPrint drawLine:2 startX:2 startY:(1016+16+104) endX:560 endY:(1016+16+104) isFullline:false];  // 第三联横线1，从左到右；
    
    [SPRTPrint drawLine:2 startX:2 startY:(1016+16+104+104) endX:(560-32) endY:(1016+16+104+104) isFullline:false];  // 第三联横线2，从左到右；
    
    [SPRTPrint drawLine:2 startX:2 startY:(1016+16+104+104+104) endX:(560-32) endY:(1016+16+104+104+104) isFullline:false];  // 第三联横线3，从左到右；
    
    [SPRTPrint drawLine:2 startX:(2+40) startY:(1016+16+104+104+104+32) endX:(560-32) endY:(1016+16+104+104+104+32) isFullline:false];  // 第三联横线4，从左到右；
    
    [SPRTPrint drawLine:2 startX:(2+40) startY:(1016+16+480-32) endX:(560-32) endY:(1016+16+480-32) isFullline:false];  // 第三联横线5，从左到右；
    
    [SPRTPrint drawLine:2 startX:(2+40) startY:(1016+16+104) endX:(2+40) endY:(1016+16+480) isFullline:false];  // 第三联竖线1，从左到右；
    
    [SPRTPrint drawLine:2 startX:(560-32) startY:(1016+16+104) endX:(560-32) endY:(1016+16+480) isFullline:false];  // 第三联竖线2，从左到右；
    
    // 条码;
    [SPRTPrint drawBarCode:(2+250) startY:1040 textStr:@"899900311642" typeNum:1 roateNum:0 lineWidthNum:3 heightNum:56];
    // 条码数据;
    [SPRTPrint drawText:(2+312) textY:1100 textStr:@"899900311642" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件人；
    [SPRTPrint drawText:(2+8) textY:1148 widthNum:32 heightNum:96 textStr:@"收件人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件人姓名+电话；
    [SPRTPrint drawText:(2+8+32+8) textY:1140 widthNum:480 heightNum:24 textStr:@"付道辉 13031036400" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 收件地址；
    [SPRTPrint drawText:(2+8+32+8) textY:1172 widthNum:456 heightNum:64 textStr:@"北京海淀区永丰屯诚信公寓" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人;
    [SPRTPrint drawText:(2+8) textY:1252 widthNum:32 heightNum:96 textStr:@"寄件人" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人姓名+电话；
    [SPRTPrint drawText:(2+4+32+8) textY:1244 widthNum:480 heightNum:24 textStr:@"刘霞飞 18515135009" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件人地址；
    [SPRTPrint drawText:(2+4+32+8) textY:1276 widthNum:456 heightNum:72 textStr:@"河南省固始县固始县" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 内容品名；
    [SPRTPrint drawText:(2+8) textY:1380 widthNum:32 heightNum:120 textStr:@"内容品名" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 订单号;
    [SPRTPrint drawText:(2+4+32+8) textY:1348 textStr:@"订单号：8786870025" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 内容品名具体；
    [SPRTPrint drawText:(2+4+32+8) textY:1380 widthNum:432 heightNum:136 textStr:@"食用油" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 数量；
    [SPRTPrint drawText:(2+4+32+8) textY:1484 textStr:@"数量:1" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 重量；
    [SPRTPrint drawText:(2+400) textY:1484 textStr:@"重量:1.0kg" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    // 寄件联；
    [SPRTPrint drawText:(2+532) textY:1272 widthNum:32 heightNum:96 textStr:@"寄件联" fontSizeNum:2 rotateNum:0 isBold:0 isUnderLine:false isReverse:false];
    
    [SPRTPrint print:0 skipNum:1];
    
    
    
}
// qzfeng end 2016/05/10

//页模式下页的大小跟具体型号有关，demo的这个版本x最大为576，y为350
- (IBAction)pageModePrintThreadProc:(id)sender
{

    [self pageModePrint];           // qzfeng 2016/05/10
    
    /*********************************************************/
 	
   /* //定义页：水平偏移从0开始，水平和垂直分辨率为203，页高为350
    [SPRTPrint printTxt:@"! 0 200 200 350 1\n"];
    //居中:从text命令的x起始到行末结束计算居中位置
    [SPRTPrint printTxt:@"CENTER\n"];
    //倍高倍宽
    [SPRTPrint printTxt:@"TEXT 24 11 0 0 斯普瑞特打印机打印测试\n"];
    //靠左，正常一文本行占32点行
    [SPRTPrint printTxt:@"LEFT\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 150 96 中华\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 150 128 人民共和国\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 150 160 万岁！\n"];
    //打印二维码:范围M 2，倍数U 6，位置 (x,y)=(276,64)
    [SPRTPrint printTxt:@"B QR 276 64 M 2 U 6\n"];
    //纠错等级M，自动选择版本号
    [SPRTPrint printTxt:@"QA,http://sprinter.com.cn-中国\n"];
    [SPRTPrint printTxt:@"ENDQR\n"];
    //页定义结束，开始真正打印
    [SPRTPrint printTxt:@"PRINT\n"];
    //走纸几行-非页模式指令
    [SPRTPrint printTxt:@"打印结束\n\n\n\n\n\n"];*/
    
    
   /*
    [SPRTPrint printTxt:@"! 0 200 200 720 1\n"];
    [SPRTPrint printTxt:@"PW 600\n"];
    [SPRTPrint printTxt:@"LINE 12 120 560 120 4\n"];
    [SPRTPrint printTxt:@"LINE 12 120 12 652 2\n"];
    [SPRTPrint printTxt:@"LINE 560 652 12 652 4\n"];
    [SPRTPrint printTxt:@"LINE 560 120 560 652 2\n"];
    [SPRTPrint printTxt:@"LINE 12 120 564 120 4\n"];
    [SPRTPrint printTxt:@"LINE 12 200 564 200 4\n"];
    [SPRTPrint printTxt:@"LINE 12 280 564 280 4\n"];
    [SPRTPrint printTxt:@"LINE 12 360 564 360 4\n"];
    [SPRTPrint printTxt:@"LINE 12 424 564 424 4\n"];
    [SPRTPrint printTxt:@"LINE 12 504 564 504 4\n"];
    [SPRTPrint printTxt:@"LINE 404 560 564 560 4\n"];
    [SPRTPrint printTxt:@"LINE 12 656 564 656 4\n"];
    [SPRTPrint printTxt:@"LINE 284 0 284 120 1\n"];
    [SPRTPrint printTxt:@"LINE 92 200 92 504 2\n"];
    [SPRTPrint printTxt:@"LINE 404 120 404 360 1\n"];
    [SPRTPrint printTxt:@"LINE 404 504 404 656 1\n"];
    [SPRTPrint printTxt:@"LINE 187 360 187 424 2\n"];
    [SPRTPrint printTxt:@"LINE 282 360 282 424 2\n"];
    [SPRTPrint printTxt:@"LINE 377 360 377 424 2\n"];
    [SPRTPrint printTxt:@"LINE 472 360 472 424 2\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 55 33 328 28 定时达\n"];
    [SPRTPrint printTxt:@"INVERSE-LINE 286 4 560 4 116\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 55 33 16 128 DF1234567890\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 216 目的\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 240 分拨\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 296 到达\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 320 网点\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 380 路径\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 440 详细\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 28 464 地址\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 55 11 184 224 西安长线\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 1\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 55 11 184 304 思普瑞特\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 102 380 第1件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 197 380 第2件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 292 380 第1件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 387 380 第1件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 482 380 第1件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 102 440 陕西省西安市临潼区秦始皇陵兵马俑一号\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 102 464 坑五排三列俑\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 412 568 测试二级网点\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 412 600 (2015-11-10\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 430 624 11:30:20)\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 454 148 第1件\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 460 228 袋装\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 55 11 452 304 派送\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 484 520 10\n"];
    [SPRTPrint printTxt:@"BA 12 520 404 608 1\n"];
    [SPRTPrint printTxt:@"B 128 1 1 104 12 520 DF12345678900010292001\n"];
    [SPRTPrint printTxt:@"BA 0 0 0 0 3\n"];
    [SPRTPrint printTxt:@"UT 0\n"];
    [SPRTPrint printTxt:@"SETBOLD 0\n"];
    [SPRTPrint printTxt:@"IT 0\n"];
    [SPRTPrint printTxt:@"TEXT 24 0 76 628 DF12345678900010292001\n"];
    [SPRTPrint printTxt:@"PR 0\n"];
    [SPRTPrint printTxt:@"FORM\n"];
    [SPRTPrint printTxt:@"PRINT\n"];
    */
    /*
    //走纸几行-非页模式指令
    [SPRTPrint printTxt:@"打印结束\n\n\n\n\n\n"];*/
    
    thread = NULL;
}

- (IBAction)buttonPrintPNGorJPG:(id)sender {
    
    if(cjFlag==0){          // qzfeng 2016/05/10
        if (thread == NULL) {
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(printPNGorJPGThreadProc:) object:sender];
            [thread start];
        } else {
            NSLog(@"Already running");
        }
    } // qzfeng 2016/05/10
    // qzfeng begin 2016/05/10
    else
    {
        [SPRTPrint printTxt:@"\n打印图片！\n\n"];
        
        [SPRTPrint printPNG_JPG:@"print.png" offset:0];
        /*
         [SPRTPrint printPNG_JPG:@"print.png" offset:10];
         [SPRTPrint printPNG_JPG:@"print.png" offset:15];
         [SPRTPrint printPNG_JPG:@"print.png" offset:20];
         */
        //走纸几行-非页模式指令
        [SPRTPrint printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
    }
    // qzfeng end 2016/05/10
    
    
    

   /*
    [SPRTPrint printTxt:@"\n打印图片1\n\n"];
    
    [SPRTPrint printPNG_JPG:@"print.png" offset:0];
    
    [SPRTPrint printTxt:@"\n\n打印图片2\n\n\n\n\n\n"];
    [SPRTPrint printPNG_JPG:@"print.png" offset:10];
    [SPRTPrint printTxt:@"\n\n打印图片3\n\n\n\n\n\n"];
    [SPRTPrint printPNG_JPG:@"print.png" offset:15];
    [SPRTPrint printTxt:@"\n\n打印图片\n\n\n\n\n\n"];
    [SPRTPrint printPNG_JPG:@"print.png" offset:20];
     [SPRTPrint printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
     */
    //走纸几行-非页模式指令
}

- (IBAction)printPNGorJPGThreadProc:(id)sender
{
    [SPRTPrint printTxt:@"\n打印图片！\n\n"];

    [SPRTPrint printPNG_JPG:@"print.png" offset:0];
    /*
     [SPRTPrint printPNG_JPG:@"print.png" offset:10];
     [SPRTPrint printPNG_JPG:@"print.png" offset:15];
     [SPRTPrint printPNG_JPG:@"print.png" offset:20];
     */
    //走纸几行-非页模式指令
    [SPRTPrint printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
    
    thread = NULL;
}


// qzfeng begin 2016/05/10
- (void)printPage {
    Byte bitmapLine1[]= {0x3f,0x3f,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x30,0x3f,0x3f};
    
    Byte bitmapLine2[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine3[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine4[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine5[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine6[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine7[]= {0xff,0xff,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xff,0xff};
    Byte bitmapLine8[]= {0xfc,0xfc,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0x0c,0xfc,0xfc};
    
    
    NSData *data;
    
    //居中打印，对齐指令需要在行首发
    [SPRTPrint printAlignCenter];
    BOOL ret=[SPRTPrint printTxt:@"斯普瑞特打印机打印测试1111111111111111\n\n\n"];
    if (ret!=YES) NSLog(@"ret fail");
    
    NSLog(@"qzf come here00");
    
    
    [SPRTPrint printAlignCenter];
    [SPRTPrint printTxt:@"调用1b 61 1居中打印\n居中打印\n居中打印\n\n\n\n"];
    
    
    //靠右打印
    [SPRTPrint printAlignRight];
    
    [SPRTPrint printTxt:@"调用1b 61 2靠右打印\n靠右打印\n靠右打印\n\n\n\n"];
    
    //靠左打印
    [SPRTPrint printAlignLeft];
    [SPRTPrint printTxt:@"调用1b 61 0恢复靠左打印\n靠左打印\n靠左打印\n\n\n"];
    
    //加大行距ESC 3 n(1b 33 n)
    [SPRTPrint setLineHeight:255];
    [SPRTPrint printTxt:@"调用ESC 3 n加大行距\n加大行距\n加大行距\n"];
    [SPRTPrint restoreDefaultLineHeight];
    [SPRTPrint printTxt:@"调用ESC 2恢复默认行距\n恢复默认行距\n恢复默认行距\n\n\n\n"];
    
    
    //设置标准ascii字符加粗、倍高、倍宽、下划线打印
    [SPRTPrint printTxt:@"调用ESC ! n 设置标准ascii字符加粗、倍高、倍宽、下划线打印\n"];
    [SPRTPrint setAsciiWordFormat:0 bold:YES doubleHeight:YES doubleWidth:YES underline:YES];
    [SPRTPrint printTxt:@"12345abcdefghijklmnopq\n"];
    [SPRTPrint printTxt:@"12345abcdefghijklmnopq\n"];
    [SPRTPrint printTxt:@"12345abcdefghijklmnopq\n"];
    
    //清除标准ascii字符加粗、倍高、倍宽、下划线打印
    [SPRTPrint setAsciiWordFormat:0 bold:NO doubleHeight:NO doubleWidth:NO underline:NO];
    [SPRTPrint printTxt:@"调用ESC ! n 清除标准ascii字符加粗、倍高、倍宽、下划线打印\n"];
    [SPRTPrint printTxt:@"12345abcdefghijklmnopq\n"];
    [SPRTPrint printTxt:@"1234567890abcdefghijklmnopq\n"];
    [SPRTPrint printTxt:@"1234567890abcdefghijklmnopq\n\n\n"];
    
    
    //设置汉子字符加粗、倍高、倍宽、下划线打印
    [SPRTPrint printTxt:@"调用FS ! n设置倍高、倍宽、下划线打印\n"];
    [SPRTPrint setChineseWordFormat:YES doubleWidth:YES underline:YES];
    [SPRTPrint printTxt:@"思普瑞特汉字打印测试\n"];
    [SPRTPrint printTxt:@"思普瑞特汉字打印测试\n"];
    [SPRTPrint printTxt:@"思普瑞特汉字打印测试\n"];
    
    //清除汉子字符加粗、倍高、倍宽、下划线打印
    [SPRTPrint setChineseWordFormat:NO doubleWidth:NO underline:NO];
    [SPRTPrint printTxt:@"调用FS ! n清除倍高、倍宽、下划线打印\n"];
    [SPRTPrint printTxt:@"思普瑞特打印机汉字打印测试\n"];
    [SPRTPrint printTxt:@"思普瑞特打印机汉字打印测试\n"];
    [SPRTPrint printTxt:@"思普瑞特打印机汉字打印测试\n\n\n"];
    
    
    
    [SPRTPrint printAlignCenter];
    //打印一个位图
    [SPRTPrint printTxt:@"打印位图\n"];
    [SPRTPrint setLineHeight:0];       //设置行间距为0
    //NSLog(@"bitmaplength=%d",sizeof(bitmap));
    data=[[NSData alloc] initWithBytes:bitmapLine1 length:sizeof(bitmapLine1)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine2 length:sizeof(bitmapLine2)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine3 length:sizeof(bitmapLine3)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine4 length:sizeof(bitmapLine4)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine5 length:sizeof(bitmapLine5)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine6 length:sizeof(bitmapLine6)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine7 length:sizeof(bitmapLine7)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    data=[[NSData alloc] initWithBytes:bitmapLine8 length:sizeof(bitmapLine8)];
    [SPRTPrint printBitMap:0 bitmap:data];
    [SPRTPrint printTxt:@"\n"];
    [SPRTPrint restoreDefaultLineHeight];   //恢复行间距
    [SPRTPrint printTxt:@"\n\n\n"];
    
    
    //打印一维条码
    [SPRTPrint printTxt:@"打印一维条码1\n"];
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    //data=[@"ABC4567abc" dataUsingEncoding:enc];
    
    // 打印"123456789123456789"
    data=[@"123456789123456789" dataUsingEncoding:enc];
    Byte dataBytes[256]={0x00};
    int dataBytesLen=0;
    [SPRTPrint getCodeCByte:data content3:dataBytes retLen:&dataBytesLen];
    
    data=[@"" dataUsingEncoding:enc];
    
    [SPRTPrint print128BarCode:2 height2:48 txtpositon2:POS_BT_HT_DOWN content0:data content2:dataBytes length2:dataBytesLen];
    
    //打印一维条码
    [SPRTPrint printTxt:@"打印一维条码2\n"];
    
    [SPRTPrint print128BarCode:2 height2:150 txtpositon2:POS_BT_HT_DOWN content0:data content2:dataBytes length2:dataBytesLen];
    
    data=[@"NO." dataUsingEncoding:enc];
    //打印一维条码
    [SPRTPrint printTxt:@"打印一维条码3\n"];
    
    [SPRTPrint print128BarCode:2 height2:48 txtpositon2:POS_BT_HT_DOWN content0:data content2:dataBytes length2:dataBytesLen];
    
    //打印一维条码
    [SPRTPrint printTxt:@"打印一维条码4\n"];
    
    [SPRTPrint print128BarCode:2 height2:150 txtpositon2:POS_BT_HT_DOWN content0:data content2:dataBytes length2:dataBytesLen];
    
    /*
     [SPRTPrint print1DBarCode:POS_BT_CODE128 width:2 height:150 txtpositon:POS_BT_HT_DOWN content:data];
     
     data=[@"12345" dataUsingEncoding:enc];
     
     [SPRTPrint print1DBarCode:POS_BT_CODE39 width:2 height:150 txtpositon:POS_BT_HT_DOWN content:data];
     */
    
    
    //打印二位条码
    [SPRTPrint printTxt:@"打印二维条码\n"];
    data=[@"www.sina.com-中国" dataUsingEncoding:enc];
    [SPRTPrint print2DBarCode:POS_BT_PDF417 para1:2 para2:6 para3:1 content:data];
    
    data=[@"www.sina.com-北京市" dataUsingEncoding:enc];
    [SPRTPrint print2DBarCode:POS_BT_DATAMATRIX para1:40 para2:40 para3:4 content:data];
    
    data=[@"www.sina.com-石家庄" dataUsingEncoding:enc];
    [SPRTPrint print2DBarCode:POS_BT_QRCODE para1:2 para2:77 para3:4 content:data];
    
    
    //
    NSLog(@"qzf come here33");
    
    [SPRTPrint printTxt:@"\n\n\n\n切纸\n"];
    [SPRTPrint cutPaper:0 feed_distance:0];
    
    [SPRTPrint printTxt:@"打印测试完毕！\n\n\n\n\n\n"];
    [SPRTPrint printAlignLeft];
    [SPRTPrint printTxt:@"\n"];
    
    
    [SPRTPrint printTxt:@"\n打印图片1\n\n"];
    
    [SPRTPrint printPNG_JPG:@"print.png" offset:0];
    
    /*
     [SPRTPrint printTxt:@"\n\n打印图片2\n\n\n\n\n\n"];
     [SPRTPrint printPNG_JPG:@"print.png" offset:10];
     [SPRTPrint printTxt:@"\n\n打印图片3\n\n\n\n\n\n"];
     [SPRTPrint printPNG_JPG:@"print.png" offset:15];
     [SPRTPrint printTxt:@"\n\n打印图片\n\n\n\n\n\n"];
     [SPRTPrint printPNG_JPG:@"print.png" offset:20];
     [SPRTPrint printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
     */
    
    [SPRTPrint printTxt:@"\n打印图片1\n\n"];
    
    [SPRTPrint printPNG_JPG:@"print.png" offset:0];
    
    [SPRTPrint printTxt:@"\n\n打印图片2\n\n\n\n\n\n"];
    [SPRTPrint printPNG_JPG:@"print.png" offset:10];
    /*
     [SPRTPrint printTxt:@"\n\n打印图片3\n\n\n\n\n\n"];
     [SPRTPrint printPNG_JPG:@"print.png" offset:15];
     [SPRTPrint printTxt:@"\n\n打印图片\n\n\n\n\n\n"];
     [SPRTPrint printPNG_JPG:@"print.png" offset:20];
     */
    
    [SPRTPrint printTxt:@"\n\n打印图片结束\n\n\n\n\n\n"];
    
}
// qzfeng end 2016/05/10

- (void)printPageThreadProc:(id)sender {
    
    [self printPage];           // qzfeng 2016/05/10
    
    thread = NULL;
}

- (IBAction)buttonPrintPage:(id)sender
{
    
    if(cjFlag==0){          // qzfeng 2016/05/10
        if (thread == NULL) {
            thread = [[NSThread alloc] initWithTarget:self selector:@selector(printPageThreadProc:) object:sender];
            [thread start];
        } else {
            NSLog(@"Already running");
        }

    } // qzfeng 2016/05/10
    // qzfeng begin 2016/05/10
    else
    {
        [self printPage];
    }
    // qzfeng end 2016/05/10
    
    
}
- (IBAction)buttonQuery:(id)sender
{
    NSLog(@"call QueryStatus");
    BOOL state = [SPRTPrint sendCheckPaperOutCmd];
    if (!state) statusText.text = @"网络或通讯异常！";
}
- (IBAction)switchAction:(id)sender
{
    UISwitch *switchButton=(UISwitch *)sender;
    isSwitchOn = [switchButton isOn];
    
}

#pragma  mark -- CBCentralManagerDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSString * state = nil;
    switch ([central state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            state = @"work";
            break;
        case CBCentralManagerStateUnknown:
        default:
            ;
    }
    NSLog(@"Central manager state: %@", state);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI{
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"has connected");
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    if (thread) {
        [thread cancel];
        thread = NULL;
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //此时连接发生错误
    NSLog(@"connected periphheral failed");
}

#pragma mark - CBPeripheralDelegate

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
{
    response += 1;
    NSLog(@"Write edata success!");
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value; 
    NSLog(@"secondview:read data=%@!",data);

    NSLog(@"qzf come here data=%@",data);
    
    // 流控判断; qzfeng 2015/12/23
    if (characteristic == activeFlowControlCharacteristic) {
        NSLog(@"qzf come here2");

        NSData * data = [characteristic value];
        NSUInteger len = [data length];
        int bytesRead = 0;
        if (len > 0) {
            unsigned char * measureData = (unsigned char *) [data bytes];
            unsigned char field = * measureData;
            measureData++;
            bytesRead++;
            if(field == 2){
                unsigned char low  = * measureData;
                measureData++;
                mtu =  low + (* measureData << 8);
            }
            if(field == 1){
                
                if(credit < 5) {
                    credit += * measureData;
                }//20151222 qwq
                
            }
        }
        return;
    }

    NSLog(@"qzf come here3");

    
    const Byte *res =[data bytes];
    char hex_resp[[data length]*2+1];
    char temp[3];
    memset(hex_resp, 0, [data length]*2+1);
    memset(temp,0,3);
    
    NSLog(@"qzf come here data=%@,cmd=%d",data,cmd);
    
    //
    switch (cmd)
    {
        
        case DLE_EOT_1:
            
            if (res[0] & 0x08) statusText.text=@"脱机";
            else  statusText.text=@"正常";
            break;
        
        case DLE_EOT_3:
            if (res[0] & 0x68) statusText.text=@"打印机错误";
            else  statusText.text=@"正常";
            break;
        case DLE_EOT_4:
            if (res[0] & 0x60) statusText.text=@"缺纸";
            else  statusText.text=@"正常";
            break;
        
        // 获取打印机自动返回的是否打印完成字节； qzfeng begin 2015/12/23
        case DLE_EOT_5:
            NSLog(@"qzf DLE_EOT_5 res[0]=%x",res[0]);
            if( res[0]&0x12)      // 打印返回字节有效；
            {
                 if(res[0]&0x04){
                     statusText.text=@"上盖打开，打印未完成！";
                     break;
                 }else if(res[0]&0x08){
                     statusText.text=@"打印头过热，打印未完成！";
                     break;
                 }else if(res[0]&0x20){
                     statusText.text=@"缺纸，打印未完成！";
                     break;
                 }else{
                     statusText.text=@"打印完成！";
                     break;
                 }
            }else{
                 statusText.text=@"打印机返回异常!";
                 NSLog(@"qzf DLE_EOT_5 打印机返回异常! res=%x",res[0]);
                 break;
            }
        // qzfeng end 2015/12/23
            
        default:
        
            for (int i=0;i<[data length];i++)
            {
               
                sprintf(temp,"%02x",res[i]);
                strcat(hex_resp,temp);
            }
            statusText.text=[NSString stringWithUTF8String:hex_resp];
            break;
    }
 //   cmd = 0;
    
}



-(void) alertMessage:(NSString *)msg{
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"提示" 
                                                   message:msg
                                                  delegate:self
                                         cancelButtonTitle:@"关闭" 
                                         otherButtonTitles:nil];
    [alert show];
    //[alert release];
    
}
@end


