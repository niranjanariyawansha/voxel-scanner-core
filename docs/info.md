## How it works

The Voxel JSON Accelerator is a hardware core designed for high-throughput text processing.

It implements a **64-bit parallel scanner** that processes 8 bytes per clock cycle. The core logic identifies structural JSON characters (`{`, `}`, `:`, `,`) while simultaneously tracking string state and escape sequences in parallel.

**Key Features:**
* **Zero-Stall Parsing:** Handles escaped quotes (`\"`) without pausing the pipeline.
* **Parallel Prefix Scanning:** Uses combinatorial logic to calculate string masks instantly across 64 bits.
* **Wrapper Logic:** For this specific Tiny Tapeout submission, the 8-bit input pins (`ui_in`) are replicated internally to fill the 64-bit bus, allowing the synthesizer to generate PPA metrics for the full 64-bit architecture.

## How to test

1.  **Clock:** Apply a 50 MHz clock signal.
2.  **Reset:** Pulse `rst_n` low to reset the internal state machine.
3.  **Input:** Apply ASCII character data to `ui_in`.
    * Example: Sending `{` (Hex `7B`) to `ui_in`.
4.  **Output:** Observe `uo_out`.
    * If the character is a structural element (like `{`), the corresponding bit in `uo_out` will go HIGH.
    * If the character is inside a string (e.g., `"key"`), the bit will remain LOW.

## External hardware

No external hardware is required to run the simulation. The design is self-contained.
