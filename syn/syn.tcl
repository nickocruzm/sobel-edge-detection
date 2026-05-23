# Change the following to your home directory
#set HOME      "/home/csgrad/shilt003"
set HOME      "/home/csgrad/nmartinez"
set DIRECTORY   "sobel-edge-detection"

# Set search and library paths + RBVT
set_app_var search_path ${HOME}/${DIRECTORY}/rtl
#set_app_var link_path /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db
#set_app_var target_library /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db

#Search and lib path LVT - BEST SLACK
set_app_var link_path /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_ss0p75v125c.db
set_app_var target_library /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_ss0p75v125c.db

#Search and lib path HVT - WORST VIOLATED SLACK
#set_app_var link_path /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_ss0p75v125c.db
#set_app_var target_library /usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_hvt/db_nldm/saed32hvt_ss0p75v125c.db

# Power grid settings
set dc_allow_rtl_pg       true
set mw_logic1_net "VDD"
set mw_logic0_net "VSS"

# Define the design name
set DESIGN_NAME     "conv"

# Analyze the Verilog source files
analyze -format verilog "conv.v mac.v register.v shift.v"

# Elaborate the design
elaborate ${DESIGN_NAME} -architecture verilog -library DEFAULT

# Link the design to ensure all references are resolved
link

# Flatten the hierarchy to ensure all submodules are ungrouped
ungroup -all -flatten -simple_names

# Constraints
# Clock definition: 2 ns period (500 MHz), 50% duty cycle
#create_clock -name "clk" -period 2 -waveform {0 1} [get_ports "clk"]
#set_dont_touch_network [get_clocks "clk"]

# Clock definition: 4 ns period (250 MHz), 50% duty cycle
#create_clock -name "clk" -period 4 -waveform {0 1} [get_ports "clk"]
#set_dont_touch_network [get_clocks "clk"]

# Clock definition: 3 ns period (333.333 MHz), 50% duty cycle
create_clock -name "clk" -period 3 -waveform {0 1} [get_ports "clk"]
set_dont_touch_network [get_clocks "clk"]

# Input and output delays relative to clock
set_input_delay 0.1 -max -rise -clock "clk" [get_ports "reset"]
set_input_delay 0.1 -max -fall -clock "clk" [get_ports "reset"]
set_input_delay 0.1 -max -rise -clock "clk" [get_ports "pxl_in[*]"]
set_input_delay 0.1 -max -fall -clock "clk" [get_ports "pxl_in[*]"]
set_output_delay 0.1 -max -rise -clock "clk" [get_ports "pxl_out[*]"]
set_output_delay 0.1 -max -fall -clock "clk" [get_ports "pxl_out[*]"]
set_output_delay 0.1 -max -rise -clock "clk" [get_ports "valid"]
set_output_delay 0.1 -max -fall -clock "clk" [get_ports "valid"]

# Clock uncertainty for setup and hold times
set_clock_uncertainty 0.2 -setup [get_clocks "clk"]
set_clock_uncertainty 0.2 -hold [get_clocks "clk"]

# General design constraints
set_max_fanout 100 [get_designs "*"]
set_fix_multiple_port_nets -all -buffer_constants

# Design-specific constraints
set_input_transition 0.1 [get_ports "pxl_in[*]"]
set_input_transition 0.1 [get_ports "reset"]

# Set capacitive load to outputs
set_load 0.005 [get_ports "pxl_out[*]"]  ;# 5 fF in pF units (SAED32 library uses pF)
set_load 0.005 [get_ports "valid"]

# Check the design for issues
check_design

# Perform synthesis with optimization
compile_ultra -incremental

# Fix naming and hierarchy for output
change_names -rules verilog -hierarchy

# Write synthesized outputs
exec mkdir -p generated/reports
write -format ddc -output "generated/${DESIGN_NAME}_synthesized.ddc"
write -format verilog -output "generated/${DESIGN_NAME}_synthesized.v"
write_sdc -nosplit "generated/${DESIGN_NAME}_const.sdc"
write_sdf "generated/${DESIGN_NAME}_const.sdf"

# Generate reports
report_timing -transition_time -nets -attributes > ${HOME}/${DIRECTORY}/syn/generated/reports/${DESIGN_NAME}_timing_reports.log
report_qor > ${HOME}/${DIRECTORY}/syn/generated/reports/${DESIGN_NAME}_qor_reports.log
report_area -hierarchy > ${HOME}/${DIRECTORY}/syn/generated/reports/${DESIGN_NAME}_area_reports.log
report_power -hierarchy > ${HOME}/${DIRECTORY}/syn/generated/reports/${DESIGN_NAME}_power_reports.log
report_reference -hierarchy > ${HOME}/${DIRECTORY}/syn/generated/reports/${DESIGN_NAME}_reference_reports.log

# Exit the synthesis tool
exit
