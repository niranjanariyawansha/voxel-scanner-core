/*
 * Copyright (c) 2024 Niranjan Ariyawansha
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_niranjanariyawansha_voxel_scanner_core (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    // --- 64-BIT INTERFACE ---
    wire [63:0] axi_tdata;
    wire        error_detected;
    wire [7:0]  struct_bitmap_out;

    assign axi_tdata = {8{ui_in}};

    // Main Voxel Scanner Logic
    voxel_scanner core_logic (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(axi_tdata),
        .data_valid(ena),
        .data_ready(),
        .struct_bitmap(struct_bitmap_out),
        .struct_valid(),
        .in_string_state(),
        .error_flag(error_detected),
        .bytes_processed()
    );

    // --- PILLAR 1: PERFORMANCE MONITOR (PMU) ---
    wire [63:0] glory_byte_count;
    wire [63:0] glory_cycle_count;

    vx1_pmu performance_monitor (
        .clk(clk),
        .rst_n(rst_n),
        .data_valid(ena),
        .byte_count(glory_byte_count),
        .cycle_count(glory_cycle_count)
    );

    // --- PILLAR 2: THERMAL & VOLTAGE SENSORS ---
    wire [15:0] live_temp;
    wire [15:0] live_voltage;
    wire        hardware_signoff_met;

    vx1_sensors health_monitor (
        .clk(clk),
        .rst_n(rst_n),
        .core_temp(live_temp),
        .core_voltage(live_voltage),
        .status_ok(hardware_signoff_met)
    );

    // Map results: Bit 7 is Error Flag, Bits 6-0 are the structural bitmap
    assign uo_out = {error_detected, struct_bitmap_out[6:0]};

    assign uio_out = 0;
    assign uio_oe  = 0;

endmodule

// Internal Scanner Module logic remains unchanged below...
module voxel_scanner #( parameter CHUNK_WIDTH = 8 ) (
    input wire clk, rst_n,
    input wire [63:0] data_in,
    input wire data_valid,
    output reg data_ready,
    output reg [7:0] struct_bitmap,
    output reg struct_valid,
    output reg in_string_state, error_flag,
    output reg [31:0] bytes_processed
);
    reg state_in_string, state_last_was_backslash;
    wire [7:0] is_quote, is_backslash, is_struct;
    reg [7:0] escape_mask, string_mask;

    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : char_class
            wire [7:0] byte_i = data_in[i*8 +: 8];
            assign is_quote[i]     = (byte_i == 8'h22);
            assign is_backslash[i] = (byte_i == 8'h5C);
            assign is_struct[i]    = (byte_i == 8'h7B || byte_i == 8'h7D || byte_i == 8'h5B || byte_i == 8'h5D || byte_i == 8'h3A || byte_i == 8'h2C);
        end
    endgenerate

    integer j;
    always @(*) begin
        escape_mask[0] = state_last_was_backslash;
        string_mask[0] = state_in_string ^ (is_quote[0] && !escape_mask[0]);
        for (j = 1; j < 8; j = j + 1) begin
            escape_mask[j] = is_backslash[j-1] && !escape_mask[j-1];
            string_mask[j] = string_mask[j-1] ^ (is_quote[j] && !escape_mask[j]);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_in_string <= 0;
            state_last_was_backslash <= 0;
            struct_bitmap <= 0; struct_valid <= 0; data_ready <= 1;
            error_flag <= 0; bytes_processed <= 0;
        end else if (data_valid) begin
            state_in_string <= string_mask[7];
            state_last_was_backslash <= is_backslash[7] && !escape_mask[7];
            struct_bitmap <= is_struct & ~string_mask;
            struct_valid <= 1;
            bytes_processed <= bytes_processed + 8;
        end
    end
endmodule
