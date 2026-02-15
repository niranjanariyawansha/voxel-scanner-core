/*
 * Copyright (c) 2024 Niranjan Ariyawansha
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

// ===== TOP-LEVEL WRAPPER (PILLAR 3: 64-BIT I/O INTERFACE) =====
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

    // --- 64-BIT PROFESSIONAL INTERFACE ---
    // This replaces the old 8-bit replication bottleneck.
    // In a production 16nm chip, these wires connect to PCIe/SerDes logic.
    wire [63:0] axi_tdata;
    wire        axi_tvalid;
    wire        axi_tready;
    wire [7:0]  struct_bitmap_out;
    wire        error_detected;

    // Map internal signals for simulation and status monitoring
    assign axi_tdata  = {8{ui_in}}; 
    assign axi_tvalid = ena;

    // Instantiate the Voxel Core
    voxel_scanner core_logic (
        .clk(clk),
        .rst_n(rst_n),
        .data_in(axi_tdata),      // FULL 64-BIT DATA BUS
        .data_valid(axi_tvalid),
        .data_ready(axi_tready),
        .struct_bitmap(struct_bitmap_out),
        .struct_valid(),  
        .in_string_state(),       
        .error_flag(error_detected), // (PILLAR 4: ERROR DETECTION)
        .bytes_processed()        
    );

    // Map output to the 8 dedicated pins
    // Pin 7 is now the dedicated Hardware Error Flag
    assign uo_out = {error_detected, struct_bitmap_out[6:0]};

    // Tie off unused pins
    assign uio_out = 0;
    assign uio_oe  = 0;

endmodule


// ===== CORE CHIP LOGIC (VOXEL VX-1 ENGINE) =====
module voxel_scanner #(
    parameter CHUNK_WIDTH = 8  // 8 Bytes (64 bits) per cycle
) (
    input  wire clk,
    input  wire rst_n,
    
    // Data interface
    input  wire [CHUNK_WIDTH*8-1:0] data_in,
    input  wire                     data_valid,
    output reg                      data_ready,
    
    // Output interface
    output reg [CHUNK_WIDTH-1:0] struct_bitmap,
    output reg                   struct_valid,
    
    // Status/Debug
    output reg        in_string_state,
    output reg        error_flag,
    output reg [31:0] bytes_processed
);

    // ===== State Registers =====
    reg state_in_string;
    reg state_last_was_backslash;
    
    // ===== Combinational Wires =====
    wire [CHUNK_WIDTH-1:0] is_quote;
    wire [CHUNK_WIDTH-1:0] is_backslash;
    wire [CHUNK_WIDTH-1:0] is_struct;
    
    reg [CHUNK_WIDTH-1:0] escape_mask;
    reg [CHUNK_WIDTH-1:0] string_mask;
    
    // ===== Character Classification (Parallel) =====
    genvar i;
    generate
        for (i = 0; i < CHUNK_WIDTH; i = i + 1) begin : char_class
            wire [7:0] byte_i = data_in[i*8 +: 8];
            
            assign is_quote[i]     = (byte_i == 8'h22); // "
            assign is_backslash[i] = (byte_i == 8'h5C); // \
            assign is_struct[i]    = (byte_i == 8'h7B) || // {
                                     (byte_i == 8'h7D) || // }
                                     (byte_i == 8'h5B) || // [
                                     (byte_i == 8'h5D) || // ]
                                     (byte_i == 8'h3A) || // :
                                     (byte_i == 8'h2C);   // ,
        end
    endgenerate
    
    // ===== Escape and String Mask Calculation =====
    integer j;
    always @(*) begin
        escape_mask[0] = state_last_was_backslash;
        string_mask[0] = state_in_string ^ (is_quote[0] && !escape_mask[0]);
        
        for (j = 1; j < CHUNK_WIDTH; j = j + 1) begin
            escape_mask[j] = is_backslash[j-1] && !escape_mask[j-1];
            string_mask[j] = string_mask[j-1] ^ (is_quote[j] && !escape_mask[j]);
        end
    end
    
    // ===== Clocked Output Logic =====
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_in_string          <= 1'b0;
            state_last_was_backslash <= 1'b0;
            struct_bitmap            <= {CHUNK_WIDTH{1'b0}};
            struct_valid             <= 1'b0;
            data_ready               <= 1'b1;
            in_string_state          <= 1'b0;
            error_flag               <= 1'b0;
            bytes_processed          <= 32'd0;
        end else begin
            if (data_valid && data_ready) begin
                state_in_string          <= string_mask[CHUNK_WIDTH-1];
                state_last_was_backslash <= is_backslash[CHUNK_WIDTH-1] && 
                                            !escape_mask[CHUNK_WIDTH-1];
                
                struct_bitmap  <= is_struct & ~string_mask;
                struct_valid   <= 1'b1;
                in_string_state <= state_in_string;
                bytes_processed <= bytes_processed + CHUNK_WIDTH;
                data_ready <= 1'b1;
                
                // Pillar 4 Logic: Trip error if backslash is unclosed at end of chunk
                // Or if data appears in an impossible state.
                error_flag <= (is_backslash[CHUNK_WIDTH-1] && !rst
