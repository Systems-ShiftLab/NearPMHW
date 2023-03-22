
set_property PULLUP true [get_ports pcie_perstn]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_perstn]

set_property PULLUP true [get_ports reset_0]



#set_clock_groups -asynchronous -group [get_clocks {}] -group [get_clocks [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT1]]]
#set_clock_groups -name cg2 -asynchronous -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]

####################################################################################
# Constraints from file : 'design_3_xdma_0_0_pcie4_ip_late.xdc'
####################################################################################

#set_clock_groups -name cg3 -asynchronous -group [get_clocks {design_3_i/xdma_0/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/design_3_xdma_0_0_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.design_3_xdma_0_0_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]


create_clock -period 10.000 -name pcie_ref_clk [get_ports pcie_refclk_clk_p]
set_false_path -from [get_ports pcie_perstn]
set_false_path -from [get_ports reset_0]
set_clock_groups -name g4 -asynchronous -group [get_clocks {design_3_i/xdma_0/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/design_3_xdma_0_0_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.design_3_xdma_0_0_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]
set_clock_groups -name g5 -asynchronous -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT1]] -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]

####################################################################################
# Constraints from file : 'design_5_xdma_0_0_pcie4_ip_late.xdc'
####################################################################################

set_clock_groups -name g1 -asynchronous -group [get_clocks {design_3_i/xdma_0/inst/pcie4_ip_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/design_3_xdma_0_0_pcie4_ip_gt_i/inst/gen_gtwizard_gtye4_top.design_3_xdma_0_0_pcie4_ip_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[32].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -group [get_clocks -of_objects [get_pins design_3_i/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT1]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
