# Enable power analysis in PrimeTime
set power_enable_analysis TRUE

set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_lvt/db_nldm/saed32lvt_ss0p75v125c.db"
set link_library [list {*} $target_library]
read_db $target_library

read_verilog "../syn/generated/conv_synthesized.v"

# {design  strip_path              vcd_file                          log_prefix}
set runs {
    {conv     conv_test/uut         ../sim/generated/conv.vcd         conv}
    {conv     img_conv_test/uut     ../sim/generated/img_conv.vcd     img_conv}
}

file mkdir generated/reports

foreach run $runs {
    lassign $run design strip vcd prefix
    current_design $design
    create_clock -period 3 -name clk [find port clk]
    read_vcd -strip_path $strip $vcd
    report_power -nosplit -verbose                 > generated/reports/${prefix}_total_power.rpt
    report_power -cell    -verbose                 > generated/reports/${prefix}_cell_power.rpt
    report_switching_activity -list_not_annotated  > generated/reports/${prefix}_unannotated.rpt
}
