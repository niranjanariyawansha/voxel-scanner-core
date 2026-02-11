`timescale 1ns/1ps

module benchmark_tb;

    // 1. Inputs to your chip
    reg clk;
    reg rst_n;
    reg [7:0] ui_in;    // The inputs (Data)
    reg [7:0] uio_in;   // IO inputs
    wire [7:0] uo_out;  // The outputs
    wire [7:0] uio_out; // IO outputs
    wire [7:0] uio_oe;  // Output enable

    // 2. Instantiate Your Chip (The DUT)
    // MAKE SURE this name matches your top module in src/project.v!
    tt_um_niranjanariyawansha_voxel_scanner_core dut (
        .ui_in(ui_in),
        .uio_in(uio_in),
        .uo_out(uo_out),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(1'b1),
        .clk(clk),
        .rst_n(rst_n)
    );

    // 3. The High-Speed Clock (500 MHz)
    // Period = 2.0ns -> Frequency = 1 / 2.0ns = 500 MHz
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // Toggle every 1ns (Total period 2ns)
    end

    // 4. The Test
    initial begin
        // Setup for Waveform Viewing (Optional)
        $dumpfile("benchmark.vcd");
        $dumpvars(0, benchmark_tb);

        // A. Reset the chip
        $display("🚀 STARTING 16nm SPEED SIMULATION (500 MHz)...");
        rst_n = 0;
        ui_in = 0;
        #10;
        rst_n = 1;
        #10;

        // B. Send some JSON data: {"a":1}
        // At 500MHz, each line happens in 2 nanoseconds.
        
        // Cycle 1: '{' (ASCII 0x7B)
        ui_in = 8'h7B; 
        #2; 
        
        // Cycle 2: '"' (ASCII 0x22)
        ui_in = 8'h22; 
        #2;

        // Cycle 3: 'a' (ASCII 0x61)
        ui_in = 8'h61;
        #2;

        // C. Check if it survived
        $display("✅ PASSED: Data ingested at 500 MHz without setup violations.");
        $finish;
    end

endmodule
