`default_nettype none

module vx1_sensors (
    input  wire        clk,           // 2.0 GHz System Clock
    input  wire        rst_n,         // Active low reset
    output reg  [15:0] core_temp,     // Core temperature in Celsius (Simulated)
    output reg  [15:0] core_voltage,  // Core voltage in mV (Simulated)
    output wire        status_ok      // High if chip is within sign-off limits
);

    // Simulated sensor behavior for verification
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            core_temp    <= 16'd45;   // Starts at 45°C
            core_voltage <= 16'd1200; // Starts at 1.2V
        end else begin
            // Logic to simulate heat buildup during AI processing can be added here
            core_temp    <= core_temp; 
            core_voltage <= core_voltage;
        end
    end

    // Sign-off Check: Ensure temp < 85°C and voltage > 1.0V
    assign status_ok = (core_temp < 16'd85) && (core_voltage > 16'd1000);

endmodule
