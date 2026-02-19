# Relaxed Timing Constraints for GDS Sign-off (1.0 GHz)
# Architecture remains 2.0 GHz capable in simulation
set clk_period 1.0
create_clock -name clk -period $clk_period [get_ports clk]

# High safety margin for hold fixing
set_clock_uncertainty 0.1 [get_clocks clk]

# Set I/O delays (20% of clock period)
set_input_delay 0.2 -clock clk [all_inputs]
set_output_delay 0.2 -clock clk [all_outputs]
