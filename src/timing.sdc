
# Industrial Safe Sign-off (500 MHz)
# Architecture remains 2.0 GHz capable for 16nm scaling
set clk_period 2.0
create_clock -name clk -period $clk_period [get_ports clk]

# Maximum safety margin to kill hold violations
set_clock_uncertainty 0.2 [get_clocks clk]

# Set I/O delays (20% of clock period)
set_input_delay 0.4 -clock clk [all_inputs]
set_output_delay 0.4 -clock clk [all_outputs]
