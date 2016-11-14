//
//  JOBTFirstViewController.m
//  BTDemo
//
//  Created by ligl on 15-07-21.
//

#import "JOBTFirstViewController.h"

// qzfeng begin 2015/05/10
/**/
//for issc
static NSString *const kWriteCharacteristicUUID_cj = @"49535343-8841-43F4-A8D4-ECBE34729BB3";
static NSString *const kReadCharacteristicUUID_cj = @"49535343-1E4D-4BD9-BA61-23C647249616";
static NSString *const kServiceUUID_cj = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
/**/
// qzfeng end 2015/05/10

/*金瓯的模块读写特征反了、
static NSString *const  kReadCharacteristicUUID= @"49535343-8841-43F4-A8D4-ECBE34729BB3";
 static NSString *const kWriteCharacteristicUUID = @"49535343-1E4D-4BD9-BA61-23C647249616";
 static NSString *const kServiceUUID = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";*/
//for ivt
static NSString *const kFlowControlCharacteristicUUID = @"ff03";
static NSString *const kWriteCharacteristicUUID = @"ff02";
static NSString *const kReadCharacteristicUUID = @"ff01";
static NSString *const kServiceUUID = @"ff00";


//for jinou 单模，双模同issc

/*
static NSString *const kWriteCharacteristicUUID = @"fff2";
static NSString *const kReadCharacteristicUUID = @"fff1";
static NSString *const kServiceUUID = @"fff0";*/

CBPeripheral *activeDevice;
CBCharacteristic *activeWriteCharacteristic;
CBCharacteristic *activeReadCharacteristic;
CBCharacteristic *activeFlowControlCharacteristic;
int mtu = 20;
int credit = 0;
int response = 1;

int cjFlag=1;           // qzfeng 2016/05/10

@interface JOBTFirstViewController ()

@end

@implementation JOBTFirstViewController
@synthesize deviceListTableView;
@synthesize scanConnectActivityInd;
@synthesize centralManager;

@synthesize selectedPeripheral;


- (void)viewDidLoad
{
    [super viewDidLoad];
	  //初始化后会调用代理CBCentralManagerDelegate 的 - (void)centralManagerDidUpdateState:(CBCentralManager *)central
    centralManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];

}

- (void)viewDidUnload
{
    [self setDeviceListTableView:nil];
    [self setScanConnectActivityInd:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)buttonStartDiscovery:(id)sender {
    //if (self.peripheral.isConnected)
    if (self.selectedPeripheral.state==CBPeripheralStateConnected)
        [centralManager cancelPeripheralConnection:self.selectedPeripheral];
    //清空当前设备列表
		if ( self.deviceList == nil) self.deviceList = [[NSMutableArray alloc]init];
    else [self.deviceList removeAllObjects];
    [deviceListTableView reloadData];
    //[centralManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    [centralManager scanForPeripheralsWithServices:nil options:nil];
    [scanConnectActivityInd startAnimating];
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopScanPeripheral) userInfo:nil repeats:NO];
    

}
- (void) stopScanPeripheral
{
    [self.centralManager stopScan];
    [scanConnectActivityInd stopAnimating];
    NSLog(@"stop scan");
}

/*---------------------------------------------------------------------------------------------------------------------------------------
 *
 *  @method CBCentralManagerDelegate CBPeripheralDelegate
 *
----------------------------------------------------------------------------------------------------------------------------------------*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    if (peripheral)
    {
        NSLog(@"foundDevice. name[%s],RSSI[%d]\n",peripheral.name.UTF8String,peripheral.RSSI.intValue);
        //if ( [peripheral.name isEqualToString:@"T9 BT Printer"] )
        {
            //self.peripheral = peripheral;
            //发现设备后即可连接该设备 调用完该方法后会调用代理CBCentralManagerDelegate的- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral表示连接上了设别
            //如果不能连接会调用 - (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
            //[centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : YES}];
            if (![self.deviceList containsObject:peripheral])
                [self.deviceList  addObject:peripheral];
            
            //NSLog(@"foundDevice. name[%s],RSSI[%d]\n",peripheral.name.UTF8String,peripheral.RSSI.intValue);
            [deviceListTableView reloadData];
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"has connected");
        //[mutableData setLength:0];
    self.selectedPeripheral.delegate = self;
    //此时设备已经连接上了  你要做的就是找到该设备上的指定服务 调用完该方法后会调用代理CBPeripheralDelegate（现在开始调用另一个代理的方法了）的
    //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
    
    // qzfeng begin 2016/05/10
    [self.selectedPeripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID_cj]]];
    // qzfeng end 2016/05/10
    
}
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    //self.peripheral = nil;
    [deviceListTableView reloadData];
    [self alertMessage:@"连接断开！"];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    //此时连接发生错误
    NSLog(@"connected periphheral failed");
    [self alertMessage:@"连接失败！"];
}


#pragma mark -- CBPeripheralDelegate
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:error
{
		if (error==nil) 
		{
			NSLog(@"Write edata failed!");
			return;
		}
		NSLog(@"Write edata success!");
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error==nil) 
    {
        //在这个方法中我们要查找到我们需要的服务  然后调用discoverCharacteristics方法查找我们需要的特性
        //该discoverCharacteristics方法调用完后会调用代理CBPeripheralDelegate的
        //- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
        for (CBService *service in peripheral.services) 
        {
            if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID]]) 
            {
                cjFlag=0;           // qzfeng 2016/05/10
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                [peripheral discoverCharacteristics:nil forService:service];
            }
            // qzfeng begin 2016/05/10
            else if ([service.UUID isEqual:[CBUUID UUIDWithString:kServiceUUID_cj]])
            {
                //[peripheral discoverCharacteristics:@[[CBUUID UUIDWithString:kCharacteristicUUID]] forService:service];
                cjFlag=1;       // qzfeng 2016/05/10
                [peripheral discoverCharacteristics:nil forService:service];
            }
            // qzfeng end 2016/05/10
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    if (error==nil) {
        //在这个方法中我们要找到我们所需的服务的特性 然后调用setNotifyValue方法告知我们要监测这个服务特性的状态变化
        //当setNotifyValue方法调用后调用代理CBPeripheralDelegate的- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        for (CBCharacteristic *characteristic in service.characteristics) 
        {
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeWriteCharacteristic = characteristic;
            }
            else
            if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID]]) 
            {
                   [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                    activeReadCharacteristic = characteristic;
            }
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kFlowControlCharacteristicUUID]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeFlowControlCharacteristic = characteristic;
                credit = 0;
                response = 1;
            }
            
            // qzfeng begin 2016/05/10
            else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kWriteCharacteristicUUID_cj]]) {
            
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeWriteCharacteristic = characteristic;
            }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kReadCharacteristicUUID_cj]]) {
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
                activeReadCharacteristic = characteristic;
            }
            
            // qzfeng end 2016/05/10
            [deviceListTableView reloadData];
    				[scanConnectActivityInd stopAnimating];
    				activeDevice = peripheral;
            
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
		NSLog(@"enter didUpdateNotificationStateForCharacteristic!");
    if (error==nil) 
    {
        //调用下面的方法后 会调用到代理的- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
        [peripheral readValueForCharacteristic:characteristic];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"enter didUpdateValueForCharacteristic!");
    NSData *data = characteristic.value; 
    NSLog(@"read data=%@!",data);
    if (characteristic == activeFlowControlCharacteristic) {
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
                }
            }
        }
    }
}


//---------------------------------------------------------------------------------------------------------------------------------------



//－行的数量：
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section   
{
    return [self.deviceList count];
}

//－行的定义  
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath  
{
    static NSString * CellIdentifier = @"JODeviceListIdentifier";  
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];  
    if (cell == nil)
    {
        //默认样式
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];  
    }
    //文字的设置
    NSUInteger row=[indexPath row];
    CBPeripheral * device = [self.deviceList objectAtIndex:row];
    cell.textLabel.text= device.name;
    
    UIButton *button ; 
    button = [ UIButton buttonWithType : UIButtonTypeRoundedRect ];
    CGRect frame = CGRectMake ( 0.0 , 0.0 , 70 , 35 );
    button. frame = frame;
    //if(device.isConnected)
    if(device.state==CBPeripheralStateConnected)
    {
        [button setTitle:@"断开" forState:UIControlStateNormal];        
    }
    else {
        [button setTitle:@"连接" forState:UIControlStateNormal];
    }
    button.backgroundColor = [ UIColor clearColor ];
    cell.accessoryView = button;
    
    [button addTarget : self action : @selector ( btnDeviceListClicked : event :)   forControlEvents :UIControlEventTouchUpInside ];
    
    
    return cell;  
}

/*!
 *
 *  用户按下连接或者断开按钮，进行连接或者断开操作
 */
-( void )tableView:( UITableView *) tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    CBPeripheral * device = [self.deviceList objectAtIndex:[indexPath row]];
    
    [scanConnectActivityInd stopAnimating];
    //if(device.isConnected)
    if(device.state==CBPeripheralStateConnected)
    {
        //NSLog(@"buttonStartDisconnect\n");
        //[bluetoothRadio startDisconnectDevice:device];
        [centralManager cancelPeripheralConnection:device];


    }
    else 
    {
        [self.centralManager stopScan];
        NSLog(@"stop scan");
    		self.selectedPeripheral = device;
    		//[self.centralManager stopScan];
        //NSLog(@"buttonStartConnect\n");
        //[bluetoothRadio startConnectDevice:device timeout:DEFAULT_CONNECT_TIMEOUT];
        [centralManager connectPeripheral:device options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @YES}];
        
    }
    [scanConnectActivityInd startAnimating];
}

/*!
 *
 *  检查用户点击按钮时的位置，并转发事件到对应的 accessory tapped 事件
 */
- ( void )btnDeviceListClicked:( id )sender event:( id )event
{
    NSSet *touches = [event allTouches ];
    UITouch *touch = [touches anyObject ];
    CGPoint currentTouchPosition = [touch locationInView : self.deviceListTableView];
    NSIndexPath *indexPath = [ self.deviceListTableView indexPathForRowAtPoint : currentTouchPosition];
    if (indexPath != nil )
    {
        [ self tableView : self.deviceListTableView accessoryButtonTappedForRowWithIndexPath : indexPath];
    }
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
