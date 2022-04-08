#!/bin/bash

vlib work
vmap work work

#vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_buffer_v2/axis_buffer.vhd

# compile top module:
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_buffer_v2/axis_buffer.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v1/floating_point_add.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v1/floating_point_mult.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/bram.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/axis_lut.vhd
# compile TB:
vcom -work work $TULIP_WIN/fpga_builds/tb/chirplet_sig_gen/tb_chirplet_sig_gen.vhd

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


