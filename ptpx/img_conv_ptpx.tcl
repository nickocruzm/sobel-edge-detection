# Enable power analysis in PrimeTime
set power_enable_analysis TRUE

set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db"
set link_library [list {*} "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db"]

read_db $target_library

# Read synthesized conv netlist
read_verilog "../syn/conv_synthesized.v"

# Set top-level design
current_design conv

# 500 MHz clock (2 ns period)
create_clock -period 2 -name clk [find port clk]

# Load VCD from image convolution simulation
# strip_path removes the testbench hierarchy so activity maps to the netlist
read_vcd -strip_path img_conv_test/uut "../sim/img_conv.vcd"

# Save power reports
report_power -nosplit -verbose > img_conv_total_power.log
report_power -cell -verbose > img_conv_cell_power.log
report_switching_activity -list_not_annotated > img_conv_unannotated.log
