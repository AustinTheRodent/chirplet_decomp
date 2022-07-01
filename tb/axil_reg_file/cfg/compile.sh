#!/bin/bash

vlib work
vmap work work

chirplet_gen_version=2

vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axil_reg_file_v1/axil_reg_file.vhd


# compile TB:
vcom -2008 -work work $TULIP_WIN/fpga_builds/tb/axil_reg_file/axi_lite_driver_pkg.vhd
vcom -2008 -work work $TULIP_WIN/fpga_builds/tb/axil_reg_file/tb_axil_reg_file.vhd

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


