libJOBluetooth.a.32 是32位的库
libJOBluetooth.a.64是32/64兼容的库
libJOBluetooth.a.new64是32/64兼容的库,比较libJOBluetooth.a.64在断线的时候总是会调用didDisconnectDevice
libJOBluetooth.81是ios8.1以上版本才能用的库，需要配合专用的蓝牙模块使用

libJOBluetooth.a.emu是模拟器用的库，只是能编译通过，功能没法使用