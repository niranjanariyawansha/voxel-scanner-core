# Timing Constraints for 2.0 GHz Sign-off
set clk_period 0.5
create_clock -name clk -period $clk_period [get_ports clk]

# Account for 16nm clock jitter and uncertainty
set_clock_uncertainty 0.05 [get_clocks clk]

# Set I/O delays (10% of clock period)
set_input_delay 0.05 -clock clk [all_inputs]
set_output_delay 0.05 -clock clk [all_outputs]
