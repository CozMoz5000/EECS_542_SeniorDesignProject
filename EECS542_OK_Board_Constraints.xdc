############################################################################
# XEM7001 - Xilinx constraints file
# Edited by: Austin Cosner 4/4/2017
############################################################################
set_property BITSTREAM.GENERAL.COMPRESS True [current_design]

set_property PACKAGE_PIN K12 [get_ports {HI_MuxSel}]
set_property IOSTANDARD LVCMOS33 [get_ports {HI_MuxSel}]

############################################################################
## FrontPanel Host Interface
############################################################################
set_property PACKAGE_PIN N11 [get_ports {HI_In[0]}]
set_property PACKAGE_PIN R13 [get_ports {HI_In[1]}]
set_property PACKAGE_PIN R12 [get_ports {HI_In[2]}]
set_property PACKAGE_PIN P13 [get_ports {HI_In[3]}]
set_property PACKAGE_PIN T13 [get_ports {HI_In[4]}]
set_property PACKAGE_PIN T12 [get_ports {HI_In[5]}]
set_property PACKAGE_PIN P11 [get_ports {HI_In[6]}]
set_property PACKAGE_PIN R10 [get_ports {HI_In[7]}]

set_property SLEW FAST [get_ports {HI_In[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HI_In[*]}]

set_property PACKAGE_PIN R15 [get_ports {HI_Out[0]}]
set_property PACKAGE_PIN N13 [get_ports {HI_Out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HI_Out[*]}]

set_property PACKAGE_PIN T15 [get_ports {HI_InOut[0]}]
set_property PACKAGE_PIN T14 [get_ports {HI_InOut[1]}]
set_property PACKAGE_PIN R16 [get_ports {HI_InOut[2]}]
set_property PACKAGE_PIN P16 [get_ports {HI_InOut[3]}]
set_property PACKAGE_PIN P15 [get_ports {HI_InOut[4]}]
set_property PACKAGE_PIN N16 [get_ports {HI_InOut[5]}]
set_property PACKAGE_PIN M16 [get_ports {HI_InOut[6]}]
set_property PACKAGE_PIN M12 [get_ports {HI_InOut[7]}]
set_property PACKAGE_PIN L13 [get_ports {HI_InOut[8]}]
set_property PACKAGE_PIN K13 [get_ports {HI_InOut[9]}]
set_property PACKAGE_PIN M14 [get_ports {HI_InOut[10]}]
set_property PACKAGE_PIN L14 [get_ports {HI_InOut[11]}]
set_property PACKAGE_PIN K16 [get_ports {HI_InOut[12]}]
set_property PACKAGE_PIN K15 [get_ports {HI_InOut[13]}]
set_property PACKAGE_PIN J14 [get_ports {HI_InOut[14]}]
set_property PACKAGE_PIN J13 [get_ports {HI_InOut[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {HI_InOut[*]}]

set_property PACKAGE_PIN M15 [get_ports {HI_AA}]
set_property IOSTANDARD LVCMOS33 [get_ports {HI_AA}]


create_clock -name okHostClk -period 20.83 [get_ports {HI_In[0]}]

set_input_delay -add_delay -max -clock [get_clocks {okHostClk}]  11.000 [get_ports {HI_InOut[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okHostClk}]  0.000  [get_ports {HI_InOut[*]}]
set_multicycle_path -setup -from [get_ports {HI_InOut[*]}] 2

set_input_delay -add_delay -max -clock [get_clocks {okHostClk}]  6.700 [get_ports {HI_In[*]}]
set_input_delay -add_delay -min -clock [get_clocks {okHostClk}]  0.000 [get_ports {HI_In[*]}]
set_multicycle_path -setup -from [get_ports {HI_In[*]}] 2

set_output_delay -add_delay -clock [get_clocks {okHostClk}]  8.900 [get_ports {HI_Out[*]}]

set_output_delay -add_delay -clock [get_clocks {okHostClk}]  9.200 [get_ports {HI_InOut[*]}]

# Board Clock ##############################################################
set_property IOSTANDARD LVCMOS33 [get_ports {CLK}]
set_property PACKAGE_PIN N14 [get_ports {CLK}]

# LEDs #####################################################################
set_property PACKAGE_PIN H5 [get_ports {LED[0]}]
set_property PACKAGE_PIN F3 [get_ports {LED[1]}]
set_property PACKAGE_PIN E3 [get_ports {LED[2]}]
set_property PACKAGE_PIN H4 [get_ports {LED[3]}]
set_property PACKAGE_PIN D3 [get_ports {LED[4]}]
set_property PACKAGE_PIN C3 [get_ports {LED[5]}]
set_property PACKAGE_PIN H3 [get_ports {LED[6]}]
set_property PACKAGE_PIN A4 [get_ports {LED[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED[*]}]
