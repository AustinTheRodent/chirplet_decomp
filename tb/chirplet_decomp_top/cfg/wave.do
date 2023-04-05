onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/clk
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/reset
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/enable
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din_valid
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din_ready
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din_last
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout_valid
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout_ready
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout_last
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din_ready_int
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout_valid_int
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/dout_last_int
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/din_last_flag
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/state
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/registered_input
add wave -noupdate /tb_chirplet_decomp_top/u_dut/u_symbol_decomp/symbol_counter
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {306 ps} 0}
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
WaveRestoreZoom {607171960 ps} {609256461 ps}
