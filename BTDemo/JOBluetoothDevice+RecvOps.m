//
//  JOBluetoothDevice+RecvOps.m
//  BTDemo
//
//  Created by SPRT on 14-11-3.
//
//
//#import "NSObject+Extension.h"
#import "objc/runtime.h"
#import "JOBluetoothDevice+RecvOps.h"
static const void *cmdKey=&cmdKey;


@implementation JOBluetoothDevice (RecvOps)
@dynamic cmd;

-(NSNumber*)cmd
{
    return objc_getAssociatedObject(self,cmdKey);
}
-(void) setCmd:(NSNumber *)cmd
{
    objc_setAssociatedObject(self, cmdKey, cmd, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
