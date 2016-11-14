//
//  JOBTFirstViewController.h
//  BTDemo
//
//  Created by ligl on 15-07-21.
//
#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import <UIKit/UIKit.h>
@interface JOBTFirstViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate,UITableViewDelegate,UITableViewDataSource>
{
	
}
@property(strong,nonatomic)CBCentralManager *centralManager;
@property(strong,nonatomic)CBPeripheral *selectedPeripheral;
@property(strong,nonatomic)NSMutableArray *deviceList;

@property (weak, nonatomic) IBOutlet UITableView *deviceListTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *scanConnectActivityInd;
- (IBAction)buttonStartDiscovery:(id)sender;
- (void) stopScanPeripheral;

@end
