`default_nettype none

module vx1_pmu (
    input  wire        clk,           // 2.0 GHz Target System Clock
    input  wire        rst_n,         // Active low reset
    input  wire        data_valid,    // Snoops the 'ena' signal from the TT wrapper
    output reg  [63:0] byte_count,    // The "Odometer" (16.0 GB/s tracker)
    output reg  [63:0] cycle_count    // The "Stopwatch" (2.0 GHz tracker)
);

    // Stopwatch: Increments every clock cycle to provide a time baseline
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cycle_count <= 64'd0;
        end else begin
            cycle_count <= cycle_count + 64'd1;
        end
    end

    // Odometer: Counts bytes only when data is actively being processed
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            byte_count <= 64'd0;
        end else if (data_valid) begin
            // VX-1 processes 8 bytes per cycle (64-bit parallel architecture)
            byte_count <= byte_count + 64'd8;
        end
    end

endmodule
