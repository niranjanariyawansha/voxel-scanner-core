// Internal Scanner Module - NOW FULLY PARAMETRIC
module voxel_scanner #( parameter CHUNK_WIDTH = 8 ) (
    input wire clk, rst_n,
    input wire [(CHUNK_WIDTH*8)-1:0] data_in, // Scaled to parameter
    input wire data_valid,
    output reg data_ready,
    output reg [CHUNK_WIDTH-1:0] struct_bitmap, // Scaled to parameter
    output reg struct_valid,
    output reg in_string_state, error_flag,
    output reg [31:0] bytes_processed
);
    reg state_in_string, state_last_was_backslash;
    
    // Internal masks now scale automatically with CHUNK_WIDTH
    wire [CHUNK_WIDTH-1:0] is_quote, is_backslash, is_struct;
    reg  [CHUNK_WIDTH-1:0] escape_mask, string_mask;

    genvar i;
    generate
        for (i = 0; i < CHUNK_WIDTH; i = i + 1) begin : char_class
            wire [7:0] byte_i = data_in[i*8 +: 8];
            assign is_quote[i]     = (byte_i == 8'h22);
            assign is_backslash[i] = (byte_i == 8'h5C);
            assign is_struct[i]    = (byte_i == 8'h7B || byte_i == 8'h7D || byte_i == 8'h5B || 
                                      byte_i == 8'h5D || byte_i == 8'h3A || byte_i == 8'h2C);
        end
    endgenerate

    integer j;
    always @(*) begin
        escape_mask[0] = state_last_was_backslash;
        string_mask[0] = state_in_string ^ (is_quote[0] && !escape_mask[0]);
        
        // Loop now uses the CHUNK_WIDTH parameter
        for (j = 1; j < CHUNK_WIDTH; j = j + 1) begin
            escape_mask[j] = is_backslash[j-1] && !escape_mask[j-1];
            string_mask[j] = string_mask[j-1] ^ (is_quote[j] && !escape_mask[j]);
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_in_string <= 0;
            in_string_state <= 0; 
            state_last_was_backslash <= 0;
            struct_bitmap <= 0; struct_valid <= 0; data_ready <= 1;
            error_flag <= 0; bytes_processed <= 0;
        end else if (data_valid) begin
            // Uses the last bit of the generated mask regardless of width
            state_in_string <= string_mask[CHUNK_WIDTH-1];
            in_string_state <= string_mask[CHUNK_WIDTH-1]; 
            state_last_was_backslash <= is_backslash[CHUNK_WIDTH-1] && !escape_mask[CHUNK_WIDTH-1];
            struct_bitmap <= is_struct & ~string_mask;
            struct_valid <= 1;
            
            // Increment logic now follows the parameter
            bytes_processed <= bytes_processed + CHUNK_WIDTH;
        end
    end
endmodule
