# Verilog Gray Counter & Converters

This repository contains a `WIDTH`-parametric synchronous Gray counter and its associated combinatorial converters. These modules are fundamental for creating robust **Clock Domain Crossing (CDC)** logic for multi-bit values.

## Quick Specs
* **`gray_cnt`**: Synchronous counter with an active-low reset and enable.
* **`bin2gray`**: Combinatorial module for Binary to Gray conversion.
* **`gray2bin`**: Combinatorial module for Gray to Binary conversion.
* **Parametric**: All modules use a `WIDTH` parameter.
* **CDC Safe**: The counter is designed to be read from an asynchronous clock domain, as it only ever changes one bit at a time.

---

## Module Descriptions

### `bin2gray.v`
A simple combinatorial module that converts a `WIDTH`-bit binary input to its Gray code equivalent.
* **Core Logic**: Implements the standard `G[i] = B[i] ^ B[i+1]` rule using the efficient vector-based operation:
    ```verilog
    assign gray_out = (bin_in >> 1) ^ bin_in;
    ```

### `gray2bin.v`
A combinatorial module that converts a `WIDTH`-bit Gray code input back to its binary equivalent.
* **Core Logic**: Implements the serial `B[i] = G[i] ^ B[i+1]` logic. This is achieved using a `generate` loop to create the required N-1 stage XOR chain, with the MSB passed through directly.

### `gray_cnt.v`
The main synchronous counter module.
* **Design**: The counter **does not** calculate the next Gray value from the current one.
* **Core Logic**: It uses a standard `internal_bin` counter. The output `gray_count` is a registered version of the *next* binary value (`internal_bin + 1`) converted to Gray code.
* **Wrap-Around Handling**: A `wire [WIDTH-1:0] next_bin` is used to calculate `internal_bin + 1`. This explicitly truncates the result to `WIDTH` bits, correctly handling the wrap-around from `(2**N)-1` to `0` *before* the Gray conversion, which was a critical bug fix.

---

## Purpose: Clock Domain Crossing (CDC)

This project's components are not meant to be used in isolation; they form a complete solution for safely passing a multi-bit counter value from **Clock Domain A** to **Clock Domain B**.

1.  **Domain A**: The **`gray_cnt`** (clocked by `clk_A`) runs.
2.  **The Boundary**: The `gray_count` output (which only changes 1 bit at a time) is passed to a 2-flop synchronizer (clocked by `clk_B`).
3.  **Domain B**: The safe, synchronized Gray value is fed into the **`gray2bin`** module to be converted back into a usable binary number, now safely in `clk_B`'s domain.

---

## Testbench

The included testbench (`testbench.sv`) validates all three modules by:
1.  Instantiating the counter and both converters.
2.  Using a "golden" `expected_binary` counter internally.
3.  **Check 1:** `gray2bin(gray_cnt_out) == expected_binary` (Tests `gray_cnt` and `gray2bin`).
4.  **Check 2:** `bin2gray(expected_binary) == gray_cnt_out` (Tests `bin2gray` and `gray_cnt`).
5.  The test runs for `(2**WIDTH) * 2` cycles to explicitly verify the **wrap-around** logic.
