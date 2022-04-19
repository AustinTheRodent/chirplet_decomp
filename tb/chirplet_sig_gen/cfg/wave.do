onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_chirplet_sig_gen/u_dut/time_sec
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_time_next/clk
add wave -noupdate /tb_chirplet_sig_gen/u_dut/first_samp
add wave -noupdate -radix hexadecimal /tb_chirplet_sig_gen/u_dut/u_time_next/din1
add wave -noupdate -radix hexadecimal /tb_chirplet_sig_gen/u_dut/u_time_next/din2
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_time_next/din_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_time_next/din_ready
add wave -noupdate -radix hexadecimal /tb_chirplet_sig_gen/u_dut/u_time_next/dout
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_time_next/dout_valid
add wave -noupdate /tb_chirplet_sig_gen/u_dut/u_time_next/dout_ready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {2035837 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 148
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
WaveRestoreZoom {1982695 ps} {2151383 ps}
