onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/din
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/din_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/din_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/din_last
add wave -noupdate -format Analog-Step -height 84 -max 87.000000000000014 -min -88.0 -radix decimal /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/dout
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/dout_ready
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_final_real_fixed/dout_last
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {92420000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {1178094 ps} {6149651 ps}
