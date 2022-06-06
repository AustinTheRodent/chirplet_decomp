set generics_list $env(generics_list)
#set use_gui $env(use_gui)

set vsim_command [concat "vsim " $generics_list "-gui work.tb_chirplet_sig_gen"]
eval $vsim_command

#add wave -recursive -depth 10 *
add wave -recursive -depth 2 *
run 100000us
