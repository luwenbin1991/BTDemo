//
//  JOBTSecondViewController.h
//  BTDemo
//
//  Created by ligi on 15-07-21.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import <UIKit/UIKit.h>

@interface JOBTSecondViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
{
    NSMutableData * recvDatas;
    BOOL isSwitchOn;
}

@property (weak, nonatomic) IBOutlet UITextField *statusText;
@property (weak, nonatomic) IBOutlet UITextView *textView_SendData;
@property(strong,nonatomic)CBCentralManager *centralManager;

- (IBAction)buttonCompleteInputContent:(id)sender;
- (IBAction)buttonSend:(id)sender;
- (IBAction)buttonClear:(id)sender;
- (IBAction)buttonPrintPage:(id)sender;
- (IBAction)buttonPageModePrint:(id)sender;
- (IBAction)buttonPrintPNGorJPG:(id)sender;
- (IBAction)buttonQuery:(id)sender;
- (IBAction)switchAction:(id)sender;
-(void) alertMessage:(NSString *)msg;
@end
