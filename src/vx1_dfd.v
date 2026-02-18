// FILE: src/vx1_dfd.v
// Pillar 3: Design-for-Debug (Black Box Trace Buffer)
`default_nettype none

module vx1_dfd (
    input  wire        clk,           // 2.0 GHz System Clock
    input  wire        rst_n,         // Active low reset
    input  wire [7:0]  internal_state, // Connects to scanner bitmap
    output reg  [63:0] trace_buffer    // Stores last 8 cycles of state
);

    // Shift register acts as a "Black Box" history recorder
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            trace_buffer <= 64'd0;
        end else begin
            // Shifts the internal state into a 64-bit history buffer
            // Every cycle, the oldest 8 bits are dropped and the newest are added
            trace_buffer <= {trace_buffer[55:0], internal_state};
        end
    end
endmodule
