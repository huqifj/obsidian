# BLE

## local name 和 device name 的区别

关于 local name 和 device name，很多人可能有疑惑，为什么蓝牙有两个名字。可以这样简单地区分：

1. Local Name 是广播出来的。Device Name 是 GATT service 中的一个特性，需要连接后才能读或写。
2. Local Name 不能过长，因为广播包数据长度有限。Local Name 有两类 short 和 long。具体长度可以自己设置。Device Name 的最长为 248 byte。Local Name 最长能到达 29 bytes。
3. Local Name 和 Device Name 要求保持一致性。Local Name 必须是 Device Name 的开始连续的一部分或全部。例如 Device Name 是“BT_DEVICE”, 则 Local Name 可以是”BT_D”或 “BT_DEVICE”。