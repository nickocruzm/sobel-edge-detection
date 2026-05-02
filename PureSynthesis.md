# Sobel Edge Detection Benchmarks (purely synthesis)


All these benchmark metrics are theoretical
- The tool only looked at your Verilog code structure
- It mapped your logic to real gates
- It estimated timing, area, and power statistically based on the circuit topology
- No image was actually passed in

## Current State (05-01-2026)

- ASIC Implementation

### Params
clock
- Period: 2 ns (500 MHz)
- Duty cycle: 50% (1 ns high, 1 ns low)
- Uncertainty (setup & hold): 0.2 ns

Input/Output Delays
- Input delay: 0.1 ns (for reset and pxl_in)
- Output delay: 0.1 ns (for pxl_out and valid)
- Input transition time: 0.1 ns

Load and fanout
- Output capacitive load: 0.005 pF (5 fF) on pxl_out and valid
- Max fanout: 100

Technology
- Library: SAED32 RVT (Regular Voltage Threshold)
- Process node: 32nm
- Corner: tt0p78v25c — meaning typical transistors, 0.78V supply, 25°C temperature

Results
- Worst Negative Slack: −1.48 ns (timing not met)
- Total Area: ~4056 units
- Leakage Power: ~58.4 million units

## Clock Frequency
**"How fast the hardware runs"**
- Typically for 100 MHz to 500 MHz, for an FPGA or ASIC implementaion
- Currently we have Negative Slack: -1.48ns (BAD)
- As we optimize one of the first indicators that we are actually heading in the right direction is when our slack trends towards zero OR (best case) when it becomes positive.

## Latency
**"how many clock cycles it takes to process one image"**

- Depends heavily on image size and architecture
- For a 256×256 image: roughly 65,000–70,000 cycles (one per pixel, plus pipeline fill time)
- For 1080p (1920×1080): roughly 2–2.5 million cycles
- our design uses a shift register buffer, which suggests a streaming/pipelined approach, so latency is mainly dominated by image size

## End-to-End Runtime
**"how long it takes to process a full image end-to-end"**
- At 300 MHz on a 256×256 image: roughly ~0.2–0.3 milliseconds 
- At 500 MHz fully optimized: closer to ~0.13 milliseconds
- These are very fast compared to software — a CPU doing the same thing in Python might take 10–50 milliseconds

## Synthesis Time
**how long the tool takes to compile**

- Our run took 51 seconds, which is quite fast
- Typical range for designs this size: 30 seconds to a few minutes
- Larger designs (full processors, etc.) can take hours