transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vmap -link {F:/_kar_Amuzi/Autonomous_RC_Car/Autonomous_RC_Car.cache/compile_simlib/riviera}
vlib riviera/xpm
vlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../Autonomous_RC_Car.gen/sources_1/ip/ila_0/hdl/verilog" -l xpm -l xil_defaultlib \
"G:/Xilinx/Vivado/2023.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
"G:/Xilinx/Vivado/2023.1/data/ip/xpm/xpm_memory/hdl/xpm_memory.sv" \

vcom -work xpm -93  -incr \
"G:/Xilinx/Vivado/2023.1/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../../Autonomous_RC_Car.gen/sources_1/ip/ila_0/sim/ila_0.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

