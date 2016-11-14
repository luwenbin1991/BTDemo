//
//  JOBluetoothRadio.h
//  JOBluetooth
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>
#import "JOBluetoothDevice.h"

#define DEFAULT_DISCOVERY_TIMEOUT           4       //SECONDS
#define DEFAULT_CONNECT_TIMEOUT             5       //SECONDS

@class JOBluetoothRadio;

@protocol JOBluetoothRadioDelegate
@optional

@required
/*!
 *  @method didFoundDevice:
 *
 *  @param  device	JOBluetoothDevice对象，表示查询到的设备
 *
 *  @discussion 当调用 startDiscovery 请求查询周围设备的时候，查询到设备时，会通过此消息通知查询到的设备。
 */
-(void) didFoundDevice:(JOBluetoothDevice *)device;

/*!
 *  @method didDiscoveryComplete:
 *
 *  @discussion 当调用 startDiscovery 请求查询周围设备的时候，查询超时时，会通过此消息通知查询已经结束。
 */
-(void) didDiscoveryComplete;

/*!
 *  @method didConnectDevice:error:
 *
 *  @param  device	JOBluetoothDevice对象，表示连接完成的设备
 *          error   是否出现错误
 *
 *  @discussion 当调用 startConnectDevice 请求连接设备的时候，连接结束时，会通过此消息通知连接结果。
 */
-(void) didConnectDevice:(JOBluetoothDevice *)device error:(Boolean)error;

/*!
 *  @method didDisconnectDevice:
 *
 *  @param  device	JOBluetoothDevice对象，表示断开连接的设备
 *          error   是否出现错误
 *
 *  @discussion 当与设备之间的连接断开时，会通过此消息通知。
 */
-(void) didDisconnectDevice:(JOBluetoothDevice *)device error:(Boolean)error;;

@end

@interface JOBluetoothRadio : NSObject<CBCentralManagerDelegate,JOBluetoothDeviceDelegate>
{
    id <JOBluetoothRadioDelegate> _delegate;
    CBCentralManager *centralManager;
    Boolean isScaning;
    NSTimer * scantimer;
}

/*!
 *  @property deviceList
 *
 *  @discussion 蓝牙设备列表，每个对象为JOBluetoothDevice类。
                类初始化（initWithDelegate）之后，会自动读取之前查询到或使用过的设备信息。
                也可以通过startDiscovery查询周围设备信息，都保存在此属性中，查询之前可以
                通过deleteDevice或者deleteAllDevice删除信息，也可以不删除，重复信息会
                自动删除。                
 *
 */
@property (strong, nonatomic,readonly)  NSMutableArray *deviceList;

/*!
 *  @method initWithDelegate:
 *
 *  @param delegate	The delegate to receive the events
 *  @discussion The initialization call.
 *
 */
-(id) initWithDelegate:(id<JOBluetoothRadioDelegate>)delegate;

/*!
 *  @method startDiscovery:
 *
 *  @param timeoutSeconds   查询超时时间，单位秒
 *
 *  @discussion 开始查询周围的蓝牙设备，查询到之后，通过回调函数告知结果
 *
 */
-(Boolean) startDiscovery:(float)timeoutSeconds;

/*!
 *  @method startConnectDevice:timeout
 *
 *  @param device 要建立连接的设备
 *  @param timeout 连接超时时间，单位秒
 *  @returns TRUE (启动成功) FALSE (启动失败)
 *
 *  @discussion 尝试与设备建立连接
 *
 */
-(Boolean) startConnectDevice:(JOBluetoothDevice *)device timeout:(float)nSeconds;

/*!
 *  @method startDisconnectDevice:
 *
 *  @param device 要断开连接的设备
 *
 *  @returns TRUE (启动成功) FALSE (启动失败)
 *
 *  @discussion 尝试与设备断开连接
 *
 */
-(Boolean) startDisconnectDevice:(JOBluetoothDevice *)device;

/*
 *  @method deleteDevice:
 *
 *  @param device   需要删除的设备
 *
 *  @returns true   (删除成功）
 false  (删除失败，指定的设备不再列表中或者设备已经连接）
 *
 *  @discussion 从设备列表中删除指定设备信息，如果设备已经连接，则不允许删除
 *
 */
-(Boolean) deleteDevice:(JOBluetoothDevice *)device;

/*
 *  @method deleteAllDevice:
 *
 *  @returns none
 *
 *  @discussion 从设备列表中删除所有未连接的设备信息
 *
 */
-(void) deleteAllDevice;


@end
