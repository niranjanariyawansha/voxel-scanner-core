# Professional Sign-off for SkyWater 130nm (100 MHz)
set clk_period 10.0
create_clock -name clk -period $clk_period [get_ports clk]

# Standard uncertainty for 130nm
set_clock_uncertainty 0.25 [get_clocks clk]

# Set I/O delays - Fixed to exclude clk port
set_input_delay 1.0 -clock clk [get_ports {ui_in[*] uio_in[*] ena rst_n}]
set_output_delay 1.0 -clock clk [all_outputs]
