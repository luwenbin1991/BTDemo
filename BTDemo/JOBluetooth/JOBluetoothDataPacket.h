//
//  JOBluetoothDataPacket.h
//  JOBluetooth
//
//  Created by wbh on 12-4-18.
//  Copyright (c) 2012年 重庆金瓯科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>


@class JOBluetoothDataPacket;

@protocol JOBluetoothDataPacketDelegate
@optional
@required
-(Boolean) bluetoothDataPacket:(JOBluetoothDataPacket *)dataPacketHandler writeData:(NSData *)data;
-(Boolean) bluetoothDataPacket:(JOBluetoothDataPacket *)dataPacketHandler writeResponsePacket:(NSData *)data error:(Boolean)error;
-(Boolean) bluetoothDataPacket:(JOBluetoothDataPacket *)dataPacketHandler writeHostCanReceivePacket:(NSData *)data;
-(Boolean) bluetoothDataPacket:(JOBluetoothDataPacket *)dataPacketHandler writeResetSequence:(NSData *)data;
-(void) bluetoothDataPacket:(JOBluetoothDataPacket *)dataPacketHandler didDataReceived:(const void *)buffer length:(NSUInteger)length;
-(void) disconnect;
@end

