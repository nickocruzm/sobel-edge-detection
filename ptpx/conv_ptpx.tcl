# Enable power analysis in PrimeTime
set power_enable_analysis TRUE

# set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db"
# set link_library [list {*} "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db"]
set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt0p78v25c.db"
set link_library [list {*} "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_tt0p78v25c.db"]

read_db $target_library

# Read conv netlist
read_verilog "../syn/generated/conv_synthesized.v"

# Set top-level design
current_design conv

#Create 500 MHz clock
create_clock -period 2 -name clk [find port clk]


# Load VCD for switching activity
read_vcd -strip_path conv_test/dut "../sim/generated/conv.vcd"

file mkdir generated

# Save power reports
report_power -nosplit -verbose > generated/total_power.log
report_power -cell -verbose > generated/cell_power.log
report_switching_activity -list_not_annotated > generated/unannotated.log
