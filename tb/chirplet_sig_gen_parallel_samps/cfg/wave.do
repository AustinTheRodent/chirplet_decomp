onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_chirplet_sig_gen_parallel_samps/u_dut/dout_valid_int
add wave -noupdate /tb_chirplet_sig_gen_parallel_samps/u_dut/dout_ready
add wave -noupdate /tb_chirplet_sig_gen_parallel_samps/u_dut/dout_last_int
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {796760000 ps} 0}
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
WaveRestoreZoom {0 ps} {3281670 ns}
