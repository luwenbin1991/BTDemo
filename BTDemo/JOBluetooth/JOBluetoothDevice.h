//
//  JOBluetoothDevice.h
//  JOBluetooth
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "JOBluetoothDataPacket.h"

@class JOBluetoothDataPacket;
@class JOBluetoothDevice;
@class JOBluetoothRadio;

@protocol JOBluetoothDeviceDelegate
@optional
/*!
 *  @method bluetoothDevice:didDiscoverServiceSuccess:
 *
 *  @param  device	JOBluetoothDevice对象，表示哪个设备搜索服务完成了
            success 搜索服务是否成功
 
 *  @discussion 服务搜索完成消息，由JOBluetoothRadio使用，其他程序不需要这个消息
 *
 */
-(void) bluetoothDevice:(JOBluetoothDevice *)device didDiscoverServiceSuccess:(Boolean)success;

/*!
 *  @method bluetoothDevice:didUpdateRSSISuccess:
 *
 *  @param  device	JOBluetoothDevice对象，表示哪个设备完成了RSSI读取工作
 *          success 读取RSSI是否成功
 *
 *  @discussion 当 readRSSI 请求完成的时候，会通过此消息通知。如果成功，就可以通过RSSI属性获取RSSI的值。
 *
 */
-(void) bluetoothDevice:(JOBluetoothDevice *)device didUpdateRSSISuccess:(Boolean)success;

@required
/*!
 *  @method bluetoothDevice:didDataReceived:
 *
 *  @param  device	JOBluetoothDevice对象，表示哪个设备接收到了数据
 *          data    接收到的数据
 *
 *  @discussion 当从对方蓝牙接收到数据时，通过此消息通知。
 *
 */
-(void) bluetoothDevice:(JOBluetoothDevice *)device didDataReceived:(NSData *)data;
@end

@interface JOBluetoothDevice : NSObject<CBPeripheralDelegate,JOBluetoothDataPacketDelegate>
{
    CBService * dataService;
    CBCharacteristic * dataCharacteristicWrite;
    CBCharacteristic * dataCharacteristicHostRecvedPacketSequence;
    CBCharacteristic * dataCharacteristicHostRecvedErrorPacketSequence;
    CBCharacteristic * dataCharacteristicHostCanReceive;
    CBCharacteristic * dataCharacteristicResetSequence;
    JOBluetoothDataPacket * dataPacketHander;
    JOBluetoothRadio * btRadio;
    Boolean bSendDidDiscoverServiceEvent;
}
@property ( nonatomic) Boolean resArrived;
@property ( nonatomic) Byte * resBytes;
/*!
 *  @property peerPeripheral
 *
 *  @discussion 与设备关联的CBPeripheral设备
 *
 */
@property (strong, nonatomic) CBPeripheral * peerPeripheral;

/*!
 *  @property connTimer
 *
 *  @discussion 连接超时定时器，JOBluetoothRadio内部使用，其他程序不要使用。
 *
 */
@property (strong, nonatomic) NSTimer * connTimer;

/*!
 *  @property delegate
 *
 *  @discussion The delegate object you want to receive device events.
 *
 */
@property (strong, nonatomic) id<JOBluetoothDeviceDelegate> delegate;

/*!
 *  @property isConnected
 *
 *  @discussion 是否与设备建立了连接，只有服务也查询成功才算连接完成
 *
 */
@property(readonly) BOOL isConnected;

/*!
 *  @property isConnecting
 *
 *  @discussion 是否正在与设备建立连接，JOBluetoothRadio使用的内部变量，其他程序最好不要使用
 *
 */
@property (nonatomic) Boolean isConnecting;

/*!
 *  @property RSSI
 *
 *  @discussion 在查询到或者连接并通过readRSSI读取之后的RSSI值，单位db
 *
 */
@property (retain, getter = getRSSI) NSNumber *RSSI;

/*!
 *  @property name
 *
 *  @discussion 设备名称.
 *
 */
@property(retain, getter = getName) NSString *name;

/*!
 *  @property UUID
 *
 *  @discussion 设备UUID，为设备地址产生的值
 *
 */
@property(retain, readonly, getter = getUUID) NSString *UUID;

/*!
 *  @property ManufacturerData
 *
 *  @discussion 在查询时读取到的设备自定义数据
 *
 */
@property (retain, getter = getManufacturerData) NSData * ManufacturerData;


/*!
 *  @method nWaitSendDataCount:
 *
 *  @discussion 还没有成功发送的字节个数
 */
@property(readonly, getter = getNWaitSendDataCount) NSUInteger nWaitSendDataCount;

/*!
 *  @method initWithCBPeripheral:
 *
 *  @param peripheral	The peripheral device
           radio        JOBluetoothRadio
 
 *  @discussion 初始化函数，由JOBluetoothRadio类调用，其他程序不需要调用，可以通过JOBluetoothRadio类获取周围的设备或者之前使用过的设备
 *
 */
-(id) initWithCBPeripheral:(CBPeripheral *)peripheral BluetoothRadio:(JOBluetoothRadio *) radio;


/*!
 *  @method readRSSI
 *
 *  @discussion 连接之后，读取当前链路的RSSI值，读取成功之后，通过RSSI属性获取其值
 *
 */
- (Boolean)readRSSI;


/*!
 *  @method discoverServices:
 *
 *  @discussion 查询设备的服务及特征值，由JOBluetoothRadio调用，其他程序不必调用
 */
-(Boolean) discoverServices;

/*!
 *  @method writeData:
 *
 *  @discussion 发送数据到对方蓝牙设备
 */
-(Boolean) writeData:(NSData *)data;

/*!
 *  @method didDisconnected:
 *
 *  @discussion 当连接断开时接收到的消息，由JOBluetoothRadio调用，其他程序不必调用
 */
-(void) didDisconnected;

@end
