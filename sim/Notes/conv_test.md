# Conv Test Bench

*Pixel Streaming*: 5x5 image is sent one pixel per clock, row by row:

The DUT is a convulation engine (`conv.v`), requires a full 3x3 window before producing valid outputs.

```verilog
Pixels sent:  1  2  3  4  5 | 0  1  0  1  0 | 1  2  [3] ← first check here
              ← row 0 ──────── row 1 ────────── row 2 →
                                                  ↑
                                           pixel [2,2] completes
                                           the first 3×3 window
```


```verilog
    send_pixel(val);                // 1. drive pxl_in, wait for posedge + #1
    check(expected, test_num, ...); // 2. immediately read pxl_out
```

```verilog

send_and_check(3,  16'd16, 1, 1);
//             ↑   ↑        ↑  ↑
//             |   |        |  └─ 1st check in this test
//             |   |        └──── Test 1
//             |   └─────────────  expect pxl_out == 16
//             └─────────────────  send pixel value 3

```

Why `@(posedge clk); #1;`?

- The @(posedge clk) synchronizes the stimulus to the clock
- The #1 skews the signal slightly past the edge, ensuring the DUT's flip-flops have already latched before the new value is applied — preventing race conditions between the testbench and the DUT

