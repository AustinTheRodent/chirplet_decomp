#!/bin/bash

vlib work
vmap work work

chirplet_gen_version=2

vcom -work work $TULIP_WIN/fpga_builds/ip_repo/fixed_to_float_v1/fixed_to_float.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/exponential_lut/exponential_rom.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/sine_lut/sine_rom.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/exponential_lut/exponential_lut.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/sine_lut/sine_lut.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_buffer_v2/axis_buffer.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/float_to_fixed_v1/float_to_fixed.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v2/floating_point_add.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/floating_point_alu_v2/floating_point_mult.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/bram.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/axis_lut_v1/axis_lut.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/complex_mult_fp.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/chirplet_gen.vhd
vcom -work work $TULIP_WIN/fpga_builds/ip_repo/chirplet_gen_v${chirplet_gen_version}/chirplet_sig_gen_parallel_samps.vhd

# compile TB:
vcom -2008 -work work $TULIP_WIN/fpga_builds/tb/chirplet_sig_gen_parallel_samps/tb_chirplet_sig_gen_parallel_samps.vhd

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


