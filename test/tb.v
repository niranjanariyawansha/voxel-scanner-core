`default_nettype none
`timescale 1ns / 1ps

/* This testbench instantiates the Voxel Core and creates the wires 
   that are driven and tested by the cocotb test.py script.
*/
module tb ();

  // 1. Setup Signal Dumping (Generates the .vcd file for GTKWave)
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  // 2. Define the Signal Wires (Mapping to the TT08 Pinout)
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;

  // 3. Instantiate the Voxel Core Module
  // Make sure this name matches your top-level module exactly!
  tt_um_niranjanariyawansha_voxel_scanner_core user_project (

      // Required Power Ports for Gate Level (GL) Simulations
`ifdef GL_TEST
      .VPWR(1'b1),
      .VGND(1'b0),
`endif

      .ui_in  (ui_in),    // Dedicated inputs (Data feed)
      .uo_out (uo_out),   // Dedicated outputs (Bitmap result)
      .uio_in (uio_in),   // Bidirectional Input path
      .uio_out(uio_out),  // Bidirectional Output path
      .uio_oe (uio_oe),   // Bidirectional Enable path
      .ena    (ena),      // High when the design is selected
      .clk    (clk),      // System clock
      .rst_n  (rst_n)     // Active-low reset
  );

endmodule
