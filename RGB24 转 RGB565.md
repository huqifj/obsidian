# RGB24 转 RGB565


R: High 5 bits

G: High 6 bits

B: High 5 Bits

```c
#define C24_TO_C565(rgb24) (((rgb24 & 0xf80000) >> 8) | ((rgb24 & 0x00fc00) >> 5) | ((rgb24 & 0x0000f8) >> 3))
```