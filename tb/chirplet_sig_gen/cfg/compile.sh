#!/bin/bash

vlib work
vmap work work

#vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_buffer_v2/axis_buffer.vhd

# compile top module:
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v1/exponential_lut/exponential_rom.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v1/exponential_lut/exponential_lut.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_buffer_v2/axis_buffer.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/float_to_fixed_v1/float_to_fixed.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v1/floating_point_add.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v1/floating_point_mult.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/bram.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/axis_lut.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v1/chirplet_gen.vhd
# compile TB:
vcom -2008 -work work $TULIP_WIN/fpga_builds/tb/chirplet_sig_gen/tb_chirplet_sig_gen.vhd

# generics used in testbench:
#export generics_list=""


if [ $1 == "compile" ];then
    exit
fi

#export use_gui=$1

#if [ $use_gui == "true" ];then
#    vsim -do $origin_dir_win/cfg/sim.do
#else
#    vsim -c -do $origin_dir_win/cfg/sim.do
#fi


