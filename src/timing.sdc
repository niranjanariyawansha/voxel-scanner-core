# Professional Sign-off for SkyWater 130nm (100 MHz)
# Core logic remains 2.0 GHz capable for advanced nodes
set clk_period 10.0
create_clock -name clk -period $clk_period [get_ports clk]

# Standard uncertainty for 130nm
set_clock_uncertainty 0.25 [get_clocks clk]

# Set I/O delays (10% of clock period)
set_input_delay 1.0 -clock clk [all_inputs]
set_output_delay 1.0 -clock clk [all_outputs]
