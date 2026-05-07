# Enable power analysis in PrimeTime
set power_enable_analysis TRUE

set target_library "/usr/local/synopsys/pdk/SAED32_EDK/lib/stdcell_rvt/db_nldm/saed32rvt_tt0p78v25c.db"
set link_library [list {*} $target_library]
read_db $target_library

read_verilog "../syn/conv_synthesized.v"

# {design  strip_path              vcd_file                 log_prefix}
set runs {
    {conv     conv_test/uut         ../sim/conv.vcd          conv}
    {conv     img_conv_test/uut     ../sim/img_conv.vcd      img_conv}
}

file mkdir reports

foreach run $runs {
    lassign $run design strip vcd prefix
    current_design $design
    create_clock -period 2 -name clk [find port clk]
    read_vcd -strip_path $strip $vcd
    report_power -nosplit -verbose                 > reports/${prefix}_total_power.rpt
    report_power -cell    -verbose                 > reports/${prefix}_cell_power.rpt
    report_switching_activity -list_not_annotated  > reports/${prefix}_unannotated.rpt
}
